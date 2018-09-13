#!/usr/bin/env perl -s

use strict;
use warnings;
use autodie;
use feature qw/ say /;
use Cwd;

our ( $verbose, $full );

my $usage = <<"EOF";
No Postgres server running!  Try:

\$ postgres -D /usr/local/var/postgres/
EOF

die $usage unless qx[pgrep postgres];

my $cwd = cwd();

my @tables = qw/
  departments
  dept_emp
  dept_manager
  employees
  salaries
  titles
  /;

if ($full) {
    my $file = qq[$cwd/pg_dump/employees-full.sql];
    my $cmd  = qq[pg_dump --no-privileges --disable-triggers employees > $file];
    say qq[\$ $cmd] if $verbose;
    system $cmd;

    my $cmd2 =
qq[perl -i.bak -lapE 's/gender [a-z]+\.employees_gender/gender STRING/' $file];
    say qq[\$ $cmd2] if $verbose;
    system $cmd2;

    # infile
    system qq[mv $file $file.bak];
    die qq[$0: $?\n] if $?;
    open my $in, '<', "$file.bak";

    # outfile
    open my $out, '>', $file;
    do {
        my $open = 0;

        while (<$in>) {
            next if /ALTER TYPE/;

            # next if /GRANT ALL ON SCHEMA/;
            # next if /ALTER DEFAULT PRIVILEGES/;
            if (/CREATE TYPE/) {
                $open = 1;
                next;
            }
            elsif ( $open && /\);/ ) {
                $open = 0;
                next;
            }
            elsif ($open) {
                next;
            }
            else {
                print $out $_;
            }
        }
      }
}
else {
    for my $table (@tables) {
        my $file = qq[$cwd/pg_dump/$table.sql];

        my $cmd = qq[pg_dump --disable-triggers -t $table employees > $file];

        say qq[\$ $cmd] if $verbose;
        system $cmd;

        # One-off rewrite of a type that is not supported by CockroachDB into
        # something it does support.
        if ( $table eq 'employees' ) {
            my $cmd =
qq[perl -i.bak -lapE 's/gender [a-z]+\.employees_gender/gender STRING/' $file];
            say qq[\$ $cmd] if $verbose;
            system $cmd;
        }
    }
}
