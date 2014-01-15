package ObjectDB::Util;

use strict;
use warnings;

use base 'Exporter';

our $VERSION   = '3.06';
our @EXPORT_OK = qw(load_class execute merge);

require Carp;
use Hash::Merge ();
use ObjectDB::Exception;

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

sub execute {
    my ($dbh, $stmt, %context) = @_;

    my ($rv, $sth);
    eval {
        $sth = $dbh->prepare($stmt->to_sql);
        $rv  = $sth->execute($stmt->to_bind);

        1;
    } or do {
        my $e = $@;

        ObjectDB::Exception->throw($e, %context, sql => $stmt);
    };

    return wantarray ? ($rv, $sth) : $rv;
}

my $merge;

sub merge {
    $merge ||= do {
        my $merge = Hash::Merge->new();
        $merge->set_behavior('STORAGE_PRECEDENT');
        $merge->set_clone_behavior(1);
        $merge;
    };
    $merge->merge(@_);
}

1;
