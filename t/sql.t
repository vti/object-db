#!/usr/bin/env perl

use lib 't/lib';

use Test::Class::Load qw(t/tests/sql);

BEGIN { $ENV{TEST_SUITE} = 1 }

Test::Class->runtests;
