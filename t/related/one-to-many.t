use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use Author;
use Book;

describe 'one to many' => sub {

    before each => sub {
        TestEnv->prepare_table('author');
        TestEnv->prepare_table('book');
    };

    it 'create_related' => sub {
        my $author = Author->new(name => 'vti')->create;

        $author->create_related('books', title => 'Crap');

        my $book = Book->new(title => 'Crap')->load;

        is($book->get_column('author_id'), $author->get_column('id'));
    };

    it 'create_related_hashref' => sub {
        my $author = Author->new(name => 'vti')->create;

        $author->create_related('books', {title => 'Crap'});

        my $book = Book->new(title => 'Crap')->load;

        is($book->get_column('author_id'), $author->get_column('id'));
    };

    it 'create_related_multi' => sub {
        my $author = Author->new(name => 'vti')->create;

        $author->create_related('books',
            [{title => 'Crap'}, {title => 'Good'}]);

        is($author->count_related('books'), 2);
    };

    it 'create related from object' => sub {
        my $author = Author->new(name => 'vti')->create;

        $author->create_related('books', [Book->new(title => 'Crap')]);

        is($author->count_related('books'), 1);
    };

    it 'create related from already created object' => sub {
        my $author = Author->new(name => 'vti')->create;

        $author->create_related('books', [Book->new(title => 'Crap')->create]);

        is($author->count_related('books'), 1);
    };

    it 'find_related' => sub {
        my $author = Author->new(name => 'vti')->create;
        $author->create_related('books', title => 'Crap');
        $author->create_related('books', title => 'Good');
        Author->new(name => 'foo')->create;

        my @books = $author->find_related('books');

        is(@books,                                                  2);
        is($books[0]->related('parent_author')->get_column('name'), 'vti');
    };

    it 'related' => sub {
        my $author = Author->new(name => 'vti')->create;
        $author->create_related('books', title => 'Crap');
        $author->create_related('books', title => 'Good');
        Author->new(name => 'foo')->create;

        my @books = $author->related('books');

        is(@books,                                                  2);
        is($books[0]->related('parent_author')->get_column('name'), 'vti');
    };

    it 'count_related' => sub {
        my $author = Author->new(name => 'vti')->create;
        $author->create_related('books', title => 'Crap');

        $author = Author->new(name => 'vti')->load;

        is($author->count_related('books'), 1);
    };

    it 'update_related' => sub {
        my $author = Author->new(name => 'vti')->create;
        $author->create_related('books', title => 'Crap');

        $author = Author->new(name => 'vti')->load;
        $author->update_related('books', set => {title => 'Good'});

        my $book = Book->new(title => 'Good')->load;
        ok($book);
    };

    it 'delete_related' => sub {
        my $author = Author->new(name => 'vti')->create;
        $author->create_related('books', title => 'Crap');

        $author = Author->new(name => 'vti')->load;
        $author->delete_related('books');

        is($author->count_related('books'), 0);
    };

};

runtests unless caller;
