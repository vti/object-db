package ObjectDB;

use strict;
use warnings;

require Carp;
use Scalar::Util ();
use SQL::Builder;
use ObjectDB::DBHPool;
use ObjectDB::Meta;
use ObjectDB::Quoter;
use ObjectDB::RelatedFactory;
use ObjectDB::Table;
use ObjectDB::With;

our $VERSION = '3.00';

$Carp::Internal{(__PACKAGE__)}++;
$Carp::Internal{"ObjectDB::$_"}++ for qw/
  With
  Related
  Related::ManyToOne
  Related::OneToOne
  Related::ManyToMany
  Related::OneToMany
  Meta::Relationship
  Meta::Relationship::ManyToOne
  Meta::Relationship::OneToOne
  Meta::Relationship::ManyToMany
  Meta::Relationship::OneToMany
  Meta::RelationshipFactory
  Base
  Table
  Util
  Quoter
  DBHPool
  Meta
  RelationshipFactory
  /;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my (%columns) = @_;

    my $self = {};
    bless $self, $class;

    foreach my $column (keys %columns) {
        if (   $self->meta->is_column($column)
            || $self->meta->is_relationship($column))
        {
            $self->set_column($column => $columns{$column});
        }
    }

    $self->{is_in_db}    = 0;
    $self->{is_modified} = 0;

    $self->{related_factory} ||= ObjectDB::RelatedFactory->new;

    return $self;
}

sub is_in_db {
    my $self = shift;

    return $self->{is_in_db};
}

sub is_modified {
    my $self = shift;

    return $self->{is_modified};
}

sub init_db {
    my $self = shift;

    no strict;

    my $class = ref($self) ? ref($self) : $self;

    if (@_) {
        if (@_ == 1 && ref $_[0]) {
            ${"$class\::DBH"} = shift;
        }
        else {
            ${"$class\::DBH"} = ObjectDB::DBHPool->new(@_);
        }

        return $self;
    }

    my $dbh = ${"$class\::DBH"};

    if (!$dbh) {
        foreach my $parent (_get_parents($class)) {
            if ($dbh = ${"$parent\::DBH"}) {
                last;
            }
        }
    }

    Carp::croak('Setup a dbh first') unless $dbh;

    return $dbh->isa('ObjectDB::DBHPool')
      ? $dbh->dbh
      : $dbh;
}

sub txn {
    my $self = shift;
    my ($cb) = @_;

    my $dbh = $self->init_db;

    return eval {
        $dbh->{AutoCommit} = 0;

        my $retval = $cb->($self);

        $self->commit;

        return $retval;
    } || do {
        my $e = $@;

        $self->rollback;

        Carp::croak($e);
    };
}

sub commit {
    my $self = shift;

    my $dbh = $self->init_db();

    if ($dbh->{AutoCommit} == 0) {
        $dbh->commit();
        $dbh->{AutoCommit} = 1;
    }

    return $self;
}

sub rollback {
    my $self = shift;

    my $dbh = $self->init_db();

    if ($dbh->{AutoCommit} == 0) {
        $dbh->rollback();
        $dbh->{AutoCommit} = 1;
    }

    return $self;
}

sub meta {
    my $class = shift;
    $class = ref $class if ref $class;

    return ObjectDB::Meta->find_or_register_meta($class, @_);
}

sub table {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;

    return ObjectDB::Table->new(class => $class, dbh => $self->init_db);
}

sub columns {
    my $self = shift;

    my @columns;
    foreach my $key ($self->meta->columns) {
        if (exists $self->{columns}->{$key}) {
            push @columns, $key;
        }
    }

    return @columns;
}

sub column {
    my $self = shift;

    $self->{columns} ||= {};

    if (@_ == 1) {
        return $self->get_column(@_);
    }
    elsif (@_ == 2) {
        $self->set_column(@_);
    }

    return $self;
}

sub get_column {
    my $self = shift;
    my ($name) = @_;

    if ($self->meta->is_column($name)) {
        unless (exists $self->{columns}->{$name}) {
            if (exists $self->meta->get_column($name)->{default}) {
                my $default = $self->meta->get_column($name)->{default};
                return ref $default eq 'CODE' ? $default->() : $default;
            }
            else {
                return;
            }
        }

        return $self->{columns}->{$name};
    }
    elsif ($self->meta->is_relationship($name)) {
        return
          exists $self->{relationships}->{$name}
          ? $self->{relationships}->{$name}
          : undef;
    }
    else {
        return $self->{virtual_columns}->{$name};
    }
}

