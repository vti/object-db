package DeleteTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Query::Delete;

sub all_in_one : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(table => 'foo');

    is($sql->to_string, 'DELETE FROM `foo`');
    is_deeply($sql->bind, []);
}

sub with_where : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        where => [a => 1]
    );

    is($sql->to_string, 'DELETE FROM `foo` WHERE `a` = ?');
    is_deeply($sql->bind, [1]);
}

sub with_order_by : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table    => 'foo',
        order_by => 'foo DESC'
    );

    is($sql->to_string, 'DELETE FROM `foo` ORDER BY `foo`.`foo` DESC');
    is_deeply($sql->bind, []);
}

sub with_offset_limit : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table  => 'foo',
        limit  => 10,
        offset => 5
    );

    is($sql->to_string, 'DELETE FROM `foo` LIMIT 10 OFFSET 5');
    is_deeply($sql->bind, []);
}

sub _build_sql {
    my $self = shift;

    return ObjectDB::SQL::Query::Delete->new(@_);
}

1;
