##!/bin/bash
#!/usr/bin/env bash
if [[ "$@" =~ "--debug" ]]; then
    rm Log.txt
    cp ansible/.DEBUG_inventory.yaml ansible/inventory.yaml
    #set -x 
fi

#-------------------------------Function--------------------------------

check_programs() {
    echo "Checking required programs..."
    local programs=("unzip" "curl" "wget" "ansible" "ssh")
    local missing=()

    for program in "${programs[@]}"; do
        if ! which "$program" > /dev/null; then
            echo "$program not found"
            missing+=("$program")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Please install the missing programs: ${missing[*]}"
        exit 1
    else
        echo "All required programs are installed"
    fi
}

install_yc_cli() {
    echo "Installing Yandex Cloud CLI..."
    curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    sudo cp ~/yandex-cloud/bin/* /usr/bin/
    rm -rf ~/yandex-cloud
}

install_terraform() {
    echo "Installing Terraform.."
    wget https://hashicorp-releases.yandexcloud.net/terraform/1.9.2/terraform_1.9.2_linux_amd64.zip && sudo unzip terraform_1.9.2_linux_amd64.zip -d /usr/bin 
    rm -rf ~/Sys_admin_12/terraform_1.9.2_linux_amd64.zip
}

configure_yc() {
    echo "Running 'yc init'..."
    yc init

    echo "Copying terraform config..."
    cp ~/Sys_admin_12/terraformrc ~/.terraformrc

    echo "Insert service account ID:"
    read service_id
    yc iam key create --service-account-id "$service_id" --folder-name default --output key.json

    yc config profile create admin
    yc config set service-account-key key.json

    echo "Insert Yandex Cloud ID:"
    read cloud_id
    yc config set cloud-id "$cloud_id"

    echo "Insert Yandex Folder ID:"
    read folder_id
    yc config set folder-id "$folder_id"

}

export_yc_var() {
    echo "Setting yandex_cloud variables"   
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID="$cloud_id"
    export YC_FOLDER_ID="$folder_id"
}

init_terraform() {
    echo "Initializing Terraform..."
    cd terraform_yandex
    terraform init | tee -a ~/Sys_admin_12/Log.txt
    cd ~/Sys_admin_12

    local result=$(python3 back_prog/find_key_string.py Log.txt "Terraform has been successfully initialized!")
    if [[ "$result" != "1" ]]; then
        echo "Terraform initialization failed"
        exit 1
    fi
}

generate_ssh_key() {
    echo "Generating SSH keys for Ansible...."
    mkdir -p ./ssh_cloud
    cd ssh_cloud
    ssh-keygen -t ed25519 -f ./id_ed25519 -N ""
    #sed 's/^\(ssh-ed25519 .*\) [^ ]*$/sys_admin:\1 sys_admin/' ./id_ed25519.pub > ./id_ed25519.pub.tmp
    #mv ./id_ed25519.pub.tmp ./id_ed25519.pub
    echo "Generating SSH keys for Postgres_cluster...."
    ssh-keygen -t rsa -f ~/Sys_admin_12/ansible/install_ssh/files/keys/id_rsa
    cd ..
}

run_terraform() {
    echo "Applying Terraform configuration..."
    cd terraform_yandex
    terraform apply -auto-approve
    cd ..
}

extract_ip() {

yc compute instance list > external_ip.txt.tmp
cat external_ip.txt.tmp

#Extract IP BD_PRIMARY
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "bd_primary" ]]; then
        echo "[Successful extraction of the bd_primary ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 > external_ip.txt
        break
    fi
    ((count++))
done

#Extract IP BD_STANDBY
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "bd_standby" ]]; then
        echo "[Successful extraction of the bd_standby ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done

#Extract IP Bacup_console
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "backup_console" ]]; then
        echo "[Successful extraction of the bd_backup_console ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done

#Extract IP Wiki_1
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "wiki_1" ]]; then
        echo "[Successful extraction of the db_wiki_1 ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done

#Extract IP Wiki_2
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "wiki_2" ]]; then
        echo "[Successful extraction of the db_wiki_2 ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done

#Extract IP load_balancer
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "load_balancer" ]]; then
        echo "[Successful extraction of the load_balancer ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done

#Extract IP zabbix
count=0

while true; do
    name_ip=$(awk '{print $4}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1)
    #echo "$name_ip"
    if [[ $name_ip == "zabbix" ]]; then
        echo "[Successful extraction of the zabbix ip address]"
        awk '{print $10}' external_ip.txt.tmp | tail -n +$((count)) | head -n 1 >> external_ip.txt
        break
    fi
    
    ((count++))
done


rm external_ip.txt.tmp
}

insert_ip_into_inventory() {
    echo "Inserting IPs into Ansible inventory..."
    python3 back_prog/insert_string.py external_ip.txt ansible/inventory.yaml "          ansible_host"
    python3 back_prog/delete_string.py
}

wait_for_hosts() {
    echo "Waiting for hosts to become available..."
    cd ansible
    local count=0
    local result="1"

    while [[ "$result" == "1" ]]; do
        ((count++))
        sleep 60
        ansible all -m ping -i inventory.yaml | tee -a ~/Sys_admin_12/Log.txt
        result=$(python3 ~/Sys_admin_12/back_prog/find_ping_pong.py ~/Sys_admin_12/Log.txt "pong")

        if [[ "$count" -eq 5 ]]; then
            echo "VMs did not respond after 5 attempts"
            exit 1
        fi
    done
    cd ..
}

run_ansible_playbooks() {
    echo "Running Ansible playbooks..."
    cd ansible
    ansible-playbook playbook.yaml -i inventory.yaml 
    cd ..

    echo "Setup complete!"
}

delete_external_ip() {
    echo "Deliting external ip address"
    yc compute instance remove-one-to-one-nat --name bd_primary --network-interface-index=0
    yc compute instance remove-one-to-one-nat --name bd_standby --network-interface-index=0
    yc compute instance remove-one-to-one-nat --name wiki_1 --network-interface-index=0
    yc compute instance remove-one-to-one-nat --name wiki_2 --network-interface-index=0

}

take_feedback() {
    balancer=$(awk 'NR==6 {print}' external_ip.txt)
    echo "Open in browser: http://$balancer:80" | tee -a ~/Sys_admin_12/Result.txt
    zabbix=$(awk 'NR==5 {print}' external_ip.txt)
    echo "Open in browser for zabbix: http://$zabbix:80" | tee -a ~/Sys_admin_12/Result.txt
    backup=$(awk 'NR==3 {print}' external_ip.txt)
    echo "Crash console $zabbix" | tee -a ~/Sys_admin_12/Result.txt
    echo "Доступ через backup_console осуществяется через ssh от пользователя postgres" | tee -a ~/Sys_admin_12/Result.txt
    echo "Ключ для postgres уже вшит в целевые машины в директрии /var/lib/postgres" | tee -a ~/Sys_admin_12/Result.txt
    echo "Копия ключа находится в директории ansible/install_ssh/files" | tee -a ~/Sys_admin_12/Result.txt
    echo "Поключение через внешний ip осуществляется по ключу которых находится в Sys_admin_12/ssh_cloud/id_ed25519 (Очень советую его не терять иначе доступ будет заблокирован)" | tee -a ~/Sys_admin_12/Result.txt
    echo "(Очень советую его не терять иначе доступ будет заблокирован)" | tee -a ~/Sys_admin_12/Result.txt
    echo "Доступ к балансировщику и zabbix также осуществляется через внешний ip" | tee -a ~/Sys_admin_12/Result.txt
    echo "Zabbix и балансировщик не имеет доступ по ssh к основным машиным в целях безопасности" | tee -a ~/Sys_admin_12/Result.txt
    echo "Пароли и учетные записи для подключения к базам данных можно узнать в плейбуках ansible" | tee -a ~/Sys_admin_12/Result.txt
    echo "После установки необходимо донастроить zabbix" | tee -a ~/Sys_admin_12/Result.txt
    echo "Для этого заходим на сервер zabbix входим под админской учеткой (Admin zabbix)" | tee -a ~/Sys_admin_12/Result.txt
    echo "Открываем data collection -> hosts -> import" | tee -a ~/Sys_admin_12/Result.txt
    echo "Файл импортирования находится в директории ansible zbx_export_hosts.yaml" | tee -a ~/Sys_admin_12/Result.txt
    echo "Удаляем старый хост zabbix_server" | tee -a ~/Sys_admin_12/Result.txt
    echo "Вроде все с богом" | tee -a ~/Sys_admin_12/Result.txt



}

#----------------------------General-----------------------------------------
echo "Check the readiness of the host before installation? [n/Y]"
read answer
answer=${answer:-y}

if [[ "$answer" == "y" ]]; then    
    check_programs
fi

echo "Do you want to install Yandex Cloud CLI? [n/Y]"
read answer
answer=${answer:-y}

if [[ "$answer" == "y" ]]; then
    install_yc_cli
fi

echo "Do you want to install Terraform? [n/Y]"
read answer
answer=${answer:-y}

if [[ "$answer" == "y" ]]; then
    install_terraform
fi

#---------------------------DEBUG-RUN------------------------------------------

if [[ "$@" =~ "--debug" ]]; then
    debug_skip() {
        echo "DEBUG: Execute next step --- $1? [n/Y]"
        read answer
        answer=${answer:-y}
        [[ "$answer" == "y" ]]
    }

    if debug_skip "configure_yc"; then
        configure_yc
    fi

    if debug_skip "export_yc_var"; then
        export_yc_var
    fi

    if debug_skip "init_terraform"; then
        init_terraform
    fi

    if debug_skip "generate_ssh_key"; then
        generate_ssh_key
    fi
    
    if debug_skip "run_terraform"; then
        run_terraform
    fi

    if debug_skip "extract_ip"; then
        extract_ip
    fi

    if debug_skip "insert_ip_into_inventory"; then
        insert_ip_into_inventory
    fi

    if debug_skip "wait_for_hosts"; then
        wait_for_hosts
    fi

    if debug_skip "run_ansible_playbooks"; then
        run_ansible_playbooks
    fi

    if debug_skip "delete_external_ip"; then
        delete_external_ip
    fi


#    if debug_skip "take_feedback"; then
#        take_feedback
#    fi
    exit
fi

#----------------------------General cont----------------------------
configure_yc
export_yc_var
init_terraform
generate_ssh_key
run_terraform
extract_ip
insert_ip_into_inventory
wait_for_hosts
run_ansible_playbooks
delete_external_ip
#take_feedback


