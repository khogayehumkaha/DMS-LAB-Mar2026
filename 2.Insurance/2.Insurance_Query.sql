CREATE DATABASE InsuranceDB;
USE InsuranceDB;

-- 1. PERSON Table
CREATE TABLE PERSON (
    D_ID VARCHAR(10) PRIMARY KEY,
    D_NAME VARCHAR(25) NOT NULL,
    ADDR VARCHAR(30)
);

-- 2. CAR Table
CREATE TABLE CAR (
    REG_NO VARCHAR(10) PRIMARY KEY,
    MODEL VARCHAR(10) NOT NULL,
    YEAR INT
);

-- 3. ACCIDENT Table
CREATE TABLE ACCIDENT (
    REPORT_NUM INT PRIMARY KEY,
    ACC_DATE DATE,
    ACC_LOC VARCHAR(30)
);

-- 4. OWNS Table
CREATE TABLE OWNS (
    D_ID VARCHAR(10) REFERENCES PERSON(D_ID),
    REG_NO VARCHAR(10) REFERENCES CAR(REG_NO),
    PRIMARY KEY(D_ID, REG_NO)
);

-- 5. PARTICIPATED Table
CREATE TABLE PARTICIPATED (
    D_ID VARCHAR(10) REFERENCES PERSON(D_ID),
    REG_NO VARCHAR(10) REFERENCES CAR(REG_NO),
    REPORT_NUM INT REFERENCES ACCIDENT(REPORT_NUM),
    DAM_AMOUNT INT,
    PRIMARY KEY (D_ID, REG_NO, REPORT_NUM)
);



-- Insert People (Including Chicago for Q6)
INSERT INTO PERSON VALUES ('D111', 'Nithin', 'Udupi'),
                          ('D222', 'Akash', 'Mangalore'),
                          ('D333', 'Smitha', 'Bangalore'),
                          ('D444', 'Rahul', 'Chicago'),
                          ('D555', 'John', 'Chicago');

-- Insert Cars (Mixed models, including no-accident car KA06)
INSERT INTO CAR VALUES ('KA01', 'Toyota', 2015),
                      ('KA02', 'Honda', 2018),
                      ('KA03', 'Toyota', 2020),
                      ('KA04', 'Toyota', 2019),
                      ('KA05', 'Toyota', 2021),
                      ('KA06', 'Ford', 2022);

-- Insert Accidents (2008 focus)
INSERT INTO ACCIDENT VALUES (1001, '2008-05-12', 'MG Road'),
                            (1002, '2008-08-20', 'Manipal'),
                            (1003, '2008-12-01', 'Highway');

-- Establish Ownership
INSERT INTO OWNS VALUES ('D111', 'KA01'), ('D222', 'KA02'), 
                        ('D333', 'KA03'), ('D333', 'KA04'), 
                        ('D333', 'KA05'), ('D444', 'KA06');

-- Record Participation (Avg damage = 15,000)
INSERT INTO PARTICIPATED VALUES ('D111', 'KA01', 1001, 5000), 
                                ('D333', 'KA03', 1002, 25000),
                                ('D333', 'KA03', 1003, 15000);



-- 1. List the names of people who owned cars that were involved in accidents in 2008. 

SELECT DISTINCT pr.D_NAME
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%';


-- 2. Find the name of owner and his car that has maximum number of accidents in 2008 

SELECT TOP 1 pr.D_NAME, p.REG_NO, COUNT(*) AS Acc_Count
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%'
GROUP BY pr.D_NAME, p.REG_NO
ORDER BY Acc_Count DESC;


-- 3. List the name of owners who own at least two TOYOTA cars. 

SELECT pr.D_NAME
FROM PERSON pr, OWNS o, CAR c
WHERE pr.D_ID = o.D_ID AND o.REG_NO = c.REG_NO
AND c.MODEL = 'Toyota'
GROUP BY pr.D_NAME
HAVING COUNT(*) >= 2;


-- 4. List the name of the owner who owns maximum TOYOTA cars.

SELECT TOP 1 pr.D_NAME, COUNT(*) AS Toyota_Count
FROM PERSON pr, OWNS o, CAR c
WHERE pr.D_ID = o.D_ID AND o.REG_NO = c.REG_NO
AND c.MODEL = 'Toyota'
GROUP BY pr.D_NAME
ORDER BY Toyota_Count DESC;



-- 5. Find the name of owner who owns cars having minimum damage amount for accidents in 2008

SELECT TOP 1 pr.D_NAME, p.DAM_AMOUNT
FROM PERSON pr, PARTICIPATED p, ACCIDENT a
WHERE pr.D_ID = p.D_ID AND p.REPORT_NUM = a.REPORT_NUM
AND a.ACC_DATE LIKE '2008%'
ORDER BY p.DAM_AMOUNT ASC;


-- 6. Find the names of drivers who live in 'Chicago'.

SELECT D_NAME FROM PERSON WHERE ADDR = 'Chicago';



-- 7. List the names of people who have been involved in an accident  using nested query

SELECT D_NAME FROM PERSON 
WHERE D_ID IN (SELECT D_ID FROM PARTICIPATED);



-- 8. List the cars that have never been involved in an accident. using nested query

SELECT REG_NO, MODEL FROM CAR 
WHERE REG_NO NOT IN (SELECT REG_NO FROM PARTICIPATED);


-- 9. Find the names of persons who own at least one car that has a damage amount greater than the average damage amount of all accidents  using nested query
--  (Average damage is 15,000; Smitha has 25,000)

SELECT DISTINCT D_NAME FROM PERSON 
WHERE D_ID IN (
    SELECT D_ID FROM PARTICIPATED 
    WHERE DAM_AMOUNT > (SELECT AVG(DAM_AMOUNT) FROM PARTICIPATED)
);


-- 10. Create a view to display the owner name and registration number for only those cars that were involved in more than one accident.

CREATE VIEW Multi_Accident_Cars AS
SELECT pr.D_NAME, p.REG_NO, COUNT(*) AS Total_Accidents
FROM PERSON pr
JOIN PARTICIPATED p ON pr.D_ID = p.D_ID
GROUP BY pr.D_NAME, p.REG_NO
HAVING COUNT(*) > 1;

-- To View:
SELECT * FROM Multi_Accident_Cars;


 -- 11. Create a view to display the person name, car model, accident date, and damage amount for all cars involved in accidents.

CREATE VIEW Accident_Summary_View AS
SELECT pr.D_NAME, c.MODEL, a.ACC_DATE, p.DAM_AMOUNT
FROM PERSON pr
JOIN PARTICIPATED p ON pr.D_ID = p.D_ID
JOIN CAR c ON p.REG_NO = c.REG_NO
JOIN ACCIDENT a ON p.REPORT_NUM = a.REPORT_NUM;

-- To View:
SELECT * FROM Accident_Summary_View;



