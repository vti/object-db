use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Fatal;
use TestDBH;
use TestEnv;

use Author;
use Book;
use Person;

subtest 'to_hash' => sub {
    _setup();

    my $author = Author->new(name => 'vti')->create;

    is_deeply($author->to_hash, { id => 1, name => 'vti' });
};

subtest 'with_virtual_columns' => sub {
    _setup();

    my $author = Author->new(name => 'vti')->create;
    $author->set_column(virtual => 'bar');

    is_deeply($author->to_hash, { id => 1, name => 'vti', virtual => 'bar' });
};

subtest 'with_default_values' => sub {
    _setup();

    my $person = Person->new();

    is_deeply($person->to_hash, { profession => 'slacker' });
};

subtest 'with_related' => sub {
    _setup();

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    my $book = Book->new(title => 'Crap')->load(with => 'parent_author');

    is_deeply(
        $book->to_hash,
        {
            id            => 1,
            author_id     => 1,
            title         => 'Crap',
            parent_author => { id => 1, name => 'vti' }
        }
    );
};

subtest 'with related empty' => sub {
    _setup();

    Book->new(title => 'Crap')->create;

    my $book = Book->new(title => 'Crap')->load(with => 'parent_author');
    $book->related('parent_author');

    is_deeply(
        $book->to_hash,
        {
            id        => 1,
            author_id => 0,
            title     => 'Crap',
        }
    );
};

subtest 'with_related multi' => sub {
    _setup();

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    $author->load(with => 'books');

    is_deeply(
        $author->to_hash,
        {
            id    => 1,
            name  => 'vti',
            books => [ { id => 1, author_id => 1, title => 'Crap' } ]
        }
    );
};

done_testing;

sub _setup {
    TestEnv->prepare_table('author');
    TestEnv->prepare_table('book');
}
