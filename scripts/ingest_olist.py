import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv 

load_dotenv()

DATA_DIR = Path("data/olist")
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
    "product_category_name_translation.csv": "category_name_translation"
}

# Function to normalize column names
def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df.columns = df.columns.str.lower().str.replace(" ", "_")
    return df

def main():
  
    engine = create_engine(DB_URL)

    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))

    for file_name, table in FILES.items():
        path = DATA_DIR / file_name
        if not path.exists():
            raise FileNotFoundError(f"Missing file: {path}")
        
        df = pd.read_csv(path)
        df = normalize_columns(df)
       
        df.to_sql(
            table,
            con = engine,
            schema = "raw",
            if_exists= "replace",
            index = False,
            chunksize = 10_000
        )

        print(f"Loaded raw.{table}: {len(df):,} rows ")

if __name__ == "__main__":
    main()