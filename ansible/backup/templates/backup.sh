#!/bin/bash

# Конфигурация
DB_NAME="my_wiki"
DB_USER="postgres"
REMOTE_HOST="192.168.10.100"
REMOTE_USER="postgres"
REMOTE_DIR="/var/lib/postgresql/backups/"
TIMESTAMP=$(date +%F_%H-%M-%S)
BACKUP_FILE="/var/lib/postgresql/backups/wiki.sql"

# Экспорт переменной для пароля (если нужно)
# export PGPASSWORD='your_password'  # ⚠️ Не рекомендуется для продакшена, лучше использовать .pgpass

# Создание дампа
pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

# Копирование на удалённый сервер
scp "$BACKUP_FILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

# Очистка временного файла
rm -f "$BACKUP_FILE"
