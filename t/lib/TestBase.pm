package TestBase;

use strict;
use warnings;

use base 'Test::Class';

INIT { Test::Class->runtests unless $ENV{TEST_SUITE} }

#sub startup : Test(startup) {
#}
#
#sub shutdown : Test(shutdown) {
#}

1;
