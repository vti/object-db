package ObjectDB::SQL::Query::Update;

use strict;
use warnings;

use base 'ObjectDB::SQL::Query';

use ObjectDB::SQL::Expression;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{set} ||= {};

    return $self;
}

sub to_string {
    my $self = shift;

    $self->{bind} = [];

    my $query = "";

    $query .= 'UPDATE ';
    $query .= $self->_quote_column($self->{table});
    $query .= ' SET ';

    my @columns;
    foreach my $column (sort keys %{$self->{set}}) {
        my $value = $self->{set}->{$column};

        my $q = '?';

        if (ref $value eq 'SCALAR') {
            $q     = $$value;
            $value = undef;
        }
        elsif (ref $value eq 'HASH') {
            my ($k, $v) = %$value;
            if ($k eq '-col') {
                $q     = $self->_quote_column($v);
                $value = undef;
            }
        }

        push @columns, $self->_quote_column($column) . " = $q";
        push @{$self->{bind}}, $value if defined $value;
    }

    $query .= join ', ', @columns;

    $query .= $self->_build_where;

    $query .= $self->_build_order_by;

    $query .= $self->_build_limits;

    return $query;
}

1;
