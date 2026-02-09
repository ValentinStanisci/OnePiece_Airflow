-- Characters
CREATE TABLE characters (
    character_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sea VARCHAR(100),
    island VARCHAR(100),
    status VARCHAR(50),
    affiliation VARCHAR(50)
);

-- Crews
CREATE TABLE crews (
    crew_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    captain VARCHAR(100)
);

-- Pirates
CREATE TABLE pirates (
    pirate_id SERIAL PRIMARY KEY,
    bounty BIGINT,
    crew_id INT REFERENCES crews(crew_id),
    character_id INT NOT NULL,
    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE
);

-- Devil Fruits
CREATE TABLE devil_fruits (
    fruit_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    user_id INT REFERENCES characters(character_id)
);

-- World Government / Marines
CREATE TABLE world_government (
    marine_id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    division VARCHAR(50),
    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE
);

-- Civilians
CREATE TABLE civilians (
    civilian_id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE
);

-- Revolutionaries
CREATE TABLE revolutionaries (
    rev_id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    division VARCHAR(100) NOT NULL,
    FOREIGN KEY (character_id) REFERENCES characters(character_id) ON DELETE CASCADE
);
