#!/bin/bash
set -euo pipefail

DEST=/var/backups/glpi
DATE=$(date +%F_%H%M)

mkdir -p "$DEST"

# 1. Base de données
mariadb-dump --single-transaction --routines --triggers glpi | gzip > "$DEST/glpi-db_$DATE.sql.gz"

# 2. Configuration et données (sans cache ni sessions)
tar -czf "$DEST/glpi-files_$DATE.tar.gz" \
    --exclude='*/_cache' --exclude='*/_tmp' --exclude='*/_sessions' \
    /etc/glpi /var/lib/glpi

# 3. Rotation : suppression des sauvegardes de plus de 7 jours
find "$DEST" -type f -mtime +7 -delete

echo "Sauvegarde terminee : $DATE"
ls -lh "$DEST"
