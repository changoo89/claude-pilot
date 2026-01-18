---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern - iterate until all tests pass._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **One active plan**: Exactly one plan active per git branch
- **No drift**: Update plan and todo list if scope changes
- **Evidence required**: Never claim completion without verification output

**TDD**: @.claude/skills/tdd/SKILL.md | **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md | **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 0.5: Continuation State Check (MANDATORY)

> **🚨 CRITICAL**: Check for existing continuation state before starting execution
> **Purpose**: Resume work from previous session or create new continuation state

### State File Location

`.pilot/state/continuation.json`

### State Check Logic

> **Worktree Mode**: State file location depends on worktree mode
> - Standard mode: `{PROJECT_ROOT}/.pilot/state/continuation.json`
> - Worktree mode: `{WORKTREE_ROOT}/.pilot/state/continuation.json`

```bash
# Source state management scripts
STATE_READ=".pilot/scripts/state_read.sh"
STATE_WRITE=".pilot/scripts/state_write.sh"
STATE_BACKUP=".pilot/scripts/state_backup.sh"

# Parse command arguments for --wt flag (before state check)
WORKTREE_MODE=false
for arg in "$@"; do
    if [ "$arg" = "--wt" ]; then
        WORKTREE_MODE=true
        break
    fi
done

# Determine state file location based on mode
if [ "$WORKTREE_MODE" = true ]; then
    # In worktree mode, check if worktree state exists
    # First, get worktree path if already created
    if [ -n "${WORKTREE_ROOT:-}" ]; then
        STATE_FILE="$WORKTREE_ROOT/.pilot/state/continuation.json"
    else
        # Worktree not created yet, will check after creation
        STATE_FILE=""
    fi
else
    # Standard mode
    PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"
fi

if [ -f "$STATE_FILE" ]; then
    # Load existing state
    CONTINUATION_STATE="$(cat "$STATE_FILE")"

    # Extract session info
    SESSION_ID="$(echo "$CONTINUATION_STATE" | jq -r '.session_id // empty')"
    PLAN_PATH_FROM_STATE="$(echo "$CONTINUATION_STATE" | jq -r '.plan_file // empty')"
    ITERATION_COUNT="$(echo "$CONTINUATION_STATE" | jq -r '.iteration_count // 0')"
    INCOMPLETE_TODOS="$(echo "$CONTINUATION_STATE" | jq -r '.todos[] | select(.status != "complete") | .id')"

    echo "📋 Continuation state found"
    echo "   Session: $SESSION_ID"
    echo "   Plan: $PLAN_PATH_FROM_STATE"
    echo "   Iterations: $ITERATION_COUNT"
    echo "   Incomplete todos: $(echo "$INCOMPLETE_TODOS" | wc -l)"

    # Ask user what to do
    echo ""
    echo "Would you like to:"
    echo "  1) Resume from continuation state"
    echo "  2) Start fresh (clear state)"
    echo ""

    # Note: In non-interactive mode, default to resume
    RESUME="${RESUME:-true}"

    if [ "$RESUME" = "true" ]; then
        echo "✓ Resuming from continuation state"
        # Use plan path from state
        PLAN_PATH="$PLAN_PATH_FROM_STATE"

        # Load todos from state
        TODO_LIST="$(echo "$CONTINUATION_STATE" | jq -r '.todos[]')"

        # Find next incomplete todo
        NEXT_TODO="$(echo "$CONTINUATION_STATE" | jq -r '.todos[] | select(.status == "in_progress" or .status == "pending") | .id' | head -1)"

        if [ -n "$NEXT_TODO" ]; then
            echo "→ Resuming with todo: $NEXT_TODO"
        fi
    else
        echo "→ Starting fresh (clearing state)"
        rm -f "$STATE_FILE"
    fi
else
    # No state exists, will create after plan detection
    echo "ℹ No continuation state found, will create new state"
fi
```

### Integration with Plan Detection

The continuation state check happens BEFORE plan detection (Step 1):
- If state exists: Use plan path from state
- If state doesn't exist: Proceed to Step 1 (Plan Detection)

### State Creation After Plan Detection

If no state exists, create new state after plan detection:

