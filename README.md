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
- **Best Practices**: No hardcoded SQL, separation of concerns, custom Docker images

---

## Architecture

```
PostgreSQL (Source Data)
    ↓
dbt Models
├── Staging Layer (Bronze)
│   ├── stg_characters
│   ├── stg_pirates
│   ├── stg_crews
│   └── stg_database_validation
├── Intermediate Layer (Silver)
│   └── int_pirates_enriched
└── Marts Layer (Gold)
    ├── mart_crew_analytics
    ├── mart_top_pirates
    ├── mart_devil_fruits_analysis
    └── mart_pipeline_summary
    ↓
Airflow DAG Orchestration
    ↓
Daily Snapshots
```

---

## Tech Stack

- **Python 3.11**
- **Apache Airflow 2.8** - Workflow orchestration
- **dbt 1.7** - Data transformation framework
- **PostgreSQL 15** - Database
- **Docker & Docker Compose** - Containerization
- **Custom Dockerfile** - Pre-installed dependencies

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

2. Build and start the services
```bash
docker-compose build
docker-compose up -d
```

This will:
- Build a custom Airflow image with dbt and git pre-installed
- Start PostgreSQL, Airflow webserver, and scheduler
- Initialize the database with One Piece data

3. Access Airflow UI
- URL: http://localhost:8080
- Username: `airflow`
- Password: `airflow`

4. Configure database connection
- Go to Admin → Connections → Click "+" to add new connection
- Create new connection:
  - **Connection ID**: `postgres_onepiece`
  - **Type**: `Postgres`
  - **Host**: `postgres`
  - **Database**: `onepiece`
  - **Username**: `airflow`
  - **Password**: `airflow`
  - **Port**: `5432`
- Click Save

⚠️ **IMPORTANT**: This connection must be configured before running the DAG.

5. Trigger the pipeline
- Enable `onepiece_analytics_pipeline` DAG (toggle to ON)
- Click "Trigger DAG" ▶️

---

## Project Structure

```
.
├── Dockerfile                  # Custom Airflow image with dbt
├── docker-compose.yml          # Services configuration
├── dags/
│   └── onepiece_pipeline.py    # Orchestration only (no SQL)
├── dbt/
│   └── onepiece_analytics/
│       ├── models/
│       │   ├── staging/        # Bronze layer
│       │   │   ├── stg_characters.sql
│       │   │   ├── stg_pirates.sql
│       │   │   ├── stg_crews.sql
│       │   │   ├── stg_database_validation.sql
│       │   │   └── schema.yml
│       │   ├── intermediate/   # Silver layer
│       │   │   └── int_pirates_enriched.sql
│       │   └── marts/          # Gold layer
│       │       ├── mart_crew_analytics.sql
│       │       ├── mart_top_pirates.sql
│       │       ├── mart_devil_fruits_analysis.sql
│       │       ├── mart_pipeline_summary.sql
│       │       └── schema.yml
│       ├── snapshots/
│       │   └── snapshot_daily_pipeline_metrics.sql
│       ├── dbt_project.yml
│       └── profiles.yml
├── init-scripts/               # Database initialization
│   ├── 01-create-onepiece-db.sh
│   └── create_table.sql
└── README.md
```

---

## Refactoring & Best Practices

This project follows modern data engineering best practices:

### ✅ No Hardcoded SQL
All SQL logic has been migrated from the Airflow DAG to dbt models:
- ❌ **Before**: SQL queries embedded in Python code (hard to test, version, and maintain)
- ✅ **After**: SQL in versioned .sql files with automated tests and documentation

### ✅ Separation of Concerns
- **Airflow**: Orchestration only (when to run, task dependencies)
- **dbt**: Data transformations, testing, documentation (what to run)

### ✅ Custom Docker Image
Uses a custom Dockerfile to pre-install dependencies:
- dbt-core 1.7.4
- dbt-postgres 1.7.4
- git

This ensures:
- Consistent environments across all containers
- Faster startup times
- No manual installation required
- Reliable deployments

### ✅ Data Quality Testing
Every model has automated tests for:
- Unique constraints
- Not null validations
- Referential integrity
- Accepted values

### ✅ Daily Snapshots
Historical tracking of pipeline metrics using dbt snapshots (Type 2 SCD)

---

## Data Models

