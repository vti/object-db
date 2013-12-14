package TestEnv;

use strict;
use warnings;

use TestDBH;

my %TABLES = (
    'person' => <<'',
    CREATE TABLE `person` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `name` varchar(40),
     `profession` varchar(40)
    );

    'author' => <<'',
    CREATE TABLE `author` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `name` varchar(40)
    );

    'book' => <<'',
    CREATE TABLE `book` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `author_id` INTEGER NOT NULL DEFAULT 0,
     `title` varchar(40)
    );

    'book_description' => <<'',
    CREATE TABLE `book_description` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `book_id` INTEGER NOT NULL DEFAULT 0,
     `description` varchar(40)
    );

    'tag' => <<'',
    CREATE TABLE `tag` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `name` varchar(40)
    );

    'book_tag_map' => <<'',
    CREATE TABLE `book_tag_map` (
     `book_id` INTEGER,
     `tag_id` INTEGER,
     PRIMARY KEY(`book_id`, `tag_id`)
    );

);

sub prepare_table {
    my $class = shift;
    my ($table) = @_;

    my $dbh = TestDBH->dbh;

    $dbh->do("DROP TABLE IF EXISTS " . $dbh->quote_identifier($table));

    die "Unknown table '$table'" unless exists $TABLES{$table};

    my $sql = $TABLES{$table};

    my $driver = $dbh->{Driver}->{Name};

    if ($driver =~ /mysql/i) {
        $sql =~ s{AUTOINCREMENT}{AUTO_INCREMENT}g;
    } elsif ($driver =~ /Pg/i) {
        $sql =~ s{`}{"}g;
        $sql =~ s{"id" INTEGER PRIMARY KEY AUTOINCREMENT}{"id" SERIAL PRIMARY KEY}g;
    }

    $dbh->do($sql);
}

1;
