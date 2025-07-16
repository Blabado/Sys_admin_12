# Sys\_admin\_12

Набор автоматизации установки и настройки инфраструктуры с использованием Ansible, Terraform и скриптов оболочки.

## 📦 Состав проекта

- `install.sh` — основной скрипт установки.
- `ansible/` — плейбуки для настройки, особенно для MediaWiki.
- `terraform_yandex/` — конфигурации Terraform для развёртывания в Yandex.Cloud.

## 🚀 Быстрый старт

1. Склонируйте репозиторий:

   ```bash
   git clone https://github.com/Blabado/Sys_admin_12.git
   cd Sys_admin_12
   ```

2. Запустите основной скрипт:

   ```bash
   ./install.sh [--debug]
   ```

   Используйте флаг `--debug` для подробного вывода процесса установки.

3. Если у вас есть резервная база данных MediaWiki:

   Скопируйте `ansible/backup/templates/wiki.sql` в нужное место, и скрипт подхватит её автоматически.

4. Если базы нет — установка завершится, и вы сможете настроить MediaWiki через веб-интерфейс.

5. После установки замените или добавьте файл `LocalSettings.php`.

6. Доступ к admin будет через специально настроенную виртуальную машину (VM).

## 💠 Структура репозитория

```text
.
├── ansible/                  # Ansible-плейбуки и шаблоны
│   └── backup/templates/    # Шаблон дампа базы wiki.sql
├── terraform_yandex/        # Конфиги Terraform для Yandex.Cloud
├── install.sh               # Скрипт установки инфраструктуры и приложения
├── terraformrc              # Настройки для Terraform
```

## ✔ Что делает `install.sh`

1. Деплой виртуальной машины (через Terraform + Yandex.Cloud).
2. Установка зависимостей и среды (Ansible, PHP, база данных, веб-сервер).
3. Настройка MediaWiki с помощью Ansible.
4. (Опционально) Восстановление базы данных из шаблона.
5. Инструкция по ручной донастройке через браузер.

## 🔧 Настройка и требования

- **Terraform** и **Yandex.Cloud CLI** для деплоя VM.
- **Ansible** для конфигурации.
- **SSH-доступ** к целевой машине.
- (Опционально) SQL-дамп `wiki.sql`.

Убедитесь, что у вас настроены переменные окружения и ключи доступа к Yandex.Cloud.

## 📮 Связанные ресурсы

- Официальная **MediaWiki**: [https://www.mediawiki.org/](https://www.mediawiki.org/)
- Документация **Ansible**: [https://docs.ansible.com/](https://docs.ansible.com/)
- Документация **Terraform**: [https://www.terraform.io/docs](https://www.terraform.io/docs)
- Yandex.Cloud: [https://cloud.yandex.com/](https://cloud.yandex.com/)

## ⚖️ Лицензия

Пользуйся на здоровье.

