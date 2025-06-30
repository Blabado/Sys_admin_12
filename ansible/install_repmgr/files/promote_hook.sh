#!/bin/bash

REMOTE_HOST_1="192.168.10.30"   # или IP адрес удалённого сервера
REMOTE_HOST_2="192.168.10.40"   # или IP адрес удалённого сервера
REMOTE_USER="postgres"            # если SSH идёт от имени postgres
SSH_KEY="/var/lib/postgresql/.ssh/id_rsa"  # путь до приватного ключа postgres

ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_1" "sudo touch /var/www/html/mediawiki-1.43.1/backup_mode && sudo chmod 777 /var/www/html/mediawiki-1.43.1/backup_mode"
ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_2" "sudo touch /var/www/html/mediawiki-1.43.1/backup_mode && sudo chmod 777 /var/www/html/mediawiki-1.43.1/backup_mode"


ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_1" "sudo systemctl stop nginx"
echo "nginx stop successfully on $REMOTE_HOST_1, promoting standby..." >> /var/log/postgresql/repmgr.log    
ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_2" "sudo systemctl stop nginx"
echo "nginx stop successfully on $REMOTE_HOST_2, promoting standby..." >> /var/log/postgresql/repmgr.log


repmgr standby promote -f /etc/repmgr.conf


ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_1" "sudo systemctl start nginx";
echo "nginx start successfully on $REMOTE_HOST_1" >> /var/log/postgresql/repmgr.log  

ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST_2" "sudo systemctl start nginx"; 
echo "nginx start successfully on $REMOTE_HOST_2" >> /var/log/postgresql/repmgr.log  



