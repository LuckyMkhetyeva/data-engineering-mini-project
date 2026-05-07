# Data Engineering Mini Project – Grocery & Supermarket BI Pipeline

## Overview
This project implements an end-to-end BI pipeline for a grocery/supermarket retail domain:

**MySQL + MongoDB → ETL Scripts → Raw Data → Transform → Cleaned Data → PostgreSQL Data Warehouse → Metabase Dashboards**

## Current Scope (Phase 1)
This repository currently covers **OLTP source setup and repository structure cleanup**.
ETL implementation is intentionally deferred to the next phase.

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
├── docs/
│   └── screenshots/
│       ├── star_schema_diagram.png
│       ├── mysql_source_data.png
│       ├── mongodb_source_data.png
│       ├── postgres_connection.png
│       ├── tables_created.png
│       ├── all_tables.png
│       ├── orders_dw_structure.png
│       ├── customer_activity_structure.png
│       ├── customer_analytics_structure.png
│       ├── fact_sales_fks.png
│       ├── csv_copied.png
│       ├── staging_loaded.png
│       ├── dimensions_populated.png
│       ├── fact_table_loaded.png
│       ├── star_schema_preview.png
│       ├── integration_insert.png
│       ├── integrated_preview.png
│       ├── final_verification.png
│       └── sample_data.png
├── etl-scripts/
├── mongo-scripts/
│   ├── mongo_seed.json
│   └── mongo_queries.js
├── sql-scripts/
│   └── data-warehouse-scripts/
│       ├── 01_create_schema_and_tables.sql
│       ├── 02_load_staging_data.sql
│       ├── 03_populate_dimensions.sql
│       ├── 04_populate_fact_table.sql
│       ├── 05_create_customer_analytics.sql
│       ├── 06_verify_all_tables.sql
│       └── 07_show_sample_data.sql
│   ├── mysql_schema.sql
│   ├── postgres_dw_schema.sql
│   ├── load_dw.sql
│   └── analytics_queries.sql
├── README.md
└── docker-compose.yaml
```

## Notes
- `data/raw` and `data/cleaned` are tracked with `.gitkeep` only until ETL outputs are generated.
- MongoDB seed data is stored as JSON (`mongo_seed.json`) for straightforward `mongoimport` usage.
- SQL scripts are separated by platform purpose (MySQL OLTP, PostgreSQL DW, load template, analytics queries).
