import requests

url = "http://130.193.37.219"  # Замените на нужный URL

for i in range(20):
    try:
        response = requests.get(url)
        print(f"Запрос {i+1}: статус {response.status_code}")
    except requests.RequestException as e:
        print(f"Запрос {i+1}: ошибка {e}")
