create database Employee;
use Employee;


-- 1. Create Tables (Basic Structure)
CREATE TABLE Department (
    DNUM INT PRIMARY KEY,
    DName VARCHAR(30) UNIQUE NOT NULL,
    MGRSSN VARCHAR(10),
    MGRStartDtae DATE
);

CREATE TABLE employee (
    SSN VARCHAR(10) PRIMARY KEY,
    FName VARCHAR(20) NOT NULL,
    LName VARCHAR(20),
    Address VARCHAR(20),
    Gender CHAR(1),
    Salary DECIMAL(10,2),
    SuperSSN VARCHAR(10) REFERENCES employee (SSN),
    DNO INT
);

-- 2. Link Department and Employee (Circular Dependency)
ALTER TABLE Department ADD CONSTRAINT FK_Mgr FOREIGN KEY (MGRSSN) REFERENCES employee(SSN);
ALTER TABLE employee ADD CONSTRAINT FK_Dept FOREIGN KEY (DNO) REFERENCES Department (DNUM);

-- 3. Create Supporting Tables
CREATE TABLE DLocation (
    DNO INT REFERENCES Department (DNUM),
    DLoc VARCHAR(30),
    PRIMARY KEY (DNO, DLoc)
);

CREATE TABLE Project (
    PNO INT PRIMARY KEY,
    PName VARCHAR(30),
    PLocation varchar(30),
    DNO INT REFERENCES Department (DNUM)
);

CREATE TABLE Works_on (
    ESSN VARCHAR(10) REFERENCES employee (SSN),
    PNO INT REFERENCES Project (PNO),
    hours INT,
    PRIMARY KEY (ESSN, PNO)
);




-- 1. Insert Employees
INSERT INTO employee (SSN, FName, LName, Address, Gender, Salary) VALUES 
('1001', 'James', 'Codd', 'Bangalore', 'M', 100000),
('1002', 'Adithi', 'S', 'Mysore', 'F', 400000),
('1003', 'Suhas', 'B', 'Udupi', 'M', 900000),
('1004', 'Nidhi', 'K', 'Mangalore', 'F', 150000);

-- 2. Insert Departments
INSERT INTO Department VALUES (1, 'Information Science', '1001', '2020-01-01');
INSERT INTO Department VALUES (2, 'Research', '1002', '2019-05-15');
INSERT INTO Department VALUES (3, 'Electrical', '1003', '2021-08-10');

-- 3. Assign Depts & Locations
UPDATE employee SET DNO=1 WHERE SSN='1001';
UPDATE employee SET DNO=2 WHERE SSN='1002';
UPDATE employee SET DNO=1 WHERE SSN='1004';
UPDATE employee SET DNO=2 WHERE SSN='1003';


INSERT INTO DLocation VALUES (1, 'Bangalore'), (2, 'Mysore'), (3, 'Udupi');

-- 4. Insert Projects
INSERT INTO Project VALUES (10, 'P1','Bangalore', 1), (20, 'Smart City','Mysore', 2), 
                           (30, 'P3','Udupi', 1);

-- 5. Insert Works_on (Configured so Q4 works for employee 1001)
INSERT INTO Works_on VALUES ('1001', 10, 4), ('1001', 30, 5); -- James works on ALL Dept 1 projects
INSERT INTO Works_on VALUES ('1004', 10, 8);                  -- Nidhi works on only one
INSERT INTO Works_on VALUES ('1003', 20, 10);                 -- Suhas on Smart City


--Query 1: List project numbers for projects involving 'Codd' as a worker or manager.

SELECT DISTINCT PNO FROM Works_on WHERE ESSN = (SELECT SSN FROM employee WHERE LName='Codd')
UNION
SELECT DISTINCT P.PNO FROM Project P, Department D 
WHERE P.DNO = D.DNUM AND D.MGRSSN = (SELECT SSN FROM employee WHERE LName = 'Codd');


--Query 2: Show 10% raise for workers on the ‘Smart City’ project.

SELECT FName, LName, 1.1 * Salary AS New_Salary
FROM employee 
WHERE SSN IN (SELECT ESSN FROM Works_on WHERE PNO IN (SELECT PNO FROM Project WHERE PName='Smart City'));

--Query 3: Salary statistics for the ‘Research’ department.

SELECT SUM(Salary) AS Total, MAX(Salary) AS Max, MIN(Salary) AS Min, AVG(Salary) AS Avg
FROM employee WHERE DNO = (SELECT DNUM FROM Department WHERE DName='Research');

--Query 4: Employees who work on ALL projects controlled by Dept 1.

SELECT FName, LName FROM employee e
WHERE NOT EXISTS (
    (SELECT PNO FROM Project WHERE DNO=1)
    EXCEPT
    (SELECT PNO FROM Works_on WHERE ESSN=e.SSN)
);

--Query 5: Depts with > 2 employees making > 1,00,000.

SELECT DNO, COUNT(*) AS Count 
FROM employee WHERE Salary > 100000 
GROUP BY DNO HAVING COUNT(*) >= 2;