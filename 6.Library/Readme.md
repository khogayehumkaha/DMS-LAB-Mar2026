
# Library Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema manages the core library entities. It uses `ON DELETE CASCADE` to ensure that when a book is removed, all associated author records, copies, and lending logs are automatically deleted.

```sql
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- 1. PUBLISHER Table
CREATE TABLE PUBLISHER (
    NAME VARCHAR(20) PRIMARY KEY,
    ADDRESS VARCHAR(30),
    PHONE VARCHAR(10)
);

-- 2. BOOK Table
CREATE TABLE BOOK (
    BOOK_ID INT PRIMARY KEY,
    TITLE VARCHAR(30),
    PUBLISHER_NAME VARCHAR(20) REFERENCES PUBLISHER(NAME) ON DELETE CASCADE,
    PUB_YEAR INT
);

-- 3. BOOK_AUTHORS Table
CREATE TABLE BOOK_AUTHORS (
    BOOK_ID INT REFERENCES BOOK(BOOK_ID) ON DELETE CASCADE,
    AUTHOR_NAME VARCHAR(20),
    PRIMARY KEY (BOOK_ID, AUTHOR_NAME)
);

-- 4. LIBRARY_BRANCH Table
CREATE TABLE LIBRARY_BRANCH (
    BRANCH_ID INT PRIMARY KEY,
    BRANCH_NAME VARCHAR(20),
    ADDRESS VARCHAR(30)
);

-- 5. BOOK_COPIES Table
CREATE TABLE BOOK_COPIES (
    BOOK_ID INT REFERENCES BOOK(BOOK_ID) ON DELETE CASCADE,
    BRANCH_ID INT REFERENCES LIBRARY_BRANCH(BRANCH_ID) ON DELETE CASCADE,
    NO_OF_COPIES INT,
    PRIMARY KEY (BOOK_ID, BRANCH_ID)
);

-- 6. CARD Table
CREATE TABLE CARD (
    CARD_NO INT PRIMARY KEY
);

-- 7. BOOK_LENDING Table
CREATE TABLE BOOK_LENDING (
    BOOK_ID INT REFERENCES BOOK(BOOK_ID) ON DELETE CASCADE,
    BRANCH_ID INT REFERENCES LIBRARY_BRANCH(BRANCH_ID) ON DELETE CASCADE,
    CARD_NO INT REFERENCES CARD(CARD_NO) ON DELETE CASCADE,
    DATE_OUT DATE,
    DUE_DATE DATE,
    PRIMARY KEY (BOOK_ID, BRANCH_ID, CARD_NO)
);
```

---

## 📊 2. Optimized Data Insertion
These statements populate the database so that **Card 101** satisfies the "more than 3 books" query and the partition query shows a spread of years.

```sql
-- Insert Publishers
INSERT INTO PUBLISHER VALUES ('Pearson', 'London', '9876543210'), 
                             ('McGraw', 'New York', '8887776660');

-- Insert Books
INSERT INTO BOOK VALUES (1, 'DBMS', 'Pearson', 2017),
                        (2, 'OS', 'Pearson', 2016),
                        (3, 'Networks', 'McGraw', 2017),
                        (4, 'Java', 'McGraw', 2018);

-- Insert Authors
INSERT INTO BOOK_AUTHORS VALUES (1, 'Navathe'), (2, 'Silberschatz'), 
                                (3, 'Tanenbaum'), (4, 'Herbert');

-- Insert Branches
INSERT INTO LIBRARY_BRANCH VALUES (10, 'Main Branch', 'Bangalore'), 
                                  (20, 'North Branch', 'Mangalore');

-- Insert Copies
INSERT INTO BOOK_COPIES VALUES (1, 10, 5), (2, 10, 2), 
                               (3, 20, 7), (4, 20, 3);

-- Insert Cards and Lending Data
INSERT INTO CARD VALUES (101), (102);

-- Card 101 borrows 4 books between Jan-June 2017
INSERT INTO BOOK_LENDING VALUES (1, 10, 101, '2017-01-10', '2017-01-25'),
                                (2, 10, 101, '2017-02-15', '2017-03-01'),
                                (3, 20, 101, '2017-04-12', '2017-04-27'),
                                (4, 20, 101, '2017-05-05', '2017-05-20');
```

---

## 🔍 3. SQL Queries and Results

### Query 1: Retrieve details of all books (ID, Title, Publisher, Author, Copies per branch)
```sql
SELECT B.BOOK_ID, B.TITLE, B.PUBLISHER_NAME, A.AUTHOR_NAME, C.NO_OF_COPIES, L.BRANCH_NAME
FROM BOOK B, BOOK_AUTHORS A, BOOK_COPIES C, LIBRARY_BRANCH L
WHERE B.BOOK_ID = A.BOOK_ID 
  AND B.BOOK_ID = C.BOOK_ID 
  AND L.BRANCH_ID = C.BRANCH_ID;
```
**Output:**
| BOOK_ID | TITLE | PUBLISHER_NAME | AUTHOR_NAME | NO_OF_COPIES | BRANCH_NAME |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | DBMS | Pearson | Navathe | 5 | Main Branch |
| 2 | OS | Pearson | Silberschatz | 2 | Main Branch |
| 3 | Networks | McGraw | Tanenbaum | 7 | North Branch |
| 4 | Java | McGraw | Herbert | 3 | North Branch |

---

### Query 2: Borrowers who borrowed > 3 books from Jan 2017 to Jun 2017
```sql
SELECT CARD_NO 
FROM BOOK_LENDING
WHERE DATE_OUT BETWEEN '2017-01-01' AND '2017-06-30'
GROUP BY CARD_NO
HAVING COUNT(*) > 3;
```
**Output:**
| CARD_NO |
| :--- |
| 101 |

---

### Query 3: Delete a book and confirm CASCADE
```sql
-- Delete 'DBMS' (ID 1)
DELETE FROM BOOK WHERE BOOK_ID = 1;

-- Verification: Check BOOK_AUTHORS (Should be empty for ID 1)
SELECT * FROM BOOK_AUTHORS WHERE BOOK_ID = 1;
```
**Output:**
| BOOK_ID | AUTHOR_NAME |
| :--- | :--- |
| *(Empty)* | |

---

### Query 4: View partitioning BOOKS by year
```sql
CREATE VIEW Book_Year_Partition AS
SELECT PUB_YEAR, COUNT(BOOK_ID) AS Total_Books
FROM BOOK
GROUP BY PUB_YEAR;

-- Verification 
SELECT * FROM Book_Year_Partition;
```
**Output:**
| PUB_YEAR | Total_Books |
| :--- | :--- |
| 2016 | 1 |
| 2017 | 1 |
| 2018 | 1 |

---

### Query 5: View of all books and available copies
```sql
CREATE VIEW Available_Copies_View AS
SELECT B.TITLE, L.BRANCH_NAME, C.NO_OF_COPIES
FROM BOOK B, BOOK_COPIES C, LIBRARY_BRANCH L
WHERE B.BOOK_ID = C.BOOK_ID AND C.BRANCH_ID = L.BRANCH_ID;

-- Verification 

SELECT * FROM Available_Copies_View;
```
**Output:**
| TITLE | BRANCH_NAME | NO_OF_COPIES |
| :--- | :--- | :--- |
| OS | Main Branch | 2 |
| Networks | North Branch | 7 |
| Java | North Branch | 3 |