### Staging Layer (Bronze)
- **stg_characters**: Cleaned character data
- **stg_pirates**: Bounty classifications
- **stg_crews**: Normalized crew information
- **stg_database_validation**: Table validation metrics

### Intermediate Layer (Silver)
- **int_pirates_enriched**: Combined pirate and character data with enrichments

### Marts Layer (Gold)
- **mart_crew_analytics**: Aggregated crew metrics (total bounty, members, power tier)
- **mart_top_pirates**: Ranked pirates by bounty
- **mart_devil_fruits_analysis**: Devil Fruit statistics and user analysis
- **mart_pipeline_summary**: High-level pipeline execution metrics

### Snapshots
- **snapshot_daily_pipeline_metrics**: Daily snapshot of database metrics

---

## DAG Workflow

The Airflow DAG executes the following tasks in sequence:

1. **log_pipeline_start** - Log execution start with timestamp
2. **dbt_deps** - Install dbt dependencies
3. **dbt_debug** - Validate dbt configuration and database connection
4. **dbt_source_freshness** - Check source data freshness
5. **dbt_run** - Execute all dbt models (staging → intermediate → marts)
6. **dbt_test** - Run data quality tests on all models
7. **dbt_snapshot** - Create daily snapshot of metrics
8. **dbt_docs_generate** - Generate dbt documentation
9. **log_pipeline_end** - Log completion with summary metrics

**All SQL transformations are handled by dbt models, not hardcoded in the DAG.**

---

## Example Queries

```sql
-- Top 5 crews by total bounty
SELECT 
    crew_name,
    captain_name,
    total_bounty_millions,
    crew_power_tier
FROM public_marts.mart_crew_analytics
ORDER BY total_bounty_millions DESC
LIMIT 5;

-- Pirates with bounties over 1 billion
SELECT 
    character_name,
    bounty_millions,
    crew_name,
    fruit_name
FROM public_marts.mart_top_pirates
WHERE is_billion_bounty = TRUE
ORDER BY bounty_rank;

-- Pipeline execution summary
SELECT 
    metric,
    value,
    category
FROM public_marts.mart_pipeline_summary
ORDER BY category, metric;

-- Database validation status
SELECT 
    table_name,
    row_count,
    validation_status
FROM public_staging.stg_database_validation
ORDER BY table_name;
```

---

## Commands

### Docker

```bash
# Build custom image (first time or after Dockerfile changes)
docker-compose build

# Start services
docker-compose up -d

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f airflow-scheduler

# Stop services
docker-compose down

# Reset everything (including data)
docker-compose down -v

# Rebuild everything from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

# Check service status
docker-compose ps
```

### dbt (inside container)

```bash
# Enter Airflow scheduler container
docker exec -it onepiece_airflow-airflow-scheduler-1 bash

# Navigate to dbt project
cd /opt/airflow/dbt/onepiece_analytics

# Run all models
dbt run --profiles-dir .

# Run specific model
dbt run --select stg_characters --profiles-dir .

# Run tests
dbt test --profiles-dir .

# Create snapshots
dbt snapshot --profiles-dir .

# Generate and serve documentation
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .

# Compile SQL without executing
dbt compile --profiles-dir .

# Check source freshness
dbt source freshness --profiles-dir .
```

### PostgreSQL

```bash
# Connect to database
docker exec -it onepiece_airflow-postgres-1 psql -U airflow -d onepiece

# Inside psql:
# List all schemas
\dn

# List tables in all schemas
\dt public*.*

# View specific table
SELECT * FROM public_staging.stg_characters LIMIT 10;

# Check row counts
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname LIKE 'public%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# Exit
\q
```

---

## Troubleshooting

### Issue: `postgres_onepiece` connection not found
**Error**: `AirflowNotFoundException: The conn_id 'postgres_onepiece' isn't defined`

**Solution**: Configure the connection in Airflow UI:
1. Go to http://localhost:8080
2. Admin → Connections → Click "+"
3. Fill in connection details (see Quick Start step 4)
4. Save and retry the DAG

### Issue: `dbt: command not found`
**Error**: `/usr/bin/bash: line 1: dbt: command not found`

**Solution**: The custom Dockerfile should handle this. Rebuild the image:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Issue: `git: command not found`
**Error**: `Error from git --help: User does not have permissions for this command: "git"`

