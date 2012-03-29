package InheritedConnection;
use base 'TestDB';

package SetterConnection;
use base 'ObjectDB';

package ConnectionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use Book;

sub via_method : Test {
    my $self = shift;

    my $dbh = InheritedConnection->init_db;

    isa_ok($dbh, 'DBI::db');
}

sub via_setter : Test {
    my $self = shift;

    my $dbh = TestDBH->dbh;
    SetterConnection->init_db($dbh);
    $dbh = SetterConnection->init_db;

    isa_ok($dbh, 'DBI::db');
}

sub via_pool : Test {
    my $self = shift;

    SetterConnection->init_db(
        dsn   => 'dbi:SQLite::memory:',
        attrs => {RaiseError => 1}
    );
    my $dbh = SetterConnection->init_db;

    isa_ok($dbh, 'DBI::db');
}

1;
