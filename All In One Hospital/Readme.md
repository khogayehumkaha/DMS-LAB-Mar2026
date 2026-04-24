
# 🏥 Super Hospital Management System (DBMS Master Schema)

This database serves as an all-in-one practice tool for advanced SQL concepts.

## 🛠️ 1. Database Schema (DDL)
Contains complex integrity constraints including circular and self-referencing foreign keys.

```sql
CREATE DATABASE HospitalSuperDB;
USE HospitalSuperDB;

-- 1. DEPARTMENT (Circular Dependency Pattern)
CREATE TABLE DEPARTMENT (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(30) UNIQUE NOT NULL,
    MGR_SSN VARCHAR(10) -- Link to STAFF (MGR_SSN)
);

-- 2. STAFF (Self-Referencing / Hierarchy Pattern)
CREATE TABLE STAFF (
    SSN VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(25) NOT NULL,
    Salary DECIMAL(10,2),
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    SuperSSN VARCHAR(10) REFERENCES STAFF(SSN), -- Supervisor (Self-Join)
    Dept_ID INT REFERENCES DEPARTMENT(Dept_ID) ON DELETE SET NULL
);

-- Handle Circular Dependency after STAFF table creation
ALTER TABLE DEPARTMENT ADD CONSTRAINT FK_DeptMgr FOREIGN KEY (MGR_SSN) REFERENCES STAFF(SSN);

-- 3. WARD (Categorical Grouping Pattern)
CREATE TABLE WARD (
    Ward_ID INT PRIMARY KEY,
    Wing CHAR(1), -- 'A', 'B' (Like Sections)
    Floor INT      -- (Like Semesters)
);

-- 4. PATIENT (Master Data)
CREATE TABLE PATIENT (
    P_ID VARCHAR(10) PRIMARY KEY,
    P_Name VARCHAR(25),
    DOB DATE,
    Ward_ID INT REFERENCES WARD(Ward_ID)
);

-- 5. MEDICAL_RECORD (Incident/Damage Pattern)
CREATE TABLE MEDICAL_RECORD (
    Record_Num INT PRIMARY KEY,
    Diagnosis VARCHAR(50),
    Visit_Date DATE,
    Total_Cost INT
);

-- 6. PATIENT_VISIT (Many-to-Many Bridge with Cascade)
CREATE TABLE PATIENT_VISIT (
    P_ID VARCHAR(10) REFERENCES PATIENT(P_ID) ON DELETE CASCADE,
    Record_Num INT REFERENCES MEDICAL_RECORD(Record_Num) ON DELETE CASCADE,
    Doctor_SSN VARCHAR(10) REFERENCES STAFF(SSN),
    PRIMARY KEY (P_ID, Record_Num)
);

-- 7. PHARMACY_BRANCH (Division Operator Pattern)
CREATE TABLE PHARMACY_BRANCH (
    Phar_ID INT PRIMARY KEY,
    Phar_Name VARCHAR(20),
    City VARCHAR(20)
);

-- 8. DRUG_ORDER (Inventory/Order Pattern)
CREATE TABLE DRUG_ORDER (
    Order_ID INT PRIMARY KEY,
    Phar_ID INT REFERENCES PHARMACY_BRANCH(Phar_ID),
    P_ID VARCHAR(10) REFERENCES PATIENT(P_ID),
    Drug_Name VARCHAR(30),
    Qty INT
);
```

---

## 📊 2. Data Insertion (DML)
*Data is structured to satisfy Division and Hierarchy queries.*

```sql
-- Setup Departments & Staff
INSERT INTO DEPARTMENT (Dept_ID, Dept_Name) VALUES (1, 'Cardiology'), (2, 'Pharmacy');
INSERT INTO STAFF VALUES ('S10', 'Dr. Smith', 150000, 'M', NULL, 1); 
INSERT INTO STAFF VALUES ('S20', 'Nurse Joy', 60000, 'F', 'S10', 2);
INSERT INTO STAFF VALUES ('S30', 'Dr. Vane', 110000, 'M', 'S10', 1);
UPDATE DEPARTMENT SET MGR_SSN = 'S10' WHERE Dept_ID = 1;

-- Wards & Patients
INSERT INTO WARD VALUES (101, 'A', 1), (102, 'B', 2);
INSERT INTO PATIENT VALUES ('P01', 'John Doe', '1985-05-12', 101);
INSERT INTO PATIENT VALUES ('P02', 'Jane Roe', '1992-08-20', 101);

-- Records & Visits
INSERT INTO MEDICAL_RECORD VALUES (5001, 'Cardiac Arrest', '2023-05-12', 45000);
INSERT INTO MEDICAL_RECORD VALUES (5002, 'Hypertension', '2023-11-20', 12000);
INSERT INTO PATIENT_VISIT VALUES ('P01', 5001, 'S10'), ('P01', 5002, 'S30');

-- Pharmacy Branches (Division Logic: P01 visits ALL Bangalore branches)
INSERT INTO PHARMACY_BRANCH VALUES (1, 'Apollo', 'Bangalore'), (2, 'MedPlus', 'Bangalore');
INSERT INTO DRUG_ORDER VALUES (901, 1, 'P01', 'Aspirin', 2), (902, 2, 'P01', 'Aspirin', 1);
```

