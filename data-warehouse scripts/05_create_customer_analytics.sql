-- =====================================================
-- CREATE INTEGRATED CUSTOMER ANALYTICS TABLE
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- Insert integrated data by joining orders and activity
INSERT INTO grocery.customer_analytics(
    customer_name,
    product,
    category,
    activity,
    line_total,
    order_date,
    activity_timestamp,
    payment_method,
    order_status,
    device_type
)
SELECT
    o.customer_name,
    o.product,
    o.category,
    a.activity,
    o.line_total,
    o.order_date,
    a.activity_timestamp,
    o.payment_method,
    o.order_status,
    a.device_type
FROM grocery.orders_dw o
JOIN grocery.customer_activity a
    ON o.customer_name = a.customer_name
    AND o.product = a.product;

-- =====================================================
-- VERIFY INTEGRATION
-- =====================================================

SELECT COUNT(*) AS integrated_rows FROM grocery.customer_analytics;

-- View sample of integrated data
SELECT * FROM grocery.customer_analytics LIMIT 10;