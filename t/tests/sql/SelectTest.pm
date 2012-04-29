package SelectTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Query::Select;

sub all_in_one : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [qw/foo/],
        table   => 'table',
        where   => [a => 1]
    );

    is($sql->to_string, 'SELECT `table`.`foo` FROM `table` WHERE `table`.`a` = ?');
    is_deeply($sql->bind, [1]);
}

sub count_column : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [\'COUNT(*)'],
        table   => 'table',
        where   => [a => 1]
    );

    is($sql->to_string, 'SELECT COUNT(*) FROM `table` WHERE `table`.`a` = ?');
    is_deeply($sql->bind, [1]);
}

sub columns_as : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [{name => \'COUNT(*)', as => 'count'}],
        table   => 'table',
        where => [a => 1]
    );

    is($sql->to_string,
        'SELECT COUNT(*) AS `count` FROM `table` WHERE `table`.`a` = ?');
    is_deeply($sql->bind, [1]);
}

sub columns_as_with_scalarref : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [{name => \'COUNT(foo)', as => 'count'}],
        table   => 'table',
        where => [a => 1]
    );

    is($sql->to_string,
        'SELECT COUNT(foo) AS `count` FROM `table` WHERE `table`.`a` = ?');
    is_deeply($sql->bind, [1]);
}

sub order_by : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns  => [qw/foo/],
        table    => 'table',
        order_by => 'foo ASC, bar DESC'
    );

    is($sql->to_string,
        'SELECT `table`.`foo` FROM `table` ORDER BY `table`.`foo` ASC, `table`.`bar` DESC'
    );
    is_deeply($sql->bind, []);
}

sub order_by_as_is : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns  => [qw/foo/],
        table    => 'table',
        order_by => \'hello'
    );

    is($sql->to_string, 'SELECT `table`.`foo` FROM `table` ORDER BY hello');
    is_deeply($sql->bind, []);
}

sub limit_offset : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [qw/foo/],
        table   => 'table',
        limit   => 5,
        offset  => 10
    );

    is($sql->to_string,
        'SELECT `table`.`foo` FROM `table` LIMIT 5 OFFSET 10');
    is_deeply($sql->bind, []);
}

sub group_by : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns  => [qw/foo/],
        table    => 'table',
        group_by => 'foo'
    );

    is($sql->to_string, 'SELECT `table`.`foo` FROM `table` GROUP BY `foo`');
    is_deeply($sql->bind, []);
}

sub group_by_as_is : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns  => [qw/foo/],
        table    => 'table',
        group_by => \'foo'
    );

    is($sql->to_string, 'SELECT `table`.`foo` FROM `table` GROUP BY foo');
    is_deeply($sql->bind, []);
}

sub join : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [qw/foo/],
        table   => 'table'
      )->join(
        table      => 'table2',
        as         => 'table3',
        columns    => 'bar',
        constraint => ['table3.bar' => {-col => 'table.foo'}]
      );

    is($sql->to_string,
        'SELECT `table`.`foo`, `table2`.`bar` FROM `table` LEFT JOIN `table2` AS `table3` ON `table3`.`bar` = `table`.`foo`'
    );
    is_deeply($sql->bind, []);
}

sub join_with_complex_constraint : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [qw/foo/],
        table   => 'table'
      )->join(
        table      => 'table2',
        columns    => 'bar',
        constraint => ['table2.bar' => {-col => 'table.foo'}, 'foo' => 1]
      );

    is($sql->to_string,
        'SELECT `table`.`foo`, `table2`.`bar` FROM `table` LEFT JOIN `table2` ON `table2`.`bar` = `table`.`foo` AND `foo` = ?'
    );
    is_deeply($sql->bind, [1]);
}

sub join_with_type : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        columns => [qw/foo/],
        table   => 'table'
      )->join(
        table      => 'table2',
        type       => 'right',
        columns    => 'bar',
        constraint => ['table2.bar' => {-col => 'table.foo'}]
      );

    is($sql->to_string,
        'SELECT `table`.`foo`, `table2`.`bar` FROM `table` RIGHT JOIN `table2` ON `table2`.`bar` = `table`.`foo`'
    );
    is_deeply($sql->bind, []);
}

sub _build_sql {
    my $self = shift;

    return ObjectDB::SQL::Query::Select->new(@_);
}

1;
