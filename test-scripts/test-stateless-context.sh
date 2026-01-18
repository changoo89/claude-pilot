#!/bin/bash
set -e

echo "=== Test: Stateless Context with Iteration History ==="
echo "Expected: GPT acknowledges previous attempts and iteration count"

# Check if Codex available
if ! command -v codex &> /dev/null; then
  echo "⚠️ SKIP: Codex CLI not installed"
  exit 0
fi

# Build delegation prompt with full history
PROMPT="You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json

EXPECTED OUTCOME: Working jq in-place syntax

CONTEXT:
- Phase: IMPLEMENTATION (files exist)
- Original request: Fix jq syntax in marketplace.json
- File: .claude-plugin/marketplace.json
- Previous iterations:
  - Attempt 1: Tried .plugins[] |= .version = \$VERSION - Failed: syntax error
  - Attempt 2: Tried (.plugins[] | select(.name==\"claude-pilot\")) |= .version = \$VERSION - Failed: still in-place issue
  - Current iteration: 3

CONSTRAINTS:
- Must use in-place jq syntax: |= operator
- Cannot create temporary files
- Must work with jq 1.6+

MUST DO:
- Provide correct jq in-place syntax
- Explain why this syntax works
- Build on previous attempts (don't repeat same errors)

MUST NOT DO:
- Use outdated jq syntax
- Create temporary files
- Repeat solutions from Attempt 1 or 2

OUTPUT FORMAT:
Summary: [what was wrong, what was fixed]
Correct Command: [exact jq command]
Verification: [how to test it works]"

# Call GPT
RESULT=$(cd /Users/chanho/claude-pilot && .claude/scripts/codex-sync.sh "read-only" "$PROMPT")

# Check: Should acknowledge iteration history
if echo "$RESULT" | grep -qiE "iteration.*3|current.*iteration|previous.*attempt|attempt.*1.*attempt.*2"; then
  echo "✅ PASS: Stateless design includes iteration history"
  echo "GPT Output:"
  echo "$RESULT" | head -20
  exit 0
fi

# Check: Should NOT treat as fresh request
if ! echo "$RESULT" | grep -qiE "attempt|iteration|previous|history"; then
  echo "❌ FAIL: Stateless design ignored, treated as fresh request"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

# Check: Should NOT repeat failed solutions
if echo "$RESULT" | grep -qiE "\.plugins\[\]|select.*claude.*pilot"; then
  echo "❌ FAIL: Repeated failed solutions from previous attempts"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

echo "⚠️ PARTIAL: Unclear result"
echo "GPT Output:"
echo "$RESULT"
exit 2
