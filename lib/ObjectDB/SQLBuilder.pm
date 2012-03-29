package ObjectDB::SQLBuilder;

use strict;
use warnings;

sub build {
    my $class = shift;
    my $command = shift;

    die 'command is required' unless $command;

    my $command_class = 'ObjectDB::SQL::Query::' . ucfirst $command;
    eval "require $command_class;";

    die "command $command_class is unknown: $@" if $@;

    return $command_class->new(@_);
}

1;
