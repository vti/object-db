package ObjectDB::Meta::Relationship;

use strict;
use warnings;

use ObjectDB::Util qw(load_class);

sub new {
    my $class = shift;
    my %params = @_;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub map   { $_[0]->{map} }
sub where { $_[0]->{where} }

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

sub with {
    $_[0]->{with}
}

1;
