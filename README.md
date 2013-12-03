# NAME

ObjectDB - usable ORM

# SYNOPSIS

    package MyDB;
    use base 'ObjectDB';

    sub init_db {
        ...
        return $dbh;
    }

    package MyAuthor;
    use base 'MyDB';

    __PACKAGE__->meta(
        table          => 'author',
        columns        => [qw/id name/],
        primary_key    => 'id',
        auto_increment => 'id',
        relationships  => {
            books => {
                type = 'one to many',
                class => 'MyBook',
                map   => {id => 'author_id'}
            }
        }
    );

    package MyBook;
    use base 'MyDB';

    __PACKAGE__->meta(
        table          => 'book',
        columns        => [qw/id author_id title/],
        primary_key    => 'id',
        auto_increment => 'id',
        relationships  => {
            author => {
                type = 'many to one',
                class => 'MyAuthor',
                map   => {author_id => 'id'}
            }
        }
    );

    my $book_by_id = MyBook->new(id => 1)->load(with => 'author');

    my @books_authored_by_Pushkin =
      MyBook->table->find(where => ['author.name' => 'Pushkin']);

    $author->create_related('books', title => 'New Book');

# DESCRIPTION

ObjectDB is a lightweight and flexible object-relational mapper. While being
light it stays usable. ObjectDB borrows many things from [Rose::DB::Object](http://search.cpan.org/perldoc?Rose::DB::Object),
but unlike the last one columns are not objects, everything is pretty much
straight forward and flat.

## Actions on rows

## Actions on tables

In order to perform an action on table a [ObjectDB::Table](http://search.cpan.org/perldoc?ObjectDB::Table) object must be
obtained via `table` method (see [ObjectDB::Table](http://search.cpan.org/perldoc?ObjectDB::Table) for all available actions).
The only exception is `find`, it is available in a row object for convenience.

    MyBook->table->delete; # deletes ALL records from MyBook

## Actions on related objects

## Transactions

All the exceptions will be catched, a rollback will be run and exceptions will
be rethrown. It is safe to use `rollback` or `commit` inside of a transaction
when you want to do custom exception handling.

    MyDB->txn(
        sub {
            ... do smth that can throw ...
        }
    );

`txn`'s return value is preserved, so it is safe to do something like:

    my $result = MyDB->txn(
        sub {
            return 'my result';
        }
    );

### Methods

- `txn`

    Accepts a subroutine reference, wraps code into eval and runs it rethrowing all
    exceptions.

- `commit`

    Commit transaction.

- `rollback`

    Rollback transaction.

## Utility methods

### Methods

- `init_db`

    Returns current `DBI` instance.

- `is_modified`

    Returns 1 if object is modified.

- `is_in_db`

    Returns 1 if object is in database.

- `is_related_loaded`

    Checks if related objects are loaded.

- `to_hash`

    Converts object into a hash reference, including all preloaded objects.

# AUTHOR

Viacheslav Tykhanovskyi

# COPYRIGHT AND LICENSE

Copyright 2013, Viacheslav Tykhanovskyi.

This module is free software, you may distribute it under the same terms as Perl.
