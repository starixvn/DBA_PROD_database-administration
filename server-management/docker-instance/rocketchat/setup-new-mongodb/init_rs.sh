#!/bin/bash

# =============================================
# MongoDB Replica Set Initialization Script
# Input:
#   ./init_rs.sh <REPLICA_SET_NAME> <HOSTNAME> <ROOT_USER> <ROOT_PASS> <IP1:PORT1> [<IP2:PORT2> ...]
# Example:
#   ./init_rs.sh rocketchat_rs rocketchat_33 admin admin 192.168.1.10:16602 192.168.1.11:16603
# =============================================

REPL_SET="$1"
HOSTNAME="$2"             # Docker hostname to exec into
ROOT_USER="$3"
ROOT_PASS="$4"
shift 4
MEMBERS=("$@")            # List of IP:PORT members

PORT=27017                # Default MongoDB port (used only for mongosh inside container)

if [[ -z "$REPL_SET" || -z "$HOSTNAME" || -z "$ROOT_USER" || -z "$ROOT_PASS" || "${#MEMBERS[@]}" -lt 1 ]]; then
  echo "❌ Usage: $0 <REPLICA_SET_NAME> <HOSTNAME> <ROOT_USER> <ROOT_PASS> <IP1:PORT1> [IP2:PORT2] ..."
  exit 1
fi

echo "🔧 Replica Set Name: $REPL_SET"
echo "🛰  Hostname (Docker exec target): $HOSTNAME"
echo "🧩 Members: ${MEMBERS[*]}"

echo "⏳ Waiting for container '${HOSTNAME}' to be ready..."
until docker exec -i "${HOSTNAME}" mongosh --port "$PORT" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done
echo -e "\n✅ Container '${HOSTNAME}' is up."

# --- Build members config string for rs.initiate ---
MEMBER_CONFIG="["
i=0
for MEMBER in "${MEMBERS[@]}"; do
  [[ $i -gt 0 ]] && MEMBER_CONFIG+=","
  MEMBER_CONFIG+="{ _id: $i, host: \"${MEMBER}\", priority: $(( ${#MEMBERS[@]} - i )) }"
  ((i++))
done
MEMBER_CONFIG+="]"

# --- Run mongosh via docker exec ---
docker exec -i "${HOSTNAME}" mongosh --port "$PORT" --quiet --eval "$(cat <<EOF
try {
  const admin = db.getSiblingDB('admin');
  admin.auth("${ROOT_USER}", "${ROOT_PASS}");

  try {
    if (rs.status().ok === 1) {
      print("[INFO] Replica Set already initialized.");
    }
  } catch (e) {
    print("[INFO] Initializing Replica Set '${REPL_SET}' with ${#MEMBERS[@]} member(s)...");

    const config = {
      _id: "${REPL_SET}",
      members: ${MEMBER_CONFIG}
    };

    rs.initiate(config);
    print("[SUCCESS] Replica Set '${REPL_SET}' initialized successfully.");
  }

  print("[INFO] Current Replica Set Status:");
  printjson(rs.status());

} catch (err) {
  print("[ERROR] " + err);
}
EOF
)"

