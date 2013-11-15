package TableFindWithRelatedTest;

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

sub find_many_to_one : Test(2) {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new->table->find(first => 1, with => 'author');
    ok $book->is_related_loaded('author');
    is($book->related('author')->get_column('name'), 'vti');
}

sub find_many_to_one_with_query : Test(2) {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;
    Author->new(name => 'foo')->create;

    $book = Book->new->table->find(first => 1, with => 'author', where => ['author.name' => 'vti']);
    ok $book->is_related_loaded('author');
    is($book->related('author')->get_column('name'), 'vti');
}

1;
