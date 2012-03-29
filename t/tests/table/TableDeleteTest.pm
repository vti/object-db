package TableDeleteTest;

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

sub delete_objects : Test {
    my $self = shift;

    Person->new(name => 'vti')->create;

    my $table = $self->_build_table;
    $table->delete;

    is($table->count, 0);
}

sub delete_objects_with_query : Test {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;
    $table->delete(where => [name => 'foo']);

    is($table->count, 1);
}

sub return_number_of_deleted_rows : Test(2) {
    my $self = shift;

    Person->new(name => 'vti')->create;
    Person->new(name => 'foo')->create;

    my $table = $self->_build_table;
    is $table->delete, 2;
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
