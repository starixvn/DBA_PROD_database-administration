#!/bin/bash

# Define source and destination folders
#source_folder="/mount/dest"
#dest_folder="/mount/source"
source_folder="/mount/fps/user_data/fps_db02/backup"
dest_folder="/mount/dest"
log_file="/mount/dest/move_log.txt"

# Function to check folder existence
check_folder_existence() {
    if [ ! -d "$1" ]; then
        echo "Destination folder '$1' does not exist."
        mkdir -p $1
    fi
}

# Function to check storage capacity
check_storage_capacity() {
    required_space=$(rsync -avn "$1/" "$2/" | awk 'END {print $4}' | tr -d ',')
    dest_free_space=$(df -k --output=avail "$2" | tail -n 1)

    # Convert the required_space to kilobytes (KB)
    required_space_kb=$((required_space / 1024))

    echo "required_space: $required_space_kb"
    echo "dest_free_space: $dest_free_space"

    if [ "$required_space_kb" -gt "$dest_free_space" ]; then
        echo "Insufficient storage capacity in destination folder."
        exit 1
    fi
}

# Function to check if a specific file contains the current date in the format yyyyMMdd
check_specific_file() {

    current_date=$(date +'%Y%m%d')
    specific_file=$source_folder/$1

    if [ -e "$specific_file" ]; then
        file_name=$(basename "$specific_file")

        if [ "$file_name" == "$current_date" ]; then
            echo "File '$specific_file' has the expected name. Continuing..."
        else
            echo "File '$specific_file' does not have the expected name. Exiting..."
            exit 1
        fi
    else
        echo "File '$specific_file' does not exist. Exiting..."
        exit 1
    fi

}

# Function to move files and folders using rsync
move_files_and_folders() {
    #test with dry-run option
    #rsync -avi --dry-run --stats --rsh=ssh --log-file="$3" --log-file-format="%o %n %i %f %b %l" "$1/" "$2/"
    rsync -avc --remove-source-files --stats --rsh=ssh --log-file="$3" --log-file-format="%o | Source: %f | Dest: $2/%n| Bytes: %b" "$1/" "$2/"
    #rsync -avc --stats --rsh=ssh --log-file="$3" --log-file-format="%o | Source: %f | Dest: $2/%n| Bytes: %b" "$1/" "$2/"
    echo "All files and folders moved successfully."
}

# Main script
check_folder_existence "$dest_folder"
check_storage_capacity "$source_folder" "$dest_folder"

# Check param input
if [ $# -eq 0 ]; then
    # No date parameter provided, use the current date
    specific_file="$(date +%Y%m%d)"
elif [ $# -eq 1 ] && [[ $1 =~ ^[0-9]{8}$ ]]; then
    # Date parameter provided and in the correct format
    specific_file=$1
else
    echo "$(date) | Usage: $0 [<date in yyyyMMdd format>]"
    exit 1
fi


check_specific_file "$specific_file"
move_files_and_folders "$source_folder" "$dest_folder" "$log_file"

echo "Files and folders moved successfully."
