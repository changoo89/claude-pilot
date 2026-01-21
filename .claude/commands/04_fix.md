---
description: Rapid bug fix workflow - auto-plan, execute, test, and close simple fixes in one command
argument-hint: "[bug_description] - required description of the bug to fix"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /04_fix

_Rapid bug fix workflow - automated planning, execution, and closure for simple fixes._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 → 5 in sequence
- Only stop on ERROR or when requiring user approval (Step 4)

---

## Core Philosophy

**Simple fixes only**: Max 3 SCs, well-scoped bugs | **All-in-one**: Plan → Execute → Test → Close | **User confirmation**: Show diff before commit

**When to use**: One-line fixes, simple validation, minor bugs, typos
**When NOT to use**: Features, architecture, multi-file refactor (use `/00_plan`)

---

## Step 1: Validate Scope

```bash
# Check task complexity
if echo "$1" | grep -qiE "(feature|architecture|refactor|design)"; then
    echo "⚠️  Complex task detected"
    echo "   Use /00_plan for: $1"
    exit 1
fi

echo "✓ Scope validated: Simple fix"
```

---

## Step 2: Create Mini-Plan

```bash
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE=".pilot/plan/draft/${TS}_rapid_fix.md"
mkdir -p .pilot/plan/draft

cat > "$PLAN_FILE" << EOF
# Rapid Fix: $1

## Success Criteria
- [ ] **SC-1**: Fix applied and verified
- [ ] **SC-2**: Tests pass
- [ ] **SC-3**: No regressions

## PRP Analysis
### What: Fix bug - $1
### Why: Resolves issue
### How: Apply minimal change
EOF

echo "✓ Plan created: $PLAN_FILE"
```

---

## Step 3: Execute Fix

```markdown
Task: subagent_type: coder
prompt: |
  Execute rapid fix: $PLAN_FILE
  Skills: tdd, ralph-loop
  Use TDD: Write test, implement fix, verify
```

---

## Step 4: Show Diff & Confirm

```bash
git diff
AskUserQuestion: Approve fix? A) Commit B) Discard
```

---

## Step 5: Commit or Discard

```bash
if [ "$APPROVED" = "yes" ]; then
    git add -A && git commit -m "fix: $1" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
else
    git checkout .
fi
```

---

**Related Skills**: rapid-fix | tdd | git-master

**⚠️ LIMITATION**: Max 3 SCs. Complex tasks → `/00_plan`
