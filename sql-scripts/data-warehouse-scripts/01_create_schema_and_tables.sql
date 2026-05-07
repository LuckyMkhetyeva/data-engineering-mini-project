-- =====================================================
-- FRESHMART DATA WAREHOUSE - SCHEMA & TABLE CREATION
-- Responsible: Keitumetse Dimpe
-- =====================================================

-- Create schema
CREATE SCHEMA IF NOT EXISTS grocery;

-- =====================================================
-- STAGING TABLES (from OLTP systems)
-- =====================================================

-- Orders staging table (from MySQL)
CREATE TABLE IF NOT EXISTS grocery.orders_dw (
    order_id       INT,
    order_date     DATE,
    customer_name  TEXT,
    product        TEXT,
    category       TEXT,
    quantity       INT,
    unit_price     NUMERIC(10,2),
    line_total     NUMERIC(12,2),
    payment_method TEXT,
    order_status   TEXT
);

-- Customer activity staging table (from MongoDB)
CREATE TABLE IF NOT EXISTS grocery.customer_activity (
    customer_name      TEXT,
    product            TEXT,
    category           TEXT,
    activity           TEXT,
    activity_timestamp TIMESTAMP,
    device_type        TEXT,
    session_id         TEXT
);

-- Integrated analytics table (final output)
CREATE TABLE IF NOT EXISTS grocery.customer_analytics (
    customer_name      TEXT,
    product            TEXT,
    category           TEXT,
    activity           TEXT,
    line_total         NUMERIC(12,2),
    order_date         DATE,
    activity_timestamp TIMESTAMP,
    payment_method     TEXT,
    order_status       TEXT,
    device_type        TEXT
);

-- =====================================================
-- STAR SCHEMA - DIMENSION TABLES
-- =====================================================

-- Customer dimension
CREATE TABLE IF NOT EXISTS grocery.dim_customer (
    customer_id   SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL UNIQUE
);

-- Product dimension
CREATE TABLE IF NOT EXISTS grocery.dim_product (
    product_id   SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category     TEXT
);

-- Date dimension
CREATE TABLE IF NOT EXISTS grocery.dim_date (
    date_id    SERIAL PRIMARY KEY,
    full_date  DATE NOT NULL UNIQUE,
    day        INT,
    month      INT,
    month_name TEXT,
    quarter    INT,
    year       INT
);

-- Payment dimension
CREATE TABLE IF NOT EXISTS grocery.dim_payment (
    payment_id     SERIAL PRIMARY KEY,
    payment_method TEXT NOT NULL UNIQUE
);

-- Activity dimension
CREATE TABLE IF NOT EXISTS grocery.dim_activity (
    activity_id   SERIAL PRIMARY KEY,
    activity_type TEXT NOT NULL UNIQUE
);

-- =====================================================
-- STAR SCHEMA - FACT TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS grocery.fact_sales (
    sale_id      SERIAL PRIMARY KEY,
    customer_id  INT REFERENCES grocery.dim_customer(customer_id),
    product_id   INT REFERENCES grocery.dim_product(product_id),
    date_id      INT REFERENCES grocery.dim_date(date_id),
    payment_id   INT REFERENCES grocery.dim_payment(payment_id),
    quantity     INT,
    unit_price   NUMERIC(10,2),
    line_total   NUMERIC(12,2),
    order_status TEXT
);

-- =====================================================
-- VERIFY ALL TABLES CREATED
-- =====================================================

\dt grocery.*;