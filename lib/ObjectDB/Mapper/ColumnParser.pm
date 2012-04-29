package ObjectDB::Mapper::ColumnParser;

use strict;
use warnings;

use base 'ObjectDB::SQL::ColumnParser';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{with} = [];

    return $self;
}

sub parse_column {
    my $self = shift;
    my ($column) = @_;

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
        if (!grep { $_ eq $with } @{$self->{with}}) {
            $self->{callback}->($with);
            push @{$self->{with}}, $with;
        }
    }

    return $column;
}

1;
