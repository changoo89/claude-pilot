#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-dist}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$OUT_DIR/plugins/claude-pilot"

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
mkdir -p "$PLUGIN_DIR"

# Copy plugin contents to plugins/claude-pilot/
# Exclude internal-only files (999_release, release skill, docs)
for dir in agents commands skills; do
  mkdir -p "$PLUGIN_DIR/$dir"
  rsync -a --delete \
    --exclude='999_release.md' \
    --exclude='release/' \
    --exclude='docs/' \
    "$ROOT_DIR/.claude/$dir/" "$PLUGIN_DIR/$dir/"
done

# Add claude-pilot: prefix to agent references in skills (required for plugin installation)
find "$PLUGIN_DIR/skills" -name "*.md" -exec sed -i '' \
  -e 's/subagent_type: coder/subagent_type: claude-pilot:coder/g' \
  -e 's/subagent_type: tester/subagent_type: claude-pilot:tester/g' \
  -e 's/subagent_type: validator/subagent_type: claude-pilot:validator/g' \
  -e 's/subagent_type: explorer/subagent_type: claude-pilot:explorer/g' \
  -e 's/subagent_type: researcher/subagent_type: claude-pilot:researcher/g' \
  -e 's/subagent_type: documenter/subagent_type: claude-pilot:documenter/g' \
  -e 's/subagent_type: plan-reviewer/subagent_type: claude-pilot:plan-reviewer/g' \
  -e 's/subagent_type: code-reviewer/subagent_type: claude-pilot:code-reviewer/g' \
  {} \;

# Transform skill path references in commands (.claude/skills/ -> skills/)
find "$PLUGIN_DIR/commands" -name "*.md" -exec sed -i '' \
  -e 's|@\.claude/skills/|@skills/|g' \
  {} \;

mkdir -p "$PLUGIN_DIR/.claude-plugin"
cp "$ROOT_DIR/.claude-plugin/plugin.json" "$PLUGIN_DIR/.claude-plugin/plugin.json"
cp "$ROOT_DIR/README.md" "$PLUGIN_DIR/README.md"

# Generate marketplace.json at root (source points to ./plugins/claude-pilot)
VERSION=$(jq -r '.version' "$ROOT_DIR/.claude-plugin/plugin.json")
mkdir -p "$OUT_DIR/.claude-plugin"
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
      "source": "./plugins/claude-pilot",
      "category": "development"
    }
  ]
}
EOF

# Copy root-level files
cp "$ROOT_DIR/README.md" "$OUT_DIR/README.md"
cp "$ROOT_DIR/LICENSE" "$OUT_DIR/LICENSE"
cp "$ROOT_DIR/CHANGELOG.md" "$OUT_DIR/CHANGELOG.md"

# Validation
if find "$OUT_DIR" -type d -name ".claude" | grep -q .; then
  die "Output contains a .claude/ directory; marketplace tree must not include it"
fi

require_dir "$PLUGIN_DIR/agents"
require_dir "$PLUGIN_DIR/commands"
require_dir "$PLUGIN_DIR/skills"
require_file "$PLUGIN_DIR/.claude-plugin/plugin.json"
require_file "$OUT_DIR/.claude-plugin/marketplace.json"

echo "Built marketplace tree at: $OUT_DIR"
echo "  - Marketplace: $OUT_DIR/.claude-plugin/marketplace.json"
echo "  - Plugin: $PLUGIN_DIR/"
