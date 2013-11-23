package ObjectDB::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(load_class);

require Carp;

sub load_class {
    my ($class) = @_;

    Carp::croak('class name is required') unless $class;

    Carp::croak("Invalid class name '$class'")
      unless $class =~ m/^[a-z0-9:]+$/i;

    my $path = $class;
    $path =~ s{::}{/}g;
    $path .= '.pm';

    return 1 if exists $INC{$path} && defined $INC{$path};

    {
        no strict 'refs';

        for (keys %{"$class\::"}) {
            return 1 if defined &{$_};
        }
    }

    eval {
        require $path;

        1;
    } or do {
        my $e = $@;

        delete $INC{$path};

        {
            no strict 'refs';
            %{"$class\::"} = ();
        }

        die $e;
    };
}

1;
