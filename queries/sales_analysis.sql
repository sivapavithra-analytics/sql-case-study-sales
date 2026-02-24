-- Sales & Customer Analysis

-- Create Table
--1 Create Customers Table
CREATE TABLE customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(50),
    Country VARCHAR(50),
    Email VARCHAR(100),
    JoinDate DATE
);

--2 Create Products Table
CREATE TABLE products (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(50),
    Category VARCHAR(50),
    UnitPrice NUMERIC(10,2)
);

--3 Create Orders Table
CREATE TABLE orders (
    OrderID VARCHAR(10) PRIMARY KEY,
    CustomerID VARCHAR(10) REFERENCES customers(CustomerID),
    ProductID VARCHAR(10) REFERENCES products(ProductID),
    OrderDate DATE,
    Quantity INT
);

--4 Create Sales Table
CREATE TABLE sales (
    SaleID VARCHAR(10) PRIMARY KEY,
    OrderID VARCHAR(10) REFERENCES orders(OrderID),
    Revenue NUMERIC(10,2),
    Profit NUMERIC(10,2)
);

--Import 
COPY customers FROM 'path/data/customers.csv' DELIMITER ',' CSV HEADER;
COPY products FROM 'path/data/products.csv' DELIMITER ',' CSV HEADER;
COPY orders FROM 'path/data/orders.csv' DELIMITER ',' CSV HEADER;
COPY sales FROM 'path/data/sales.csv' DELIMITER ',' CSV HEADER;

-- Verify Data
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM sales;

-- Business Analysis Queries
--1 Total Amount
SELECT 
    o.OrderID,
    p.ProductName,
    p.UnitPrice,
    o.Quantity,
    (p.UnitPrice * o.Quantity) AS Total_Amount
FROM orders o
JOIN products p 
    ON o.ProductID = p.ProductID;

--2 Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM sales;

--3 Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', o.OrderDate) AS Month,
    SUM(p.UnitPrice * o.Quantity) AS Monthly_Revenue
FROM orders o
JOIN products p 
    ON o.ProductID = p.ProductID
GROUP BY DATE_TRUNC('month', o.OrderDate)
ORDER BY Month;

--4 Top 5 Customers by Revenue
SELECT 
    c.CustomerID,
    c.Name,
    SUM(s.Revenue) AS Total_Revenue
FROM customers c
JOIN orders o 
    ON c.CustomerID = o.CustomerID
JOIN sales s 
    ON o.OrderID = s.OrderID
GROUP BY c.CustomerID, c.Name
ORDER BY Total_Revenue DESC
LIMIT 5;

--5 Best-Selling Products
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(o.Quantity) AS Total_Quantity_Sold
FROM products p
JOIN orders o 
    ON p.ProductID = o.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Total_Quantity_Sold DESC;

--6 Revenue by Category
SELECT 
    p.Category,
    SUM(s.Revenue) AS Total_Revenue
FROM products p
JOIN orders o 
    ON p.ProductID = o.ProductID
JOIN sales s 
    ON o.OrderID = s.OrderID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

--7 Customer Purchase Frequency
SELECT 
    c.name,
    COUNT(DISTINCT o.orderid) AS total_orders
FROM customers c
JOIN orders o ON c.customerid = o.customerid
GROUP BY c.name
ORDER BY total_orders DESC;

--8 High-Value Customers (Revenue > Average Customer Spend)
SELECT *
FROM (
    SELECT 
        c.customerid,
        c.name,
        SUM(s.revenue) AS total_spent
    FROM customers c
    JOIN orders o ON c.customerid = o.customerid
    JOIN sales s ON o.orderid = s.orderid
    GROUP BY c.customerid, c.name
) sub
WHERE total_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(revenue) AS customer_total
        FROM sales s
        JOIN orders o ON s.orderid = o.orderid
        GROUP BY o.customerid
    ) avg_table
)
ORDER BY total_spent DESC;
