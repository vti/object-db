package ManyToOneTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use ObjectDB::Table;
use Author;
use Book;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('author');
    TestEnv->prepare_table('book');
}

sub find_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new(title => 'Crap')->load;

    $author = $book->find_related('parent_author');

    is($author->get_column('name'), 'vti');
}

1;
