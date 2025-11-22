#!/bin/bash
set -e

CONTAINER="pgsql"
DATA_DIR="/srv/lxd-pgdata"
PG_VER="17"

# -------------------------------------------------------------------------
# PASSWORD MODE
# -------------------------------------------------------------------------
GENERATE_PASSWORD="yes"  # yes = random strong password; no = static password
PG_PASSWORD="ChangeMe123!"  # used only if GENERATE_PASSWORD=no

if [ "$GENERATE_PASSWORD" = "yes" ]; then
    PG_PASSWORD=$(openssl rand -base64 20)
fi

echo "=== LXD PostgreSQL Installer for Debian 13 (Trixie) ==="

# -------------------------------------------------------------------------
# 1. Create LXC Container
# -------------------------------------------------------------------------
if ! lxc list | grep -q "$CONTAINER"; then
    echo "[+] Creating container: $CONTAINER"
    lxc launch images:debian/13 "$CONTAINER"
    sleep 3
else
    echo "[i] Container $CONTAINER already exists"
fi

lxc exec "$CONTAINER" -- apt update -y

# -------------------------------------------------------------------------
# 2. Clean old PostgreSQL configs
# -------------------------------------------------------------------------
echo "[+] Cleaning PostgreSQL leftovers"
lxc exec "$CONTAINER" -- bash -c "rm -f /etc/apt/sources.list.d/pgdg.list"
lxc exec "$CONTAINER" -- bash -c "rm -f /etc/apt/keyrings/postgresql.gpg"
lxc exec "$CONTAINER" -- bash -c "apt purge -y 'postgresql*' || true"
lxc exec "$CONTAINER" -- bash -c "apt autoremove -y"
lxc exec "$CONTAINER" -- bash -c "rm -rf /var/lib/postgresql"

# -------------------------------------------------------------------------
# 3. Install PostgreSQL 17
# -------------------------------------------------------------------------
echo "[+] Installing PostgreSQL"
lxc exec "$CONTAINER" -- apt install -y postgresql postgresql-contrib

# -------------------------------------------------------------------------
# 4. Drop default cluster (correct syntax for Debian 13)
# -------------------------------------------------------------------------
echo "[+] Dropping default cluster (if exists)"
lxc exec "$CONTAINER" -- bash -c "pg_dropcluster --stop $PG_VER main 2>/dev/null || true"

# -------------------------------------------------------------------------
# 5. Get UID mapping
# -------------------------------------------------------------------------
CONTAINER_UID=$(lxc exec "$CONTAINER" -- id -u postgres)
HOST_BASE_UID=$(lxc config show "$CONTAINER" --expanded | awk '/Hostid:/ {print $2}')
HOST_PG_UID=$((HOST_BASE_UID + CONTAINER_UID))

echo "[+] postgres UID inside container: $CONTAINER_UID"
echo "[+] host base UID: $HOST_BASE_UID"
echo "[+] mapped postgres UID on host: $HOST_PG_UID"

# -------------------------------------------------------------------------
# 6. Prepare persistent directory
# -------------------------------------------------------------------------
echo "[+] Preparing persistent data directory"
sudo mkdir -p "$DATA_DIR"
sudo chown -R "$HOST_PG_UID:$HOST_PG_UID" "$DATA_DIR"
sudo chmod 700 "$DATA_DIR"

# -------------------------------------------------------------------------
# 7. Attach persistent storage to container
# -------------------------------------------------------------------------
if ! lxc config show "$CONTAINER" --expanded | grep -q "pgdata"; then
    echo "[+] Adding disk mount"
    lxc config device add "$CONTAINER" pgdata disk source="$DATA_DIR" path=/var/lib/postgresql
else
    echo "[i] pgdata mount already exists"
fi

# Restart container to apply mount
lxc restart "$CONTAINER"
sleep 3

# -------------------------------------------------------------------------
# 8. Create cluster inside persistent directory
# -------------------------------------------------------------------------
echo "[+] Creating PostgreSQL cluster"
lxc exec "$CONTAINER" -- bash -c "pg_createcluster $PG_VER main --start"

# -------------------------------------------------------------------------
# 9. Configure remote access
# -------------------------------------------------------------------------
echo "[+] Configuring remote access"
lxc exec "$CONTAINER" -- bash -c "sed -i \"/listen_addresses/c listen_addresses='*'\" /etc/postgresql/$PG_VER/main/postgresql.conf"
lxc exec "$CONTAINER" -- bash -c "echo 'host all all 0.0.0.0/0 scram-sha-256' >> /etc/postgresql/$PG_VER/main/pg_hba.conf"
lxc exec "$CONTAINER" -- systemctl restart postgresql

# -------------------------------------------------------------------------
# 10. Apply password to postgres user
# -------------------------------------------------------------------------
echo "[+] Setting password for postgres user"
lxc exec "$CONTAINER" -- sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PG_PASSWORD';"

# -------------------------------------------------------------------------
# 11. Summary
# -------------------------------------------------------------------------
IP=$(lxc list "$CONTAINER" | awk '/RUNNING/ {print $6}')

echo
echo "=== INSTALLATION COMPLETE ==="
echo "Container: $CONTAINER"
echo "Persistent data: $DATA_DIR"
echo "Cluster path: /var/lib/postgresql/$PG_VER/main"
echo "Container IP: $IP"
echo
echo "Postgres superuser: postgres"
echo "Postgres password:   $PG_PASSWORD"
echo
echo "Connect from host:"
echo "    psql -h $IP -U postgres"
echo
echo "[DONE]"
