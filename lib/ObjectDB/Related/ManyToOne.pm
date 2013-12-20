package ObjectDB::Related::ManyToOne;

use strict;
use warnings;

use base 'ObjectDB::Related';

our $VERSION = '3.03';

sub find_related {
    my $self   = shift;
    my ($row)  = shift;
    my %params = @_;

    my $meta = $self->meta;

    $params{where} ||= [];

    my ($from, $to) = %{$meta->map};

    $params{single} = 1;

    return unless defined $row->column($from);

    push @{$params{where}}, ($to => $row->column($from));

    return $meta->class->table->find(%params);
}

1;
