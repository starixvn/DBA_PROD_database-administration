#!/bin/bash
# Incremental Backup Script for MongoDB

# Variables
BACKUP_DIR_INNER="/data/backup/incremental_bk"  
BACKUP_DIR="/mount/volumes/rocketchat33/backup/incremental_bk" 
DATE=$(date +"%Y-%m-%d")
LOG_FILE="/var/docker/rocketchat33/log/incremental_backup.log"
TIMESTAMP_FILE="/mount/volumes/rocketchat33/backup/timestamp.ts"
MONGO_USER='admin'
MONGO_PASSWD='wWOhBNvgdx3EDzy9kCHYtrRXGML4Zn7j'

AUTH_PARAM="-u ${MONGO_USER} -p ${MONGO_PASSWD} --authenticationDatabase admin "

# Ensure we have a valid timestamp file from the last full backup
if [ ! -f "$TIMESTAMP_FILE" ]; then
    echo "Timestamp file not found. Run a full backup first." >> $LOG_FILE
    exit 1
fi

# Step 1: Get the last timestamp for incremental backup
LAST_TIMESTAMP=$(cat "$TIMESTAMP_FILE")
if [ -z "$LAST_TIMESTAMP" ]; then
    echo "Invalid timestamp in $TIMESTAMP_FILE. Run a full backup first." >> $LOG_FILE
    exit 1
fi


echo "----------------------------" >> $LOG_FILE
echo "Starting incremental backup at $(date)" >> $LOG_FILE
echo "Using timestamp: $LAST_TIMESTAMP" >> $LOG_FILE

# Step 2: Get the latest oplog timestamp for next backup 
# Dump latest entry from oplog.rs
#NEXT_DATE=$(date -d "$DATE +1 day" +"%Y-%m-%d")
#NEXT_TIMESTAMP_FILE="$BACKUP_DIR/timestamp-$NEXT_DATE.ts"

# Extract the "t" (timestamp seconds) from the latest oplog entry
LATEST_TS=$(docker exec rocketchat_33 mongosh ${AUTH_PARAM} --quiet --eval 'db.getSiblingDB("local").oplog.rs.find().sort({$natural:-1}).limit(1).next().ts')

# Check if the timestamp was retrieved successfully
if [ -z "$LATEST_TS" ]; then
    echo "Failed to get latest oplog timestamp for next backup $(Dump)" >> $LOG_FILE
else
    # Save the timestamp to the .ts file and write it to the log
    echo "$LATEST_TS" > $TIMESTAMP_FILE
    echo "Saved next timestamp for $NEXT_DATE: $LATEST_TS" >> $LOG_FILE
fi

# Step 3: Perform incremental backup using mongodump
INCREMENTAL_BACKUP_FILE="$BACKUP_DIR_INNER/$DATE"

# Construct the backup command
EXTRACTED_TIMESTAMP=$(echo "$LAST_TIMESTAMP" | sed -n 's/.*t: \([0-9]*\).*/\1/p')

COMMAND="docker exec rocketchat_33 mongodump ${AUTH_PARAM} -d local -c oplog.rs --query='{ \"ts\": { \"\$gt\": { \"\$timestamp\": { \"t\": $(echo $EXTRACTED_TIMESTAMP), \"i\": 1 } } } }' -o $INCREMENTAL_BACKUP_FILE"

echo "Running command: $COMMAND" >> $LOG_FILE

if ! eval "$COMMAND" >> $LOG_FILE 2>&1; then
    echo "Incremental backup failed at $(date)" >> $LOG_FILE
    echo "Backup failed. Check error log for details." >> $LOG_FILE
else
    echo "Incremental backup completed at $(date)" >> $LOG_FILE
fi


# Step 4: Delete old incremental backup directories (>30 days)
if ! find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;; then
    echo "Failed to delete old incremental backup directories at $(date)" >> $LOG_FILE
    echo "Error deleting old backup directories. Check error log for details." >> $LOG_FILE
fi

