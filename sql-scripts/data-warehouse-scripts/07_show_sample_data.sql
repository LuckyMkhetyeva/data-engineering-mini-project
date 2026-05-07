-- =====================================================
-- SAMPLE DATA DISPLAY FOR REPORT
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- Sample from orders_dw
SELECT * FROM grocery.orders_dw LIMIT 5;

-- Sample from customer_activity
SELECT * FROM grocery.customer_activity LIMIT 5;

-- Sample from fact_sales with dimension names
SELECT
    dc.customer_name,
    dp.product_name,
    dp.category,
    dd.full_date,
    dpm.payment_method,
    fs.quantity,
    fs.line_total
FROM grocery.fact_sales fs
JOIN grocery.dim_customer dc ON fs.customer_id = dc.customer_id
JOIN grocery.dim_product  dp ON fs.product_id  = dp.product_id
JOIN grocery.dim_date     dd ON fs.date_id     = dd.date_id
JOIN grocery.dim_payment dpm ON fs.payment_id  = dpm.payment_id
LIMIT 10;