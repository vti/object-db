package TableCountTest;

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
use Person;

sub setup : Test(setup) {
    my $self = shift;

    TestEnv->prepare_table('person');
    TestEnv->prepare_table('book');
    TestEnv->prepare_table('author');
}

sub return_zero_on_empty_table : Test {
    my $self = shift;

    my $table = $self->_build_table;

    is($table->count, 0);
}

sub count_rows : Test {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 10;

    my $table = $self->_build_table;

    is($table->count, 10);
}

sub count_rows_with_query : Test {
    my $self = shift;

    Person->new(name => $_)->create for 1 .. 10;

    my $table = $self->_build_table;

    is($table->count(where => [name => {'>=' => 5}]), 5);
}

sub count_rows_with_query_and_join : Test {
    my $self = shift;

    my $author = Author->new(name => 'author')->create;
    Book->new(title => $_, author_id => $author->column('id'))->create
      for 1 .. 2;

    my $author2 = Author->new(name => 'author2')->create;
    Book->new(title => $_, author_id => $author2->column('id'))->create
      for 1 .. 3;

    my $table = $self->_build_table(class => 'Book');

    is($table->count(where => ['author.name' => 'author']), 2);
}

sub _build_table {
    my $self = shift;

    return ObjectDB::Table->new(class => 'Person', dbh => TestDBH->dbh, @_);
}

1;
