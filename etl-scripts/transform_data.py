# ============================================================
# DMS580S Mini Project 2026
# ETL Layer: Transforming Data. To be loaded to the warehouse
# Domain: Grocery & Supermarket Retail (FreshMart)
# Author: Ongeziwe J. Mtolo - 221205276
# ============================================================

from __future__ import annotations

import json
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MYSQL_RAW_PATH = PROJECT_ROOT / "data" / "raw" / "mysql_orders_raw.csv"
MONGO_RAW_PATH = PROJECT_ROOT / "data" / "raw" / "mongo_activity_raw.json"

ORDERS_CLEAN_PATH = PROJECT_ROOT / "data" / "cleaned" / "orders_clean.csv"
ACTIVITY_CLEAN_PATH = PROJECT_ROOT / "data" / "cleaned" / "activity_clean.csv"

PRODUCT_NAME_MAPPING = {
    "Maize Meal (5kg)": "Maize Meal 5kg",
    "Apples (Granny Smith)": "Apples Granny Smith",
}

ORDERS_COLUMNS = [
    "order_id",
    "order_date",
    "customer_name",
    "product",
    "category",
    "quantity",
    "unit_price",
    "line_total",
    "payment_method",
    "order_status",
]

ACTIVITY_COLUMNS = [
    "customer_name",
    "product",
    "category",
    "activity",
    "activity_timestamp",
    "device_type",
    "session_id",
]

ALLOWED_ACTIVITY_MAP = {
    "viewed": "Viewed",
    "added to cart": "Added to Cart",
    "purchased": "Purchased",
}


def to_snake_case(columns: list[str]) -> list[str]:
    return [str(column).strip().lower().replace(" ", "_") for column in columns]


