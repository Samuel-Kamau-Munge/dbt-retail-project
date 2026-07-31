# Retail Data Pipeline - Build Progress

## Phase 1: Project Structure & Schemas ✅
- [x] Create directory structure (staging, warehouse, marts, macros, sql, dags, plugins)
- [x] Create SQL schema creation scripts
- [x] Create raw landing tables
- [x] Create quarantine tables
- [x] Execute schema creation on PostgreSQL

## Phase 2: Validation Engine ✅
- [x] Create validation macros (not_null, unique, referential, domain)
- [x] Create quarantine insert macro
- [x] Create cleaning macros (dedup, clean_string, clean_date)

## Phase 3: Staging Models ✅
- [x] Create stg_customers.sql
- [x] Create stg_products.sql
- [x] Create stg_orders.sql
- [x] Create stg_order_items.sql
- [x] Create stg_payments.sql
- [x] Create stg_inventory.sql
- [x] Create stg_suppliers.sql
- [x] Create stg_returns.sql

## Phase 4: Warehouse Models (Star Schema) ✅
- [x] Create dim_customers.sql — SCD Type 2
- [x] Create dim_products.sql — with supplier denormalization
- [x] Create dim_suppliers.sql
- [x] Create dim_date.sql — 2016–2030 coverage
- [x] Create fct_orders.sql — header-level facts
- [x] Create fct_order_items.sql — line-level granular facts
- [x] Create fct_inventory.sql — inventory snapshots

## Phase 5: Analytics Marts ✅
- [x] Create daily_sales.sql — daily + product category aggregates
- [x] Create monthly_kpi.sql — executive monthly KPIs
- [x] Create customer_lifetime_value.sql — CLV scoring & segmentation
- [x] Create inventory_turnover.sql — turnover ratios + stock health

## Phase 6: dbt Tests & Documentation ✅
- [x] Create sources.yml — retail_raw source with 10 raw tables
- [x] Create comprehensive schema.yml files (staging/warehouse/marts/tableau)
- [x] Create custom test assertions (6 singular tests)
- [x] Update dbt_project.yml — layered schema configs, tags, tests settings
- [x] Create profiles.yml — dev + prod Postgres targets, env vars

## Phase 7: Airflow Orchestration ✅
- [x] Create dbt DAG factory — reusable create_dbt_dag()
- [x] Create retail DAG — daily 2am schedule, SLA on run task
- [x] Create monitoring hooks — failure, SLA, success, dbt metrics callbacks

## Phase 8: Final Polish ✅
- [x] Update README.md — architecture, quickstart, model inventory
- [x] Create Tableau-ready views — 4 BI-optimized views
- [x] Add metrics layer — 20+ dbt metrics (revenue, orders, customers, ops, inventory, financial)
