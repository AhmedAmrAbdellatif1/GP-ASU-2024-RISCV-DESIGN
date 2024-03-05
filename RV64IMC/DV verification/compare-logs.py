def compare_logs(spike_log_path, rtl_log_path):
    with open(spike_log_path, "r") as spike_file, open(rtl_log_path, "r") as rtl_file:
        spike_lines = spike_file.readlines()
        rtl_lines = rtl_file.readlines()

    error_count = 0
    processed_lines = set()

    # Compare lines after stripping leading and trailing whitespace
    for i, (spike_line, rtl_line) in enumerate(zip(spike_lines, rtl_lines), start=1):
        spike_line = spike_line.strip()
        rtl_line = rtl_line.strip()

        if spike_line != rtl_line:
            if i not in processed_lines:
                print(f"\033[31mDifference in line {i}:\033[0m")
                print(f"  \033[31mSpike:\033[0m {spike_line}")
                print(f"  \033[31mRTL:\033[0m   {rtl_line}\n")

                error_count += 1
                processed_lines.add(i)

    if error_count == 0:
        print("\033[32mSucceeded: Both logs are identical.\033[0m\n")
    else:
        print(f"\033[31mFailed: {error_count} differences found.\033[0m\n")

# Example usage:
spike_log_path = "../spike.log"
rtl_log_path = "../questa.log"
compare_logs(spike_log_path, rtl_log_path)

