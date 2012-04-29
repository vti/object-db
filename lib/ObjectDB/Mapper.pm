package ObjectDB::Mapper;

use strict;
use warnings;

use ObjectDB::SQL::Query::Select;
use ObjectDB::Mapper::ColumnParser;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    die 'meta is required' unless $self->{meta};

    return $self;
}

sub to_sql {
    my $self = shift;
    my (%params) = @_;

    my $table = $self->{meta}->table;

    $params{columns} ||= [$self->{meta}->get_columns];
    $params{columns} = [$params{columns}]
      unless ref $params{columns} eq 'ARRAY';

    if (!grep { $self->{meta}->is_primary_key($_) } @{$params{columns}}) {
        unshift @{$params{columns}}, $self->{meta}->get_primary_key;
    }

    $self->{columns} = $params{columns};

    my $with = $params{with} || [];
    $with = [$with] unless ref $with eq 'ARRAY';

    my $sql; $sql = ObjectDB::SQL::Query::Select->new(
        table         => $table,
        columns       => $params{columns},
        where         => $params{where},
        limit         => $params{limit},
        offset        => $params{offset},
        order_by      => $params{order_by},
        group_by      => $params{group_by},
        column_parser => ObjectDB::Mapper::ColumnParser->new(
            meta     => $self->{meta},
            callback => sub {
                my ($new_with) = @_;

                if (!grep {$_ eq $new_with} @$with) {
                    $self->_map_joins($sql, $new_with);
                }
            }
        )
    );

    if ($params{joins}) {
        foreach my $join (@{$params{joins}}) {
            $sql->join(%$join);
        }
    }

    if (@$with) {
        $self->_map_joins($sql, $with);
    }

    return ($sql->to_string, @{$sql->bind});
}

sub from_row {
    my $self = shift;
    my ($row, @args) = @_;

    my $object = $self->{meta}->class->new(@args);

    foreach my $column (@{$self->{columns}}) {
        my $name = ref $column eq 'HASH' ? $column->{as} || $column->{name} : $column;
        $object->set_column($name => shift @$row);
    }

    if (my $with = $self->{with}) {
        $self->_map_row($row, $object, $with);
    }

    die 'Not all columns were mapped' if @$row;

    return $object;
}

sub _map_joins {
    my $self = shift;
    my ($sql, $with) = @_;

    $with = [$with] unless ref $with eq 'ARRAY';

    $with = [map { ref $_ eq 'HASH' ? $_ : {name => $_} } @$with];

    $self->{with} ||= [];

    foreach my $rel (@$with) {
        my $name = $rel->{name};

        my $meta = $self->{meta};

        my $result = {name => $name};

        my $subname = '';

        my @parts = split /\./, $name;
        while (my $part = shift @parts) {
            $subname = $subname ? $subname . '.' . $part : $part;

            my $relationship = $meta->relationships->{$part}
              or die "Unknown relationship '$part'";

            $meta = $relationship->class->meta;

            if (grep {$_->{name} eq $subname} @{$self->{with}}) {
                next;
            }

            my @joins =
              $relationship->to_source(%$rel,
                columns => @parts ? [] : $rel->{columns});

            my @columns;
            foreach my $join (@joins) {
                $sql->join(%$join);

                push @columns, @{$join->{columns}}
                  if $join->{columns} && @{$join->{columns}};
            }

            $result->{parts}->{$part} = [@columns];
        }

        push @{$self->{with}}, $result;
    }
}

sub _map_row {
    my $self = shift;
    my ($row, $object, $with) = @_;

    foreach my $rel (@$with) {
        my $name = $rel->{name};

        my $parent = $object;

        my $meta = $self->{meta};
        my @parts = split /\./, $name;

        foreach my $part (@parts) {
            my $relationship = $meta->relationships->{$part};

            my $rel_object;

            if ($parent->is_related_loaded($part)) {
                $rel_object = $parent->related($part);
            }
            else {
                $rel_object = $relationship->class->new;
                $parent->{_relationships}->{$part} = $rel_object;
            }

            foreach my $column (@{$rel->{parts}->{$part}}) {
                my $name = ref $column eq 'HASH' ? $column->{as} || $column->{name} : $column;
                $name =~ s{^$part\.}{};
                $rel_object->set_column($name => shift @$row);
            }

            $meta = $rel_object->meta;
            $parent = $rel_object;
        }
    }
}

1;
