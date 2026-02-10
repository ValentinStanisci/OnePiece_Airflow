FROM apache/airflow:2.8.0-python3.11

USER root
RUN apt-get update && apt-get install -y git && apt-get clean

USER airflow
RUN pip install --no-cache-dir dbt-core==1.7.4 dbt-postgres==1.7.4