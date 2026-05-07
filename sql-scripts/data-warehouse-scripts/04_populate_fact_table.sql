-- =====================================================
-- POPULATE STAR SCHEMA FACT TABLE
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- Clear fact table for repeatable execution
TRUNCATE TABLE grocery.fact_sales RESTART IDENTITY;

-- Insert into fact_sales by joining orders with dimensions
INSERT INTO grocery.fact_sales(
    customer_id,
    product_id,
    date_id,
    payment_id,
    quantity,
    unit_price,
    line_total,
    order_status
)
SELECT
    dc.customer_id,
    dp.product_id,
    dd.date_id,
    dpm.payment_id,
    o.quantity,
    o.unit_price,
    o.line_total,
    o.order_status
FROM grocery.orders_dw o
JOIN grocery.dim_customer dc ON dc.customer_name = o.customer_name
JOIN grocery.dim_product  dp ON dp.product_name  = o.product
JOIN grocery.dim_date     dd ON dd.full_date     = o.order_date
JOIN grocery.dim_payment  dpm ON dpm.payment_method = o.payment_method;

-- =====================================================
-- VERIFY FACT TABLE POPULATION
-- =====================================================

SELECT COUNT(*) AS fact_rows_loaded FROM grocery.fact_sales;

-- View sample of fact table with dimensions
SELECT
    dc.customer_name,
    dp.product_name,
    dp.category,
    dd.month_name,
    dd.year,
    dpm.payment_method,
    fs.quantity,
    fs.line_total,
    fs.order_status
FROM grocery.fact_sales fs
JOIN grocery.dim_customer dc ON fs.customer_id = dc.customer_id
JOIN grocery.dim_product  dp ON fs.product_id  = dp.product_id
JOIN grocery.dim_date     dd ON fs.date_id     = dd.date_id
JOIN grocery.dim_payment dpm ON fs.payment_id  = dpm.payment_id
ORDER BY fs.sale_id
LIMIT 10;