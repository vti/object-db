package TableCountTest;

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

sub return_zero_on_empty_table : Test {
    my $self = shift;

    my $table = $self->_build_table;

    is($table->count, 0);
}

sub count_rows : Test {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 10;

    my $table = $self->_build_table;

    is($table->count, 10);
}

sub count_rows_with_query : Test {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 10;

    my $table = $self->_build_table;

    is($table->count(where => [name => {'>=' => 5}]), 5);
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
