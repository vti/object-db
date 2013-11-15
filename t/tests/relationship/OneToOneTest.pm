package OneToOneTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use ObjectDB::Table;
use Book;
use BookDescription;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('book');
    TestEnv->prepare_table('book_description');
}

sub create_related : Test {
    my $self = shift;

    my $book = Book->new(title => 'fiction')->create;
    $book->create_related('description', description => 'Crap');

    ok($book->related('description'));
}

sub create_related_object : Test {
    my $self = shift;

    my $book = Book->new(title => 'fiction')->create;
    $book->create_related('description',
        BookDescription->new(description => 'Crap'));

    my $description = BookDescription->table->find(
        first => 1,
        where => [book_id => $book->get_column('id')]
    );
    is($description->get_column('description'), 'Crap');
}

sub find_related : Test {
    my $self = shift;

    my $book = Book->new(title => 'fiction')->create;
    my $description =
      BookDescription->new(description => 'Crap', book_id => $book->get_column('id'))
      ->create;

    $book = Book->new(id => $book->get_column('id'))->load;

    $description = $book->find_related('description');

    is($description->get_column('description'), 'Crap');
}

sub updated_related : Test {
    my $self = shift;

    my $book = Book->new(title => 'fiction')->create;
    my $description =
      BookDescription->new(description => 'Crap', book_id => $book->get_column('id'))
      ->create;

    $book = Book->new(id => $book->get_column('id'))->load;

    $book->update_related('description', set => {description => 'Good'});

    $book = Book->new(id => $book->get_column('id'))->load(with => 'description');

    is($book->related('description')->get_column('description'), 'Good');
}

sub delete_related : Test {
    my $self = shift;

    my $book = Book->new(title => 'fiction')->create;
    $book->create_related('description', description => 'Crap');

    $book->delete_related('description');

    ok(!$book->related('description'));
}

1;
