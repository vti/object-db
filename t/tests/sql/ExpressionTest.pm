package ExpressionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Expression;

sub stringify : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 'b']);

    is($expr->to_string, '`a` = ?');
    is_deeply($expr->bind, ['b']);
}

sub with_undefs : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 1, b => undef, c => 3]);

    is($expr->to_string, '`a` = ? AND `b` = ? AND `c` = ?');
    is_deeply($expr->bind, [1, undef, 3]);
}

sub glue_with_and : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 'b', c => 'd']);

    is($expr->to_string, '`a` = ? AND `c` = ?');
    is_deeply($expr->bind, ['b', 'd']);
}

sub scalarref_accepted_as_is : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => \'a = b');

    is($expr->to_string, 'a = b');
    is_deeply($expr->bind, []);
}

sub hashref_changes_op : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => {'!=' => 'b'}]);

    is($expr->to_string, '`a` != ?');
    is_deeply($expr->bind, ['b']);
}

sub arrayref_in : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => [1, 2, 3]]);

    is($expr->to_string, '`a` IN (?, ?, ?)');
    is_deeply($expr->bind, [1, 2, 3]);
}

sub arrayref_not_in : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => {not => [1, 2, 3]}]);

    is($expr->to_string, '`a` NOT IN (?, ?, ?)');
    is_deeply($expr->bind, [1, 2, 3]);
}

sub key_scalarref_as_is : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [\'MAX() FAX (123']);

    is($expr->to_string, 'MAX() FAX (123');
    is_deeply($expr->bind, []);
}

sub value_scalarref_as_is : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => \'MAX() FAX (123']);

    is($expr->to_string, '`a` = MAX() FAX (123');
    is_deeply($expr->bind, []);
}

sub change_logic : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [-or => [a => 'b', c => 'd']]);

    is($expr->to_string, '(`a` = ? OR `c` = ?)');
    is_deeply($expr->bind, ['b', 'd']);
}

sub change_logic_inside : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 1, -or => [b => 2, c => 3]]);

    is($expr->to_string, '`a` = ? AND (`b` = ? OR `c` = ?)');
    is_deeply($expr->bind, [1, 2, 3]);
}

sub cache_build_result : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 1, -or => [b => 2, c => 3]]);

    $expr->to_string;

    is($expr->to_string, '`a` = ? AND (`b` = ? OR `c` = ?)');
    is_deeply($expr->bind, [1, 2, 3]);
}

sub column_on_right_side : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => {-col => 'b'}]);

    $expr->to_string;

    is($expr->to_string, '`a` = `b`');
    is_deeply($expr->bind, []);
}

sub column_on_right_side_with_op_change : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => {'!=' => {-col => 'b'}}]);

    $expr->to_string;

    is($expr->to_string, '`a` != `b`');
    is_deeply($expr->bind, []);
}

sub functions : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => ['FOO(a)' => {'!=' => {-col => 'BAR(b)'}}]);

    $expr->to_string;

    is($expr->to_string, 'FOO(`a`) != BAR(`b`)');
    is_deeply($expr->bind, []);
}

sub with_prefix : Test(2) {
    my $self = shift;

    my $expr = $self->_build_expression->build(expr => [a => 'b'], prefix => 'table');

    is($expr->to_string, '`table`.`a` = ?');
    is_deeply($expr->bind, ['b']);
}

sub _build_expression {
    my $self = shift;

    return ObjectDB::SQL::Expression->new(@_);
}

1;
