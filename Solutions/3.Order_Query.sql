-- Query 1: List the Order# and Day_of_Order for all orders placed by 'Kumar'
SELECT ORDER_NO, ORDER_DATE 
FROM ORDERS O, CUSTOMER C 
WHERE O.CUST_NO = C.CUST_NO 
AND C.CNAME = 'Kumar';


-- Query 2: List all ITEM_NO and Quantity for a specific Order# (e.g., 101)
-- Note: Replace 101 with the order number you want to check
SELECT ITEM_NO, QTY 
FROM ORDER_ITEM 
WHERE ORDER_NO = 101;


-- Query 3: List Order# and Ship_date for all orders shipped from Warehouse# 10
SELECT ORDER_NO, SHIP_DATE 
FROM SHIPMENT 
WHERE WAREHOUSE_NO = 10;


-- Query 4: List Warehouse# and City for all warehouses that have shipped Order# 101
SELECT W.WAREHOUSE_NO, W.CITY 
FROM WAREHOUSE W, SHIPMENT S 
WHERE W.WAREHOUSE_NO = S.WAREHOUSE_NO 
AND S.ORDER_NO = 101;


-- Query 5: Find the number of orders placed by each customer
-- (Displays Customer Name and their total order count)
SELECT C.CNAME, COUNT(*) AS ORDER_COUNT 
FROM CUSTOMER C, ORDERS O 
WHERE C.CUST_NO = O.CUST_NO 
GROUP BY C.CNAME;