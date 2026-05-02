-- PostgreSQL Data Warehouse schema for grocery BI
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.fact_customer_orders (
  order_id BIGINT,
  order_date DATE,
  customer_name TEXT,
  product TEXT,
  category TEXT,
  quantity INT,
  unit_price NUMERIC(10,2),
  line_total NUMERIC(12,2),
  payment_method TEXT,
  order_status TEXT
);

CREATE TABLE IF NOT EXISTS dw.fact_customer_activity (
  activity_id BIGSERIAL PRIMARY KEY,
  customer_name TEXT,
  product TEXT,
  category TEXT,
  activity TEXT,
  activity_timestamp TIMESTAMPTZ,
  device_type TEXT,
  session_id TEXT
);
