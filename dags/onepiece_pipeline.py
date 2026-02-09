"""
One Piece Analytics Pipeline

End-to-end data pipeline using Apache Airflow and dbt for transforming 
One Piece character and crew data.

This DAG orchestrates:
- Database validation
- dbt model execution (staging → intermediate → marts)
- Data quality testing
- Analytics report generation
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

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

def validate_database_connection():
    """Validates PostgreSQL connection"""
    hook = PostgresHook(postgres_conn_id='postgres_onepiece')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM characters;")
    result = cursor.fetchone()
    print(f"✅ Conexión exitosa! Total de personajes en la base: {result[0]}")
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

    # Task 1: Database validation
    validate_db = PostgresOperator(
        task_id='validate_database',
        postgres_conn_id='postgres_onepiece',
        sql="""
            SELECT 
                'characters' as table_name, 
                COUNT(*) as row_count 
            FROM characters
            UNION ALL
            SELECT 'pirates', COUNT(*) FROM pirates
            UNION ALL
            SELECT 'crews', COUNT(*) FROM crews;
        """,
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

    # Task 4: Run dbt models
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt run --profiles-dir .',
    )

    # Task 5: Run data quality tests
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/airflow/dbt/onepiece_analytics && dbt test --profiles-dir .',
    )

    # Task 6: Generate analytics report
    generate_report = PostgresOperator(
        task_id='generate_analytics_report',
        postgres_conn_id='postgres_onepiece',
        sql="""
            SELECT 
                'Total Crews Analyzed' as metric,
                COUNT(*)::text as value
            FROM public_marts.mart_crew_analytics
            UNION ALL
            SELECT 
                'Top Bounty (Millions)',
                MAX(bounty_millions)::text
            FROM public_marts.mart_top_pirates
            UNION ALL
            SELECT 
                'Total Devil Fruits',
                COUNT(*)::text
            FROM public_marts.mart_devil_fruits_analysis;
        """,
    )

    # Task 7: Daily snapshot
    create_snapshot = PostgresOperator(
        task_id='create_daily_snapshot',
        postgres_conn_id='postgres_onepiece',
        sql="""
            CREATE TABLE IF NOT EXISTS public.pipeline_snapshots (
                snapshot_id SERIAL PRIMARY KEY,
                snapshot_date DATE NOT NULL,
                total_characters INT,
                total_pirates INT,
                total_bounty BIGINT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            
            INSERT INTO public.pipeline_snapshots 
                (snapshot_date, total_characters, total_pirates, total_bounty)
            SELECT 
                CURRENT_DATE,
                (SELECT COUNT(*) FROM characters),
                (SELECT COUNT(*) FROM pirates),
                (SELECT COALESCE(SUM(bounty), 0) FROM pirates);
        """,
    )

    # Task dependencies
    validate_db >> dbt_deps >> dbt_debug >> dbt_run >> dbt_test >> generate_report >> create_snapshot
