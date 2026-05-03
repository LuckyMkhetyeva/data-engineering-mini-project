from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError


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


def get_repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def require_env_var(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise ValueError(f"[ERROR] Missing required environment variable: {name}")
    return value


def validate_columns(df: pd.DataFrame, expected_columns: list[str], dataset_name: str) -> None:
    missing = [col for col in expected_columns if col not in df.columns]
    if missing:
        raise ValueError(
            f"[ERROR] {dataset_name} is missing required columns: {', '.join(missing)}"
        )


def read_cleaned_csv(csv_path: Path, expected_columns: list[str], dataset_name: str) -> pd.DataFrame:
    if not csv_path.exists():
        raise FileNotFoundError(
            "[ERROR] Missing cleaned dataset: "
            f"{csv_path}. Run transform step first: python etl-scripts/transform.py"
        )

    try:
        df = pd.read_csv(csv_path)
    except Exception as exc:
        raise ValueError(f"[ERROR] Failed to read {dataset_name} CSV ({csv_path}): {exc}") from exc

    validate_columns(df, expected_columns, dataset_name)
    return df[expected_columns]


def build_dw_engine():
    host = require_env_var("DW_HOST")
    port = os.environ.get("DW_PORT", "5432")
    database = require_env_var("DW_DATABASE")
    user = require_env_var("DW_USER")
    password = require_env_var("DW_PASSWORD")

    connection_url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}"
    return create_engine(connection_url)


def main() -> None:
    repo_root = get_repo_root()
    orders_path = repo_root / "data" / "cleaned" / "orders_clean.csv"
    activity_path = repo_root / "data" / "cleaned" / "activity_clean.csv"

    print("[INFO] Starting warehouse load process...")
    print(f"[INFO] Loading cleaned orders data from: {orders_path}")
    orders_df = read_cleaned_csv(orders_path, ORDERS_COLUMNS, "orders_clean")

    print(f"[INFO] Loading cleaned activity data from: {activity_path}")
    activity_df = read_cleaned_csv(activity_path, ACTIVITY_COLUMNS, "activity_clean")

    print("[INFO] Connecting to data warehouse...")
    try:
        engine = build_dw_engine()
        with engine.begin() as connection:
            # We replace table contents on each load.
            # Future production versions should use incremental loads or upserts.
            orders_df.to_sql("dw_orders", connection, if_exists="replace", index=False)
            activity_df.to_sql("dw_customer_activity", connection, if_exists="replace", index=False)
    except (ValueError, SQLAlchemyError) as exc:
        raise RuntimeError(f"[ERROR] Data warehouse load failed: {exc}") from exc

    print("[INFO] Successfully loaded dw_orders and dw_customer_activity.")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(exc)
        raise SystemExit(1)
