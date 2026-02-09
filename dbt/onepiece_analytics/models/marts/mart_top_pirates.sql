-- Marts layer: Top pirates ranked by bounty
-- Analytics table for threat assessment and bounty tracking

WITH pirates_enriched AS (
    SELECT * FROM {{ ref('int_pirates_enriched') }}
),

crews AS (
    SELECT * FROM {{ ref('stg_crews') }}
),

devil_fruits AS (
    SELECT 
        user_id,
        name AS fruit_name,
        type AS fruit_type
    FROM {{ source('onepiece', 'devil_fruits') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY p.bounty DESC) AS bounty_rank,
    p.pirate_id,
    p.character_name,
    p.bounty,
    p.bounty_millions,
    p.threat_level,
    p.origin_sea,
    p.origin_island,
    p.status,
    p.is_alive,
    c.crew_name,
    c.captain_name,
    df.fruit_name,
    df.fruit_type,
    CASE WHEN df.fruit_name IS NOT NULL THEN TRUE ELSE FALSE END AS has_devil_fruit,
    CASE WHEN p.bounty >= 1000000000 THEN TRUE ELSE FALSE END AS is_billion_bounty,
    CURRENT_TIMESTAMP AS report_generated_at
FROM pirates_enriched p
LEFT JOIN crews c ON p.crew_id = c.crew_id
LEFT JOIN devil_fruits df ON p.character_id = df.user_id
WHERE p.is_alive = TRUE
ORDER BY p.bounty DESC
