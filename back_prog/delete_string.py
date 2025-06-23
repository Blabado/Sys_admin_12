def delete_lines_by_keyword(file_path, keyword):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    filtered_lines = [line for line in lines if line.strip() != keyword.strip()]

    with open(file_path, 'w') as file:
        file.writelines(filtered_lines)

# Пример использования функции
delete_lines_by_keyword('ansible/inventory.yaml', 'ansible_host:')
