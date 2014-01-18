package ObjectDB::Util;

use strict;
use warnings;

use base 'Exporter';

our $VERSION   = '3.07';
our @EXPORT_OK = qw(load_class execute merge merge_rows);

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

    my $sql  = $stmt->to_sql;
    my @bind = $stmt->to_bind;

    my ($rv, $sth);
    eval {
        $sth = $dbh->prepare($sql);
        $rv  = $sth->execute(@bind);

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

sub merge_rows {
    my $rows = shift;

    my $merged = [];

  NEXT_MERGE: while (@$rows) {
        push @$merged, shift @$rows;
        last unless @$rows;

        my $prev = $merged->[-1];
        my $row  = $rows->[0];

        foreach my $key (keys %$row) {
            if (   defined($row->{$key})
                && ref($row->{$key})
                && (ref $row->{$key} eq 'HASH' || $row->{$key} eq 'ARRAY'))
            {
                next NEXT_MERGE unless exists $prev->{$key};
                next;
            }

            if (exists $prev->{$key}) {
                if (!defined $prev->{$key} && !defined $row->{$key}) {
                    next;
                }
                elsif (defined($prev->{$key})
                    && defined($row->{$key})
                    && $prev->{$key} eq $row->{$key})
                {
                    next;
                }

                next NEXT_MERGE;
            }
            else {
                next NEXT_MERGE;
            }
        }

        pop @$merged;

        foreach my $key (keys %$row) {
            next
              unless ref $prev->{$key} eq 'HASH'
              || ref $prev->{$key} eq 'ARRAY';

            my $prev_row =
              ref $prev->{$key} eq 'ARRAY'
              ? $prev->{$key}->[-1]
              : $prev->{$key};

            my $merged = merge_rows([$prev_row, $row->{$key}]);
            if (@$merged > 1) {
                my $prev_rows =
                  ref $prev->{$key} eq 'ARRAY'
                  ? $prev->{$key}
                  : [$prev->{$key}];
                pop @$prev_rows;
                $row->{$key} = [@$prev_rows, @$merged];
            }
        }
    }

    return $merged;
}

1;
