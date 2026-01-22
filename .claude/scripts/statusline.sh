#!/bin/bash
# Statusline script for claude-pilot
# Combines global statusline with pending plan count
#
# This script follows the hater pattern:
# 1. Call global statusline hook (shows model info)
# 2. Append pending and in-progress plan counts
#
# Worktree-aware: Shows main repo's plan counts when in worktree
#
# Requirements: jq for JSON parsing

# Set PROJECT_DIR (self-contained, no external dependency)
if [[ -z "${PROJECT_DIR:-}" ]]; then
    if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
        PROJECT_DIR="$CLAUDE_PROJECT_DIR"
    else
        PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi
fi

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

# Determine pilot directory
pilot_dir="$PROJECT_DIR/.pilot"

# Count pending plans (always show count, even when 0)
pending_dir="${pilot_dir}/plan/pending/"
if [ -d "$pending_dir" ]; then
    pending=$(rg --files --no-ignore --glob '!*.gitkeep' "$pending_dir" 2>/dev/null | wc -l | tr -d ' ') || pending=0
else
    pending=0
fi

# Count draft plans (always show count, even when 0)
draft_dir="${pilot_dir}/plan/draft/"
if [ -d "$draft_dir" ]; then
    draft=$(rg --files --no-ignore --glob '!*.gitkeep' "$draft_dir" 2>/dev/null | wc -l | tr -d ' ') || draft=0
else
    draft=0
fi

# Count in-progress plans (always show count, even when 0)
in_progress_dir="${pilot_dir}/plan/in_progress/"
if [ -d "$in_progress_dir" ]; then
    in_progress=$(rg --files --no-ignore --glob '!*.gitkeep' "$in_progress_dir" 2>/dev/null | wc -l | tr -d ' ') || in_progress=0
else
    in_progress=0
fi

# Combine global output with plan counts
# Format: "global_output | 📋 D:{draft} P:{pending} I:{in_progress}"
echo "$global_output | 📋 D:$draft P:$pending I:$in_progress"
