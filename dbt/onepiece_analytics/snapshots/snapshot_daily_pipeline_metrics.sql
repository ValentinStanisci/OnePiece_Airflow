{% snapshot snapshot_daily_pipeline_metrics %}

{{
    config(
      target_schema='snapshots',
      unique_key='snapshot_date',
      strategy='timestamp',
      updated_at='created_at',
    )
}}

-- Daily snapshot of pipeline metrics
-- Replaces hardcoded SQL from DAG's create_daily_snapshot task

WITH metrics AS (
    SELECT 
        CURRENT_DATE as snapshot_date,
        (SELECT COUNT(*) FROM {{ source('onepiece', 'characters') }}) as total_characters,
        (SELECT COUNT(*) FROM {{ source('onepiece', 'pirates') }}) as total_pirates,
        (SELECT COALESCE(SUM(bounty), 0) FROM {{ source('onepiece', 'pirates') }}) as total_bounty,
        (SELECT COUNT(*) FROM {{ source('onepiece', 'crews') }}) as total_crews,
        (SELECT COUNT(*) FROM {{ source('onepiece', 'devil_fruits') }}) as total_devil_fruits,
        CURRENT_TIMESTAMP as created_at
)

SELECT * FROM metrics

{% endsnapshot %}