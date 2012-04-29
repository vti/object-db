package ObjectDB::Table;

use strict;
use warnings;

require Carp;
use ObjectDB::SQLBuilder;
use ObjectDB::Meta;
use ObjectDB::Iterator;
use ObjectDB::Mapper;

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

    my $mapper = ObjectDB::Mapper->new(meta => $self->meta);

    my ($sql, @bind) = $mapper->to_sql(%params);

    my $sth = $self->dbh->prepare($sql);
    $sth->execute(@bind);

    my $rows = $sth->fetchall_arrayref;
    return unless $rows && @$rows;

    my @objects;
    foreach my $row (@$rows) {
        push @objects, $mapper->from_row($row);
    }

    return $single ? $objects[0] : @objects;
}

sub update {
    my $self = shift;
    my (%params) = @_;

    my $sql = ObjectDB::SQLBuilder->build(
        'update',
        table => $self->meta->table,
        %params
    );

    return $self->dbh->do($sql->to_string, undef, @{$sql->bind});
}

sub delete {
    my $class = shift;

    my $dbh = $class->dbh;

    my $sql = ObjectDB::SQLBuilder->build(
        'delete',
        table => $class->meta->table,
        @_
    );

    my $sth = $dbh->prepare($sql->to_string);

    return $sth->execute(@{$sql->bind});
}

sub count {
    my $self = shift;
    my (%params) = @_;

    my $dbh = $self->dbh;

    my $mapper = ObjectDB::Mapper->new(meta => $self->meta);

    my ($sql, @bind) = $mapper->to_sql(
        columns => [{name => \'COUNT(*)', as => 'count'}],
        %params
    );

    my $sth = $dbh->prepare($sql);
    $sth->execute(@bind);

    my $results = $sth->fetchall_arrayref;
    my $object = $mapper->from_row($results->[0]);

    return $object->get_column('count');
}

sub drop {
    my $self = shift;

    my $sql = ObjectDB::SQL::Query::DropTable->new(table => $self->meta->table);

    return !!$self->dbh->do($sql->to_string);
}

1;
