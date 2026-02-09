-- Staging layer: crew data normalization

SELECT
    crew_id,
    TRIM(name) AS crew_name,
    TRIM(captain) AS captain_name
FROM {{ source('onepiece', 'crews') }}
