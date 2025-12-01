#!/bin/bash
set -e

# ------------------------------------------------------------
#  LXD + ZFS + MySQL Automated Deployment Script
#  
# ------------------------------------------------------------

CONTAINER_NAME="mysql01"
STORAGE_POOL="zfspool1"
VOLUME_NAME="mysqlvol"
ZFS_POOL_DATASET="lzpool/lxd"     # <-- CHANGE THIS TO YOUR ZFS DATASET
IMAGE="images:debian/12"

echo "========================================================="
echo "   LXD + ZFS + MySQL Full Automated Deployment"
echo "========================================================="

# ------------------------------------------------------------
# CHECK DEPENDENCIES
# ------------------------------------------------------------

command -v lxc >/dev/null || { echo "[ERROR] LXD not installed!"; exit 1; }
command -v zfs >/dev/null || { echo "[ERROR] ZFS tools not installed!"; exit 1; }

echo "[OK] Dependencies are installed."


# ------------------------------------------------------------
# CHECK ZFS DATASET
# ------------------------------------------------------------

if ! zfs list "$ZFS_POOL_DATASET" >/dev/null 2>&1; then
    echo "[ERROR] ZFS dataset $ZFS_POOL_DATASET does not exist!"
    echo "Create it first, e.g.:"
    echo "  sudo zfs create lzpool/lxd"
    exit 1
fi

echo "[OK] Using ZFS dataset: $ZFS_POOL_DATASET"


# ------------------------------------------------------------
# CREATE LXD STORAGE POOL (if not exists)
# ------------------------------------------------------------
if ! lxc storage show "$STORAGE_POOL" >/dev/null 2>&1; then
    echo "[INFO] Creating ZFS LXD storage pool: $STORAGE_POOL ..."
    lxc storage create "$STORAGE_POOL" zfs source="$ZFS_POOL_DATASET"
else
    echo "[OK] LXD storage pool already exists: $STORAGE_POOL"
fi


# ------------------------------------------------------------
# CREATE MYSQL ZFS STORAGE VOLUME
# ------------------------------------------------------------
if ! lxc storage volume show "$STORAGE_POOL" "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "[INFO] Creating ZFS volume for MySQL..."
    lxc storage volume create "$STORAGE_POOL" "$VOLUME_NAME"
else
    echo "[OK] ZFS volume already exists: $VOLUME_NAME"
fi


# ------------------------------------------------------------
# CREATE CONTAINER
# ------------------------------------------------------------
if ! lxc info "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "[INFO] Creating container $CONTAINER_NAME ..."
    lxc launch "$IMAGE" "$CONTAINER_NAME" -s "$STORAGE_POOL"
else
    echo "[OK] Container already exists: $CONTAINER_NAME"
fi

sleep 5


# ------------------------------------------------------------
# ATTACH MYSQL VOLUME TO CONTAINER
# ------------------------------------------------------------
if ! lxc config device show "$CONTAINER_NAME" | grep -q "mysqldata"; then
    echo "[INFO] Attaching disk volume to container..."
    lxc config device add "$CONTAINER_NAME" mysqldata disk \
        source="$VOLUME_NAME" \
        pool="$STORAGE_POOL" \
        path="/var/lib/mysql"
else
    echo "[OK] MySQL data volume already attached."
fi


# ------------------------------------------------------------
# INSTALL MARIADB INSIDE CONTAINER
# ------------------------------------------------------------
echo "[INFO] Installing MariaDB inside container..."

lxc exec "$CONTAINER_NAME" -- bash -c "apt update && apt install -y mariadb-server"

echo "[INFO] Stopping MariaDB to reinitialize database on ZFS volume..."
lxc exec "$CONTAINER_NAME" -- systemctl stop mariadb || true


# ------------------------------------------------------------
# MOVE DEFAULT DB & REINITIALIZE ON ZFS VOLUME
# ------------------------------------------------------------

echo "[INFO] Preparing /var/lib/mysql ..."
lxc exec "$CONTAINER_NAME" -- bash -c "rm -rf /var/lib/mysql/*"
lxc exec "$CONTAINER_NAME" -- bash -c "chown -R mysql:mysql /var/lib/mysql"

echo "[INFO] Running mysql_install_db ..."
lxc exec "$CONTAINER_NAME" -- bash -c "mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql"


# ------------------------------------------------------------
# START MYSQL
# ------------------------------------------------------------
echo "[INFO] Starting MariaDB..."
lxc exec "$CONTAINER_NAME" -- systemctl start mariadb
sleep 2

echo "[INFO] Checking MariaDB status..."
lxc exec "$CONTAINER_NAME" -- systemctl status mariadb --no-pager


# ------------------------------------------------------------
# FINISH
# ------------------------------------------------------------
echo "========================================================="
echo " MySQL deployed successfully!"
echo " Container name:  $CONTAINER_NAME"
echo " Storage pool:    $STORAGE_POOL"
echo " MySQL volume:    $VOLUME_NAME"
echo " ZFS dataset:     $ZFS_POOL_DATASET"
echo " MySQL running at: lxc exec $CONTAINER_NAME -- mysql -u root"
echo "========================================================="
