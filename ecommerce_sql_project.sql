# E-commerce Sales Analysis - SQL Project
## Business Case Study for UAE Market

### Project Overview
This project analyzes e-commerce sales data to provide actionable business insights for management decisions in the UAE market.

### Database Schema

-- Create Database
CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(20),
    registration_date DATE,
    city VARCHAR(50),
    emirate VARCHAR(30),
    customer_segment VARCHAR(20) -- Premium, Regular, New
);

-- 2. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    launch_date DATE
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(12,2),
    payment_method VARCHAR(30),
    order_status VARCHAR(20),
    delivery_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

### Sample Data Insertion

-- Insert Sample Customers (UAE Focus)
INSERT INTO customers VALUES
(1, 'Ahmed Al-Mansouri', 'ahmed.mansouri@gmail.com', '+971501234567', '2023-01-15', 'Dubai', 'Dubai', 'Premium'),
(2, 'Fatima Hassan', 'fatima.hassan@yahoo.com', '+971507654321', '2023-02-20', 'Abu Dhabi', 'Abu Dhabi', 'Regular'),
(3, 'John Smith', 'john.smith@hotmail.com', '+971509876543', '2023-03-10', 'Sharjah', 'Sharjah', 'New'),
(4, 'Priya Sharma', 'priya.sharma@gmail.com', '+971502468135', '2023-01-25', 'Dubai', 'Dubai', 'Regular'),
(5, 'Mohammed Ali', 'mohammed.ali@outlook.com', '+971508642975', '2023-04-05', 'Ajman', 'Ajman', 'Premium');

-- Insert Sample Products
INSERT INTO products VALUES
(101, 'Samsung Galaxy S24', 'Electronics', 'Smartphones', 'Samsung', 3499.00, 2800.00, '2024-01-01'),
(102, 'Nike Air Max 270', 'Fashion', 'Shoes', 'Nike', 649.00, 400.00, '2023-06-15'),
(103, 'Philips Air Fryer', 'Home & Kitchen', 'Appliances', 'Philips', 299.00, 180.00, '2023-08-01'),
(104, 'Adidas Football Jersey', 'Sports', 'Apparel', 'Adidas', 199.00, 120.00, '2023-09-01'),
(105, 'MacBook Air M2', 'Electronics', 'Laptops', 'Apple', 4999.00, 4200.00, '2023-07-01');

-- Insert Sample Orders
INSERT INTO orders VALUES
(1001, 1, '2024-01-15', 3499.00, 'Credit Card', 'Delivered', '2024-01-17'),
(1002, 2, '2024-01-20', 948.00, 'Cash on Delivery', 'Delivered', '2024-01-23'),
(1003, 1, '2024-02-10', 299.00, 'Credit Card', 'Delivered', '2024-02-12'),
(1004, 3, '2024-02-15', 649.00, 'Debit Card', 'Delivered', '2024-02-18'),
(1005, 4, '2024-03-01', 4999.00, 'Bank Transfer', 'Processing', NULL);

-- Insert Sample Order Items
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 3499.00, 0.00),
(2, 1002, 102, 1, 649.00, 50.00),
(3, 1002, 103, 1, 299.00, 0.00),
(4, 1003, 103, 1, 299.00, 0.00),
(5, 1004, 102, 1, 649.00, 0.00),
(6, 1005, 105, 1, 4999.00, 0.00);

-- ===========================================
-- BUSINESS ANALYSIS QUERIES
-- ===========================================

-- 1. CUSTOMER PURCHASE BEHAVIOR ANALYSIS

-- Customer Lifetime Value (CLV)
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    ROUND(SUM(o.total_amount)/COUNT(o.order_id), 2) as clv_per_order,
    DATEDIFF(CURDATE(), c.registration_date) as days_since_registration
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY total_spent DESC;

-- Customer Segmentation by Purchase Frequency
SELECT 
    customer_segment,
    COUNT(DISTINCT c.customer_id) as customer_count,
    AVG(order_count) as avg_orders_per_customer,
    AVG(total_spent) as avg_spending_per_customer
