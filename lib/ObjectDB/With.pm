package ObjectDB::With;

use strict;
use warnings;

our $VERSION = '3.00';

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{meta} = $params{meta};
    $self->{with} = $params{with};
    $self->{with} = [$self->{with}]
      if $self->{with} && ref $self->{with} ne 'ARRAY';

    my $joins = {join => []};

    my %seen;
    if (my @with = sort @{$self->{with} || []}) {
        foreach my $with (@with) {
            my $meta = $self->{meta};

            my @parts = split /[.]/xms, $with;

            my $seen        = q{};
            my $parent_join = $joins;
            foreach my $part (@parts) {
                $seen .= q{.} . $part;

                my $rel = $meta->get_relationship($part);

                if ($seen{$seen}) {
                    $parent_join = $seen{$seen};
                    $meta        = $rel->class->meta;
                    next;
                }

                my $join = $rel->to_source(table => $parent_join->{as});

                push @{$parent_join->{join}},
                  {
                    source  => $join->{table},
                    as      => $join->{as},
                    on      => $join->{constraint},
                    op      => $join->{join},
                    columns => $join->{columns},
                    join    => []
                  };

                $parent_join = $parent_join->{join}->[-1];
                $seen{$seen} = $parent_join;

                $meta = $rel->class->meta;
            }
        }
    }

    $self->{joins} = $joins->{join};

    return $self;
}

sub to_joins {
    my $self = shift;

    return $self->{joins};
}

1;
