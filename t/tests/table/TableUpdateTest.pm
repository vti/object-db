package TableUpdateTest;

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

sub update_objects : Test {
    my $self = shift;

    Person->new(name => 'vti')->create;

    my $table = $self->_build_table;
    $table->update(set => {name => 'foo'});

    my $person = Person->new(id => 1)->load;

    is($person->get_column('name'), 'foo');
}

sub update_objects_with_query : Test(2) {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;
    $table->update(set => {name => 'bar'}, where => [name => 'foo']);

    my $person = Person->new(id => 1)->load;
    is($person->get_column('name'), 'vti');

    $person = Person->new(id => 2)->load;
    is($person->get_column('name'), 'bar');
}

sub return_number_of_updated_rows : Test(2) {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;
    is $table->update(set => {name => 'bar'}, where => [name => 'foo']), 1;
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
