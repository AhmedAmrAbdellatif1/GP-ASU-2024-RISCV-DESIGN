from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")

input_file_path = "../spike.txt"
output_file_path = "../mod_text/spike-1.txt"

with open(input_file_path, "r") as input_file, open(output_file_path, "w") as output_file:
    found_init = False

    for line in input_file:
        if "core   0: >>>>  init_machine_mode" in line:
            continue  # Skip the line with init_machine_mode

        if "core   0: >>>>  init" in line:
            found_init = True
            continue  # Skip the line with init, but mark found_init as True

        if "core   0: >>>>  test_done" in line:
            found_init = False  # Reset found_init when encountering test_done
            continue  # Skip the line with test_done

        if found_init:
            output_file.write(line)

print(f"{formatted_date}    (1) Removing kernel init. from the spike log")

