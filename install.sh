#!/bin/bash
echo "Check the readiness of the host before installation?"
echo "Take n/Y"
read answer
if [[ -z $answer ]]; then
    answer="y"
fi
if [[ $answer == "n" ]]; then
    exit 0
fi
#------------------Check prog-----------------------------------------------
programs=("unzip" "curl" "wget" "terraform" "ansible" "ssh")
count=0
for program in "${programs[@]}"
do
	if which "$program" > /dev/null; then 
        ((count++))
	else
		echo "Please install $program"
    fi
done

if [ $count -ne ${#programs[@]} ]; then
    echo "Not all programs are installed."
    exit 1
else
    echo "The necessary programs are installed"
fi
#-------------------Check yc------------------------------------------------
echo "You need to install the yandex_cloud provider. Install and configur"
echo "Take n/Y"
read answer
if [[ $answer == "n" ]]; then
    exit 0
fi
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
sudo cp ~/yandex-cloud/bin/* /usr/bin/
rm -r ~/yandex-cloud  
if [[ $(which "${programs[0]}" > /dev/null; echo $?) -ne 0 ]]; then
    exit 0
fi
yc init
cp ~/Sys_admin_12/terraformrc ~/.terraformrc
echo "You need to log in to yandex_cloud, create a service account and insert its id"
read Id_temp
yc iam key create \
  --service-account-id $Id_temp \
  --folder-name default \
  --output key.json 
yc config profile create admin 
yc config set service-account-key key.json
echo "You need to log in to yandex_cloud and copy the cloud id"
read Id_temp
yc config set cloud-id $Id_temp
echo "You need to log in to yandex_cloud and copy the cloud folder id"
read Id_temp
yc config set folder-id $Id_temp
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id) 
cd terraform_yandex 
terraform init | tee -a ~/Sys_admin_12/Log.txt
cd ~/Sys_admin_12
Res=$(python3 back_prog/find_key_string.py Log.txt "Terraform has been successfully initialized!")
echo "$Res"
exit
#---------------------Conf yc-------------------------------------------


echo "Continue? n/y"
read answer
if [[ $answer == "n" ]]; then
    echo "Скрипт завершается."
    exit 0
fi
if [[ $answer == "n" ]]; then
    echo "Скрипт завершается."
    exit 0
fi

mkdir ./ssh_cloud 
cd ssh_cloud
ssh-keygen -t ed25519 -f ./id_ed25519
sed 's/^\(ssh-ed25519 .*\) [^ ]*$/admin:\1 admin/' ./id_ed25519.pub > ./id_ed25519.pub.tmp
mv ./id_ed25519.pub.tmp ./id_ed25519.pub
cd ..
cd terraform_yandex
terraform apply -auto-approve
cd ..
yc compute instance list | awk '{print $10}' > ~/Sys_admin_12/external_ips.txt
vm_1=$(awk 'NR==4 {print}' external_ips.txt)
vm_2=$(awk 'NR==5 {print}' external_ips.txt)
vm_3=$(awk 'NR==6 {print}' external_ips.txt)
cd ansible
echo "linux: #Группа хостов
  children: #Обозначение, что будет подгруппа хостов
    nginx: #Имя подгруппы хостов
      hosts: #Узлы группы
        vm_1: #Имя машины
          ansible_host: $vm_1 #Адрес машины ubuntu-1 proxy
        vm_2:
          ansible_host: $vm_2 #Адрес машины ubuntu-2 main
        vm_3:
          ansible_host: $vm_3 #Адрес машины ubuntu-3 proxy
  vars: #Переменные, доступные или используемые для всех подгрупп
    ansible_user: "admin"
    ansible_ssh_private_key_file: "~/Sys_admin_12/ssh_cloud/id_ed25519"
    ansible_become: true #Становиться ли другим пользователем после подключения
    #become_user: "root"" > inventory.yaml
echo "Подождем 3 минуты пока виртуалки подумают пока подумай ты чем вообще занимаешься куда идешь"
sleep 180 # По ощущениям стоит подождать
ansible all -m ping -i inventory.yaml
ansible-playbook playbook.yaml -i inventory.yaml --tags="install_packages" | tee ansible_1.log
ansible-playbook playbook.yaml -i inventory.yaml --tags="nginx_custom"  | tee ansible_2.log
echo "enter this into your browser http://$vm_2:3000"
echo "DONE"
