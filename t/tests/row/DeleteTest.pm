package DeleteTest;

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

    $self->{person} = Person->new(name => 'vti')->create;
}

sub delete_by_primary_key : Test {
    my $self = shift;

    my $person = $self->_build_object(id => $self->{person}->get_column('id'));

    $person->delete;

    $person = $self->_build_object(id => $self->{person}->get_column('id'));
    ok(!$person->load);
}

sub delete_by_unique_key : Test {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');
    $person->delete;

    $person = $self->_build_object(id => $self->{person}->get_column('id'));
    ok(!$person->load);
}

sub throw_when_deleting_not_by_primary_or_unique_key : Test {
    my $self = shift;

    my $person = $self->_build_object(profession => 'hacker');

    like(exception { $person->delete }, qr/no primary or unique keys specified/);
}

sub throw_when_delete_didnt_occur : Test {
    my $self = shift;

    my $person = $self->_build_object(id => 999);

    like(exception { $person->delete }, qr/Object was not deleted/);
}

#sub do_nothing_on_second_update : Test {
#    my $self = shift;
#
#    $self->_insert(id => 1, name => 'vti');
#
#    my $person = $self->_build_object(id => 1);
#    $person->set_column(name => 'vti');
#
#    $person->update;
#
#    ok($person->update);
#}

sub empty_object_after_deletion : Test {
    my $self = shift;

    my $person = $self->_build_object(id => 1);

    $person->delete;

    ok(not defined $person->get_column('id'));
}

sub not_modified_after_delete : Test {
    my $self = shift;

    my $person = $self->_build_object(id => 1);

    $person->delete;

    ok(!$person->is_modified);
}

sub not_in_db : Test {
    my $self = shift;

    my $person = $self->_build_object(id => 1);

    $person->delete;

    ok(!$person->is_in_db);
}

sub _build_object {
    my $self = shift;

    return Person->new(@_);
}

1;
