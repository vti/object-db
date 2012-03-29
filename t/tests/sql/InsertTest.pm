package InsertTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::SQL::Query::Insert;

sub all_in_one : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => 'bar'}
    );

    is($sql->to_string, 'INSERT INTO `foo` (`foo`) VALUES (?)');
    is_deeply($sql->bind, ['bar']);
}

sub with_scalaref : Test(2) {
    my $self = shift;

    my $sql = $self->_build_sql(
        table => 'foo',
        set   => {foo => \'"bar"'}
    );

    is($sql->to_string, 'INSERT INTO `foo` (`foo`) VALUES ("bar")');
    is_deeply($sql->bind, []);
}

sub _build_sql {
    my $self = shift;

    return ObjectDB::SQL::Query::Insert->new(@_);
}

1;
