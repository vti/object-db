#!/usr/bin/env perl

use lib 't/lib';
use lib 't/tests';

use UtilTest;
use ColumnsTest;
use ConnectionTest;
use DBHPoolTest;

Test::Class->runtests;
