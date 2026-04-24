CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. DEPARTMENT Table
CREATE TABLE DEPARTMENT (
    Dept_Id INT PRIMARY KEY,
    Dept_Name VARCHAR(20) NOT NULL
);

-- 2. STUDENT Table
CREATE TABLE STUDENT (
    USN VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    DOB DATE,
    Gender CHAR(1),
    Address VARCHAR(30),
    Dept_Id INT REFERENCES DEPARTMENT(Dept_Id)
);

-- 3. COURSE Table
CREATE TABLE COURSE (
    Course_Id VARCHAR(10) PRIMARY KEY,
    Course_Title VARCHAR(30) NOT NULL,
    Credits INT,
    Dept_Id INT REFERENCES DEPARTMENT(Dept_Id)
);

-- 4. GRADE_REPORT Table
CREATE TABLE GRADE_REPORT (
    USN VARCHAR(10) REFERENCES STUDENT(USN),
    Course_Id VARCHAR(10) REFERENCES COURSE(Course_Id),
    MSE1 INT,
    MSE2 INT,
    Task INT,
    SEE INT,
    Total INT,
    PRIMARY KEY (USN, Course_Id)
);

-- 5. CLASS Table
CREATE TABLE CLASS (
    Sem INT,
    Sec CHAR(1),
    USN VARCHAR(10) REFERENCES STUDENT(USN),
    PRIMARY KEY (Sem, Sec, USN)
);


-- Insert Departments
INSERT INTO DEPARTMENT VALUES (1, 'ISE'), (2, 'Computer Science'), (3, 'ECE');

-- Insert Students
INSERT INTO STUDENT VALUES ('4NM17IS001', 'Abhishek', '1999-05-20', 'M', 'Bangalore', 1);
INSERT INTO STUDENT VALUES ('4NM17IS040', 'Bhavya', '1999-11-15', 'F', 'Mangalore', 1);
INSERT INTO STUDENT VALUES ('4NM17CS020', 'Chetan', '2000-01-10', 'M', 'Udupi', 2);
INSERT INTO STUDENT VALUES ('4NM17CS021', 'Divya', '2000-03-05', 'F', 'Bangalore', 2);
INSERT INTO STUDENT VALUES ('4NM17EC001', 'Esha', '2000-07-22', 'F', 'Bangalore', 3);

-- Insert Classes
INSERT INTO CLASS VALUES (4, 'B', '4NM17IS001'), (4, 'B', '4NM17IS040');
INSERT INTO CLASS VALUES (4, 'A', '4NM17CS020'), (6, 'A', '4NM17CS021'), (4, 'A', '4NM17EC001');

-- Insert Courses
INSERT INTO COURSE VALUES ('18IS41', 'Database Management Systems', 4, 1);
INSERT INTO COURSE VALUES ('18IS42', 'DAA', 4, 1);
INSERT INTO COURSE VALUES ('CS01', 'Computer Networks', 3, 2);
INSERT INTO COURSE VALUES ('CS02', 'Operating Systems', 4, 2);
INSERT INTO COURSE VALUES ('EC03', 'Embeded Systems', 2, 3);

-- Insert Grade Reports (MSE exams data)
INSERT INTO GRADE_REPORT VALUES ('4NM17IS001', '18IS41', 25, 22, 10, 45, 102);
INSERT INTO GRADE_REPORT VALUES ('4NM17IS001', '18IS42', 28, 24, 10, 48, 110);
INSERT INTO GRADE_REPORT VALUES ('4NM17IS040', '18IS41', 20, 18, 9, 40, 87);
INSERT INTO GRADE_REPORT VALUES ('4NM17CS020', 'CS01', 15, 15, 5, 30, 65);
INSERT INTO GRADE_REPORT VALUES ('4NM17CS021', 'CS01', 22, 20, 8, 45, 95);
INSERT INTO GRADE_REPORT VALUES ('4NM17EC001', '18IS41', 0, 0, 0, 40, 40); -- No MSE taken



-- 1. Student details in 4th Semester 'B' Section

SELECT S.* FROM STUDENT S JOIN CLASS C ON S.USN = C.USN
WHERE C.Sem = 4 AND C.Sec = 'B';



-- 2. Total Male/Female students in each semester and section


SELECT C.Sem, C.Sec, S.Gender, COUNT(*) AS Total_Students
FROM STUDENT S, CLASS C WHERE S.USN = C.USN
GROUP BY C.Sem, C.Sec, S.Gender;



-- 3. View of MSE1 marks for '4NM17IS001'


CREATE VIEW Student_MSE1_View AS
SELECT USN, Course_Id, MSE1 FROM GRADE_REPORT WHERE USN = '4NM17IS001';

--- Verification
SELECT * FROM Student_MSE1_View;


-- 4. Titles of courses with 4 credits

SELECT Course_Title FROM COURSE WHERE Credits = 4;


-- 5. Students scoring more than average 'Total' in 'CS01' (Nested)

SELECT Name FROM STUDENT WHERE USN IN (
    SELECT USN FROM GRADE_REPORT 
    WHERE Course_Id = 'CS01' AND Total > (SELECT AVG(Total) FROM GRADE_REPORT WHERE Course_Id = 'CS01')
);


-- 6. Students in 'Computer Science' department (Nested)


SELECT Name FROM STUDENT 
WHERE Dept_Id = (SELECT Dept_Id FROM DEPARTMENT WHERE Dept_Name = 'Computer Science');


-- 7. Students with Max 'Total' in 'Database Management Systems'

SELECT S.Name FROM STUDENT S JOIN GRADE_REPORT G ON S.USN = G.USN
WHERE G.Course_Id = (SELECT Course_Id FROM COURSE WHERE Course_Title = 'Database Management Systems')
AND G.Total = (SELECT MAX(Total) FROM GRADE_REPORT WHERE Course_Id = (SELECT Course_Id FROM COURSE WHERE Course_Title = 'Database Management Systems'));


--- 8. Students with highest total marks in each semester (JOIN)


SELECT C.Sem, S.Name, G.Total
FROM STUDENT S 
JOIN CLASS C ON S.USN = C.USN 
JOIN GRADE_REPORT G ON S.USN = G.USN
JOIN (SELECT Sem, MAX(Total) as MaxTotal FROM CLASS C1 JOIN GRADE_REPORT G1 ON C1.USN = G1.USN GROUP BY Sem) AS MaxTable
ON C.Sem = MaxTable.Sem AND G.Total = MaxTable.MaxTotal;



-- 9. Students who have not taken any MSE exams


SELECT Name FROM STUDENT WHERE USN IN (
    SELECT USN FROM GRADE_REPORT WHERE (MSE1 = 0 OR MSE1 IS NULL) AND (MSE2 = 0 OR MSE2 IS NULL)
);




--- 10. Students who have taken MSE in all subjects of their semester (NOT EXISTS)


SELECT S.Name FROM STUDENT S
WHERE NOT EXISTS (
    SELECT C.Course_Id FROM COURSE C 
    JOIN DEPARTMENT D ON C.Dept_Id = D.Dept_Id 
    WHERE D.Dept_Id = S.Dept_Id
    EXCEPT
    SELECT G.Course_Id FROM GRADE_REPORT G WHERE G.USN = S.USN AND G.MSE1 > 0
);



