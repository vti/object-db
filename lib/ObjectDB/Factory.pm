package ObjectDB::Factory;

use strict;
use warnings;

require Carp;
use ObjectDB::Util qw(load_class);

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub namespace { Carp::croak('implement') }

sub build {
    my $self   = shift;
    my $type   = shift;
    my %params = @_;

    Carp::croak('type is required') unless $type;

    my @parts = map { ucfirst } split(' ', $type);
    my $rel_class = $self->namespace . join('', @parts);

    load_class $rel_class;

    return $rel_class->new(%params);
}

1;
