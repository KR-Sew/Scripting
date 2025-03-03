#!/bin/bash

# Default minimum log file size in MB
DEFAULT_MIN_SIZE=100

# Check if the user provided a size argument, otherwise use default
MIN_SIZE=${1:-$DEFAULT_MIN_SIZE}

# Validate that the provided argument is a number
if ! [[ "$MIN_SIZE" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid number for the minimum log file size."
    exit 1
fi

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
