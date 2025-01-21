# db_loader.py
import pandas as pd
from sqlalchemy import create_engine
import gzip
import os
from dotenv import load_dotenv
import sys

# Load environment variables
load_dotenv()

# Database Configuration from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")  
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Data URLs
GREEN_TAXI_DATA_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
ZONE_LOOKUP_DATA_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"

# File Paths
GREEN_TAXI_FILE = "green_tripdata_2019-10.csv.gz"
ZONE_LOOKUP_FILE = "taxi_zone_lookup.csv"

def download_data():
    """Download the required data files."""
    print("Downloading data files...")
    
    # Download green taxi data
    if not os.path.exists(GREEN_TAXI_FILE):
        os.system(f"wget -O {GREEN_TAXI_FILE} {GREEN_TAXI_DATA_URL}")
        print(f"Downloaded {GREEN_TAXI_FILE} successfully ✅")
    else:
        print(f"{GREEN_TAXI_FILE} already exists, skipping download")
    
    # Download zone lookup data
    if not os.path.exists(ZONE_LOOKUP_FILE):
        os.system(f"wget -O {ZONE_LOOKUP_FILE} {ZONE_LOOKUP_DATA_URL}")
        print(f"Downloaded {ZONE_LOOKUP_FILE} successfully ✅")
    else:
        print(f"{ZONE_LOOKUP_FILE} already exists, skipping download")

def load_data_to_postgres():
    """Load the datasets into the PostgreSQL database."""
    print("Connecting to the database...")
    connection_string = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    
    success = True
    
    try:
        engine = create_engine(connection_string)
        # Load Green Taxi Data
        print("Loading green taxi data...")
        with gzip.open(GREEN_TAXI_FILE, 'rt') as file:
            green_taxi_data = pd.read_csv(file, low_memory=False)
        green_taxi_data.to_sql('green_taxi_trips', engine, if_exists='replace', index=False)
        print("Green taxi data loaded successfully ✅")

        # Load Zone Lookup Data
        print("Loading zone lookup data...")
        zone_lookup_data = pd.read_csv(ZONE_LOOKUP_FILE)
        zone_lookup_data.to_sql('taxi_zones', engine, if_exists='replace', index=False)
        print("Zone lookup data loaded successfully ✅")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        success = False
        
    return success

if __name__ == "__main__":
    print("Starting data loading process...")
    
    try:
        download_data()
        print("\nStarting database loading...")
        if load_data_to_postgres():
            print("\nData loading process completed successfully! ✅")
        else:
            print("\nData loading process failed! ❌")
            sys.exit(1)
    except Exception as e:
        print(f"\nAn error occurred: {e}")
        sys.exit(1)