

# 🏥 Unified Hospital Management System (Master Lab)

This database serves as a comprehensive educational model that unifies the logical patterns of seven different lab programs into one cohesive ecosystem.

## 🛠️ 1. Complete Database Schema (DDL)
This script creates the environment, handles circular management dependencies, and sets up cascading referential integrity.

```sql
CREATE DATABASE HospitalMasterDB;
USE HospitalMasterDB;

-- 1. DEPARTMENT Table (Circular Dependency Pattern)
CREATE TABLE Department (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(30) UNIQUE NOT NULL,
    MGR_SSN VARCHAR(10) -- Link to Staff (MGR_SSN)
);

-- 2. STAFF Table (Self-Referencing & Hierarchy Pattern)
CREATE TABLE Staff (
    SSN VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(25) NOT NULL,
    Salary DECIMAL(10,2),
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    SuperSSN VARCHAR(10) REFERENCES Staff(SSN), -- Supervisor (Self-Join)
    Dept_ID INT REFERENCES Department(Dept_ID) ON DELETE SET NULL
);

-- Handle Circular Dependency
ALTER TABLE Department ADD CONSTRAINT FK_DeptMgr FOREIGN KEY (MGR_SSN) REFERENCES Staff(SSN);

-- 3. PATIENT Table
CREATE TABLE Patient (
    P_ID VARCHAR(10) PRIMARY KEY,
    P_Name VARCHAR(25),
    SSN VARCHAR(10) REFERENCES Staff(SSN) -- Attending Primary Staff
);

-- 4. MEDICAL_RECORD Table (Accident/Damage pattern)
CREATE TABLE Medical_Record (
    Record_Num INT PRIMARY KEY,
    Diagnosis VARCHAR(50),
    Visit_Date DATE,
    Total_Cost INT -- Logic from Insurance/Order labs
);

-- 5. PATIENT_VISIT Table (Many-to-Many Bridge)
CREATE TABLE Patient_Visit (
    P_ID VARCHAR(10) REFERENCES Patient(P_ID),
    Record_Num INT REFERENCES Medical_Record(Record_Num) ON DELETE CASCADE,
    SSN VARCHAR(10) REFERENCES Staff(SSN), -- Doctor in charge of visit
    PRIMARY KEY (P_ID, Record_Num)
);

-- 6. PHARMACY_BRANCH Table (Division Operator Pattern)
CREATE TABLE Pharmacy_Branch (
    Phar_Name VARCHAR(20) PRIMARY KEY,
    City VARCHAR(20)
);

-- 7. PHAR_INVENTORY Table
CREATE TABLE Phar_Inventory (
    Batch_ID INT PRIMARY KEY,
    Phar_Name VARCHAR(20) REFERENCES Pharmacy_Branch(Phar_Name),
    Med_Name VARCHAR(30),
    P_ID VARCHAR(10) REFERENCES Patient(P_ID)
);
```

---

## 📊 2. Sample Data Insertion (DML)
Data is structured to ensure that **"John Doe"** satisfies the division query (visiting all branches) and **"Dr. Smith"** satisfies management queries.

```sql
-- Setup Departments & Staff
INSERT INTO Department (Dept_ID, Dept_Name) VALUES (1, 'Cardiology'), (2, 'Pharmacy');
INSERT INTO Staff VALUES ('S10', 'Dr. Smith', 150000, 'M', NULL, 1); 
INSERT INTO Staff VALUES ('S20', 'Nurse Joy', 60000, 'F', 'S10', 2);
INSERT INTO Staff VALUES ('S30', 'Dr. Vane', 110000, 'M', 'S10', 1);
UPDATE Department SET MGR_SSN = 'S10' WHERE Dept_ID = 1;

-- Patient & Record Data
INSERT INTO Patient VALUES ('P01', 'John Doe', 'S10');
INSERT INTO Medical_Record VALUES (5001, 'Cardiac Arrest', '2008-05-12', 45000);
INSERT INTO Medical_Record VALUES (5002, 'Hypertension', '2008-11-20', 12000);
INSERT INTO Patient_Visit VALUES ('P01', 5001, 'S10');
INSERT INTO Patient_Visit VALUES ('P01', 5002, 'S30');

-- Pharmacy Branches
INSERT INTO Pharmacy_Branch VALUES ('Phar_East', 'Bangalore'), ('Phar_West', 'Bangalore');
INSERT INTO Phar_Inventory VALUES (701, 'Phar_East', 'Aspirin', 'P01');
INSERT INTO Phar_Inventory VALUES (702, 'Phar_West', 'Aspirin', 'P01');
```

