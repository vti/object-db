package ObjectDB::Meta::Relationship;

use strict;
use warnings;

use ObjectDB::Util qw(load_class);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{name}       = $params{name};
    $self->{type}       = $params{type};
    $self->{orig_class} = $params{orig_class};
    $self->{class}      = $params{class};
    $self->{map}        = $params{map};
    $self->{join}       = $params{join};

    return $self;
}

sub name { $_[0]->{name} }
sub map  { $_[0]->{map} }

sub orig_class {
    my $self = shift;

    my $orig_class = $self->{orig_class};

    load_class $orig_class;

    return $orig_class;
}

sub class {
    my $self = shift;

    my $class = $self->{class};

    load_class $class;

    return $class;
}

sub related_table {
    my $self = shift;

    return $self->class->meta->table;
}

1;
