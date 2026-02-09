-- Staging layer: character data cleansing and standardization

WITH source_data AS (
    SELECT
        character_id,
        name,
        sea,
        island,
        status,
        affiliation,
        created_at
    FROM {{ source('onepiece', 'characters') }}
)

SELECT
    character_id,
    TRIM(name) AS character_name,
    COALESCE(TRIM(sea), 'Unknown') AS origin_sea,
    COALESCE(TRIM(island), 'Unknown') AS origin_island,
    LOWER(TRIM(status)) AS status,
    LOWER(TRIM(affiliation)) AS affiliation,
    CASE 
        WHEN LOWER(status) = 'alive' THEN TRUE
        WHEN LOWER(status) = 'deceased' THEN FALSE
        ELSE NULL
    END AS is_alive
FROM source_data
