use strict;
use warnings;

use Test::More;
use Test::Fatal;

use ObjectDB::With;

use Book;
use BookDescription;

subtest 'convert with to joins' => sub {
    my $with = ObjectDB::With->new(meta => Book->meta, with => ['author']);

    is_deeply $with->to_joins,
      [
        {
            source  => 'author',
            as      => 'author',
            op      => 'left',
            columns => [qw/id name/],
            on      => ['book.author_id' => {-col => 'author.id'}],
            join    => [],
        }
      ];
};

subtest 'convert with to joins deeply' => sub {
    my $with = ObjectDB::With->new(
        meta => BookDescription->meta,
        with => ['book', 'book.author']
    );

    is_deeply $with->to_joins,
      [
        {
            source  => 'book',
            as      => 'book',
            op      => 'left',
            columns => [qw/id author_id title/],
            on      => ['book_description.book_id' => {-col => 'book.id'}],
            join    => [
                {
                    source  => 'author',
                    as      => 'author',
                    op      => 'left',
                    columns => [qw/id name/],
                    on      => ['book.author_id' => {-col => 'author.id'}],
                    join    => []
                }
            ]
        },
      ];
};

subtest 'autoload intermediate joins' => sub {
    my $with = ObjectDB::With->new(
        meta => BookDescription->meta,
        with => ['book.author']
    );

    is_deeply $with->to_joins,
      [
        {
            source  => 'book',
            as      => 'book',
            op      => 'left',
            columns => [qw/id author_id title/],
            on      => ['book_description.book_id' => {-col => 'book.id'}],
            join    => [
                {
                    source  => 'author',
                    as      => 'author',
                    op      => 'left',
                    columns => [qw/id name/],
                    on      => ['book.author_id' => {-col => 'author.id'}],
                    join    => []
                }
            ]
        },
      ];
};

subtest 'throw when unknown relationship' => sub {
    like
      exception { ObjectDB::With->new(meta => Book->meta, with => ['unknown']) }
    , qr/Unknown relationship 'unknown' in Book/;
};

done_testing;
