#!/bin/bash
# Ralph Loop: Quality Gates for SC-1

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
VIBE_REF="$PROJECT_ROOT/.claude/skills/vibe-coding/REFERENCE.md"

echo "Running Quality Gates for SC-1"
echo "==============================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Gate 1: Line count ≤300
echo "[1/5] Line Count Verification"
LINE_COUNT=$(wc -l < "$VIBE_REF" | tr -d ' ')
if [ "$LINE_COUNT" -le 300 ]; then
    echo "✅ PASS: Line count is $LINE_COUNT (≤300)"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Line count is $LINE_COUNT (>300)"
    ((FAIL_COUNT++))
fi
echo ""

# Gate 2: Content preservation
echo "[2/5] Content Preservation"
if "$PROJECT_ROOT/.pilot/tests/test_vibe_coding_content.sh" > /dev/null 2>&1; then
    echo "✅ PASS: All essential content preserved"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Some content missing"
    ((FAIL_COUNT++))
fi
echo ""

# Gate 3: Markdown syntax validation
echo "[3/5] Markdown Syntax Validation"
if grep -q '^#' "$VIBE_REF" && \
   grep -q '```' "$VIBE_REF"; then
    echo "✅ PASS: Valid markdown structure"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Invalid markdown structure"
    ((FAIL_COUNT++))
fi
echo ""

# Gate 4: Cross-reference integrity
echo "[4/5] Cross-Reference Integrity"
BROKEN_REFS=0
for ref in $(grep -o '@[./a-zA-Z0-9/_-]*\.md' "$VIBE_REF" | sort -u); do
    path="${ref#@}"
    if [ "${path:0:2}" = "./" ]; then
        full_path="$PROJECT_ROOT/.claude/skills/vibe-coding/${path#./}"
    else
        full_path="$PROJECT_ROOT/$path"
    fi

    if [ ! -f "$full_path" ]; then
        echo "  ❌ Broken reference: $ref → $full_path"
        ((BROKEN_REFS++))
    fi
done

if [ $BROKEN_REFS -eq 0 ]; then
    echo "✅ PASS: All cross-references valid"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: $BROKEN_REFS broken reference(s)"
    ((FAIL_COUNT++))
fi
echo ""

# Gate 5: File integrity
echo "[5/5] File Integrity"
if [ -f "$VIBE_REF" ] && [ -s "$VIBE_REF" ]; then
    echo "✅ PASS: File exists and is not empty"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: File missing or empty"
    ((FAIL_COUNT++))
fi
echo ""

# Summary
echo "==============================="
echo "Quality Gates Summary"
echo "==============================="
echo "Passed: $PASS_COUNT/5"
echo "Failed: $FAIL_COUNT/5"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 All quality gates passed!"
    echo "<CODER_COMPLETE>"
    exit 0
else
    echo "⚠️  Some quality gates failed"
    echo "<CODER_BLOCKED>"
    exit 1
fi
