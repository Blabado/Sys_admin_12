import csv
import json
import uuid

def csv_to_zabbix_json(csv_file, json_file):
    host_groups = {}
    interfaces = []
    hosts = []

    with open(csv_file, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            host_name = row['host'].strip()
            ip = row['ip'].strip()
            groups_raw = row.get('groups', '').strip()
            templates_raw = row.get('templates', '').strip()

            if not host_name or not ip:
                continue

            # Группы — сделаем уникальными и добавим в словарь с uuid
            groups_list = [g.strip() for g in groups_raw.split(',') if g.strip()]
            for g in groups_list:
                if g not in host_groups:
                    host_groups[g] = str(uuid.uuid4())

            # Шаблоны
            templates_list = [t.strip() for t in templates_raw.split(',') if t.strip()]

            # Создаем interface с уникальным id
            interface_id = str(uuid.uuid4())
            interfaces.append({
                "interfaceid": interface_id,
                "type": 1,     # агент
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            })

            # Формируем хост
            host = {
                "host": host_name,
                "name": host_name,
                "groups": [{"name": g} for g in groups_list],
                "templates": [{"name": t} for t in templates_list],
                "interfaces": [{"interface_ref": interface_id}]
            }
            hosts.append(host)

    # Формируем итоговую структуру
    data = {
        "zabbix_export": {
            "version": "6.4",
            "host_groups": [{"uuid": v, "name": k} for k, v in host_groups.items()],
            "hosts": hosts,
            "interfaces": interfaces
        }
    }

    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"JSON для импорта создан: {json_file}")


csv_to_zabbix_json('hosts.csv', 'hosts_import.json')
