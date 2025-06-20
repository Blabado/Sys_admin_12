#!/bin/bash
#Предполагается что на хост машине установлен ansible 
#Предполагается что на хост машине установлен и подключен к yandex cloud - terraform
echo "Ты привязал terraform к yandex_cloud?"
sleep 3
echo "Название директории terraform_yandex если что"
sleep 1
echo "Введи пожалуйста no/yes"
read answer
if [[ $answer == "no" ]]; then
    echo "Скрипт завершается."
    exit 0
fi
mkdir ./ssh_cloud 
cd ssh_cloud
ssh-keygen -t ed25519 -f ./id_ed25519
sed 's/^\(ssh-ed25519 .*\) tim@timpc$/admin:\1 admin/' ./id_ed25519.pub > ./id_ed25519.pub.tmp
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
