package DBTestBase;

use strict;
use warnings;

use base 'Test::Class';

use TestEnv;

sub DBTestBase::SKIP_CLASS {
    my $self = shift;

    !eval { require DBD::SQLite; 1 }
}

sub startup : Test(startup) {
    TestEnv->setup;
}

sub shutdown : Test(shutdown) {
    TestEnv->teardown;
}

1;
