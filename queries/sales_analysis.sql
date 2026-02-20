-- Sales & Customer Analysis

--1 Create Database
CREATE DATABASE sales_analysis;
\c sales_analysis;

--2 Create Tables

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE
);

-- Sales Table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    total_amount NUMERIC(10,2)
);

--3 Import CSV Data

-- Business Analysis Queries

--1 Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM sales;

--2 Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(s.total_amount) AS monthly_revenue
FROM sales s
JOIN orders o ON s.order_id = o.order_id
GROUP BY month
ORDER BY month;

--3 Top 10 Customers by Revenue
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN sales s ON o.order_id = s.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;

--4 Best-Selling Products
SELECT 
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;
 
--5 Revenue by Category
SELECT 
    p.category,
    SUM(s.total_amount) AS category_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

--6 Customer Purchase Frequency
SELECT 
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

--7 High-Value Customers (Revenue> Average Customer Spend)
SELECT *
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN sales s ON o.order_id = s.order_id
    GROUP BY c.customer_id, c.customer_name
) sub
WHERE total_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(total_amount) AS customer_total
        FROM sales s
        JOIN orders o ON s.order_id = o.order_id
        GROUP BY o.customer_id
    ) avg_table
)
ORDER BY total_spent DESC;