**Solution**: Already included in Dockerfile. If issue persists:
```bash
docker exec -u root onepiece_airflow-airflow-scheduler-1 apt-get update && apt-get install -y git
docker exec -u root onepiece_airflow-airflow-webserver-1 apt-get update && apt-get install -y git
```

### Issue: Database tables don't exist
**Error**: `relation "characters" does not exist`

**Solution**: Check if init scripts ran successfully:
```bash
# Check postgres logs
docker logs onepiece_airflow-postgres-1 | grep "Data loaded"

# If data wasn't loaded, reinitialize:
docker-compose down -v
docker-compose up -d
```

### Issue: Port 5432 already in use
**Error**: `Bind for 0.0.0.0:5432 failed: port is already allocated`

**Solution**: Either stop local PostgreSQL or change the port in docker-compose.yml:
```yaml
ports:
  - "5433:5432"  # Use 5433 externally instead
```

### Issue: Airflow webserver not accessible
**Solution**: 
1. Check if container is healthy: `docker-compose ps`
2. Wait 1-2 minutes for initialization
3. Check logs: `docker-compose logs airflow-webserver`
4. Ensure port 8080 is not in use by another service

### Issue: Models are skipped during dbt run
**Cause**: Upstream model failed, so dependent models are skipped

**Solution**:
1. Check which model failed in dbt_run logs
2. Fix the SQL error in that model
3. Re-run the DAG

---

## Development Workflow

### Making Changes to dbt Models

1. Edit the .sql file in `dbt/onepiece_analytics/models/`
2. Test locally in container:
```bash
docker exec -it onepiece_airflow-airflow-scheduler-1 bash
cd /opt/airflow/dbt/onepiece_analytics
dbt run --select your_model --profiles-dir .
dbt test --select your_model --profiles-dir .
```
3. Commit changes
4. Trigger DAG in Airflow to validate end-to-end

### Adding a New dbt Model

1. Create new .sql file in appropriate folder (staging/intermediate/marts)
2. Add model to schema.yml with tests:
```yaml
models:
  - name: your_new_model
    description: "Description here"
    columns:
      - name: id
        tests:
          - unique
          - not_null
```
3. Run `dbt run --select your_new_model --profiles-dir .`
4. Add to git and trigger DAG

### Modifying the DAG

1. Edit `dags/onepiece_pipeline.py`
2. Airflow automatically picks up changes (may take ~30 seconds)
3. Test by triggering the DAG manually

---

## Skills Demonstrated

- ✅ ETL/ELT pipeline design and orchestration
- ✅ SQL and dimensional data modeling
- ✅ Workflow orchestration with Airflow
- ✅ dbt for data transformations and testing
- ✅ Docker containerization and custom images
- ✅ Data quality testing and validation
- ✅ Database design (PostgreSQL)
- ✅ Python scripting
- ✅ Git version control and branching strategies
- ✅ Best practices: separation of concerns, no hardcoded SQL
- ✅ CI/CD readiness
- ✅ Technical documentation

---

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Follow the code style:
   - Python: PEP 8
   - SQL: Lowercase keywords, snake_case for identifiers
   - dbt: staging → intermediate → marts pattern
4. Test your changes locally with Docker
5. Ensure all dbt tests pass: `dbt test --profiles-dir .`
6. Commit with clear messages following conventional commits
7. Submit a Pull Request with description of changes

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

---

## Future Enhancements

Potential improvements for this project:

- [ ] Add CI/CD pipeline with GitHub Actions
- [ ] Implement Great Expectations for advanced data quality
- [ ] Add dbt exposures for downstream BI dashboards
- [ ] Implement incremental models for large tables
- [ ] Add Slack/email alerts for pipeline failures
- [ ] Create dbt macros for common transformations
- [ ] Add data lineage visualization
- [ ] Implement row-level security
- [ ] Add monitoring with Prometheus/Grafana
- [ ] Deploy to cloud (AWS/GCP/Azure)

---

## License

MIT License

Copyright (c) 2026 Valentin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Contact

**Valentin Alastanisci**
- Email: vaalastanisci@outlook.es
- GitHub: [Vaaleth](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

For questions, issues, or collaboration opportunities, feel free to reach out!

---

## Acknowledgments

- Apache Airflow community
- dbt Labs for excellent documentation
- One Piece universe data for making this project fun
- Docker for containerization platform

---

**⚡ Built with passion for data engineering and One Piece! 🏴‍☠️**
