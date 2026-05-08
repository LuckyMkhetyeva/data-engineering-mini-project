# folder: docs/bi-metabase.md
# BI Metadata - FreshMart

## Data Dictionary (`grocery.customer_analytics`)

| Field Name | Source System | Data Type | Description | BI Usage |
|---|---|---|---|---|
| `customer_name` | MySQL + MongoDB (integrated) | `TEXT` | Customer name aligned across orders and activity records. | Slice revenue and behaviour by customer; top customer analysis. |
| `product` | MySQL + MongoDB (integrated) | `TEXT` | Standardized product name. | Product performance, conversion-style activity analysis. |
| `category` | MySQL | `TEXT` | Product category from transaction source. | Category-level revenue comparisons. |
| `activity` | MongoDB | `TEXT` | Customer action (`Viewed`, `Added to Cart`, `Purchased`). | Behaviour distribution and funnel-style visuals. |
| `line_total` | MySQL | `NUMERIC(12,2)` | Order line amount (`quantity * unit_price`). | Primary revenue metric for BI charts. |
| `order_date` | MySQL | `DATE` | Date when order was placed. | Time-series reporting and period comparisons. |
| `activity_timestamp` | MongoDB | `TIMESTAMP` | Time when behavioural event occurred. | Customer journey sequencing and temporal analysis. |
| `payment_method` | MySQL | `TEXT` | Payment method used for the order line. | Revenue by payment method visuals. |
| `order_status` | MySQL | `TEXT` | Transaction status (e.g., Completed, Refunded). | Revenue filters and quality control in dashboards. |
| `device_type` | MongoDB | `TEXT` | Device used for activity event (e.g., Mobile, Desktop). | Device behaviour segmentation. |

## Business Rules

1. Use only `Completed` orders for core revenue KPIs unless refund analysis is explicitly required.
2. Calculate revenue with `line_total`.
3. Match customer behaviour to sales using `customer_name` + `product`.
4. Standardize activity values to: `Viewed`, `Added to Cart`, `Purchased`.
5. Standardize product names before integrating source datasets.
6. Convert date/time fields to PostgreSQL-compatible `DATE` and `TIMESTAMP` formats.
7. Do not load records with null/blank `customer_name` or `product` into the analytics table.
8. Exclude refunded orders from default business dashboards, or clearly label them when included.