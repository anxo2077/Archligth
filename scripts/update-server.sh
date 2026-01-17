#!/bin/bash

# Variables
SERVER_DIR="/home/opc/archlight-server"
SERVER_PORT=25565
BACKUP_DIR="${SERVER_DIR}/backups"
JAR_FILE="archlight-server-1.21.1.jar"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO] Iniciando actualización de servidor Archlight...${NC}"

# Validar que el JAR existe
if [ ! -f "${SERVER_DIR}/${JAR_FILE}" ]; then
    echo -e "${RED}[ERROR] ${JAR_FILE} no encontrado en ${SERVER_DIR}${NC}"
    exit 1
fi

# Crear backup
mkdir -p "${BACKUP_DIR}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo -e "${YELLOW}[INFO] Creando backup...${NC}"
cp -r "${SERVER_DIR}/mods" "${BACKUP_DIR}/mods_${TIMESTAMP}" 2>/dev/null || true
cp -r "${SERVER_DIR}/config" "${BACKUP_DIR}/config_${TIMESTAMP}" 2>/dev/null || true

# Detener el servidor
echo -e "${YELLOW}[INFO] Deteniendo servidor...${NC}"
pkill -f "java.*archlight" || true
pkill -f "java.*${JAR_FILE}" || true
sleep 5

# Actualizar archivos
echo -e "${YELLOW}[INFO] Copiando archivos nuevos...${NC}"
if [ -d "mods" ] && [ "$(ls -A mods)" ]; then
    cp -r mods/* "${SERVER_DIR}/mods/" 2>/dev/null || true
    echo -e "${GREEN}[OK] Mods actualizados${NC}"
fi

if [ -d "config" ] && [ "$(ls -A config)" ]; then
    cp -r config/* "${SERVER_DIR}/config/" 2>/dev/null || true
    echo -e "${GREEN}[OK] Config actualizado${NC}"
fi

# Reiniciar servidor
echo -e "${GREEN}[INFO] Reiniciando servidor...${NC}"
cd "${SERVER_DIR}"
nohup java -Xmx3G -Xms2G -jar "${JAR_FILE}" nogui > server.log 2>&1 &

# Esperar a que se inicie
sleep 3

# Verificar que está corriendo
if pgrep -f "java.*${JAR_FILE}" > /dev/null; then
    echo -e "${GREEN}[OK] Servidor actualizado y reiniciado correctamente!${NC}"
    echo -e "${GREEN}[PID] $(pgrep -f 'java.*archlight')${NC}"
else
    echo -e "${RED}[ERROR] El servidor no se inició correctamente${NC}"
    echo -e "${RED}[INFO] Revisa los logs: tail -f ${SERVER_DIR}/server.log${NC}"
    exit 1
fi