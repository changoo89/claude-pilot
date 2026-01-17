#!/bin/bash
# Statusline script for claude-pilot
# Combines global statusline with pending plan count
#
# This script follows the hater pattern:
# 1. Call global statusline hook (shows model info)
# 2. Append pending plan count
#
# Requirements: jq for JSON parsing

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract current directory from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Get global statusline output (model info)
# Global hook format: "📁 dirname | model_name"
GLOBAL_HOOK="${HOME}/.claude/hooks/statusline.sh"
if [ -x "$GLOBAL_HOOK" ]; then
    global_output=$(echo "$input" | "$GLOBAL_HOOK")
else
    # Fallback if global hook doesn't exist
    model=$(echo "$input" | jq -r '.model.display_name')
    global_output="📁 ${cwd##*/} | $model"
fi

# Count pending plans (always show count, even when 0)
pending_dir="${cwd}/.pilot/plan/pending/"
if [ -d "$pending_dir" ]; then
    pending=$(find "$pending_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || pending=0
else
    pending=0
fi

# Combine global output with pending count
echo "$global_output | 📋 P:$pending"
