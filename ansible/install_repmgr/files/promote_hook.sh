#!/bin/bash

REMOTE_HOST_1="192.168.10.30"   # или IP адрес удалённого сервера
REMOTE_USER="postgres"            # если SSH идёт от имени postgres
SSH_KEY="/var/lib/postgresql/.ssh/id_rsa"  # путь до приватного ключа postgres
if ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_1" "sudo systemctl stop nginx"; then
    echo "nginx stopped successfully on $REMOTE_HOST_1, promoting standby..." >> /var/log/postgresql/repmgr.log
    repmgr standby promote -f /etc/repmgr.conf
else
    echo "Failed to stop nginx on $REMOTE_HOST_1" >> /var/log/postgresql/repmgr.log
    exit 1
fi
