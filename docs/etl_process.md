# ETL Process Documentation

## Author: Ongeziwe J. Mtolo - 221205276

## ETL Process

### Overview

This project implements an Extract, Transform, and Load (ETL) process as part of the FreshMart Grocery and Supermarket Retail BI pipeline. The ETL process is responsible for moving data from operational source systems into a cleaned format that can later be loaded into the PostgreSQL data warehouse for analytical reporting.

The overall ETL flow is:

```text
MySQL + MongoDB → Extract → Raw Files → Transform → Cleaned CSV Files → PostgreSQL Data Warehouse
```

In this project, MySQL and MongoDB act as OLTP source systems. MySQL stores structured transactional data such as customer orders, products, categories, order items, and payment information. MongoDB stores semi-structured behavioural data such as customer product views, cart additions, and purchases.

The ETL process prepares these datasets so that they can be integrated in PostgreSQL and used for business intelligence analysis through Metabase.

---

## Extract Phase

The Extract phase retrieves data from the source OLTP systems and stores the output in the `data/raw/` directory. At this stage, the data is kept close to its original source format so that the extraction process can be clearly separated from the transformation process.

The extraction scripts used are:

```bash
etl-scripts/extract_mysql.py
etl-scripts/extract_mongo.py
```

The raw extraction outputs are:

```bash
data/raw/mysql_orders_raw.csv
data/raw/mongo_activity_raw.json
```

### MySQL Transactional Data Extraction

MySQL is used as the structured transactional OLTP source. It stores grocery retail order data for the FreshMart system.

The `extract_mysql.py` script connects to the MySQL `grocerydb` database and extracts flattened order data by joining several transactional tables:

```text
orders
order_items
customers
products
categories
```

The purpose of this extraction is to produce a single raw order dataset that contains the necessary order, customer, product, category, and payment details needed for analysis.

The extracted MySQL output is saved as:

```bash
data/raw/mysql_orders_raw.csv
```

The extracted fields include:

```text
order_id
order_date
customer_name
product
category
quantity
unit_price
line_total
payment_method
order_status
```

This raw CSV file represents transactional sales activity from the MySQL OLTP system.

### MongoDB Behavioural Data Extraction

MongoDB is used as the behavioural OLTP source. It stores customer activity events that describe how customers interact with grocery products before or during purchasing.

The `extract_mongo.py` script connects to the MongoDB `grocerydb` database and reads data from the `customer_activity` collection.

The extracted MongoDB output is saved as:

```bash
data/raw/mongo_activity_raw.json
```

The extracted fields include:

```text
customer_name
product
category
activity
timestamp
session_id
device_type
```

MongoDB records may also contain an `_id` field. During extraction, this value is converted into a string where necessary so that the raw JSON output can be saved successfully.

This raw JSON file represents customer behavioural activity such as:

- product viewed
- product added to cart
- product purchased

---

## Transform Phase

The Transform phase reads the raw extracted files from `data/raw/` and produces cleaned, warehouse-ready CSV files in `data/cleaned/`.

The transformation script used is:

```bash
etl-scripts/transform_data.py
```

The transformation process standardises the structure, naming, and data types of the extracted datasets so they can be loaded into PostgreSQL consistently.

The cleaned outputs are:

```bash
data/cleaned/orders_clean.csv
data/cleaned/activity_clean.csv
```

### Orders Dataset Transformation

The raw MySQL orders extract is transformed into:

```bash
data/cleaned/orders_clean.csv
```

The transformation process for the orders dataset includes:

- standardising column names to lowercase snake_case
- keeping only the required warehouse columns
- ensuring columns are in the correct order
- converting `order_date` into a consistent date format
- validating numeric fields such as `quantity`, `unit_price`, and `line_total`
- removing rows with missing critical values such as `order_id`, `customer_name`, or `product`
- trimming unnecessary whitespace from text fields
- standardising product names where needed to support later integration with MongoDB activity data

The cleaned orders dataset is prepared for loading into the PostgreSQL staging table:

