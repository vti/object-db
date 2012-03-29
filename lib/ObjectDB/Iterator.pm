package ObjectDB::Iterator;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub next {
    my $self = shift;

    return $self->{walker}->($self);
}

1;