```bash
# Create new continuation state (if not exists)
if [ ! -f "$STATE_FILE" ] && [ -n "$PLAN_PATH" ]; then
    # Extract todos from plan
    PLAN_TODOS="$(grep -E '^\- \[ \] ' "$PLAN_PATH" | sed 's/^- [ ]* //' | jq -R '.' | jq -s -c 'map({id: ., status: "pending", iteration: 0, owner: "coder"})')"

    # Create state JSON
    STATE_JSON=$(jq -n \
        --arg version "1.0" \
        --arg session_id "$(uuidgen)" \
        --arg branch "$BRANCH" \
        --arg plan_file "$PLAN_PATH" \
        --argjson todos "$PLAN_TODOS" \
        --argjson iteration_count 0 \
        --argjson max_iterations 7 \
        --arg continuation_level "normal" \
        '{
            version: $version,
            session_id: $session_id,
            branch: $branch,
            plan_file: $plan_file,
            todos: $todos,
            iteration_count: $iteration_count,
            max_iterations: $max_iterations,
            last_checkpoint: now | todate,
            continuation_level: $continuation_level
        }')

    # Backup and write state
    mkdir -p "$(dirname "$STATE_FILE")"
    [ -f "$STATE_FILE" ] && . "$STATE_BACKUP" "$STATE_FILE"
    echo "$STATE_JSON" > "$STATE_FILE"

    echo "✓ Created continuation state: $STATE_FILE"
fi
```

---

## Step 1: Plan Detection (MANDATORY FIRST ACTION)

> **🚨 YOU MUST DO THIS FIRST - NO EXCEPTIONS**

```bash
ls -la .pilot/plan/pending/*.md 2>/dev/null
ls -la .pilot/plan/in_progress/*.md 2>/dev/null
```

### Step 1.1: Plan State Transition & Worktree Setup (ATOMIC)

> **🚨 CRITICAL - BLOCKING OPERATION**: MUST complete successfully BEFORE any other work.

**Full worktree setup**: See @.claude/guides/worktree-setup.md

**Check for --wt flag**:
```bash
# Parse command arguments for --wt flag
WORKTREE_MODE=false
for arg in "$@"; do
    if [ "$arg" = "--wt" ]; then
        WORKTREE_MODE=true
        break
    fi
done

echo "Worktree mode: $WORKTREE_MODE"
```

