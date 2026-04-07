-- 1. DEPARTMENT Table
CREATE TABLE Department (
    DNUM INT PRIMARY KEY CHECK (DNUM > 0 AND DNUM < 20),
    DName VARCHAR(30) UNIQUE NOT NULL,
    MGRSSN VARCHAR(10), -- References Employee(SSN) after it's created
    MGRStartDtae DATE
);


-- 2. EMPLOYEE Table
CREATE TABLE employee (
    SSN VARCHAR(10) PRIMARY KEY,
    FName VARCHAR(20) NOT NULL,
    LName VARCHAR(20),
    Address VARCHAR(20),
    Gender CHAR(1) CHECK (Gender IN ('F', 'M')),
    Salary DECIMAL(10,2),
    SuperSSN VARCHAR(10) REFERENCES employee (SSN),
    DNO INT -- References Department(DNUM)
);


-- 3. Adding Foreign Keys that couldn't be added during table creation
ALTER TABLE Department ADD CONSTRAINT FK_Dept_Mgr FOREIGN KEY (MGRSSN) REFERENCES employee(SSN);
ALTER TABLE employee ADD CONSTRAINT FK_Emp_Dep FOREIGN KEY (DNO) REFERENCES Department (DNUM);


-- 4. DEPT_LOCATION Table (Missing earlier)
CREATE TABLE DLocation (
    DNO INT REFERENCES Department (DNUM),
    DLoc VARCHAR(30),
    PRIMARY KEY (DNO, DLoc)
);


-- 5. PROJECT Table
CREATE TABLE Project (
    PNO INT PRIMARY KEY,
    PName VARCHAR(30),
    PLocation VARCHAR(30),
    DNO INT REFERENCES Department (DNUM)
);


-- 6. WORKS_ON Table
CREATE TABLE Works_on (
    ESSN VARCHAR(10) REFERENCES employee (SSN),
    PNO INT REFERENCES Project (PNO),
    hours INT,
    PRIMARY KEY (ESSN, PNO)
);