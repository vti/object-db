use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use Author;
use Book;

describe 'related' => sub {

    before each => sub {
        TestEnv->prepare_table('author');
        TestEnv->prepare_table('book');
    };

    it 'related' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new(title => 'Crap')->load(with => 'parent_author');

        is($book->related('parent_author')->get_column('name'), 'vti');
    };

    it 'is_related_loaded' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new(title => 'Crap')->load(with => 'parent_author');

        ok($book->is_related_loaded('parent_author'));
    };

    it 'load_related_on_demand' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new(title => 'Crap')->load;

        is($book->related('parent_author')->get_column('name'), 'vti');
    };

    it 'is_related_loaded_false' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new(title => 'Crap')->load;

        ok(!$book->is_related_loaded('parent_author'));
    };

};

runtests unless caller;
