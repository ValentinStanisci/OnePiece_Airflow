-- Intermediate layer: enriched pirate data with character details

WITH pirates AS (
    SELECT * FROM {{ ref('stg_pirates') }}
),

characters AS (
    SELECT * FROM {{ ref('stg_characters') }}
)

SELECT
    p.pirate_id,
    p.character_id,
    c.character_name,
    c.origin_sea,
    c.origin_island,
    c.status,
    c.is_alive,
    p.crew_id,
    p.bounty,
    p.bounty_millions,
    p.threat_level,
    CASE 
        WHEN c.origin_sea = 'East Blue' THEN 'East Blue (Weakest Sea)'
        WHEN c.origin_sea IN ('North Blue', 'South Blue', 'West Blue') THEN c.origin_sea
        ELSE 'Grand Line / New World'
    END AS sea_classification
FROM pirates p
INNER JOIN characters c ON p.character_id = c.character_id
