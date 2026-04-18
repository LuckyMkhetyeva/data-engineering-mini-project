# Data Engineering Mini Project – BI Pipeline

## Overview

This project implements an end-to-end **Business Intelligence (BI) pipeline** within a retail analytics context. The system simulates a real-world data engineering workflow where operational systems generate data that is transformed into structured analytical insights through a governed **ETL (Extract, Transform, Load)** process and stored in a centralized data warehouse.

The pipeline follows a layered architecture:

- **OLTP Systems**: MySQL (transactional data) and MongoDB (behavioral data)
- **ETL Process**: Data extraction, cleaning, transformation, and loading
- **OLAP System**: PostgreSQL data warehouse
- **BI Layer**: Metabase dashboards and visualizations

---

## System Architecture

 This section will be updated with Mermaid and PlantUML diagrams.

The system flow is as follows:

```bash
MySQL + MongoDB → ETL → PostgreSQL → Metabase
```

- MySQL stores structured transactional data (orders)
- MongoDB stores semi-structured behavioral data (customer activity)
- ETL integrates and standardizes the data
- PostgreSQL stores analytical datasets
- Metabase provides dashboards and insights

Project Structure

```bash
data-engineering-mini-project/
├── docker-compose.yml
├── README.md
├── sql/
│   ├── ...
├── mongo/
│   ├──...
│   ├──...
├── data/
│   ├── raw/
│   └── cleaned/
├── docs/
│   ├── screenshots/
│   ├── ...
└── diagrams/
    ├── ...
```

## Project Domain - 
