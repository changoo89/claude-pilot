---
description: Rapid bug fix workflow - auto-plan, execute, test, and close simple fixes in one command
argument-hint: "[bug_description] - required description of the bug to fix"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /04_fix

_Rapid bug fix workflow - automated planning, execution, and closure for simple fixes._

## Core Philosophy

- **Simple fixes only**: Maximum 3 success criteria, well-scoped bug fixes
- **All-in-one workflow**: Plan → Execute → Test → Close in single command
- **Scope validation**: Auto-reject complex tasks (use /00_plan instead)
- **User confirmation**: Show diff before committing, require explicit approval

**When to use /04_fix**:
- One-line fixes
- Simple validation additions
- Minor bug fixes
- Typos and formatting issues

**When to use /00_plan instead**:
- Feature development
- Architecture decisions
- Multi-file refactoring
- Complex debugging (4+ SCs)

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before planning
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Architecture decision | Keywords: "tradeoffs", "design", "structure", "architecture" | Delegate to GPT Architect |
| Security concern | Keywords: "auth", "vulnerability", "credential", "security" | Delegate to GPT Security Analyst |

**See**: @.claude/skills/rapid-fix/REFERENCE.md for delegation flow implementation

---

## Step 1: Scope Validation (MANDATORY)

> **Purpose**: Reject complex tasks before plan generation
> **Algorithm**: Complexity score calculation (0.0-1.0 scale)

**Threshold**: Score ≥0.5 → Reject, suggest `/00_plan`

**Complexity Components**:
- Input length >200 chars: +0.3
- Architecture keywords: +0.3
- >3 files mentioned: +0.2
- Multiple tasks detected: +0.2

**See**: @.claude/skills/rapid-fix/REFERENCE.md for detailed algorithm and rejection criteria

---

## Step 2: Auto-Generate Minimal Plan

> **Purpose**: Create focused plan with 1-3 SCs for simple fixes

**Plan Structure**:
- User Requirements (Verbatim)
- PRP Analysis (What/Why/How)
- Success Criteria (3 SCs)
- Test Plan
- Execution Plan (20 min total)

**See**: @.claude/skills/rapid-fix/REFERENCE.md for plan template and time estimation

---

## Step 3: Move Plan to In Progress

```bash
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
IN_PROGRESS_PATH="$PROJECT_ROOT/.claude-pilot/.pilot/plan/in_progress/$(basename "$PLAN_PATH")"
mkdir -p "$PROJECT_ROOT/.claude-pilot/.pilot/plan/in_progress"
mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
PLAN_PATH="$IN_PROGRESS_PATH"

# Set active pointer
mkdir -p "$PROJECT_ROOT/.claude-pilot/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.claude-pilot/.pilot/plan/active/${KEY}.txt"

echo "✓ Plan ready: $PLAN_PATH"
```

---

## Step 4: Prepare for /02_execute (Informational)

> **Note**: Continuation state will be created by `/02_execute` automatically

The `/02_execute` command will:
- Check for existing continuation state
- Create new state if not exists
- Update state on each Ralph Loop iteration
- Handle max-iteration safety

No action needed here - state management is delegated to `/02_execute`.

---

## Step 5: Execute Plan with TDD + Ralph Loop

> **Purpose**: Auto-execute by calling /02_execute with generated plan

**Execution Flow**:
1. Read plan from `$PLAN_PATH`
2. Implement SCs using TDD (Red-Green-Refactor)
3. Run Ralph Loop until all quality gates pass
4. Update continuation state on each iteration

```bash
echo ""
echo "════════════════════════════════════════════════════════════"
echo "🚀 Executing Fix Plan via /02_execute"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Plan: $PLAN_PATH"
echo "Branch: $BRANCH"
echo ""

# Set environment variable to indicate this is a /04_fix execution
export PILOT_FIX_MODE=1
export PILOT_FIX_PLAN="$PLAN_PATH"

# Execute the plan using /02_execute
/02_execute

# Capture execution result
EXEC_RESULT=$?

echo ""
echo "→ /02_execute completed with result: $EXEC_RESULT"
```

**See**: @.claude/skills/rapid-fix/REFERENCE.md for integration notes and state management

---

