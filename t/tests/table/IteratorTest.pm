package IteratorTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use ObjectDB::Iterator;
use Person;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('person');
}

sub iterator : Test {
    my $self = shift;

    ok(1);
    #Person->new(name => 'vti')->create;

    #my $sth =
    #  TestDBH->dbh->prepare('SELECT id, name, profession FROM person');
    #$sth->execute;

    #my $iterator = $self->_build_iterator(
    #    walker => sub {
    #        my @row = $sth->fetchrow_array;
    #        return unless @row;

    #        my @columns = Person->meta->columns;

    #        my $object = Person->_map_row_to_object(
    #            row     => \@row,
    #            columns => \@columns,
    #            with    => $self->{with}
    #        );

    #        return $object;
    #    }
    #);

    #is($iterator->next->get_column('name'), 'vti');
}

sub _build_iterator {
    my $self = shift;

    return ObjectDB::Iterator->new(class => 'Person', @_);
}

1;
