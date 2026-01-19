# Execute Plan - Detailed Reference

> **Purpose**: Extended details for plan execution workflow
> **Main Skill**: @.claude/skills/execute-plan/SKILL.md
> **Last Updated**: 2026-01-19

---

## Continuation State System

### State File Format

```json
{
  "version": "1.0",
  "session_id": "uuid",
  "branch": "main",
  "plan_file": ".pilot/plan/in_progress/plan.md",
  "todos": [
    {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
    {"id": "SC-2", "status": "in_progress", "iteration": 0, "owner": "coder"}
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-18T10:30:00Z",
  "continuation_level": "normal"
}
```

### State Check Logic (Detailed)

The continuation state check happens BEFORE plan detection:

**Worktree Mode State Location**:
- Worktree not created yet: Check after creation
- Worktree created: `{WORKTREE_ROOT}/.pilot/state/continuation.json`

**Standard Mode State Location**:
- `{PROJECT_ROOT}/.pilot/state/continuation.json`

**State Loading Process**:
1. Check if STATE_FILE exists
2. Load JSON with jq
3. Extract: session_id, plan_file, iteration_count, incomplete_todos
4. Display continuation summary
5. Ask user: resume or start fresh
6. If resume: Use plan path from state, load todos, find next incomplete todo
7. If start fresh: Delete state file, proceed to plan detection

### State Creation After Plan Detection

If no state exists, create new state after plan detection:

```bash
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
```

### State Update After Todo Completion

Update continuation state AFTER each todo completion:

```bash
update_continuation_state() {
    local todo_id="$1"
    local todo_status="$2"  # pending | in_progress | complete
    local iteration="$3"

    # Use flock for atomic read-modify-write (prevents TOCTOU race condition)
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
```

### Continuation Check After Todo Completion

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
    echo "Use /99_continue to resume after review"
    echo ""

    # Return success (warning only, not error)
    return 0
fi
```

### User Escape Hatch

Users can override continuation at any time:

| Command | Purpose | Effect |
|---------|---------|--------|
| `/cancel` | Cancel current work | Stops continuation, preserves state |
| `/stop` | Stop execution | Stops continuation, preserves state |
| `/done` | Mark as complete | Stops continuation, ready for /03_close |

**Agent Behavior**:
- If user types any escape hatch command → **STOP IMMEDIATELY**
- Do not continue with next todo
- Do not update continuation state
- Preserve state for potential resume with `/99_continue`

**Implementation**:
```bash
# Before continuing, check for user escape hatch
USER_INPUT_CHECK="${USER_INPUT:-}"

if echo "$USER_INPUT_CHECK" | grep -qE "^/(cancel|stop|done)"; then
    echo "→ User invoked escape hatch: $USER_INPUT_CHECK"
    echo "→ Stopping continuation (state preserved)"
    return 0
fi
```

---

## Worktree Mode Setup

### Worktree Creation Process

Full worktree setup guide: **@.claude/guides/worktree-setup.md**

**Step 1: Parse --wt flag**
```bash
WORKTREE_MODE=false
for arg in "$@"; do
    if [ "$arg" = "--wt" ]; then
        WORKTREE_MODE=true
        break
    fi
done
```

**Step 2: Create worktree** (if --wt flag set)
```bash
if [ "$WORKTREE_MODE" = true ]; then
    echo "🌳 Initializing worktree mode..."

    # Get current branch (we're in main repo)
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    MAIN_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"

    # Create new branch name for worktree
    WT_BRANCH="wt/$(date +%s)"
    echo "Creating worktree branch: $WT_BRANCH"

    # Call worktree creation script
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

    # Store worktree path for persistence across Bash tool calls
    WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"
    echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
    echo "  Branch: $WT_BRANCH" >> "$WORKTREE_PERSIST_FILE"
    echo "  Main Branch: $MAIN_BRANCH" >> "$WORKTREE_PERSIST_FILE"

    # Set environment variables (for this shell session only)
    export PROJECT_ROOT="$WORKTREE_PATH"
    export WORKTREE_ROOT="$WORKTREE_PATH"
    export PILOT_WORKTREE_MODE=1
    export PILOT_WORKTREE_BRANCH="$WT_BRANCH"

    echo "✓ Worktree environment configured"
fi
```

**Step 3: Restore worktree context** (for persistence across Bash calls)
```bash
MAIN_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"

