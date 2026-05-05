# FreshMart Grocery - Data Warehouse Design (OLAP System)

**Responsible:** Keitumetse Dimpe

---

## 1. Overview

This document covers the complete design and implementation of the Grocery data warehouse built on PostgreSQL. It includes all three required tables, the star schema with five dimension tables and one fact table, and all SQL commands executed with screenshot evidence.

---

## 2. Schema and Required Tables

All warehouse tables are created inside a dedicated schema called `grocery`. The three tables required by the project brief are:

| Table | Description | Row Count |
|-------|-------------|-----------|
| `grocery.orders_dw` | Staging table loaded from MySQL | 70 order line rows |
| `grocery.customer_activity` | Staging table loaded from MongoDB | 25 activity rows |
| `grocery.customer_analytics` | Integrated table (SQL JOIN of both staging tables) | 34 rows |

---

## 3. Star Schema Design

The Grocery data warehouse follows a **Star Schema** design pattern. The central fact table (`fact_sales`) is surrounded by five dimension tables that provide descriptive context.

### 3.1 Table Roles

| Table | Role | Row Count | Description |
|-------|------|-----------|-------------|
| `fact_sales` | FACT TABLE | 70 | Stores measurable transaction rows with FK links to 4 dimensions |
| `dim_customer` | DIMENSION | 15 | Unique customers |
| `dim_product` | DIMENSION | 20 | Unique products with categories |
| `dim_date` | DIMENSION | 35 | Unique order dates (day/month/quarter/year) |
| `dim_payment` | DIMENSION | 4 | Payment methods (Cash, Card, EFT, Mobile) |
| `dim_activity` | DIMENSION | 3 | Activity types (Viewed, Added to Cart, Purchased) |

### 3.2 Star Schema Diagram

![Star Schema Diagram](./diagrams/Star%20Schema%20Diagram.png)

---

## 4. Step 1: Verify Source Data (MySQL OLTP)
```
docker exec mysql-node-71 mysql -uroot -prootpass -e "USE grocerydb; SELECT COUNT() AS total_orders FROM orders; SELECT COUNT() AS total_items FROM order_items;"
```

![MySQL Source Data](./screenshots/mysql_source_data.png)

---

## 5. Step 2: Verify Source Data (MongoDB OLTP)

```
docker exec mongodb mongosh --eval "db = db.getSiblingDB('grocerydb'); print('Activity records: ' + db.customer_activity.countDocuments());"
```

![MongoDB Source Data](./screenshots/mongodb_source_data.png)


## 6. Step 3: Opening PostgreSQL Warehouse

```
docker exec -it postgres-dw psql -U admin -d warehouse
```
![Postgres_Connection](./docs/screenshots/postgres_connection.png)

---

## 7. Step 2: Creating All Warehouse Tables

```sql
-- Create dedicated schema for the grocery data warehouse
CREATE SCHEMA IF NOT EXISTS grocery;

-- REQUIRED TABLE 1: orders_dw (staging from MySQL)
CREATE TABLE IF NOT EXISTS grocery.orders_dw (
    order_id INT,
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

-- REQUIRED TABLE 2: customer_activity (staging from MongoDB)
CREATE TABLE IF NOT EXISTS grocery.customer_activity (
    customer_name TEXT,
    product TEXT,
    category TEXT,
    activity TEXT,
    activity_timestamp TIMESTAMP,
    device_type TEXT,
    session_id TEXT
);

-- REQUIRED TABLE 3: customer_analytics (final integrated table)
CREATE TABLE IF NOT EXISTS grocery.customer_analytics (
    customer_name TEXT,
    product TEXT,
    category TEXT,
    activity TEXT,
    line_total NUMERIC(12,2),
    order_date DATE,
    activity_timestamp TIMESTAMP,
    payment_method TEXT,
    order_status TEXT,
    device_type TEXT
);

-- DIMENSION 1: Customers
CREATE TABLE IF NOT EXISTS grocery.dim_customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL UNIQUE
);

-- DIMENSION 2: Products
CREATE TABLE IF NOT EXISTS grocery.dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL
);

-- DIMENSION 3: Dates
CREATE TABLE IF NOT EXISTS grocery.dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INT,
    month INT,
    month_name TEXT,
    quarter INT,
    year INT
);

-- DIMENSION 4: Payment Methods
CREATE TABLE IF NOT EXISTS grocery.dim_payment (
    payment_id SERIAL PRIMARY KEY,
    payment_method TEXT NOT NULL UNIQUE
);

-- DIMENSION 5: Activity Types
CREATE TABLE IF NOT EXISTS grocery.dim_activity (
    activity_id SERIAL PRIMARY KEY,
    activity_type TEXT NOT NULL UNIQUE
);

-- FACT TABLE: fact_sales (references all 4 dimensions via FK)
CREATE TABLE IF NOT EXISTS grocery.fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES grocery.dim_customer(customer_id),
    product_id INT REFERENCES grocery.dim_product(product_id),
    date_id INT REFERENCES grocery.dim_date(date_id),
    payment_id INT REFERENCES grocery.dim_payment(payment_id),
    quantity INT,
    unit_price NUMERIC(10,2),
    line_total NUMERIC(12,2),
    order_status TEXT
);
```
