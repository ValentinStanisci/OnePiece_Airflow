-- Marts layer: Pipeline analytics summary report
-- Replaces hardcoded SQL from DAG's generate_analytics_report task

WITH crew_stats AS (
    SELECT 
        'Total Crews Analyzed' as metric,
        COUNT(*)::text as value,
        'crews' as category,
        CURRENT_TIMESTAMP as report_generated_at
    FROM {{ ref('mart_crew_analytics') }}
),

bounty_stats AS (
    SELECT 
        'Top Bounty (Millions)' as metric,
        MAX(bounty_millions)::text as value,
        'bounties' as category,
        CURRENT_TIMESTAMP as report_generated_at
    FROM {{ ref('mart_top_pirates') }}
),

devil_fruit_stats AS (
    SELECT 
        'Total Devil Fruits' as metric,
        COUNT(*)::text as value,
        'devil_fruits' as category,
        CURRENT_TIMESTAMP as report_generated_at
    FROM {{ ref('mart_devil_fruits_analysis') }}
),

pirate_stats AS (
    SELECT 
        'Total Active Pirates' as metric,
        COUNT(*)::text as value,
        'pirates' as category,
        CURRENT_TIMESTAMP as report_generated_at
    FROM {{ ref('mart_top_pirates') }}
    WHERE is_alive = TRUE
),

billion_bounty_stats AS (
    SELECT 
        'Billion+ Bounty Pirates' as metric,
        COUNT(*)::text as value,
        'bounties' as category,
        CURRENT_TIMESTAMP as report_generated_at
    FROM {{ ref('mart_top_pirates') }}
    WHERE is_billion_bounty = TRUE
)

SELECT * FROM crew_stats
UNION ALL
SELECT * FROM bounty_stats
UNION ALL
SELECT * FROM devil_fruit_stats
UNION ALL
SELECT * FROM pirate_stats
UNION ALL
SELECT * FROM billion_bounty_stats
ORDER BY category, metric