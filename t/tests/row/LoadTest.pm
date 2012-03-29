package LoadTest;

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

sub load_by_primary_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'foo');
    $self->_insert(id => 2, name => 'vti');

    my $person = $self->_build_object(id => 2);
    $person->load;

    is($person->column('name'), 'vti');
}

sub overwrite_columns : Test {
    my $self = shift;

    my $person = Person->new(name => 'vti')->create;
    $person->set_column(name => 'bar');
    $person->load;

    is($person->get_column('name'), 'vti');
}

sub leave_virtual_columns : Test {
    my $self = shift;

    my $person = Person->new(name => 'vti')->create;
    $person->set_column(virtual => 'bar');
    $person->load;

    is($person->get_column('virtual'), 'bar');
}

sub load_by_unique_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(name => 'vti');
    $person->load;

    is($person->column('id'), 1);
}

sub load_second_time_by_primary_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(name => 'vti');
    $person->load;

    TestDBH->dbh->do("UPDATE `person` SET `name` = 'foo' WHERE `id` = 1");

    $person->load;

    is($person->column('name'), 'foo');
}

sub throw_when_loading_not_by_primary_or_unique_key : Test {
    my $self = shift;

    my $person = $self->_build_object(profession => 'hacker');

    like(exception { $person->load }, qr/no primary or unique keys specified/);
}

sub return_undef_when_not_found : Test {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');

    ok(not defined $person->load);
}

sub is_in_db : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(name => 'vti');
    $person->load;

    ok($person->is_in_db);
}

sub not_modified : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(name => 'vti');
    $person->load;

    ok(!$person->is_modified);
}

sub _build_object {
    my $self = shift;

    return Person->new(@_);
}

sub _insert {
    my $self = shift;
    my (%params) = @_;

    my $names  = join ',', map {"`$_`"} keys %params;
    my $values = join ',', map {"'$_'"} values %params;

    TestDBH->dbh->do("INSERT INTO `person` ($names) VALUES ($values)");
}

1;
