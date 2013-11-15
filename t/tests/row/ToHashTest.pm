package ToHashTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use Author;
use Book;
use Person;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('author');
}

sub to_hash : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;

    is_deeply($author->to_hash, {id => 1, name => 'vti'});
}

sub with_virtual_columns : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->set_column(virtual => 'bar');

    is_deeply($author->to_hash, {id => 1, name => 'vti', virtual => 'bar'});
}

sub with_default_values : Test {
    my $self = shift;

    my $person = Person->new();

    is_deeply($person->to_hash, {profession => 'slacker'});
}

sub with_related : Test {
    my $self = shift;

    my $author = Author->new(name => 'vti')->create;
    $author->create_related('books', title => 'Crap');

    my $book = Book->new(title => 'Crap')->load(with => 'parent_author');

    is_deeply(
        $book->to_hash,
        {
            id            => 1,
            author_id     => 1,
            title         => 'Crap',
            parent_author => {id => 1, name => 'vti'}
        }
    );
}

1;
