package TestDBH;

use strict;
use warnings;

use DBI;

our $DBH;

sub dbh {
    my $class = shift;

    return $DBH if $DBH;

    my $dbh = DBI->connect('dbi:SQLite::memory:', '', '', {RaiseError => 1});
    die $DBI::errorstr unless $dbh;

    $dbh->do("PRAGMA default_synchronous = OFF");
    $dbh->do("PRAGMA temp_store = MEMORY");

    $DBH = $dbh;
    return $dbh;
}

1;