**Worktree mode** (with --wt flag):
```bash
if [ "$WORKTREE_MODE" = true ]; then
    echo "🌳 Initializing worktree mode..."

    # Get current branch (we're in main repo)
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    MAIN_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"

    # Create new branch name for worktree
    WT_BRANCH="wt/$(date +%s)"
    echo "Creating worktree branch: $WT_BRANCH"

    # Create worktree using worktree-create.sh
    WORKTREE_CREATE_SCRIPT=".claude/scripts/worktree-create.sh"

    if [ ! -f "$WORKTREE_CREATE_SCRIPT" ]; then
        echo "❌ Error: worktree-create.sh not found" >&2
        exit 1
    fi

    # Call worktree creation script
    WORKTREE_OUTPUT="$(bash "$WORKTREE_CREATE_SCRIPT" "$WT_BRANCH" "$MAIN_BRANCH")"
    WORKTREE_EXIT_CODE=$?

    if [ $WORKTREE_EXIT_CODE -ne 0 ]; then
        echo "❌ Failed to create worktree" >&2
        exit 1
    fi

    # Extract worktree path from output
    WORKTREE_PATH="$(echo "$WORKTREE_OUTPUT" | grep "^WORKTREE_PATH=" | cut -d'=' -f2)"

    if [ -z "$WORKTREE_PATH" ] || [ ! -d "$WORKTREE_PATH" ]; then
        echo "❌ Failed to determine worktree path" >&2
        exit 1
    fi

    echo "✓ Worktree created at: $WORKTREE_PATH"

    # CRITICAL: Store worktree path for persistence across Bash tool calls
    # NOTE: Bash tool resets cwd after each call, so we store the path explicitly
    WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"
    echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
    echo "  Branch: $WT_BRANCH" >> "$WORKTREE_PERSIST_FILE"
    echo "  Main Branch: $MAIN_BRANCH" >> "$WORKTREE_PERSIST_FILE"
    echo "✓ Worktree path stored: $WORKTREE_PERSIST_FILE"

    # Set environment variables (for this shell session only)
    export PROJECT_ROOT="$WORKTREE_PATH"
    export WORKTREE_ROOT="$WORKTREE_PATH"
    export PILOT_WORKTREE_MODE=1
    export PILOT_WORKTREE_BRANCH="$WT_BRANCH"

    echo "✓ Worktree environment configured"
    echo "  Worktree Path: $WORKTREE_PATH"
    echo "  WORKTREE_ROOT: $WORKTREE_ROOT"
    echo ""
    echo "⚠️  NOTE: Bash tool resets cwd between calls."
    echo "   All file operations must use absolute paths via WORKTREE_ROOT."
fi

# Restore worktree context if available (for worktree mode persistence)
# NOTE: This must happen BEFORE plan detection to set correct paths
MAIN_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"

if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    # Worktree mode active - restore paths
    WORKTREE_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    WORKTREE_BRANCH="$(sed -n '2p' "$WORKTREE_PERSIST_FILE" | cut -d' ' -f2-)"
    MAIN_BRANCH="$(sed -n '3p' "$WORKTREE_PERSIST_FILE" | cut -d' ' -f2-)"
    WORKTREE_ROOT="$WORKTREE_PATH"
    PROJECT_ROOT="$WORKTREE_PATH"
    WORKTREE_MODE="true"
    PILOT_WORKTREE_MODE="1"

    echo "🔄 Worktree context restored"
    echo "  Worktree Path: $WORKTREE_PATH"
    echo "  Worktree Branch: $WORKTREE_BRANCH"
    echo ""
fi

# Plan detection (works in both standard and worktree mode)
PLAN_PATH="${EXPLICIT_PATH}"

# Use worktree path for plan detection if in worktree mode
PLAN_SEARCH_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"

# Priority: Explicit path → Oldest pending → Most recent in_progress
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

# IF pending, MUST move FIRST
if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PLAN_SEARCH_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "❌ FATAL: Failed to move plan" >&2; exit 1; }
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"

# Final validation
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "❌ No plan found. Run /00_plan first" >&2; exit 1; }

# Add worktree metadata to plan file (worktree mode only)
if [ "${WORKTREE_MODE:-false}" = true ]; then
    # Check if plan already has worktree info
    if ! grep -q "## Worktree Info" "$PLAN_PATH"; then
        # Add worktree metadata section (compatible with /03_close read_worktree_metadata)
        TEMP_PLAN="${PLAN_PATH}.tmp"

        # Use variables from persistence or creation
        local wt_branch="${WORKTREE_BRANCH:-$WT_BRANCH}"
        local wt_path="${WORKTREE_PATH:-}"
        local main_branch="${MAIN_BRANCH:-}"
        local main_project="${MAIN_PROJECT_ROOT:-}"

        # Create lock file path in worktree
        LOCK_FILE="${WORKTREE_ROOT}/.pilot/plan/locks/worktree.lock"

        # Insert worktree info after problem statement
        awk '
            /^## Problem Statement/ { in_problem=1 }
            in_problem && /^$/ && !added {
                print "## Worktree Info\\n"
                print "Branch: '"$wt_branch"'"
                print "Worktree Path: '"$wt_path"'"
                print "Main Branch: '"$main_branch"'"
                print "Main Project: '"$main_project"'"
                print "Lock File: '"$LOCK_FILE"'"
                print ""
                added=1
                next
            }
            { print }
        ' "$PLAN_PATH" > "$TEMP_PLAN"

        mv "$TEMP_PLAN" "$PLAN_PATH"
        echo "✓ Added worktree metadata to plan"
    fi
fi

# Set active pointer
# NOTE: In worktree mode, set pointer in worktree. In standard mode, set in main repo.
ACTIVE_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"
mkdir -p "$ACTIVE_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$ACTIVE_ROOT/.pilot/plan/active/${KEY}.txt"

echo "✓ Plan ready: $PLAN_PATH"
echo "  Branch: $BRANCH"
[ "${WORKTREE_MODE:-false}" = true ] && echo "  Mode: Worktree" || echo "  Mode: Standard"
```

