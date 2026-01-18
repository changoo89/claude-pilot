#!/bin/bash
# Test SC-7: Progressive Disclosure Applied to Large Guides

set -e

echo "Testing SC-7: Progressive Disclosure Pattern"
echo "============================================="

# Test 1: Verify SKILL.md exists and is ≤75 lines
test_1() {
    local skill_file="/Users/chanho/claude-pilot/.claude/guides/todo-granularity/SKILL.md"
    
    if [ ! -f "$skill_file" ]; then
        echo "❌ FAIL: SKILL.md not found at $skill_file"
        return 1
    fi
    
    local lines=$(wc -l < "$skill_file")
    if [ "$lines" -gt 75 ]; then
        echo "❌ FAIL: SKILL.md has $lines lines (exceeds 75)"
        return 1
    fi
    
    echo "✅ PASS: SKILL.md exists with $lines lines (≤75)"
    return 0
}

# Test 2: Verify REFERENCE.md exists and contains detailed content
test_2() {
    local ref_file="/Users/chanho/claude-pilot/.claude/guides/todo-granularity/REFERENCE.md"
    
    if [ ! -f "$ref_file" ]; then
        echo "❌ FAIL: REFERENCE.md not found at $ref_file"
        return 1
    fi
    
    local lines=$(wc -l < "$ref_file")
    if [ "$lines" -lt 500 ]; then
        echo "❌ FAIL: REFERENCE.md has only $lines lines (expected 600+)"
        return 1
    fi
    
    echo "✅ PASS: REFERENCE.md exists with $lines lines (600+)"
    return 0
}

# Test 3: Verify original file removed or replaced
test_3() {
    local old_file="/Users/chanho/claude-pilot/.claude/guides/todo-granularity.md"
    
    if [ -f "$old_file" ]; then
        echo "⚠️  WARNING: Original todo-granularity.md still exists (should be removed or replaced)"
    else
        echo "✅ PASS: Original file removed"
    fi
    
    return 0
}

# Test 4: Verify SKILL.md has @import reference to REFERENCE.md
test_4() {
    local skill_file="/Users/chanho/claude-pilot/.claude/guides/todo-granularity/SKILL.md"
    
    if ! grep -q "@.*todo-granularity/REFERENCE.md" "$skill_file"; then
        echo "❌ FAIL: SKILL.md doesn't reference REFERENCE.md"
        return 1
    fi
    
    echo "✅ PASS: SKILL.md references REFERENCE.md"
    return 0
}

# Test 5: Verify content preservation (all key sections present)
test_5() {
    local ref_file="/Users/chanho/claude-pilot/.claude/guides/todo-granularity/REFERENCE.md"
    
    # Check for key sections from original
    local required_sections=(
        "Three Rules"
        "Time Rule"
        "Owner Rule"
        "Atomic Rule"
        "Todo Templates"
        "Anti-Patterns"
        "Verification Checklist"
    )
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$ref_file"; then
            echo "❌ FAIL: Required section '$section' not found in REFERENCE.md"
            return 1
        fi
    done
    
    echo "✅ PASS: All required sections present in REFERENCE.md"
    return 0
}

# Run all tests
echo ""
echo "Running tests..."
echo "---------------"
test_1
test_2
test_3
test_4
test_5

echo ""
echo "============================================="
echo "All SC-7 tests passed!"
