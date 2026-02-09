#!/bin/bash

# Script de inicio rápido para el proyecto One Piece Data Pipeline
# Autor: Valentin

set -e

echo "🏴‍☠️ Iniciando One Piece Data Pipeline..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paso 1: Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creando archivo .env...${NC}"
    echo "AIRFLOW_UID=$(id -u)" > .env
    echo -e "${GREEN}✓ .env creado${NC}"
fi

# Paso 2: Crear directorios necesarios
echo -e "${YELLOW}Creando directorios...${NC}"
mkdir -p logs dags plugins data
echo -e "${GREEN}✓ Directorios creados${NC}"

# Paso 3: Levantar servicios
echo -e "${YELLOW}Levantando servicios Docker...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"

# Paso 4: Esperar a que Airflow esté listo
echo -e "${YELLOW}Esperando a que Airflow esté listo...${NC}"
echo "Esto puede tomar 1-2 minutos..."
sleep 60

# Paso 5: Verificar estado
echo ""
echo -e "${GREEN}✓ Pipeline iniciado exitosamente!${NC}"
echo ""
echo "📊 Servicios disponibles:"
echo "   Airflow UI: http://localhost:8080"
echo "   Usuario: airflow"
echo "   Password: airflow"
echo ""
echo "🐘 PostgreSQL:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: onepiece"
echo "   Usuario: airflow"
echo "   Password: airflow"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Abrí http://localhost:8080 en tu navegador"
echo "   2. Creá la conexión 'postgres_onepiece' en Admin → Connections"
echo "   3. Activá el DAG 'onepiece_analytics_pipeline'"
echo "   4. Ejecutá el DAG para ver la magia ✨"
echo ""
echo "📚 Para más información, lee el README.md"
echo ""
