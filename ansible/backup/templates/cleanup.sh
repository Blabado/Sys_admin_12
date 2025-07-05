#!/bin/bash

BACKUP_DIR="/var/lib/postgresql/backups"
DAYS=7

find "$BACKUP_DIR" -type f -mtime +$MINUTES -name "*.sql" -exec rm -f {} \;

