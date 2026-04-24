
# 🎬 Movie Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema (DDL)
This schema manages actors, directors, movies, and their associated cast and ratings.

```sql
CREATE DATABASE MovieDB;
USE MovieDB;

-- 1. ACTOR Table
CREATE TABLE ACTOR (
    Act_id INT PRIMARY KEY,
    Act_Name VARCHAR(30),
    Act_Gender CHAR(1) CHECK (Act_Gender IN('M','F'))
);

-- 2. DIRECTOR Table
CREATE TABLE DIRECTOR (
    Dir_id INT PRIMARY KEY,
    Dir_Name VARCHAR(25),
    Dir_Phone BIGINT
);

-- 3. MOVIES Table
CREATE TABLE MOVIES (
    Mov_id INT PRIMARY KEY,
    Mov_Title VARCHAR(50),
    Mov_Year INT,
    Mov_Lang VARCHAR(20),
    Dir_id INT REFERENCES DIRECTOR(Dir_id) ON DELETE CASCADE
);

-- 4. MOVIE_CAST Table
CREATE TABLE MOVIE_CAST (
    Act_id INT REFERENCES ACTOR(Act_id) ON DELETE CASCADE,
    Mov_id INT REFERENCES MOVIES(Mov_id) ON DELETE CASCADE,
    Role VARCHAR(20),
    PRIMARY KEY(Act_id, Mov_id)
);

-- 5. VIEWER Table
CREATE TABLE VIEWER (
    Viewer_ID INT PRIMARY KEY,
    Name VARCHAR(25),
    Age INT,
    Gender CHAR(1)
);

-- 6. RATINGS Table
CREATE TABLE RATINGS (
    Viewer_ID INT REFERENCES VIEWER(Viewer_ID) ON DELETE CASCADE,
    Mov_id INT REFERENCES MOVIES(Mov_id) ON DELETE CASCADE,
    Stars FLOAT,
    PRIMARY KEY(Viewer_ID, Mov_id)
);
```

---

## 📊 2. Optimized Data Insertion (DML)
*Data is structured to ensure all queries return meaningful results.*

```sql
-- Insert Actors
INSERT INTO ACTOR VALUES (101, 'Anil Kapoor', 'M'), (102, 'Sridevi', 'F'), 
                         (103, 'Hrithik Roshan', 'M'), (104, 'Amitabh Bachchan', 'M');

-- Insert Directors
INSERT INTO DIRECTOR VALUES (201, 'Subhash Ghai', 9888877777), 
                            (202, 'Christopher Nolan', 9111122222), 
                            (203, 'Siddharth Anand', 9222233333);

-- Insert Movies
INSERT INTO MOVIES VALUES (501, 'Ram Lakhan', 1989, 'Hindi', 201),
                          (502, 'Race 3', 2018, 'Hindi', 201),
                          (503, 'Inception', 2010, 'English', 202),
                          (504, 'War', 2019, 'Hindi', 203),
                          (505, 'KRRISH', 2006, 'Hindi', 203);

-- Insert Movie Cast
INSERT INTO MOVIE_CAST VALUES (101, 501, 'Lakhan'), (101, 502, 'Robert'),
                              (103, 504, 'Kabir'), (103, 505, 'Krishna'),
                              (104, 503, 'Saito');

-- Insert Viewers and Ratings
INSERT INTO VIEWER VALUES (1, 'Rahul', 25, 'M'), (2, 'Anjali', 22, 'F');

INSERT INTO RATINGS VALUES (1, 501, 4), (2, 501, 3), -- Avg 3.5
                           (1, 503, 1), (2, 503, 1.5), -- Avg 1.25
                           (1, 504, 4), (2, 504, 4), -- Avg 4.0
                           (1, 505, 4.5); -- Avg 4.5
```

---

## 🔍 3. SQL Queries and Results

### 1. Actors who acted before 2000 and after 2017
```sql
SELECT A.Act_Name FROM ACTOR A
JOIN MOVIE_CAST MC ON A.Act_id = MC.Act_id
JOIN MOVIES M ON MC.Mov_id = M.Mov_id
WHERE M.Mov_Year < 2000
INTERSECT
SELECT A.Act_Name FROM ACTOR A
JOIN MOVIE_CAST MC ON A.Act_id = MC.Act_id
JOIN MOVIES M ON MC.Mov_id = M.Mov_id
WHERE M.Mov_Year > 2017;
```
**Output:**
| Act_Name |
| :--- |
| Anil Kapoor |

---

### 2. Movie Title, Number of Stars, and Highest Rating
```sql
SELECT M.Mov_Title, COUNT(R.Stars) AS Num_Ratings, MAX(R.Stars) AS Highest_Stars
FROM MOVIES M, RATINGS R
WHERE M.Mov_id = R.Mov_id
GROUP BY M.Mov_Title
ORDER BY M.Mov_Title;
```
**Output:**
| Mov_Title | Num_Ratings | Highest_Stars |
| :--- | :--- | :--- |
| Inception | 2 | 1.5 |
| KRRISH | 1 | 4.5 |
| Ram Lakhan | 2 | 4.0 |
| War | 2 | 4.0 |

---

### 3. Update rating of all movies directed by ‘Subhash Ghai’ to 5
```sql
UPDATE RATINGS
SET Stars = 5
WHERE Mov_id IN (
    SELECT Mov_id FROM MOVIES M 
    JOIN DIRECTOR D ON M.Dir_id = D.Dir_id 
    WHERE D.Dir_Name = 'Subhash Ghai'
);

-- Verification
SELECT M.Mov_Title, R.Stars FROM MOVIES M JOIN RATINGS R ON M.Mov_id = R.Mov_id WHERE M.Mov_id = 501;
```
**Output (After Update):**
| Mov_Title | Stars |
| :--- | :--- |
| Ram Lakhan | 5.0 |

---

### 4. Actors worked in at least two movies with rating ≥ 4 (Using EXISTS)
```sql
SELECT A.Act_Name FROM ACTOR A
WHERE EXISTS (
    SELECT COUNT(*) FROM MOVIE_CAST MC
    JOIN RATINGS R ON MC.Mov_id = R.Mov_id
    WHERE MC.Act_id = A.Act_id AND R.Stars >= 4
    GROUP BY MC.Act_id
    HAVING COUNT(DISTINCT MC.Mov_id) >= 2
);
```
**Output:**
| Act_Name |
| :--- |
| Hrithik Roshan |

---

### 5. Categorize movies based on rating (Block Buster, Super Hit, Flop)
```sql
SELECT M.Mov_Title, AVG(R.Stars) AS Avg_Rating,
CASE 
    WHEN AVG(R.Stars) BETWEEN 4.5 AND 5 THEN 'Block Buster'
    WHEN AVG(R.Stars) BETWEEN 3.5 AND 4.49 THEN 'Super Hit'
    ELSE 'Flop'
END AS Review
FROM MOVIES M
JOIN RATINGS R ON M.Mov_id = R.Mov_id
GROUP BY M.Mov_Title;
```
**Output:**
| Mov_Title | Avg_Rating | Review |
| :--- | :--- | :--- |
| Inception | 1.25 | Flop |
| War | 4.0 | Super Hit |
| Ram Lakhan | 5.0 | Block Buster |
| KRRISH | 4.5 | Block Buster |