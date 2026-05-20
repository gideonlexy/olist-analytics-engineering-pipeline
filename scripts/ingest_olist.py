import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data" / "olist"

DB_URL = os.getenv("DB_URL")
if not DB_URL:
    raise ValueError("DB_URL environment variable is not set")

FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "product_category_name_translation.csv": "category_name_translation",
}


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df.columns = df.columns.str.lower().str.replace(" ", "_", regex=False)
    return df


def table_exists(conn, table_name: str) -> bool:
    result = conn.execute(
        text(
            """
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.tables
                WHERE table_schema = 'raw'
                  AND table_name = :table_name
            );
            """
        ),
        {"table_name": table_name},
    )
    return result.scalar()


def main() -> None:
    engine = create_engine(DB_URL)

    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))

    for file_name, table in FILES.items():
        path = DATA_DIR / file_name

        if not path.exists():
            raise FileNotFoundError(f"Missing file: {path}")

        print(f"Loading {file_name} into raw.{table}")

        df = pd.read_csv(path)
        df = normalize_columns(df)

        with engine.begin() as conn:
            if table_exists(conn, table):
                conn.execute(text(f'TRUNCATE TABLE raw."{table}" RESTART IDENTITY CASCADE;'))

            df.to_sql(
                table,
                con=conn,
                schema="raw",
                if_exists="append",
                index=False,
                chunksize=10_000,
                method="multi",
            )

        print(f"Loaded raw.{table}: {len(df):,} rows")

    print("Raw ingestion completed successfully.")


if __name__ == "__main__":
    main()