FROM (
    SELECT 
        c.customer_id,
        c.customer_segment,
        COUNT(o.order_id) as order_count,
        COALESCE(SUM(o.total_amount), 0) as total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_segment
) customer_stats
GROUP BY customer_segment;

-- 2. REVENUE TRENDS BY REGION

-- Revenue by Emirate
SELECT 
    c.emirate,
    COUNT(DISTINCT c.customer_id) as total_customers,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    ROUND(SUM(o.total_amount)/COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.emirate
ORDER BY total_revenue DESC;

-- Monthly Revenue Trends
SELECT 
    YEAR(o.order_date) as year,
    MONTH(o.order_date) as month,
    MONTHNAME(o.order_date) as month_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as monthly_revenue,
    AVG(o.total_amount) as avg_monthly_order_value
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year DESC, month DESC;

-- 3. PRODUCT PERFORMANCE ANALYSIS

-- Top Performing Products
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    COUNT(oi.order_item_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as gross_revenue,
    SUM(oi.quantity * p.cost_price) as total_cost,
    SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * p.cost_price) as profit,
    ROUND((SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * p.cost_price)) / SUM(oi.quantity * oi.unit_price) * 100, 2) as profit_margin_percent
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category, p.brand
ORDER BY gross_revenue DESC;

-- Category Performance Analysis
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) as products_count,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.quantity * oi.unit_price) as category_revenue,
    AVG(oi.unit_price) as avg_product_price,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as revenue_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 4. SEASONAL SALES PATTERNS

-- Quarterly Sales Analysis
SELECT 
    YEAR(o.order_date) as year,
    QUARTER(o.order_date) as quarter,
    CASE 
        WHEN QUARTER(o.order_date) = 1 THEN 'Q1 (Jan-Mar)'
        WHEN QUARTER(o.order_date) = 2 THEN 'Q2 (Apr-Jun)'
        WHEN QUARTER(o.order_date) = 3 THEN 'Q3 (Jul-Sep)'
        ELSE 'Q4 (Oct-Dec)'
    END as quarter_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as quarterly_revenue,
    AVG(o.total_amount) as avg_order_value
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY YEAR(o.order_date), QUARTER(o.order_date)
ORDER BY year DESC, quarter DESC;

-- Day of Week Analysis
SELECT 
    DAYNAME(o.order_date) as day_of_week,
    WEEKDAY(o.order_date) as day_number,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as daily_revenue,
    AVG(o.total_amount) as avg_order_value
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY DAYNAME(o.order_date), WEEKDAY(o.order_date)
ORDER BY day_number;

-- ===========================================
-- ADVANCED BUSINESS INSIGHTS
-- ===========================================

-- Customer Retention Rate
SELECT 
    'Customer Retention Analysis' as metric,
    COUNT(DISTINCT customer_id) as total_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) as repeat_customers,
    ROUND(COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_rate_percent
FROM (
    SELECT 
        customer_id, 
        COUNT(order_id) as order_count
    FROM orders
    GROUP BY customer_id
) customer_orders;

-- Payment Method Preferences
SELECT 
    payment_method,
    COUNT(order_id) as order_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) as percentage_of_orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method
ORDER BY order_count DESC;

-- Product Cross-Sell Analysis
SELECT 
    p1.product_name as product_1,
    p2.product_name as product_2,
    COUNT(*) as times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY oi1.product_id, oi2.product_id, p1.product_name, p2.product_name
HAVING COUNT(*) > 1
ORDER BY times_bought_together DESC;

-- ===========================================
-- KEY BUSINESS METRICS DASHBOARD
-- ===========================================

SELECT 
    'Business Overview' as report_section,
    (SELECT COUNT(*) FROM customers) as total_customers,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'Delivered') as completed_orders,
    (SELECT COUNT(DISTINCT product_id) FROM products) as total_products,
    (SELECT ROUND(SUM(total_amount), 2) FROM orders WHERE order_status = 'Delivered') as total_revenue,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders WHERE order_status = 'Delivered') as avg_order_value,
    (SELECT emirate FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_status = 'Delivered' GROUP BY emirate ORDER BY SUM(o.total_amount) DESC LIMIT 1) as top_revenue_emirate;