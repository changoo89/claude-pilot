#!/bin/bash
# Statusline script for claude-pilot
# Displays pending plan count in Claude Code statusline
# Input: JSON via stdin (workspace.current_dir)
# Output: Formatted statusline string

# Check jq availability
if ! command -v jq &> /dev/null; then
    echo "📁 ${PWD##*/}"
    exit 0
fi

# Read and validate JSON input
input=$(cat) || { echo "📁 ${PWD##*/}"; exit 0; }

# Parse workspace.current_dir with error handling
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty') 2>/dev/null || {
    echo "📁 ${PWD##*/}"
    exit 0
}

# Handle empty cwd - fallback to PWD
[ -z "$cwd" ] && cwd="$PWD"

# Check if pending directory exists
pending_dir="$cwd/.pilot/plan/pending/"
if [ ! -d "$pending_dir" ]; then
    echo "📁 ${cwd##*/}"
    exit 0
fi

# Count pending files (exclude .gitkeep)
pending=$(find "$pending_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || pending=0

# Format output based on pending count
if [ "$pending" -gt 0 ]; then
    echo "📁 ${cwd##*/} | 📋 P:$pending"
else
    echo "📁 ${cwd##*/}"
fi
