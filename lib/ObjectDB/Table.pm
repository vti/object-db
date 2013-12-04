package ObjectDB::Table;

use strict;
use warnings;

our $VERSION = '3.00';

use constant DEFAULT_PAGE_SIZE => 10;

require Carp;
use SQL::Composer;
use SQL::Composer::Expression;
use ObjectDB;
use ObjectDB::Quoter;
use ObjectDB::With;
use ObjectDB::Meta;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{class} = $params{class};
    $self->{dbh}   = $params{dbh};

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
        my $page_size = delete $params{page_size} || DEFAULT_PAGE_SIZE;

        if (defined $page) {
            $page = 1 unless $page && $page =~ m/^\d+$/smx;
            $params{offset} = ($page - 1) * $page_size;
            $params{limit}  = $page_size;
        }
    }

    my $quoter = ObjectDB::Quoter->new(meta => $self->meta);
    my $where = SQL::Composer::Expression->new(
        quoter         => $quoter,
        expr           => $params{where},
        default_prefix => $self->meta->table
    );
    my $with = ObjectDB::With->new(
        meta => $self->meta,
        with => [@{$params{with}}, $quoter->with]
    );

    my $select = SQL::Composer->build(
        'select',
        from       => $self->meta->table,
        columns    => [$self->meta->get_columns],
        join       => $with->to_joins,
        where      => $where,
        limit      => $params{limit},
        offset     => $params{offset},
        order_by   => $params{order_by},
        group_by   => $params{group_by},
        for_update => $params{for_update},
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

    my $sql = SQL::Composer->build(
        'update',
        table => $self->meta->table,
        set   => $params{set},
        where => $params{where},
    );

    return $self->dbh->do($sql->to_sql, undef, $sql->to_bind);
}

sub delete : method {
    my $class = shift;
    my (%params) = @_;

    my $dbh = $class->dbh;

    my $sql = SQL::Composer->build(
        'delete',
        from  => $class->meta->table,
        where => $params{where},
    );

    my $sth = $dbh->prepare($sql->to_sql);

    return $sth->execute($sql->to_bind);
}

sub count {
    my $self = shift;
    my (%params) = @_;

    my $dbh = $self->dbh;

    my $quoter = ObjectDB::Quoter->new(meta => $self->meta);
    my $where = SQL::Composer::Expression->new(
        quoter         => $quoter,
        expr           => $params{where},
        default_prefix => $self->meta->table
    );
    my $with =
      ObjectDB::With->new(meta => $self->meta, with => [$quoter->with]);

    my $select = SQL::Composer->build(
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

    my $results    = $sth->fetchall_arrayref;
    my $row_object = $select->from_rows($results);

    return $row_object->[0]->{count};
}

sub _execute {
    my $self = shift;
    my ($stmt) = @_;

    my $sql  = $stmt->to_sql;
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
