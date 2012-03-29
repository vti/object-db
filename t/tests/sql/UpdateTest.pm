package UpdateTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Query::Update;

sub all_in_one : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => 'bar'}
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = ?');
    is_deeply($sql->bind, ['bar']);
}

sub with_scalaref : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => \'bar + 1'}
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = bar + 1');
    is_deeply($sql->bind, []);
}

sub with_modifier : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => {-col => 'bar'}}
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = `bar`');
    is_deeply($sql->bind, []);
}

sub with_where : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => 'bar'},
        where => [a => 1]
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = ? WHERE `a` = ?');
    is_deeply($sql->bind, ['bar', 1]);
}

sub with_order_by : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => 'bar'},
        order_by => 'foo DESC'
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = ? ORDER BY `foo`.`foo` DESC');
    is_deeply($sql->bind, ['bar']);
}

sub with_offset_limit : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => 'bar'},
        limit => 10,
        offset => 5
    );

    is($sql->to_string, 'UPDATE `foo` SET `foo` = ? LIMIT 10 OFFSET 5');
    is_deeply($sql->bind, ['bar']);
}

sub _build_sql {
    my $self = shift;

    return ObjectDB::SQL::Query::Update->new(@_);
}

1;
