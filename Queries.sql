-- ==========================================
-- SQL Assignment
-- Name: Akash Rathor
-- ==========================================

-- ==========================================
-- 1. Create Employee Table
-- ==========================================

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    city VARCHAR(50),
    dept_id INT,
    state VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active'
);

-- ==========================================
-- 3. Create Department Table
-- ==========================================

CREATE TABLE Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL,
    dept_head VARCHAR(100),
    employee_count INT,
    budget DECIMAL(12,2),
    location VARCHAR(50),
    contact_email VARCHAR(100),
    established_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

-- ==========================================
-- 4. Insert Sample Data in Department Table
-- ==========================================

INSERT INTO Department
(dept_name, dept_head, employee_count, budget, location, contact_email, established_date, status)
VALUES
('IT', 'Rahul Sharma', 50, 5000000, 'Delhi', 'it@company.com', '2018-01-15', 'Active'),
('HR', 'Priya Verma', 15, 1500000, 'Mumbai', 'hr@company.com', '2018-03-20', 'Active'),
('Finance', 'Amit Patel', 20, 3000000, 'Ahmedabad', 'finance@company.com', '2017-07-10', 'Active');

-- ==========================================
-- 5. Assign Department IDs
-- ==========================================

UPDATE Employee SET dept_id = 1 WHERE department = 'IT';
UPDATE Employee SET dept_id = 2 WHERE department = 'HR';
UPDATE Employee SET dept_id = 3 WHERE department = 'Finance';

-- ==========================================
-- 7. Top 5 Highest Salary Employees
-- ==========================================

SELECT *
FROM Employee
ORDER BY salary DESC
LIMIT 5;

-- ==========================================
-- 8. Department Wise Employee Count
-- ==========================================

SELECT department,
       COUNT(*) AS employee_count
FROM Employee
GROUP BY department;

-- ==========================================
-- 9. Second Highest Salary
-- ==========================================

SELECT MAX(salary) AS second_highest_salary
FROM Employee
WHERE salary <
(
    SELECT MAX(salary)
    FROM Employee
);

-- ==========================================
-- 10. Employees Whose Salary is Greater Than
-- Department Average Salary
-- ==========================================

SELECT *
FROM Employee e
WHERE salary >
(
    SELECT AVG(salary)
    FROM Employee
    WHERE department = e.department
);

-- ==========================================
-- 11. INNER JOIN
-- ==========================================

SELECT e.emp_id,
       e.first_name,
       e.salary,
       d.dept_name
FROM Employee e
INNER JOIN Department d
ON e.dept_id = d.dept_id;

-- ==========================================
-- 12. LEFT JOIN
-- ==========================================

SELECT e.emp_id,
       e.first_name,
       d.dept_name
FROM Employee e
LEFT JOIN Department d
ON e.dept_id = d.dept_id;

-- ==========================================
-- 13. GROUP BY with HAVING
-- Departments Having More Than 2 Employees
-- ==========================================

SELECT dept_id,
       COUNT(*) AS total_employees
FROM Employee
GROUP BY dept_id
HAVING COUNT(*) > 2;

-- ==========================================
-- 14. Employees Hired in Last 6 Months
-- ==========================================

SELECT *
FROM Employee
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- ==========================================
-- 15. Find Duplicate Records
-- ==========================================

SELECT first_name,
       last_name,
       email,
       COUNT(*) AS duplicate_count
FROM Employee
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- ==========================================
-- 16. Find Duplicate Records Using Self Join
-- ==========================================

SELECT e1.emp_id,
       e1.first_name,
       e1.email
FROM Employee e1
INNER JOIN Employee e2
ON e1.email = e2.email
AND e1.emp_id > e2.emp_id;

-- ==========================================
-- 17. Delete Duplicate Records Using Self Join
-- ==========================================

DELETE e1
FROM Employee e1
INNER JOIN Employee e2
ON e1.email = e2.email
AND e1.emp_id > e2.emp_id;

-- ==========================================
-- 18. Check Table Structure
-- ==========================================

DESC Employee;

DESC Department;

-- ==========================================
-- 19. Window Function - Rank Employees By Salary
-- ==========================================

SELECT emp_id,
       first_name,
       salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM Employee;

-- ==========================================
-- 20. Window Function - Department Wise Salary Rank
-- ==========================================

SELECT emp_id,
       first_name,
       dept_id,
       salary,
       DENSE_RANK() OVER (
           PARTITION BY dept_id
           ORDER BY salary DESC
       ) AS department_rank
FROM Employee;

-- ==========================================
-- 21. Window Function - Running Total Salary
-- ==========================================

SELECT emp_id,
       first_name,
       salary,
       SUM(salary) OVER (
           ORDER BY emp_id
       ) AS running_total_salary
FROM Employee;

-- ==========================================
-- 22. CASE WHEN - Categorize Employees By Salary
-- ==========================================

SELECT emp_id,
       first_name,
       salary,
       CASE
           WHEN salary >= 70000 THEN 'High Salary'
           WHEN salary >= 50000 THEN 'Medium Salary'
           ELSE 'Low Salary'
       END AS salary_category
FROM Employee;

-- ==========================================
-- 23. CASE WHEN - Employee Status Description
-- ==========================================

SELECT emp_id,
       first_name,
       status,
       CASE
           WHEN status = 'Active' THEN 'Currently Working'
           WHEN status = 'Inactive' THEN 'Not Working'
           ELSE 'Unknown'
       END AS employee_status
FROM Employee;

-- ==========================================
-- 24. Create View - Employee Department Details
-- ==========================================

CREATE VIEW employee_department_view AS
SELECT e.emp_id,
       e.first_name,
       e.last_name,
       e.salary,
       d.dept_name
FROM Employee e
INNER JOIN Department d
ON e.dept_id = d.dept_id;

-- ==========================================
-- 25. Display View Data
-- ==========================================

SELECT *
FROM employee_department_view;

-- ==========================================
-- 26. Create Salary Log Table
-- ==========================================

CREATE TABLE salary_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 27. Create Trigger For Salary Updates
-- ==========================================

DELIMITER $$

CREATE TRIGGER salary_update_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO salary_log
    (
        emp_id,
        old_salary,
        new_salary
    )
    VALUES
    (
        OLD.emp_id,
        OLD.salary,
        NEW.salary
    );
END $$

DELIMITER ;

-- ==========================================
-- 28. Test Trigger
-- ==========================================

UPDATE Employee
SET salary = 80000
WHERE emp_id = 1;

-- ==========================================
-- 29. Display Salary Log Records
-- ==========================================

SELECT *
FROM salary_log;