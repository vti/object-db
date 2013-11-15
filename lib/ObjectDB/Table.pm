package ObjectDB::Table;

use strict;
use warnings;

require Carp;
use SQL::Builder;
use ObjectDB;
use ObjectDB::Quoter;
use ObjectDB::With;
use ObjectDB::Meta;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub meta {
    my $self = shift;

    return $self->{class}->meta;
}

sub dbh {
    my $self = shift;

    return $self->{dbh};
}

sub find {
    my $self = shift;
    my (%params) = @_;

    $params{with} ||= [];
    $params{with} = [$params{with}] unless ref $params{with} eq 'ARRAY';

    my $single = delete $params{single} || delete $params{first};

    unless ($single) {
        my $page = delete $params{page};
        my $page_size = delete $params{page_size} || 10;

        if (defined $page) {
            $page = 1 unless $page && $page =~ m/^[0-9]+$/o;
            $params{offset} = ($page - 1) * $page_size;
            $params{limit}  = $page_size;
        }
    }

    my $quoter = ObjectDB::Quoter->new(meta => $self->meta);
    my $where = SQL::Builder::Expression->new(
        quoter         => $quoter,
        expr           => $params{where},
        default_prefix => $self->meta->table
    );
    my $with = ObjectDB::With->new(
        meta => $self->meta,
        with => [@{$params{with}}, $quoter->with]
    );

    my $select = SQL::Builder->build(
        'select',
        from     => $self->meta->table,
        columns  => [$self->meta->get_columns],
        join     => $with->to_joins,
        where    => $where,
        limit    => $params{limit},
        offset   => $params{offset},
        order_by => $params{order_by},
        group_by => $params{group_by},
    );

    my $rows = $self->_execute($select);
    return unless $rows && @$rows;

    my @objects =
      map { $self->meta->class->new(%{$_}) } @{$select->from_rows($rows)};

    return $single ? $objects[0] : @objects;
}

sub update {
    my $self = shift;
    my (%params) = @_;

    my $sql = SQL::Builder->build(
        'update',
        table => $self->meta->table,
        %params
    );

    return $self->dbh->do($sql->to_sql, undef, $sql->to_bind);
}

sub delete {
    my $class = shift;

    my $dbh = $class->dbh;

    my $sql = SQL::Builder->build(
        'delete',
        from => $class->meta->table,
        @_
    );

    my $sth = $dbh->prepare($sql->to_sql);

    return $sth->execute($sql->to_bind);
}

sub count {
    my $self = shift;
    my (%params) = @_;

    my $dbh = $self->dbh;

    my $quoter = ObjectDB::Quoter->new(meta => $self->meta);
    my $where = SQL::Builder::Expression->new(
        quoter         => $quoter,
        expr           => $params{where},
        default_prefix => $self->meta->table
    );
    my $with =
      ObjectDB::With->new(meta => $self->meta, with => [$quoter->with]);

    my $select = SQL::Builder->build(
        'select',
        from    => $self->meta->table,
        columns => [{-col => \'COUNT(*)', -as => 'count'}],
        where   => $where,
        join    => $with->to_joins
    );

    my $sql  = $select->to_sql;
    my @bind = $select->to_bind;

    my $sth = $dbh->prepare($sql);
    $sth->execute(@bind);

    my $results = $sth->fetchall_arrayref;
    my $object  = $select->from_rows($results);

    return $object->[0]->{count};
}

sub drop {
    my $self = shift;

    die 'implement';
}

sub _execute {
    my $self = shift;
    my ($stmt) = @_;

    my $sql = $stmt->to_sql;
    my @bind = $stmt->to_bind;

    eval {
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@bind);
        return $sth->fetchall_arrayref;
    } or do {
        my $e = $@;

        Carp::croak($e);
    };
}

1;
