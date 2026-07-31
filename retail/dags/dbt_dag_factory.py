import logging

from airflow import DAG
from airflow.operators.bash import BashOperator

from monitoring_hooks import task_failure_alert

logger = logging.getLogger(__name__)


def _on_failure_callback(context):
    dag_id = context.get("dag_id")
    task_id = context.get("task_id")
    execution_date = context.get("execution_date")
    logger.error(
        "DAG Task failed: dag_id=%s, task_id=%s, execution_date=%s",
        dag_id,
        task_id,
        execution_date,
    )
    task_failure_alert(context)


def create_dbt_dag(
    dag_id,
    dbt_project_dir,
    profile_dir,
    schedule_interval,
    default_args,
    tags=None,
    catchup=False,
    max_active_runs=1,
):
    dag = DAG(
        dag_id=dag_id,
        default_args=default_args,
        schedule_interval=schedule_interval,
        tags=tags if tags else [],
        catchup=catchup,
        max_active_runs=max_active_runs,
    )

    project_dir = dbt_project_dir

    dbt_debug = BashOperator(
        task_id="dbt_debug",
        bash_command=f"cd {project_dir} && dbt debug --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {project_dir} && dbt deps --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"cd {project_dir} && dbt seed --profiles-dir {profile_dir} --full-refresh",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {project_dir} && dbt run --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {project_dir} && dbt test --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"cd {project_dir} && dbt snapshot --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_docs_generate = BashOperator(
        task_id="dbt_docs_generate",
        bash_command=f"cd {project_dir} && dbt docs generate --profiles-dir {profile_dir}",
        dag=dag,
        on_failure_callback=_on_failure_callback,
    )

    dbt_debug >> dbt_deps >> dbt_seed >> dbt_run >> dbt_test >> dbt_snapshot >> dbt_docs_generate

    return dag
