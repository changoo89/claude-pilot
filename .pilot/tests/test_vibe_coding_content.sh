#!/bin/bash
# Test: Verify essential content preservation in vibe-coding/REFERENCE.md

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
VIBE_REF="$PROJECT_ROOT/.claude/skills/vibe-coding/REFERENCE.md"

echo "Testing Content Preservation for vibe-coding/REFERENCE.md"
echo "=========================================================="

PASS_COUNT=0
FAIL_COUNT=0

# Check 1: SOLID acronym with external link
if grep -q "SOLID Principles Quick Reference" "$VIBE_REF" && \
   grep -q "https://en.wikipedia.org/wiki/SOLID" "$VIBE_REF"; then
    echo "✅ SOLID acronym with external link present"
    ((PASS_COUNT++))
else
    echo "❌ SOLID acronym or external link missing"
    ((FAIL_COUNT++))
fi

# Check 2: Quick Reference Checklist
if grep -q "## Quick Reference Checklist" "$VIBE_REF" && \
   grep -q "All functions ≤50 lines" "$VIBE_REF"; then
    echo "✅ Quick Reference Checklist present"
    ((PASS_COUNT++))
else
    echo "❌ Quick Reference Checklist missing"
    ((FAIL_COUNT++))
fi

# Check 3: Cross-reference to @./SKILL.md
if grep -q "@./SKILL.md" "$VIBE_REF"; then
    echo "✅ Cross-reference to @./SKILL.md present"
    ((PASS_COUNT++))
else
    echo "❌ Cross-reference to @./SKILL.md missing"
    ((FAIL_COUNT++))
fi

# Check 4: Essential principles preserved
if grep -q "Self-Documenting Code" "$VIBE_REF" && \
   grep -q "Single Abstraction Level" "$VIBE_REF" && \
   grep -q "Principle of Least Surprise" "$VIBE_REF"; then
    echo "✅ Essential VIBE principles preserved"
    ((PASS_COUNT++))
else
    echo "❌ Some VIBE principles missing"
    ((FAIL_COUNT++))
fi

# Check 5: Refactoring patterns preserved
if grep -q "Extract Method Pattern" "$VIBE_REF"; then
    echo "✅ Refactoring patterns preserved"
    ((PASS_COUNT++))
else
    echo "❌ Refactoring patterns missing"
    ((FAIL_COUNT++))
fi

# Check 6: Code Smells section preserved
if grep -q "## Code Smells and Solutions" "$VIBE_REF"; then
    echo "✅ Code Smells section preserved"
    ((PASS_COUNT++))
else
    echo "❌ Code Smells section missing"
    ((FAIL_COUNT++))
fi

# Check 7: Early Return pattern preserved
if grep -q "## Early Return Pattern" "$VIBE_REF"; then
    echo "✅ Early Return pattern preserved"
    ((PASS_COUNT++))
else
    echo "❌ Early Return pattern missing"
    ((FAIL_COUNT++))
fi

echo ""
echo "=========================================================="
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All content preservation checks passed"
    exit 0
else
    echo "❌ Some content preservation checks failed"
    exit 1
fi
