#!/bin/bash
# Script para configurar la conexión de Airflow a la base de datos One Piece

# Esperar a que Airflow esté listo
sleep 10

# Crear la conexión usando Airflow CLI
docker exec -it onepiece-data-pipeline-airflow-webserver-1 airflow connections add 'postgres_onepiece' \
    --conn-type 'postgres' \
    --conn-login 'airflow' \
    --conn-password 'airflow' \
    --conn-host 'postgres' \
    --conn-port 5432 \
    --conn-schema 'onepiece'

echo "✅ Conexión 'postgres_onepiece' configurada exitosamente"
