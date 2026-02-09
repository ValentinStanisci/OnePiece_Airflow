-- Marts layer: Aggregated crew analytics
-- Optimized for analytical queries and dashboards

WITH crew_base AS (
    SELECT * FROM {{ ref('stg_crews') }}
),

pirates_enriched AS (
    SELECT * FROM {{ ref('int_pirates_enriched') }}
),

crew_memberships AS (
    SELECT 
        crew_id,
        character_id,
        TRUE as is_active
    FROM {{ source('onepiece', 'pirates') }}
),

crew_stats AS (
    SELECT
        c.crew_id,
        c.crew_name,
        c.captain_name,
        COUNT(DISTINCT CASE WHEN cm.is_active THEN cm.character_id END) AS active_members,
        COUNT(DISTINCT cm.character_id) AS total_members_all_time,
        COALESCE(SUM(CASE WHEN cm.is_active THEN p.bounty ELSE 0 END), 0) AS total_active_bounty,
        COALESCE(MAX(CASE WHEN cm.is_active THEN p.bounty ELSE 0 END), 0) AS highest_bounty,
        COALESCE(AVG(CASE WHEN cm.is_active THEN p.bounty END), 0) AS avg_bounty,
        COUNT(DISTINCT CASE WHEN cm.is_active AND p.is_alive THEN cm.character_id END) AS alive_members
    FROM crew_base c
    LEFT JOIN crew_memberships cm ON c.crew_id = cm.crew_id
    LEFT JOIN pirates_enriched p ON cm.character_id = p.character_id
    GROUP BY c.crew_id, c.crew_name, c.captain_name
)

SELECT
    crew_id,
    crew_name,
    captain_name,
    active_members,
    total_members_all_time,
    total_active_bounty,
    ROUND(total_active_bounty / 1000000.0, 2) AS total_bounty_millions,
    highest_bounty,
    ROUND(highest_bounty / 1000000.0, 2) AS highest_bounty_millions,
    ROUND(avg_bounty, 0) AS avg_bounty,
    alive_members,
    CASE 
        WHEN total_active_bounty >= 10000000000 THEN 'Yonko Crew'
        WHEN total_active_bounty >= 1000000000 THEN 'Powerful Crew'
        WHEN total_active_bounty >= 100000000 THEN 'Notable Crew'
        ELSE 'Emerging Crew'
    END AS crew_power_tier,
    ROUND(100.0 * alive_members / NULLIF(active_members, 0), 1) AS survival_rate_pct,
    CURRENT_TIMESTAMP AS updated_at
FROM crew_stats
ORDER BY total_active_bounty DESC
