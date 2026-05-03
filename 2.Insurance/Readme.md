
# Insurance Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema manages drivers, their vehicles, and accident participation records.

```sql
CREATE DATABASE InsuranceDB;
USE InsuranceDB;

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
*Data is structured to include Chicago residents and specific 2008 accident stats.*

```sql
-- Insert People (Including Chicago for Q6)
INSERT INTO PERSON VALUES ('D111', 'Nithin', 'Udupi'),
                          ('D222', 'Akash', 'Mangalore'),
                          ('D333', 'Smitha', 'Bangalore'),
                          ('D444', 'Rahul', 'Chicago'),
                          ('D555', 'John', 'Chicago');

-- Insert Cars (Mixed models, including no-accident car KA06)
INSERT INTO CAR VALUES ('KA01', 'Toyota', 2015),
                      ('KA02', 'Honda', 2018),
                      ('KA03', 'Toyota', 2020),
                      ('KA04', 'Toyota', 2019),
                      ('KA05', 'Toyota', 2021),
                      ('KA06', 'Ford', 2022);

-- Insert Accidents (2008 focus)
INSERT INTO ACCIDENT VALUES (1001, '2008-05-12', 'MG Road'),
                            (1002, '2008-08-20', 'Manipal'),
                            (1003, '2008-12-01', 'Highway');

-- Establish Ownership
INSERT INTO OWNS VALUES ('D111', 'KA01'), ('D222', 'KA02'), 
                        ('D333', 'KA03'), ('D333', 'KA04'), 
                        ('D333', 'KA05'), ('D444', 'KA06');

-- Record Participation (Avg damage = 15,000)
INSERT INTO PARTICIPATED VALUES ('D111', 'KA01', 1001, 5000), 
                                ('D333', 'KA03', 1002, 25000),
                                ('D333', 'KA03', 1003, 15000);
```

---

## 🔍 3. Queries and Results

### 1. List the names of people who owned cars that were involved in accidents in 2008.  
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

### 2.  Find the name of owner and his car that has maximum number of accidents in 2008
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

### 3. List the name of owners who own at least two TOYOTA cars. 

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

### 4. List the name of the owner who owns maximum TOYOTA cars.

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

### 5. Find the name of owner who owns cars having minimum damage amount for accidents in 2008 

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

---

### 6. Find the names of drivers who live in 'Chicago'. 

```sql
SELECT D_NAME FROM PERSON WHERE ADDR = 'Chicago';
```
**Output:**
| D_NAME |
| :--- |
| Rahul |
| John |

---

### 7. List the names of people who have been involved in an accident  using nested query

```sql
SELECT D_NAME FROM PERSON 
WHERE D_ID IN (SELECT D_ID FROM PARTICIPATED);
```
**Output:**
| D_NAME |
| :--- |
| Nithin |
| Smitha |

---

### 8. List the cars that have never been involved in an accident. using nested query

```sql
SELECT REG_NO, MODEL FROM CAR 
WHERE REG_NO NOT IN (SELECT REG_NO FROM PARTICIPATED);
```
**Output:**
| REG_NO | MODEL |
| :--- | :--- |
| KA02 | Honda |
| KA04 | Toyota |
| KA05 | Toyota |
| KA06 | Ford |

---

### 9. Find the names of persons who own at least one car that has a damage amount greater than the average damage amount of all accidents  using nested query
*(Average damage is 15,000; Smitha has 25,000)*
```sql
SELECT DISTINCT D_NAME FROM PERSON 
WHERE D_ID IN (
    SELECT D_ID FROM PARTICIPATED 
    WHERE DAM_AMOUNT > (SELECT AVG(DAM_AMOUNT) FROM PARTICIPATED)
);
```
**Output:**
| D_NAME |
| :--- |
| Smitha |


---

### 10.  Create a view to display the owner name and registration number for only those cars that were involved in more than one accident.
```sql
CREATE VIEW Multi_Accident_Cars AS
SELECT pr.D_NAME, p.REG_NO, COUNT(*) AS Total_Accidents
FROM PERSON pr
JOIN PARTICIPATED p ON pr.D_ID = p.D_ID
GROUP BY pr.D_NAME, p.REG_NO
HAVING COUNT(*) > 1;

-- To View:
SELECT * FROM Multi_Accident_Cars;
```
**Output Table:**
| D_NAME | REG_NO | Total_Accidents |
| :--- | :--- | :--- |
| Smitha | KA03 | 2 |

---


### 11. Create a view to display the person name, car model, accident date, and damage amount for all cars involved in accidents.
```sql
CREATE VIEW Accident_Summary_View AS
SELECT pr.D_NAME, c.MODEL, a.ACC_DATE, p.DAM_AMOUNT
FROM PERSON pr
JOIN PARTICIPATED p ON pr.D_ID = p.D_ID
JOIN CAR c ON p.REG_NO = c.REG_NO
JOIN ACCIDENT a ON p.REPORT_NUM = a.REPORT_NUM;

-- To View:
SELECT * FROM Accident_Summary_View;
```
**Output Table:**
| D_NAME | MODEL | ACC_DATE | DAM_AMOUNT |
| :--- | :--- | :--- | :--- |
| Nithin | Toyota | 2008-05-12 | 5000 |
| Smitha | Toyota | 2008-08-20 | 25000 |
| Smitha | Toyota | 2008-12-01 | 15000 |

---


### 
