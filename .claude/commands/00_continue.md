---
description: Resume work from continuation state
argument-hint: "No arguments - reads from continuation state"
allowed-tools: Read, Bash, TodoWrite, AskUserQuestion
---

# /00_continue

_Resume work from continuation state file._

## Purpose

Resume work from a previous session that was interrupted or stopped. This command reads the continuation state, validates it, and continues from the last checkpoint.

> **⚠️ CRITICAL**: /00_continue can ONLY be used if continuation state exists from a previous session

---

## Step 1: Check Continuation State

**Action**: Verify continuation state file exists

```bash
# Check if continuation state exists
STATE_FILE=".pilot/state/continuation.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "Error: No continuation state found"
    echo "To start a new session, use /00_plan instead"
    exit 1
fi
```

**Validation**:
- File must exist at `.pilot/state/continuation.json`
- If missing, show error and suggest `/00_plan`

---

## Step 2: Load State

**Action**: Read continuation state using state_read.sh script

```bash
# Load continuation state
STATE_DIR=".pilot/state"
SCRIPT_DIR=".pilot/scripts"

STATE_JSON=$(bash "$SCRIPT_DIR/state_read.sh" --state-dir "$STATE_DIR")

# Parse state fields
SESSION_ID=$(echo "$STATE_JSON" | jq -r '.session_id')
BRANCH=$(echo "$STATE_JSON" | jq -r '.branch')
PLAN_FILE=$(echo "$STATE_JSON" | jq -r '.plan_file')
TODOS=$(echo "$STATE_JSON" | jq -r '.todos')
ITERATION_COUNT=$(echo "$STATE_JSON" | jq -r '.iteration_count')
MAX_ITERATIONS=$(echo "$STATE_JSON" | jq -r '.max_iterations')
LAST_CHECKPOINT=$(echo "$STATE_JSON" | jq -r '.last_checkpoint')
CONTINUATION_LEVEL=$(echo "$STATE_JSON" | jq -r '.continuation_level')
```

**Output**: Display loaded state to user

```
Continuation State Loaded:
- Session: {SESSION_ID}
- Branch: {BRANCH}
- Plan: {PLAN_FILE}
- Iteration: {ITERATION_COUNT}/{MAX_ITERATIONS}
- Last Checkpoint: {LAST_CHECKPOINT}
```

---

## Step 3: Validate State

**Action**: Validate continuation state is still valid

### 3.1: Verify Branch Matches

```bash
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo "Warning: Continuation state is from branch '$BRANCH'"
    echo "Current branch: '$CURRENT_BRANCH'"
    echo "Do you want to continue anyway? (y/n)"

    # Ask user for confirmation
    # Use AskUserQuestion tool if available
fi
```

### 3.2: Verify Plan File Exists

```bash
if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found: $PLAN_FILE"
    echo "The plan file may have been moved or deleted"
    exit 1
fi
```

### 3.3: Check Iteration Limit

```bash
if [ "$ITERATION_COUNT" -ge "$MAX_ITERATIONS" ]; then
    echo "Warning: Maximum iterations reached ($ITERATION_COUNT/$MAX_ITERATIONS)"
    echo "Consider reviewing progress and starting a new session"
fi
```

---

## Step 4: Resume Work

**Action**: Find next incomplete todo and mark as in_progress

### 4.1: Display Current Todos

```bash
# Parse todos from state
echo "Current Todos:"
echo "$TODOS" | jq -r '.[] | "\(.id): \(.status) (owner: \(.owner))"'
```

### 4.2: Find Next Incomplete Todo

```bash
# Find first todo with status != "complete"
NEXT_TODO=$(echo "$TODOS" | jq -r '[.[] | select(.status != "complete")][0]')

if [ -z "$NEXT_TODO" ] || [ "$NEXT_TODO" = "null" ]; then
    echo "All todos are complete!"
    echo "Use /03_close to finalize the session"
    exit 0
fi

NEXT_TODO_ID=$(echo "$NEXT_TODO" | jq -r '.id')
NEXT_TODO_OWNER=$(echo "$NEXT_TODO" | jq -r '.owner')
```

