-- Query 1: Projects involving 'Codd' as worker or manager
SELECT DISTINCT PNO FROM Works_on 
WHERE ESSN = (SELECT SSN FROM employee WHERE LName='Codd')
UNION
SELECT DISTINCT P.PNO FROM Project P, Department D 
WHERE P.DNO = D.DNUM AND D.MGRSSN = (SELECT SSN FROM employee WHERE LName = 'Codd');


-- Query 2: 10% raise for employees on 'Smart City' project
-- Pre-requisite: Update Project set PName='Smart City' where PNO=24;
SELECT SSN, FName, LName, 1.1 * Salary AS Updated_salary
FROM employee 
WHERE SSN IN (
    SELECT ESSN FROM Works_on 
    WHERE PNO = (SELECT PNO FROM project WHERE PName='Smart City')
);


-- Query 3: Salary stats for 'Research' department
-- Pre-requisite: Update Department set DName='Research' where DNUM='2';
SELECT SUM(e.salary) AS Total_Salary, MAX(e.salary) AS Max_Salary, 
       MIN(e.salary) AS Min_Salary, AVG(e.salary) AS Avg_Salary
FROM employee e, Department d
WHERE d.DName='Research' AND e.DNO=d.DNUM;


-- Query 4: Employees working on ALL projects controlled by Dept 5
-- Note: Manual uses Dept 3 in the code while asking for Dept 5 in text
SELECT e.FName, e.LName
FROM Department d, employee e, Works_on w, Project p
WHERE d.DNUM = e.DNO AND e.SSN = w.ESSN AND w.PNO = p.PNO AND p.DNO = 3;


-- Query 5: Depts with >2 employees, count of those earning > 100,000
SELECT DNO, COUNT(*) AS Num_of_emps
FROM employee
WHERE Salary > 100000 AND DNO IN (
    SELECT DNO FROM employee 
    GROUP BY DNO 
    HAVING COUNT(*) > 2
)
GROUP BY DNO;