def strip_text_columns(dataframe: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    for column in columns:
        series = dataframe[column]
        dataframe[column] = series.where(series.isna(), series.astype(str).str.strip())
    return dataframe


def transform_orders() -> pd.DataFrame:
    try:
        orders_df = pd.read_csv(MYSQL_RAW_PATH)
    except FileNotFoundError as error:
        raise FileNotFoundError(
            "Raw MySQL extract not found. Run etl-scripts/extract_mysql.py first."
        ) from error
    except pd.errors.ParserError as error:
        raise ValueError(f"Invalid CSV input at {MYSQL_RAW_PATH}: {error}") from error

    print(f"[INFO] Loaded raw MySQL extract: {len(orders_df)} rows")

    orders_df.columns = to_snake_case(list(orders_df.columns))

    missing_columns = [column for column in ORDERS_COLUMNS if column not in orders_df.columns]
    if missing_columns:
        raise ValueError(f"Missing required MySQL columns: {missing_columns}")

    orders_df = orders_df[ORDERS_COLUMNS].copy()

    text_columns = ["customer_name", "product", "category", "payment_method", "order_status"]
    orders_df = strip_text_columns(orders_df, text_columns)

    orders_df["product"] = orders_df["product"].replace(PRODUCT_NAME_MAPPING)

    orders_df["order_id"] = pd.to_numeric(orders_df["order_id"], errors="coerce")
    orders_df["quantity"] = pd.to_numeric(orders_df["quantity"], errors="coerce")
    orders_df["unit_price"] = pd.to_numeric(orders_df["unit_price"], errors="coerce")
    orders_df["line_total"] = pd.to_numeric(orders_df["line_total"], errors="coerce")
    orders_df["order_date"] = pd.to_datetime(orders_df["order_date"], errors="coerce")

    before_drop = len(orders_df)
    required_mask = (
        orders_df["order_id"].notna()
        & orders_df["customer_name"].notna()
        & (orders_df["customer_name"] != "")
        & orders_df["product"].notna()
        & (orders_df["product"] != "")
    )
    orders_df = orders_df[required_mask].copy()
    removed_rows = before_drop - len(orders_df)
    if removed_rows:
        print(f"[WARN] Removed {removed_rows} invalid order rows")

    orders_df["order_id"] = orders_df["order_id"].astype("int64")
    orders_df["quantity"] = orders_df["quantity"].astype("Int64")
    orders_df["order_date"] = orders_df["order_date"].dt.strftime("%Y-%m-%d")

    print(f"[INFO] Cleaned orders dataset: {len(orders_df)} rows")
    return orders_df


def normalize_activity_values(series: pd.Series) -> pd.Series:
    normalized = series.where(series.isna(), series.astype(str).str.strip())
    normalized_key = normalized.where(
        normalized.isna(), normalized.str.replace(r"\s+", " ", regex=True).str.lower()
    )
    return normalized_key.map(ALLOWED_ACTIVITY_MAP).fillna(normalized)


def transform_activity() -> pd.DataFrame:
    try:
        with MONGO_RAW_PATH.open("r", encoding="utf-8") as file:
            documents = json.load(file)
    except FileNotFoundError as error:
        raise FileNotFoundError(
            "Raw MongoDB extract not found. Run etl-scripts/extract_mongo.py first."
        ) from error
    except json.JSONDecodeError as error:
        raise ValueError(f"Invalid JSON input at {MONGO_RAW_PATH}: {error}") from error

    if not isinstance(documents, list):
        raise ValueError("MongoDB raw JSON must contain a list of documents.")

    activity_df = pd.DataFrame(documents)
    print(f"[INFO] Loaded raw MongoDB extract: {len(activity_df)} documents")

    if "_id" in activity_df.columns:
        activity_df = activity_df.drop(columns=["_id"])

    activity_df.columns = to_snake_case(list(activity_df.columns))
    if "timestamp" in activity_df.columns:
        activity_df = activity_df.rename(columns={"timestamp": "activity_timestamp"})

    missing_columns = [column for column in ACTIVITY_COLUMNS if column not in activity_df.columns]
    if missing_columns:
        raise ValueError(f"Missing required MongoDB fields: {missing_columns}")

    activity_df = activity_df[ACTIVITY_COLUMNS].copy()

    activity_df = strip_text_columns(activity_df, ACTIVITY_COLUMNS)

    activity_df["activity"] = normalize_activity_values(activity_df["activity"])
    activity_df["product"] = activity_df["product"].replace(PRODUCT_NAME_MAPPING)

    before_drop = len(activity_df)
    required_mask = (
        activity_df["customer_name"].notna()
        & (activity_df["customer_name"] != "")
        & activity_df["product"].notna()
        & (activity_df["product"] != "")
        & activity_df["activity"].notna()
        & (activity_df["activity"] != "")
    )
    activity_df = activity_df[required_mask].copy()
    removed_rows = before_drop - len(activity_df)
    if removed_rows:
        print(f"[WARN] Removed {removed_rows} invalid activity rows")

    activity_df["activity_timestamp"] = pd.to_datetime(
        activity_df["activity_timestamp"], errors="coerce"
    ).dt.strftime("%Y-%m-%d %H:%M:%S")

    print(f"[INFO] Cleaned activity dataset: {len(activity_df)} rows")
    return activity_df


def save_dataframe(df: pd.DataFrame, output_path: Path, label: str) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    relative_output = output_path.relative_to(PROJECT_ROOT)

    if output_path.exists():
        print(f"[INFO] Existing file found. Overwriting: {relative_output}")

    try:
        df.to_csv(output_path, index=False)
    except OSError as error:
        raise OSError(f"Unable to write {output_path}: {error}") from error

    print(f"[INFO] Saved cleaned {label} to: {relative_output}")


def main() -> None:
    try:
        orders_clean = transform_orders()
        activity_clean = transform_activity()

        save_dataframe(orders_clean, ORDERS_CLEAN_PATH, "orders")
        save_dataframe(activity_clean, ACTIVITY_CLEAN_PATH, "activity")
    except (FileNotFoundError, ValueError, OSError) as error:
        print(f"[ERROR] {error}")


if __name__ == "__main__":
    main()
