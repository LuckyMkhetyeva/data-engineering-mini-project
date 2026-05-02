-- Sample BI queries for grocery/supermarket domain

-- Top purchased products (based on completed orders)
SELECT product, SUM(quantity) AS units_sold
FROM dw.fact_customer_orders
WHERE order_status = 'Completed'
GROUP BY product
ORDER BY units_sold DESC
LIMIT 10;

-- Conversion funnel from activity to purchase by product
SELECT
  a.product,
  COUNT(*) FILTER (WHERE a.activity = 'Viewed') AS viewed,
  COUNT(*) FILTER (WHERE a.activity = 'Added to Cart') AS added_to_cart,
  COUNT(*) FILTER (WHERE a.activity = 'Purchased') AS purchased
FROM dw.fact_customer_activity a
GROUP BY a.product
ORDER BY purchased DESC, viewed DESC;
