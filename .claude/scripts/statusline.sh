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

# Source common environment library
# shellcheck source=../lib/env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/env.sh" ]]; then
    source "$SCRIPT_DIR/../lib/env.sh"
fi

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract current directory from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Source worktree utilities for worktree detection
# Use lib directory for worktree utilities
WORKTREE_UTILS="${SCRIPT_DIR}/worktree-utils.sh"
if [ -f "$WORKTREE_UTILS" ]; then
    . "$WORKTREE_UTILS"
fi

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

# Determine pilot directory (worktree-aware)
# If in worktree, use main repo's .pilot directory
# Otherwise, use local .pilot directory
if is_in_worktree 2>/dev/null; then
    pilot_dir="$(get_main_pilot_dir 2>/dev/null || echo "$PROJECT_DIR/.pilot")"
else
    pilot_dir="$PROJECT_DIR/.pilot"
fi

# Count pending plans (always show count, even when 0)
pending_dir="${pilot_dir}/plan/pending/"
if [ -d "$pending_dir" ]; then
    pending=$(find "$pending_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || pending=0
else
    pending=0
fi

# Count draft plans (always show count, even when 0)
draft_dir="${pilot_dir}/plan/draft/"
if [ -d "$draft_dir" ]; then
    draft=$(find "$draft_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || draft=0
else
    draft=0
fi

# Count in-progress plans (always show count, even when 0)
in_progress_dir="${pilot_dir}/plan/in_progress/"
if [ -d "$in_progress_dir" ]; then
    in_progress=$(find "$in_progress_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || in_progress=0
else
    in_progress=0
fi

# Combine global output with plan counts
# Format: "global_output | 📋 D:{draft} P:{pending} I:{in_progress}"
echo "$global_output | 📋 D:$draft P:$pending I:$in_progress"
