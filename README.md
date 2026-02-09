# One Piece Data Pipeline

Modern data engineering pipeline using Apache Airflow, dbt, PostgreSQL, and Docker to analyze One Piece universe data.

![Tech Stack](https://img.shields.io/badge/Airflow-2.8-blue)
![dbt](https://img.shields.io/badge/dbt-1.7-orange)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![Docker](https://img.shields.io/badge/Docker-Latest-blue)

---

## Overview

This project demonstrates a production-grade data pipeline that implements:

- **Medallion Architecture** (Bronze/Silver/Gold layers)
- **Orchestration** with Apache Airflow DAGs
- **Data Transformations** using dbt
- **Dimensional Modeling** with fact and dimension tables
- **Automated Data Quality Testing**
- **Containerization** with Docker Compose

---

## Architecture

```
PostgreSQL (Source Data)
    ↓
dbt Models
├── Staging Layer (Bronze)
│   ├── stg_characters
│   ├── stg_pirates
│   └── stg_crews
├── Intermediate Layer (Silver)
│   └── int_pirates_enriched
└── Marts Layer (Gold)
    ├── mart_crew_analytics
    ├── mart_top_pirates
    └── mart_devil_fruits_analysis
    ↓
Airflow DAG Orchestration
```

---

## Tech Stack

- **Python 3.11**
- **Apache Airflow 2.8** - Workflow orchestration
- **dbt 1.7** - Data transformation framework
- **PostgreSQL 15** - Database
- **Docker & Docker Compose** - Containerization

---

## Quick Start

### Prerequisites

- Docker Desktop
- 4GB RAM minimum

### Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/onepiece-data-pipeline.git
cd onepiece-data-pipeline
```

2. Start the services
```bash
docker-compose up -d
```

3. Access Airflow UI
- URL: http://localhost:8080
- Username: `airflow`
- Password: `airflow`

4. Configure database connection
- Go to Admin → Connections
- Create new connection:
  - Connection ID: `postgres_onepiece`
  - Type: `Postgres`
  - Host: `postgres`
  - Database: `onepiece`
  - Username: `airflow`
  - Password: `airflow`
  - Port: `5432`

5. Trigger the pipeline
- Enable `onepiece_analytics_pipeline` DAG
- Click "Trigger DAG"

---

## Project Structure

```
.
├── dags/                       # Airflow DAGs
│   └── onepiece_pipeline.py
├── dbt/
│   └── onepiece_analytics/
│       ├── models/
│       │   ├── staging/        # Bronze layer
│       │   ├── intermediate/   # Silver layer
│       │   └── marts/          # Gold layer
│       ├── dbt_project.yml
│       └── profiles.yml
├── init-scripts/               # Database initialization
├── docker-compose.yml
└── README.md
```

---

## Data Models

### Staging Layer
- **stg_characters**: Cleaned character data
- **stg_pirates**: Bounty classifications
- **stg_crews**: Normalized crew information

### Intermediate Layer
- **int_pirates_enriched**: Combined pirate and character data

### Marts Layer
- **mart_crew_analytics**: Aggregated crew metrics (total bounty, members, power tier)
- **mart_top_pirates**: Ranked pirates by bounty
- **mart_devil_fruits_analysis**: Devil Fruit statistics and user analysis

---

## Example Queries

```sql
-- Top 5 crews by total bounty
SELECT 
    crew_name,
    captain_name,
    total_bounty_millions,
    crew_power_tier
FROM marts.mart_crew_analytics
ORDER BY total_bounty_millions DESC
LIMIT 5;

-- Pirates with bounties over 1 billion
SELECT 
    character_name,
    bounty_millions,
    crew_name,
    fruit_name
FROM marts.mart_top_pirates
WHERE is_billion_bounty = TRUE
ORDER BY bounty_rank;
```

---

## DAG Workflow

The Airflow DAG executes the following tasks:

1. `validate_database` - Check database connectivity
2. `dbt_deps` - Install dbt dependencies
3. `dbt_debug` - Validate dbt configuration
4. `dbt_run` - Execute all dbt models
5. `dbt_test` - Run data quality tests
6. `generate_analytics_report` - Create summary metrics
7. `create_daily_snapshot` - Store daily data snapshot

---

## Commands

### Docker
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Reset (including data)
docker-compose down -v
```

### dbt
```bash
# Enter Airflow container
docker exec -it onepiece-data-pipeline-airflow-scheduler-1 bash

# Navigate to dbt project
cd /opt/airflow/dbt/onepiece_analytics

# Run models
dbt run --profiles-dir .

# Run tests
dbt test --profiles-dir .
```

### PostgreSQL
```bash
# Connect to database
docker exec -it onepiece-data-pipeline-postgres-1 psql -U airflow -d onepiece

# View tables
\dt public_*.*

# Query data
SELECT * FROM marts.mart_crew_analytics;
```

---

## Skills Demonstrated

- ETL/ELT pipeline design
- SQL and data modeling
- Workflow orchestration
- Data quality testing
- Docker containerization
- Python scripting
- Git version control

---

## License

MIT

---

## Contact

For questions or collaboration: [Your Contact Info]
