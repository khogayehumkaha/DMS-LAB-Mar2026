
# Employee Database Management System (DBMS Lab)

This project provides a streamlined and clean implementation of the **Employee Database** (Part A, Problem 1) as per the 18IS507 Lab Manual. 

## 🚀 Overview
The implementation focuses on a **"Query-Ready"** data setup. Instead of performing multiple updates after insertion, the data is pre-configured so that all queries—including the complex Relational Division in Query 4—produce immediate and visible results.

## 🛠️ 1. Database Schema
The schema defines the structure for Employees, Departments, Projects, and their locations. It uses **4-digit SSNs** for simplicity and handles circular dependencies using `ALTER` statements.

```sql
-- Create Department Table (Initial)
CREATE TABLE Department (
    DNUM INT PRIMARY KEY,
    DName VARCHAR(30) UNIQUE NOT NULL,
    MGRSSN VARCHAR(10),
    MGRStartDtae DATE
);

-- Create Employee Table
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

-- Establish Foreign Key Constraints
ALTER TABLE Department ADD CONSTRAINT FK_Mgr FOREIGN KEY (MGRSSN) REFERENCES employee(SSN);
ALTER TABLE employee ADD CONSTRAINT FK_Dept FOREIGN KEY (DNO) REFERENCES Department (DNUM);

-- Create DLocation Table
CREATE TABLE DLocation (
    DNO INT REFERENCES Department (DNUM),
    DLoc VARCHAR(30),
    PRIMARY KEY (DNO, DLoc)
);

-- Create Project Table
CREATE TABLE Project (
    PNO INT PRIMARY KEY,
    PName VARCHAR(30),
    PLocation varchar(30),
    DNO INT REFERENCES Department (DNUM)
);

-- Create Works_on Table
CREATE TABLE Works_on (
    ESSN VARCHAR(10) REFERENCES employee (SSN),
    PNO INT REFERENCES Project (PNO),
    hours INT,
    PRIMARY KEY (ESSN, PNO)
);
```


---

## 📊 2. Data Insertion
The data is optimized to satisfy the specific logic of the lab queries (e.g., setting an employee's name to 'Codd' and a project to 'Smart City').

```sql
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

-- 3. Link Employees to Depts
UPDATE employee SET DNO=1 WHERE SSN='1001';
UPDATE employee SET DNO=2 WHERE SSN='1002';
UPDATE employee SET DNO=1 WHERE SSN='1004';
UPDATE employee SET DNO=2 WHERE SSN='1003';

-- 4. Insert Locations and Projects
INSERT INTO DLocation VALUES (1, 'Bangalore'), (2, 'Mysore'), (3, 'Udupi');
INSERT INTO Project VALUES (10, 'P1','Bangalore', 1), (20, 'Smart City','Mysore', 2), 
                           (30, 'P3','Udupi', 1);

-- 5. Insert Works_on (Configured so James works on ALL Dept 1 projects)
INSERT INTO Works_on VALUES ('1001', 10, 4), ('1001', 30, 5); 
INSERT INTO Works_on VALUES ('1004', 10, 8);                 
INSERT INTO Works_on VALUES ('1003', 20, 10);                
```

---

## 🔍 3. SQL Queries and Results

### Query 1
**Make a list of all project numbers for projects that involve an employee whose last name is ‘Codd’, either as a worker or as a manager of the department.**
```sql
SELECT DISTINCT PNO FROM Works_on WHERE ESSN = (SELECT SSN FROM employee WHERE LName='Codd')
UNION
SELECT DISTINCT P.PNO FROM Project P, Department D 
WHERE P.DNO = D.DNUM AND D.MGRSSN = (SELECT SSN FROM employee WHERE LName = 'Codd');
```
| PNO |
| :--- |
| 10 |
| 30 |

---

### Query 2
**Show the resulting salaries if every employee working on the ‘Smart City’ project is given a 10 percent raise.**
```sql
SELECT FName, LName, 1.1 * Salary AS New_Salary
FROM employee 
WHERE SSN IN (SELECT ESSN FROM Works_on WHERE PNO IN (SELECT PNO FROM Project WHERE PName='Smart City'));
```
| FName | LName | New_Salary |
| :--- | :--- | :--- |
| Suhas | B | 990000.00 |

---

### Query 3
**Find the sum, maximum, minimum, and average salary of the ‘Research’ department.**
```sql
SELECT SUM(Salary) AS Total, MAX(Salary) AS Max, MIN(Salary) AS Min, AVG(Salary) AS Avg
FROM employee WHERE DNO = (SELECT DNUM FROM Department WHERE DName='Research');
```
| Total | Max | Min | Avg |
| :--- | :--- | :--- | :--- |
| 1300000.00 | 900000.00 | 400000.00 | 650000.00 |

---

### Query 4
**Retrieve the name of each employee who works on ALL the projects controlled by department number 1.**
```sql
SELECT FName, LName FROM employee e
WHERE NOT EXISTS (
    (SELECT PNO FROM Project WHERE DNO=1)
    EXCEPT
    (SELECT PNO FROM Works_on WHERE ESSN=e.SSN)
);
```
| FName | LName |
| :--- | :--- |
| James | Codd |

---

### Query 5
**For each department that has more than 2 employees, retrieve the department number and the number of its employees who are making more than Rs. 1,00,000.**
```sql
SELECT DNO, COUNT(*) AS Count 
FROM employee WHERE Salary > 100000 
GROUP BY DNO HAVING COUNT(*) >= 2;
```
| DNO | Count |
| :--- | :--- |
| 2 | 2 |