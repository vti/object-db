package OneToManyTest;

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

sub create_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;

    $author->create_related('books', title => 'Crap');

    my $book = Book->new(title => 'Crap')->load;

    is($book->get_column('author_id'), $author->get_column('id'));
}

sub create_related_hashref : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;

    $author->create_related('books', {title => 'Crap'});

    my $book = Book->new(title => 'Crap')->load;

    is($book->get_column('author_id'), $author->get_column('id'));
}

sub create_related_multi : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;

    $author->create_related('books', [{title => 'Crap'}, {title => 'Good'}]);

    is($author->count_related('books'), 2);
}

sub find_related : Test(2) {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');
    $author->create_related('books', title => 'Good');
    Author->new(name => 'foo')->create;

    my @books = $author->find_related('books');

    is(@books, 2);
    is($books[0]->related('parent_author')->get_column('name'), 'vti');
}

sub related : Test(2) {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');
    $author->create_related('books', title => 'Good');
    Author->new(name => 'foo')->create;

    my @books = $author->related('books');

    is(@books, 2);
    is($books[0]->related('parent_author')->get_column('name'), 'vti');
}

sub count_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    $author = Author->new(name => 'vti')->load;

    is($author->count_related('books'), 1);
}

sub update_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    $author = Author->new(name => 'vti')->load;
    $author->update_related('books', set => {title => 'Good'});

    my $book = Book->new(title => 'Good')->load;
    ok($book);
}

sub delete_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    $author = Author->new(name => 'vti')->load;
    $author->delete_related('books');

    is($author->count_related('books'), 0);
}

1;
