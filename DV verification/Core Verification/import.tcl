# Specify the path to the folder you want to list files from
set folder_path [pwd]

# Use glob to get a list of file names in the folder
set file_list [glob -nocomplain -directory $folder_path *]

# Open the output file for writing
set output_file [open files.f w]

# Extract only the file names with .sv and .svh extensions without the full path
foreach file $file_list {
    if {[file extension $file] eq ".sv"} {
        # Write the file name to the output file
        lappend file_names_only [file tail $file]
    }
}

puts $output_file $file_names_only

# Close the output file
close $output_file