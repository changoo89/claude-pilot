#!/usr/bin/env bash
#
# validate_versions.sh - Validate version consistency across all sources
#
# Usage: validate_versions.sh <tag_version>
#
# Exits with code 0 if all versions match, non-zero otherwise
#

set -euo pipefail

# Version to validate (e.g., "4.1.7")
TAG_VERSION="${1:-}"

if [ -z "$TAG_VERSION" ]; then
    echo "Error: Tag version not provided"
    echo "Usage: validate_versions.sh <tag_version>"
    exit 1
fi

# Strip 'v' prefix if present
TAG_VERSION="${TAG_VERSION#v}"

echo "Validating version: $TAG_VERSION"
echo "=================================="

# Read version from plugin.json
if [ ! -f ".claude-plugin/plugin.json" ]; then
    echo "Error: .claude-plugin/plugin.json not found"
    exit 1
fi

PLUGIN_VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
echo "plugin.json version: $PLUGIN_VERSION"

if [ "$TAG_VERSION" != "$PLUGIN_VERSION" ]; then
    echo "Error: Tag version ($TAG_VERSION) does not match plugin.json version ($PLUGIN_VERSION)"
    exit 1
fi

# Read version from marketplace.json
if [ ! -f ".claude-plugin/marketplace.json" ]; then
    echo "Error: .claude-plugin/marketplace.json not found"
    exit 1
fi

MARKETPLACE_VERSION=$(jq -r '.plugins[] | select(.name == "claude-pilot") | .version' .claude-plugin/marketplace.json)
echo "marketplace.json version: $MARKETPLACE_VERSION"

if [ "$TAG_VERSION" != "$MARKETPLACE_VERSION" ]; then
    echo "Error: Tag version ($TAG_VERSION) does not match marketplace.json version ($MARKETPLACE_VERSION)"
    exit 1
fi

# Read version from .pilot-version
if [ ! -f ".claude/.pilot-version" ]; then
    echo "Error: .claude/.pilot-version not found"
    exit 1
fi

PILOT_VERSION=$(cat .claude/.pilot-version)
echo ".pilot-version: $PILOT_VERSION"

if [ "$TAG_VERSION" != "$PILOT_VERSION" ]; then
    echo "Error: Tag version ($TAG_VERSION) does not match .pilot-version ($PILOT_VERSION)"
    exit 1
fi

echo "=================================="
echo "All versions are consistent!"
exit 0
