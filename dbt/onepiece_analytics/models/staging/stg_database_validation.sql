-- Staging layer: Database validation metrics
-- Replaces hardcoded SQL from DAG's validate_database task

WITH table_counts AS (
    SELECT 
        'characters' as table_name, 
        COUNT(*) as row_count,
        CURRENT_TIMESTAMP as validated_at
    FROM {{ source('onepiece', 'characters') }}
    
    UNION ALL
    
    SELECT 
        'pirates' as table_name,
        COUNT(*) as row_count,
        CURRENT_TIMESTAMP as validated_at
    FROM {{ source('onepiece', 'pirates') }}
    
    UNION ALL
    
    SELECT 
        'crews' as table_name,
        COUNT(*) as row_count,
        CURRENT_TIMESTAMP as validated_at
    FROM {{ source('onepiece', 'crews') }}
    
    UNION ALL
    
    SELECT 
        'devil_fruits' as table_name,
        COUNT(*) as row_count,
        CURRENT_TIMESTAMP as validated_at
    FROM {{ source('onepiece', 'devil_fruits') }}
)

SELECT 
    table_name,
    row_count,
    CASE 
        WHEN row_count = 0 THEN 'WARNING: Empty table'
        WHEN row_count > 0 THEN 'OK'
        ELSE 'ERROR'
    END as validation_status,
    validated_at
FROM table_counts
ORDER BY table_name