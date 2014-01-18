use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestEnv;
use Author;
use Book;
use BookDescription;

describe 'table find with related' => sub {
    before each => sub {
        TestEnv->prepare_table('author');
        TestEnv->prepare_table('book');
        TestEnv->prepare_table('book_description');
    };

    it 'find_many_to_one' => sub {
        Author->new(
            name  => 'vti',
            books => [{title => 'Book1'}, {title => 'Book2'}]
        )->create;

        my $author = Author->new->table->find(first => 1, with => 'books');
        ok $author->is_related_loaded('books');
        is($author->related('books')->[0]->get_column('title'), 'Book1');
        is($author->related('books')->[1]->get_column('title'), 'Book2');
    };

    it 'find_many_to_one_deeply' => sub {
        my $author = Author->new(
            name  => 'vti',
            books => [
                {title => 'Book1', description => {description => 'Crap1'}},
                {title => 'Book2', description => {description => 'Crap2'}}
            ]
        )->create;

        $author = Author->new->table->find(
            first => 1,
            with  => [qw/books books.description/]
        );

        ok $author->is_related_loaded('books');
        ok $author->related('books')->[0]->is_related_loaded('description');
        is(
            $author->related('books')->[0]->related('description')
              ->get_column('description'),
            'Crap1'
        );
    };

    it 'find_many_to_one_with_query' => sub {
        my $author = Author->new(
            name  => 'vti',
            books => [
                {title => 'Book1', description => {description => 'Crap1'}},
                {title => 'Book2', description => {description => 'Crap2'}}
            ]
        )->create;

        $author = Author->new->table->find(
            first => 1,
            with  => [qw/books books.description/],
            where => ['books.description.description' => 'Crap2']
        );
        ok $author->is_related_loaded('books');
        ok $author->related('books')->[0]->is_related_loaded('description');
        is(
            $author->related('books')->[0]->related('description')
              ->get_column('description'),
            'Crap2'
        );
    };

    it 'finds related objects ordered' => sub {
        Author->new(
            name  => 'vti',
            books => [{title => 'Book1'}, {title => 'Book2'}]
        )->create;
        Author->new(
            name  => 'bill',
            books => [{title => 'Book2'}, {title => 'Book1'}]
        )->create;

        my @authors = Author->new->table->find(
            with     => [qw/books/],
            order_by => 'books.title'
        );
        is(@authors, 2);
        ok $authors[0]->is_related_loaded('books');
        is($authors[0]->related('books')->[0]->get_column('title'), 'Book1');
        is($authors[0]->related('books')->[1]->get_column('title'), 'Book2');
        ok $authors[1]->is_related_loaded('books');
        is($authors[1]->related('books')->[0]->get_column('title'), 'Book1');
        is($authors[1]->related('books')->[1]->get_column('title'), 'Book2');
    };

};

runtests unless caller;
