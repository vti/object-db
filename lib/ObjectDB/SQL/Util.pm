package ObjectDB::SQL::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(quote prefix);

sub quote {
    my ($column, $quote_symbol) = @_;

    $quote_symbol ||= '`';

    my ($begin, $name, $end) = parse($column);
    return "$begin$name$end" if $name eq '*';

    my @args;
    foreach my $arg (split /\s*,\s*/, $name) {
        if ($arg =~ m/^(?:'.*?')$|^(?:".*?")$|^(?:-)?\d/) {
            push @args, $arg;
            next;
        }

        my @parts = split /\./, $arg;
        @parts = map { s/$quote_symbol/\\$quote_symbol/g; $_ } @parts;
        push @args, join('.', map { "$quote_symbol$_$quote_symbol" } @parts);
    }

    $begin . join(', ', @args) . $end;
}

sub prefix {
    my ($column, $prefix) = @_;

    my ($begin, $name, $end) = parse($column);
    return $column if $name eq '*';

    return $column if $name =~ m/\w+\./;

    return $begin . $prefix . '.' . $name . $end;
}

sub parse {
    my ($name) = @_;

    my ($begin, $end) = ('', '');
    if ($name =~ m/^(.*\()([^\)]+)(\).*)$/) {
        return ($begin, $name, $end) = ($1, $2, $3);
    }

    return ('', $name, '');
}

1;
