use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use Author;
use Book;

describe 'many to one' => sub {

    before each => sub {
        TestEnv->prepare_table('author');
        TestEnv->prepare_table('book');
    };

    it 'find_related' => sub {
        my $author = Author->new(name => 'vti')->create;
        my $book =
          Book->new(title => 'Crap', author_id => $author->get_column('id'))
          ->create;

        $book = Book->new(title => 'Crap')->load;

        $author = $book->find_related('parent_author');

        is($author->get_column('name'), 'vti');
    };

};

runtests unless caller;
