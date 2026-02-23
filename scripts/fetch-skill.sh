#!/bin/bash

REPO="vercel-labs/agent-browser"
BRANCH="main"
SKILL_PATH="skills/agent-browser"
OUTPUT_DIR="."
API_URL="https://api.github.com/repos/$REPO/contents"

mkdir -p "$OUTPUT_DIR"

fetch_dir() {
    local path="$1"
    local out_dir="$2"
    
    echo "Fetching: $path"
    
    local json
    json=$(curl -s "$API_URL/$path?ref=$BRANCH")
    
    echo "$json" | grep -E '"name"|"download_url"|"type"' | paste - - - | while read -r line; do
        local name=$(echo "$line" | grep -oP '"name"\s*:\s*"\K[^"]+')
        local type=$(echo "$line" | grep -oP '"type"\s*:\s*"\K[^"]+')
        local download_url=$(echo "$line" | grep -oP '"download_url"\s*:\s*"\K[^"]+' 2>/dev/null || echo "null")
        
        if [ "$type" = "dir" ]; then
            mkdir -p "$out_dir/$name"
            fetch_dir "$path/$name" "$out_dir/$name"
        elif [ "$type" = "file" ] && [ "$download_url" != "null" ]; then
            echo "  Downloading: $name"
            curl -sL "$download_url" -o "$out_dir/$name"
        fi
    done
}

fetch_dir "$SKILL_PATH" "$OUTPUT_DIR"

echo ""
echo "Done! Skill files saved to $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
