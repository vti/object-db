package ObjectDB::Meta;

use strict;
use warnings;

require Storable;
require Carp;
use List::Util qw(first);

use ObjectDB::Meta::RelationshipFactory;

our %objects;

sub new {
    my $class = shift;
    my (%params) = @_;

    Carp::croak('Class is required when building meta') unless $params{class};

    if (my $parent = $class->_is_inheriting($params{class})) {
        return $parent;
    }

    Carp::croak('Table is required when building meta') unless $params{table};

    my $self = {
        class => $params{class},
        table => $params{table}
    };
    bless $self, $class;

    $self->set_columns($params{columns});
    $self->set_primary_key($params{primary_key}) if $params{primary_key};
    $self->set_unique_keys($params{unique_keys}) if $params{unique_keys};
    $self->set_auto_increment($params{auto_increment}) if $params{auto_increment};

    $self->_build_relationships($params{relationships});

    return $self;
}

sub class          { $_[0]->{class} }
sub table          { $_[0]->{table} }
sub relationships  { $_[0]->{relationships} }
sub column         { shift->get_column(@_); }
sub columns        { $_[0]->get_columns; }
sub primary_key    { $_[0]->get_primary_key; }
sub auto_increment { $_[0]->get_auto_increment; }

sub is_primary_key {
    my $self = shift;
    my ($name) = @_;

    return !!first {$name eq $_} $self->get_primary_key;
}

sub is_unique_key {
    my $self = shift;
    my ($name) = @_;

    foreach my $key (@{$self->{unique_keys}}) {
        return 1 if first {$name eq $_} @$key;
    }

    return 0;
}

sub get_class {
    my $self = shift;

    return $self->{class};
}

sub get_table {
    my $self = shift;

    return $self->{table};
}

sub set_table {
    my $self = shift;
    my ($value) = @_;

    $self->{table} = $value;

    return $self;
}

sub is_column {
    my $self = shift;
    my ($name) = @_;

    die 'Name is required' unless $name;

    return !!first { $name eq $_->{name} } @{$self->{columns}};
}

sub get_column {
    my $self = shift;
    my ($name) = @_;

    Carp::croak("Unknown column '$name'") unless $self->is_column($name);

    return first { $_->{name} eq $name } @{$self->{columns}};
}

sub get_columns {
    my $self = shift;

    return map { $_->{name} } @{$self->{columns}};
}

sub get_regular_columns {
    my $self = shift;

    my @columns;

    foreach my $column ($self->get_columns) {
        next if first { $column eq $_ } $self->get_primary_key;

        push @columns, $column;
    }

    return @columns;
}

sub set_columns {
    my $self = shift;

    $self->{columns} = [];

    $self->add_columns(@_);

    return $self;
}

sub add_columns {
    my $self = shift;
    my (@columns) = @_ == 1 && ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    my $count = 0;
    while (my ($name, $options) = @columns[$count, $count + 1]) {
        last unless $name;

        if (ref $options eq 'HASH') {
            $self->add_column($name, $options);
        }
        else {
            $self->add_column($name);

            $count++;
            next;
        }

        $count += 2;
    }

    return $self;
}

sub add_column {
    my $self = shift;
    my ($name, $attributes) = @_;

    Carp::croak('Name is required') unless $name;
    Carp::croak("Column '$name' already exists") if $self->is_column($name);

    $attributes ||= {};

    push @{$self->{columns}}, {name => $name, %$attributes};

    return $self;
}

sub remove_column {
    my $self = shift;
    my ($name) = @_;

    return unless $name && $self->is_column($name);

    $self->{columns} = [grep { $_->{name} ne $name } @{$self->{columns}}];

    return $self;
}

sub get_primary_key {
    my $self = shift;

    return @{$self->{primary_key} || []};
}

sub set_primary_key {
    my $self = shift;
    my (@columns) = @_ == 1 && ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    foreach my $column (@columns) {
        Carp::croak("Unknown column '$column'") unless $self->is_column($column);
    }

    $self->{primary_key} = [@columns];

    return $self;
}

sub get_unique_keys {
    my $self = shift;

    return @{$self->{unique_keys}};
}

sub set_unique_keys {
    my $self = shift;
    my (@columns) = @_ == 1 && ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    $self->{unique_keys} = [];

    $self->add_unique_keys(@columns);

    return $self;
}

sub add_unique_keys {
    my $self = shift;
    my (@columns) = @_ == 1 && ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    foreach my $column (@columns) {
        $self->add_unique_key($column);
    }

    return $self;
}

sub add_unique_key {
    my $self = shift;
    my (@columns) = @_ == 1 && ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    foreach my $column (@columns) {
        Carp::croak("Unknown column '$column'") unless $self->is_column($column);
    }

    push @{$self->{unique_keys}}, [@columns];

    return $self;
}

sub get_auto_increment {
    my $self = shift;

    return $self->{auto_increment};
}

sub set_auto_increment {
    my $self = shift;
    my ($column) = @_;

    Carp::croak("Unknown column '$column'") unless $self->is_column($column);

    $self->{auto_increment} = $column;

    return $self;
}

sub is_relationship {
    my $self = shift;
    my ($name) = @_;

    return exists $self->{relationships}->{$name};
}

sub get_relationship {
    my $self = shift;
    my ($name) = @_;

    Carp::croak("Unknown relationship '$name'")
      unless exists $self->{relationships}->{$name};

    return $self->{relationships}->{$name};
}

sub add_relationship {
    my $self = shift;
    my ($name, $options) = @_;

    Carp::croak("Name and options are required") unless $name && $options;

    $self->{relationships}->{$name} =
      ObjectDB::Meta::RelationshipFactory->new->build($options->{type}, %$options,
        orig_class => $self->get_class);
}

sub add_relationships {
    my $self = shift;

    my $count = 0;
    while (my ($name, $options) = @_[$count, $count + 1]) {
        last unless $name && $options;

        $self->add_relationship($name, $options);

        $count += 2;
    }
}

sub _build_relationships {
    my $self = shift;
    my ($relationships) = @_;

    $self->{relationships} ||= {};

    foreach my $rel (keys %{$relationships}) {
        $self->{relationships}->{$rel} =
          ObjectDB::Meta::RelationshipFactory->new->build($relationships->{$rel}->{type}, %{$relationships->{$rel}},
            orig_class => $self->{class});
    }
}

sub _is_inheriting {
    my $class = shift;
    my ($for_class) = @_;

    foreach my $parent (_get_parents($for_class)) {
        if (my $parent_meta = $objects{$parent}) {
            my $meta = Storable::dclone($parent_meta);

            $meta->{class} = $for_class;

            return $meta;
        }
    }

    return;
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
