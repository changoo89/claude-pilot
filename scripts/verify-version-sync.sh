#!/bin/bash
# Verify all version files are synchronized
# Usage: ./verify-version-sync.sh [expected_version]

set -e

if [ -z "$1" ]; then
  EXPECTED=$(grep '^version' pyproject.toml | sed 's/.*= *//' | tr -d '"')
else
  EXPECTED="$1"
fi

echo "=== Version Sync Verification ==="
echo "Expected version: $EXPECTED"
echo ""

MISMATCH=0

# Check all 5 version locations
check_version() {
  local file="$1"
  local actual="$2"
  if [ "$actual" = "$EXPECTED" ]; then
    echo "✅ $file: $actual"
  else
    echo "❌ $file: $actual (expected: $EXPECTED)"
    MISMATCH=1
  fi
}

check_version "pyproject.toml" "$(grep '^version' pyproject.toml | head -1 | sed 's/.*= *//' | tr -d '"')"
check_version "__init__.py" "$(grep '__version__' src/claude_pilot/__init__.py | head -1 | sed 's/.*= *//' | tr -d '"')"
check_version "config.py" "$(grep 'VERSION =' src/claude_pilot/config.py | head -1 | sed 's/.*= *//' | tr -d '"')"
check_version "install.sh" "$(grep 'VERSION=' install.sh | head -1 | sed 's/.*=//' | tr -d '"')"
check_version ".pilot-version" "$(cat .claude/.pilot-version 2>/dev/null || echo 'missing')"

echo ""
if [ $MISMATCH -eq 0 ]; then
  echo "✅ All versions synchronized!"
  exit 0
else
  echo "❌ Version mismatch detected!"
  exit 1
fi
