# Continue Work - Detailed Reference

> **Purpose**: Comprehensive continuation system implementation guide
> **Target**: Agents implementing continuation behavior and state management

---

## Overview

The Sisyphus Continuation System ensures agents continue working until completion or manual intervention. Tasks are completed automatically without manual restart, with state persistence across sessions.

**Key Features**:
- **State Persistence**: Continuation state in `.pilot/state/continuation.json`
- **Agent Continuation**: Agents check state before stopping
- **Granular Todos**: Broken into ≤15 minute chunks
- **Automatic Recovery**: Backup recovery for corrupted state
- **Branch Safety**: Mismatch detection and user prompts

---

## State Management Scripts

### Script Overview

**Location**: `.pilot/scripts/`

**state_read.sh**: Read continuation state from JSON file with validation
- `read_state()`: Read and validate continuation.json
- Returns: State content or error message
- Validates JSON structure with `jq`

**state_write.sh**: Write continuation state atomically
- `write_state()`: Write state atomically with backup
- Creates `.backup` file before writing
- Validates JSON before write
- Returns: Success/failure status

**state_backup.sh**: Backup continuation state before modifications
- `backup_state()`: Copy state to `.backup` file
- Preserves original state for recovery
- Returns: Backup file path or error

### Script Sourcing Pattern

```bash
STATE_READ=".pilot/scripts/state_read.sh"
STATE_WRITE=".pilot/scripts/state_write.sh"
STATE_BACKUP=".pilot/scripts/state_backup.sh"

# Source scripts
[ -f "$STATE_READ" ] && . "$STATE_READ" || { echo "Error: state_read.sh not found" >&2; exit 1; }
[ -f "$STATE_WRITE" ] && . "$STATE_WRITE" || { echo "Error: state_write.sh not found" >&2; exit 1; }
[ -f "$STATE_BACKUP" ] && . "$STATE_BACKUP" || { echo "Error: state_backup.sh not found" >&2; exit 1; }
```

**Error Handling**:
- Each script sourced independently
- Exit code 1 if any script missing
- Error messages written to stderr
- Prevents execution with incomplete tooling

---

## State Validation Algorithm

### 1. Read State

```bash
STATE=$(cat "$STATE_FILE")
```

### 2. Validate JSON

```bash
if ! echo "$STATE" | jq empty 2>/dev/null; then
    echo "❌ Invalid continuation state (corrupted JSON)"
    echo ""
    echo "Attempting recovery from backup..."

    BACKUP_FILE="${STATE_FILE}.backup"
    if [ -f "$BACKUP_FILE" ]; then
        STATE=$(cat "$BACKUP_FILE")
        if echo "$STATE" | jq empty 2>/dev/null; then
            echo "✓ Recovered from backup"
            echo "$STATE" > "$STATE_FILE"
        else
            echo "❌ Backup also corrupted"
            exit 1
        fi
    else
        echo "❌ No backup available"
        exit 1
    fi
fi
```

### 3. Extract State Variables

```bash
SESSION_ID=$(echo "$STATE" | jq -r '.session_id // empty')
BRANCH=$(echo "$STATE" | jq -r '.branch // empty')
PLAN_FILE=$(echo "$STATE" | jq -r '.plan_file // empty')
ITERATION_COUNT=$(echo "$STATE" | jq -r '.iteration_count // 0')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 7')
CONTINUATION_LEVEL=$(echo "$STATE" | jq -r '.continuation_level // "normal"')
```

**Variable Descriptions**:

| Variable | Type | Purpose | Default |
|----------|------|---------|---------|
| `SESSION_ID` | string | Unique session identifier | empty |
| `BRANCH` | string | Git branch name | empty |
| `PLAN_FILE` | string | Path to plan file | empty |
| `ITERATION_COUNT` | number | Current iteration count | 0 |
| `MAX_ITERATIONS` | number | Maximum iterations allowed | 7 |
| `CONTINUATION_LEVEL` | string | Aggressiveness level | "normal" |

### 4. Display State

```
📋 Continuation State
   Session: abc123-def456-ghi789
   Branch: main
   Plan: .pilot/plan/in_progress/fix_20260118_235333.md
   Iterations: 3/7
   Level: normal
```

