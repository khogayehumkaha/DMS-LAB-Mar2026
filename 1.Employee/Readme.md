
# Employee Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema handles complex relationships, including circular dependencies between employees and departments, and project tracking.

```sql
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
```

---

## 📊 2. Data Insertion
*Data is optimized to ensure all 9 queries return meaningful results.*

```sql
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
```

---

## 🔍 3. Queries and Results

### 1. Employees working on all projects controlled by Dept 5
```sql
SELECT FName, LName FROM EMPLOYEE E
WHERE NOT EXISTS (
    (SELECT PNo FROM PROJECT WHERE DNo=5)
    EXCEPT
    (SELECT PNo FROM WORKS_ON W WHERE W.SSN = E.SSN)
);
```
**Output:**
| FName | LName |
| :--- | :--- |
| James | Codd |

---

### 2. Dept # and Count of employees making > 10,00,000 (in depts with > 5 staff)
*(Note: To see results with small sample data, we use `HAVING COUNT(*) >= 3`)*
```sql
SELECT DNo, COUNT(*) AS High_Earners
FROM EMPLOYEE
WHERE Salary > 1000000
GROUP BY DNo
HAVING DNo IN (SELECT DNo FROM EMPLOYEE GROUP BY DNo HAVING COUNT(*) >= 3);
```
**Output:**
| DNo | High_Earners |
| :--- | :--- |
| 1 | 2 |
| 5 | 3 |

---

### 3. Projects involving 'Codd' as a worker or manager
```sql
SELECT DISTINCT PNo FROM WORKS_ON WHERE SSN = (SELECT SSN FROM EMPLOYEE WHERE LName='Codd')
UNION
SELECT DISTINCT P.PNo FROM PROJECT P, DEPARTMENT D 
WHERE P.DNo = D.DNo AND D.MgrSSN = (SELECT SSN FROM EMPLOYEE WHERE LName = 'Codd');
```
**Output:**
| PNo |
| :--- |
| 10 |
| 20 |
| 30 |

---

### 4. Project names located in 'Stafford'
```sql
SELECT PName FROM PROJECT WHERE PLocation = 'Stafford';
```
**Output:**
| PName |
| :--- |
| Big Data |
| Cloud Arch |

---

### 5. Employees with at least one dependent (Nested Query)
```sql
SELECT FName, LName FROM EMPLOYEE 
WHERE SSN IN (SELECT ESSN FROM DEPENDENT);
```
**Output:**
| FName | LName |
| :--- | :--- |
| James | Codd |
| Adithi | S |

---

### 6. Employees in 'Research' department (Nested Query)
```sql
SELECT FName, LName FROM EMPLOYEE 
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName = 'Research');
```
**Output:**
| FName | LName |
| :--- | :--- |
| Adithi | S |
| Suhas | B |
| Nidhi | K |

---

### 7. Managers who have at least one dependent (Nested Query)
```sql
SELECT FName, LName FROM EMPLOYEE 
WHERE SSN IN (SELECT MgrSSN FROM DEPARTMENT)
AND SSN IN (SELECT ESSN FROM DEPENDENT);
```
**Output:**
| FName | LName |
| :--- | :--- |
| James | Codd |
| Adithi | S |

---

### 8. 10% raise for employees on 'Smart City' project
```sql
SELECT FName, LName, Salary AS Old_Salary, (Salary * 1.1) AS New_Salary
FROM EMPLOYEE 
WHERE SSN IN (SELECT SSN FROM WORKS_ON WHERE PNo IN (SELECT PNo FROM PROJECT WHERE PName='Smart City'));
```
**Output:**
| FName | LName | Old_Salary | New_Salary |
| :--- | :--- | :--- | :--- |
| James | Codd | 1100000.00 | 1210000.00 |
| Suhas | B | 1500000.00 | 1650000.00 |

---

### 9. Salary statistics for 'Information Science' department
```sql
SELECT SUM(Salary) AS Total, MAX(Salary) AS Max, MIN(Salary) AS Min, AVG(Salary) AS Avg
FROM EMPLOYEE 
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName='Information Science');
```
**Output:**
| Total | Max | Min | Avg |
| :--- | :--- | :--- | :--- |
| 3150000.00 | 1100000.00 | 950000.00 | 1050000.00 |