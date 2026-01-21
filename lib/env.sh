#!/usr/bin/env bash
# lib/env.sh - Common environment library for claude-pilot plugin
# Provides absolute path resolution for PLUGIN_ROOT and PROJECT_DIR
# Works in both local development and marketplace deployment scenarios

# PLUGIN_ROOT resolution algorithm
# Priority: CLAUDE_PLUGIN_ROOT env var → script location calculation
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
    # Fallback: calculate from script location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
fi

# PROJECT_DIR resolution algorithm
# Priority: CLAUDE_PROJECT_DIR env var → git root → PWD
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
    PROJECT_DIR="$CLAUDE_PROJECT_DIR"
elif command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
    PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
    PROJECT_DIR="$(pwd -P)"
fi

# Export path constants
LIB_DIR="$PLUGIN_ROOT/lib"
CACHE_DIR="$PROJECT_DIR/.claude/cache"
CONFIG_DIR="$PROJECT_DIR/.claude"
PILOT_DIR="$PROJECT_DIR/.pilot"

export PLUGIN_ROOT PROJECT_DIR LIB_DIR CACHE_DIR CONFIG_DIR PILOT_DIR
