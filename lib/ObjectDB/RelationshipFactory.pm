package ObjectDB::RelationshipFactory;

use strict;
use warnings;

use ObjectDB::Util qw(load_class);

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub namespace {'ObjectDB::Relationship::'}

sub build {
    my $self   = shift;
    my $type   = shift;
    my %params = @_;

    die 'type is required' unless $type;

    my @parts = map {ucfirst} split(' ', $type);
    my $rel_class = $self->namespace . join('', @parts);

    load_class $rel_class;

    return $rel_class->new(%params);
}

1;
