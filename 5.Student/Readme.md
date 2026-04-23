

# Student Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema manages academic records, including departments, courses, and grade reports. We create the `Department` table first to ensure foreign key constraints are met.

```sql
CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. DEPARTMENT Table
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(20) NOT NULL
);

-- 2. STUDENT Table
CREATE TABLE Student (
    usn VARCHAR(10) PRIMARY KEY,
    s_name VARCHAR(15) NOT NULL,
    dept_id INT REFERENCES Department(dept_id),
    dob DATE,
    gender CHAR(1)
);

-- 3. COURSE Table
CREATE TABLE Course (
    course_id VARCHAR(10) PRIMARY KEY,
    course_title VARCHAR(20) NOT NULL,
    credits INT,
    dept_id INT REFERENCES Department(dept_id)
);

-- 4. GRADE_REPORT Table
CREATE TABLE Grade_report (
    usn VARCHAR(10) REFERENCES Student(usn),
    course_id VARCHAR(10) REFERENCES Course(course_id),
    mse1 INT,
    mse2 INT,
    task INT,
    see INT,
    total INT,
    PRIMARY KEY (usn, course_id)
);

-- 5. CLASS Table
CREATE TABLE Class (
    usn VARCHAR(10) REFERENCES Student(usn),
    sem INT NOT NULL,
    sec CHAR(1) NOT NULL,
    PRIMARY KEY(usn, sem, sec)
);
```

---

## 📊 2. Optimized Data Insertion
The data is tailored so that Query 1 finds students in **4th Sem 'B'** and Query 3 works for the specific USN.

```sql
-- Insert Departments
INSERT INTO Department VALUES (1, 'ISE'), (2, 'CSE'), (3, 'ECE');

-- Insert Students
INSERT INTO Student VALUES ('4NM17IS001', 'Abhishek', 1, '1999-05-20', 'M');
INSERT INTO Student VALUES ('4NM17IS040', 'Bhavya', 1, '1999-11-15', 'F');
INSERT INTO Student VALUES ('4NM17CS020', 'Chetan', 2, '2000-01-10', 'M');

-- Insert Classes (Setting up 4th Sem, B Section)
INSERT INTO Class VALUES ('4NM17IS001', 4, 'B');
INSERT INTO Class VALUES ('4NM17IS040', 4, 'B');
INSERT INTO Class VALUES ('4NM17CS020', 4, 'A');

-- Insert Courses
INSERT INTO Course VALUES ('18IS41', 'DBMS', 4, 1);
INSERT INTO Course VALUES ('18IS42', 'DAA', 4, 1);

-- Insert Grade Reports
INSERT INTO Grade_report VALUES ('4NM17IS001', '18IS41', 25, 22, 10, 45, 102);
INSERT INTO Grade_report VALUES ('4NM17IS001', '18IS42', 28, 24, 10, 48, 110);
INSERT INTO Grade_report VALUES ('4NM17IS040', '18IS41', 20, 18, 9, 40, 87);
```

---

## 🔍 3. SQL Queries and Results

### Query 1: List student details studying in 4th Semester ‘B’ section.
```sql
SELECT S.* FROM Student S, Class C 
WHERE S.usn = C.usn AND C.sem = 4 AND C.sec = 'B';
```
**Output:**
| usn | s_name | dept_id | dob | gender |
| :--- | :--- | :--- | :--- | :--- |
| 4NM17IS001 | Abhishek | 1 | 1999-05-20 | M |
| 4NM17IS040 | Bhavya | 1 | 1999-11-15 | F |

---

### Query 2: Total number of male and female students in each semester and section.
```sql
SELECT C.sem, C.sec, S.gender, COUNT(*) AS Total_Students
FROM Student S, Class C
WHERE S.usn = C.usn
GROUP BY C.sem, C.sec, S.gender
ORDER BY C.sem, C.sec;
```
**Output:**
| sem | sec | gender | Total_Students |
| :--- | :--- | :--- | :--- |
| 4 | A | M | 1 |
| 4 | B | F | 1 |
| 4 | B | M | 1 |

---

### Query 3: Create a view of MSE1 marks of student USN ‘4NM17IS001’ in all subjects.
```sql
CREATE VIEW Student_MSE1_View AS
SELECT usn, course_id, mse1 
FROM Grade_report 
WHERE usn = '4NM17IS001';

-- To view the result:
SELECT * FROM Student_MSE1_View;
```
**Output:**
| usn | course_id | mse1 |
| :--- | :--- | :--- |
| 4NM17IS001 | 18IS41 | 25 |
| 4NM17IS001 | 18IS42 | 28 |