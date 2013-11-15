package ManyToManyTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use TestDBH;
use TestEnv;
use Book;
use Tag;
use BookTagMap;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('book');
    TestEnv->prepare_table('tag');
    TestEnv->prepare_table('book_tag_map');
}

sub find_related : Test(2) {
    my $self = shift;

    my $book = Book->new(title => 'Crap')->create;
    my $tag = Tag->new(name => 'fiction')->create;
    Tag->new(name => 'else')->create;
    my $map = BookTagMap->new(
        book_id => $book->get_column('id'),
        tag_id  => $tag->get_column('id')
    )->create;

    $book = Book->new(title => 'Crap')->load;

    my @tags = $book->find_related('tags');

    is(@tags, 1);

    is($tags[0]->get_column('name'), 'fiction');
}

#sub create_related : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my $tag = $book->create_related('tags', name => 'horror');
#
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->load;
#
#    ok($map);
#}
#
#sub create_related_hashref : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my $tag = $book->create_related('tags', {name => 'horror'});
#
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->load;
#    ok($map);
#}
#
#sub create_related_multi : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    $book->create_related('tags', [{name => 'horror'}, {name => 'crap'}]);
#
#    is($book->count_related('tags'), 2);
#}
#
#sub create_related_multi_return_array : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my @tags =
#      $book->create_related('tags', [{name => 'horror'}, {name => 'crap'}]);
#
#    is(@tags, 2);
#}
#
#sub create_related_only_map : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    Tag->new(name => 'horror')->create;
#    my $tag = $book->create_related('tags', name => 'horror');
#
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->load;
#    ok($map);
#}
#
#sub count_related : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my $tag = Tag->new(name => 'fiction')->create;
#    Tag->new(name => 'else')->create;
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->create;
#
#    $book = Book->new(title => 'Crap')->load;
#
#    is($book->count_related('tags'), 1);
#}
#
#sub delete_map_entry_on_delete_related : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my $tag = Tag->new(name => 'fiction')->create;
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->create;
#
#    $book = Book->new(title => 'Crap')->load;
#
#    $book->delete_related('tags');
#
#    ok(!$map->load);
#}
#
#sub delete_only_map_entry_on_delete_related : Test {
#    my $self = shift;
#
#    my $book = Book->new(title => 'Crap')->create;
#    my $tag = Tag->new(name => 'fiction')->create;
#    my $map = BookTagMap->new(
#        book_id => $book->get_column('id'),
#        tag_id  => $tag->get_column('id')
#    )->create;
#
#    $book = Book->new(title => 'Crap')->load;
#
#    $book->delete_related('tags');
#
#    ok($tag->load);
#}

1;