```bash
grocery.orders_dw
```

### Customer Activity Dataset Transformation

The raw MongoDB customer activity extract is transformed into:

```bash
data/cleaned/activity_clean.csv
```

The transformation process for the activity dataset includes:

- removing the MongoDB `_id` field
- renaming `timestamp` to `activity_timestamp`
- keeping only the required warehouse columns
- standardising activity values such as `Viewed`, `Added to Cart`, and `Purchased`
- ensuring timestamp values are consistent
- removing rows with missing critical values such as `customer_name`, `product`, or `activity`
- trimming unnecessary whitespace from text fields
- standardising product names so that MongoDB activity data can correctly join with MySQL order data

Examples of product name standardisation include:

```text
Maize Meal (5kg) → Maize Meal 5kg
Apples (Granny Smith) → Apples Granny Smith
```

This standardisation is important because the final integration step joins the MySQL-derived order data and MongoDB-derived activity data using:

```text
customer_name
product
```

The cleaned activity dataset is prepared for loading into the PostgreSQL staging table:

```bash
grocery.customer_activity
```

---

## Load Phase into PostgreSQL Data Warehouse

After the raw data has been extracted and transformed, the cleaned CSV files are loaded into the PostgreSQL data warehouse. PostgreSQL is used as the OLAP layer because it stores cleaned and structured datasets for analytical querying and reporting.

The cleaned files used for loading are:

```bash
data/cleaned/orders_clean.csv
data/cleaned/activity_clean.csv
```

The official warehouse loading process is handled using SQL scripts stored in:

```bash
sql-scripts/data-warehouse-scripts/
```

These scripts create the warehouse schema, load staging data, populate dimension tables, populate the fact table, and create the final integrated analytics table.

The cleaned orders dataset is loaded into:

```bash
grocery.orders_dw
```

The cleaned customer activity dataset is loaded into:

```bash
grocery.customer_activity
```

The warehouse then uses these staging tables to populate the star schema tables:

```text
grocery.dim_customer
grocery.dim_product
grocery.dim_date
grocery.dim_payment
grocery.dim_activity
grocery.fact_sales
```

The final integrated analytics table is:

```bash
grocery.customer_analytics
```

This table combines customer order data from MySQL with customer activity data from MongoDB. The integration is based mainly on matching:

```text
customer_name
product
```

This allows the system to analyse customer behaviour together with actual purchase activity.

---

## PostgreSQL Warehouse Script Flow

The PostgreSQL data warehouse scripts are executed after the ETL transformation step. They follow this order:

```bash
01_create_schema_and_tables.sql
02_load_staging_data.sql
03_populate_dimensions.sql
04_populate_fact_table.sql
05_create_customer_analytics.sql
06_verify_all_tables.sql
07_show_sample_data.sql
```

### Purpose of Each Warehouse Script

| Script | Purpose |
|---|---|
| `01_create_schema_and_tables.sql` | Creates the `grocery` schema, staging tables, dimension tables, fact table, and customer analytics table |
| `02_load_staging_data.sql` | Loads cleaned CSV files into `grocery.orders_dw` and `grocery.customer_activity` |
| `03_populate_dimensions.sql` | Populates dimension tables such as customers, products, dates, payments, and activities |
| `04_populate_fact_table.sql` | Loads transactional sales data into the `grocery.fact_sales` fact table |
| `05_create_customer_analytics.sql` | Integrates order and activity data into the final `grocery.customer_analytics` table |
| `06_verify_all_tables.sql` | Verifies row counts and confirms that the warehouse tables were populated |
| `07_show_sample_data.sql` | Displays sample warehouse data for reporting and evidence purposes |

---

## ETL Execution Commands

The ETL process can be executed in the following order:

```bash
python etl-scripts/extract_mysql.py
python etl-scripts/extract_mongo.py
python etl-scripts/transform_data.py
```

After the cleaned CSV files have been generated, the PostgreSQL warehouse scripts are executed inside the PostgreSQL container:

