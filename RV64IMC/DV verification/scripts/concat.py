def concatenate_rows(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        lines = infile.read().splitlines()

        if len(lines) > 1 and all(len(line) == 4 for line in lines):
            # Concatenate each line with the following line
            concatenated_text = ''
            for i in range(0, len(lines), 2):
                if i + 1 < len(lines):
                    concatenated_text += lines[i + 1] + lines[i] + '\n'

            # Write the concatenated text to the output file
            outfile.write(concatenated_text)

            print(f"Output written to {output_file}")
        else:
            print("Invalid input file format. Each line should consist of 4 characters.")

if __name__ == "__main__":
    input_file = "../machine_code_hex.txt"  # Replace with your input file name
    output_file = "../output.txt"  # Replace with your desired output file name
    concatenate_rows(input_file, output_file)

