-- =====================================================
-- POPULATE STAR SCHEMA DIMENSION TABLES
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- Populate dim_customer from orders
INSERT INTO grocery.dim_customer(customer_name)
SELECT DISTINCT customer_name FROM grocery.orders_dw
ON CONFLICT(customer_name) DO NOTHING;

-- Populate dim_product from orders
INSERT INTO grocery.dim_product(product_name, category)
SELECT DISTINCT product, category FROM grocery.orders_dw
ON CONFLICT(product_name) DO NOTHING;

-- Populate dim_date from orders (extract date parts)
INSERT INTO grocery.dim_date(full_date, day, month, month_name, quarter, year)
SELECT DISTINCT 
    order_date,
    EXTRACT(DAY FROM order_date)::INT,
    EXTRACT(MONTH FROM order_date)::INT,
    TO_CHAR(order_date, 'Month'),
    EXTRACT(QUARTER FROM order_date)::INT,
    EXTRACT(YEAR FROM order_date)::INT
FROM grocery.orders_dw
ON CONFLICT(full_date) DO NOTHING;

-- Populate dim_payment from orders
INSERT INTO grocery.dim_payment(payment_method)
SELECT DISTINCT payment_method FROM grocery.orders_dw
ON CONFLICT(payment_method) DO NOTHING;

-- Populate dim_activity from customer_activity
INSERT INTO grocery.dim_activity(activity_type)
SELECT DISTINCT activity FROM grocery.customer_activity
ON CONFLICT(activity_type) DO NOTHING;

-- =====================================================
-- VERIFY DIMENSION POPULATION
-- =====================================================

SELECT 'dim_customer' AS dim, COUNT(*) FROM grocery.dim_customer
UNION ALL SELECT 'dim_product', COUNT(*) FROM grocery.dim_product
UNION ALL SELECT 'dim_date',    COUNT(*) FROM grocery.dim_date
UNION ALL SELECT 'dim_payment', COUNT(*) FROM grocery.dim_payment
UNION ALL SELECT 'dim_activity',COUNT(*) FROM grocery.dim_activity;