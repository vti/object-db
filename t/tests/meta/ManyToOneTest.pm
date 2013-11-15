package ManyToOneTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Meta::Relationship::ManyToOne;

sub build_to_source : Test {
    my $self = shift;

    my $rel = $self->_build_relationship(
        name       => 'author',
        type       => 'many to one',
        class      => 'Author',
        orig_class => 'Book',
        map        => {book_author_id => 'id'}
    );

    is_deeply(
        $rel->to_source,
        {   table      => 'author',
            as         => 'author',
            join       => 'left',
            constraint => ['book.book_author_id' => {-col => 'author.id'}],
            columns => ['id', 'name']
        }
    );
}

sub accept_columns_but_leave_primary_key : Test {
    my $self = shift;

    my $rel = $self->_build_relationship(
        name       => 'author',
        type       => 'many to one',
        class      => 'Author',
        orig_class => 'Book',
        map        => {book_author_id => 'id'}
    );

    is_deeply(
        $rel->to_source(columns => []),
        {   table      => 'author',
            as         => 'author',
            join       => 'left',
            constraint => ['book.book_author_id' => {-col => 'author.id'}],
            columns    => ['id']
        }
    );
}

#sub accept_join_type : Test {
#    my $self = shift;
#
#    my $rel = $self->_build_relationship(
#        type       => 'many to one',
#        class      => 'User',
#        orig_class => 'Article',
#        map        => {user_id => 'id'},
#        join       => 'inner'
#    );
#
#    is_deeply(
#        $rel->to_source,
#        {   table      => 'user',
#            join       => 'inner',
#            constraint => ['article.user_id' => {-col => 'user.id'}],
#            columns => []
#        }
#    );
#}

#sub accept_join_args : Test {
#    my $self = shift;
#
#    my $rel = $self->_build_relationship(
#        type       => 'many to one',
#        class      => 'User',
#        orig_class => 'Article',
#        map        => {user_id => 'id'},
#        join_args  => [master_type => \'foo']
#    );
#
#    is_deeply(
#        $rel->to_source,
#        {   table      => 'user',
#            join       => 'left',
#            constraint => [
#                'article.user_id'  => {-col => 'user.id'},
#                'user.master_type' => 'foo'
#            ],
#            columns => []
#        }
#    );
#}

sub _build_relationship {
    my $self = shift;

    return ObjectDB::Meta::Relationship::ManyToOne->new(@_);
}

1;
