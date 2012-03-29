package ObjectDB::SQL::Query::Select;

use strict;
use warnings;

use base 'ObjectDB::SQL::Query';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{joins}   ||= [];
    $self->{columns} ||= [];

    $self->{columns} =
      $self->_normalize_columns([@{$self->{columns}}], $self->{table});

    $self->{constraint} ||= ObjectDB::SQL::Expression->new;

    return $self;
}

sub columns {
    my $self = shift;

    return map { $_->{name} } @{$self->{columns}};
}

sub join : method {
    my $self = shift;
    my (%options) = @_;

    my $table = $options{table};

    $options{type} ||= 'left';

    if ($options{columns}) {
        $options{columns} = [$options{columns}]
          unless ref $options{columns} eq 'ARRAY';

        $options{columns} =
          $self->_normalize_columns([@{$options{columns}}], $table);

        push @{$self->{columns}}, @{$options{columns}};
    }

    push @{$self->{joins}}, {table => $table, %options};

    return $self;
}

sub to_string {
    my $self = shift;

    my $where    = $self->_build_where(prefix => $self->{table});
    my $order_by = $self->_build_order_by;
    my $limits   = $self->_build_limits;

    my $query = "";

    $query .= 'SELECT ';

    my @columns;
    foreach my $column (@{$self->{columns}}) {
        my $name = $column->{name};
        $name = ref $name eq 'SCALAR' ? $$name : $self->_quote_column($name);

        if (my $as = $column->{as}) {
            $as = ref $as eq 'SCALAR' ? $$as : $self->_quote_column($as);

            push @columns, $name . ' AS ' . $as;
        }
        else {
            push @columns, $name;
        }
    }

    $query .= join ', ', @columns;

    $query .= ' FROM ' . $self->_build_sources;

    $query .= $where;

    if (my $group_by = $self->{group_by}) {
        $query .= ' GROUP BY '
          . (
            ref $group_by eq 'SCALAR'
            ? $$group_by
            : $self->_quote_column($group_by)
          );
    }

    $query .= $order_by;

    $query .= $limits;

    return $query;
}

sub _build_sources {
    my $self = shift;

    my $sources = '';

    $sources .= $self->_quote_column($self->{table});

    foreach my $source (@{$self->{joins}}) {
        my $expr = $self->{constraint}->build(expr => $source->{constraint});
        $source->{type} ||= 'left';
        $sources
          .= ' '
          . uc($source->{type})
          . ' JOIN '
          . $self->_quote_column($source->{table}) . ' ON '
          . $expr->to_string;
        push @{$self->{bind}}, @{$self->{constraint}->bind};
    }

    return $sources;
}

sub _normalize_columns {
    my $self = shift;
    my ($columns, $prefix) = @_;

    my $normalized = [];
    foreach my $column (@$columns) {
        if (ref $column ne 'HASH') {
            $column = {name => $column};
        }

        if ($prefix) {
            $column->{name} = $self->_prefix_column($column->{name}, $prefix) unless ref $column->{name};
        }

        push @$normalized, $column;
    }

    return $normalized;
}

1;
