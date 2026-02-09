"""
One Piece Analytics Pipeline

End-to-end data pipeline using Apache Airflow and dbt for transforming 
One Piece character and crew data.

This DAG orchestrates:
- Database validation (via dbt test)
- dbt model execution (staging → intermediate → marts)
- Data quality testing
- Daily snapshots
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator

# DAG configuration
default_args = {
    'owner': 'data-eng',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 8),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def log_pipeline_start():
    """Log pipeline execution start"""
    print("🏴‍☠️ Starting One Piece Analytics Pipeline")
    print(f"⏰ Execution time: {datetime.now()}")

def log_pipeline_end():
    """Log pipeline execution completion"""
    hook = PostgresHook(postgres_conn_id='postgres_onepiece')
    conn = hook.get_conn()
    cursor = conn.cursor()
    
    # Get basic stats
    cursor.execute("""
        SELECT 
            (SELECT COUNT(*) FROM public_marts.mart_crew_analytics) as crews,
            (SELECT COUNT(*) FROM public_marts.mart_top_pirates) as pirates,
            (SELECT COUNT(*) FROM public_marts.mart_devil_fruits_analysis) as devil_fruits
    """)
    
    result = cursor.fetchone()
    print(f"✅ Pipeline completed successfully!")
    print(f"📊 Crews analyzed: {result[0]}")
    print(f"🏴‍☠️ Pirates processed: {result[1]}")
    print(f"🍎 Devil Fruits tracked: {result[2]}")
    
    cursor.close()
    conn.close()

# DAG definition
with DAG(
    'onepiece_analytics_pipeline',
    default_args=default_args,
    description='One Piece analytics pipeline with dbt transformations',
    schedule_interval='@daily',
    catchup=False,
    tags=['onepiece', 'dbt', 'analytics'],
) as dag:

    # Task 1: Log start
    start_pipeline = PythonOperator(
        task_id='log_pipeline_start',
        python_callable=log_pipeline_start,
    )

    # Task 2: Install dbt dependencies
    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt deps --profiles-dir .',
    )

    # Task 3: Validate dbt configuration
    dbt_debug = BashOperator(
        task_id='dbt_debug',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt debug --profiles-dir .',
    )

    # Task 4: Run source freshness checks
    dbt_source_freshness = BashOperator(
        task_id='dbt_source_freshness',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt source freshness --profiles-dir .',
    )

    # Task 5: Run dbt models (staging → intermediate → marts)
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt run --profiles-dir .',
    )

    # Task 6: Run data quality tests
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt test --profiles-dir .',
    )

    # Task 7: Run dbt snapshots (daily snapshot)
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt snapshot --profiles-dir .',
    )

    # Task 8: Generate documentation
    dbt_docs_generate = BashOperator(
        task_id='dbt_docs_generate',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt docs generate --profiles-dir .',
    )

    # Task 9: Log completion
    end_pipeline = PythonOperator(
        task_id='log_pipeline_end',
        python_callable=log_pipeline_end,
    )

    # Task dependencies
    start_pipeline >> dbt_deps >> dbt_debug >> dbt_source_freshness >> dbt_run >> dbt_test >> [dbt_snapshot, dbt_docs_generate] >> end_pipeline
    
  