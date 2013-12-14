package TestDBH;

use strict;
use warnings;

use DBI;

our $DBH;

sub dbh {
    my $class = shift;

    return $DBH if $DBH;

    my @dsn;
    if (my $dsn = $ENV{TEST_OBJECTDB_DBH}) {
        @dsn = split /,/, $dsn;
    }
    else {
        push @dsn, 'dbi:SQLite::memory:', '', '';
    }

    my $dbh = DBI->connect(@dsn, {RaiseError => 1});
    die $DBI::errorstr unless $dbh;

    if (!$ENV{TEST_OBJECTDB_DBH}) {
        $dbh->do("PRAGMA default_synchronous = OFF");
        $dbh->do("PRAGMA temp_store = MEMORY");
    }

    $DBH = $dbh;
    return $dbh;
}

1;