sub set_columns {
    my $self = shift;
    my %values = ref $_[0] ? %{$_[0]} : @_;

    while (my ($key, $value) = each %values) {
        $self->set_column($key => $value);
    }

    return $self;
}

sub set_column {
    my $self = shift;
    my ($name, $value) = @_;

    if ($self->meta->is_column($name)) {
        if (not defined $value
            && !$self->meta->get_column($name)->{is_null})
        {
            $value = '';
        }

        if (
            !exists $self->{columns}->{$name}
            || !(
                   (defined $self->{columns}->{$name} && defined $value)
                && ($self->{columns}->{$name} eq $value)
            )
          )
        {
            $self->{columns}->{$name} = $value;
            $self->{is_modified} = 1;
        }
    }
    elsif ($self->meta->is_relationship($name)) {
        if (!Scalar::Util::blessed($value)) {
            $value = $self->meta->get_relationship($name)->class->new(%$value);
        }

        $self->{relationships}->{$name} = $value;
    }
    else {
        $self->{virtual_columns}->{$name} = $value;
    }

    return $self;
}

sub clone {
    my $self = shift;

    my %data;
    foreach my $column ($self->meta->columns) {
        next
          if $self->meta->is_primary_key($column)
          || $self->meta->is_unique_key($column);
        $data{$column} = $self->column($column);
    }

    return (ref $self)->new->set_columns(%data);
}

sub create {
    my $self = shift;

    return $self if $self->is_in_db;

    my $dbh = $self->init_db;

    my $sql = SQL::Builder->build(
        'insert',
        into   => $self->meta->table,
        values => [map { $_ => $self->{columns}->{$_} } $self->columns]
    );

    my $sth = $dbh->prepare($sql->to_sql);
    my $rv  = $sth->execute($sql->to_bind);
    return unless $rv;

    if (my $auto_increment = $self->meta->auto_increment) {
        $self->set_column(
            $auto_increment => $dbh->last_insert_id(
                undef, undef, $self->meta->table, $auto_increment
            )
        );
    }

    $self->{is_in_db}    = 1;
    $self->{is_modified} = 0;

    foreach my $rel (keys %{$self->meta->relationships}) {
        if (my $rel_values = $self->{relationships}->{$rel}) {
            $self->{relationships}->{$rel} =
              $self->create_related($rel, $rel_values);
        }
    }

    return $self;
}

sub find { shift->table->find(@_) }

sub load {
    my $self = shift;
    my (%params) = @_;

    my @columns;

    foreach my $name ($self->columns) {
        push @columns, $name if $self->meta->is_primary_key($name);
    }

    if (!@columns) {
        foreach my $name ($self->columns) {
            push @columns, $name if $self->meta->is_unique_key($name);
        }
    }

    Carp::croak(ref($self) . ": no primary or unique keys specified")
      unless @columns;

    my $where = [map { $_ => $self->{columns}->{$_} } @columns];

    my $with = ObjectDB::With->new(meta => $self->meta, with => $params{with});

    my $select = SQL::Builder->build(
        'select',
        columns    => [$self->meta->get_columns],
        from       => $self->meta->table,
        where      => $where,
        join       => $with->to_joins,
        limit      => 1,
        for_update => $params{for_update},
    );

    my $sql  = $select->to_sql;
    my @bind = $select->to_bind;

    my $dbh = $self->init_db;

    my $sth = $dbh->prepare($sql);
    $sth->execute(@bind);

    my $results = $sth->fetchall_arrayref;
    return unless $results && @$results;

    my $object = $select->from_rows($results);

    $self->set_columns(%{$object->[0]});

    $self->{is_modified} = 0;
    $self->{is_in_db}    = 1;

    return $self;
}

