#!/usr/bin/env perl

use lib 't/lib';
use lib 't/tests';

BEGIN { $ENV{TEST_SUITE} = 1 }

use UtilTest;
use ColumnsTest;
use ConnectionTest;
use DBHPoolTest;

Test::Class->runtests;
