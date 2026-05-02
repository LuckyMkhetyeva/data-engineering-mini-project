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
├── etl-scripts/
├── mongo-scripts/
│   ├── mongo_seed.json
│   └── mongo_queries.js
├── sql-scripts/
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
