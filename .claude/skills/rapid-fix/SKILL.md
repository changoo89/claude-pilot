---
name: rapid-fix
description: Rapid bug fix workflow - auto-plan, execute, test, and close simple fixes in one command. Use for simple bug fixes, one-line changes, minor validation issues.
---

# SKILL: Rapid Fix (Rapid Bug Fix Workflow)

> **Purpose**: Automated planning, execution, and closure for simple bug fixes in one command
> **Target**: Coder Agent fixing simple bugs (1-3 SCs)

---

## Quick Start

### When to Use This Skill
- One-line fixes (typos, simple validation)
- Minor bug fixes (null pointer, off-by-one)
- Simple validation additions
- Formatting issues

### Quick Reference
```bash
# Scope validation (reject complex tasks)
COMPLEXITY_SCORE=$(calculate_score "$INPUT")
[ $COMPLEXITY_SCORE -ge 0.5 ] && echo "Use /00_plan instead"

# Auto-generate minimal plan (1-3 SCs)
PLAN_PATH=".claude-pilot/.pilot/plan/pending/fix_${TIMESTAMP}.md"
generate_plan "$BUG_DESCRIPTION" > "$PLAN_PATH"

# Execute via /02_execute with TDD + Ralph Loop
export PILOT_FIX_MODE=1
export PILOT_FIX_PLAN="$PLAN_PATH"
/02_execute

# Confirm and close
git diff HEAD
[ "$COMMIT_CONFIRM" = "true" ] && /03_close
```

---

## What This Skill Covers

### In Scope
- Scope validation (complexity score algorithm)
- Auto-generation of minimal plans (1-3 SCs)
- Direct execution via `/02_execute`
- User confirmation before commit
- Auto-close with commit on approval

### Out of Scope
- Full planning methodology → `/00_plan` command
- TDD cycle execution → @.claude/skills/tdd/SKILL.md
- Ralph Loop iteration → @.claude/skills/ralph-loop/SKILL.md
- Manual plan closure → `/03_close` command

---

## Core Concepts

### Scope Validation Algorithm

**Complexity Score** (0.0-1.0 scale):
- Input length >200 chars: +0.3
- Architecture keywords: +0.3
- >3 files mentioned: +0.2
- Multiple tasks detected: +0.2

**Threshold**: Score ≥0.5 → Reject with `/00_plan` suggestion

### Auto-Generated Plan Structure

**Minimal plan** (1-3 SCs):
- SC-1: Analyze bug and identify root cause
- SC-2: Implement fix with test coverage
- SC-3: Verify fix and close with commit

**Estimated time**: 20 minutes total

### Execution Integration

**Calls `/02_execute` directly**:
- Leverages existing continuation state system
- Automatic Ralph Loop iteration
- Quality gates enforced (tests, type-check, lint, coverage)
- State preserved for `/99_continue` resumption

### User Confirmation Flow

**Before commit**:
1. Show `git diff HEAD` to user
2. Prompt for confirmation (y/n)
3. If confirmed: Auto-close with commit
4. If not confirmed: Preserve plan and state

---

## Further Reading

**Internal**: @.claude/skills/rapid-fix/REFERENCE.md - Detailed algorithm, rejection criteria, continuation workflow, error handling | @.claude/skills/execute-plan/SKILL.md - Plan execution workflow | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop

**External**: [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052) | [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
