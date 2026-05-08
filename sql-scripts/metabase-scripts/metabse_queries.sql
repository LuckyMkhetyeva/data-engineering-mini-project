-- =====================================================
-- FRESHMART METABASE ANALYTICAL QUERIES
-- Use these queries in Metabase as SQL questions.
-- Author: Lucky Mkhetyeva - 221400214
-- =====================================================

-- 1) Product Sales Performance (Completed Orders)
-- Metabase chart: Bar chart (X = product, Y = total_revenue)
SELECT
    dp.product_name AS product,
    SUM(fs.quantity) AS total_quantity_sold,
    ROUND(SUM(fs.line_total), 2) AS total_revenue
FROM grocery.fact_sales fs
JOIN grocery.dim_product dp ON fs.product_id = dp.product_id
WHERE fs.order_status = 'Completed'
GROUP BY dp.product_name
ORDER BY total_revenue DESC;

-- 2) Revenue Trend by Month (Completed Orders)
-- Metabase chart: Line chart (X = order_month, Y = total_revenue)
SELECT
    CONCAT(dd.year, '-', LPAD(dd.month::text, 2, '0')) AS order_month,
    ROUND(SUM(fs.line_total), 2) AS total_revenue
FROM grocery.fact_sales fs
JOIN grocery.dim_date dd ON fs.date_id = dd.date_id
WHERE fs.order_status = 'Completed'
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

-- 3) Top Customers by Revenue and Orders
-- Metabase chart: Horizontal bar chart or table
SELECT
    dc.customer_name AS customer,
    COUNT(*) AS order_lines,
    SUM(fs.quantity) AS total_items_purchased,
    ROUND(SUM(fs.line_total), 2) AS total_spend
FROM grocery.fact_sales fs
JOIN grocery.dim_customer dc ON fs.customer_id = dc.customer_id
WHERE fs.order_status = 'Completed'
GROUP BY dc.customer_name
ORDER BY total_spend DESC;

-- 4) Customer Activity Distribution
-- Metabase chart: Pie/Donut chart (Dimension = activity, Measure = activity_count)
SELECT
    COALESCE(activity, 'Unknown') AS activity,
    COUNT(*) AS activity_count
FROM grocery.customer_activity
GROUP BY COALESCE(activity, 'Unknown')
ORDER BY activity_count DESC;

-- 5) Integrated Behaviour-to-Sales Journey
-- Metabase chart: Table (customer journey details)
SELECT
    ca.customer_name AS customer,
    ca.product AS product,
    ca.category AS category,
    ca.activity AS activity,
    ca.order_date AS order_date,
    ca.activity_timestamp AS activity_timestamp,
    ca.payment_method AS payment_method,
    ca.order_status AS order_status,
    ROUND(ca.line_total, 2) AS revenue
FROM grocery.customer_analytics ca
ORDER BY ca.order_date DESC, ca.activity_timestamp DESC;

-- 6) Revenue by Category (Optional)
-- Metabase chart: Bar chart (X = category, Y = total_revenue)
SELECT
    COALESCE(dp.category, 'Uncategorized') AS category,
    ROUND(SUM(fs.line_total), 2) AS total_revenue
FROM grocery.fact_sales fs
JOIN grocery.dim_product dp ON fs.product_id = dp.product_id
WHERE fs.order_status = 'Completed'
GROUP BY COALESCE(dp.category, 'Uncategorized')
ORDER BY total_revenue DESC;

-- 7) Revenue by Payment Method (Optional)
-- Metabase chart: Stacked bar or pie chart
SELECT
    dpay.payment_method AS payment_method,
    ROUND(SUM(fs.line_total), 2) AS total_revenue,
    COUNT(*) AS order_lines
FROM grocery.fact_sales fs
JOIN grocery.dim_payment dpay ON fs.payment_id = dpay.payment_id
WHERE fs.order_status = 'Completed'
GROUP BY dpay.payment_method
ORDER BY total_revenue DESC;

-- 8) Device Type Activity Distribution (Optional)
-- Metabase chart: Bar chart
SELECT
    COALESCE(device_type, 'Unknown') AS device_type,
    COUNT(*) AS activity_count
FROM grocery.customer_activity
GROUP BY COALESCE(device_type, 'Unknown')
ORDER BY activity_count DESC;

-- 9) Product Conversion-Style Activity Counts (Optional)
-- Metabase chart: Stacked bar chart (X = product, stack = activity)
SELECT
    product,
    SUM(CASE WHEN activity = 'Viewed' THEN 1 ELSE 0 END) AS viewed_count,
    SUM(CASE WHEN activity = 'Added to Cart' THEN 1 ELSE 0 END) AS added_to_cart_count,
    SUM(CASE WHEN activity = 'Purchased' THEN 1 ELSE 0 END) AS purchased_count
FROM grocery.customer_activity
GROUP BY product
 