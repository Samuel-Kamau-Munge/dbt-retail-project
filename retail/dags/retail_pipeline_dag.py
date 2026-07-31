from datetime import datetime, timedelta

from airflow.operators.python import PythonOperator

from dbt_dag_factory import create_dbt_dag
from monitoring_hooks import sla_miss_alert


default_args = {
    "owner": "data-team",
    "depends_on_past": False,
    "start_date": datetime(2024, 1, 1),
    "email": ["data-team@example.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "execution_timeout": timedelta(hours=2),
}

dbt_project_dir = "/opt/airflow/dbt/retail"
profile_dir = "/opt/airflow/dbt/retail"

dag = create_dbt_dag(
    dag_id="retail_pipeline_dag",
    dbt_project_dir=dbt_project_dir,
    profile_dir=profile_dir,
    schedule_interval="0 2 * * *",
    default_args=default_args,
    tags=["retail", "dbt", "daily"],
    catchup=False,
    max_active_runs=1,
)

dag.sla_miss_callback = sla_miss_alert


def check_schemas():
    print("Checking schemas retail_staging, retail_warehouse, retail_analytics, retail_quarantine exist...")


def send_summary_report():
    print("Pipeline completed, sending summary report to stakeholders...")


with dag:
    pre_check_schema = PythonOperator(
        task_id="pre_check_schema",
        python_callable=check_schemas,
    )

    post_send_report = PythonOperator(
        task_id="post_send_report",
        python_callable=send_summary_report,
    )

    dbt_debug = dag.get_task("dbt_debug")
    dbt_run = dag.get_task("dbt_run")
    dbt_docs_generate = dag.get_task("dbt_docs_generate")

    dbt_run.sla = timedelta(hours=1)

    pre_check_schema >> dbt_debug
    dbt_docs_generate >> post_send_report