```bash
\i /warehouse-scripts/01_create_schema_and_tables.sql
\i /warehouse-scripts/02_load_staging_data.sql
\i /warehouse-scripts/03_populate_dimensions.sql
\i /warehouse-scripts/04_populate_fact_table.sql
\i /warehouse-scripts/05_create_customer_analytics.sql
\i /warehouse-scripts/06_verify_all_tables.sql
\i /warehouse-scripts/07_show_sample_data.sql
```

The `docker-compose.yml` file mounts the cleaned data and warehouse scripts into the PostgreSQL container, allowing PostgreSQL to access the files without manually copying them into the container.

---

## Evidence of ETL Execution

Screenshots were captured to provide evidence that the ETL extraction process was executed successfully from the command line and that data was extracted from the source databases.

### Python Extraction Response

The screenshot below shows the Python extraction response after running the extraction scripts. It provides evidence that the extraction process executed successfully and produced output files for the raw data stage.

![Python Extraction Response](docs/screenshots/etl-screenshots/Python%20Extraction%20Response.png)

### Python Data Extraction from Source Databases

The screenshot below shows the extracted data outputs from the source databases. It supports the ETL evidence by showing that the MySQL and MongoDB source data was extracted and stored for further processing.

![Python Data Extraction from Source DBs](docs/screenshots/etl-screenshots/Python%20Data%20Extraction%20from%20Source%20DBs.png)

These screenshots support the ETL documentation by showing that the extraction stage was performed using Python scripts and not through manually created datasets.

---

## ETL Process Summary

| ETL Stage | Input | Process | Output |
|---|---|---|---|
| Extract: MySQL | MySQL `grocerydb` transactional tables | Joins order, customer, product, category, and item data | `data/raw/mysql_orders_raw.csv` |
| Extract: MongoDB | MongoDB `grocerydb.customer_activity` collection | Reads customer behavioural activity documents | `data/raw/mongo_activity_raw.json` |
| Transform: Orders | `data/raw/mysql_orders_raw.csv` | Cleans column names, validates data types, removes invalid rows, standardises product names | `data/cleaned/orders_clean.csv` |
| Transform: Activity | `data/raw/mongo_activity_raw.json` | Removes `_id`, renames timestamp field, validates activity values, standardises product names | `data/cleaned/activity_clean.csv` |
| Load: PostgreSQL | Cleaned CSV files | Loads cleaned data into PostgreSQL staging tables using SQL scripts and `COPY` | `grocery.orders_dw`, `grocery.customer_activity` |
| Warehouse Integration | PostgreSQL staging tables | Populates dimensions, fact table, and integrated analytics table | `grocery.fact_sales`, `grocery.customer_analytics` |

---

## ETL Process Summary Explanation

The ETL process ensures that data from the two source systems is extracted, cleaned, standardised, and prepared for analytical use. MySQL provides structured transactional sales data, while MongoDB provides customer behavioural activity data.

The raw extracts are stored separately in `data/raw/`, which keeps the original extracted data available for traceability. The transformed outputs are stored in `data/cleaned/`, where they are ready for loading into PostgreSQL.

Once loaded into PostgreSQL, the warehouse scripts create staging tables, populate dimension tables, load the sales fact table, and generate the final `customer_analytics` table. This final table supports business intelligence reporting by combining what customers bought with how they interacted with products before or during the purchase process.

---

## Assumptions

The ETL process assumes that:

- Docker containers for MySQL, MongoDB, and PostgreSQL are running before the ETL scripts are executed.
- MySQL has been seeded with grocery transactional data.
- MongoDB has been seeded with customer activity data.
- Raw extracted files are stored in `data/raw/`.
- Cleaned transformed files are stored in `data/cleaned/`.
- PostgreSQL warehouse loading is handled using SQL scripts under `sql-scripts/data-warehouse-scripts/`.
- Product names are standardised during transformation to support accurate joins between MySQL and MongoDB-derived datasets.
- Metabase connects to the PostgreSQL data warehouse after the warehouse tables have been created and populated.
