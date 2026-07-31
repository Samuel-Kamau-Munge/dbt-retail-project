import logging
from datetime import datetime

logger = logging.getLogger(__name__)


def task_failure_alert(context):
    task_instance = context.get("task_instance")
    exception = context.get("exception")
    execution_date = context.get("execution_date")
    dag_id = context.get("dag_id")
    task_id = context.get("task_id")

    logger.error(
        "Task FAILED - dag_id=%s, task_id=%s, execution_date=%s, task_instance=%s, exception=%s",
        dag_id,
        task_id,
        execution_date,
        task_instance,
        exception,
    )


def sla_miss_alert(dag, task_list, blocking_task_list, slas, blocking_tis):
    logger.warning(
        "SLA MISS - dag_id=%s, task_list=%s, blocking_task_list=%s, slas=%s, blocking_tis=%s",
        dag.dag_id if dag else "unknown",
        [t.task_id for t in task_list] if task_list else [],
        [t.task_id for t in blocking_task_list] if blocking_task_list else [],
        slas,
        [ti.task_id for ti in blocking_tis] if blocking_tis else [],
    )


def task_success_metrics(context):
    task_id = context.get("task_id")
    dag_id = context.get("dag_id")
    ti = context.get("task_instance")
    end_date = ti.end_date if ti else None
    start_date = ti.start_date if ti else None
    duration = None
    if start_date and end_date:
        if isinstance(end_date, datetime) and isinstance(start_date, datetime):
            duration = (end_date - start_date).total_seconds()

    logger.info(
        "Task SUCCESS - dag_id=%s, task_id=%s, duration=%s seconds, end_date=%s",
        dag_id,
        task_id,
        duration,
        end_date,
    )


def dbt_run_metrics_callback(context):
    ti = context.get("task_instance")
    if not ti:
        logger.warning("dbt_run_metrics_callback: No task_instance found in context")
        return

    try:
        dag_id = ti.dag_id
        task_id = ti.task_id
        xcom_result = ti.xcom_pull(task_ids=task_id, key="return_value")
        log_output = xcom_result or ""

        pass_count = 0
        fail_count = 0

        if isinstance(log_output, str):
            lines = log_output.splitlines()
            for line in lines:
                if "PASS" in line:
                    pass_count += 1
                if "FAIL" in line:
                    fail_count += 1

        logger.info(
            "dbt Run Metrics - dag_id=%s, task_id=%s, PASS_count=%d, FAIL_count=%d",
            dag_id,
            task_id,
            pass_count,
            fail_count,
        )
    except Exception as e:
        logger.error("dbt_run_metrics_callback error: %s", e)
