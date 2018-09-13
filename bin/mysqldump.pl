#!/usr/bin/env perl -s

use strict;
use warnings;
use autodie;
use feature qw/ say /;
use Cwd;

our ( $full, $verbose );

my $usage = <<"EOF";
No MySQL server running!  Try:

\$ mysql.server start
EOF

die $usage unless qx[pgrep mysql];
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
    my $file = qq[$cwd/mysqldump/employees-full.sql];
    my $cmd  = qq[mysqldump -uroot -pfoo employees > $file];
    say qq[\$ $cmd] if $verbose;
    system $cmd;
}
else {
    for my $table (@tables) {
        my $cmd =
qq[mysqldump -uroot -pfoo employees $table > $cwd/mysqldump/$table.sql];
        say qq[\$ $cmd] if $verbose;
        system $cmd;
    }
}

__END__

perl -E 'for my $table (qw<departments current_dept_emp dept_emp dept_emp_latest_date dept_manager employees salaries titles>) { my $cmd = qq[mysqldump -uroot -pfoo employees $table > $table-mysql-dump.sql]; system $cmd; }'

