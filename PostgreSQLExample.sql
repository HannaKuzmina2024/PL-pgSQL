DROP TABLE IF EXISTS CAREER CASCADE;
DROP TABLE IF EXISTS SALARY CASCADE;
DROP TABLE IF EXISTS EMP CASCADE;
DROP TABLE IF EXISTS DEPT CASCADE;
DROP TABLE IF EXISTS JOB CASCADE;
DROP EXTENSION IF EXISTS hstore;
DROP TYPE IF EXISTS job_category;
DROP MATERIALIZED VIEW IF EXISTS mv_emp_details;

-- TABLE emp
CREATE TABLE emp (
    empno INTEGER PRIMARY KEY,
    empname CHARACTER VARYING NOT NULL,
    birthdate DATE,
    phone CHARACTER VARYING,
	manager_id INTEGER REFERENCES emp(empno),
	extra_info JSONB,
	skills TEXT[]  
);

ALTER TABLE emp
ADD CONSTRAINT birthdate_check 
CHECK (birthdate >= CURRENT_DATE - INTERVAL '90 years' 
        AND birthdate <= CURRENT_DATE - INTERVAL '18 years');

CREATE INDEX idx_empname ON emp(empname);

CREATE OR REPLACE FUNCTION format_empname()
RETURNS TRIGGER AS $$
BEGIN
    NEW.empname := INITCAP(NEW.empname);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER empname_format_trigger
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
EXECUTE FUNCTION format_empname();

INSERT INTO emp (empno, empname, birthdate, phone, manager_id, extra_info, skills)
VALUES
    (7790, 'JOHN KLINTON', '1980-07-09', '49-1522-427632', NULL,
     '{"linkedin": "https://linkedin.com/in/johnklinton", "hobbies": ["golf", "photography"]}', 
     ARRAY['Leadership', 'Strategy']),
     
    (7499, 'ALLEN', '1961-02-20', '49.1522 487854', 7790,
     '{"certifications": ["CFA", "CPA"]}', 
     ARRAY['Finance', 'Excel']),
     
    (7521, 'WARD', '1958-02-22', '49 1522 727672', 7790,
     '{"hobbies": ["fishing"]}', 
     ARRAY['Sales', 'Communication']),
     
    (7566, 'JONES', '1973-04-02', '49 1522 227 532', 7790,
     '{"languages": ["English", "Spanish"]}', 
     ARRAY['Project Management']),
     
    (7789, 'ALEX BOUSH', '1982-09-21', '49-1522 385631', 7790,
     '{"linkedin": "https://linkedin.com/in/alexboush"}', 
     ARRAY['Logistics']),
     
    (7369, 'SMITH', '1948-12-17', '49 1522 127631', 7789,
     '{"hobbies": ["chess", "gardening"]}', 
     ARRAY['Clerical', 'Typing']),
     
    (7654, 'JOHN MARTIN', '1945-09-28', '49-1522.527133', 7789,
     '{"hobbies": ["woodworking"]}', 
     ARRAY['Driving']),
     
    (7698, 'RICHARD MARTIN', '1981-05-01', '49.1522 327132', 7789,
     '{"certifications": ["Negotiation"]}', 
     ARRAY['Sales']),
     
    (7782, 'CLARK', NULL, '49-1522-152222', 7499,
     '{"notes": "Unknown birthdate"}', 
     ARRAY['Admin']),
     
    (7788, 'SCOTT', '1987-08-13', '49.1522.442632', 7499,
     '{"github": "https://github.com/scottdev"}', 
     ARRAY['Java', 'Python', 'PostgreSQL']);

-- Select kinds of stored info for each employee 
SELECT empname, jsonb_object_keys(extra_info) AS key
FROM emp;
-- Select employees who have a LinkedIn profile
SELECT empname, extra_info->>'linkedin' AS linkedin
FROM emp
WHERE extra_info ? 'linkedin';
-- List each skill on its own row
SELECT empname, unnest(skills) AS skill
FROM emp;

-- Enable hstore extension
CREATE EXTENSION IF NOT EXISTS hstore;

-- TABLE dept 
CREATE TABLE dept (
    deptno SERIAL PRIMARY KEY,
    deptname CHARACTER VARYING NOT NULL,
    deptaddr CHARACTER VARYING,
	dept_meta HSTORE
);

INSERT INTO DEPT (DEPTNAME, DEPTADDR, DEPT_META)
VALUES
    ('ACCOUNTING', 'NEW YORK', 'hybrid => yes, budget_unit => 10000'),
    ('RESEARCH', 'DALLAS', 'hybrid => no, budget_unit => 30000'),
    ('SALES', 'CHICAGO', 'hybrid => yes, budget_unit => 30000'),
    ('OPERATIONS', 'BOSTON', 'hybrid => no, budget_unit => 10000');

-- TABLE job
CREATE TYPE job_category AS ENUM ('technical', 'administrative', 'managerial', 'support');

CREATE TABLE job (
    jobno INTEGER PRIMARY KEY,
    jobname CHARACTER VARYING NOT NULL,
    minsalary INTEGER CHECK (MINSALARY > 0),
	category job_category
);

