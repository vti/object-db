package OneToOneTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Meta::Relationship::OneToOne;

sub build_to_source : Test {
    my $self = shift;

    my $rel = $self->_build_relationship(
        type       => 'one to one',
        orig_class => 'Author',
        class      => 'Book',
        map        => {id => 'book_author_id'}
    );

    is_deeply(
        $rel->to_source,
        {   table      => 'book',
            join       => 'left',
            constraint => ['author.id' => {-col => 'book.book_author_id'}],
            columns    => ['id', 'author_id', 'title']
        }
    );
}

sub _build_relationship {
    my $self = shift;

    return ObjectDB::Meta::Relationship::OneToOne->new(@_);
}

1;
