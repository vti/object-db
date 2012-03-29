package RelatedTest;

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

sub related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new(title => 'Crap')->load(with => 'author');

    is($book->related('author')->get_column('name'), 'vti');
}

sub is_related_loaded : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new(title => 'Crap')->load(with => 'author');

    ok($book->is_related_loaded('author'));
}

sub load_related_on_demand : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new(title => 'Crap')->load;

    is($book->related('author')->get_column('name'), 'vti');
}

sub is_related_loaded_false : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    my $book =
      Book->new(title => 'Crap', author_id => $author->get_column('id'))
      ->create;

    $book = Book->new(title => 'Crap')->load;

    ok(!$book->is_related_loaded('author'));
}

1;
