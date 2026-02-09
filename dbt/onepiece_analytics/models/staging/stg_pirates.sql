-- Staging layer: pirate bounty data with threat classification

SELECT
    p.pirate_id,
    p.character_id,
    p.crew_id,
    p.bounty,
    ROUND(p.bounty / 1000000.0, 2) AS bounty_millions,
    CASE
        WHEN p.bounty >= 1000000000 THEN 'Yonko Level'
        WHEN p.bounty >= 500000000 THEN 'Supernova'
        WHEN p.bounty >= 100000000 THEN 'High Threat'
        WHEN p.bounty >= 10000000 THEN 'Medium Threat'
        ELSE 'Low Threat'
    END AS threat_level
FROM {{ source('onepiece', 'pirates') }} p
