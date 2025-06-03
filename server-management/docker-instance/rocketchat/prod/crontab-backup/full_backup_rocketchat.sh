#!/bin/bash
# Full Backup Script for MongoDB

# Variables
BACKUP_DIR_INNER="/data/backup/full_bk" 
BACKUP_DIR="/mount/volumes/rocketchat33/backup/full_bk" 
BACKUP_DIR_TIMESTAMP="/mount/volumes/rocketchat33/backup" 
DATE=$(date +"%Y-%m-%d")
LOG_FILE="/var/docker/rocketchat33/log/full_backup.log"
TIMESTAMP_FILE="$BACKUP_DIR_TIMESTAMP/timestamp.ts" 
MONGO_USER='admin'
MONGO_PASSWD='wWOhBNvgdx3EDzy9kCHYtrRXGML4Zn7j'

AUTH_PARAM="-u ${MONGO_USER} -p ${MONGO_PASSWD} --authenticationDatabase admin "

echo "----------------------------" >> $LOG_FILE
echo "Starting full backup at $(date)" >> $LOG_FILE

# Step 1: Get the latest oplog timestamp's 
echo "Saving latest oplog timestamp before backup..." >> $LOG_FILE

# Extract the "t" (timestamp seconds) from the latest oplog entry
LATEST_TS=$(docker exec rocketchat_33 mongosh ${AUTH_PARAM} --quiet --eval 'db.getSiblingDB("local").oplog.rs.find().sort({$natural:-1}).limit(1).next().ts')

# Check if the timestamp was retrieved successfully
if [ -z "$LATEST_TS" ]; then
    echo "Failed to get oplog timestamp at $(date)" >> $LOG_FILE
else
    # Save the timestamp to the .ts file and write it to the log
    echo "$LATEST_TS" > $TIMESTAMP_FILE
    echo "Timestamp (t) saved to $TIMESTAMP_FILE: $LATEST_TS" >> $LOG_FILE
fi

# Step 2: Perform full backup using mongodump
echo "Starting full backup at $(date)" >> $LOG_FILE

# Construct the backup command
COMMAND="docker exec rocketchat_33 mongodump ${AUTH_PARAM} --archive=$BACKUP_DIR_INNER/full_backup_$DATE.gz --gzip --oplog" 
echo "Running command: $COMMAND" >> $LOG_FILE

if ! docker exec rocketchat_33 mongodump ${AUTH_PARAM} --archive=$BACKUP_DIR_INNER/full_backup_$DATE.gz --gzip --oplog >> $LOG_FILE 2>&1; then
    echo "Full backup failed at $(date)" >> $LOG_FILE
    echo "Backup failed. Check error log for details." >> $LOG_FILE
else
    echo "Full backup completed at $(date)" >> $LOG_FILE
fi

# Step 3: Delete old backup files (>30 days)
echo "Deleting old backup files (>30 days)..." >> $LOG_FILE
if ! find $BACKUP_DIR -type f -name "full_backup_*.gz" -mtime +30 -delete; then
    echo "Failed to delete old backups at $(date)" >> $LOG_FILE
    echo "Error deleting old backups. Check error log for details." >> $LOG_FILE
else
    echo "Old backups deleted successfully." >> $LOG_FILE
fi

echo "Full backup process completed at $(date)" >> $LOG_FILE
