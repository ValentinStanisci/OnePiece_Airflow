-- Marts layer: Devil Fruit analysis
-- Distribution and power assessment statistics

WITH devil_fruits_base AS (
    SELECT 
        fruit_id,
        name AS fruit_name,
        type AS fruit_type,
        user_id
    FROM {{ source('onepiece', 'devil_fruits') }}
),

characters AS (
    SELECT * FROM {{ ref('stg_characters') }}
),

pirates AS (
    SELECT * FROM {{ ref('stg_pirates') }}
)

SELECT
    df.fruit_id,
    df.fruit_name,
    df.fruit_type,
    c.character_name AS current_user,
    c.status AS user_status,
    c.affiliation AS user_affiliation,
    c.origin_sea AS user_origin_sea,
    p.bounty,
    p.bounty_millions,
    p.threat_level,
    CASE df.fruit_type
        WHEN 'Logia' THEN 'Highest'
        WHEN 'Paramecia' THEN 'Medium-High'
        WHEN 'Zoan' THEN 'Medium'
        ELSE 'Unknown'
    END AS fruit_power_class,
    CASE 
        WHEN p.bounty >= 1000000000 THEN 'Major Threat'
        WHEN p.bounty >= 100000000 THEN 'Significant Threat'
        ELSE 'Minor Threat'
    END AS user_threat_assessment,
    CURRENT_TIMESTAMP AS analyzed_at
FROM devil_fruits_base df
LEFT JOIN characters c ON df.user_id = c.character_id
LEFT JOIN pirates p ON df.user_id = p.character_id
ORDER BY 
    CASE df.fruit_type
        WHEN 'Logia' THEN 1
        WHEN 'Paramecia' THEN 2
        WHEN 'Zoan' THEN 3
        ELSE 4
    END,
    p.bounty DESC NULLS LAST
