#!/bin/bash

# Define the minimum log file size (in MB)
MIN_SIZE=100

# Find log files larger than MIN_SIZE MB
echo "Searching for log files larger than $MIN_SIZE MB..."
LOG_FILES=$(find /var/log -type f -size +"${MIN_SIZE}M")

# Check if any large log files were found
if [[ -z "$LOG_FILES" ]]; then
    echo "No log files larger than ${MIN_SIZE}MB found."
    exit 0
fi

# Display the files and ask for confirmation
echo "The following large log files were found:"
echo "$LOG_FILES"
echo

for FILE in $LOG_FILES; do
    echo -n "Do you want to clear $FILE? (y/n): "
    read -r RESPONSE
    if [[ "$RESPONSE" == "y" ]]; then
        sudo truncate -s 0 "$FILE"
        echo "Cleared: $FILE"
    else
        echo "Skipped: $FILE"
    fi
done

echo "Log file cleanup complete."
