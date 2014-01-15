package ObjectDB::Related::ManyToMany;

use strict;
use warnings;

use base 'ObjectDB::Related';

our $VERSION = '3.05';

sub create_related {
    my $self = shift;
    my ($row, $related) = @_;

    my @row_objects;
    foreach my $related (@$related) {
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

    return @row_objects;
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

    my @where = @{$params{where} || []};
    unshift @where, "$map_table.$map_table_to" => $row->column($map_table_from);

    return $meta->class->table->find(%params, where => \@where);
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

    my @where = @{$params{where} || []};
    unshift @where, "$map_table.$map_table_to" => $row->column($map_table_from);

    return $meta->class->table->count(%params, where => \@where);
}

sub delete_related {
    my $self = shift;
    my ($row, %params) = @_;

    my $meta = $self->meta;

    my $map_from = $meta->map_from;
    my $map_to   = $meta->map_to;

    my ($map_table_to, $map_table_from) =
      %{$meta->map_class->meta->get_relationship($map_from)->map};

    my $table     = $meta->class->meta->table;
    my $map_table = $meta->map_class->meta->table;

    my @where = @{$params{where} || []};
    unshift @where, "$map_table.$map_table_to" => $row->column($map_table_from);

    return $meta->map_class->table->delete(%params, where => \@where);
}

1;
