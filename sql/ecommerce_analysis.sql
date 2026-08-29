-- E-COMMERCE ANALYTICS PROJECT
-- Database: ecommerce_analytics

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(30),
    region VARCHAR(30),
    signup_date DATE
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    sales DECIMAL(12,2),
    profit DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Import using psql:
-- \copy customers FROM 'C:\path\customers.csv' WITH (FORMAT csv, HEADER true);
-- \copy products FROM 'C:\path\products.csv' WITH (FORMAT csv, HEADER true);
-- \copy orders FROM 'C:\path\orders.csv' WITH (FORMAT csv, HEADER true);

-- BASIC ANALYSIS
SELECT COUNT(*) AS total_orders FROM orders;
SELECT ROUND(SUM(sales),2) AS total_revenue FROM orders;
SELECT ROUND(SUM(profit),2) AS total_profit FROM orders;

-- JOIN: revenue by category
SELECT p.category, ROUND(SUM(o.sales),2) AS revenue
FROM orders o
JOIN products p ON o.product_id=p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- JOIN: revenue by region
SELECT c.region, ROUND(SUM(o.sales),2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY c.region
ORDER BY revenue DESC;

-- CUSTOMER VALUE
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS orders,
       ROUND(SUM(o.sales),2) AS revenue,
       ROUND(SUM(o.profit),2) AS profit
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY revenue DESC
LIMIT 20;

-- REPEAT CUSTOMERS
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) x;

-- MONTHLY REVENUE
SELECT DATE_TRUNC('month',order_date)::date AS month,
       ROUND(SUM(sales),2) AS revenue
FROM orders
GROUP BY 1
ORDER BY 1;

-- PRODUCT RANKING WITH WINDOW FUNCTION
SELECT p.product_name,
       ROUND(SUM(o.sales),2) AS revenue,
       RANK() OVER (ORDER BY SUM(o.sales) DESC) AS revenue_rank
FROM orders o
JOIN products p ON o.product_id=p.product_id
GROUP BY p.product_name
ORDER BY revenue_rank
LIMIT 10;

-- RUNNING MONTHLY REVENUE WITH WINDOW FUNCTION
WITH monthly AS (
    SELECT DATE_TRUNC('month',order_date)::date AS month,
           SUM(sales) AS revenue
    FROM orders
    GROUP BY 1
)
SELECT month,
       ROUND(revenue,2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month),2) AS running_revenue
FROM monthly
ORDER BY month;

-- CUSTOMER SEGMENT PERFORMANCE
SELECT c.segment,
       COUNT(DISTINCT c.customer_id) AS customers,
       ROUND(SUM(o.sales),2) AS revenue,
       ROUND(SUM(o.profit),2) AS profit
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.segment
ORDER BY revenue DESC;
