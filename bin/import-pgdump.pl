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

our ( $verbose, $full, $byparts );

die qq[No CockroachDB cluster running!\n] unless qx[pgrep cockroach];

my $db_config = { AutoCommit => 1, pg_errorlevel => $verbose ? 2 : 0 };

my $dbh = DBI->connect( "dbi:Pg:dbname=employees;host=localhost;port=26257",
    'root', '', $db_config );

my $cwd = cwd();

if ($full) {
    my $dir  = qq[$cwd/pg_dump/];
    my $file = qq[employees-full.sql];
    die qq[$0: cp2nodes failed!\n]
      unless cp2nodes( qq[$dir/$file], $verbose );
    if ($byparts) {
        my @tables =
          qw/ employees departments dept_manager dept_emp titles salaries /;
        for my $table (@tables) {
            my $stmt = qq[IMPORT TABLE $table FROM PGDUMP 'nodelocal:///$file'];
            say qq[> $stmt] if $verbose;
            my $sth = $dbh->prepare($stmt);
            $sth->execute();
        }
    }
    else {
        my $stmt = qq[IMPORT PGDUMP 'nodelocal:///$file';];
        say qq[> $stmt] if $verbose;
        my $sth = $dbh->prepare($stmt);
        $sth->execute();
    }
}
else {

    for my $table ( sort keys %tables ) {
        my $file   = qq[$cwd/pg_dump/$table.sql];
        my $schema = $tables{$table};
        die qq[$0: cp2nodes failed!\n]
          unless cp2nodes( $file, $verbose );
        my $stmt =
qq[IMPORT TABLE $table ( $schema ) PGDUMP DATA ('nodelocal:///$table.sql');];
        say qq[> $stmt] if $verbose;
        my $sth = $dbh->prepare($stmt);
        $sth->execute();
    }
}

$dbh->disconnect;

__END__

In order to avoid the error

  DBD::Pg::st execute failed: ERROR:  0A000: non-public schemas unsupported: employees

  you will need to provide your user ('rloveland' in this case) with the proper privileges on the employees schema

  perms start out looking like this

\c employees
You are now connected to database "employees" as user "rloveland".

employees=# \dn+ - to view permissions
                             List of schemas
   Name    |   Owner   |   Access privileges    |      Description       
-----------+-----------+------------------------+------------------------
 employees | rloveland |                        | 
 public    | rloveland | rloveland=UC/rloveland+| standard public schema
           |           | =UC/rloveland          | 
(2 rows)

employees=# DROP SCHEMA public;
DROP SCHEMA

employees=# ALTER SCHEMA employees RENAME TO public;
ALTER SCHEMA

employees=# \dn+
                      List of schemas
  Name  |   Owner   |   Access privileges    | Description 
--------+-----------+------------------------+-------------
 public | rloveland | rloveland=UC/rloveland+| 
        |           | =UC/rloveland          | 
(1 row)
