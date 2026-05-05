-- =====================================================
-- FINAL VERIFICATION - ALL TABLES ROW COUNTS
-- Responsible: Keitumetse Dimpe
-- =====================================================

SELECT 'orders_dw'         AS table_name, COUNT(*) AS rows FROM grocery.orders_dw
UNION ALL SELECT 'customer_activity',  COUNT(*) FROM grocery.customer_activity
UNION ALL SELECT 'customer_analytics', COUNT(*) FROM grocery.customer_analytics
UNION ALL SELECT 'fact_sales',         COUNT(*) FROM grocery.fact_sales
UNION ALL SELECT 'dim_customer',       COUNT(*) FROM grocery.dim_customer
UNION ALL SELECT 'dim_product',        COUNT(*) FROM grocery.dim_product
UNION ALL SELECT 'dim_date',           COUNT(*) FROM grocery.dim_date
UNION ALL SELECT 'dim_payment',        COUNT(*) FROM grocery.dim_payment
UNION ALL SELECT 'dim_activity',       COUNT(*) FROM grocery.dim_activity
ORDER BY table_name;

-- =====================================================
-- VERIFY FOREIGN KEY CONSTRAINTS
-- =====================================================

\d grocery.fact_sales