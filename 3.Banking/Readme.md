
# Banking Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema uses `ON DELETE CASCADE` to maintain referential integrity across the banking system.

```sql
CREATE DATABASE Banking;
USE Banking;

-- 1. BRANCH Table
CREATE TABLE Branch (
    bname VARCHAR(15) PRIMARY KEY,
    bcity VARCHAR(15),
    assets REAL
);

-- 2. ACCOUNT Table
CREATE TABLE Account (
    accno INT PRIMARY KEY,
    bname VARCHAR(15) DEFAULT 'Main',
    balance REAL,
    FOREIGN KEY(bname) REFERENCES Branch(bname) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. CUSTOMER Table
CREATE TABLE Customer (
    cname VARCHAR(20) PRIMARY KEY,
    cstreet VARCHAR(25),
    ccity VARCHAR(20)
);

-- 4. LOAN Table
CREATE TABLE Loan (
    loan_no INT PRIMARY KEY,
    bname VARCHAR(15),
    amount REAL,
    FOREIGN KEY(bname) REFERENCES Branch(bname) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. BORROWER Table
CREATE TABLE Borrower (
    cname VARCHAR(20),
    loan_no INT PRIMARY KEY,
    FOREIGN KEY(cname) REFERENCES Customer(cname) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(loan_no) REFERENCES Loan(loan_no) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. DEPOSITOR Table
CREATE TABLE Depositor (
    cname VARCHAR(20),
    accno INT PRIMARY KEY,
    FOREIGN KEY(accno) REFERENCES Account(accno) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(cname) REFERENCES Customer(cname) ON DELETE CASCADE ON UPDATE CASCADE
);
```

---

## 📊 2. Optimized Data Insertion
*Fixed: Every account number (`accno`) is unique in the Depositor table to avoid Primary Key violations.*

```sql
-- Insert Branches
INSERT INTO Branch VALUES ('Main', 'Bangalore', 500000);
INSERT INTO Branch VALUES ('Indiranagar', 'Bangalore', 200000);
INSERT INTO Branch VALUES ('Udupi_Main', 'Udupi', 300000);

-- Insert Customers
INSERT INTO Customer VALUES ('Avinash', 'Bull Temple Road', 'Bangalore');
INSERT INTO Customer VALUES ('Dinesh', 'Bannerghatta Road', 'Bangalore');
INSERT INTO Customer VALUES ('Nikil', 'Manipal Ave', 'Udupi');

-- Insert Accounts
INSERT INTO Account VALUES (101, 'Main', 5000);
INSERT INTO Account VALUES (102, 'Main', 10000);
INSERT INTO Account VALUES (103, 'Indiranagar', 2000);
INSERT INTO Account VALUES (104, 'Udupi_Main', 8000);
INSERT INTO Account VALUES (105, 'Main', 7000);

-- Insert Depositors (Linking Customers to Unique Accounts)
INSERT INTO Depositor VALUES ('Avinash', 101); -- Avinash Account 1 at Main
INSERT INTO Depositor VALUES ('Avinash', 102); -- Avinash Account 2 at Main
INSERT INTO Depositor VALUES ('Avinash', 103); -- Avinash Account at Indiranagar
INSERT INTO Depositor VALUES ('Dinesh', 105);  -- Dinesh Account at Main (Used 105 instead of 101)
INSERT INTO Depositor VALUES ('Nikil', 104);

-- Insert Loans
INSERT INTO Loan VALUES (501, 'Main', 50000);
INSERT INTO Borrower VALUES ('Avinash', 501);
```

---

## 🔍 3. SQL Queries and Results

### Query 1: Customers with at least two accounts at the 'Main' branch.
```sql
SELECT d.cname 
FROM Depositor d, Account a
WHERE d.accno = a.accno AND a.bname = 'Main'
GROUP BY d.cname
HAVING COUNT(*) >= 2;
```
**Output:**
| cname |
| :--- |
| Avinash |

---

### Query 2: Customers who have an account at ALL branches in 'Bangalore'.
```sql
SELECT d.cname FROM Depositor d
WHERE NOT EXISTS (
    (SELECT bname FROM Branch WHERE bcity = 'Bangalore')
    EXCEPT
    (SELECT a.bname FROM Account a, Depositor d2 
     WHERE a.accno = d2.accno AND d2.cname = d.cname)
)
GROUP BY d.cname;
```
**Output:**
| cname |
| :--- |
| Avinash |

---

### Query 3: Customers with accounts in at least 2 branches in 'Bangalore'.
```sql
SELECT d.cname
FROM Depositor d, Account a, Branch b
WHERE d.accno = a.accno AND a.bname = b.bname AND b.bcity = 'Bangalore'
GROUP BY d.cname
HAVING COUNT(DISTINCT a.bname) >= 2;
```
**Output:**
| cname |
| :--- |
| Avinash |

---

### Query 4: Customers who borrowed a loan from at least one branch in 'Bangalore'.
```sql
SELECT DISTINCT cname
FROM Borrower br, Loan l, Branch b
WHERE br.loan_no = l.loan_no AND l.bname = b.bname AND b.bcity = 'Bangalore';
```
**Output:**
| cname |
| :--- |
| Avinash |

---

### Query 5: Branch name with maximum number of customers in 'Bangalore'.
```sql
SELECT TOP 1 b.bname, COUNT(DISTINCT d.cname) AS Customer_Count
FROM Branch b, Account a, Depositor d
WHERE b.bname = a.bname AND a.accno = d.accno AND b.bcity = 'Bangalore'
GROUP BY b.bname
ORDER BY Customer_Count DESC;
```
**Output:**
| bname | Customer_Count |
| :--- | :--- |
| Main | 2 | 
*(Note: Avinash and Dinesh both have accounts at Main)*