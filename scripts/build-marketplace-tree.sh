#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-dist}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

require_dir "$ROOT_DIR/.claude/agents"
require_dir "$ROOT_DIR/.claude/commands"
require_dir "$ROOT_DIR/.claude/skills"
require_file "$ROOT_DIR/.claude-plugin/plugin.json"
require_file "$ROOT_DIR/README.md"
require_file "$ROOT_DIR/LICENSE"
require_file "$ROOT_DIR/CHANGELOG.md"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

for dir in agents commands skills; do
  mkdir -p "$OUT_DIR/$dir"
  rsync -a --delete "$ROOT_DIR/.claude/$dir/" "$OUT_DIR/$dir/"
done

mkdir -p "$OUT_DIR/.claude-plugin"
cp "$ROOT_DIR/.claude-plugin/plugin.json" "$OUT_DIR/.claude-plugin/plugin.json"

# Generate marketplace.json for release branch (with local source ".")
VERSION=$(jq -r '.version' "$ROOT_DIR/.claude-plugin/plugin.json")
cat > "$OUT_DIR/.claude-plugin/marketplace.json" << EOF
{
  "\$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "claude-pilot-marketplace",
  "version": "$VERSION",
  "description": "SPEC-First development workflow with TDD, Ralph Loop, autonomous agents, and intelligent GPT Codex delegation for Claude Code",
  "owner": {
    "name": "changoo89",
    "email": "changoo89@users.noreply.github.com"
  },
  "plugins": [
    {
      "name": "claude-pilot",
      "description": "SPEC-First development workflow: Plan -> Confirm -> Execute -> Review -> Document -> Close.",
      "version": "$VERSION",
      "author": {
        "name": "changoo89",
        "email": "changoo89@users.noreply.github.com"
      },
      "source": ".",
      "category": "development"
    }
  ]
}
EOF

cp "$ROOT_DIR/README.md" "$OUT_DIR/README.md"
cp "$ROOT_DIR/LICENSE" "$OUT_DIR/LICENSE"
cp "$ROOT_DIR/CHANGELOG.md" "$OUT_DIR/CHANGELOG.md"

if find "$OUT_DIR" -type d -name ".claude" | grep -q .; then
  die "Output contains a .claude/ directory; marketplace tree must not include it"
fi

require_dir "$OUT_DIR/agents"
require_dir "$OUT_DIR/commands"
require_dir "$OUT_DIR/skills"
require_file "$OUT_DIR/.claude-plugin/plugin.json"
require_file "$OUT_DIR/.claude-plugin/marketplace.json"

echo "Built marketplace tree at: $OUT_DIR"
