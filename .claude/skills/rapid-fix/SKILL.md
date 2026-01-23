---
name: rapid-fix
description: Rapid bug fix workflow - auto-plan, execute, test, and close simple fixes in one command. Use for simple bug fixes, one-line changes, minor validation issues.
---

# SKILL: Rapid Fix (Rapid Bug Fix Workflow)

> **Purpose**: Automated planning, execution, and closure for simple bug fixes in one command
> **Target**: Coder Agent fixing simple bugs (1-3 SCs)

---

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 → 5 in sequence
- Only stop on ERROR or when requiring user approval (Step 4)

---

## Quick Start

### When to Use This Skill
- One-line fixes (typos, simple validation)
- Minor bug fixes (null pointer, off-by-one)
- Simple validation additions
- Formatting issues

### When NOT to Use
- Features or architecture changes
- Multi-file refactors
- Design changes
→ Use `/00_plan` for complex tasks

---

## What This Skill Covers

### In Scope
- Scope validation (complexity score algorithm)
- Auto-generation of minimal plans (1-3 SCs)
- Direct execution via Coder agent with TDD + Ralph Loop
- User confirmation before commit
- Commit with Co-Authored-By attribution

### Out of Scope
- Full planning methodology → `/00_plan` command
- TDD cycle execution → @.claude/skills/tdd/SKILL.md
- Ralph Loop iteration → @.claude/skills/ralph-loop/SKILL.md
- Manual plan closure → `/03_close` command

---

## Step 1: Validate Scope

**Goal**: Reject complex tasks that belong in `/00_plan`

```bash
# Parse arguments
BUG_DESCRIPTION="$1"

if [ -z "$BUG_DESCRIPTION" ]; then
    echo "❌ Error: Bug description required"
    echo "   Usage: /04_fix \"bug description\""
    exit 1
fi

# Check task complexity via keywords
if echo "$BUG_DESCRIPTION" | grep -qiE "(feature|architecture|refactor|design)"; then
    echo "⚠️  Complex task detected: $BUG_DESCRIPTION"
    echo ""
    echo "   This requires full planning workflow."
    echo "   Use: /00_plan \"$BUG_DESCRIPTION\""
    exit 1
fi

echo "✓ Scope validated: Simple fix"
```

---

## Step 2: Create Mini-Plan

**Goal**: Generate minimal plan (1-3 SCs) with absolute path

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code execution directory (absolute path required)
PROJECT_ROOT="$(pwd)"

# Create plan with timestamp
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TIMESTAMP}_rapid_fix.md"

# Ensure directory exists
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"

# Generate minimal plan
cat > "$PLAN_FILE" << EOF
# Rapid Fix: $BUG_DESCRIPTION

> **Type**: Bug Fix (Rapid)
> **Estimated**: 20 minutes
> **Created**: $(date '+%Y-%m-%d %H:%M:%S')

## Success Criteria

- [ ] **SC-1**: Fix applied and verified
- [ ] **SC-2**: Tests pass
- [ ] **SC-3**: No regressions

## PRP Analysis

### What: Fix bug - $BUG_DESCRIPTION
### Why: Resolves issue impacting functionality
### How: Apply minimal change with test coverage

## Test Plan

1. Write failing test that reproduces bug
2. Implement minimal fix
3. Verify all tests pass (Ralph Loop)
4. Confirm no regressions

## Quality Gates

- Tests: ALL PASS
- Coverage: ≥80% overall
- Type-check: CLEAN
- Lint: CLEAN
EOF

echo "✓ Plan created: $PLAN_FILE"
```

---

## Step 3: Execute Fix

**Goal**: Invoke Coder agent with TDD + Ralph Loop

```markdown
Invoke Coder agent with:

Task:
  subagent_type: coder
  prompt: |
    Execute rapid fix from plan: $PLAN_FILE

    Skills to load: tdd, ralph-loop, vibe-coding

    Follow TDD cycle:
    1. Red: Write failing test
    2. Green: Minimal implementation
    3. Refactor: Apply Vibe Coding standards

    Enter Ralph Loop immediately after first code change.
    Iterate until all quality gates pass.

    Return summary when complete.
```

**Wait for Coder agent to return** with `<CODER_COMPLETE>` or `<CODER_BLOCKED>`.

**If `<CODER_BLOCKED>`**: Stop and report issue to user.

---

## Step 4: Show Diff & Confirm

**Goal**: Show user the changes and get approval

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Changes made:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git diff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask user for approval
read -p "Approve fix and commit? [y/N]: " APPROVAL

if [ "$APPROVAL" != "y" ] && [ "$APPROVAL" != "Y" ]; then
    echo "❌ Fix not approved - changes preserved"
    echo "   Plan available at: $PLAN_FILE"
    exit 0
fi

echo "✓ Fix approved"
```

---

## Step 5: Commit Changes

**Goal**: Commit with conventional commit message and Co-Authored-By

```bash
# Stage all changes
git add -A

# Create commit with Co-Authored-By
git commit -m "$(cat <<'EOF'
fix: $BUG_DESCRIPTION

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

if [ $? -eq 0 ]; then
    echo "✓ Changes committed"
    git log -1 --oneline
else
    echo "❌ Commit failed"
    exit 1
fi

echo ""
echo "🎉 Rapid fix complete!"
echo ""
echo "📊 Summary:"
echo "   Plan: $PLAN_FILE"
echo "   Commit: $(git log -1 --format='%h - %s')"
```

---

## Core Concepts

### Scope Validation Algorithm

**Complexity Keywords**:
- `feature`, `architecture`, `refactor`, `design`
- Any of these → Reject with `/00_plan` suggestion

**Rationale**: Rapid fix is for simple bugs (≤3 SCs, ≤20 minutes)

### Auto-Generated Plan Structure

**Minimal plan** (1-3 SCs):
- SC-1: Analyze bug and identify root cause
- SC-2: Implement fix with test coverage
- SC-3: Verify fix and close with commit

**Estimated time**: 20 minutes total

### Execution Integration

**Invokes Coder agent directly** with:
- TDD cycle (Red-Green-Refactor)
- Ralph Loop (autonomous iteration)
- Quality gates (tests, type-check, lint, coverage ≥80%)

### User Confirmation Flow

**Before commit**:
1. Show `git diff` to user
2. Prompt for approval (y/N)
3. If approved: Commit with Co-Authored-By
4. If not approved: Preserve plan and changes

---

## Further Reading

**Internal**: @.claude/skills/rapid-fix/REFERENCE.md - Detailed algorithm, rejection criteria, continuation workflow, error handling | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop | @.claude/skills/vibe-coding/SKILL.md - Code quality standards | @.claude/skills/git-master/SKILL.md - Git operations

**External**: [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052) | [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