---

## 🔍 3. Queries & Output Tables

### Q1: Relational Division (ALL)
*Find patients who collected medication from **ALL** pharmacy branches in 'Bangalore'.*
```sql
SELECT P_Name FROM PATIENT P
WHERE NOT EXISTS (
    (SELECT Phar_ID FROM PHARMACY_BRANCH WHERE City = 'Bangalore')
    EXCEPT
    (SELECT Phar_ID FROM DRUG_ORDER D WHERE D.P_ID = P.P_ID)
);
```
| P_Name |
| :--- |
| John Doe |

---

### Q2: Self-Join Hierarchy
*List Staff names and their Supervisor names.*
```sql
SELECT E.Name AS Staff, S.Name AS Supervisor
FROM STAFF E JOIN STAFF S ON E.SuperSSN = S.SSN;
```
| Staff | Supervisor |
| :--- | :--- |
| Nurse Joy | Dr. Smith |
| Dr. Vane | Dr. Smith |

---

### Q3: Views & Categorization (CASE)
*Create a view for the 'Cardiology' department showing visit status based on cost.*
```sql
CREATE VIEW Cardiology_Report AS
SELECT P.P_Name, M.Diagnosis, M.Total_Cost,
CASE 
    WHEN M.Total_Cost > 30000 THEN 'Premium Treatment'
    ELSE 'Standard Treatment'
END AS Category
FROM PATIENT P
JOIN PATIENT_VISIT V ON P.P_ID = V.P_ID
JOIN MEDICAL_RECORD M ON V.Record_Num = M.Record_Num
WHERE V.Doctor_SSN IN (SELECT SSN FROM STAFF WHERE Dept_ID = 1);

SELECT * FROM Cardiology_Report;
```
| P_Name | Diagnosis | Total_Cost | Category |
| :--- | :--- | :--- | :--- |
| John Doe | Cardiac Arrest | 45000 | Premium Treatment |
| John Doe | Hypertension | 12000 | Standard Treatment |

---

### Q4: Nested Update
*Give a 10% discount to all patients staying in 'Wing A'.*
```sql
UPDATE MEDICAL_RECORD
SET Total_Cost = Total_Cost * 0.9
WHERE Record_Num IN (
    SELECT V.Record_Num FROM PATIENT_VISIT V
    JOIN PATIENT P ON V.P_ID = P.P_ID
    JOIN WARD W ON P.Ward_ID = W.Ward_ID
    WHERE W.Wing = 'A'
);

-- Verification
SELECT Record_Num, Total_Cost FROM MEDICAL_RECORD;
```
| Record_Num | Total_Cost (Updated) |
| :--- | :--- |
| 5001 | 40500 |
| 5002 | 10800 |

---

### Q5: Aggregation & Joins
*Find the total revenue generated by each doctor.*
```sql
SELECT S.Name, SUM(M.Total_Cost) AS Revenue
FROM STAFF S
JOIN PATIENT_VISIT V ON S.SSN = V.Doctor_SSN
JOIN MEDICAL_RECORD M ON V.Record_Num = M.Record_Num
GROUP BY S.Name;
```
| Name | Revenue |
| :--- | :--- |
| Dr. Smith | 40500 |
| Dr. Vane | 10800 |

---

### 🛡️ 4. Concept Checklist Covered
* [x] **Circular Dependency:** Department ↔ Manager SSN.
* [x] **Unary Relationship:** Staff ↔ Supervisor.
* [x] **Relational Division:** Patients vs All Pharmacy Branches.
* [x] **Set Operations:** EXCEPT used in Division query.
* [x] **Cascade Actions:** Deleting a Patient removes Visits.
* [x] **Views & CASE:** `Cardiology_Report` View.
* [x] **Nested Queries:** Used in Update and View logic.