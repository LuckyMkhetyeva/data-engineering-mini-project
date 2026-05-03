# =================================================================
# DMS580S Mini Project 2026
# ETL Layer: Extracting MySQL raw data. Prepping for transformation
# Domain: Grocery & Supermarket Retail (FreshMart)
# Author: Ongeziwe J. Mtolo - 221205276
# =================================================================

from __future__ import annotations

import csv
from pathlib import Path
from typing import Any

import mysql.connector
from mysql.connector import Error

DB_CONFIG = {
    "host": "localhost",
    "port": 3309,
    "user": "root",
    "password": "rootpass",
    "database": "grocerydb",
}

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_CSV_PATH = PROJECT_ROOT / "data" / "raw" / "mysql_orders_raw.csv"

EXTRACT_QUERY = """
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name AS product,
    cat.category_name AS category,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    o.payment_method,
    o.order_status
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories cat
    ON p.category_id = cat.category_id
ORDER BY o.order_date, o.order_id, oi.item_id;
""".strip()


def connect_db() -> Any:
    """Create and return a MySQL database connection."""
    connection = mysql.connector.connect(**DB_CONFIG)
    print("[INFO] Successfully connected to MySQL database.")
    return connection


def extract_data(connection: Any) -> tuple[list[tuple[Any, ...]], list[str]]:
    """Run the extract query and return rows plus column headers."""
    cursor = connection.cursor()
    try:
        cursor.execute(EXTRACT_QUERY)
        rows = cursor.fetchall()
        headers = [column[0] for column in cursor.description]
        print(f"[INFO] Extracted {len(rows)} rows from MySQL.")
        return rows, headers
    finally:
        cursor.close()


def save_to_csv(rows: list[tuple[Any, ...]], headers: list[str], output_path: Path) -> None:
    """Save extracted rows and headers to a UTF-8 CSV file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", encoding="utf-8", newline="") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(headers)
        writer.writerows(rows)

    relative_output = output_path.relative_to(PROJECT_ROOT)
    print(f"[INFO] Raw MySQL extract saved to: {relative_output}")


def main() -> None:
    """Extract raw MySQL order data and save it to a CSV file."""
    connection = None

    try:
        connection = connect_db()
        rows, headers = extract_data(connection)
        save_to_csv(rows, headers, OUTPUT_CSV_PATH)
    except Error as error:
        print(f"[ERROR] {error}")
    except OSError as error:
        print(f"[ERROR] {error}")
    finally:
        if connection is not None and connection.is_connected():
            connection.close()
            print("[INFO] MySQL connection closed.")


if __name__ == "__main__":
    main()
