SELECT
    *
FROM
    non_functional_locations;

SELECT
    *
FROM
    departments;

SELECT
    *
FROM
    jobs;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    job_history;

SELECT
    *
FROM
    regions;

SELECT
    *
FROM
    countries;

SELECT
    *
FROM
    locations;

--VIEW don't take storage it is useful to display data which are not sensitive
CREATE OR REPLACE VIEW emp_view AS
    SELECT
        employee_id,
        first_name,
        last_name,
        hire_date,
        job_id,
        commission_pct,
        manager_id,
        department_id
    FROM
        employees;

SELECT
    *
FROM
    emp_view;

--country wise number of records and state 

SELECT
    country_id,
    COUNT(*),
    COUNT(state_province)
FROM
    locations
GROUP BY
    country_id
ORDER BY
    country_id;



--Find department wise number of managers and numbers of records


SELECT
    d.department_name,
    COUNT(*),
    COUNT(e.manager_id)
FROM
         employees e
    JOIN departments d ON e.department_id = d.department_id
GROUP BY
    d.department_name;

-- COUNT(*) take NULL values whereas COUNT(NAME_COLUMN) doesn't take NULL value

--Categorize employee base on hire date

1. before 1990
2. between 1990 to 1995
3. between 1995 to 2000
4. after 90s
;
SELECT
    first_name || ' '
                  || last_name,
    hire_date,
    CASE
        WHEN hire_date < TO_DATE('01/01/1990', 'dd/MM/yyyy')  THEN
            'BEFORE 1990'
        WHEN hire_date >= TO_DATE('01/01/1990', 'dd/MM/yyyy')
             AND hire_date < TO_DATE('01/01/1995', 'dd/MM/yyyy') THEN
            'BETWEEN 1990 TO 1995'
        WHEN hire_date >= TO_DATE('01/01/1995', 'dd/MM/yyyy')
             AND hire_date < TO_DATE('01/01/2000', 'dd/MM/yyyy') THEN
            'BETWEEN 1995 TO 2000'
        WHEN hire_date >= TO_DATE('01/01/2000', 'dd/MM/yyyy') THEN
            'AFTER 90s'
        ELSE
            'NOT CATEGORIZED'
    END hire_category
FROM
    employees
ORDER BY
    hire_date;


--Find all the employee where salary is more than the average salary of all employee

SELECT
    e.employee_id,
    salary,
    avg_salary
FROM
    employees e,
    (
        SELECT
            AVG(salary) avg_salary
        FROM
            employees
    )         avg_sal
WHERE
    e.salary > avg_sal.avg_salary;

WITH avg_sal AS (
    SELECT
        AVG(salary) avg_salary
    FROM
        employees
)
SELECT
    e.employee_id,
    salary,
    avg_salary
FROM
    employees e,
    avg_sal
WHERE
    e.salary > avg_sal.avg_salary;

--Fin all the departments where the total salary of all employee in that department is more than the average of total salary of all employee in the database.
CREATE OR REPLACE VIEW department_level_details AS
    WITH dep_wise_sal AS (
        SELECT
            department_id,
            SUM(salary) total_sal_dept_wise
        FROM
            employees
        GROUP BY
            department_id
    ), avg_sal AS (
        SELECT
            AVG(salary) avg_sal
        FROM
            employees
    )
    SELECT
        *
    FROM
        dep_wise_sal,
        avg_sal
    WHERE
        dep_wise_sal.total_sal_dept_wise > avg_sal.avg_sal;


/******************************** 7 . Show department level details using aggregate function and inline view *****************/

CREATE OR REPLACE VIEW department_level_details_1 AS
    WITH dept_sal_det AS (
        SELECT
            department_id,
            MAX(salary) AS max_salary,
            MIN(salary) AS min_salary,
            round(AVG(salary),
                  2)    AS avg_salary,
            SUM(salary) AS sum_salary,
            COUNT(*)    AS number_of_emp
        FROM
            employees
        GROUP BY
            department_id
    ), emp_resignation_det AS (
        SELECT
            department_id,
            COUNT(*) AS number_of_emp_resigned
        FROM
            job_history
        GROUP BY
            department_id
    )
    SELECT
        departments.department_id,
        departments.department_name,
        employees.first_name
        || ' '
           || employees.last_name AS manager_name,
        locations.city,
        max_salary,
        min_salary,
        avg_salary,
        sum_salary,
        number_of_emp,
        number_of_emp_resigned
    FROM
             departments left
        JOIN employees ON departments.manager_id = employees.employee_id
        LEFT JOIN locations ON departments.location_id = locations.location_id
        LEFT JOIN dept_sal_det ON departments.department_id = dept_sal_det.department_id
        LEFT JOIN emp_resignation_det ON departments.department_id = emp_resignation_det.department_id
    ORDER BY
        departments.department_id;

SELECT
    *
FROM
    department_level_details_1;


--Fetch employee record with third MAX salary without Analytical function


/*ROWNUM is a "Pseudocolumn" that assigns a number to each row returned by a query indicating the 
order in which Oracle selects the row from a table. 
*/
WITH THIRD_MAX_SALARY AS (
SELECT MAX(SALARY) AS THIRD_MAX_SAL
FROM EMPLOYEES
WHERE SALARY NOT IN
  (SELECT T.*
  FROM
    ( SELECT SALARY FROM EMPLOYEES GROUP BY SALARY ORDER BY SALARY DESC
    ) T
  WHERE ROWNUM < 5
  ))
SELECT * 
FROM EMPLOYEES JOIN THIRD_MAX_SALARY
ON EMPLOYEES.SALARY = THIRD_MAX_SALARY.THIRD_MAX_SAL;

--Find Duplicate Location ID alorng with details
WITH ALL_LOCATIONS AS (
SELECT LOCATION_ID, POSTAL_CODE, CITY, COUNTRY_ID FROM LOCATIONS
UNION
SELECT LOCATIONS_ID, CAST(POSTAL_CODE AS VARCHAR(12)), CITY, COUNTRY_ID FROM NON_FUNCTIONAL_LOCATIONS
), 
DUPLICATE_LOCATION_ID AS (
SELECT LOCATION_ID, COUNT(*) AS DUPLICATE_COUNT FROM ALL_LOCATIONS 
GROUP BY LOCATION_ID
HAVING COUNT(*) > 1
)
SELECT ALL_LOCATIONS.LOCATION_ID, POSTAL_CODE, CITY, COUNTRY_ID
FROM ALL_LOCATIONS JOIN DUPLICATE_LOCATION_ID
ON ALL_LOCATIONS.LOCATION_ID = DUPLICATE_LOCATION_ID.LOCATION_ID;

SELECT LOCATION_ID, POSTAL_CODE, CITY, COUNTRY_ID FROM LOCATIONS
UNION
SELECT LOCATIONS_ID,
    CAST(POSTAL_CODE AS VARCHAR(12 BYTE)),
    CITY,
    COUNTRY_ID
FROM NON_FUNCTIONAL_LOCATIONS;

--Select unique city along with location details

WITH ALL


