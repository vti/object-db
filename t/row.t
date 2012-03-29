#!/usr/bin/env perl

use lib 't/lib';

use Test::Class::Load qw(t/tests/row);

Test::Class->runtests;
