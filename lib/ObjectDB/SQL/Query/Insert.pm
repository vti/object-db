package ObjectDB::SQL::Query::Insert;

use strict;
use warnings;

use base 'ObjectDB::SQL';

use ObjectDB::SQL::Util qw(quote prefix);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{set} ||= {};

    return $self;
}

sub to_string {
    my $self = shift;

    $self->{bind} = [];

    my $query = "";

    $query .= 'INSERT INTO ';
    $query .= quote($self->{table});

    my @bind;
    my @columns;
    foreach my $column (sort keys %{$self->{set}}) {
        my $value = $self->{set}->{$column};

        push @columns, quote($column);

        if (ref $value eq 'SCALAR') {
            push @bind, $$value;
        }
        else {
            push @{$self->{bind}}, $value;
            push @bind, '?';
        }
    }

    $query .= ' (' . join(', ', @columns) . ')';

    $query .= ' VALUES (' . join(', ', @bind) . ')';

    return $query;
}

1;
