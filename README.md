# F1 1984 Season Analytics Project

# Project Overview
ETL Pipeline for collection, processing, and visualizing Formula 1 1984 season statistics.

# Architecture
<> EXTRACT: Python
<> LOAD : PostgreeSQL
<> TRANSFORM : PostgreeSQL using CTE, Window Functions, Subqueries
<> ORCHESTRATE : Apache Airflow in Docker
<> VISUALIZE : Power BI dashboard

# Data Model
Formula 1 1984 season data with:
{} 16 races
{} 36 drivers
{} 15 teams

# How to Run
1. Clone repository
2. Run 'docker-compose up -d'
3. Access Airflow UI at http://localhost:8000
4. Trigger DAG 'f1_1984_pipeline'
5. Open Power BI file in 'dashboard/' folder

# Project Structure
f1-1984-project/
    data/ # Data Storage
        raw/ # Raw scraped data (CSV)
        staging/ # Intermediate data
        processed/ # Ready for BI
    scripts/ # Python scripts
        extract.py # Data scraping
        load.py # Load to PostgreeSQL
        transform.sql # SQL transformations
    airflow/ #
        dags/ # Airflow DAG files
    docs/ # Documentation
    docker-compose.yml #

# Technologies
^^ Python 3.9+
^^ PostgreeSQL 13
^^ Apache Airflow 2.7
^^ Docker
^^ Power BI

# Author
Grigory539

# Date
July 2026