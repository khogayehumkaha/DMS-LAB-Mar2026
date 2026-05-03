CREATE DATABASE EmployeeDB;
USE EmployeeDB;

-- 1. DEPARTMENT Table
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(30) UNIQUE NOT NULL,
    MgrSSN VARCHAR(10),
    MgrStartDate DATE
);

-- 2. EMPLOYEE Table
CREATE TABLE EMPLOYEE (
    SSN VARCHAR(10) PRIMARY KEY,
    FName VARCHAR(20) NOT NULL,
    LName VARCHAR(20),
    Address VARCHAR(20),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    SuperSSN VARCHAR(10) REFERENCES EMPLOYEE(SSN),
    DNo INT REFERENCES DEPARTMENT(DNo)
);

-- Circular Dependency: Link Manager SSN back to Employee
ALTER TABLE DEPARTMENT ADD CONSTRAINT FK_Mgr FOREIGN KEY (MgrSSN) REFERENCES EMPLOYEE(SSN);

-- 3. DLOCATION Table
CREATE TABLE DLOCATION (
    DNo INT REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE,
    DLoc VARCHAR(30),
    PRIMARY KEY (DNo, DLoc)
);

-- 4. PROJECT Table
CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(30),
    PLocation VARCHAR(30),
    DNo INT REFERENCES DEPARTMENT(DNo)
);

-- 5. WORKS_ON Table
CREATE TABLE WORKS_ON (
    SSN VARCHAR(10) REFERENCES EMPLOYEE(SSN),
    PNo INT REFERENCES PROJECT(PNo),
    Hours INT,
    PRIMARY KEY (SSN, PNo)
);

-- 6. DEPENDENT Table
CREATE TABLE DEPENDENT (
    ESSN VARCHAR(10) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    Dependent_Name VARCHAR(20),
    Sex CHAR(1),
    Bdate DATE,
    Relationship VARCHAR(20),
    PRIMARY KEY (ESSN, Dependent_Name)
);



-- Insert Base Employees (No DNo yet)
INSERT INTO EMPLOYEE (SSN, FName, LName, Address, Sex, Salary) VALUES 
('101', 'James', 'Codd', 'Bangalore', 'M', 1100000),
('102', 'Adithi', 'S', 'Mysore', 'F', 1200000),
('103', 'Suhas', 'B', 'Udupi', 'M', 1500000),
('104', 'Nidhi', 'K', 'Mangalore', 'F', 1050000),
('105', 'Chetan', 'R', 'Bangalore', 'M', 1100000),
('106', 'Riya', 'M', 'Mysore', 'F', 950000);

-- Insert Departments
INSERT INTO DEPARTMENT VALUES (1, 'Information Science', '101', '2020-01-01');
INSERT INTO DEPARTMENT VALUES (5, 'Research', '102', '2019-05-15');

-- Link Employees to Depts
UPDATE EMPLOYEE SET DNo=1 WHERE SSN IN ('101', '105', '106');
UPDATE EMPLOYEE SET DNo=5 WHERE SSN IN ('102', '103', '104');

-- Projects
INSERT INTO PROJECT VALUES (10, 'Big Data', 'Stafford', 5);
INSERT INTO PROJECT VALUES (20, 'Smart City', 'Mysore', 5);
INSERT INTO PROJECT VALUES (30, 'Cloud Arch', 'Stafford', 5);

-- Works_on (James Codd works on ALL projects of Dept 5)
INSERT INTO WORKS_ON VALUES ('101', 10, 4), ('101', 20, 5), ('101', 30, 10);
INSERT INTO WORKS_ON VALUES ('103', 20, 8);

-- Dependents
INSERT INTO DEPENDENT VALUES ('101', 'Alice', 'F', '2010-01-01', 'Daughter');
INSERT INTO DEPENDENT VALUES ('102', 'Bob', 'M', '2012-05-05', 'Son');




-- 1. Retrieve the name of each employee who works on all the projects controlled by department number 5 

SELECT FName, LName FROM EMPLOYEE E
WHERE NOT EXISTS (
    (SELECT PNo FROM PROJECT WHERE DNo=5)
    EXCEPT
    (SELECT PNo FROM WORKS_ON W WHERE W.SSN = E.SSN)
);

-- 2. For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs. 10,00,000.
-- (Note: To see results with small sample data, we use HAVING COUNT(*) >= 3)

SELECT DNo, COUNT(*) AS High_Earners
FROM EMPLOYEE
WHERE Salary > 1000000
GROUP BY DNo
HAVING DNo IN (SELECT DNo FROM EMPLOYEE GROUP BY DNo HAVING COUNT(*) >= 3);

-- 3.  Make a list of all project numbers for projects that involve an employee whose last name is ‘Codd’, either as a worker or as a manager of the department that controls the project. 


SELECT DISTINCT PNo FROM WORKS_ON WHERE SSN = (SELECT SSN FROM EMPLOYEE WHERE LName='Codd')
UNION
SELECT DISTINCT P.PNo FROM PROJECT P, DEPARTMENT D 
WHERE P.DNo = D.DNo AND D.MgrSSN = (SELECT SSN FROM EMPLOYEE WHERE LName = 'Codd');


-- 4.  Show all project names located in 'Stafford'. 

SELECT PName FROM PROJECT WHERE PLocation = 'Stafford';


-- 5. List all employees who have at least one dependent using nested queries 

SELECT FName, LName FROM EMPLOYEE 
WHERE SSN IN (SELECT ESSN FROM DEPENDENT);


-- 6. Retrieve the names of employees who work in the 'Research' department using nested queries 

SELECT FName, LName FROM EMPLOYEE 
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName = 'Research');

-- 7. List the names of managers who have at least one dependent  using nested queries

SELECT FName, LName FROM EMPLOYEE 
WHERE SSN IN (SELECT MgrSSN FROM DEPARTMENT)
AND SSN IN (SELECT ESSN FROM DEPENDENT);


--  8. Show the resulting salaries if every employee working on the ‘Smart City’ project is given a 10 percent raise.

SELECT FName, LName, Salary AS Old_Salary, (Salary * 1.1) AS New_Salary
FROM EMPLOYEE 
WHERE SSN IN (SELECT SSN FROM WORKS_ON WHERE PNo IN (SELECT PNo FROM PROJECT WHERE PName='Smart City'));


-- 9. Find the sum of the salaries of all employees of the ‘Information Science’ department, as well as the maximum salary, the minimum salary, and the average salary in this department. 

SELECT SUM(Salary) AS Total, MAX(Salary) AS Max, MIN(Salary) AS Min, AVG(Salary) AS Avg
FROM EMPLOYEE 
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName='Information Science');


-- 10. Retrieve the names of employees whose salary is greater than the average salary of their respective department.

SELECT FName, LName, Salary 
FROM EMPLOYEE E
WHERE Salary > (SELECT AVG(Salary) FROM EMPLOYEE WHERE DNo = E.DNo);


-- 11. For each department, retrieve the department name and the number of employees who are actively assigned to at least one project.

SELECT D.DName, COUNT(DISTINCT W.SSN) AS Active_Workers
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNo = E.DNo
JOIN WORKS_ON W ON E.SSN = W.SSN
GROUP BY D.DName;


-- 12. Create a view to display employee name, department name, and project name for employees working on at least one project.

CREATE VIEW Employee_Project_Summary AS
SELECT E.FName + ' ' + E.LName AS Full_Name, D.DName, P.PName
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo;

-- Verification
SELECT * FROM Employee_Project_Summary;




