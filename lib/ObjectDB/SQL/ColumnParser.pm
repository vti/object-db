package ObjectDB::SQL::ColumnParser;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = bless {@_}, $class;

    return $self;
}

sub parse_column {
    my $self = shift;
    my ($column) = @_;

    return $column;
}

1;
