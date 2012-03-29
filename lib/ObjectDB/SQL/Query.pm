package ObjectDB::SQL::Query;

use strict;
use warnings;

use base 'ObjectDB::SQL';

use Scalar::Util qw(blessed);

use ObjectDB::SQL::Expression;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{expr} ||= ObjectDB::SQL::Expression->new(
        quoter        => $self->{quoter},
        column_parser => $self->{column_parser}
    );

    return $self;
}

sub _build_where {
    my $self = shift;
    my (%params) = @_;

    return '' unless $self->{where} && @{$self->{where}};

    my $expr = $self->{expr}->build(%params, expr => $self->{where});

    my $query = ' WHERE ' . $expr->to_string;
    push @{$self->{bind}}, @{$expr->bind};

    return $query;
}

sub _build_order_by {
    my $self = shift;

    return '' unless my $order_by = $self->{order_by};

    my @orders;
    if (ref $order_by eq 'SCALAR') {
        @orders = $$order_by;
    }
    else {
        @orders = split /\s*,\s*/, $order_by;
        foreach my $order (@orders) {
            if ($order =~ s/^([^\s]+)//) {
                my $column = $self->{column_parser}->parse_column($1);
                $column = $self->_quote_column($column, $self->{table});
                $order = $column . $order;
            }
        }
    }

    return ' ORDER BY ' . join ', ', @orders;
}

sub _build_limits {
    my $self = shift;

    my $query = '';

    if ($self->{limit}) {
        $query .= ' LIMIT ' . $self->{limit};
    }

    if ($self->{offset}) {
        $query .= ' OFFSET ' . $self->{offset};
    }

    return $query;
}

1;
