#!/usr/bin/env perl

use strict;
use warnings;
use Cwd;

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

for my $table (@tables) {
    my $cmd =
      qq[mysqldump -uroot -pfoo employees $table > $cwd/mysqldump/$table.sql];
    system $cmd;
}

__END__

perl -E 'for my $table (qw<departments current_dept_emp dept_emp dept_emp_latest_date dept_manager employees salaries titles>) { my $cmd = qq[mysqldump -uroot -pfoo employees $table > $table-mysql-dump.sql]; system $cmd; }'

