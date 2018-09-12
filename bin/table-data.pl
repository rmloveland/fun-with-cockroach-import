my %tables = (
    'departments' => qq[
dept_no VARCHAR NOT NULL,
dept_name VARCHAR NOT NULL
],
    dept_emp => qq[
emp_no INTEGER NOT NULL,
dept_no VARCHAR NOT NULL,
from_date DATE NOT NULL,
to_date DATE NOT NULL
],
    dept_manager => qq[
emp_no INTEGER NOT NULL,
dept_no VARCHAR NOT NULL,
from_date DATE NOT NULL,
to_date DATE NOT NULL
],
    'employees' => qq[
emp_no INTEGER NOT NULL,
birth_date DATE NOT NULL,
first_name STRING NOT NULL,
last_name STRING NOT NULL,
gender STRING NOT NULL,
hire_date DATE NOT NULL
],
    salaries => qq[
emp_no INTEGER NOT NULL,
salary INTEGER NOT NULL,
from_date DATE NOT NULL,
to_date DATE NOT NULL
],
    titles => qq[
emp_no INTEGER NOT NULL,
title VARCHAR NOT NULL,
from_date DATE NOT NULL,
to_date DATE
],
);
