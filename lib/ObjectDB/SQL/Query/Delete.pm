package ObjectDB::SQL::Query::Delete;

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

    my $query = '';

    $query .= 'DELETE FROM ' . $self->_quote_column($self->{table});

    $query .= $self->_build_where;

    $query .= $self->_build_order_by;

    $query .= $self->_build_limits;

    return $query;
}

1;