if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    # Worktree mode active - restore paths
    WORKTREE_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    WORKTREE_BRANCH="$(sed -n '2s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    MAIN_BRANCH="$(sed -n '3s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    WORKTREE_ROOT="$WORKTREE_PATH"
    PROJECT_ROOT="$WORKTREE_PATH"
    WORKTREE_MODE="true"
    PILOT_WORKTREE_MODE="1"

    echo "🔄 Worktree context restored"
    echo "  Worktree Path: $WORKTREE_PATH"
    echo "  Worktree Branch: $WORKTREE_BRANCH"
    echo ""
fi
```

**Step 4: Add worktree metadata to plan**
```bash
if [ "${WORKTREE_MODE:-false}" = true ]; then
    # Check if plan already has worktree info
    if ! grep -q "## Worktree Info" "$PLAN_PATH"; then
        # Add worktree metadata section
        TEMP_PLAN="${PLAN_PATH}.tmp"

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
```

---

## Parallel Execution Patterns

### SC Dependency Analysis (Step 2.1)

Before invoking Coder agents, analyze SC dependencies:

**Analysis Process**:
1. Extract all Success Criteria from plan file
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts - same file modified by multiple SCs)
4. Check for dependency keywords ("requires", "depends on", "after", "needs")
5. Group SCs by parallel execution capability

**Dependency Analysis Table Template**:

| SC | Files | Dependencies | Parallel Group | Notes |
|----|-------|--------------|----------------|-------|
| SC-1 | `src/auth/login.ts` | None | Group 1 | Independent |
| SC-2 | `src/auth/logout.ts` | None | Group 1 | Independent |
| SC-3 | `tests/auth.test.ts` | None | Group 1 | Independent |
| SC-4 | `src/auth/middleware.ts` | SC-1 | Group 2 | Requires SC-1 |
| SC-5 | `docs/auth.md` | SC-4 | Group 3 | Requires middleware |

**File Conflict Detection Rules**:
- If 2+ SCs modify the same file → Sequential execution (different groups)
- If SC-2 references SC-1 output → Sequential execution (SC-2 after SC-1)
- If SCs have different files and no references → Parallel execution (same group)

**Parallel Group Assignment**:
- **Group 1**: Fully independent SCs (different files, no dependencies)
- **Group 2**: SCs dependent on Group 1 completion
- **Group 3+**: SCs dependent on previous groups

### Parallel Coder Invocation (Step 2.2)

**For Group 1 (Independent SCs)**: Invoke multiple Coder agents concurrently

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
```

**For Group 2+ (Dependent SCs)**: Sequential execution after previous group completes

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
```

### Process Parallel Coder Results (Step 2.2.1)

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

### Partial Failure Handling (Step 2.2.2)

If 1 of N parallel agents fails:
1. Note the failure with agent ID and SC
2. Continue waiting for other parallel agents
3. Present all results together (successes + failures)
4. Re-invoke **only failed agent** (with error context from previous attempt)
5. Merge successful results once retry succeeds

**Fallback**: If 2+ retries fail, use `AskUserQuestion` for recovery options

### Legacy Single Coder Pattern (Step 2.3)

For simple plans (1-2 SCs, no clear parallelization benefit), use single Coder agent:

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

## Verification Patterns

### Parallel Verification (Step 3.5)

Invoke three verification agents in parallel:

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

### Process Verification Results (Step 3.5.1)

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## GPT Delegation

### Auto-Delegation to GPT Architect (Step 3.2)

**MANDATORY**: When Coder returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect

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

### GPT Expert Escalation (Step 5)

**Trigger**: 2+ failed fix attempts, architecture decisions, security concerns

| Situation | Expert |
|-----------|--------|
| 2+ failed fix attempts | Architect (fresh perspective) |
| Architecture decisions | Architect |
| Security concerns | Security Analyst |

**Escalation Pattern**:
```bash
# Read expert prompt
Read .claude/rules/delegator/prompts/[expert].md

# Call codex-sync.sh
.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"
```

---

## Micro-Cycle Compliance

**Micro-Cycle Compliance** (Step 6):
1. Edit/Write code
2. Mark test todo as `in_progress` → **UPDATE STATE** (see State Update section)
3. Run tests
4. Fix failures or mark complete → **UPDATE STATE** (see State Update section)
5. Repeat

**State Updates**: Every todo status change MUST update continuation state

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Worktree Setup**: @.claude/guides/worktree-setup.md
- **GPT Delegation**: @.claude/rules/delegator/orchestration.md
- **Continuation System**: @.claude/guides/continuation-system.md
