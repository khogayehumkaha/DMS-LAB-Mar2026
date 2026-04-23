


# Order Database Management System (DBMS Lab)

## 🛠️ 1. Database Schema
This schema manages the flow from customer orders to warehouse shipments.

```sql
CREATE DATABASE ORDERS_DB;
USE ORDERS_DB;

-- 1. CUSTOMER Table
CREATE TABLE CUSTOMER (
    CUST_NO INT PRIMARY KEY,
    CNAME VARCHAR(20) NOT NULL,
    CITY VARCHAR(20)
);

-- 2. ORDERS Table
CREATE TABLE ORDERS (
    ORDER_NO INT PRIMARY KEY,
    ORDER_DATE DATE,
    CUST_NO INT REFERENCES CUSTOMER(CUST_NO),
    ORDER_AMT INT
);

-- 3. ITEM Table
CREATE TABLE ITEM (
    ITEM_NO INT PRIMARY KEY,
    UNITPRICE INT
);

-- 4. ORDER_ITEM Table
CREATE TABLE ORDER_ITEM (
    ORDER_NO INT REFERENCES ORDERS(ORDER_NO),
    ITEM_NO INT REFERENCES ITEM(ITEM_NO),
    QTY INT,
    PRIMARY KEY (ORDER_NO, ITEM_NO)
);

-- 5. WAREHOUSE Table
CREATE TABLE WAREHOUSE (
    WAREHOUSE_NO INT PRIMARY KEY,
    CITY VARCHAR(20)
);

-- 6. SHIPMENT Table
CREATE TABLE SHIPMENT (
    ORDER_NO INT REFERENCES ORDERS(ORDER_NO),
    WAREHOUSE_NO INT REFERENCES WAREHOUSE(WAREHOUSE_NO),
    SHIP_DATE DATE,
    PRIMARY KEY (ORDER_NO, WAREHOUSE_NO)
);
```

---

## 📊 2. Optimized Data Insertion
Data is structured to ensure that **Kumar** has orders and **Order 101** is shipped through **Warehouse 10**.

```sql
-- Insert Customers
INSERT INTO CUSTOMER VALUES (1, 'Kumar', 'Bangalore'), (2, 'Rahul', 'Mysore'), (3, 'Kumar', 'Delhi');

-- Insert Orders
INSERT INTO ORDERS VALUES (101, '2023-01-10', 1, 5000);
INSERT INTO ORDERS VALUES (102, '2023-02-15', 1, 2000);
INSERT INTO ORDERS VALUES (103, '2023-03-20', 2, 1500);

-- Insert Items
INSERT INTO ITEM VALUES (501, 500), (502, 1000);

-- Insert Order Items
INSERT INTO ORDER_ITEM VALUES (101, 501, 2);
INSERT INTO ORDER_ITEM VALUES (101, 502, 4);
INSERT INTO ORDER_ITEM VALUES (102, 501, 1);

-- Insert Warehouses
INSERT INTO WAREHOUSE VALUES (10, 'Bangalore'), (20, 'Chennai');

-- Insert Shipments
INSERT INTO SHIPMENT VALUES (101, 10, '2023-01-12');
INSERT INTO SHIPMENT VALUES (102, 10, '2023-02-17');
INSERT INTO SHIPMENT VALUES (103, 20, '2023-03-22');
```

---

## 🔍 3. SQL Queries and Results

### Query 1: List the Order# and Day_of_Order for all orders placed by 'Kumar'
```sql
SELECT ORDER_NO, ORDER_DATE 
FROM ORDERS O, CUSTOMER C 
WHERE O.CUST_NO = C.CUST_NO AND C.CNAME = 'Kumar';
```
**Output:**
| ORDER_NO | ORDER_DATE |
| :--- | :--- |
| 101 | 2023-01-10 |
| 102 | 2023-02-15 |

---

### Query 2: List all ITEM_NO and Quantity for Order# 101
```sql
SELECT ITEM_NO, QTY 
FROM ORDER_ITEM 
WHERE ORDER_NO = 101;
```
**Output:**
| ITEM_NO | QTY |
| :--- | :--- |
| 501 | 2 |
| 502 | 4 |

---

### Query 3: List Order# and Ship_date for orders from Warehouse# 10
```sql
SELECT ORDER_NO, SHIP_DATE 
FROM SHIPMENT 
WHERE WAREHOUSE_NO = 10;
```
**Output:**
| ORDER_NO | SHIP_DATE |
| :--- | :--- |
| 101 | 2023-01-12 |
| 102 | 2023-02-17 |

---

### Query 4: List Warehouse# and City for warehouses that shipped Order# 101
```sql
SELECT W.WAREHOUSE_NO, W.CITY 
FROM WAREHOUSE W, SHIPMENT S 
WHERE W.WAREHOUSE_NO = S.WAREHOUSE_NO AND S.ORDER_NO = 101;
```
**Output:**
| WAREHOUSE_NO | CITY |
| :--- | :--- |
| 10 | Bangalore |

---

### Query 5: Number of orders placed by each customer
```sql
SELECT C.CNAME, COUNT(O.ORDER_NO) AS Order_Count
FROM CUSTOMER C
LEFT JOIN ORDERS O ON C.CUST_NO = O.CUST_NO
GROUP BY C.CNAME;
```
**Output:**
| CNAME | Order_Count |
| :--- | :--- |
| Kumar | 2 |
| Rahul | 1 |