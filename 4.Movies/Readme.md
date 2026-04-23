

# Movie Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema defines actors, directors, movies, casting roles, and viewer ratings.

```sql
CREATE DATABASE Movie;
USE Movie;

-- 1. ACTOR Table
CREATE TABLE ACTOR (
    ACT_ID INT PRIMARY KEY,
    ACT_NAME VARCHAR(30),
    ACT_GENDER CHAR(1) CHECK (ACT_GENDER IN('M','F'))
);

-- 2. DIRECTOR Table
CREATE TABLE DIRECTOR (
    DIR_ID INT PRIMARY KEY,
    DIR_NAME VARCHAR(25),
    DIR_PHONE BIGINT -- Use BIGINT for phone numbers
);

-- 3. MOVIES Table
CREATE TABLE MOVIES (
    MOV_ID INT PRIMARY KEY,
    MOV_TITLE VARCHAR(50),
    MOV_YEAR INT,
    MOV_LANG VARCHAR(20),
    DIR_ID INT REFERENCES DIRECTOR(DIR_ID),
    UNIQUE(MOV_TITLE)
);

-- 4. MOVIE_CAST Table
CREATE TABLE MOVIE_CAST (
    ACT_ID INT REFERENCES ACTOR(ACT_ID),
    MOV_ID INT REFERENCES MOVIES(MOV_ID),
    ROLE VARCHAR(20),
    PRIMARY KEY(ACT_ID, MOV_ID)
);

-- 5. VIEWER Table
CREATE TABLE VIEWER (
    VIEW_ID INT PRIMARY KEY,
    VIEW_NAME VARCHAR(25),
    AGE INT,
    VIEW_GENDER CHAR(1) CHECK (VIEW_GENDER IN('F','M'))
);

-- 6. RATINGS Table
CREATE TABLE RATINGS (
    VIEW_ID INT REFERENCES VIEWER(VIEW_ID),
    MOV_ID INT REFERENCES MOVIES(MOV_ID),
    STARS INT CHECK(STARS>=0 AND STARS<=5),
    PRIMARY KEY(VIEW_ID, MOV_ID)
);
```

---

## 📊 2. Optimized Data Insertion
Data is structured so that **Anil Kapoor** satisfies Query 1 and **Subhash Ghai** satisfies Query 3.

```sql
-- Insert Actors
INSERT INTO ACTOR VALUES (101, 'Anil Kapoor', 'M');
INSERT INTO ACTOR VALUES (102, 'Sridevi', 'F');
INSERT INTO ACTOR VALUES (103, 'Hrithik Roshan', 'M');

-- Insert Directors
INSERT INTO DIRECTOR VALUES (201, 'Subhash Ghai', 9888877777);
INSERT INTO DIRECTOR VALUES (202, 'Christopher Nolan', 9111122222);

-- Insert Movies
INSERT INTO MOVIES VALUES (501, 'Ram Lakhan', 1989, 'Hindi', 201);
INSERT INTO MOVIES VALUES (502, 'Race 3', 2018, 'Hindi', 201); -- Subhash Ghai movie
INSERT INTO MOVIES VALUES (503, 'Inception', 2010, 'English', 202);

-- Insert Movie Cast (Anil Kapoor in 1989 and 2018 movies)
INSERT INTO MOVIE_CAST VALUES (101, 501, 'Lakhan');
INSERT INTO MOVIE_CAST VALUES (101, 502, 'Robert');
INSERT INTO MOVIE_CAST VALUES (102, 501, 'Radha');

-- Insert Viewers
INSERT INTO VIEWER VALUES (1, 'Rahul', 25, 'M');
INSERT INTO VIEWER VALUES (2, 'Anjali', 22, 'F');

-- Insert Ratings
INSERT INTO RATINGS VALUES (1, 501, 4);
INSERT INTO RATINGS VALUES (2, 501, 2);
INSERT INTO RATINGS VALUES (1, 503, 5);
```

---

## 🔍 3. SQL Queries and Results

### Query 1: List all actors who acted in a movie before 2000 and also in a movie after 2017.
```sql
SELECT A.ACT_NAME
FROM ACTOR A
JOIN MOVIE_CAST MC ON A.ACT_ID = MC.ACT_ID
JOIN MOVIES M ON MC.MOV_ID = M.MOV_ID
WHERE M.MOV_YEAR < 2000
INTERSECT
SELECT A.ACT_NAME
FROM ACTOR A
JOIN MOVIE_CAST MC ON A.ACT_ID = MC.ACT_ID
JOIN MOVIES M ON MC.MOV_ID = M.MOV_ID
WHERE M.MOV_YEAR > 2017;
```
**Output:**
| ACT_NAME |
| :--- |
| Anil Kapoor |

---

### Query 2: Title of movies and their star ratings (highest rating per movie), sorted by title.
```sql
SELECT M.MOV_TITLE, MAX(R.STARS) AS Highest_Stars
FROM MOVIES M, RATINGS R
WHERE M.MOV_ID = R.MOV_ID
GROUP BY M.MOV_TITLE
ORDER BY M.MOV_TITLE;
```
**Output:**
| MOV_TITLE | Highest_Stars |
| :--- | :--- |
| Inception | 5 |
| Ram Lakhan | 4 |

---

### Query 3: Update rating of all movies directed by ‘Subhash Ghai’ to 5.
```sql
UPDATE RATINGS
SET STARS = 5
WHERE MOV_ID IN (
    SELECT MOV_ID 
    FROM MOVIES M, DIRECTOR D 
    WHERE M.DIR_ID = D.DIR_ID AND D.DIR_NAME = 'Subhash Ghai'
);

-- Verification Query
SELECT M.MOV_TITLE, R.STARS
FROM MOVIES M, RATINGS R, DIRECTOR D
WHERE M.MOV_ID = R.MOV_ID AND M.DIR_ID = D.DIR_ID AND D.DIR_NAME = 'Subhash Ghai';
```
**Output:**
| MOV_TITLE | STARS |
| :--- | :--- |
| Ram Lakhan | 5 |