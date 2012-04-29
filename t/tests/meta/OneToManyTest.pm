package OneToManyTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Meta::Relationship::OneToMany;

sub build_to_source : Test {
    my $self = shift;

    my $rel = $self->_build_relationship(
        name       => 'books',
        type       => 'one to many',
        orig_class => 'Author',
        class      => 'Book',
        map        => {id => 'book_author_id'}
    );

    is_deeply(
        $rel->to_source,
        {   table      => 'book',
            as         => 'books',
            join       => 'left',
            constraint => ['author.id' => {-col => 'books.book_author_id'}],
            columns    => ['books.id', 'books.author_id', 'books.title']
        }
    );
}

sub _build_relationship {
    my $self = shift;

    return ObjectDB::Meta::Relationship::OneToMany->new(@_);
}

1;
