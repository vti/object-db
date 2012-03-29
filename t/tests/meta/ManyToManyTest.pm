package ManyToManyTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Meta::Relationship::ManyToMany;

sub build_to_source : Test {
    my $self = shift;

    my $rel = $self->_build_relationship(
        orig_class => 'Book',
        type       => 'many to many',
        map_class  => 'BookTagMap',
        map_from   => 'book',
        map_to     => 'tag'
    );

    is_deeply(
        [$rel->to_source],
        [   {   table      => 'book_tag_map',
                join       => 'left',
                constraint => ['book.id' => {-col => 'book_tag_map.book_id'}]
            },
            {   table      => 'tag',
                join       => 'left',
                constraint => ['book_tag_map.tag_id' => {-col => 'tag.id'}],
                columns => ['id', 'name']
            }
        ]
    );
}

sub _build_relationship {
    my $self = shift;

    return ObjectDB::Meta::Relationship::ManyToMany->new(@_);
}

1;
