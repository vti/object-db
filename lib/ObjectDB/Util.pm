package ObjectDB::Util;

use strict;
use warnings;

use base 'Exporter';

our $VERSION   = '3.00';
our @EXPORT_OK = qw(load_class);

require Carp;

sub load_class {
    my ($class) = @_;

    Carp::croak('class name is required') unless $class;

    Carp::croak("Invalid class name '$class'")
      unless $class =~ m/^[[:lower:]\d:]+$/smxi;

    my $path = $class;
    $path =~ s{::}{/}smxg;
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

        Carp::croak($e);
    };
}

1;