INSERT INTO job (jobno, jobname, minsalary, category)
VALUES
    (1000, 'Manager', 2500, 'managerial'),
    (1001, 'Financial director', 5000, 'managerial'),
    (1002, 'Executive director', 5000, 'managerial'),
    (1003, 'Salesman', 1500, 'technical'),
    (1004, 'Clerk', 1000, 'support'),
    (1005, 'DRIVER', 1000, 'support'),
    (1006, 'PRESIDENT', 10000, 'managerial');

-- TABLE career
CREATE TABLE career (
    jobno INTEGER REFERENCES job(jobno) NOT NULL,
    empno INTEGER REFERENCES emp(empno) NOT NULL,
    deptno INTEGER REFERENCES dept(deptno),
    startdate DATE NOT NULL,
    enddate DATE
);

ALTER TABLE career
ADD CONSTRAINT startdate_enddate_check
CHECK (startdate >= '2000-01-01'::DATE AND startdate < enddate);

INSERT INTO career 
VALUES
    (1004, 7698, 1, '2000-05-21', '2000-12-01'),
    (1003, 7698, 1, '2010-06-01', NULL),
    (1003, 7369, 2, '2005-05-21', NULL),
    (1001, 7499, 3, '2003-01-02', '2005-12-31'),
    (1004, 7654, 2, '2000-07-21', '2004-06-01'),
    (1002, 7499, 3, '2006-06-01', '2008-10-25'),
    (1001, 7499, NULL, '2006-10-12', NULL),
    (1004, 7369, 3, '2000-07-01', NULL),
    (1001, 7499, 1, '2008-01-01', NULL),
    (1005, 7789, 4, '2001-01-01', NULL),
    (1006, 7790, 4, '2001-10-01', NULL);

-- TABLE salary
CREATE TABLE salary (
    empno INTEGER REFERENCES emp(empno),
    sl_month INTEGER CHECK (sl_month  > 0 AND sl_month  < 13),
    sl_year INTEGER CHECK (sl_year >= 2000 AND sl_year < EXTRACT(YEAR FROM CURRENT_DATE)),
    salvalue INTEGER
);

INSERT INTO salary VALUES
    (7369, 5, 2020, 2580),
    (7369, 6, 2020, 2650),
    (7369, 7, 2020, 2510),
    (7369, 8, 2020, 2495),
    (7369, 9, 2020, 1750),
    (7369, 10, 2020, 3540),
    (7369, 11, 2020, 2580),
    (7369, 12, 2020, 2050),
    (7789, 1, 2021, 1850),
    (7789, 2, 2021, 1900),
    (7789, 3, 2021, 1950),
    (7789, 4, 2021, 1950),
    (7790, 5, 2021, 1000),
    (7790, 6, 2021, 1050),
    (7790, 7, 2021, 1000),
    (7499, 8, 2021, 8050),
    (7499, 9, 2021, 8050),
    (7499, 10, 2021, 8150),
    (7369, 1, 2021, 3000),
    (7369, 2, 2021, 3000),
    (7369, 3, 2021, 3000),
    (7369, 4, 2021, 3000),
    (7369, 5, 2021, 3000),
    (7499, 1, 2022, 3200),
    (7499, 2, 2022, 3200),
    (7499, 3, 2022, 3200),
    (7499, 4, 2022, 3200),
    (7499, 5, 2022, 3200),
    (7499, 1, 2023, 5500),
    (7499, 2, 2023, 5500),
    (7499, 3, 2023, 5500),
    (7499, 4, 2023, 5500),
    (7369, 1, 2023, 3100),
    (7369, 2, 2023, 3100),
    (7369, 3, 2023, 3100);	

-- Function check_salary_min_threshold is created for a trigger trg_check_salary_threshold
/*It operates when data in the SALARY table is updated. 
If the SALVALUE field is updated, then when a new salary is assigned that is less than the official salary (JOB table, MINSALARY field), 
the change is not made and the old value is saved; 
if the new salary value is greater than the official salary, then the change is made.
*/
CREATE OR REPLACE FUNCTION check_salary_min_threshold()
RETURNS TRIGGER AS $$
DECLARE
    current_jobno INTEGER;
    official_minsalary INTEGER;
BEGIN
    -- Get current job number from CAREER table (active job has ENDDATE IS NULL)
    SELECT JOBNO INTO current_jobno
    FROM CAREER
    WHERE EMPNO = NEW.EMPNO AND ENDDATE IS NULL
    LIMIT 1;

    IF current_jobno IS NULL THEN
        RAISE EXCEPTION 'No active job found for employee %', NEW.EMPNO;
    END IF;

    -- Get official minimum salary for the job
    SELECT MINSALARY INTO official_minsalary
    FROM JOB
    WHERE JOBNO = current_jobno;

    -- Check if new salary is below the official threshold
    IF NEW.SALVALUE < official_minsalary THEN
        RAISE NOTICE 'New salary % is below minimum salary % for job % - change rejected.',
            NEW.SALVALUE, official_minsalary, current_jobno;
        RETURN OLD;  -- Reject change, keep old value
    END IF;

    RETURN NEW;  -- Accept the change
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_salary_threshold
BEFORE UPDATE OF SALVALUE ON SALARY
FOR EACH ROW
EXECUTE FUNCTION check_salary_min_threshold();

