use strict;
use warnings;

use Test::More;

use ObjectDB::Quoter;

use Book;

subtest 'quote' => sub {
    my $quoter = ObjectDB::Quoter->new;

    is $quoter->quote('foo'), '`foo`';
    is_deeply [$quoter->with], [];
};

subtest 'collect with' => sub {
    my $quoter = ObjectDB::Quoter->new(meta => Book->meta);

    is $quoter->quote('author.name'), '`author`.`name`';
    is_deeply [$quoter->with], ['author'];
};

subtest 'not collect with if exists' => sub {
    my $quoter = ObjectDB::Quoter->new(meta => Book->meta);

    $quoter->quote('author.name');
    $quoter->quote('author.name');

    is_deeply [$quoter->with], ['author'];
};

done_testing;