---

## JSON Schema

**State File Format** (`continuation.json`):

```json
{
  "version": "1.0",
  "session_id": "uuid-v4",
  "branch": "main",
  "plan_file": ".pilot/plan/in_progress/plan.md",
  "todos": [
    {
      "id": "SC-1",
      "status": "complete",
      "iteration": 1,
      "owner": "coder"
    },
    {
      "id": "SC-2",
      "status": "in_progress",
      "iteration": 0,
      "owner": "coder"
    }
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-18T10:30:00Z",
  "continuation_level": "normal"
}
```

**Validation Rules**:
- `version`: Must be "1.0"
- `session_id`: Valid UUID v4 format
- `branch`: Non-empty string
- `plan_file`: Existing file path
- `todos`: Array of todo objects
- `iteration_count`: Integer ≥0
- `max_iterations`: Integer ≥1
- `last_checkpoint`: ISO 8601 timestamp
- `continuation_level`: One of: "aggressive", "normal", "polite"

---

## Branch Mismatch Detection

### Current Branch Detection

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
```

### Comparison Logic

```bash
if [ "$BRANCH" != "$CURRENT_BRANCH" ]; then
    echo ""
    echo "⚠️ Branch mismatch detected"
    echo "   State branch: $BRANCH"
    echo "   Current branch: $CURRENT_BRANCH"
    echo ""
    echo "Options:"
    echo "  1. Switch to state branch: git checkout $BRANCH"
    echo "  2. Clear state and start fresh: rm .pilot/state/continuation.json"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 1
    fi
fi
```

### Branch Mismatch Scenarios

**Scenario 1: Different Branch, User Continues**
- State branch: `feature/auth`
- Current branch: `main`
- User choice: `y`
- Result: Continues on main branch (state detached from context)

**Scenario 2: Different Branch, User Switches**
- State branch: `feature/auth`
- Current branch: `main`
- User action: `git checkout feature/auth`
- Result: Continues on feature/auth branch

**Scenario 3: Different Branch, User Clears State**
- State branch: `feature/auth`
- Current branch: `main`
- User action: `rm .pilot/state/continuation.json`
- Result: Fresh start on main branch

**When to Allow Mismatch**:
- State is from completed worktree (now deleted)
- Testing continuation across branches
- Manual intervention expected

**When to Reject Mismatch**:
- Active worktree still exists
- Risk of data loss
- Conflicting concurrent work

---

## Todo Extraction

### jq Query Patterns

**Get All Todos**:
```bash
ALL_TODOS=$(echo "$STATE" | jq -r '.todos[]')
```

**Count Incomplete Todos**:
```bash
INCOMPLETE_COUNT=$(echo "$STATE" | jq '[.todos[] | select(.status != "complete")] | length')
```

**Count by Status**:
```bash
COMPLETED=$(echo "$STATE" | jq '[.todos[] | select(.status == "complete")] | length')
IN_PROGRESS=$(echo "$STATE" | jq '[.todos[] | select(.status == "in_progress")] | length')
PENDING=$(echo "$STATE" | jq '[.todos[] | select(.status == "pending")] | length')
TOTAL=$(echo "$STATE" | jq '.todos | length')
```

**Todo Status Display**:
```
📊 Todo Status
   Total: 10
   Completed: 7
   In Progress: 1
   Pending: 2
```

### Extract Specific Todo

```bash
# Get first incomplete todo
NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status != "complete") | .id' | head -1)

# Get all incomplete todo IDs
INCOMPLETE_IDS=$(echo "$STATE" | jq -r '.todos[] | select(.status != "complete") | .id')

# Get todo by ID
TODO_1=$(echo "$STATE" | jq -r '.todos[] | select(.id == "SC-1")')

# Get todos by owner
CODER_TODOS=$(echo "$STATE" | jq -r '.todos[] | select(.owner == "coder")')
```

### Find Next In Progress Todo

```bash
IN_PROGRESS_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "in_progress") | .id')

if [ -n "$IN_PROGRESS_TODO" ]; then
    NEXT_TODO="$IN_PROGRESS_TODO"
