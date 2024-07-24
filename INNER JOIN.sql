CREATE TABLE employees (
 employee_id INTEGER PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 manager_id INTEGER,
 FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE salaries (
 employee_id INTEGER PRIMARY KEY,
 salary INTEGER NOT NULL,
 FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO employees (employee_id, name, manager_id) VALUES
(1, 'Alice', NULL),
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'Dave', 2),
(5, 'Eve', 2);

INSERT INTO salaries (employee_id, salary) VALUES
(1, 100000),
(2, 80000),
(3, 120000),
(4, 70000),
(5, 90000);

SELECT * 
FROM employees
;
SELECT * 
FROM salaries
;

-- Getting Manager Salaries 
SELECT employee_id AS manager_id, salary
FROM salaries
WHERE employee_id IN (
SELECT table1.manager_id
FROM employees AS table1
JOIN salaries AS table2
	ON table1.employee_id=table2.employee_id
)
;

-- Getting Employee Salaries 
SELECT employee_id, salary
FROM salaries
WHERE employee_id IN (
SELECT distinct table1.employee_id
FROM employees AS table1
JOIN salaries AS table2
	ON table1.manager_id=table2.employee_id
)
;

-- Checking employees with higher salaries than their manager
WITH Combined_Tables AS(
SELECT table1.employee_id, table1.name, table1.manager_id, table2.salary
FROM employees AS table1
JOIN salaries AS table2
	ON table1.employee_id=table2.employee_id
)
SELECT employees.*
FROM Combined_Tables AS employees
JOIN Combined_Tables AS managers
-- Join where employees manager ID = managers employee ID
ON employees.manager_id = managers.employee_id
WHERE employees.salary > managers.salary 
;