sub update {
    my $self = shift;

    return $self unless $self->is_modified;

    my %where;
    foreach my $name ($self->columns) {
        $where{$name} = $self->{columns}->{$name}
          if $self->meta->is_primary_key($name);
    }

    if (!keys %where) {
        foreach my $name ($self->columns) {
            $where{$name} = $self->{columns}->{$name}
              if $self->meta->is_unique_key($name);
        }
    }

    Carp::croak(ref($self) . ": no primary or unique keys specified")
      unless keys %where;

    my $dbh = $self->init_db;

    my @columns = grep { !$self->meta->is_primary_key($_) } $self->columns;
    my @values  = map  { $self->{columns}->{$_} } @columns;

    my %set;
    @set{@columns} = @values;
    my $sql = SQL::Builder->build(
        'update',
        table  => $self->meta->table,
        values => [%set],
        where  => [%where]
    );

    my $sth = $dbh->prepare($sql->to_sql);
    my $rv  = $sth->execute($sql->to_bind);
    Carp::croak("Object was not updated") if $rv eq '0E0';

    $self->{is_modified} = 0;
    $self->{is_in_db}    = 1;

    return $rv;
}

sub delete : method {
    my $self = shift;

    my %where;
    foreach my $name ($self->columns) {
        $where{$name} = $self->{columns}->{$name}
          if $self->meta->is_primary_key($name);
    }

    if (!keys %where) {
        foreach my $name ($self->columns) {
            $where{$name} = $self->{columns}->{$name}
              if $self->meta->is_unique_key($name);
        }
    }

    Carp::croak(ref($self) . ": no primary or unique keys specified")
      unless keys %where;

    my $dbh = $self->init_db;

    my $sql = SQL::Builder->build(
        'delete',
        from  => $self->meta->table,
        where => [%where]
    );

    my $sth = $dbh->prepare($sql->to_sql);

    my $rv = $sth->execute($sql->to_bind);
    Carp::croak("Object was not deleted") if $rv eq '0E0';

    %$self = ();

    return $self;
}

sub to_hash {
    my $self = shift;

    my $hash = {};

    foreach my $key ($self->meta->get_columns) {
        if (exists $self->{columns}->{$key}) {
            $hash->{$key} = $self->get_column($key);
        }
        elsif (exists $self->meta->get_column($key)->{default}) {
            $hash->{$key} = $self->get_column($key);
        }
    }

    foreach my $key (keys %{$self->{virtual_columns}}) {
        $hash->{$key} = $self->get_column($key);
    }

    foreach my $name (keys %{$self->{relationships}}) {
        my $rel = $self->{relationships}->{$name};

        Carp::croak("unknown '$name' relationship") unless $rel;

        $hash->{$name} = $rel->to_hash;
    }

    return $hash;
}

sub is_related_loaded {
    my $self = shift;
    my ($name) = @_;

    return exists $self->{relationships}->{$name};
}

sub related {
    my $self = shift;
    my ($name) = shift;

    if (!$self->{relationships}->{$name}) {
        $self->{relationships}->{$name} =
          wantarray
          ? [$self->find_related($name, @_)]
          : $self->find_related($name, @_);
    }

    my $related = $self->{relationships}->{$name};

    return
        wantarray
      ? ref $related eq 'ARRAY'
          ? @$related
          : ($related)
      : $related;
}

sub find_related   { shift->_do_related('find',   @_) }
sub create_related { shift->_do_related('create', @_) }
sub update_related { shift->_do_related('update', @_) }
sub count_related  { shift->_do_related('count',  @_) }
sub delete_related { shift->_do_related('delete', @_) }

sub _do_related {
    my $self   = shift;
    my $action = shift;
    my $name   = shift;

    Carp::croak('Relationship name is required') unless $name;

    my $related = $self->_build_related($name);

    my $method = "$action\_related";
    return $related->$method($self, @_);
}

sub _build_related {
    my $self = shift;
    my ($name) = @_;

    my $meta = $self->meta->get_relationship($name);

    return $self->{related_factory}->build($meta->type, meta => $meta);
}

sub _get_parents {
    my ($for_class) = @_;

    my @parents;

    no strict 'refs';

    foreach my $sub_class (@{"${for_class}::ISA"}) {
        push @parents, _get_parents($sub_class)
          if $sub_class->isa('ObjectDB') && $sub_class ne 'ObjectDB';
    }

    return $for_class, @parents;
}

1;
