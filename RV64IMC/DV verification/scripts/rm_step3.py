from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")

input_file_path = "../mod_text/spike-2.txt"
output_file_path = "../mod_text/spike-3.txt"

with open(input_file_path, "r") as input_file, open(output_file_path, "w") as output_file:
    # Read lines from the input file
    lines = input_file.readlines()

    # Write every even-numbered line to the output file
    for i, line in enumerate(lines, start=1):
        if i % 2 == 0:
            output_file.write(line)

print(f"{formatted_date}    (3) Removing the duplicated lines in spike log")

