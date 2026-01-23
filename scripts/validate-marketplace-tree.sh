#!/usr/bin/env bash
set -euo pipefail

DIST_DIR="${1:-dist}"

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

require_dir "$DIST_DIR"
require_dir "$DIST_DIR/agents"
require_dir "$DIST_DIR/commands"
require_dir "$DIST_DIR/skills"
require_dir "$DIST_DIR/.claude-plugin"
require_file "$DIST_DIR/.claude-plugin/plugin.json"

if [[ -d "$DIST_DIR/.claude" ]]; then
  die "Found forbidden directory: $DIST_DIR/.claude"
fi
if find "$DIST_DIR" -type d -name ".claude" | grep -q .; then
  die "Found forbidden nested .claude/ directory under: $DIST_DIR"
fi

total_files="$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')"
agents_files="$(find "$DIST_DIR/agents" -type f | wc -l | tr -d ' ')"
commands_files="$(find "$DIST_DIR/commands" -type f | wc -l | tr -d ' ')"
skills_files="$(find "$DIST_DIR/skills" -type f | wc -l | tr -d ' ')"

echo "Marketplace tree OK: $DIST_DIR"
echo "Files: total=$total_files agents=$agents_files commands=$commands_files skills=$skills_files"