--UPDATE will be rejected: minsalary of employee 7369 is 1500.
UPDATE SALARY SET SALVALUE = 400 WHERE EMPNO = 7369 AND SL_YEAR = 2023 AND SL_MONTH = 1;
--UPDATE will be accepted
UPDATE SALARY SET SALVALUE = 2000 WHERE EMPNO = 7369 AND SL_YEAR = 2023 AND SL_MONTH = 1;

--Materialized view MY_EMP_DETAILS
CREATE MATERIALIZED VIEW mv_emp_details AS 
SELECT 
    e.EMPNO, 
    e.EMPNAME, 
    e.BIRTHDATE, 
    mgr.EMPNAME AS MANAGER_NAME,
	e.phone, 
    d.DEPTNAME, 
    d.DEPTADDR, 
    j.JOBNAME, 
    j.MINSALARY, 
    s.SL_MONTH, 
    s.SL_YEAR, 
    s.SALVALUE, 
    c.STARTDATE, 
    c.ENDDATE
FROM 
    EMP e
LEFT JOIN 
    EMP mgr ON e.MANAGER_ID = mgr.EMPNO
JOIN 
    CAREER c ON e.EMPNO = c.EMPNO
JOIN 
    DEPT d ON c.DEPTNO = d.DEPTNO
JOIN 
    JOB j ON c.JOBNO = j.JOBNO
JOIN 
    SALARY s ON e.EMPNO = s.EMPNO;

-- Update rows in the emp table according to the correct format [0-9]{2}[ ][0-9]{4}[ ][0-9]{6}
CREATE OR REPLACE PROCEDURE update_emp_phone()
LANGUAGE plpgsql
AS $$
BEGIN
    
    UPDATE emp 
    SET phone = REGEXP_REPLACE(phone, '([0-9]{2})[-. ]([0-9]{4})[-. ]([0-9]{6})', '\1 \2 \3')
    WHERE NOT REGEXP_LIKE(phone, '[0-9]{2}[ ][0-9]{4}[ ][0-9]{6}');
    
    RAISE NOTICE 'The phone column has been updated for rows that do not match the format.';
END;
$$;

CALL update_emp_phone();	

REFRESH MATERIALIZED VIEW mv_emp_details;

select * from mv_emp_details;

-- Function CALCULATE_SALARY_TAX calculates the total tax for a specific employee, using the following logic:
/*
- the tax is equal to 9% of the salary accrued in the month, 
  if the total salary from the beginning of the year to the end of the month in question does not exceed 20,000;
- the tax is equal to 12% of the salary accrued in the month,
  if the total salary from the beginning of the year to the end of the month in question is more than 20,000, but does not exceed 30,000;
- the tax is equal to 15% of the salary accrued in the month,
  if the total salary from the beginning of the year to the end of the month in question is more than 30,000.
 */
CREATE OR REPLACE FUNCTION calculate_salary_tax(
    empno_input INTEGER,
    threshold_1 NUMERIC DEFAULT 20000,
    threshold_2 NUMERIC DEFAULT 30000
)

RETURNS NUMERIC AS $$
DECLARE
    tax_total NUMERIC := 0;
    running_total NUMERIC := 0;
    salary_row RECORD;
    tax_rate NUMERIC;
BEGIN
    FOR salary_row IN
        SELECT SL_YEAR, SL_MONTH, SALVALUE
        FROM SALARY
        WHERE EMPNO = empno_input
        ORDER BY SL_YEAR, SL_MONTH
    LOOP
        running_total := running_total + salary_row.SALVALUE;

        IF running_total <= threshold_1 THEN
            tax_rate := 0.09;
        ELSIF running_total <= threshold_2 THEN
            tax_rate := 0.12;
        ELSE
            tax_rate := 0.15;
        END IF;

        tax_total := tax_total + (salary_row.SALVALUE * tax_rate);
    END LOOP;

    RETURN ROUND(tax_total, 2);
END;
$$ LANGUAGE plpgsql;

-- Calculate total tax for employee 7369 using default thresholds
SELECT calculate_salary_tax(7369);

-- Calculate custom thresholds
SELECT calculate_salary_tax(7369, 25000, 40000);

-- Select calculates the running total of the salary for each employee across months in a given year
SELECT 
    EMPNO, 
    EMPNAME, 
    MANAGER_NAME,
    DEPTNAME,  
    JOBNAME, 
    MINSALARY, 
    SL_MONTH, 
    SL_YEAR, 
    SALVALUE, 
    SUM(SALVALUE) OVER (PARTITION BY (EMPNO, SL_YEAR) ORDER BY SL_YEAR, SL_MONTH ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_salary
FROM 
    mv_emp_details
ORDER BY 
    EMPNO, SL_YEAR, SL_MONTH;
	
