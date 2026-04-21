-- 1. STUDENT Table
CREATE TABLE STUDENT (
    regno VARCHAR(15) PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    major VARCHAR(20),
    bdate DATE
);


-- 2. COURSE Table
CREATE TABLE COURSE (
    course_no INT PRIMARY KEY,
    cname VARCHAR(25),
    dept VARCHAR(20)
);


-- 3. ENROLL Table (Student-Course relationship)
CREATE TABLE ENROLL (
    regno VARCHAR(15) REFERENCES STUDENT(regno),
    course_no INT REFERENCES COURSE(course_no),
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course_no, sem)
);


-- 4. TEXTBOOK Table
CREATE TABLE TEXTBOOK (
    book_id INT PRIMARY KEY,
    book_title VARCHAR(40),
    publisher VARCHAR(25),
    author VARCHAR(25)
);


-- 5. BOOK_ADOPTION Table (Course-Textbook relationship)
CREATE TABLE BOOK_ADOPTION (
    course_no INT REFERENCES COURSE(course_no),
    sem INT,
    book_id INT REFERENCES TEXTBOOK(book_id),
    PRIMARY KEY (course_no, sem, book_id)
);