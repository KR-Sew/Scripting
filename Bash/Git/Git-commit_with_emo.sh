#!/bin/bash

# Define commit types and their corresponding emojis
declare -A EMOJI_MAP=(
    ["feature"]="✨"  # Sparkles
    ["fix"]="🐛"      # Bug
    ["refactor"]="🔧" # Wrench
    ["docs"]="📝"     # Memo
    ["style"]="🎨"    # Palette
    ["performance"]="⚡" # Lightning bolt
    ["remove"]="🔥"   # Fire
    ["deploy"]="🚀"   # Rocket
)

# Get commit type and message
read -p "Enter commit type (feature, fix, refactor, docs, style, performance, remove, deploy): " type
read -p "Enter commit message: " message

# Check if the type exists in the emoji map
if [[ -n "${EMOJI_MAP[$type]}" ]]; then
    emoji="${EMOJI_MAP[$type]}"
    git commit -m "$emoji $message"
else
    echo "Unknown type, committing without emoji..."
    git commit -m "$message"
fi
