#!/bin/bash

# Configuration
DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR="/var/backups/mysql"
DB_NAME="lampdb"
DB_USER="lampuser"
DB_PASS="SecurePass123!" # Ideally use a .my.cnf file for better security

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Run the backup
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"

# Delete backups older than 7 days to save space
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete

echo "Backup completed: ${DB_NAME}_${DATE}.sql"
