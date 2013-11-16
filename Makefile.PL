#!/usr/bin/env perl

use 5.008007;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my ($mm) = $ExtUtils::MakeMaker::VERSION =~ /^([^_]+)/;

WriteMakefile(
    NAME          => 'ObjectDB',
    VERSION_FROM  => 'lib/ObjectDB.pm',
    ABSTRACT_FROM => 'lib/ObjectDB.pm',
    AUTHOR        => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (
        $mm < 6.46
        ? ()
        : (
            META_MERGE => {
                requires  => {perl => '5.008007'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    repository => 'http://github.com/vti/object-db3'
                },
                no_index => {directory => [qw/t/]}
            }
        )
    ),

    PREREQ_PM => {
        'Carp'        => 0,
        'Storable'    => 0,
        'Test::More'  => 0,
        'Test::Fatal' => 0,
        'Test::Spec'  => 0,

        'SQL::Builder' => 0,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
    clean => {FILES    => 'ObjectDB-*'},
    test  => {TESTS    => 't/*.t t/*/*.t'}
);
