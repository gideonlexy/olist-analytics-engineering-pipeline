from datetime import timedelta, datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

PROJECT_DIR = "/opt/airflow/project"
DBT_DIR = f"{PROJECT_DIR}/dbt/olist_dbt"

default_args = {
    "owner":"gideon",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),

}

with DAG(
    dag_id="olist_analytics_pipeline",
    default_args=default_args,
    description="Orchestrates Olist raw ingestion and dbt analytics transformations.",
    start_date=datetime(2024, 6, 1),
    schedule="@daily",
    catchup=False,
    tags = ["olist", "airflow", "dbt", "analytics-engineering"],

) as dag:
    
    start = EmptyOperator(task_id="start")

    ingest_raw = BashOperator(
        task_id = "ingest_raw_data",
        bash_command = f'cd {PROJECT_DIR} && python scripts/ingest_olist.py',
    )

    dbt_deps = BashOperator(
        task_id = "dbt_deps",
        bash_command = f'cd {DBT_DIR} && dbt deps',
    )

    dbt_build = BashOperator(
        task_id = "dbt_build",
        bash_command = f'cd {DBT_DIR} && dbt build',
    )

    dbt_docs_generate = BashOperator(
        task_id = "dbt_docs_generate",
        bash_command = f'cd {DBT_DIR} && dbt docs generate',
    )

    end = EmptyOperator(task_id="end")

    start >> ingest_raw >> dbt_deps >> dbt_build >> dbt_docs_generate >> end