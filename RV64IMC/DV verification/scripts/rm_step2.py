from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")

input_file_path = "../mod_text/spike-1.txt"
output_file_path = "../mod_text/spike-2.txt"

with open(input_file_path, "r") as input_file, open(output_file_path, "w") as output_file:
    # Read lines from the input file
    lines = input_file.readlines()

    # Filter out lines starting with "core   0: >>>>"
    filtered_lines = [line for line in lines if not line.startswith("core   0: >>>>")]

    # Write the filtered lines to the output file
    for line in filtered_lines:
        output_file.write(line)

print(f"{formatted_date}    (2) Removing init and main lines from spike log")