**Standard mode** (without --wt):
```bash
if [ "$WORKTREE_MODE" = false ]; then
    PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    PLAN_PATH="${EXPLICIT_PATH}"

    # Priority: Explicit path → Oldest pending → Most recent in_progress
    [ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

    # IF pending, MUST move FIRST
    if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
        PLAN_FILENAME="$(basename "$PLAN_PATH")"
        IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
        mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
        mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "❌ FATAL: Failed to move plan" >&2; exit 1; }
        PLAN_PATH="$IN_PROGRESS_PATH"
    fi

    [ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"

    # Final validation
    [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "❌ No plan found. Run /00_plan first" >&2; exit 1; }

    # Set active pointer
    mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
    BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
    KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"

    echo "✓ Plan ready: $PLAN_PATH (standard mode)"
fi
```

---

## Step 1.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before execution
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| 2+ failed attempts | Previous attempts failed | Delegate to Architect |
| Architecture decision | "tradeoffs", "design", "structure" | Delegate to Architect |
| Security concern | "auth", "vulnerability", "secure" | Delegate to Security Analyst |

---

## Step 2: Convert Plan to Todo List

Read plan, extract: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan

**Rules**:
- **Sequential**: One `in_progress` at a time
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously
- **MANDATORY**: After EVERY "Implement/Add/Create" todo, add "Run tests for [X]" todo

**Full parallel patterns**: @.claude/guides/parallel-execution.md

---

## Step 2.1: SC Dependency Analysis (MANDATORY)

> **🚨 CRITICAL**: Before invoking Coder agents, analyze SC dependencies to determine parallel execution strategy

> **Implementation**: This analysis is performed inline by reading the plan file. No separate script needed.

### Dependency Analysis Process

1. **Extract all Success Criteria** from plan file
2. **Parse file paths** mentioned in each SC
3. **Check for file overlaps** (conflicts - same file modified by multiple SCs)
4. **Check for dependency keywords** ("requires", "depends on", "after", "needs")
5. **Group SCs** by parallel execution capability

### Dependency Analysis Table Template

| SC | Files | Dependencies | Parallel Group | Notes |
|----|-------|--------------|----------------|-------|
| SC-1 | `src/auth/login.ts` | None | Group 1 | Independent |
| SC-2 | `src/auth/logout.ts` | None | Group 1 | Independent |
| SC-3 | `tests/auth.test.ts` | None | Group 1 | Independent |
| SC-4 | `src/auth/middleware.ts` | SC-1 | Group 2 | Requires SC-1 |
| SC-5 | `docs/auth.md` | SC-4 | Group 3 | Requires middleware |

### File Conflict Detection

**Rules**:
- If 2+ SCs modify the same file → Sequential execution (different groups)
- If SC-2 references SC-1 output → Sequential execution (SC-2 after SC-1)
- If SCs have different files and no references → Parallel execution (same group)

### Parallel Group Assignment

- **Group 1**: Fully independent SCs (different files, no dependencies)
- **Group 2**: SCs dependent on Group 1 completion
- **Group 3+**: SCs dependent on previous groups

### Output

After analysis, produce:
1. **Dependency table** (as shown above)
2. **Execution strategy**: Parallel vs Sequential for each group
3. **Todo list** organized by parallel groups

---

## Step 2.2: Parallel Coder Invocation (For Independent SCs)

> **For Group 1 (Independent SCs)**: Invoke multiple Coder agents concurrently using Task tool

> **For Group 2+ (Dependent SCs)**: Sequential execution after previous group completes

### Parallel Execution Pattern (Group 1)

**🚀 MANDATORY ACTION**: For each independent SC in Group 1, invoke a separate Coder agent NOW

```markdown
[Parallel Group 1 - Independent SCs]

Task:
  subagent_type: coder
  prompt: |
    Execute SC-1: {SC-1_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

Task:
  subagent_type: coder
  prompt: |
    Execute SC-2: {SC-2_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

Task:
  subagent_type: coder
  prompt: |
    Execute SC-3: {SC-3_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.
```