### 4.3: Mark Next Todo as in_progress

```bash
# Update todo status to in_progress
UPDATED_TODOS=$(echo "$TODOS" | jq "(.[] | select(.id == \"$NEXT_TODO_ID\")).status |= \"in_progress\"")

# Write updated state
NEW_ITERATION=$((ITERATION_COUNT + 1))

bash "$SCRIPT_DIR/state_write.sh" \
    --plan-file "$PLAN_FILE" \
    --todos "$UPDATED_TODOS" \
    --iteration "$NEW_ITERATION" \
    --state-dir "$STATE_DIR"
```

---

## Step 5: Continue Execution

**Action**: Invoke appropriate agent based on todo owner

### 5.1: Read Plan File

```bash
# Read the plan to understand context
PLAN_CONTENT=$(cat "$PLAN_FILE")
```

### 5.2: Determine Agent Type

Based on `NEXT_TODO_OWNER`, invoke the appropriate agent:

| Owner | Agent | Purpose |
|-------|-------|---------|
| `coder` | Coder Agent | Implement features |
| `tester` | Tester Agent | Write/run tests |
| `validator` | Validator Agent | Verify quality gates |
| `documenter` | Documenter Agent | Update documentation |

### 5.3: Display Continuation Instructions

```
Resuming work on: {NEXT_TODO_ID}
Owner: {NEXT_TODO_OWNER}
Iteration: {NEW_ITERATION}/{MAX_ITERATIONS}

Continuation Checklist:
- [ ] Complete current todo
- [ ] Update checkpoint on progress
- [ ] Continue until all todos complete
- [ ] Use /03_close when done

Press Enter to continue or /cancel to abort
```

### 5.4: Update Checkpoint on Progress

After each significant progress step, update the continuation state:

```bash
# Update checkpoint timestamp
bash "$SCRIPT_DIR/state_write.sh" \
    --plan-file "$PLAN_FILE" \
    --todos "$UPDATED_TODOS" \
    --iteration "$NEW_ITERATION" \
    --state-dir "$STATE_DIR"
```

---

## Escape Hatch

**If user types `/cancel` or `/stop`**:
- Stop immediately
- Save current state
- Do not delete continuation file

**If user types `/done`**:
- Mark current todo as complete
- Update state
- Exit gracefully

---

## Integration Points

**Uses**:
- `.pilot/scripts/state_read.sh` - Read continuation state
- `.pilot/scripts/state_write.sh` - Write continuation state
- `.pilot/state/continuation.json` - State file location

**Related Commands**:
- `/00_plan` - Start new session
- `/02_execute` - Execute with continuation tracking
- `/03_close` - Finalize session (deletes state)

---

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| `continuation.json not found` | No previous session | Suggest `/00_plan` |
| `Plan file not found` | Plan moved/deleted | Error and exit |
| `Branch mismatch` | Switched git branch | Warning + confirmation |
| `Max iterations reached` | Too many loops | Warning + suggest review |
| `All todos complete` | Work finished | Suggest `/03_close` |

---

## Example Usage

```bash
# User runs /00_continue after interruption

Continuation State Loaded:
- Session: 103AB02E-E21F-4901-A4B9-DA2B55D29156
- Branch: main
- Plan: .pilot/plan/in_progress/20250118_sisyphus_continuation_system.md
- Iteration: 1/7
- Last Checkpoint: 2026-01-18T06:16:55Z

Current Todos:
- SC-1: in_progress (owner: coder)
- SC-2: pending (owner: tester)
- SC-3: pending (owner: validator)

Resuming work on: SC-1
Owner: coder
Iteration: 2/7

# Agent continues implementing SC-1...
```

---

**Version**: 1.0
**Related**: [Continuation System Guide](../guides/continuation-system.md)
