package UtilTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Util qw(quote prefix);

sub quote_single : Test {
    my $self = shift;

    is(quote('foo'), '`foo`');
}

sub quote_prefixed : Test {
    my $self = shift;

    is(quote('foo.bar'), '`foo`.`bar`');
}

sub quote_having_symbol : Test {
    my $self = shift;

    is(quote('fo`o'), '`fo\`o`');
}

sub quote_function : Test {
    my $self = shift;

    is(quote('FOO(a)'), 'FOO(`a`)');
}

sub quote_functions : Test {
    my $self = shift;

    is(quote('FOO(BAR(a))'), 'FOO(BAR(`a`))');
}

sub quote_function_with_star : Test {
    my $self = shift;

    is(quote('FOO(*)'), 'FOO(*)');
}

sub quote_function_with_parameters : Test {
    my $self = shift;

    is(quote('FOO(a, "b", 1)'), 'FOO(`a`, "b", 1)');
}

sub prefix_column : Test {
    my $self = shift;

    is(prefix('foo', 'bar'), 'bar.foo');
}

sub prefix_function : Test {
    my $self = shift;

    is(prefix('FOO(foo)', 'bar'), 'FOO(bar.foo)');
}

sub not_prefix_already_prefixed : Test {
    my $self = shift;

    is(prefix('foo.bar', 'bar'), 'foo.bar');
}

1;
