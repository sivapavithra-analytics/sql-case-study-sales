-- Sales & Customer Analysis

-- 1. View sample data
SELECT *
FROM sales
LIMIT 10;

-- 2. Total revenue
SELECT SUM(sales_amount) AS total_revenue
FROM sales;

-- 3. Top 5 customers by revenue
SELECT customer_id,
       SUM(sales_amount) AS revenue
FROM sales
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 5;
