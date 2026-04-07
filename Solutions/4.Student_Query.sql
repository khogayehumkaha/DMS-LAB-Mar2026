-- Query 1: Add a new textbook to the database and adopt it for a course
-- (Note: These are two separate steps usually required in the lab)
INSERT INTO TEXTBOOK VALUES (106, 'Database Systems', 'Pearson', 'Elmasri');
INSERT INTO BOOK_ADOPTION VALUES (1, 5, 106);


-- Query 2: List textbooks for a specific department (e.g., 'CS') 
-- where the course uses more than 2 books.
SELECT DISTINCT T.book_id, T.book_title
FROM TEXTBOOK T, BOOK_ADOPTION B, COURSE C
WHERE T.book_id = B.book_id
  AND B.course_no = C.course_no
  AND C.dept = 'CS'
  AND (SELECT COUNT(B2.book_id) 
       FROM BOOK_ADOPTION B2 
       WHERE B2.course_no = C.course_no) > 2;


-- Query 3: List departments where ALL courses use textbooks from a specific publisher
-- (e.g., 'Pearson')
SELECT DISTINCT dept
FROM COURSE
WHERE dept NOT IN (
    SELECT C.dept 
    FROM COURSE C, BOOK_ADOPTION B, TEXTBOOK T
    WHERE C.course_no = B.course_no 
      AND B.book_id = T.book_id
      AND T.publisher != 'Pearson'
);


-- Query 4: List students who have enrolled in the maximum number of courses
SELECT S.name
FROM STUDENT S, ENROLL E
WHERE S.regno = E.regno
GROUP BY S.regno, S.name
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*) 
    FROM ENROLL 
    GROUP BY regno
);


-- Query 5: List students who have not enrolled in any course
SELECT name 
FROM STUDENT 
WHERE regno NOT IN (SELECT regno FROM ENROLL);