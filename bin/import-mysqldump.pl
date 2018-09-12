#!/usr/bin/env perl -s

use strict;
use warnings;
use autodie;
use experimentals;
use Cwd;
use DBI;

push @INC, '.';
require './bin/cp2nodes.pl';
my %tables = do './bin/table-data.pl';

our ($verbose);

die qq[No CockroachDB cluster running!\n] unless qx[pgrep cockroach];

my $db_config = { AutoCommit => 1, pg_errorlevel => $verbose ? 2 : 0 };

my $dbh = DBI->connect( "dbi:Pg:dbname=employees;host=localhost;port=26257",
    'root', '', $db_config );

my $cwd = cwd();

for my $table ( sort keys %tables ) {
    my $file   = qq[$cwd/mysqldump/$table.sql];
    my $schema = $tables{$table};
    die qq[$0: cp2nodes failed!\n] unless cp2nodes( $file, $verbose );
    my $stmt =
qq[IMPORT TABLE $table ( $schema ) MYSQLDUMP DATA ('nodelocal:///$table.sql');];
    say qq[> $stmt] if $verbose;
    my $sth = $dbh->prepare($stmt);
    $sth->execute();
}

$dbh->disconnect;

__END__
