#!/bin/bash

# Define source and destination folders
#source_folder="/mount/fps/user_data/fps_db02/backup"
dest_folder="/mount/bk/cts"
log_file="/mount/bk/cts/cts_bk_log.txt"
config_file="/mount/cronfiles/xtra_df.cnf"

# Function to check folder existence
check_folder_existence() {
    if [ ! -d "$1" ]; then
        echo "Destination folder '$1' does not exist."
        mkdir -p $1
    fi
}

# Function to check storage capacity
check_storage_capacity() {
    #prod required spaces
    #required_space=1073741824 # in KB, 1TB free then can be backup

    #test
    required_space=1 # in KB, 1TB free then can be backup
    dest_free_space=$(df -k --output=avail "$1" | tail -n 1)

    # Convert the required_space to kilobytes (KB)
    required_space_kb=$required_space

    echo "required_space: $required_space_kb"
    echo "dest_free_space: $dest_free_space"

    if [ "$required_space_kb" -gt "$dest_free_space" ]; then
        echo "Insufficient storage capacity in destination folder! Should be 1TB free to perform backup."
        exit 1
    fi
}

# Function to check if a specific file contains the current date in the format yyyyMMdd
create_log_file() {

    logfile=$dest_folder/$(date +'%Y%m')_log.txt

    if [ -e "$logfile" ]; then
        log_file=$logfile
    else
        touch $logfile
        log_file=$logfile
    fi
}

# Function to move files and folders using rsync
cts_xtrabackup() {
    docker run --rm -it -u0 --volumes-from cts_master_mysql80 -v /mount/bk/cts/$1:/xtrabackup_backupfiles:rw -v $3:$3:rw --network=cts_network perconalab/percona-xtrabackup:8.0.35 xtrabackup --defaults-extra-file="$3" --host=cts_master_mysql80 --port=3306 --backup --compress --compress-threads=12 --parallel=12 >> "$2" 2>&1
    #echo $1 $2 $3
    echo "Backup successfully. =====================" >> "$2"
    echo "Backup successfully."
}

cts_delete_old_backups()
{
    old_folder="$(date -d "-6 days" +%Y%m%d)_DBSPU11_160_FULL_BACKUP"
    #echo $old_folder
    #find and delete files in specific folder
    if find $1/$old_folder -type f -mtime 0 -exec rm -v {} \; >> "$2" 2>&1; then
        echo "Delete ${old_folder} successfully!!!!!!!!!!!!!!" >> "$2";
        echo "Delete ${old_folder} successfully!";
    fi
}

# Main script
check_folder_existence "$dest_folder"
check_storage_capacity "$dest_folder"

# Check param input
if [ $# -eq 0 ]; then
    # No date parameter provided, use the current date
    specific_file="$(date +%Y%m%d)_DBSPU11_160_FULL_BACKUP"
elif [ $# -eq 1 ] && [[ $1 =~ ^[0-9]{8}$ ]]; then
    # Date parameter provided and in the correct format
    specific_file="${1}_DBSPU11_160_FULL_BACKUP"
else
    echo "$(date) | Usage: $1 [<date in yyyyMMdd format>]"
    exit 1
fi

#create new log file every month
create_log_file

#<<'general_folders'
#and comments

#exec backup mysql all dbs
echo "" >> "$log_file"
echo "################################" >> "$log_file"
echo "BEGIN BACKUP PRCESS | $(date)" >> "$log_file"
echo "################################" >> "$log_file"
cts_xtrabackup "$specific_file" "$log_file" "$config_file"

echo "" >> "$log_file"
echo "################################" >> "$log_file"
echo "BEGIN TO DELETE OLD BACKUP FILES | $(date)" >> "$log_file"
echo "################################" >> "$log_file"

#delete old backup files
cts_delete_old_backups "$dest_folder" "$log_file"

echo "" >> "$log_file"
echo "################################" >> "$log_file"
echo "CRON JOB DONE !!!!!!!!!!!!!!!!!!" >> "$log_file"
echo "CRON JOB DONE !!!!!!!!!!!!!!!!!!"
echo "################################" >> "$log_file"

#general_folders