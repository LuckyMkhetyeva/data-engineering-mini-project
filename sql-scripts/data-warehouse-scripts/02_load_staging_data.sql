-- =====================================================
-- LOAD DATA INTO STAGING TABLES FROM CSV FILES
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- First, copy CSV files to PostgreSQL container:
-- docker cp data/cleaned/orders_clean.csv postgres-dw:/tmp/orders_clean.csv
-- docker cp data/cleaned/activity_clean.csv postgres-dw:/tmp/activity_clean.csv

-- Load orders data
COPY grocery.orders_dw(
    order_id,
    order_date,
    customer_name,
    product,
    category,
    quantity,
    unit_price,
    line_total,
    payment_method,
    order_status
)
FROM '/tmp/orders_clean.csv'
DELIMITER ','
CSV HEADER;

-- Load customer activity data
COPY grocery.customer_activity(
    customer_name,
    product,
    category,
    activity,
    activity_timestamp,
    device_type,
    session_id
)
FROM '/tmp/activity_clean.csv'
DELIMITER ','
CSV HEADER;

-- =====================================================
-- VERIFY DATA LOADED
-- =====================================================

SELECT 'orders_dw' AS table_name, COUNT(*) AS rows FROM grocery.orders_dw
UNION ALL
SELECT 'customer_activity', COUNT(*) FROM grocery.customer_activity;