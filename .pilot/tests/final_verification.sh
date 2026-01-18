#!/bin/bash
# Final verification of all changes

echo "=========================================="
echo "Final Verification: /03_close Git Push Fix"
echo "=========================================="

# Check 1: Step 7.3 has blocking behavior
echo ""
echo "Check 1: Step 7.3 has blocking header"
if grep -q "### 7.3 Safe Git Push (MANDATORY - Blocking" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Step 7.3 header updated to blocking"
else
    echo "❌ FAIL: Step 7.3 header not updated"
    exit 1
fi

# Check 2: Step 7.3 has exit 1 on failure
echo ""
echo "Check 2: Step 7.3 has blocking logic"
if grep -q "exit 1" /Users/chanho/claude-pilot/.claude/commands/03_close.md && \
   grep -q "plan closure blocked" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Step 7.3 has exit 1 on push failure"
else
    echo "❌ FAIL: Step 7.3 missing blocking logic"
    exit 1
fi

# Check 3: Step 7.4 has SHA comparison
echo ""
echo "Check 3: Step 7.4 has SHA comparison verification"
if grep -q "LOCAL_SHA" /Users/chanho/claude-pilot/.claude/commands/03_close.md && \
   grep -q "REMOTE_SHA" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Step 7.4 has SHA comparison"
else
    echo "❌ FAIL: Step 7.4 missing SHA comparison"
    exit 1
fi

# Check 4: Step 1 has git push for worktree
echo ""
echo "Check 4: Step 1 has git push for worktree mode"
if grep -q "Push squash merge to remote" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Step 1 includes worktree push"
else
    echo "❌ FAIL: Step 1 missing worktree push"
    exit 1
fi

# Check 5: Worktree push has error handling
echo ""
echo "Check 5: Worktree push has error handling"
if grep -q "Worktree preserved for manual push" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Worktree push preserves worktree on failure"
else
    echo "❌ FAIL: Worktree push missing error handling"
    exit 1
fi

# Check 6: Error messages are clear
echo ""
echo "Check 6: Error messages are actionable"
if grep -q "get_push_error_message" /Users/chanho/claude-pilot/.claude/commands/03_close.md && \
   grep -q "git push origin" /Users/chanho/claude-pilot/.claude/commands/03_close.md; then
    echo "✅ PASS: Error messages include actionable instructions"
else
    echo "❌ FAIL: Error messages not actionable"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ ALL VERIFICATION CHECKS PASSED"
echo "=========================================="
exit 0
