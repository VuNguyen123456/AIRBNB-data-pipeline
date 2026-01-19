# Airbnb End-to-End Data Engineering Pipeline

A production-grade data pipeline implementing medallion architecture (Bronze → Silver → Gold) with dimensional modeling, built using AWS S3, Snowflake, and dbt.

![Pipeline Architecture](https://img.shields.io/badge/AWS-S3-orange) ![Snowflake](https://img.shields.io/badge/Snowflake-Data_Warehouse-blue) ![dbt](https://img.shields.io/badge/dbt-Transform-red) ![Python](https://img.shields.io/badge/Python-3.12-green)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Data Flow](#data-flow)
- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Running the Pipeline](#running-the-pipeline)
- [Data Models](#data-models)
- [Testing](#testing)
- [Security](#security)
- [Learning Outcomes](#learning-outcomes)

---

## 🎯 Project Overview

This project demonstrates a complete data engineering workflow for processing Airbnb booking data. It transforms raw CSV files from AWS S3 through multiple transformation layers in Snowflake using dbt, ultimately creating both a denormalized One Big Table (OBT) and an optimized Star Schema for analytics.

**Dataset:**
- 500 listings across multiple cities
- 200 hosts with performance metrics
- 5,000+ booking transactions

---

## 🏗️ Architecture

```
┌─────────────┐
│   AWS S3    │  Raw CSV files (listings.csv, hosts.csv, bookings.csv)
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│                    SNOWFLAKE                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │  STAGING SCHEMA (Raw Landing Zone)              │   │
│  │  - listings, bookings, hosts                    │   │
│  └────────────────┬────────────────────────────────┘   │
│                   │                                     │
│                   ▼                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │  BRONZE LAYER (Raw with Incremental Loading)    │   │
│  │  - bronze_listings                              │   │
│  │  - bronze_bookings                              │   │
│  │  - bronze_hosts                                 │   │
│  └────────────────┬────────────────────────────────┘   │
│                   │                                     │
│                   ▼                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │  SILVER LAYER (Cleaned & Business Logic)        │   │
│  │  - silver_listings (price tagging)              │   │
│  │  - silver_bookings (calculated amounts)         │   │
│  │  - silver_hosts (response rate quality tiers)   │   │
│  └────────────────┬────────────────────────────────┘   │
│                   │                                     │
│                   ▼                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │  GOLD LAYER (Analytics-Ready)                   │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │  One Big Table (OBT)                     │   │   │
│  │  │  - Metadata-driven pipeline              │   │   │
│  │  │  - Denormalized for easy querying        │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │  Star Schema (Dimensional Model)         │   │   │
│  │  │  - fact_bookings                         │   │   │
│  │  │  - dim_listings (SCD Type 2)             │   │   │
│  │  │  - dim_hosts (SCD Type 2)                │   │   │
│  │  │  - dim_bookings (SCD Type 2)             │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 💻 Technologies Used

| Technology | Purpose |
|------------|---------|
| **AWS S3** | Object storage for raw CSV files |
| **Snowflake** | Cloud data warehouse for data storage and compute |
| **dbt (Data Build Tool)** | SQL-based transformation framework |
| **Jinja** | Templating language for dynamic SQL generation |
| **Python** | Package management and environment setup |
| **Git/GitHub** | Version control and collaboration |
| **SQL** | Data transformation and querying |

---

## 🔄 Data Flow

### Medallion Architecture

**Bronze Layer (Raw)**
- Direct copy from staging with incremental loading
- Preserves source data exactly as-is
- Serves as single source of truth
- Uses `created_at` timestamp for incremental updates

**Silver Layer (Cleaned)**
- Data cleaning and standardization
- Business logic application
- Derived columns and calculations
- Example transformations:
  - Response rate quality categorization (VERY_GOOD, GOOD, FAIR, POOR)
  - Price tier tagging (low, mid, high)
  - Total booking amount calculations

**Gold Layer (Analytics-Ready)**
- **One Big Table (OBT):** Metadata-driven denormalized table for easy analytics
- **Star Schema:** Optimized dimensional model with fact and dimension tables
- Slowly Changing Dimensions (SCD Type 2) for historical tracking

---

## ⚡ Key Features

### 1. **Incremental Loading**
- Reduces compute costs by processing only new records
- Based on `created_at` timestamp comparison
- Saves 80%+ in processing time for large datasets

### 2. **Metadata-Driven Pipeline**
- Configuration-based SQL generation using Jinja
- Add new tables by updating config array - no SQL changes needed
- Highly maintainable and scalable approach

```sql
{% set configs = [
    {"table": "...", "columns": "...", "join_condition": "..."},
    {"table": "...", "columns": "...", "join_condition": "..."}
] %}
```

### 3. **Slowly Changing Dimensions (SCD Type 2)**
- Tracks historical changes in dimension tables
- Preserves full audit trail with `dbt_valid_from` and `dbt_valid_to`
- Enables time-travel analytics

### 4. **Custom Jinja Macros**
- Reusable SQL functions for common operations
- Examples: `multiply()`, `tag()`, `trimmer()`
- Promotes DRY (Don't Repeat Yourself) principles

### 5. **Data Quality Testing**
- Custom SQL tests for business logic validation
- Built-in tests for uniqueness and null checks
- Warning severity for non-critical issues

### 6. **Ephemeral Models**
- Intermediate transformations without physical tables
- Reduces database clutter and storage costs
- Used for dimension staging before snapshots

---

## 📁 Project Structure

```
aws_dbt_snowflake_project/
├── models/
│   ├── sources/
│   │   └── sources.yml              # Source table definitions
│   ├── bronze/
│   │   ├── bronze_bookings.sql      # Raw bookings (incremental)
│   │   ├── bronze_hosts.sql         # Raw hosts (incremental)
│   │   └── bronze_listings.sql      # Raw listings (incremental)
│   ├── silver/
│   │   ├── silver_bookings.sql      # Cleaned bookings
│   │   ├── silver_hosts.sql         # Cleaned hosts with quality tiers
│   │   └── silver_listings.sql      # Cleaned listings with price tags
│   ├── gold/
│   │   ├── obt.sql                  # One Big Table (metadata-driven)
│   │   ├── fact_bookings.sql        # Fact table (metrics only)
│   │   └── ephemeral/
│   │       ├── bookings.sql         # Dimension staging (ephemeral)
│   │       ├── hosts.sql            # Dimension staging (ephemeral)
│   │       └── listings.sql         # Dimension staging (ephemeral)
│   └── properties.yml               # Model configurations
├── macros/
│   ├── multiply.sql                 # Custom multiplication macro
│   ├── tag.sql                      # Price tagging macro
│   └── trimmer.sql                  # String cleaning macro
├── tests/
│   └── booking_amount_check.sql     # Data quality test
├── snapshots/
│   ├── dim_bookings.yml             # Booking dimension (SCD Type 2)
│   ├── dim_hosts.yml                # Host dimension (SCD Type 2)
│   └── dim_listings.yml             # Listing dimension (SCD Type 2)
├── dbt_project.yml                  # Project configuration
├── profiles.yml                     # Snowflake credentials (gitignored)
├── .gitignore                       # Security - excludes credentials
└── README.md                        # This file
```

---

## 🚀 Setup Instructions

### Prerequisites

- Python 3.12+
- AWS account with S3 access
- Snowflake account (free trial available)
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/airbnb-data-pipeline.git
cd airbnb-data-pipeline
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Activate (Mac/Linux)
source .venv/bin/activate

# Install dependencies
pip install dbt-core dbt-snowflake
```

### 3. Configure Snowflake Connection

Create `profiles.yml` in the project root:

```yaml
aws_dbt_snowflake_project:
  outputs:
    dev:
      account: YOUR_ACCOUNT_IDENTIFIER
      database: AIRBNB
      password: YOUR_PASSWORD
      role: ACCOUNTADMIN
      schema: dbt_schema
      threads: 1
      type: snowflake
      user: YOUR_USERNAME
      warehouse: COMPUTE_WH
  target: dev
```

**⚠️ IMPORTANT:** Never commit `profiles.yml` to version control!

### 4. Set Up AWS S3

```bash
# Upload CSV files to S3
aws s3 cp listings.csv s3://your-bucket-name/src/
aws s3 cp hosts.csv s3://your-bucket-name/src/
aws s3 cp bookings.csv s3://your-bucket-name/src/
```

### 5. Load Data to Snowflake Staging

```sql
-- In Snowflake, create database and schema
CREATE DATABASE AIRBNB;
CREATE SCHEMA staging;

-- Create tables and load from S3 using COPY INTO
-- (See ddl.sql for full schema definitions)
```

---

## ▶️ Running the Pipeline

### Build All Models

```bash
# Run all transformations
dbt run
```

### Build Specific Layers

```bash
# Bronze layer only
dbt run --select bronze

# Silver layer only
dbt run --select silver

# Gold layer only
dbt run --select gold
```

### Full Refresh (Reload All Data)

```bash
dbt run --full-refresh
```

### Run Snapshots (SCD Type 2)

```bash
dbt snapshot
```

### Run Tests

```bash
# Run all tests
dbt test

# Run specific test
dbt test --select booking_amount_check
```

### Build Everything (Models + Snapshots + Tests)

```bash
dbt build
```

---

## 📊 Data Models

### Bronze Layer

**Purpose:** Raw data preservation with incremental loading

**Models:**
- `bronze_bookings` - 5,000 booking records
- `bronze_hosts` - 200 host profiles
- `bronze_listings` - 500 property listings

**Key Feature:** Incremental materialization using `created_at` timestamp

### Silver Layer

**Purpose:** Data cleaning and business logic

**Transformations:**

| Model | Transformation Examples |
|-------|------------------------|
| `silver_bookings` | Calculate total booking amount with custom `multiply()` macro |
| `silver_hosts` | Categorize response rates (VERY_GOOD, GOOD, FAIR, POOR) |
| `silver_listings` | Tag prices as low/mid/high using `tag()` macro |

### Gold Layer - One Big Table (OBT)

**Purpose:** Denormalized table for easy analytics

**Features:**
- Metadata-driven SQL generation
- All entities joined in one wide table
- Optimized for BI tools (Tableau, Power BI)
- Easy for non-technical users to query

### Gold Layer - Star Schema

**Fact Table:** `fact_bookings`
- Booking metrics (amounts, fees, nights)
- Foreign keys to dimensions
- Optimized for aggregation queries

**Dimension Tables (SCD Type 2):**
- `dim_bookings` - Booking status and dates
- `dim_hosts` - Host information with history
- `dim_listings` - Property details with history

**Historical Tracking:**
```sql
-- Query historical state
SELECT *
FROM dim_hosts
WHERE host_id = 123
  AND '2024-06-15' BETWEEN dbt_valid_from AND dbt_valid_to
```

---

## 🧪 Testing

### Custom SQL Test Example

```sql
-- tests/booking_amount_check.sql
{{ config(severity = 'warn') }}

SELECT *
FROM {{ source('staging', 'bookings') }}
WHERE BOOKING_AMOUNT < 200
```

**Test Logic:**
- Returns 0 rows = ✅ PASS
- Returns rows = ⚠️ WARNING (flags suspicious bookings)

### Built-in Tests (in schema.yml)

```yaml
models:
  - name: bronze_bookings
    columns:
      - name: booking_id
        tests:
          - unique
          - not_null
```

---

## 🔒 Security

This project follows security best practices:

✅ **Credentials Protection**
- `profiles.yml` excluded via `.gitignore`
- No hardcoded passwords or API keys in SQL files
- AWS credentials managed separately

✅ **What's Safe to Share**
- dbt models and transformations
- Project configuration (dbt_project.yml)
- Tests and macros
- Documentation

❌ **Never Committed**
- `profiles.yml` (Snowflake credentials)
- `.venv/` (Python environment)
- `target/` (Compiled SQL)
- AWS access keys

---

## 📚 Learning Outcomes

### Technical Skills Demonstrated

**Data Engineering Concepts:**
- ✅ Medallion architecture (Bronze/Silver/Gold)
- ✅ Dimensional modeling (Star Schema)
- ✅ Slowly Changing Dimensions (SCD Type 2)
- ✅ Incremental data loading
- ✅ Data quality testing

**dbt Expertise:**
- ✅ Declarative transformations
- ✅ Jinja templating for dynamic SQL
- ✅ Custom macros for reusable logic
- ✅ Ephemeral models
- ✅ Snapshot functionality
- ✅ Source and model referencing

**Best Practices:**
- ✅ Version control with Git
- ✅ Credential management and security
- ✅ Code modularity and reusability
- ✅ Documentation
- ✅ Metadata-driven design patterns
  
## Demo
https://www.loom.com/share/d051218110d74a53a9abde1903e80d63

## 📸 Gallery

# Bronze Layer:
bookings
<img width="2550" height="1267" alt="bronze_layer_data_bookings png" src="https://github.com/user-attachments/assets/846f927c-fbaa-4342-9d0d-3186b5bf18e1" />
hosts
<img width="2548" height="1263" alt="bronze_layer_data_hosts png" src="https://github.com/user-attachments/assets/cbc3894c-978e-4fe3-bc6b-585cadd02e3a" />
listings
<img width="2545" height="1267" alt="bronze_layer_data_listings png" src="https://github.com/user-attachments/assets/6a005e7f-9def-4313-b977-c08d2193035c" />

# Silver layer
bookings
<img width="2556" height="1265" alt="silver_layer_data_bookings png" src="https://github.com/user-attachments/assets/1d0edc90-dcda-4bed-96fc-802f66364a55" />
hosts
<img width="2552" height="1266" alt="silver_layer_data_hosts png" src="https://github.com/user-attachments/assets/30559a70-a8ee-4498-851d-3fd93a5f8269" />
listings
<img width="2550" height="1267" alt="silver_layer_data_listings png" src="https://github.com/user-attachments/assets/83b6f66e-dcde-48a7-9d75-eda027154d92" />

# Gold layer
One-Big-Table:
<img width="2553" height="924" alt="gold_layer_data_obt png" src="https://github.com/user-attachments/assets/1c408a56-8d3f-43d8-b239-e2b7517d279b" />

Star Schema:
- Fact table:
<img width="2555" height="1261" alt="gold_layer_data_fact png" src="https://github.com/user-attachments/assets/b92541bc-835f-469a-a708-950362b86c3e" />
- Dimensions table:
bookings
<img width="2556" height="1267" alt="gold_layer_data_dim_bookings png" src="https://github.com/user-attachments/assets/897317e4-afae-48e2-b3a0-b9c5611c651d" />
hosts
<img width="2552" height="1267" alt="gold_layer_data_dim_hosts png" src="https://github.com/user-attachments/assets/e35d797c-5567-4345-8f81-fc334ad3fa0c" />
listings
<img width="2551" height="1270" alt="gold_layer_data_dim_listings png" src="https://github.com/user-attachments/assets/d1b69eb6-ea93-4e70-aa03-863db667e821" />

# Slow changing dimension (SCD) type 2 - incremental loading
<img width="2522" height="707" alt="snapshot after modification" src="https://github.com/user-attachments/assets/2508593a-dc8a-4da4-9d9b-b94d05fef0a4" />

# Database:
<img width="741" height="967" alt="db" src="https://github.com/user-attachments/assets/e4aa31ca-adad-454e-b675-5c252768d1cd" />

# Building tables and snapshots in Snowflakes
<img width="1084" height="737" alt="dbt-build png" src="https://github.com/user-attachments/assets/4baa1069-0278-487a-a669-c7c3626c5007" />

# AWS S3
<img width="2552" height="680" alt="aws s3" src="https://github.com/user-attachments/assets/d481032b-07a0-4daf-93aa-61093066c735" />

# dbt docs
<img width="2476" height="1227" alt="Screenshot 2026-01-18 164316" src="https://github.com/user-attachments/assets/32843e75-9f40-4027-a6dc-7ced9f5ca291" />

<img width="2544" height="1266" alt="Screenshot 2026-01-18 163946" src="https://github.com/user-attachments/assets/5eb142c6-af5e-4797-8367-ca43bc5fc70e" />

<img width="2497" height="1259" alt="Screenshot 2026-01-18 164051" src="https://github.com/user-attachments/assets/663a8fd4-59a0-4d8c-8529-6a5c65bc02fa" />

<img width="2520" height="1262" alt="Screenshot 2026-01-18 164454" src="https://github.com/user-attachments/assets/54fc41b3-27e7-42e1-a4e0-0aec906ac3aa" />

<img width="2533" height="1266" alt="Screenshot 2026-01-18 164631" src="https://github.com/user-attachments/assets/fa66af94-d880-458f-b479-98ff3ec59985" />

## 📝 License

This project is open source and available for educational purposes.

---

## 🤝 Contributing

This is a learning project, but feedback and suggestions are welcome! Feel free to open an issue or submit a pull request.


---

**Built with ❤️ using AWS, Snowflake, and dbt**



