package CreateTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use Person;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('person');
}

sub create_one_instance : Test() {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

    is(@$result, 1);
}

sub save_columns : Test() {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    my $result = TestDBH->dbh->selectall_arrayref('SELECT id, name FROM `person`');

    is_deeply($result->[0], [1, 'vti']);
}

sub do_nothing_on_double_create : Test {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    $person->create;

    my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

    is(@$result, 1);
}

sub autoincrement_field_is_set : Test() {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    is($person->column('id'), 1);
}

sub is_in_db : Test() {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    ok($person->is_in_db);
}

sub not_modified : Test() {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->create;

    ok(!$person->is_modified);
}

sub _build_object {
    my $self = shift;

    return Person->new(@_);
}

1;
