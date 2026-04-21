-- Query 1: Retrieve details of all books (ID, Title, Publisher, Author, Copies per branch)
SELECT B.BOOK_ID, B.TITLE, B.PUBLISHER_NAME, A.AUTHOR_NAME, C.NO_OF_COPIES, L.BRANCH_ID
FROM BOOK B, BOOK_AUTHORS A, BOOK_COPIES C, LIBRARY_BRANCH L
WHERE B.BOOK_ID = A.BOOK_ID 
  AND B.BOOK_ID = C.BOOK_ID 
  AND L.BRANCH_ID = C.BRANCH_ID;


-- Query 2: Get particulars of borrowers who have borrowed more than 3 books from Jan 2017 to Jun 2017
SELECT CARD_NO
FROM BOOK_LENDING
WHERE DATE_OUT BETWEEN '2017-01-01' AND '2017-06-01'
GROUP BY CARD_NO
HAVING COUNT(*) > 3;


-- Query 3: Delete a book in the BOOK table. (Confirm CASCADE action deletes related records)
DELETE FROM BOOK WHERE BOOK_ID = 101;


-- Query 4: Partition the BOOK table based on release year and show it in a View
-- (Note: Standard SQL view to categorize by year)
CREATE VIEW BOOKS_BY_YEAR AS
SELECT PUB_YEAR, COUNT(BOOK_ID) AS TOTAL_BOOKS
FROM BOOK
GROUP BY PUB_YEAR;


SELECT * FROM BOOKS_BY_YEAR;


-- Query 5: Create a View of all books and its number of copies currently available in branches
CREATE VIEW BOOK_INVENTORY AS
SELECT B.TITLE, C.NO_OF_COPIES, L.BRANCH_NAME
FROM BOOK B, BOOK_COPIES C, LIBRARY_BRANCH L
WHERE B.BOOK_ID = C.BOOK_ID AND L.BRANCH_ID = C.BRANCH_ID;

SELECT * FROM BOOK_INVENTORY;