#!/usr/bin/env perl -s

use strict;
use warnings;
use autodie;
use experimentals;
use Cwd;
use DBI;

our ($verbose);

die qq[No CockroachDB cluster running!\n] unless qx[pgrep cockroach];

my $db_config = { AutoCommit => 1, pg_errorlevel => $verbose ? 2 : 0 };

my $dbh = DBI->connect( "dbi:Pg:dbname=employees;host=localhost;port=26257",
    'root', '', $db_config );

push @INC, '.';    # uggggg
my %tables = do './bin/table-data.pl';

for my $table ( sort keys %tables ) {
    my $stmt = qq[DROP TABLE IF EXISTS $table CASCADE];
    say qq[> $stmt] if $verbose;
    my $sth = $dbh->prepare($stmt);
    $sth->execute();
}
