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

### Delegation Flow

1. **STOP**: Scan user input for trigger signals
2. **MATCH**: Identify expert type from triggers
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/`
4. **CHECK**: Verify Codex CLI is installed (graceful fallback if not)
5. **EXECUTE**: Call `codex-sync.sh "read-only" "<prompt>"` or continue
6. **CONFIRM**: Log delegation decision

### Graceful Fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0
fi
```

---

## Step 1: Scope Validation (MANDATORY)

> **Purpose**: Reject complex tasks before plan generation
> **Algorithm**: Complexity score calculation (0.0-1.0 scale)

### Complexity Score Calculation

```bash
# Get user input (argument provided to /04_fix)
USER_INPUT="${1:-}"

# Calculate complexity score
COMPLEXITY_SCORE=0.0

# 1. Input Length Check (>200 chars → +0.3)
INPUT_LENGTH="${#USER_INPUT}"
if [ "$INPUT_LENGTH" -gt 200 ]; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.3" | bc)
fi

# 2. Keyword Detection (+0.3 for architecture keywords)
ARCH_KEYWORDS="refactor|redesign|architecture|tradeoffs|design|system"
if echo "$USER_INPUT" | grep -qiE "$ARCH_KEYWORDS"; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.3" | bc)
fi

# 3. File Count Detection (>3 files → +0.2)
# Count unique file paths in input
FILE_COUNT=$(echo "$USER_INPUT" | grep -oE '\w+\.\w+' | sort -u | wc -l)
if [ "$FILE_COUNT" -gt 3 ]; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.2" | bc)
fi

# 4. Multiple Tasks Detection (multiple "AND", "THEN", "ALSO" → +0.2)
if echo "$USER_INPUT" | grep -qiE '\s+(and|then|also)\s+'; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.2" | bc)
fi

# 5. Threshold Check (>=0.5 → Reject)
THRESHOLD=0.5
if (( $(echo "$COMPLEXITY_SCORE >= $THRESHOLD" | bc -l) )); then
    echo "⚠️  Task too complex for /04_fix"
    echo ""
    echo "This task appears to require multiple steps (estimated 4+ success criteria)."
    echo ""
    echo "Reasons:"
    [ "$INPUT_LENGTH" -gt 200 ] && echo "- Input length: $INPUT_LENGTH chars (>200 threshold)"
    echo "$USER_INPUT" | grep -qiE "$ARCH_KEYWORDS" && echo "- Keywords detected: architecture-related keywords"
    [ "$FILE_COUNT" -gt 3 ] && echo "- Files mentioned: $FILE_COUNT files (>3 threshold)"
    echo "$USER_INPUT" | grep -qiE '\s+(and|then|also)\s+' && echo "- Multiple tasks detected"
    echo ""
    echo "Use /00_plan instead for:"
    echo "- Complex bug fixes"
    echo "- Multi-file refactoring"
    echo "- Architecture decisions"
    echo "- Feature development"
    echo ""
    echo "Example: /00_plan \"$USER_INPUT\""
    exit 1
fi

echo "✓ Scope validation passed (complexity: $COMPLEXITY_SCORE)"
```

---

## Step 2: Auto-Generate Minimal Plan

> **Purpose**: Create focused plan with 1-3 SCs for simple fixes

### Plan Structure

