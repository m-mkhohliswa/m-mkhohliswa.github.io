from sqlalchemy import create_engine
from pathlib import Path
import pandas as pd
import pymysql
import urllib.parse
import cryptography

DB_PASSWORD = urllib.parse.quote_plus("Mkhohliswa@1407")
DB_HOST     = "localhost"
DB_NAME     = "sp_companies_db"
DB_USERNAME = "root"


engine = create_engine(f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}")

files = {
    "01_company_info":            "company_info",
    "02_company_news_sentiment":  "company_news_sentiment",
    "03_company_balance_sheet":   "company_balance_sheet",
    "04_company_financials":      "company_financials",
    "05_company_filings":         "company_filings",
    "06_company_officers":        "company_officers",
}

for filename, table_name in files.items():
    filepath = rf"C:\Users\musam\GitHubProjects\kagglehub\datasets\sadiqguru\s-and-p-500-stock-data-along-with-financials-and-news\versions\6\{filename}.csv"
    print(f"Loading {filename}...")

    first_chunk = True
    for chunk in pd.read_csv(filepath, chunksize=1000):
        if first_chunk:
            chunk.to_sql(table_name, con=engine, if_exists="replace", index=False)
            first_chunk = False
        else:
            chunk.to_sql(table_name, con=engine, if_exists="append", index=False)

    print(f"  ✓ Table '{table_name}' written successfully")

print("\nAll files loaded successfully!")

price_data_dir = r"C:\Users\musam\Portfolio_Analysis\price_data"

for csv_file in sorted(price_data_dir.glob("*.csv")):
    # Use the filename (without extension) as the table name
    table_name = csv_file.stem.lower()  # e.g. "AAPL" -> "aapl"
    print(f"Loading {csv_file.name}...")

    first_chunk = True
    for chunk in pd.read_csv(csv_file, chunksize=1000):
        if first_chunk:
            chunk.to_sql(table_name, con=engine, if_exists="replace", index=False)
            first_chunk = False
        else:
            chunk.to_sql(table_name, con=engine, if_exists="append", index=False)

    print(f"  ✓ Table '{table_name}' written successfully")

print("\nAll files loaded successfully!")

