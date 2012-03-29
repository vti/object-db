package ObjectDB::SQL::Quoter;

use strict;
use warnings;

use ObjectDB::SQL::Util qw(quote prefix);

sub new {
    my $class = shift;

    my $self = bless {@_}, $class;

    return $self;
}

sub quote_column {
    my $self = shift;
    my ($column, $prefix) = @_;

    return $prefix ? quote(prefix($column, $prefix)) : quote($column);
}

sub prefix_column {
    my $self = shift;

    return prefix(@_);
}

1;
