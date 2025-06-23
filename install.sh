#!/bin/bash
#set -e

#-------------------------------Function--------------------------------

check_programs() {
    echo "Checking required programs..."
    local programs=("unzip" "curl" "terraform" "ansible" "ssh")
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

generate_ssh_keys() {
    echo "Generating SSH keys..."
    mkdir -p ./ssh_cloud
    cd ssh_cloud
    ssh-keygen -t ed25519 -f ./id_ed25519 -N ""
    sed 's/^\(ssh-ed25519 .*\) [^ ]*$/admin:\1 admin/' ./id_ed25519.pub > ./id_ed25519.pub.tmp
    mv ./id_ed25519.pub.tmp ./id_ed25519.pub
    cd ..
}

apply_terraform() {
    echo "Applying Terraform configuration..."
    cd terraform_yandex
    terraform apply -auto-approve
    cd ..
}

extract_ips() {
    echo "Extracting external IPs..."
    yc compute instance list | awk '{print $10}' | tail -n +4 | head -n -2 > external_ip.txt

    if [ ! -s external_ip.txt ]; then
        echo "No VMs have been created"
        exit 1
    fi
}

insert_ips_into_inventory() {
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
        sleep 20
        ansible all -m ping -i inventory.yaml | tee -a Log.txt
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
    ansible-playbook playbook.yaml -i inventory.yaml --tags="install_packages" | tee -a Log.txt
    ansible-playbook playbook.yaml -i inventory.yaml --tags="nginx_custom" | tee -a Log.txt
    cd ..

    echo "Setup complete!"
    echo "Open in browser: http://<vm_2_ip>:3000"
}

#----------------------------General-----------------------------------------
echo "Check the readiness of the host before installation? [n/Y]"
read answer
answer=${answer:-y}

if [[ "$answer" == "n" ]]; then
    exit 0
fi
check_programs

echo "Do you want to install and configure Yandex Cloud CLI? [n/Y]"
read answer
answer=${answer:-y}

if [[ "$answer" == "n" ]]; then
    exit 0
fi

install_yc_cli
configure_yc
init_terraform
generate_ssh_keys
apply_terraform
extract_ips
insert_ips_into_inventory
wait_for_hosts
run_ansible_playbooks
