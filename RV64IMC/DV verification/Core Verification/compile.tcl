# Specify the path to the folder you want to list files from
set folder_path [pwd]

# Use glob to get a list of file names in the folder
set file_list [glob -nocomplain -directory $folder_path *]

# Extract only the file names with .sv and .svh extensions without the full path
set file_names_only {}
foreach file $file_list {
    if {[file extension $file] eq ".sv"} {
        lappend file_names_only [file tail $file]
    }
}

 puts $file_names_only

# Print the list of file names
foreach name $file_names_only {
    
}


