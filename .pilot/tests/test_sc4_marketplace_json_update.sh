#!/usr/bin/env bash
# Test SC-4: marketplace.json should use GitHub ref format

set -euo pipefail

MARKETPLACE_JSON="/Users/chanho/claude-pilot/.claude-plugin/marketplace.json"

die() {
  echo "FAIL: $*" >&2
  exit 1
}

# Check file exists
[[ -f "$MARKETPLACE_JSON" ]] || die "marketplace.json not found at: $MARKETPLACE_JSON"

# Check top-level version matches plugin version
plugin_version=$(jq -r '.version' "$MARKETPLACE_JSON")
[[ "$plugin_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid top-level version: $plugin_version"

# Check plugins array exists and has exactly one plugin
plugin_count=$(jq '.plugins | length' "$MARKETPLACE_JSON")
[[ "$plugin_count" -eq 1 ]] || die "Expected 1 plugin, found: $plugin_count"

# Check source format - should be GitHub ref, not "./"
source_type=$(jq -r '.plugins[0].source.source' "$MARKETPLACE_JSON")
[[ "$source_type" == "github" ]] || die "Source type should be 'github', got: $source_type"

# Check repository
repo=$(jq -r '.plugins[0].source.repo' "$MARKETPLACE_JSON")
[[ "$repo" == "changoo89/claude-pilot" ]] || die "Invalid repo: $repo"

# Check ref is "release"
ref=$(jq -r '.plugins[0].source.ref' "$MARKETPLACE_JSON")
[[ "$ref" == "release" ]] || die "Ref should be 'release', got: $ref"

# Verify schema fields exist
jq -e '.plugins[0].name' "$MARKETPLACE_JSON" > /dev/null || die "Missing plugin.name"
jq -e '.plugins[0].version' "$MARKETPLACE_JSON" > /dev/null || die "Missing plugin.version"
jq -e '.plugins[0].author' "$MARKETPLACE_JSON" > /dev/null || die "Missing plugin.author"

echo "✓ SC-4: marketplace.json uses GitHub ref format (source: github, repo: changoo89/claude-pilot, ref: release)"
exit 0
