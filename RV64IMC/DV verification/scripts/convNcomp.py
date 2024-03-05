import warnings
import pandas as pd
import csv
from datetime import datetime

current_datetime = datetime.now()
formatted_date = current_datetime.strftime("%a, %d %b %Y %H:%M:%S")


def process_line(line):
    # Split the line into parts
    parts = line.strip().split()

    # Extract instruction, gpr, and data based on the format
    if len(parts) == 3:
        instruction = parts[0].strip('()')
        gpr = parts[1]
        data = parts[2]
    elif len(parts) == 1:
        instruction = parts[0].strip('()')
        gpr = ''
        data = ''
    else:
        raise ValueError("Invalid line format")

    return instruction, gpr, data

def create_csv(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        csv_writer = csv.writer(outfile)

        # Write header
        csv_writer.writerow(['Instruction', 'GPR', 'Data'])

        # Process each line in the input file
        for line in infile:
            instruction, gpr, data = process_line(line)
            csv_writer.writerow([instruction, gpr, data])

    # print(f"CSV file '{output_file}' has been generated successfully.")

def compare_csv_files(file1_path, file2_path):
    df1 = pd.read_csv(file1_path)
    df2 = pd.read_csv(file2_path)

    error_count = 0
    processed_rows = set()

    if not df1.equals(df2):
        print("Failed: Differences found.")

        # Find and print the locations of differences
        diff_locations = (df1 != df2) & ~(pd.isna(df1) & pd.isna(df2))
        diff_rows, diff_columns = diff_locations.values.nonzero()

        for row, col in zip(diff_rows, diff_columns):
            if row not in processed_rows:
                print(f"Difference in row {row + 2}:")

                spike_value = df1.iat[row, col]
                rtl_value = df2.iat[row, col]

                print(f"  Column {df1.columns[col]}:")
                print(f"    Spike: {spike_value}")
                print(f"    RTL:   {rtl_value}")

                error_count += 1
                processed_rows.add(row)

    if error_count == 0:
        print("Succeeded: Both CSV files are identical.")
    else:
        print(f"Failed: {error_count} differences found.")

if __name__ == "__main__":
    input_file1 = "../spike.csv"  # Replace with your first output CSV file path
    input_file2 = "../questa.csv"  # Replace with your second output CSV file path
    
    print(f"{formatted_date}    Convert the log files into csv files")    

    # Generate CSV files from the previous program's output
    create_csv("../spike-log.txt", input_file1)
    create_csv("../questa-log.txt", input_file2)

    # Compare the CSV files
    
    print(f"{formatted_date}    Start comparing the csv files")
    compare_csv_files(input_file1, input_file2)

