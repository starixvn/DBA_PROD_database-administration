#!/bin/bash

# Check if a date parameter is provided and in the format yyyyMMdd
if [ $# -eq 0 ]; then
  # No date parameter provided, use the current date
  current_date=$(date +%Y%m%d)
elif [ $# -eq 1 ] && [[ $1 =~ ^[0-9]{8}$ ]]; then
  # Date parameter provided and in the correct format
  current_date=$1
else
  echo "$(date) | Usage: $0 [<date in yyyyMMdd format>]"
  exit 1
fi

# Set the source directory, destination directory, and current date
extension="bak"
source_dir="/mount/fps/user_data/fps_db02-fps_01/backup/"
destination_dir="/mount/fps/dbbackup_remote/fps_db02-fps_01"

# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
    echo "$(date) | Source directory does not exist: $source_dir"
    exit 1
fi

# Loop through files with .bak extension in the source directory
for file in `find $source_dir | grep -E "\.$extension$"`
do
    # Get the filename without the path
    filename=$(basename "$file")

    # Check if the filename contains the current date
    if [[ "$filename" == *"$current_date"* ]]; then
        #get relative pathfile
        empty=""
        fullpath=$file;
        pathfile=$(echo "$file" | sed "s|$source_dir|$empty|")

        # Check if the compressed file already exists in the destination directory
        compressed_file="$destination_dir/$pathfile.7z"
        if [ ! -e "$compressed_file" ]; then

            # Grant read permission to the file
            chmod a+r "$file"

            # Compress the file using 7z and store it in the destination directory
            
            7z a -y "$destination_dir/$pathfile.7z" "$file" 1> /dev/null # suppress output info of 7z command

            # Optionally, you can remove the original .bak file after compression
            # rm "$file"

            echo "$(date) | Processed and compressed: $filename"
        else
            echo "$(date) | Skipped (already compressed): $filename"
        fi
    else
        echo "$(date) | Skipped (does not contain $current_date): $filename"
    fi
done

echo "$(date) | Script completed"
