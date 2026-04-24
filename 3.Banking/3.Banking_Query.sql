CREATE DATABASE Banking_System;
USE Banking_System;

-- 1. BRANCH Table
CREATE TABLE BRANCH (
    branch_name VARCHAR(20) PRIMARY KEY,
    branch_city VARCHAR(20),
    assets REAL
);

-- 2. ACCOUNT Table
CREATE TABLE ACCOUNT (
    accno INT PRIMARY KEY,
    branch_name VARCHAR(20) REFERENCES BRANCH(branch_name) ON DELETE CASCADE,
    balance REAL
);

-- 3. CUSTOMER Table
CREATE TABLE CUSTOMER (
    customer_name VARCHAR(20) PRIMARY KEY,
    customer_street VARCHAR(30),
    customer_city VARCHAR(20)
);

-- 4. DEPOSITOR Table (Link Customer to Account)
CREATE TABLE DEPOSITOR (
    customer_name VARCHAR(20) REFERENCES CUSTOMER(customer_name),
    accno INT REFERENCES ACCOUNT(accno),
    PRIMARY KEY (customer_name, accno)
);

-- 5. LOAN Table
CREATE TABLE LOAN (
    loan_number INT PRIMARY KEY,
    branch_name VARCHAR(20) REFERENCES BRANCH(branch_name) ON DELETE CASCADE,
    amount REAL
);

-- 6. BORROWER Table (Link Customer to Loan)
CREATE TABLE BORROWER (
    customer_name VARCHAR(20) REFERENCES CUSTOMER(customer_name),
    loan_number INT REFERENCES LOAN(loan_number),
    PRIMARY KEY (customer_name, loan_number)
);




-- Insert Branches
INSERT INTO BRANCH VALUES ('Main', 'Bangalore', 500000);
INSERT INTO BRANCH VALUES ('Indiranagar', 'Bangalore', 200000);
INSERT INTO BRANCH VALUES ('MG Road', 'Bangalore', 150000);
INSERT INTO BRANCH VALUES ('Brighton', 'Delhi', 300000);
INSERT INTO BRANCH VALUES ('Perryridge', 'Mumbai', 400000);

-- Insert Customers
INSERT INTO CUSTOMER VALUES ('Avinash', 'Bull Temple Road', 'Bangalore');
INSERT INTO CUSTOMER VALUES ('Dinesh', 'Bannerghatta Road', 'Bangalore');
INSERT INTO CUSTOMER VALUES ('Nikil', 'Manipal Ave', 'Udupi');
INSERT INTO CUSTOMER VALUES ('Rahul', 'CP', 'Delhi');

-- Insert Accounts
INSERT INTO ACCOUNT VALUES (101, 'Main', 5000);
INSERT INTO ACCOUNT VALUES (102, 'Main', 10000);
INSERT INTO ACCOUNT VALUES (103, 'Indiranagar', 12000);
INSERT INTO ACCOUNT VALUES (104, 'MG Road', 8000);
INSERT INTO ACCOUNT VALUES (105, 'Brighton', 6000);
INSERT INTO ACCOUNT VALUES (106, 'Perryridge', 20000);

-- Insert Depositors (Avinash has accounts in ALL Bangalore branches)
INSERT INTO DEPOSITOR VALUES ('Avinash', 101), ('Avinash', 103), ('Avinash', 104);
INSERT INTO DEPOSITOR VALUES ('Dinesh', 101), ('Dinesh', 102);
INSERT INTO DEPOSITOR VALUES ('Nikil', 104);
INSERT INTO DEPOSITOR VALUES ('Rahul', 105);

-- Insert Loans
INSERT INTO LOAN VALUES (501, 'Main', 50000);
INSERT INTO LOAN VALUES (502, 'Brighton', 5000);
INSERT INTO LOAN VALUES (503, 'Indiranagar', 12000);

-- Insert Borrowers
INSERT INTO BORROWER VALUES ('Avinash', 501), ('Dinesh', 503), ('Rahul', 502);



-- 1. Customers with at least two accounts at the 'Main' branch

SELECT customer_name 
FROM DEPOSITOR D, ACCOUNT A
WHERE D.accno = A.accno AND A.branch_name = 'Main'
GROUP BY customer_name
HAVING COUNT(*) >= 2;


-- 2. Customers with an account at ALL branches in 'Bangalore'

SELECT customer_name FROM CUSTOMER C
WHERE NOT EXISTS (
    (SELECT branch_name FROM BRANCH WHERE branch_city = 'Bangalore')
    EXCEPT
    (SELECT A.branch_name FROM ACCOUNT A, DEPOSITOR D 
     WHERE A.accno = D.accno AND D.customer_name = C.customer_name)
);



-- 3. Customers with accounts in at least 2 branches in 'Bangalore'

SELECT D.customer_name
FROM DEPOSITOR D, ACCOUNT A, BRANCH B
WHERE D.accno = A.accno AND A.branch_name = B.branch_name AND B.branch_city = 'Bangalore'
GROUP BY D.customer_name
HAVING COUNT(DISTINCT A.branch_name) >= 2;



-- 4. Customers who borrowed from at least one branch in 'Bangalore'

SELECT DISTINCT customer_name
FROM BORROWER BR, LOAN L, BRANCH B
WHERE BR.loan_number = L.loan_number AND L.branch_name = B.branch_name 
AND B.branch_city = 'Bangalore';


-- 5. Branch name with max customers in 'Bangalore'

SELECT TOP 1 branch_name
FROM (
    SELECT A.branch_name, COUNT(DISTINCT D.customer_name) as cnt 
    FROM BRANCH B, ACCOUNT A, DEPOSITOR D 
    WHERE B.branch_name = A.branch_name AND A.accno = D.accno AND B.branch_city = 'Bangalore' 
    GROUP BY A.branch_name
) t ORDER BY cnt DESC;


-- 6. Loan numbers with amount > 10,000

SELECT loan_number FROM LOAN WHERE amount > 10000;


-- 7. Accounts with balance higher than any account in 'Brighton' (Nested)

SELECT accno FROM ACCOUNT 
WHERE balance > (SELECT MAX(balance) FROM ACCOUNT WHERE branch_name = 'Brighton');


-- 8. Branches with assets > assets of 'Perryridge' (Nested)

SELECT branch_name FROM BRANCH 
WHERE assets > (SELECT assets FROM BRANCH WHERE branch_name = 'Perryridge');


-- 9. Customer with the highest loan amount in the bank (Nested)

SELECT customer_name FROM BORROWER 
WHERE loan_number = (SELECT loan_number FROM LOAN WHERE amount = (SELECT MAX(amount) FROM LOAN));


