package TransactionTest;

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

sub commit : Test {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');

    $person->txn(sub { $person->create });

    my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

    is(@$result, 1);
}

sub rollback : Test {
    my $self = shift;

    my $person = $self->_build_object(name => 'vti');

    eval {
        $person->txn(
            sub {
                $person->create;
                die;
            }
        );
    };

    my $result = TestDBH->dbh->selectall_arrayref('SELECT * FROM `person`');

    is(@$result, 0);
}

sub _build_object {
    my $self = shift;

    return Person->new(@_);
}

1;
