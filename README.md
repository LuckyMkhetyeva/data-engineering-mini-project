# Data Engineering Mini Project – Grocery & Supermarket BI Pipeline

## Overview

This project implements an end-to-end Business Intelligence pipeline for a grocery/supermarket retail domain called **FreshMart**.

The pipeline demonstrates how operational and behavioural data can be captured from different OLTP systems, processed through an ETL workflow, loaded into a PostgreSQL data warehouse, and prepared for business intelligence reporting through Metabase.

```text
MySQL + MongoDB → ETL Scripts → Raw Data → Transform → Cleaned Data → PostgreSQL Data Warehouse → Metabase Dashboards
```

## Project Status

The project currently includes the main technical components required for the Mini BI Pipeline assignment:

| Layer | Technology | Current Status |
|---|---|---|
| Transactional OLTP source | MySQL | Implemented with grocery retail schema and seed data |
| Behavioural OLTP source | MongoDB | Implemented with customer activity seed data |
| ETL extraction | Python | Implemented for MySQL and MongoDB extraction |
| ETL transformation | Python / Pandas | Implemented for cleaning, standardisation, and CSV output |
| Data warehouse | PostgreSQL | Implemented with staging tables, integrated analytics table, dimensions, and fact table |
| Star schema | PostgreSQL | Implemented using `fact_sales` and supporting dimension tables |
| BI layer | Metabase | Docker service included; dashboard implementation/documentation in progress |
| Evidence and screenshots | Report documentation | Placeholder sections included; screenshots to be added after execution evidence is captured |

## System Architecture

The project follows this architecture:

```text
┌─────────────────────────┐       ┌─────────────────────────┐
│ MySQL OLTP System       │       │ MongoDB OLTP System     │
│ Transactional Orders    │       │ Customer Activity Data  │
└───────────┬─────────────┘       └───────────┬─────────────┘
            │                                 │
            │ Extract                         │ Extract
            ▼                                 ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│ Raw MySQL CSV           │       │ Raw MongoDB JSON        │
│ data/raw/               │       │ data/raw/               │
└───────────┬─────────────┘       └───────────┬─────────────┘
            │                                 │
            └──────────────┬──────────────────┘
                           │ Transform / Clean
                           ▼
              ┌─────────────────────────┐
              │ Cleaned CSV Files       │
              │ data/cleaned/           │
              └───────────┬─────────────┘
                          │ Load using PostgreSQL COPY
                          ▼
              ┌─────────────────────────┐
              │ PostgreSQL Data         │
              │ Warehouse / OLAP        │
              └───────────┬─────────────┘
                          │ Visualise
                          ▼
              ┌─────────────────────────┐
              │ Metabase BI Dashboard   │
              └─────────────────────────┘
```

## Technologies Used

- **Docker Compose** – container orchestration for the project services
- **MySQL 8** – transactional OLTP database for orders and retail data
- **MongoDB 6** – behavioural OLTP database for customer activity
- **Python** – ETL scripting
- **Pandas** – data transformation and CSV generation
- **PostgreSQL 15** – OLAP data warehouse
- **Metabase** – BI dashboarding and visual analytics

## Repository Structure

```bash
data-engineering-mini-project/
├── .github/
├── data/
│   ├── raw/
│   │   └── .gitkeep
│   └── cleaned/
│       └── .gitkeep
├── diagrams/
│   └── Star Schema Diagram.drawio
├── docs/
│   └── screenshots/
│       └── [execution evidence screenshots]
├── etl-scripts/
│   ├── extract_mysql.py
│   ├── extract_mongo.py
│   ├── transform_data.py
│   └── experimental/
├── mongo-scripts/
│   ├── init_mongo.js
│   ├── mongo_seed.json
│   └── mongo_queries.js
├── sql-scripts/
│   ├── mysql_schema.sql
│   └── data-warehouse-scripts/
│       ├── 01_create_schema_and_tables.sql
│       ├── 02_load_staging_data.sql
│       ├── 03_populate_dimensions.sql
│       ├── 04_populate_fact_table.sql
│       ├── 05_create_customer_analytics.sql
│       ├── 06_verify_all_tables.sql
│       └── 07_show_sample_data.sql
├── data-warehouse-design.md
├── docker-compose.yaml
└── README.md
```

## OLTP Source Systems

### MySQL – Transactional Orders

MySQL stores the structured transactional retail data for FreshMart.

