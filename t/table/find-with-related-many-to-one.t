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
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new->table->find(first => 1, with => 'parent_author');
        ok $book->is_related_loaded('parent_author');
        is($book->related('parent_author')->get_column('name'), 'vti');
    };

    it 'find_many_to_one_deeply' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;
        my $description = BookDescription->new(
            description => 'Very',
            book_id     => $book->get_column('id')
        )->create;

        $description = BookDescription->new->table->find(
            first => 1,
            with  => 'parent_book.parent_author'
        );
        ok $description->is_related_loaded('parent_book');
        is($description->related('parent_book')->get_column('title'), 'Crap');
        ok $description->related('parent_book')
          ->is_related_loaded('parent_author');
        is(
            $description->related('parent_book')->related('parent_author')
              ->get_column('name'),
            'vti'
        );
    };

    it 'find_many_to_one_with_query' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;
        Author->new(name => 'foo')->create;

        $book = Book->new->table->find(
            first => 1,
            where => ['parent_author.name' => 'vti']
        );
        ok $book->is_related_loaded('parent_author');
        is($book->related('parent_author')->get_column('name'), 'vti');
    };
};

runtests unless caller;
