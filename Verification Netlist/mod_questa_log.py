from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")

def extract_and_save(log_file_path, output_file_path="questa_post_syn.log"):
    with open(log_file_path, 'r') as file:
        lines = file.readlines()

    code_lines = []
    inside_code_block = False

    for line in lines:
        if "run -all" in line:
            inside_code_block = True
            continue
        elif line.startswith("# ** Note: $stop"):
            inside_code_block = False
            break

        if inside_code_block:
            code_lines.append(line.replace("#", "").strip())

    extracted_code = '\n'.join(code_lines)

    with open(output_file_path, 'w') as output_file:
        output_file.write(extracted_code)

if __name__ == "__main__":
    log_file_path = r"questa_post_syn.txt"  # Replace with your actual log file path
    extract_and_save(log_file_path)
    print(f"{formatted_date}    Modify questa log to match spike's")
