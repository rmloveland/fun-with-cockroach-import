#!/usr/bin/env perl

use strict;
use warnings;
use Cwd;
use DBI;

my $usage = <<"EOF";
No Postgres server running!  Try:

\$ postgres -D /usr/local/var/postgres/
EOF

die $usage unless qx[pgrep postgres];

my $dbh =
  DBI->connect( "dbi:Pg:dbname=employees", 'rloveland', '',
    { AutoCommit => 0 } );

my $cwd = cwd();

# The AutoCommit attribute should always be explicitly set

my @tables = qw/
  departments
  dept_emp
  dept_manager
  employees
  salaries
  titles
  /;

for my $table (@tables) {
    my $file = qq[$cwd/csv/$table.sql];
    my $stmt = qq[COPY $table to '$file' delimiters',';];
    $dbh->do($stmt);
}

$dbh->disconnect;
