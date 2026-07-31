# Retail Data Warehouse - dbt Project

## Project Overview
End-to-end retail data pipeline with layered architecture: Staging → Warehouse (Star Schema) → Analytics Marts → BI Views. Built with dbt on PostgreSQL.

## Architecture
- retail_staging: Raw landing zone with validation & cleaning views (8 staging models)
- retail_warehouse: Star schema with 4 dimensions (dim_customers SCD2, dim_products, dim_suppliers, dim_date) and 3 fact tables (fct_orders, fct_order_items, fct_inventory)
- retail_analytics: 4 business marts (daily_sales, monthly_kpi, customer_lifetime_value, inventory_turnover) + 4 Tableau-ready views
- retail_quarantine: Validation failure logging with JSONB row_data

## Directory Structure
Brief tree: sql/, models/{staging, warehouse, marts, tableau}, macros/, tests/, snapshots/, seeds/, dags/, analyses/

## Data Flow
Raw Data → Landing Tables (SQL DDL) → Staging Views (Clean/Dedup) → Dimensional Model (Star Schema) → Business Marts (Aggregates) → BI Views

## Quick Start
1. Install dbt-postgres: pip install dbt-postgres
2. Configure profiles.yml with Postgres credentials (or use env vars DBT_POSTGRES_PASSWORD)
3. Run schema setup SQLs in sql/ folder: 01_, 02_, 03_
4. Run: dbt deps → dbt seed → dbt run → dbt test
5. Generate docs: dbt docs generate && dbt docs serve

## Model Inventory
| Model Name | Layer | Materialization | Description |
| stg_customers | Staging | View | Cleaned & validated customer data |
| stg_products | Staging | View | Cleaned product catalog with type casting |
| stg_suppliers | Staging | View | Normalized supplier records |
| stg_orders | Staging | View | Deduplicated orders with status validation |
| stg_order_items | Staging | View | Order line items with referential checks |
| stg_payments | Staging | View | Payment transactions with domain validation |
| stg_inventory | Staging | View | Inventory levels with quantity cleaning |
| stg_returns | Staging | View | Return records with reason mapping |
| dim_customers | Warehouse | Table (SCD2) | Customer dimension with slowly changing attributes |
| dim_products | Warehouse | Table | Product dimension with supplier & pricing info |
| dim_suppliers | Warehouse | Table | Supplier dimension with contact details |
| dim_date | Warehouse | Table | Date dimension with calendar attributes |
| fct_orders | Warehouse | Table | Order fact with status & delivery metrics |
| fct_order_items | Warehouse | Table | Order item fact with revenue & freight |
| fct_inventory | Warehouse | Table | Inventory fact with stock levels & values |
| daily_sales | Marts | Table | Daily sales aggregates by product category |
| monthly_kpi | Marts | Table | Monthly KPIs: revenue, profit, delivery rates |
| customer_lifetime_value | Marts | Table | CLV scores, segments, and purchase patterns |
| inventory_turnover | Marts | Table | Inventory turnover ratios & stock health |
| tableau_sales_dashboard | Tableau | View | Daily sales joined with date attributes |
| tableau_monthly_performance | Tableau | View | Monthly performance KPIs for reporting |
| tableau_customer_analytics | Tableau | View | Customer segments, CLV tiers, tenure bands |
| tableau_inventory_view | Tableau | View | Inventory health with product & supplier details |

## Validation Engine
Macros: validate_not_null, validate_unique, validate_referential, validate_domain, insert_quarantine, plus cleaning macros: clean_string, clean_date, dedup_rows.

## Orchestration
Airflow DAGs in dags/: dbt_dag_factory.py (reusable), retail_pipeline_dag.py (daily 2am schedule), monitoring_hooks.py.

## Testing & Quality
dbt native tests: unique, not_null, relationships, accepted_values. Custom tests in tests/ folder.