The MySQL source database is initialised from:

```text
sql-scripts/mysql_schema.sql
```

The schema includes the following tables:

- `store_branches`
- `customers`
- `categories`
- `suppliers`
- `products`
- `orders`
- `order_items`

The seeded data includes:

- 15 customers
- 20 products
- 35 order headers
- 70+ order line items

This exceeds the project requirement of at least 30 MySQL order records.

### MongoDB – Customer Behavioural Activity

MongoDB stores customer behavioural activity data.

The MongoDB source data is initialised using:

```text
mongo-scripts/init_mongo.js
mongo-scripts/mongo_seed.json
```

The collection used is:

```text
grocerydb.customer_activity
```

The behavioural data includes activity types such as:

- `Viewed`
- `Added to Cart`
- `Purchased`

This exceeds the project requirement of at least 15 MongoDB customer activity records.

## ETL Process

The ETL process is implemented using Python scripts inside the `etl-scripts` directory.

### Extract

MySQL extraction script:

```bash
python etl-scripts/extract_mysql.py
```

This connects to the MySQL OLTP database, joins the relevant order tables, and exports the raw order data to:

```text
data/raw/mysql_orders_raw.csv
```

MongoDB extraction script:

```bash
python etl-scripts/extract_mongo.py
```

This connects to MongoDB, extracts the customer activity documents, converts MongoDB ObjectId values into serialisable strings, and exports the raw activity data to:

```text
data/raw/mongo_activity_raw.json
```

### Transform

Transformation script:

```bash
python etl-scripts/transform_data.py
```

The transformation process:

- standardises column names
- removes unnecessary MongoDB fields such as `_id`
- renames MongoDB `timestamp` to `activity_timestamp`
- standardises activity values
- standardises product names for successful integration
- converts dates and timestamps into consistent formats
- validates required fields
- exports cleaned CSV files for PostgreSQL loading

Cleaned output files:

```text
data/cleaned/orders_clean.csv
data/cleaned/activity_clean.csv
```

### Load

The cleaned CSV files are mounted into the PostgreSQL container using Docker Compose:

```yaml
./data/cleaned:/etl-data/cleaned:ro
```

The warehouse scripts use PostgreSQL `COPY` commands to load the cleaned CSV files into the data warehouse tables.

## PostgreSQL Data Warehouse

The PostgreSQL warehouse is implemented using SQL scripts in:

```text
sql-scripts/data-warehouse-scripts/
```

The required project tables are:

- `grocery.orders_dw`
- `grocery.customer_activity`
- `grocery.customer_analytics`

The warehouse also includes a star schema design:

### Fact Table

- `grocery.fact_sales`

### Dimension Tables

- `grocery.dim_customer`
- `grocery.dim_product`
- `grocery.dim_date`
- `grocery.dim_payment`
- `grocery.dim_activity`

## Data Integration

The final integrated analytical table is:

```text
grocery.customer_analytics
```

It combines order data from MySQL and activity data from MongoDB using a SQL join on:

```text
customer_name + product
```

This allows the project to connect customer behavioural activity with actual sales transactions.

## How to Run the Pipeline

### 1. Start the required Docker services

```bash
docker compose up -d mysql-node-7 mongodb postgres metabase
```

For only the source systems and warehouse, run:

```bash
docker compose up -d mysql-node-7 mongodb postgres
```

### 2. Confirm containers are running

```bash
docker ps
```

Expected containers include:

- `mysql-node-71`
- `mongodb`
- `postgres-dw`
- `metabase`

### 3. Run MySQL extraction

```bash
python etl-scripts/extract_mysql.py
```

Expected output file:

```text
data/raw/mysql_orders_raw.csv
```

### 4. Run MongoDB extraction

```bash
python etl-scripts/extract_mongo.py
```

Expected output file:

```text
data/raw/mongo_activity_raw.json
```

### 5. Run transformation

```bash
python etl-scripts/transform_data.py
```

Expected cleaned files:

```text
data/cleaned/orders_clean.csv
data/cleaned/activity_clean.csv
```

### 6. Connect to PostgreSQL warehouse

```bash
docker exec -it postgres-dw psql -U admin -d warehouse
```

### 7. Run the warehouse scripts inside `psql`

