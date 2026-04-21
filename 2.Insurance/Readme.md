

# Insurance Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema defines the structure for managing driver information, car registrations, and accident records.

```sql
CREATE DATABASE Insurance;
USE Insurance;

-- 1. PERSON Table
CREATE TABLE PERSON (
    D_ID VARCHAR(10) PRIMARY KEY,
    D_NAME VARCHAR(25) NOT NULL,
    ADDR VARCHAR(30)
);

-- 2. CAR Table
CREATE TABLE CAR (
    REG_NO VARCHAR(10) PRIMARY KEY,
    MODEL VARCHAR(10) NOT NULL,
    YEAR INT 
);

-- 3. ACCIDENT Table
CREATE TABLE ACCIDENT (
    REPORT_NUM INT PRIMARY KEY,
    ACC_DATE DATE,
    ACC_LOC VARCHAR(30)
);

-- 4. OWNS Table
CREATE TABLE OWNS (
    D_ID VARCHAR(10) REFERENCES PERSON(D_ID),
    REG_NO VARCHAR(10) REFERENCES CAR(REG_NO),
    PRIMARY KEY(D_ID, REG_NO)
);

-- 5. PARTICIPATED Table
CREATE TABLE PARTICIPATED (
    D_ID VARCHAR(10) REFERENCES PERSON(D_ID),
    REG_NO VARCHAR(10) REFERENCES CAR(REG_NO),
    REPORT_NUM INT REFERENCES ACCIDENT(REPORT_NUM),
    DAM_AMOUNT INT,
    PRIMARY KEY (D_ID, REG_NO, REPORT_NUM)
);
```

---

## 📊 2. Optimized Data Insertion
The following data ensures that **Smitha** satisfies the "Maximum Accidents" and "Maximum Toyota Cars" logic for the queries.

```sql
-- Insert People
INSERT INTO PERSON VALUES ('D111', 'Nithin', 'Udupi');
INSERT INTO PERSON VALUES ('D222', 'Akash', 'Mangalore');
INSERT INTO PERSON VALUES ('D333', 'Smitha', 'Bangalore');
INSERT INTO PERSON VALUES ('D444', 'Rahul', 'Udupi');

-- Insert Cars (Mixed models, multiple Toyotas)
INSERT INTO CAR VALUES ('KA01', 'Toyota', 2015);
INSERT INTO CAR VALUES ('KA02', 'Honda', 2018);
INSERT INTO CAR VALUES ('KA03', 'Toyota', 2020);
INSERT INTO CAR VALUES ('KA04', 'Toyota', 2019);
INSERT INTO CAR VALUES ('KA05', 'Toyota', 2021);

-- Insert Accidents (Focus on 2008)
INSERT INTO ACCIDENT VALUES (1001, '2008-05-12', 'MG Road');
INSERT INTO ACCIDENT VALUES (1002, '2008-08-20', 'Manipal');
INSERT INTO ACCIDENT VALUES (1003, '2008-12-01', 'Highway');

-- Establish Ownership
INSERT INTO OWNS VALUES ('D111', 'KA01');
INSERT INTO OWNS VALUES ('D222', 'KA02');
INSERT INTO OWNS VALUES ('D333', 'KA03');
INSERT INTO OWNS VALUES ('D333', 'KA04');
INSERT INTO OWNS VALUES ('D333', 'KA05');

-- Record Participation
-- Nithin: 1 Accident
INSERT INTO PARTICIPATED VALUES ('D111', 'KA01', 1001, 5000); 

-- Smitha: 2 Accidents (Ensures Smitha is the result for Query 2)
INSERT INTO PARTICIPATED VALUES ('D333', 'KA03', 1002, 25000);
INSERT INTO PARTICIPATED VALUES ('D333', 'KA03', 1003, 15000); 
```

---

## 🔍 3. SQL Queries and Results

### Query 1: Names of people involved in accidents in 2008
```sql
SELECT DISTINCT pr.D_NAME
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%';
```
**Output:**
| D_NAME |
| :--- |
| Nithin |
| Smitha |

---

### Query 2: Owner and car with maximum number of accidents in 2008
```sql
SELECT TOP 1 pr.D_NAME, p.REG_NO, COUNT(*) AS Acc_Count
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%'
GROUP BY pr.D_NAME, p.REG_NO
ORDER BY Acc_Count DESC;
```
**Output:**
| D_NAME | REG_NO | Acc_Count |
| :--- | :--- | :--- |
| Smitha | KA03 | 2 |

---

### Query 3: Owners who own at least two TOYOTA cars
```sql
SELECT pr.D_NAME
FROM PERSON pr, OWNS o, CAR c
WHERE pr.D_ID = o.D_ID AND o.REG_NO = c.REG_NO
AND c.MODEL = 'Toyota'
GROUP BY pr.D_NAME
HAVING COUNT(*) >= 2;
```
**Output:**
| D_NAME |
| :--- |
| Smitha |

---

### Query 4: Owner who owns maximum TOYOTA cars
```sql
SELECT TOP 1 pr.D_NAME, COUNT(*) AS Toyota_Count
FROM PERSON pr, OWNS o, CAR c
WHERE pr.D_ID = o.D_ID AND o.REG_NO = c.REG_NO
AND c.MODEL = 'Toyota'
GROUP BY pr.D_NAME
ORDER BY Toyota_Count DESC;
```
**Output:**
| D_NAME | Toyota_Count |
| :--- | :--- |
| Smitha | 3 |

---

### Query 5: Owner with minimum damage amount in 2008
```sql
SELECT TOP 1 pr.D_NAME, p.DAM_AMOUNT
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%'
ORDER BY p.DAM_AMOUNT ASC;
```
**Output:**
| D_NAME | DAM_AMOUNT |
| :--- | :--- |
| Nithin | 5000 |