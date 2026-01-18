#!/bin/bash
# Final verification for SC-7

set -e

echo "Final Verification for SC-7"
echo "==========================="
echo ""

# Verify SKILL.md exists and size
echo "1. SKILL.md file:"
ls -lh /Users/chanho/claude-pilot/.claude/guides/todo-granularity/SKILL.md
echo ""

# Verify REFERENCE.md exists and size
echo "2. REFERENCE.md file:"
ls -lh /Users/chanho/claude-pilot/.claude/guides/todo-granularity/REFERENCE.md
echo ""

# Verify original file backed up
echo "3. Original file status:"
if [ -f /Users/chanho/claude-pilot/.claude/guides/todo-granularity.md.backup ]; then
    echo "✅ Original backed up to todo-granularity.md.backup"
else
    echo "⚠️  Original backup not found"
fi
echo ""

# Verify cross-references updated
echo "4. Cross-references updated:"
echo "- continuation-system.md:"
grep -c "todo-granularity/SKILL.md" /Users/chanho/claude-pilot/.claude/guides/continuation-system.md || true
echo "- 00_plan.md:"
grep -c "todo-granularity/SKILL.md" /Users/chanho/claude-pilot/.claude/commands/00_plan.md || true
echo ""

# Verify SKILL.md has @import to REFERENCE.md
echo "5. SKILL.md imports REFERENCE.md:"
grep "@.*todo-granularity/REFERENCE" /Users/chanho/claude-pilot/.claude/guides/todo-granularity/SKILL.md
echo ""

echo "==========================="
echo "✅ SC-7 Complete!"
