#!/bin/bash

# Default values
DEFAULT_MIN_SIZE=100
DEFAULT_PATH="/var/log"

# Get user input or use defaults
MIN_SIZE=${1:-$DEFAULT_MIN_SIZE}
SEARCH_PATH=${2:-$DEFAULT_PATH}

# Validate that the provided size argument is a number
if ! [[ "$MIN_SIZE" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid number for the minimum log file size."
    exit 1
fi

# Validate that the provided path exists
if [[ ! -d "$SEARCH_PATH" ]]; then
    echo "Error: The specified path '$SEARCH_PATH' is not a valid directory."
    exit 1
fi

echo "Searching for log files larger than $MIN_SIZE MB in $SEARCH_PATH..."
LOG_FILES=$(find "$SEARCH_PATH" -type f -size +"${MIN_SIZE}M")

# Check if any large log files were found
if [[ -z "$LOG_FILES" ]]; then
    echo "No log files larger than ${MIN_SIZE}MB found in $SEARCH_PATH."
    exit 0
fi

# Display the files and ask for confirmation
echo "The following large log files were found in $SEARCH_PATH:"
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
