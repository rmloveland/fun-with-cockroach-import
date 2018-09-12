all:

# Exporting from other DBs

mysqldump: import-clean
	perl bin/mysqldump.pl

pgdump: import-clean
	perl bin/pgdump.pl -verbose

pgdump-full: import-clean
	perl bin/pgdump.pl -full -verbose

pgcsv: import-clean
	perl bin/pgcsv.pl

# Importing into CockroachDB

import-csv: pgcsv crdb-database-exists
	perl bin/import-csv.pl -verbose

import-pgdump: pgdump
	perl bin/import-pgdump.pl -verbose

import-pgdump-full: pgdump-full
	perl bin/import-pgdump.pl -verbose -full

import-pgdump-full-by-parts: pgdump-full # FAILS - tables need to be in specific order
	perl bin/import-pgdump.pl -verbose -full -byparts

import-mysqldump: mysqldump
	perl bin/import-mysqldump.pl -verbose

# Setup/Teardown

crdb-database-exists:
	cockroach sql --insecure -e 'CREATE DATABASE IF NOT EXISTS employees'

import-clean:
	cockroach sql --insecure -e 'SELECT VERSION();' && \
	perl bin/drop-crdb-tables.pl -verbose

pgloader:
	pgloader mysql://root:foo@localhost/employees postgresql://localhost:5432/employees

# Data compression

tar-csv:
	tar -cv csv | gzip > employees-database-csv.tar.gz

tar-pgdump:
	tar -cv pg_dump | gzip > employees-database-pgdump.tar.gz

tar-mysqldump:
	tar -cv mysqldump | gzip > employees-database-mysqldump.tar.gz
