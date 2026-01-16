#!/bin/bash
# Statusline script for claude-pilot
# Displays pending plan count in Claude Code statusline

# Use current directory directly
cwd="$PWD"

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
