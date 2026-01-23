#!/usr/bin/env bash
# Test SC-6: Release Branch build and validation

set -euo pipefail

ROOT_DIR="/Users/chanho/claude-pilot"
DIST_DIR="$ROOT_DIR/dist"

die() {
  echo "FAIL: $*" >&2
  exit 1
}

# Clean up any existing dist
rm -rf "$DIST_DIR"

# Run build script
echo "Building marketplace tree..."
bash "$ROOT_DIR/scripts/build-marketplace-tree.sh" "$DIST_DIR" || die "Build script failed"

# Verify dist structure exists
[[ -d "$DIST_DIR" ]] || die "Dist directory not created"
[[ -d "$DIST_DIR/agents" ]] || die "agents/ missing in dist"
[[ -d "$DIST_DIR/commands" ]] || die "commands/ missing in dist"
[[ -d "$DIST_DIR/skills" ]] || die "skills/ missing in dist"
[[ -d "$DIST_DIR/.claude-plugin" ]] || die ".claude-plugin/ missing in dist"
[[ -f "$DIST_DIR/.claude-plugin/plugin.json" ]] || die "plugin.json missing in dist"

# Verify no .claude directory in dist (must be standard structure)
if [[ -d "$DIST_DIR/.claude" ]]; then
  die "Found forbidden .claude/ directory in dist (must use standard structure)"
fi

# Run validation script
echo "Validating marketplace tree..."
bash "$ROOT_DIR/scripts/validate-marketplace-tree.sh" "$DIST_DIR" || die "Validation script failed"

# Count files to ensure content was copied
agents_count=$(find "$DIST_DIR/agents" -type f | wc -l | tr -d ' ')
commands_count=$(find "$DIST_DIR/commands" -type f | wc -l | tr -d ' ')
skills_count=$(find "$DIST_DIR/skills" -type f | wc -l | tr -d ' ')

[[ "$agents_count" -gt 0 ]] || die "No agents files copied"
[[ "$commands_count" -gt 0 ]] || die "No commands files copied"
[[ "$skills_count" -gt 0 ]] || die "No skills files copied"

echo "✓ SC-6: Build and validation successful"
echo "  - agents: $agents_count files"
echo "  - commands: $commands_count files"
echo "  - skills: $skills_count files"
exit 0
