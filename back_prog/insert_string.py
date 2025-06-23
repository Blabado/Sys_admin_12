import sys

def insert_one_line_per_keyword(source_path, dest_path, keyword):
    # Read lines from source file
    with open(source_path, 'r') as src:
        source_lines = [line.strip() for line in src if line.strip()]

    # Read lines from destination file
    with open(dest_path, 'r') as dest:
        dest_lines = dest.readlines()

    new_lines = []
    source_index = 0

    for line in dest_lines:
        if keyword in line and source_index < len(source_lines):
            # Keep the current line as-is
            new_lines.append(line.rstrip() + '\n')
            # Insert a properly indented line below it
            new_lines.append(f"{keyword}: {source_lines[source_index]}\n")
            source_index += 1
        else:
            new_lines.append(line)

    with open(dest_path, 'w') as dest:
        dest.writelines(new_lines)

    print(f"Inserted {source_index} IP addresses from '{source_path}' into '{dest_path}' after lines containing '{keyword}'.")

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python insert_lines.py <source_file> <destination_file> <keyword>")
        sys.exit(1)

    source_file = sys.argv[1]
    destination_file = sys.argv[2]
    keyword = sys.argv[3]

    insert_one_line_per_keyword(source_file, destination_file, keyword)
