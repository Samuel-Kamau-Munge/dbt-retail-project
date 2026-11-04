# Retail Data Engineering Pipeline

An end-to-end retail data engineering project built with **Python, PostgreSQL, dbt and Apache Airflow**. The project demonstrates how raw retail data can be generated, validated, transformed and organised into analytical models for business reporting and decision-making.

## Project Overview

Retail businesses generate data across customers, products, orders, payments, inventory and returns. Bringing this information together into a reliable and structured analytical environment is essential for understanding business performance.

This project implements a retail data pipeline designed to process raw operational data and transform it into structured analytical datasets.

The pipeline follows a layered data architecture, separating raw data ingestion, staging transformations, warehouse modelling and analytical marts.

## Technology Stack

- **Python (Faker):** Synthetic retail data generation.
- **PostgreSQL:** Relational database and data warehouse.
- **dbt:** Data transformation, modelling and testing.
- **Apache Airflow:** Workflow orchestration and scheduling.
- **Tableau:** Business intelligence and reporting integration.

## Data Architecture

The project follows a layered data transformation approach:

1. **Raw Data Layer**
   - Stores incoming retail data.
   - Maintains source tables for customers, products, orders, payments, inventory, suppliers and returns.
   - Includes quarantine mechanisms for records requiring further validation.

2. **Staging Layer**
   - Cleans and standardises source records.
   - Handles duplicate records and inconsistent values.
   - Prepares datasets for downstream transformations.

3. **Data Warehouse Layer**
   - Implements a dimensional modelling approach using a star schema.
   - Organises data into fact and dimension tables.
   - Includes historical customer tracking using Slowly Changing Dimensions (SCD Type 2).

4. **Analytics Layer**
   - Produces business-oriented datasets for reporting.
   - Supports sales analysis, customer segmentation, inventory monitoring and business performance reporting.

## Key Data Models

### Staging Models
- Customers
- Products
- Orders
- Order Items
- Payments
- Inventory
- Suppliers
- Returns

### Warehouse Models

**Dimension tables**
- `dim_customers`
- `dim_products`
- `dim_suppliers`
- `dim_date`

**Fact tables**
- `fct_orders`
- `fct_order_items`
- `fct_inventory`

### Analytics Marts
- Daily Sales
- Monthly KPIs
- Customer Lifetime Value
- Inventory Turnover

## Data Quality and Validation

The project incorporates data quality mechanisms designed to improve the reliability of analytical datasets.

These include:
- Null-value validation.
- Uniqueness checks.
- Referential integrity checks.
- Domain validation.
- Duplicate detection and removal.
- Data cleaning and standardisation.
- Quarantine handling for invalid records.

## Workflow Orchestration

Apache Airflow is used to coordinate pipeline execution.

The documented orchestration design includes:
- Scheduled daily pipeline execution.
- Reusable dbt DAG generation.
- Execution monitoring.
- Failure and success callbacks.
- SLA monitoring.

## Business Applications

The resulting analytical datasets are designed to support questions such as:

- How much revenue is generated daily and monthly?
- Which products and categories contribute most to sales?
- Which customers generate the highest lifetime value?
- How efficiently is inventory moving?
- How are orders and payments performing over time?

## Project Objectives

This project demonstrates practical data engineering concepts, including:

- Relational database design.
- Data pipeline development.
- SQL-based transformations.
- Dimensional data modelling.
- Data quality engineering.
- Workflow orchestration.
- Analytics-ready data preparation.

## Project Status

The repository contains the documented implementation of the pipeline's major development phases. Individual components, execution instructions and test results should be verified against the source code before treating the project as production-ready.

## Author

**Samuel Munge**

Independent Data Engineer

Email: samuelmunge@outlook.com

GitHub: [Samuel-Kamau-Munge](https://github.com/Samuel-Kamau-Munge)

---

*This is an independent technical project using synthetic retail data. It is not a production deployment for a real retail business.*
