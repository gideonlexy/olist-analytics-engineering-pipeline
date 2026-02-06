# Olist Analytics Engineering Pipeline

## Overview
This project is an **end-to-end analytics engineering pipeline** built on a real-world e-commerce dataset.  
It demonstrates how raw operational data is ingested, modeled, transformed, tested, and served for business analytics using modern data engineering practices.

The goal of this project is to replicate how analytics pipelines are built in production environments, focusing on **data correctness, modeling, and reproducibility**, not just analysis.


## Architecture (High Level)
Raw CSV Files
     ↓
Python Ingestion Scripts
     ↓
PostgreSQL (raw schema)
     ↓
dbt Transformations (staging → marts)
     ↓
Analytics Tables (facts & dimensions)
     ↓
Tableau Dashboards


---

## Data Source
**Olist Brazilian E-Commerce Dataset**  
A public dataset containing real e-commerce transactions, customers, sellers, payments, deliveries, and reviews.

Source:
- https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset includes multiple related tables, making it suitable for realistic data modeling and analytics use cases.

---

## Business Questions

### Revenue & Orders
- What are daily, weekly, and monthly revenue trends?
- What is the average order value (AOV)?
- How does payment method usage change over time?

### Customer Behavior
- How many customers are new vs returning each month?
- What is the repeat purchase rate?
- How long does it take customers to place a second order?

### Operations & Delivery
- What percentage of orders are delivered on time?
- What is the average delivery duration?
- Which sellers or regions experience the most delays?

### Seller & Product Performance
- Which sellers generate the most revenue?
- Which product categories perform best?
- How do reviews correlate with delivery performance?

---

## Tech Stack

### Core Tools
- **Python 3.10+** – data ingestion & validation
- **PostgreSQL** – analytics warehouse
- **dbt Core** – transformations, tests, documentation
- **Docker** – reproducible local database environment
- **Git & GitHub** – version control and documentation

### Analytics & Visualization
- **Tableau** – dashboards and business insights

---


## Database Setup (Local)

This project uses **PostgreSQL running in Docker** for reproducibility.

Start the database:

```bash
docker compose up -d


