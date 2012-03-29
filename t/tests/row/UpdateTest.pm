package UpdateTest;

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

sub update_by_primary_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(id => 1);
    $person->set_column(name => 'foo');
    $person->update;

    $person = $self->_build_object(id => 1);
    $person->load;

    is($person->column('name'), 'foo');
}

sub update_by_unique_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti', profession => 'hacker');

    my $person = $self->_build_object(name => 'vti');
    $person->set_column(profession => 'slacker');
    $person->update;

    $person = $self->_build_object(id => 1);
    $person->load;

    is($person->column('profession'), 'slacker');
}

sub update_second_time_by_primary_key : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(name => 'vti');
    $person->load;

    $person->set_column(name => 'foo');
    $person->update;

    $person = $self->_build_object(id => 1);
    $person->load;

    is($person->column('name'), 'foo');
}

sub throw_when_updating_not_by_primary_or_unique_key : Test {
    my $self = shift;

    my $person = $self->_build_object(profession => 'hacker');
    $person->set_column(profession => 'slacker');

    like(exception { $person->update }, qr/no primary or unique keys specified/);
}

sub throw_when_update_didnt_occur : Test {
    my $self = shift;

    my $person = $self->_build_object(id => 1);
    $person->set_column(name => 'vti');

    like(exception { $person->update }, qr/Object was not updated/);
}

sub do_nothing_on_second_update : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(id => 1);
    $person->set_column(name => 'vti');

    $person->update;

    ok($person->update);
}

sub not_modified_after_update : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(id => 1);
    $person->set_column(name => 'vti');

    $person->update;

    ok(!$person->is_modified);
}

sub is_in_db : Test {
    my $self = shift;

    $self->_insert(id => 1, name => 'vti');

    my $person = $self->_build_object(id => 1);
    $person->set_column(name => 'vti');

    $person->update;

    ok($person->is_in_db);
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