## Step 6: Verify Completion

After Coder agent completes:

```bash
# Check continuation state for completion
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"

if [ -f "$STATE_FILE" ]; then
    INCOMPLETE_TODOS="$(cat "$STATE_FILE" | jq -r '.todos[] | select(.status != "complete") | .id')"
    INCOMPLETE_COUNT="$(echo "$INCOMPLETE_TODOS" | grep -c '^' || echo 0)"

    if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
        echo ""
        echo "⚠️  Work incomplete: $INCOMPLETE_COUNT todos remaining"
        echo ""
        echo "→ Use /99_continue to resume work"
        echo ""
        exit 0
    fi
fi

echo "✅ All todos complete"
```

---

## Step 7: User Confirmation Before Auto-Close

> **Purpose**: User must approve changes before commit (SC-4)

**Show Diff and Prompt**:

```bash
echo ""
echo "════════════════════════════════════════════════════════════"
echo "📋 Review Changes Before Commit"
echo "════════════════════════════════════════════════════════════"
echo ""

# Show git diff
git diff HEAD

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Prompt user for confirmation
echo "Commit these changes? (y/n)"

# Default: Require explicit confirmation
COMMIT_CONFIRM="${COMMIT_CONFIRM:-false}"

if [ "$COMMIT_CONFIRM" != "true" ]; then
    echo "ℹ️  Commit confirmation required"
    echo "   Set COMMIT_CONFIRM=true to proceed with commit"
    echo ""
    echo "→ Plan complete but not closed. Run:"
    echo "   COMMIT_CONFIRM=true /03_close"
    exit 0
fi
```

**See**: @.claude/skills/rapid-fix/REFERENCE.md for confirmation flow details

---

## Step 8: Auto-Close on Success

> **Purpose**: Archive plan and create commit (if user confirmed)

```bash
if [ "$COMMIT_CONFIRM" = "true" ]; then
    echo "→ Closing plan..."

    # Move plan to done
    mkdir -p "$PROJECT_ROOT/.claude-pilot/.pilot/plan/done"
    DONE_PATH="$PROJECT_ROOT/.claude-pilot/.pilot/plan/done/$(basename "$PLAN_PATH")"
    mv "$PLAN_PATH" "$DONE_PATH"

    # Clear active pointer
    rm -f "$PROJECT_ROOT/.claude-pilot/.pilot/plan/active/${KEY}.txt"

    echo "✓ Plan archived: $DONE_PATH"

    # Create git commit
    cd "$PROJECT_ROOT" || exit 1

    # Generate commit message
    TITLE="Fix: $(echo "$BUG_DESCRIPTION" | head -c 50)"
    COMMIT_MSG="${TITLE}

Co-Authored-By: Claude <noreply@anthropic.com>"

    git add -A
    git commit -m "$COMMIT_MSG"

    echo "✓ Git commit created"

    # Delete continuation state
    rm -f "$STATE_FILE"
    echo "✓ Continuation state cleaned up"

    echo ""
    echo "✅ Fix complete!"
    echo ""
else
    echo "→ Plan not closed (awaiting confirmation)"
fi
```

**See**: @.claude/skills/rapid-fix/REFERENCE.md for close process details

---

## Success Criteria

- [ ] Scope validation passed (complexity <0.5)
- [ ] Plan created with 1-3 SCs
- [ ] Plan executed with TDD + Ralph Loop
- [ ] All tests pass
- [ ] Coverage ≥80%
- [ ] Type check clean
- [ ] Lint clean
- [ ] User confirmed changes before commit
- [ ] Plan archived to done/
- [ ] Git commit created

---

## Continuation Support

If work is incomplete:
- Continuation state preserved in `.pilot/state/continuation.json`
- Run `/99_continue` to resume work
- Max 7 Ralph Loop iterations before manual intervention required

**See**: @.claude/skills/rapid-fix/REFERENCE.md for continuation workflow

---

## Related Commands

- **/00_plan** - For complex tasks requiring full planning
- **/99_continue** - Resume incomplete work
- **/02_execute** - Standard execution workflow
- **/03_close** - Manual plan closure

**Detailed Reference**: @.claude/skills/rapid-fix/REFERENCE.md
