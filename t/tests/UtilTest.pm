package MetaTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Util qw(each_pair);

sub pairwise : Test {

    my @array = (foo => 'bar');

    my %hash;
    each_pair {
        my ($key, $value) = @_;
        $hash{$key} = $value;
    }
    @array;

    is_deeply(\%hash, {foo => 'bar'});
}

1;
