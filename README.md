# Fun with Cockroach IMPORT

The data in this repo is from the [employees data set](https://github.com/datacharmer/test_db) that is also used in the [MySQL docs](https://dev.mysql.com/doc/employee/en/). The data set was imported into Postgres from MySQL using [pgloader](https://pgloader.io).

Tables:

+ departments
+ dept_emp
+ dept_manager
+ employees
+ salaries
+ titles

## Prerequistes

The various make targets assume you have the following:

1. A local MySQL server running with the `employees` data set
2. A local Postgres server running with the `employees` data set available in the public schema
3. A local (insecure) CockroachDB cluster running with an `employees` database ready to accept the data

Software:

+ perl
+ pgloader

Version info:

- postgres (PostgreSQL) 10.5
- /usr/local/bin/mysql  Ver 14.14 Distrib 5.7.22, for osx10.12 (x86_64) using  EditLine wrapper
- CockroachDB CCL v2.2.0-alpha.00000000-757-gb33c49ff73 (x86_64-apple-darwin16.7.0, built 2018/09/12 19:30:43, go1.10.3)  (built from master on Wednesday, September 12, 2018)

## Make targets

At a high level, each of the following make targets runs commands to:

1. Dump the previous DB into one or more files (except CSV, obv.)
2. Copy the dump file(s) to the local nodes' storage
3. Run the CockroachDB IMPORT statement(s)
4. ???
5. PROFIT!

### Postgres

#### Whole database at once

    $ make import-pgdump-full

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments CASCADE
    > DROP TABLE IF EXISTS dept_emp CASCADE
    > DROP TABLE IF EXISTS dept_manager CASCADE
    > DROP TABLE IF EXISTS employees CASCADE
    > DROP TABLE IF EXISTS salaries CASCADE
    > DROP TABLE IF EXISTS titles CASCADE

    $ pg_dump --no-privileges --disable-triggers employees > /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump/employees-full.sql
    $ perl -i.bak -lapE 's/gender [a-z]+.employees_gender/gender STRING/' /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump/employees-full.sql

    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node2/extern/

    > IMPORT PGDUMP 'nodelocal:///employees-full.sql';

#### One table at a time using `IMPORT TABLE foo ( $schema ) PGDUMP ...`

    $ make import-pgdump

will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments
    > DROP TABLE IF EXISTS dept_emp
    > DROP TABLE IF EXISTS dept_manager
    > DROP TABLE IF EXISTS employees
    > DROP TABLE IF EXISTS salaries
    > DROP TABLE IF EXISTS titles

    $ pg_dump --disable-triggers -t departments employees > /Users/rloveland/work/code/employees-db/pg_dump/departments.sql
    $ pg_dump --disable-triggers -t dept_emp employees > /Users/rloveland/work/code/employees-db/pg_dump/dept_emp.sql
    $ pg_dump --disable-triggers -t dept_manager employees > /Users/rloveland/work/code/employees-db/pg_dump/dept_manager.sql
    $ pg_dump --disable-triggers -t employees employees > /Users/rloveland/work/code/employees-db/pg_dump/employees.sql
    $ perl -i.bak -lapE 's/gender [a-z]+.employees_gender/gender STRING/' /Users/rloveland/work/code/employees-db/pg_dump/employees.sql
    $ pg_dump --disable-triggers -t salaries employees > /Users/rloveland/work/code/employees-db/pg_dump/salaries.sql
    $ pg_dump --disable-triggers -t titles employees > /Users/rloveland/work/code/employees-db/pg_dump/titles.sql

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/departments.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/departments.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/departments.sql /tmp/node2/extern/

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_emp.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_emp.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_emp.sql /tmp/node2/extern/

    > IMPORT TABLE dept_emp ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) PGDUMP DATA ('nodelocal:///dept_emp.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_manager.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_manager.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/dept_manager.sql /tmp/node2/extern/

    > IMPORT TABLE dept_manager ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) PGDUMP DATA ('nodelocal:///dept_manager.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/employees.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/employees.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/employees.sql /tmp/node2/extern/

    > IMPORT TABLE employees ( 
    emp_no INTEGER NOT NULL,
    birth_date DATE NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    gender STRING NOT NULL,
    hire_date DATE NOT NULL
     ) PGDUMP DATA ('nodelocal:///employees.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/salaries.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/salaries.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/salaries.sql /tmp/node2/extern/

    > IMPORT TABLE salaries ( 
    emp_no INTEGER NOT NULL,
    salary INTEGER NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) PGDUMP DATA ('nodelocal:///salaries.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/titles.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/titles.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/pg_dump/titles.sql /tmp/node2/extern/

    > IMPORT TABLE titles ( 
    emp_no INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE
     ) PGDUMP DATA ('nodelocal:///titles.sql');

#### One table at a time using `IMPORT TABLE foo FROM PGDUMP ...`

    $ make import-pgdump-full-by-parts

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments CASCADE
    > DROP TABLE IF EXISTS dept_emp CASCADE
    > DROP TABLE IF EXISTS dept_manager CASCADE
    > DROP TABLE IF EXISTS employees CASCADE
    > DROP TABLE IF EXISTS salaries CASCADE
    > DROP TABLE IF EXISTS titles CASCADE

    $ pg_dump --no-privileges --disable-triggers employees > /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump/employees-full.sql
    $ perl -i.bak -lapE 's/gender [a-z]+.employees_gender/gender STRING/' /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump/employees-full.sql

    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/pg_dump//employees-full.sql /tmp/node2/extern/

    > IMPORT TABLE employees FROM PGDUMP 'nodelocal:///employees-full.sql'
    > IMPORT TABLE departments FROM PGDUMP 'nodelocal:///employees-full.sql'

    > IMPORT TABLE dept_manager FROM PGDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (dept_manager) at bin/import-pgdump.pl line 37.

    > IMPORT TABLE dept_emp FROM PGDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (dept_emp) at bin/import-pgdump.pl line 37.

    > IMPORT TABLE titles FROM PGDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (titles) at bin/import-pgdump.pl line 37.

    > IMPORT TABLE salaries FROM PGDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (salaries) at bin/import-pgdump.pl line 37.

### MySQL

#### Whole database at once

    $ make import-mysqldump-full

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments CASCADE
    > DROP TABLE IF EXISTS dept_emp CASCADE
    > DROP TABLE IF EXISTS dept_manager CASCADE
    > DROP TABLE IF EXISTS employees CASCADE
    > DROP TABLE IF EXISTS salaries CASCADE
    > DROP TABLE IF EXISTS titles CASCADE

    $ mysqldump -uroot employees > /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump/employees-full.sql

    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node2/extern/

    > IMPORT MYSQLDUMP 'nodelocal:///employees-full.sql';

#### One table at a time using `IMPORT TABLE foo ( $schema ) MYSQLDUMP ...`

    $ make import-mysqldump

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments
    > DROP TABLE IF EXISTS dept_emp
    > DROP TABLE IF EXISTS dept_manager
    > DROP TABLE IF EXISTS employees
    > DROP TABLE IF EXISTS salaries
    > DROP TABLE IF EXISTS titles

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/departments.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/departments.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/departments.sql /tmp/node2/extern/

    > IMPORT TABLE departments ( 
    dept_no VARCHAR NOT NULL,
    dept_name VARCHAR NOT NULL
     ) MYSQLDUMP DATA ('nodelocal:///departments.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_emp.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_emp.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_emp.sql /tmp/node2/extern/

    > IMPORT TABLE dept_emp ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) MYSQLDUMP DATA ('nodelocal:///dept_emp.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_manager.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_manager.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/dept_manager.sql /tmp/node2/extern/

    > IMPORT TABLE dept_manager ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) MYSQLDUMP DATA ('nodelocal:///dept_manager.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/employees.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/employees.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/employees.sql /tmp/node2/extern/

    > IMPORT TABLE employees ( 
    emp_no INTEGER NOT NULL,
    birth_date DATE NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    gender STRING NOT NULL,
    hire_date DATE NOT NULL
     ) MYSQLDUMP DATA ('nodelocal:///employees.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/salaries.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/salaries.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/salaries.sql /tmp/node2/extern/

    > IMPORT TABLE salaries ( 
    emp_no INTEGER NOT NULL,
    salary INTEGER NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) MYSQLDUMP DATA ('nodelocal:///salaries.sql');

    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/titles.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/titles.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/mysqldump/titles.sql /tmp/node2/extern/

    > IMPORT TABLE titles ( 
    emp_no INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE
     ) MYSQLDUMP DATA ('nodelocal:///titles.sql');

#### One table at a time using `IMPORT TABLE foo FROM MYSQLDUMP ...`

    $ make import-mysqldump-full-by-parts

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments CASCADE
    > DROP TABLE IF EXISTS dept_emp CASCADE
    > DROP TABLE IF EXISTS dept_manager CASCADE
    > DROP TABLE IF EXISTS employees CASCADE
    > DROP TABLE IF EXISTS salaries CASCADE
    > DROP TABLE IF EXISTS titles CASCADE

    $ mysqldump -uroot -pfoo employees > /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump/employees-full.sql

    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/fun-with-cockroach-import/mysqldump//employees-full.sql /tmp/node2/extern/

    > IMPORT TABLE employees FROM MYSQLDUMP 'nodelocal:///employees-full.sql'
    > IMPORT TABLE departments FROM MYSQLDUMP 'nodelocal:///employees-full.sql'

    > IMPORT TABLE dept_manager FROM MYSQLDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (dept_manager) at bin/import-mysqldump.pl line 38.

    > IMPORT TABLE dept_emp FROM MYSQLDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (dept_emp) at bin/import-mysqldump.pl line 38.

    > IMPORT TABLE titles FROM MYSQLDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (titles) at bin/import-mysqldump.pl line 38.

    > IMPORT TABLE salaries FROM MYSQLDUMP 'nodelocal:///employees-full.sql'
    DBD::Pg::st execute failed: ERROR:  XX000: referenced table "employees" not found in tables being imported (salaries) at bin/import-mysqldump.pl line 38.

### CSV

    $ make import-csv

Which will result in roughly these commands (`>` runs in the DB, `$` runs in the shell):

    > DROP TABLE IF EXISTS departments
    > DROP TABLE IF EXISTS dept_emp
    > DROP TABLE IF EXISTS dept_manager
    > DROP TABLE IF EXISTS employees
    > DROP TABLE IF EXISTS salaries
    > DROP TABLE IF EXISTS titles

    $ cockroach sql --insecure -e 'CREATE DATABASE IF NOT EXISTS employees'
    CREATE DATABASE

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/departments.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/departments.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/departments.csv /tmp/node2/extern/

    > IMPORT TABLE departments ( 
    dept_no VARCHAR NOT NULL,
    dept_name VARCHAR NOT NULL
     ) CSV DATA ('nodelocal:///departments.csv');

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_emp.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_emp.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_emp.csv /tmp/node2/extern/

    > IMPORT TABLE dept_emp ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) CSV DATA ('nodelocal:///dept_emp.csv');

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_manager.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_manager.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/dept_manager.csv /tmp/node2/extern/

    > IMPORT TABLE dept_manager ( 
    emp_no INTEGER NOT NULL,
    dept_no VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) CSV DATA ('nodelocal:///dept_manager.csv');

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/employees.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/employees.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/employees.csv /tmp/node2/extern/

    > IMPORT TABLE employees ( 
    emp_no INTEGER NOT NULL,
    birth_date DATE NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    gender STRING NOT NULL,
    hire_date DATE NOT NULL
     ) CSV DATA ('nodelocal:///employees.csv');

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/salaries.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/salaries.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/salaries.csv /tmp/node2/extern/

    > IMPORT TABLE salaries ( 
    emp_no INTEGER NOT NULL,
    salary INTEGER NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL
     ) CSV DATA ('nodelocal:///salaries.csv');

    $ rsync -q /Users/rloveland/work/code/employees-db/csv/titles.csv /tmp/node0/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/titles.csv /tmp/node1/extern/
    $ rsync -q /Users/rloveland/work/code/employees-db/csv/titles.csv /tmp/node2/extern/

    > IMPORT TABLE titles ( 
    emp_no INTEGER NOT NULL,
    title VARCHAR NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE
     ) CSV DATA ('nodelocal:///titles.csv');
