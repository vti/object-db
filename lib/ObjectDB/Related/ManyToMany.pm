package ObjectDB::Related::ManyToMany;

use strict;
use warnings;

use base 'ObjectDB::Related';

our $VERSION = '3.01';

sub create_related {
    my $self = shift;
    my ($row) = shift;

    my @related = @_ == 1 ? ref $_[0] eq 'ARRAY' ? @{$_[0]} : ($_[0]) : ({@_});

    my @row_objects;
    foreach my $related (@related) {
        my %params = %$related;

        my $meta = $self->meta;

        my $row_object;

        $row_object = $meta->class->new(%params)->load;
        if (!$row_object) {
            $row_object = $meta->class->new(%params)->create;
        }

        my $map_from = $meta->map_from;
        my $map_to   = $meta->map_to;

        my ($from_foreign_pk, $from_pk) =
          %{$meta->map_class->meta->get_relationship($map_from)->map};

        my ($to_foreign_pk, $to_pk) =
          %{$meta->map_class->meta->get_relationship($map_to)->map};

        $meta->map_class->new(
            $from_foreign_pk => $row->get_column($from_pk),
            $to_foreign_pk   => $row_object->get_column($to_pk)
        )->create;

        push @row_objects, $row_object;
    }

    return @related == 1 ? $row_objects[0] : @row_objects;
}

sub find_related {
    my $self   = shift;
    my ($row)  = shift;
    my %params = @_;

    my $meta = $self->meta;

    my $map_from = $meta->map_from;
    my $map_to   = $meta->map_to;

    my ($map_table_to, $map_table_from) =
      %{$meta->map_class->meta->get_relationship($map_from)->map};

    my $table     = $meta->class->meta->table;
    my $map_table = $meta->map_class->meta->table;
    $params{where} =
      ["$map_table.$map_table_to" => $row->column($map_table_from)];

    return $meta->class->table->find(%params);
}

sub count_related {
    my $self   = shift;
    my ($row)  = shift;
    my %params = @_;

    my $meta = $self->meta;

    my $map_from = $meta->{map_from};
    my $map_to   = $meta->{map_to};

    my ($map_table_to, $map_table_from) =
      %{$meta->map_class->meta->get_relationship($map_from)->map};

    my $table     = $meta->class->meta->table;
    my $map_table = $meta->map_class->meta->table;
    $params{where} =
      ["$map_table.$map_table_to" => $row->column($map_table_from)];

    return $meta->class->table->count(%params);
}

sub delete_related {
    my $self = shift;
    my ($row, %params) = @_;

    $params{where} ||= [];

    my $meta = $self->meta;

    my $map_from = $meta->map_from;
    my $map_to   = $meta->map_to;

    my ($to, $from) =
      %{$meta->map_class->meta->get_relationship($map_from)->map};

    push @{$params{where}}, ($to => $row->get_column($from));

    if ($meta->where) {
        push @{$params{where}}, %{$meta->where};
    }

    return $meta->map_class->table->delete(%params);
}

1;
