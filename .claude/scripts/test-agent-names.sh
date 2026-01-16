#!/bin/bash
# Test script to verify agent name case-sensitivity

echo "Checking agent name case-sensitivity..."

# Find all subagent_type references with uppercase letters
UPPERCASE=$(grep -rn "subagent_type: [A-Z]" .claude/commands/ .claude/guides/ 2>/dev/null || true)

if [ -n "$UPPERCASE" ]; then
    echo "❌ Found uppercase agent names:"
    echo "$UPPERCASE"
    exit 1
else
    echo "✅ All agent names are lowercase"
    exit 0
fi