```bash
# Generate plan filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PLAN_TITLE="fix_${TIMESTAMP}"
PLAN_PATH=".pilot/plan/pending/${PLAN_TITLE}.md"

# Extract bug description from user input
BUG_DESCRIPTION="$USER_INPUT"

# Create minimal plan
cat > "$PLAN_PATH" << EOF
# Fix: $BUG_DESCRIPTION

> **Generated**: $(date +'%Y-%m-%d %H:%M:%S') | **Work**: $PLAN_TITLE

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | $(date +%H:%M) | $BUG_DESCRIPTION | Bug fix request |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix the reported bug

**Scope**:
- **In Scope**: Bug fix as described
- **Out of Scope**: Feature additions, refactoring

### Why (Context)

**Current Problem**: Bug reported in user input

**Business Value**: Fix critical bug affecting functionality

### How (Approach)

**Implementation Strategy**:
1. Analyze the bug
2. Implement fix with TDD
3. Verify with tests
4. Close with commit

### Success Criteria

- [ ] **SC-1**: Analyze bug and identify root cause
- [ ] **SC-2**: Implement fix with test coverage
- [ ] **SC-3**: Verify fix and close with commit

---

## Test Plan

| ID | Scenario | Expected | Type |
|----|----------|----------|------|
| TS-1 | Fix resolves bug | Bug no longer occurs | Integration |
| TS-2 | No regressions | Existing tests pass | Regression |

---

## Execution Plan

1. **SC-1**: Analyze bug (coder, 5 min)
2. **SC-2**: Implement fix (coder, 10 min)
3. **SC-3**: Verify and close (validator, 5 min)

---

**Plan Version**: 1.0
**Status**: Pending
EOF

echo "✓ Plan created: $PLAN_PATH"
```

---

## Step 3: Move Plan to In Progress

```bash
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/$(basename "$PLAN_PATH")"
mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
PLAN_PATH="$IN_PROGRESS_PATH"

# Set active pointer
mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"

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

### Execution Flow

The command chains to `/02_execute` which will:
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

# Call /02_execute with the generated plan
# This ensures proper continuation state management and Ralph Loop integration
echo "→ Invoking /02_execute with generated plan..."
echo ""

# Set environment variable to indicate this is a /04_fix execution
export PILOT_FIX_MODE=1
export PILOT_FIX_PLAN="$PLAN_PATH"

# Execute the plan using /02_execute
# The /02_execute command will:
# - Move plan from pending to in_progress (if needed)
# - Create/update continuation state
# - Execute SCs with TDD + Ralph Loop
# - Update continuation state on each iteration
# - Return when complete or max iterations reached

# Note: We invoke the skill directly to ensure proper execution
/02_execute

# Capture execution result
EXEC_RESULT=$?

echo ""
echo "→ /02_execute completed with result: $EXEC_RESULT"
```

### Integration Notes

**Why call `/02_execute` directly?**
- Ensures consistent execution behavior across all commands
- Leverages existing continuation state management (Step 2.6 in `/02_execute`)
- Maintains Ralph Loop integration with state updates
- Supports `/99_continue` resumption seamlessly

**Continuation State Management**:
- State file: `.pilot/state/continuation.json`
- Updated automatically by `/02_execute` on each Ralph Loop iteration
- Includes: session_id, branch, plan_file, todos, iteration_count, max_iterations
- Compatible with `/99_continue` for resumption

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

### Show Diff and Prompt

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

# Note: In actual command execution, this uses AskUserQuestion tool
# For now, show the pattern:
echo ""
echo "Options:"
echo "  y) Yes - commit changes and close plan"
echo "  n) No - keep changes but don't commit"
echo ""
echo "→ If 'n': Use /99_continue to resume, or /03_close --no-commit to skip commit"
echo ""

# Default: Require explicit confirmation (set COMMIT_CONFIRM=true to proceed)
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

---

## Step 8: Auto-Close on Success

> **Purpose**: Archive plan and create commit (if user confirmed)

### Close Plan

```bash
if [ "$COMMIT_CONFIRM" = "true" ]; then
    echo "→ Closing plan..."

    # Move plan to done
    mkdir -p "$PROJECT_ROOT/.pilot/plan/done"
    DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/$(basename "$PLAN_PATH")"
    mv "$PLAN_PATH" "$DONE_PATH"

    # Clear active pointer
    rm -f "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"

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

---

## Related Commands

- **/00_plan** - For complex tasks requiring full planning
- **/99_continue** - Resume incomplete work
- **/02_execute** - Standard execution workflow
- **/03_close** - Manual plan closure
