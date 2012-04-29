package MapperTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use ObjectDB::Mapper;

use Person;
use Book;
use BookDescription;

sub build_sql : Test(2) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Person->meta);

    my ($sql, @bind) = $mapper->to_sql(where => [a => 1]);

    is($sql,
        'SELECT `person`.`id`, `person`.`name`, `person`.`profession` FROM `person` WHERE `person`.`a` = ?'
    );
    is_deeply([@bind], [1]);
}

sub build_sql_with_columns : Test(2) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Person->meta);

    my ($sql, @bind) =
      $mapper->to_sql(columns => ['name'], where => [a => 1]);

    is($sql,
        'SELECT `person`.`id`, `person`.`name` FROM `person` WHERE `person`.`a` = ?'
    );
    is_deeply([@bind], [1]);
}

sub build_sql_with_related : Test(2) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Book->meta);

    my ($sql, @bind) = $mapper->to_sql(with => 'author');

    is($sql,
        'SELECT `book`.`id`, `book`.`author_id`, `book`.`title`, `author`.`id`, `author`.`name` FROM `book` LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id`'
    );
    is_deeply([@bind], []);
}

sub build_sql_with_related_and_columns : Test(3) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Book->meta);

    my ($sql, @bind) = $mapper->to_sql(with => {name => 'description', columns => ['description']});

    is($sql,
        'SELECT `book`.`id`, `book`.`author_id`, `book`.`title`, `description`.`id`, `description`.`description` FROM `book` LEFT JOIN `book_description` AS `description` ON `book`.`id` = `description`.`book_id`'
    );
    is_deeply([@bind], []);

    my $book = $mapper->from_row([1, 1, 'Good', 1, 'Good']);

    is($book->related('description')->get_column('description'), 'Good');
}

sub build_sql_with_related_and_as_columns : Test(3) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Book->meta);

    my ($sql, @bind) = $mapper->to_sql(with => {name => 'description', columns => [{name => 'description', as => 'about'}]});

    is($sql,
        'SELECT `book`.`id`, `book`.`author_id`, `book`.`title`, `description`.`id`, `description`.`description` AS `about` FROM `book` LEFT JOIN `book_description` AS `description` ON `book`.`id` = `description`.`book_id`'
    );
    is_deeply([@bind], []);

    my $book = $mapper->from_row([1, 1, 'Good', 1, 'Good']);

    is($book->related('description')->get_column('about'), 'Good');
}

sub build_sql_with_related_and_where : Test(2) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Book->meta);

    my ($sql, @bind) =
      $mapper->to_sql(with => 'author', where => ['author.name' => 'vti']);

    is($sql,
        'SELECT `book`.`id`, `book`.`author_id`, `book`.`title`, `author`.`id`, `author`.`name` FROM `book` LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id` WHERE `author`.`name` = ?'
    );
    is_deeply([@bind], ['vti']);
}

sub map_with_deep_related_and_where : Test(3) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => BookDescription->meta);

    my ($sql, @bind) = $mapper->to_sql(
        with  => 'book.author',
        where => ['book.author.name' => 'vti']
    );

    is($sql,
        'SELECT `book_description`.`id`, `book_description`.`book_id`, `book_description`.`description`, `book`.`id`, `author`.`id`, `author`.`name` FROM `book_description` LEFT JOIN `book` AS `book` ON `book_description`.`book_id` = `book`.`id` LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id` WHERE `author`.`name` = ?'
    );
    is_deeply([@bind], ['vti']);

    my $book_description = $mapper->from_row([1, 1, 'Good', 1, 1, 'vti']);

    is( $book_description->related('book')->related('author')
          ->get_column('name'),
        'vti'
    );
}

sub map_with_multiple_deep_related : Test(4) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => BookDescription->meta);

    my ($sql, @bind) = $mapper->to_sql(with => ['book', 'book.author']);

    my $expected = 'SELECT
        `book_description`.`id`, `book_description`.`book_id`, `book_description`.`description`,
        `book`.`id`, `book`.`author_id`, `book`.`title`,
        `author`.`id`, `author`.`name`
        FROM `book_description`
        LEFT JOIN `book` AS `book` ON `book_description`.`book_id` = `book`.`id`
        LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id`';
    $expected =~ s/\s+/ /g;

    is($sql, $expected);
    is_deeply([@bind], []);

    my $book_description =
      $mapper->from_row([1, 1, 'Good', 1, 1, 'Story', 1, 'vti']);

    is($book_description->related('book')->get_column('title'), 'Story');
    is( $book_description->related('book')->related('author')
          ->get_column('name'),
        'vti'
    );
}

sub map_automatically_on_where : Test(4) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => BookDescription->meta);

    my ($sql, @bind) =
      $mapper->to_sql(where => ['book.author.name' => 'vti']);

    my $expected = 'SELECT
        `book_description`.`id`, `book_description`.`book_id`, `book_description`.`description`,
        `book`.`id`,
        `author`.`id`, `author`.`name`
        FROM `book_description`
        LEFT JOIN `book` AS `book` ON `book_description`.`book_id` = `book`.`id`
        LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id`
        WHERE `author`.`name` = ?';
    $expected =~ s/\s+/ /g;

    is($sql, $expected);
    is_deeply([@bind], ['vti']);

    my $book_description = $mapper->from_row([1, 1, 'Good', 1, 1, 'vti']);

    is($book_description->related('book')->get_column('id'), 1);
    is( $book_description->related('book')->related('author')
          ->get_column('name'),
        'vti'
    );
}

sub map_automatically_on_order_by : Test(4) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => BookDescription->meta);

    my ($sql, @bind) = $mapper->to_sql(order_by => 'book.author.name');

    my $expected = 'SELECT
       `book_description`.`id`, `book_description`.`book_id`, `book_description`.`description`,
       `book`.`id`,
       `author`.`id`, `author`.`name`
       FROM `book_description`
       LEFT JOIN `book` AS `book` ON `book_description`.`book_id` = `book`.`id`
       LEFT JOIN `author` AS `author` ON `book`.`author_id` = `author`.`id`
       ORDER BY `author`.`name`';
    $expected =~ s/\s+/ /g;

    is($sql, $expected);
    is_deeply([@bind], []);

    my $book_description = $mapper->from_row([1, 1, 'Good', 1, 1, 'vti']);

    is($book_description->related('book')->get_column('id'), 1);
    is( $book_description->related('book')->related('author')
          ->get_column('name'),
        'vti'
    );
}

sub build_object : Test(3) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Person->meta);

    my ($sql, @bind) = $mapper->to_sql(where => [a => 1]);

    my $person = $mapper->from_row([1, 'vti', 'slacker']);

    is($person->get_column('id'),         1);
    is($person->get_column('name'),       'vti');
    is($person->get_column('profession'), 'slacker');
}

sub build_object_with_related : Test(1) {
    my $self = shift;

    my $mapper = $self->_build_mapper(meta => Book->meta);

    my ($sql, @bind) = $mapper->to_sql(with => 'author');

    my $book = $mapper->from_row([1, 1, 'title', 1, 'vti']);

    is($book->related('author')->get_column('name'), 'vti');
}

sub _build_mapper {
    my $self = shift;

    return ObjectDB::Mapper->new(@_);
}

1;
