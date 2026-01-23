#!/usr/bin/env bash
set -euo pipefail

DIST_DIR="${1:-dist}"
PLUGIN_DIR="$DIST_DIR/plugins/claude-pilot"

die() {
  echo "Error: $*" >&2
  exit 1
}

require_dir() {
  [[ -d "$1" ]] || die "Missing required directory: $1"
}

require_file() {
  [[ -f "$1" ]] || die "Missing required file: $1"
}

# Validate marketplace structure
require_dir "$DIST_DIR"
require_dir "$DIST_DIR/.claude-plugin"
require_file "$DIST_DIR/.claude-plugin/marketplace.json"

# Validate plugin structure
require_dir "$PLUGIN_DIR"
require_dir "$PLUGIN_DIR/agents"
require_dir "$PLUGIN_DIR/commands"
require_dir "$PLUGIN_DIR/skills"
require_dir "$PLUGIN_DIR/.claude-plugin"
require_file "$PLUGIN_DIR/.claude-plugin/plugin.json"

# No .claude directories allowed
if find "$DIST_DIR" -type d -name ".claude" | grep -q .; then
  die "Found forbidden .claude/ directory"
fi

total_files="$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')"
agents_files="$(find "$PLUGIN_DIR/agents" -type f | wc -l | tr -d ' ')"
commands_files="$(find "$PLUGIN_DIR/commands" -type f | wc -l | tr -d ' ')"
skills_files="$(find "$PLUGIN_DIR/skills" -type f | wc -l | tr -d ' ')"

echo "Marketplace tree OK: $DIST_DIR"
echo "  - marketplace.json: $DIST_DIR/.claude-plugin/marketplace.json"
echo "  - plugin: $PLUGIN_DIR/"
echo "  - Files: total=$total_files agents=$agents_files commands=$commands_files skills=$skills_files"
