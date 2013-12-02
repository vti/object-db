use Test::Spec;
use Test::Fatal;

use lib 't/lib';

use TestDBH;
use TestEnv;
use Book;
use Tag;
use BookTagMap;

describe 'many to many' => sub {

    before each => sub {
        TestEnv->prepare_table('book');
        TestEnv->prepare_table('tag');
        TestEnv->prepare_table('book_tag_map');
    };

    it 'find_related' => sub {
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
    };

   #sub create_related' => sub {
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
   #sub create_related_hashref' => sub {
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
   #sub create_related_multi' => sub {
   #    my $self = shift;
   #
   #    my $book = Book->new(title => 'Crap')->create;
   #    $book->create_related('tags', [{name => 'horror'}, {name => 'crap'}]);
   #
   #    is($book->count_related('tags'), 2);
   #}
   #
   #sub create_related_multi_return_array' => sub {
   #    my $self = shift;
   #
   #    my $book = Book->new(title => 'Crap')->create;
   #    my @tags =
   #      $book->create_related('tags', [{name => 'horror'}, {name => 'crap'}]);
   #
   #    is(@tags, 2);
   #}
   #
   #sub create_related_only_map' => sub {
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
   #sub count_related' => sub {
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
   #sub delete_map_entry_on_delete_related' => sub {
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
   #sub delete_only_map_entry_on_delete_related' => sub {
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
};

runtests unless caller;
