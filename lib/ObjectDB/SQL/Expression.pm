package ObjectDB::SQL::Expression;

use strict;
use warnings;

use base 'ObjectDB::SQL';

sub build {
    my $self = shift;
    my (%params) = @_;

    $self->{prefix} = $params{prefix};
    $self->{expr} =
      ref $params{expr} eq 'ARRAY' ? $params{expr} : [$params{expr}];
    $self->{bind} = [];

    $self->{to_string} = $self->_build_logic($self->{expr}, 'AND');

    return $self;
}

sub to_string {
    my $self = shift;

    return $self->{to_string};
}

sub _build_logic {
    my $self = shift;
    my ($expr, $logic) = @_;

    my @parts;

    my $count = 0;
    while (my ($key, $value) = @{$expr}[$count, $count + 1]) {
        last unless defined $key;

        if (ref $key eq 'SCALAR') {
            push @parts, $$key;
            $count++;
            next;
        }

        if ($key =~ s/^-//) {
            if ($key eq 'or' || $key eq 'and') {
                push @parts, '(' . $self->_build_logic($value, uc $key) . ')';
                $count += 2;
                next;
            }
        }

        my $op;
        my $q  = '?';

        if (ref $value eq 'HASH') {
            ($op, $value) = %$value;
            if ($op eq '-col') {
                $op = '=';

                $value   = $self->_parse_column($value);
                $q       = $self->_quote_column($value);

                $key = $self->_parse_column($key);
                push @parts, $self->_quote_column($key) . " $op $q";

                $count += 2;
                next;
            }
        }

        if (ref $value eq 'ARRAY') {
            if ($op) {
                $op = uc($op) . ' IN';
            }
            else {
                $op = 'IN';
            }
            $q = '(' . join(', ', split //, ('?' x @$value)) . ')';
            push @{$self->{bind}}, @$value;
        }
        elsif (ref $value eq 'SCALAR') {
            $q = $$value;
        }
        elsif (ref $value eq 'HASH') {
            $op ||= '=';
            my $old_op = $op;
            ($op, $value) = %$value;
            if ($op eq '-col') {
                $op = $old_op;

                $value = $self->_parse_column($value);
                $q     = $self->_quote_column($value);
            }
            else {
                push @{$self->{bind}}, $value;
            }
        }
        else {
            push @{$self->{bind}}, $value;
        }

        $op ||= '=';
        $key = $self->_parse_column($key);
        push @parts, $self->_quote_column($key) . " $op $q";

        $count += 2;
    }

    return join " $logic ", @parts;
}

1;