```sql
\i /warehouse-scripts/01_create_schema_and_tables.sql
\i /warehouse-scripts/02_load_staging_data.sql
\i /warehouse-scripts/03_populate_dimensions.sql
\i /warehouse-scripts/04_populate_fact_table.sql
\i /warehouse-scripts/05_create_customer_analytics.sql
\i /warehouse-scripts/06_verify_all_tables.sql
\i /warehouse-scripts/07_show_sample_data.sql
```

### 8. Access Metabase

Open Metabase in a browser:

```text
http://localhost:3000
```

When connecting Metabase to PostgreSQL, use the Docker service name as the host:

| Setting | Value |
|---|---|
| Database type | PostgreSQL |
| Host | `postgres` |
| Port | `5432` |
| Database name | `warehouse` |
| Username | `admin` |
| Password | `adminpass` |

> Note: Since Metabase runs inside Docker, the PostgreSQL host should be `postgres`, not `localhost`.

## Metabase Dashboard Plan

The BI layer will use Metabase to create dashboards from the PostgreSQL warehouse.

Recommended dashboard name:

```text
FreshMart BI Dashboard
```

Recommended visualisations:

| Dashboard Card | Source Table/View | Chart Type | Purpose |
|---|---|---|---|
| Product Sales Performance | `fact_sales` + `dim_product` | Bar chart | Show revenue by product |
| Customer Activity Distribution | `customer_activity` or `customer_analytics` | Pie chart | Show Viewed vs Added to Cart vs Purchased |
| Revenue Trends Over Time | `fact_sales` + `dim_date` | Line chart | Show sales trends by month/date |
| Top Customers by Revenue | `fact_sales` + `dim_customer` | Bar chart/table | Identify highest-value customers |
| Revenue by Category | `fact_sales` + `dim_product` | Bar chart | Show best-performing product categories |
| Integrated Customer Journey | `customer_analytics` | Table | Connect activity behaviour with sales transactions |

## Example Analytical Queries

The project should support queries such as:

- total revenue by product
- total revenue by category
- sales trends over time
- activity distribution by activity type
- top customers by revenue
- customer behaviour linked to purchases
- revenue by payment method
- device type activity distribution

A dedicated Metabase SQL query file will be added in a later BI layer update.

## Evidence and Screenshots Placeholder

Execution evidence will be added after running and verifying the full pipeline.

Required evidence to capture:

### Source Database Evidence

- [ ] MySQL container running
- [ ] MySQL tables created
- [ ] MySQL source data count query
- [ ] MySQL sample order data query results
- [ ] MongoDB container running
- [ ] MongoDB collection created
- [ ] MongoDB activity record count
- [ ] MongoDB sample activity documents

### ETL Evidence

- [ ] MySQL extraction script execution
- [ ] MongoDB extraction script execution
- [ ] Raw files generated in `data/raw`
- [ ] Transformation script execution
- [ ] Cleaned files generated in `data/cleaned`
- [ ] Sample cleaned CSV output

### Data Warehouse Evidence

- [ ] PostgreSQL connection
- [ ] Schema and tables created
- [ ] `orders_dw` loaded successfully
- [ ] `customer_activity` loaded successfully
- [ ] Dimension tables populated
- [ ] Fact table populated
- [ ] `customer_analytics` integrated table populated
- [ ] Final verification query results
- [ ] Star schema diagram included

### Metabase Evidence

- [ ] Metabase running at `http://localhost:3000`
- [ ] PostgreSQL database connected successfully
- [ ] Product sales bar chart
- [ ] Customer activity pie chart
- [ ] Revenue trend line chart
- [ ] Final dashboard screenshot

## Documentation Status

| Document | Purpose | Status |
|---|---|---|
| `README.md` | Main project setup and execution guide | Updated |
| `data-warehouse-design.md` | Data warehouse and star schema explanation | In progress / available |
| `docs/screenshots/` | Execution evidence | Placeholder screenshots to be added |
| `diagrams/` | Star schema and architecture diagrams | In progress / available |
| `docs/metabase-dashboard-guide.md` | Metabase setup and dashboard instructions | To be added |
| `docs/bi-metadata.md` | Data dictionary and business rules | To be added |

## Notes

- The `data/raw` and `data/cleaned` folders are tracked with `.gitkeep` files so that generated ETL output folders exist in the repository structure.
- Generated CSV and JSON outputs may be recreated by rerunning the ETL scripts.
- The PostgreSQL warehouse scripts are mounted into the container, allowing them to be executed directly from inside `psql`.
- The current implementation is suitable for moving into the BI visualisation phase using Metabase.
