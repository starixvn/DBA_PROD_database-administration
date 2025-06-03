#!/bin/bash

# ============================================
# MongoDB ReplicaSet Deployment Script for Rocket.Chat
# ============================================
# Usage:
#   ./deploy_mongodb.sh <MONGO_HOST> <MONGO_PORT> <MONGO_NETWORK> [--reset|--delete]

# ========== Input Arguments ==========
MONGO_HOST="$1"
MONGO_PORT="$2"
MONGO_NETWORK="$3"
OPTIONAL_FLAG="$4"

# ========== Validate Arguments ==========
if [ -z "$MONGO_HOST" ] || [ -z "$MONGO_PORT" ] || [ -z "$MONGO_NETWORK" ]; then
  echo "Usage: $0 <MONGO_HOST> <MONGO_PORT> <MONGO_NETWORK> [--reset|--delete]"
  exit 1
fi

# ========== Constants ==========
ROOT_DIR="/var/docker/${MONGO_HOST}"
VOLUME_DIR="/mount/volumes/${MONGO_HOST}"
CONFIG_DIR="${ROOT_DIR}/config"
LOG_DIR="${ROOT_DIR}/log"
YAML_DIR="${ROOT_DIR}/yaml_config_files"

MONGO_TAG="7.0.18"
MONGO_USER="admin"
MONGO_PASS="admin"

# ========== Show Plan ==========
echo ""
echo "===== MongoDB Deployment Plan ====="
echo "MongoDB Container Name : ${MONGO_HOST}"
echo "MongoDB Port           : ${MONGO_PORT}"
echo "Docker Network         : ${MONGO_NETWORK}"
echo "Volume Path            : ${VOLUME_DIR}"
echo "Config Path            : ${CONFIG_DIR}"
echo "Log Path               : ${LOG_DIR}"
echo "Compose & .env Path    : ${YAML_DIR}"
echo "Action                 : ${OPTIONAL_FLAG:-create}"
echo "===================================="
echo ""

read -p "⚠️  Confirm to proceed? Type 'yes' to continue: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Aborted by user."
  exit 1
fi

# ========== Handle --delete Option ==========
if [ "$OPTIONAL_FLAG" == "--delete" ]; then
  echo "[!] Deleting container and all related data..."
  docker rm -f "${MONGO_HOST}" 2>/dev/null || true
  sudo rm -rf "${ROOT_DIR}" "${VOLUME_DIR}"
  echo "[✓] All data and container removed."
  exit 0
fi

# ========== Optional Reset ==========
if [ "$OPTIONAL_FLAG" == "--reset" ]; then
  echo "[!] Reset mode enabled. Removing old container and data..."
  docker rm -f "${MONGO_HOST}" 2>/dev/null || true
  sudo rm -rf "${ROOT_DIR}" "${VOLUME_DIR}"
  echo "[✓] Old container and data removed."
fi

# ========== Create Docker Network if Needed ==========
if ! docker network ls --format '{{.Name}}' | grep -wq "${MONGO_NETWORK}"; then
  echo "[+] Creating Docker network '${MONGO_NETWORK}'..."
  docker network create --driver bridge "${MONGO_NETWORK}"
else
  echo "[=] Docker network '${MONGO_NETWORK}' already exists."
fi

# ========== Create Folder Structure ==========
echo "[+] Creating directory structure..."
sudo mkdir -p "${CONFIG_DIR}" "${LOG_DIR}" "${YAML_DIR}"
sudo mkdir -p "${VOLUME_DIR}/data" "${VOLUME_DIR}/backup"

# ========== Set Permissions ==========
echo "[+] Setting permissions..."
sudo chmod -R 777 "${LOG_DIR}"
sudo chmod -R 777 "${VOLUME_DIR}"

# ========== Generate replica.key ==========
if [ ! -f "${CONFIG_DIR}/replica.key" ]; then
  echo "[+] Generating replica key..."
  openssl rand -base64 756 | sudo tee "${CONFIG_DIR}/replica.key" > /dev/null
  sudo chmod 400 "${CONFIG_DIR}/replica.key"
  sudo chown 999:999 "${CONFIG_DIR}/replica.key"
else
  echo "[=] Replica key already exists. Skipping key generation."
fi

# ========== Create mongod.conf ==========
echo "[+] Creating mongod.conf..."
cat <<EOF | sudo tee "${CONFIG_DIR}/mongod.conf" > /dev/null
storage:
  dbPath: /data/db

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true

replication:
  replSetName: "rocketchat_rs"

security:
  keyFile: /data/replica.key

net:
  bindIp: 0.0.0.0
  port: 27017
EOF

# ========== Create .env ==========
echo "[+] Creating .env..."
cat <<EOF | sudo tee "${YAML_DIR}/.env" > /dev/null
# Network
MONGO_NETWORK=${MONGO_NETWORK}
DRIVER_NETWORK=bridge
EXTERNAL_NETWORK=true

# Config
MONGO_BACKUP=${VOLUME_DIR}/backup
MONGO_DATA=${VOLUME_DIR}/data
MONGO_LOG=${LOG_DIR}
MONGO_CONF=${CONFIG_DIR}
MONGO_CONFIG_DIR=${YAML_DIR}

# MONGODB
MONGO_TAG=${MONGO_TAG}
MONGO_HOST=${MONGO_HOST}
MONGO_PORT=${MONGO_PORT}
MONGO_INITDB_ROOT_USERNAME=${MONGO_USER}
MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASS}
EOF

# ========== Create docker-compose.yml ==========
echo "[+] Creating docker-compose.yml..."
cat <<EOF | sudo tee "${YAML_DIR}/docker-compose.yml" > /dev/null
version: '3.7'

networks:
  default:
    name: \${MONGO_NETWORK}
    driver: \${DRIVER_NETWORK}
    external: \${EXTERNAL_NETWORK}

services:
  ${MONGO_HOST}:
    image: mongo:\${MONGO_TAG}
    container_name: \${MONGO_HOST}
    hostname: \${MONGO_HOST}
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 2G
    environment:
      MONGO_INITDB_ROOT_USERNAME: \${MONGO_INITDB_ROOT_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: \${MONGO_INITDB_ROOT_PASSWORD}
    ports:
      - \${MONGO_PORT}:27017
    volumes:
      - \${MONGO_DATA}:/data/db
      - \${MONGO_BACKUP}:/data/backup
      - \${MONGO_LOG}:/var/log/mongodb
      - \${MONGO_CONF}/replica.key:/data/replica.key
      - \${MONGO_CONF}/mongod.conf:/etc/mongod.conf
    restart: always
    command: "mongod --config /etc/mongod.conf"
EOF

# ========== Start Container ==========
echo "[+] Starting MongoDB container..."
cd "${YAML_DIR}"
docker-compose --env-file .env up -d

echo ""
echo "[✅] MongoDB container '${MONGO_HOST}' is running at port ${MONGO_PORT}"
echo "Replica set name: rocketchat_rs"
echo ""
