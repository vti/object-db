package ObjectDB::Quoter;

use strict;
use warnings;

use base 'SQL::Builder::Quoter';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{meta} = $params{meta};
    $self->{with} = [];

    return $self;
}

sub quote {
    my $self = shift;
    my ($column, $prefix) = @_;

    my @parts = split /\./, $column;
    $column = pop @parts;

    my $meta = $self->{meta};
    my $rel_table;
    my $name;
    foreach my $part (@parts) {
        my $relationship = $meta->relationships->{$part}
          or die "Unknown relationship '$part' in " . $meta->class;
        $name      = $relationship->name;
        $rel_table = $relationship->class->meta->table;
        $meta      = $relationship->class->meta;
    }

    if ($rel_table) {
        $column = $name . '.' . $column;

        my $with = join '.', @parts;
        push @{$self->{with}}, $with
          unless grep { $_ eq $with } @{$self->{with}};
    }

    return $self->SUPER::quote($column, $prefix);
}

sub with {
    my $self = shift;

    return @{$self->{with} || []};
}

1;
