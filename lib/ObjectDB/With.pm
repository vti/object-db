package ObjectDB::With;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{meta} = $params{meta};
    $self->{with} = $params{with};
    $self->{with} = [$self->{with}] if $self->{with} &&  ref $self->{with} ne 'ARRAY';

    my $joins = $self->{joins} = [];

    my %seen;
    if (my @with = sort @{$self->{with} || []}) {
        foreach my $with (@with) {
            my $meta = $self->{meta};

            my @parts = split /\./, $with;

            my $seen = '';
            foreach my $part (@parts) {
                $seen .= '.'. $part;

                my $rel = $meta->relationships->{$part};
                Carp::croak("Unknown relationship '$part' in " . $meta->class)
                  unless $rel;

                if (!$seen{$seen}++) {
                    my $join = $rel->to_source;
                    push @$joins,
                      {
                        source  => $join->{table},
                        on      => $join->{constraint},
                        op      => $join->{join},
                        columns => $join->{columns},
                        as      => $join->{as},
                      };
                }

                $meta = $rel->class->meta;
            }
        }
    }

    return $self;
}

sub to_joins {
    my $self = shift;

    return $self->{joins};
}

1;
