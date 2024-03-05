from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")

input_file_path = "../mod_text/spike-3.txt"
output_file_path = "../spike.log"

with open(input_file_path, "r") as input_file, open(output_file_path, "w") as output_file:
    # Read lines from the input file
    lines = input_file.readlines()

    # Remove the leading "core   0: 3 " from each line
    modified_lines = [line.replace("core   0: 3 ", "") for line in lines]

    # Write the modified lines to the output file
    for modified_line in modified_lines:
        output_file.write(modified_line)

print(f"{formatted_date}    (4) Eliminating the leading garabage from spike log")

