package TableFindWithPagingTest;

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

sub get_page : Test {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 20;

    my $table = $self->_build_table;

    my @persons = $table->find(page => 1);
    is(@persons, 10);
}

sub get_page_with_correct_results : Test(2) {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 20;

    my $table = $self->_build_table;

    my @persons = $table->find(page => 2);
    is($persons[0]->get_column('name'), 11);
    is($persons[-1]->get_column('name'), 20);
}

sub default_to_the_first_page_on_invalid_data : Test(2) {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 20;

    my $table = $self->_build_table;

    my @persons = $table->find(page => 'abc');
    is($persons[0]->get_column('name'), 1);
    is($persons[-1]->get_column('name'), 10);
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