else
    NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "pending") | .id' | head -1)
fi
```

### Todo Status Values

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `pending` | Not started | Extract and start |
| `in_progress` | Currently active | Continue execution |
| `complete` | Finished | Skip |

### Edge Cases

**No Incomplete Todos**:
```bash
if [ "$INCOMPLETE_COUNT" -eq 0 ]; then
    echo "✅ All todos complete!"
    echo ""
    echo "→ No continuation needed"
    echo "→ State cleaned up automatically"
    exit 0
fi
```

**All Todos Pending**:
```bash
if [ "$IN_PROGRESS" -eq 0 ]; then
    NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "pending") | .id' | head -1)
    echo "→ Starting with $NEXT_TODO"
fi
```

---

## State Update Patterns

### 1. Increment Iteration Count

```bash
NEW_ITERATION=$((ITERATION_COUNT + 1))
```

### 2. Update Todo Status

```bash
# Mark SC-1 as complete
UPDATED_STATE=$(echo "$STATE" | jq --argjson iteration "$NEW_ITERATION" '
  .iteration_count = $iteration |
  .todos[] |= map(if .id == "SC-1" then .status = "complete" else . end)
')

echo "$UPDATED_STATE" > "$STATE_FILE"
```

### 3. Update Last Checkpoint

```bash
UPDATED_STATE=$(echo "$STATE" | jq '
  .last_checkpoint = (now | todate)
')

echo "$UPDATED_STATE" > "$STATE_FILE"
```

### 4. Atomic Update Pattern

```bash
# Create backup first
backup_state

# Update state
UPDATED_STATE=$(jq '...' "$STATE_FILE")

# Verify update
if ! jq empty "$STATE_FILE" 2>/dev/null; then
    echo "❌ State update failed, restoring backup"
    restore_state
    exit 1
fi

# Remove backup on success
rm -f "${STATE_FILE}.backup"
```

### Update Scenarios

**Scenario 1: Complete SC-2, Start SC-3**
```bash
UPDATED_STATE=$(echo "$STATE" | jq '
  .todos[] |= map(if .id == "SC-2" then .status = "complete" else .end) |
  .todos[] |= map(if .id == "SC-3" then .status = "in_progress" else .end) |
  .iteration_count += 1
')
```

**Scenario 2: Update Iteration Only**
```bash
UPDATED_STATE=$(echo "$STATE" | jq '
  .iteration_count += 1 |
  .last_checkpoint = (now | todate)
')
```

**Scenario 3: Mark All Complete**
```bash
UPDATED_STATE=$(echo "$STATE" | jq '
  .todos[] |= map(.status = "complete") |
  .last_checkpoint = (now | todate)
')
```

---

## Continuation Levels

### Level: Aggressive

**Behavior**:
- Maximum continuation, minimal pauses
- Auto-proceed to next todo without confirmation
- Ideal for: Automated workflows, batch processing

**Use Case**:
```bash
export CONTINUATION_LEVEL="aggressive"
/continue
```

**Tradeoffs**:
- ✅ Fast completion
- ❌ Less user control
- ❌ Higher risk of cascading errors

### Level: Normal (Default)

**Behavior**:
- Balanced continuation
- Brief status display between todos
- Proceeds automatically with visibility

**Use Case**:
```bash
export CONTINUATION_LEVEL="normal"
/continue
```

**Tradeoffs**:
- ✅ Balance of speed and control
- ✅ Good visibility into progress
- ✅ Standard for most workflows

### Level: Polite

**Behavior**:
- More frequent checkpoints
- User confirmation before major changes
- Progress updates at each step

**Use Case**:
```bash
export CONTINUATION_LEVEL="polite"
/continue
```

**Tradeoffs**:
- ✅ Maximum user control
- ✅ Clear progress tracking
- ❌ Slower completion
- ❌ More manual intervention

---

## Error Recovery

### State File Not Found

**Symptom**:
```
❌ No continuation state found
```

**Causes**:
1. No plan has been executed yet
2. State file was deleted
3. Work was completed and state cleaned up

**Solutions**:
```bash
# Start new work
/00_plan "implement feature"
/02_execute

# Or recreate state manually (advanced)
echo '{...}' > .pilot/state/continuation.json
```

### Invalid State JSON

**Symptom**:
```
❌ Invalid continuation state (corrupted JSON)
```

**Recovery Attempt**:
```
Attempting recovery from backup...
✓ Recovered from backup
```

**If Backup Fails**:
```
❌ Backup also corrupted
```

**Solution**:
```bash
# Manual state recreation required
# See documentation for state file format
```

### Branch Mismatch

**Symptom**:
```
⚠️ Branch mismatch detected
   State branch: feature/auth
   Current branch: main
```

**Options**:
1. Switch to state branch: `git checkout feature/auth`
2. Clear state and start fresh: `rm .pilot/state/continuation.json`

### Max Iterations Reached

**Symptom**:
```
<CODER_BLOCKED>
```

**Meaning**:
- 7 Ralph Loop iterations completed
- Work may be incomplete
- Manual intervention required

**Solutions**:
```bash
# Resume with manual review
/continue

# Or close manually
/03_close
```

---

## Testing Continuation

### Manual Testing

**Test Basic Continuation**:
```bash
# 1. Start work
/02_execute  # Creates continuation state

# 2. Interrupt manually (Ctrl+C)

# 3. Resume
/continue  # Should continue from checkpoint
```

**Test Branch Recovery**:
```bash
# 1. Create worktree
git worktree add feature/test

# 2. Execute plan
/02_execute

# 3. Switch to main
git checkout main

# 4. Resume (should detect branch mismatch)
/continue  # Will prompt for action
```

**Test State Recovery**:
```bash
# 1. Corrupt state file
echo '{invalid json}' > .pilot/state/continuation.json

# 2. Run continuation (should recover from backup)
/continue  # Should use backup
```

### Verification Checklist

After running `/continue`:
- [ ] State file loaded successfully
- [ ] Branch matched or user confirmed mismatch
- [ ] Next incomplete todo identified
- [ ] Coder agent invoked successfully
- [ ] State updated after agent completion
- [ ] All todos complete OR max iterations reached
- [ ] User informed of completion status

---

## Best Practices

### When to Use /continue

**Good Scenarios**:
- After interrupting long-running `/02_execute`
- After system crash or timeout
- When resuming work next day
- After manual intervention during execution

**Poor Scenarios** (use other commands):
- Starting new work → Use `/00_plan`
- Manual plan closure → Use `/03_close`
- Code review → Use `/review`

### State Management Tips

**Backup Regularly**:
- State automatically backed up before updates
- Keep backup in sync with main state
- Test recovery procedures

**Monitor Iterations**:
- Check iteration count before resuming
- 7 iterations is safety limit
- Manual review may be needed

**Branch Awareness**:
- Always note which branch state is for
- Use worktrees for parallel work
- Clean up state after branch deletion

---

## Integration with Other Commands

### /02_execute Integration

**State Creation**:
- `/02_execute` creates state on first execution
- Updates state on each Ralph Loop iteration
- Detects existing state on resume

**State Detection**:
```bash
# In /02_execute
if [ -f "$STATE_FILE" ]; then
    echo "🔄 Resuming from iteration $ITERATION_COUNT"
else
    echo "🆕 Creating new continuation state"
fi
```

### /03_close Integration

**State Cleanup**:
- `/03_close` verifies all todos complete
- Deletes state file after successful commit
- Removes backup as well

**Verification**:
```bash
# In /03_close
if [ -f "$STATE_FILE" ]; then
    echo "⚠️  State file still exists"
    echo "→ Work may be incomplete"
fi
```

### /00_plan Integration

**Fresh Start**:
- `/00_plan` ensures no stale state
- Warns if continuation state exists
- Offers to clear before starting

---

## Related Documentation

**Internal**:
- @.claude/guides/continuation-system.md - Sisyphus system architecture
- @.claude/guides/todo-granularity.md - Granular todo breakdown
- @.claude/skills/execute-plan/SKILL.md - Plan execution workflow
- @.claude/commands/continue.md - Continue command reference

**External**:
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

---

**Reference Version**: claude-pilot 4.2.0
**Last Updated**: 2026-01-19
