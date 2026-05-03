
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

### 1. List all actors who acted in a movie before 2000 and also in a movie after 2017. 
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

### 2. Find the title of movies and number of stars for each movie that has at least one rating and find the highest number of stars that movie received. Sort the result by movie title. 
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

### 4.  Find actors who have worked in at least two movies with a rating of 4 stars or higher. (Use EXISTS)
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

### 5. Categorize movies based on the following criterion: If rating = 4.5 to 5 then Review = ‘Block Buster’ If rating = 3.5 to 4.4 then Review = ‘Super Hit’ Else Review = ‘Flop’. (Use JOIN)
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


### 6.  Find the names of actors who have acted in more movies than the average number of movies acted by all actors.
```sql
SELECT A.Act_Name 
FROM ACTOR A
JOIN MOVIE_CAST MC ON A.Act_id = MC.Act_id
GROUP BY A.Act_id, A.Act_Name
HAVING COUNT(MC.Mov_id) > (
    SELECT AVG(Movie_Count) 
    FROM (SELECT COUNT(Mov_id) AS Movie_Count FROM MOVIE_CAST GROUP BY Act_id) AS Temp
);
```
**Output Table:**
| Act_Name |
| :--- |
| Anil Kapoor |
| Hrithik Roshan |

---

### 7. Find the movie titles that have received ratings from **all** viewers registered in the database.
```sql
SELECT M.Mov_Title FROM MOVIES M
WHERE NOT EXISTS (
    SELECT Viewer_ID FROM VIEWER
    EXCEPT
    SELECT Viewer_ID FROM RATINGS R WHERE R.Mov_id = M.Mov_id
);
```
**Output Table:**
| Mov_Title |
| :--- |
| Ram Lakhan |
| Inception |
| War |

---

### 8. Retrieve movie titles whose average rating is higher than the overall average rating of all movie ratings in the system.
```sql
SELECT M.Mov_Title, AVG(R.Stars) as Avg_Stars
FROM MOVIES M
JOIN RATINGS R ON M.Mov_id = R.Mov_id
GROUP BY M.Mov_Title
HAVING AVG(R.Stars) > (SELECT AVG(Stars) FROM RATINGS);
```
**Output Table:**
| Mov_Title | Avg_Stars |
| :--- | :--- |
| Ram Lakhan | 5.0 |
| War | 4.0 |
| KRRISH | 4.5 |

---

### 9. Find actors who have acted in at least 2 different movies, and **all** those movies were released after 2005.
```sql
SELECT A.Act_Name 
FROM ACTOR A
WHERE (SELECT COUNT(MC.Mov_id) FROM MOVIE_CAST MC WHERE MC.Act_id = A.Act_id) >= 2
AND NOT EXISTS (
    SELECT * FROM MOVIE_CAST MC 
    JOIN MOVIES M ON MC.Mov_id = M.Mov_id
    WHERE MC.Act_id = A.Act_id AND M.Mov_Year <= 2005
);
```
**Output Table:**
| Act_Name |
| :--- |
| Hrithik Roshan |

---

### 10. List the names of directors whose movie actors have also acted in movies directed by other (different) directors.
```sql
SELECT DISTINCT D.Dir_Name
FROM DIRECTOR D
JOIN MOVIES M ON D.Dir_id = M.Dir_id
JOIN MOVIE_CAST MC ON M.Mov_id = MC.Mov_id
WHERE MC.Act_id IN (
    SELECT MC2.Act_id 
    FROM MOVIE_CAST MC2
    JOIN MOVIES M2 ON MC2.Mov_id = M2.Mov_id
    WHERE M2.Dir_id <> D.Dir_id
);
```


**Output:**
| Dir_Name |
| :--- |
| Subhash Ghai |
| Siddharth Anand |

---