### 2.2.1 Process Parallel Coder Results

**Expected Output**: Each agent returns `<CODER_COMPLETE>` or `<CODER_BLOCKED>`

**Wait for ALL agents** in parallel group to complete before proceeding.

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | SC met, tests pass, coverage ≥80% | Mark todo as complete |
| `<CODER_BLOCKED>` | Cannot complete | **AUTO-DELEGATE to GPT Architect** |

**After ALL agents return**:
1. Mark all parallel todos as `completed` together
2. Verify no file conflicts (should be none if dependency analysis correct)
3. Integrate results (combine file lists, test results, coverage data)
4. Proceed to Group 2 (if any) or to Step 3.5 (Verification)

### Sequential Execution Pattern (Group 2+)

For dependent SCs (Group 2+), invoke Coder agents **sequentially** after previous group completes:

```markdown
[Sequential Group 2 - Dependent SCs]

# Invoke one Coder at a time, wait for completion before next
Task:
  subagent_type: coder
  prompt: |
    Execute SC-4: {SC-4_DESCRIPTION}
    (Requires SC-1 to be complete)

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

# After SC-4 completes, then invoke SC-5, and so on...
```

### 2.2.2 Partial Failure Handling

If 1 of N parallel agents fails:

1. Note the failure with agent ID and SC
2. Continue waiting for other parallel agents
3. Present all results together (successes + failures)
4. Re-invoke **only failed agent** (with error context from previous attempt)
5. Merge successful results once retry succeeds

**Fallback**: If 2+ retries fail, use `AskUserQuestion` for recovery options

---

## Step 2.3: Legacy Single Coder Pattern (Optional)

> **For simple plans** (1-2 SCs, no clear parallelization benefit), use single Coder agent

```markdown
[Single Coder - For Simple Plans]

Task:
  subagent_type: coder
  prompt: |
    Execute the following plan:

    Plan Path: {PLAN_PATH}
    Success Criteria: {SC_LIST_FROM_PLAN}
    Test Scenarios: {TS_LIST_FROM_PLAN}

    Implement using TDD + Ralph Loop. Return summary only.
```

**When to use single Coder**:
- Plan has 1-2 SCs only
- No clear file separation between SCs
- Sequential dependencies between all SCs
- Resource constraints (cost optimization)

---

## Step 3: Process Coder Agent Results

> **Process results from parallel or sequential Coder invocation**

### 3.1 Verify Coder Output (TDD Enforcement)

> **🚨 CRITICAL - MANDATORY Verification**

Required fields in agent output:
- [ ] Test Files created
- [ ] Test Results (PASS/FAIL counts)
- [ ] Coverage percentage (≥80% overall, ≥90% core)
- [ ] Ralph Loop iterations count

**If verification fails**: Re-invoke with explicit instruction or use `AskUserQuestion`

### 3.2 Auto-Delegation to GPT Architect

> **MANDATORY**: When Coder returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect

**Trigger**: Coder agent reports it cannot complete the work

**Action**:
1. Read `.claude/rules/delegator/prompts/architect.md`
2. Build delegation prompt with context:
   - What the coder was trying to do
   - What blocked it
   - Relevant code snippets
   - Error messages
3. Call: `.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"`
4. Process Architect response
5. Re-invoke Coder with Architect guidance

**Fallback**: If Architect also fails, then use `AskUserQuestion`

**Delegation Count**: Track attempts, max 2 auto-delegations before fallback

---

## Step 3.5: Parallel Verification (Multi-Angle Quality Check)

> **Reference**: @.claude/guides/parallel-execution.md#pattern-2

**🚀 MANDATORY ACTION**: Invoke all three verification agents NOW

```markdown
Task:
  subagent_type: tester
  prompt: |
    Run tests and verify coverage for {PLAN_PATH}.
    Return: Test results, Coverage percentage, Failing test details.

Task:
  subagent_type: validator
  prompt: |
    Run type check and lint for {PLAN_PATH}.
    Return: Type check result, Lint result, Error details.

Task:
  subagent_type: code-reviewer
  prompt: |
    Review code for {PLAN_PATH}.
    Focus: Async bugs, memory leaks, security issues.
```