---

## 🔍 3. Integrated Query Solutions & Output Tables

### Query 1: The Division Pattern (Banking/Employee Concepts)
**Goal:** Find patients who have collected medication from **ALL** pharmacy branches in 'Bangalore'.
```sql
SELECT P_Name FROM Patient P
WHERE NOT EXISTS (
    (SELECT Phar_Name FROM Pharmacy_Branch WHERE City = 'Bangalore')
    EXCEPT
    (SELECT Phar_Name FROM Phar_Inventory I WHERE I.P_ID = P.P_ID)
);
```
**Output:**
| P_Name |
| :--- |
| John Doe |

---

### Query 2: Aggregation & Grouping (Employee/Order Concepts)
**Goal:** Find Dept IDs where at least 2 staff members earn more than 1,00,000.
```sql
SELECT Dept_ID, COUNT(*) AS High_Earners
FROM Staff 
WHERE Salary > 100000 
GROUP BY Dept_ID 
HAVING COUNT(*) >= 2;
```
**Output:**
| Dept_ID | High_Earners |
| :--- | :--- |
| 1 | 2 |

---

### Query 3: Top-1 & Date Filtering (Insurance/Movie Concepts)
**Goal:** Find the patient who had the minimum treatment cost in the year 2008.
```sql
SELECT TOP 1 P.P_Name, M.Total_Cost
FROM Patient P, Medical_Record M, Patient_Visit V
WHERE P.P_ID = V.P_ID AND V.Record_Num = M.Record_Num
AND M.Visit_Date LIKE '2008%'
ORDER BY M.Total_Cost ASC;
```
**Output:**
| P_Name | Total_Cost |
| :--- | :--- |
| John Doe | 12000 |

---

### Query 4: Reporting via Views (Student/Library Concepts)
**Goal:** Create a view for the 'Cardiology' department showing staff and their patient visit counts.
```sql
CREATE VIEW Cardiology_Stats AS
SELECT S.Name AS Doctor, COUNT(V.P_ID) AS Total_Visits
FROM Staff S LEFT JOIN Patient_Visit V ON S.SSN = V.SSN
WHERE S.Dept_ID = 1
GROUP BY S.Name;

SELECT * FROM Cardiology_Stats;
```
**Output:**
| Doctor | Total_Visits |
| :--- | :--- |
| Dr. Smith | 1 |
| Dr. Vane | 1 |

---

### Query 5: Cascade Verification (Library Concepts)
**Goal:** Demonstrate that deleting a master Medical Record removes linked visits.
```sql
DELETE FROM Medical_Record WHERE Record_Num = 5001;

-- Verification (Visit 5001 should be gone)
SELECT * FROM Patient_Visit WHERE Record_Num = 5001;
```
**Output:**
| P_ID | Record_Num | SSN |
| :--- | :--- | :--- |
| *(Empty)* | | |

---

### 💡 Mastery Checklist
By practicing this Hospital DB, you have mastered:
* **Lab 1:** Self-joins (`SuperSSN`) and Circular constraints (`MGR_SSN`).
* **Lab 2:** Date-based filtering and `MIN/MAX` value retrieval.
* **Lab 3:** Relational Division using `NOT EXISTS` and `EXCEPT`.
* **Lab 4:** Complex `JOIN` paths between 4+ tables.
* **Lab 5:** Abstracting logic into reusable `VIEWS`.
* **Lab 6:** Data integrity via `ON DELETE CASCADE`.
* **Lab 7:** Primary key management in many-to-many bridge tables.