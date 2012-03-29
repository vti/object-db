package Table;
use base 'ObjectDB';
__PACKAGE__->meta(
    table   => 'table',
    columns => [
        qw/foo bar baz/,
        'nullable'   => {is_null => 1},
        with_default => {default => '123'}
    ]
);

package ColumnsTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

sub set_columns_via_constructor : Test {
    my $self = shift;

    my $row = $self->_build_object(foo => 'bar');
    is($row->get_column('foo'), 'bar');
}

sub set_columns_overwrite_early_set_columns : Test {
    my $self = shift;

    my $row = $self->_build_object(foo => 'bar');
    $row->set_columns(foo => 'baz');
    is($row->get_column('foo'), 'baz');
}

#sub set_columns_overwrite_all_early_set_columns : Test {
#    my $self = shift;
#
#    my $row = $self->_build_object(foo => 'bar');
#    $row->set_columns(bar => 'baz');
#    is($row->get_column('foo'), undef);
#}

sub set_column_overwrites_undef_value : Test {
    my $self = shift;

    my $row = $self->_build_object();
    $row->set_column(foo => undef);
    $row->set_column(foo => 'bar');
    is($row->get_column('foo'), 'bar');
}

sub not_null_columns_return_empty_strings : Test {
    my $self = shift;

    my $row = $self->_build_object(foo => undef);
    is($row->get_column('foo'), '');
}

sub null_columns_return_undef : Test {
    my $self = shift;

    my $row = $self->_build_object();
    is($row->get_column('nullable'), undef);
}

sub default_columns_return_default_values : Test {
    my $self = shift;

    my $row = $self->_build_object();
    is($row->get_column('with_default'), '123');
}

sub virtual_columns_are_not_set_via_constructor : Test {
    my $self = shift;

    my $row = $self->_build_object(unknown => 'bar');
    is($row->get_column('unknown'), undef);
}

sub virtual_columns_are_set_via_methods : Test {
    my $self = shift;

    my $row = $self->_build_object();
    $row->set_column(unknown => 'bar');
    is($row->get_column('unknown'), 'bar');
}

sub _build_object {
    my $self = shift;

    return Table->new(@_);
}

1;