### 3.5.1 Process Verification Results

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## Step 4: Result Integration Pattern

### Parallel Agent Completion

1. **Wait for all agents**: Task tool blocks until all complete
2. **Process inline results**: Each agent returns summary with completion marker
3. **Update todos**: Mark all parallel todos as `completed` together
4. **Verify no conflicts**: Check file overlap (should be none if dependency analysis correct)
5. **Merge results**: Combine file lists, test results, coverage data
6. **Proceed to next phase**: Integration testing or next parallel group

### Partial Failure Handling

If 1 of 3 parallel agents fails:
1. Note the failure with agent ID
2. Continue waiting for other agents
3. Present all results together
4. Re-invoke only failed agent (with error context)
5. Merge successful results once retry succeeds

---

## Step 5: GPT Expert Escalation (Optional)

> **Trigger**: 2+ failed fix attempts, architecture decisions, security concerns
> **Full guide**: @.claude/rules/delegator/orchestration.md

### When to Escalate

| Situation | Expert |
|-----------|--------|
| 2+ failed fix attempts | Architect (fresh perspective) |
| Architecture decisions | Architect |
| Security concerns | Security Analyst |

### Escalation Pattern

```bash
# Read expert prompt
Read .claude/rules/delegator/prompts/[expert].md

# Call codex-sync.sh
.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"
```

---

## Step 2.6: Update Continuation State After Each Todo (MANDATORY)

> **🚨 CRITICAL**: Update continuation state after EVERY todo completion
> **Purpose**: Maintain accurate progress tracking across agent invocations

### State Update Timing

Update continuation state AFTER each of these events:
- Todo marked as `completed`
- Test run finishes (pass or fail)
- Ralph Loop iteration completes
- Agent reports completion

### State Update Logic

```bash
# Source state management scripts
STATE_WRITE=".pilot/scripts/state_write.sh"
STATE_BACKUP=".pilot/scripts/state_backup.sh"
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"

# Update state after todo completion (with file locking to prevent race conditions)
update_continuation_state() {
    local todo_id="$1"
    local todo_status="$2"  # pending | in_progress | complete
    local iteration="$3"

    # Use flock for atomic read-modify-write (prevents TOCTOU race condition)
    # Lock file: STATE_FILE.lock
    (
        flock -x 9 || { echo "Error: Failed to acquire lock on $STATE_FILE" >&2; exit 1; }

        # Backup existing state (within lock for consistency)
        [ -f "$STATE_FILE" ] && . "$STATE_BACKUP" "$STATE_DIR"

        # Update todo status (within lock for atomicity)
        UPDATED_STATE="$(cat "$STATE_FILE" | jq \
            --arg todo_id "$todo_id" \
            --arg todo_status "$todo_status" \
            --argjson iteration "$iteration" \
            '
            if .todos then
                .todos |= map(
                    if .id == $todo_id then
                        .status = $todo_status |
                        .iteration = $iteration |
                        if $todo_status == "complete" then
                            .completed_at = now | todate
                        else
                            .
                        end
                    else
                        .
                    end
                )
            else
                .
            end |
            .iteration_count += 1 |
            .last_checkpoint = now | todate
            ')"

        # Write updated state (within lock for atomic write)
        echo "$UPDATED_STATE" > "$STATE_FILE"

        echo "✓ Updated continuation state"
        echo "   Todo: $todo_id → $todo_status"
        echo "   Iteration: $iteration"

    ) 9>"$STATE_FILE.lock"
}

# Example: Mark todo as complete after Coder agent finishes
# update_continuation_state "SC-1" "complete" 1

# Example: Mark todo as in_progress when starting work
# update_continuation_state "SC-2" "in_progress" 2
```

### Integration with Micro-Cycle

The state update happens as part of the micro-cycle (Step 6):

1. Edit/Write code
2. Mark test todo as `in_progress` → **UPDATE STATE**
3. Run tests
4. Fix failures or mark complete → **UPDATE STATE**
5. Repeat

### Continuation Prompt Injection

After updating state, check if work should continue:

```bash
# Check if all todos are complete
ALL_COMPLETE="$(cat "$STATE_FILE" | jq -r '.todos[] | select(.status != "complete") | .id')"

if [ -z "$ALL_COMPLETE" ]; then
    echo "✅ All todos complete - work finished"
else
    # Get next incomplete todo
    NEXT_TODO="$(cat "$STATE_FILE" | jq -r '.todos[] | select(.status == "pending") | .id' | head -1)"

    if [ -n "$NEXT_TODO" ]; then
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "⚠️  CONTINUATION CHECK"
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "Incomplete todos detected: $(echo "$ALL_COMPLETE" | wc -l)"
        echo "Next todo: $NEXT_TODO"
        echo ""
        echo "→ CONTINUING with next todo (Sisyphus mode)"
        echo "════════════════════════════════════════════════════════════"
        echo ""

        # Continue with next todo (don't stop)
        # Agent will automatically proceed to next incomplete todo
    fi
fi
```

### Max Iteration Protection

Check iteration count to prevent infinite loops:

```bash
# Check max iterations
MAX_ITERATIONS="$(cat "$STATE_FILE" | jq -r '.max_iterations // 7')"
CURRENT_ITERATION="$(cat "$STATE_FILE" | jq -r '.iteration_count // 0')"

if [ "$CURRENT_ITERATION" -ge "$MAX_ITERATIONS" ]; then
    echo ""
    echo "⚠️  MAX ITERATIONS REACHED ($CURRENT_ITERATION/$MAX_ITERATIONS)"
    echo "→ Manual review required - continuation paused"
    echo ""
    echo "Remaining todos:"
    cat "$STATE_FILE" | jq -r '.todos[] | select(.status != "complete") | "  - \(.id)"'
    echo ""
    echo "Use /00_continue to resume after review"
    echo ""

    # Return success (warning only, not error)
    # Continuation paused but state remains valid
    return 0
fi
```

### User Escape Hatch

**CRITICAL**: Users can override continuation at any time using these commands:

| Command | Purpose | Effect |
|---------|---------|--------|
| `/cancel` | Cancel current work | Stops continuation, preserves state |
| `/stop` | Stop execution | Stops continuation, preserves state |
| `/done` | Mark as complete | Stops continuation, ready for /03_close |

**Agent Behavior**:
- If user types any escape hatch command → **STOP IMMEDIATELY**
- Do not continue with next todo
- Do not update continuation state
- Preserve state for potential resume with `/00_continue`

**Implementation**:
```bash
# Before continuing, check for user escape hatch
# (This check happens before each continuation prompt)
USER_INPUT_CHECK="${USER_INPUT:-}"

if echo "$USER_INPUT_CHECK" | grep -qE "^/(cancel|stop|done)"; then
    echo "→ User invoked escape hatch: $USER_INPUT_CHECK"
    echo "→ Stopping continuation (state preserved)"
    return 0
fi
```

---

## Step 6: Todo Continuation Enforcement

> **Principle**: Don't batch - mark todo as `in_progress` → Complete → Move to next

**Micro-Cycle Compliance**:
1. Edit/Write code
2. Mark test todo as `in_progress` → **UPDATE STATE** (see Step 2.6)
3. Run tests
4. Fix failures or mark complete → **UPDATE STATE** (see Step 2.6)
5. Repeat

**State Updates**: Every todo status change MUST update continuation state (Step 2.6)

---

## Step 7: Update Plan Artifacts

| Action | Method |
|--------|--------|
| Mark SC complete | Update plan checkboxes |
| Update history | Add findings to Review History |
| Save plan | Write updated plan file |

---

## Step 8: Auto-Chain to Documentation

> **Unless** `--no-docs` flag provided

Auto-chain to `/91_document` to update CONTEXT.md files and README.md

---

## Success Criteria

- [ ] All SCs marked complete in plan
- [ ] All tests pass
- [ ] Coverage ≥80% (overall), ≥90% (core)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Plan file updated with completion status

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Worktree Setup**: @.claude/guides/worktree-setup.md
- **GPT Delegation**: @.claude/rules/delegator/orchestration.md

---

## Next Command

- `/91_document` - Update documentation (unless `--no-docs`)
- `/03_close` - Archive plan and cleanup worktree
