#!/bin/bash
# Common environment library for claude-pilot scripts
#
# This file provides environment variables and common functions
# used across various claude-pilot scripts.

# Set PROJECT_DIR to CLAUDE_PROJECT_DIR if not already set
# CLAUDE_PROJECT_DIR is provided by Claude Code CLI
if [[ -z "${PROJECT_DIR:-}" ]] && [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
    export PROJECT_DIR="$CLAUDE_PROJECT_DIR"
fi

# Fallback: try to detect project root from git if PROJECT_DIR is still empty
if [[ -z "${PROJECT_DIR:-}" ]]; then
    # Try to get git root directory
    GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -n "$GIT_ROOT" ]]; then
        export PROJECT_DIR="$GIT_ROOT"
    fi
fi

# Final fallback to current directory
if [[ -z "${PROJECT_DIR:-}" ]]; then
    export PROJECT_DIR="$(pwd)"
fi

# Export pilot directory path
export PILOT_DIR="${PROJECT_DIR}/.pilot"

# Export scripts directory path
export SCRIPTS_DIR="${PROJECT_DIR}/.claude/scripts"

# Export lib directory path
export LIB_DIR="${PROJECT_DIR}/.claude/lib"
