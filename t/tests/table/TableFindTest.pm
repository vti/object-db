package TableFindTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use ObjectDB::Table;
use Person;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('person');
}

sub find_objects : Test {
    my $self = shift;

    Person->new(name => 'vti')->create;

    my $table = $self->_build_table;

    my @persons = $table->find;

    is(@persons, 1);
}

sub find_objects_with_query : Test(2) {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;

    my @persons = $table->find(where => [name => 'vti']);

    is($persons[0]->get_column('name'), 'vti');
}

sub find_single_object : Test(2) {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;

    my $person = $table->find(where => [name => 'vti'], single => 1);

    is($person->get_column('name'), 'vti');
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
