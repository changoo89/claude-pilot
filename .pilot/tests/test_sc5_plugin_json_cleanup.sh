#!/usr/bin/env bash
# Test SC-5: plugin.json should only contain metadata fields
# Remove commands, skills, mcpServers fields (keep only metadata)

set -euo pipefail

PLUGIN_JSON="/Users/chanho/claude-pilot/.claude-plugin/plugin.json"
REQUIRED_FIELDS=("name" "description" "version" "author" "homepage" "repository" "license" "keywords")
FORBIDDEN_FIELDS=("commands" "skills" "mcpServers")

die() {
  echo "FAIL: $*" >&2
  exit 1
}

# Check file exists
[[ -f "$PLUGIN_JSON" ]] || die "plugin.json not found at: $PLUGIN_JSON"

# Check required fields exist
for field in "${REQUIRED_FIELDS[@]}"; do
  jq -e ".${field}" "$PLUGIN_JSON" > /dev/null || die "Missing required field: ${field}"
done

echo "✓ All required fields present: ${REQUIRED_FIELDS[*]}"

# Check forbidden fields do NOT exist
for field in "${FORBIDDEN_FIELDS[@]}"; do
  if jq -e ".${field}" "$PLUGIN_JSON" > /dev/null 2>&1; then
    die "Forbidden field found: ${field} (should be removed for release branch pattern)"
  fi
done

echo "✓ No forbidden fields present: ${FORBIDDEN_FIELDS[*]}"

# Verify metadata structure
name=$(jq -r '.name' "$PLUGIN_JSON")
[[ "$name" == "claude-pilot" ]] || die "Invalid name: $name"

version=$(jq -r '.version' "$PLUGIN_JSON")
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid version format: $version"

echo "✓ SC-5: plugin.json is clean (metadata only, no commands/skills/mcpServers)"
exit 0
