#!/bin/bash
set -e

# Database initialization script
echo "Initializing One Piece database..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE onepiece;
EOSQL

echo "Database created"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "onepiece" < /docker-entrypoint-initdb.d/create_table.sql

echo "Schema created"
echo "Loading sample data..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "onepiece" <<-EOSQL

-- Tripulaciones principales
INSERT INTO crews (name, captain) VALUES 
    ('Piratas del Sombrero de Paja', 'Monkey D. Luffy'),
    ('Piratas de Barbablanca', 'Edward Newgate'),
    ('Piratas de Roger', 'Gol D. Roger'),
    ('Piratas de Barbanegra', 'Marshall D. Teach'),
    ('Piratas de Big Mom', 'Charlotte Linlin'),
    ('Piratas de Kaido', 'Kaido'),
    ('Piratas de Shanks', 'Shanks');

-- Personajes principales
INSERT INTO characters (name, sea, island, status, affiliation) VALUES 
    ('Monkey D. Luffy', 'East Blue', 'Dawn Island', 'Alive', 'Pirate'),
    ('Roronoa Zoro', 'East Blue', 'Shimotsuki Village', 'Alive', 'Pirate'),
    ('Nami', 'East Blue', 'Cocoyasi Village', 'Alive', 'Pirate'),
    ('Usopp', 'East Blue', 'Syrup Village', 'Alive', 'Pirate'),
    ('Sanji', 'North Blue', 'Germa Kingdom', 'Alive', 'Pirate'),
    ('Tony Tony Chopper', 'Grand Line', 'Drum Island', 'Alive', 'Pirate'),
    ('Nico Robin', 'West Blue', 'Ohara', 'Alive', 'Pirate'),
    ('Franky', 'South Blue', 'Water 7', 'Alive', 'Pirate'),
    ('Brook', 'West Blue', 'Unknown', 'Alive', 'Pirate'),
    ('Jinbe', 'Grand Line', 'Fishman Island', 'Alive', 'Pirate'),
    ('Portgas D. Ace', 'South Blue', 'Baterilla', 'Deceased', 'Pirate'),
    ('Edward Newgate', 'Grand Line', 'Sphinx', 'Deceased', 'Pirate'),
    ('Gol D. Roger', 'South Blue', 'Loguetown', 'Deceased', 'Pirate'),
    ('Marshall D. Teach', 'Grand Line', 'Unknown', 'Alive', 'Pirate'),
    ('Kaido', 'Grand Line', 'Wano', 'Alive', 'Pirate'),
    ('Charlotte Linlin', 'Grand Line', 'Whole Cake Island', 'Alive', 'Pirate'),
    ('Shanks', 'West Blue', 'Unknown', 'Alive', 'Pirate'),
    ('Smoker', 'Grand Line', 'Loguetown', 'Alive', 'Marine'),
    ('Monkey D. Garp', 'East Blue', 'Dawn Island', 'Alive', 'Marine'),
    ('Sengoku', 'Grand Line', 'Unknown', 'Alive', 'Marine'),
    ('Akainu', 'North Blue', 'Unknown', 'Alive', 'Marine'),
    ('Monkey D. Dragon', 'Unknown', 'Unknown', 'Alive', 'Revolutionary');

-- Piratas con recompensas
INSERT INTO pirates (character_id, bounty, crew_id) VALUES 
    (1, 3000000000, 1),   -- Luffy
    (2, 1111000000, 1),   -- Zoro
    (3, 366000000, 1),    -- Nami
    (4, 500000000, 1),    -- Usopp
    (5, 1032000000, 1),   -- Sanji
    (6, 1000, 1),         -- Chopper
    (7, 930000000, 1),    -- Robin
    (8, 394000000, 1),    -- Franky
    (9, 383000000, 1),    -- Brook
    (10, 1100000000, 1),  -- Jinbe
    (11, 550000000, 2),   -- Ace
    (12, 5046000000, 2),  -- Whitebeard
    (13, 5564800000, 3),  -- Roger
    (14, 3996000000, 4),  -- Blackbeard
    (15, 4611100000, 6),  -- Kaido
    (16, 4388000000, 5),  -- Big Mom
    (17, 4039000000, 7);  -- Shanks

-- Frutas del Diablo
INSERT INTO devil_fruits (name, type, user_id) VALUES 
    ('Gomu Gomu no Mi', 'Paramecia', 1),
    ('Hana Hana no Mi', 'Paramecia', 7),
    ('Yomi Yomi no Mi', 'Paramecia', 9),
    ('Mera Mera no Mi', 'Logia', 11),
    ('Gura Gura no Mi', 'Paramecia', 12),
    ('Yami Yami no Mi', 'Logia', 14),
    ('Uo Uo no Mi Model: Seiryu', 'Zoan', 15),
    ('Soru Soru no Mi', 'Paramecia', 16);

-- Marines
INSERT INTO world_government (character_id, division) VALUES 
    (18, 'G-5'),
    (19, 'HQ'),
    (20, 'HQ'),
    (21, 'HQ');

-- Revolucionarios  
INSERT INTO revolutionaries (character_id, division) VALUES 
    (22, 'Revolutionary Army');

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_pirates_bounty ON pirates(bounty DESC);
CREATE INDEX IF NOT EXISTS idx_characters_affiliation ON characters(affiliation);
CREATE INDEX IF NOT EXISTS idx_devil_fruits_type ON devil_fruits(type);

-- Vista resumen
CREATE OR REPLACE VIEW vw_crew_overview AS
SELECT 
    c.name as crew_name,
    c.captain,
    COUNT(DISTINCT p.character_id) as total_members,
    SUM(p.bounty) as total_bounty,
    ROUND(AVG(p.bounty), 0) as avg_bounty
FROM crews c
LEFT JOIN pirates p ON c.crew_id = p.crew_id
GROUP BY c.crew_id, c.name, c.captain
ORDER BY total_bounty DESC NULLS LAST;

EOSQL

echo "Data loaded successfully"
echo ""
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "onepiece" <<-EOSQL
    SELECT 'Characters' as table_name, COUNT(*) as records FROM characters
    UNION ALL
    SELECT 'Pirates', COUNT(*) FROM pirates
    UNION ALL
    SELECT 'Crews', COUNT(*) FROM crews
    UNION ALL
    SELECT 'Devil Fruits', COUNT(*) FROM devil_fruits;
EOSQL

echo ""
echo "One Piece database initialized successfully"

