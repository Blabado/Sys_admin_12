import re

def search_key_line(file_name, key_line):
    count = 0
    with open(file_name, 'r') as file:
        for line in file:
            if re.search(key_line, line):
                count += 1
                if count == 3:
                    return 0  # Возвращаем 1, если нашли три строки
    return 1  # Возвращаем 0, если не нашли три строки

# Пример использования функции
if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Необходимо указать имя файла и ключевую строку.")
        sys.exit(1)

    file_name = sys.argv[1]  # Имя файла, переданное как аргумент
    key_line = sys.argv[2]  # Ключевая строка, переданная как аргумент

    result = search_key_line(file_name, key_line)
    print(result)
 
