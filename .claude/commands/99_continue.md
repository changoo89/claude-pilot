---
name: 99_continue
description: Resume work from continuation state (Sisyphus system)
---

# /99_continue

> **Purpose**: Resume work from continuation state when agents need to continue incomplete tasks
> **Usage**: `/99_continue` - Automatically loads state and continues with next incomplete todo

---

## Quick Start

```bash
/99_continue
```

The command will:
1. Check `.pilot/state/continuation.json` exists
2. Load state (todos, iteration count, plan file)
3. Resume with next incomplete todo
4. Update checkpoint on progress

---

## Step 0: Source State Management Scripts

```bash
STATE_READ=".pilot/scripts/state_read.sh"
STATE_WRITE=".pilot/scripts/state_write.sh"
STATE_BACKUP=".pilot/scripts/state_backup.sh"

# Source scripts
[ -f "$STATE_READ" ] && . "$STATE_READ" || { echo "Error: state_read.sh not found" >&2; exit 1; }
[ -f "$STATE_WRITE" ] && . "$STATE_WRITE" || { echo "Error: state_write.sh not found" >&2; exit 1; }
[ -f "$STATE_BACKUP" ] && . "$STATE_BACKUP" || { echo "Error: state_backup.sh not found" >&2; exit 1; }
```

**See**: @.claude/skills/continue-work/REFERENCE.md for script details

---

## Step 1: Check Continuation State Exists

```bash
STATE_FILE=".pilot/state/continuation.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "❌ No continuation state found"
    echo ""
    echo "Possible reasons:"
    echo "  - No plan has been executed yet"
    echo "  - State file was deleted"
    echo "  - Work was completed and state cleaned up"
    echo ""
    echo "To start new work:"
    echo "  1. Run /00_plan to create a plan"
    echo "  2. Run /02_execute to start execution"
    echo ""
    exit 1
fi

echo "✓ Continuation state found: $STATE_FILE"
```

---

## Step 2: Load and Validate State

```bash
# Read state
STATE=$(cat "$STATE_FILE")

# Validate JSON
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

# Extract state variables
SESSION_ID=$(echo "$STATE" | jq -r '.session_id // empty')
BRANCH=$(echo "$STATE" | jq -r '.branch // empty')
PLAN_FILE=$(echo "$STATE" | jq -r '.plan_file // empty')
ITERATION_COUNT=$(echo "$STATE" | jq -r '.iteration_count // 0')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 7')
CONTINUATION_LEVEL=$(echo "$STATE" | jq -r '.continuation_level // "normal')

echo ""
echo "📋 Continuation State"
echo "   Session: $SESSION_ID"
echo "   Branch: $BRANCH"
echo "   Plan: $PLAN_FILE"
echo "   Iterations: $ITERATION_COUNT/$MAX_ITERATIONS"
echo "   Level: $CONTINUATION_LEVEL"
```

**See**: @.claude/skills/continue-work/REFERENCE.md for state format and recovery

---

## Step 3: Check Branch Match

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")

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

**See**: @.claude/skills/continue-work/REFERENCE.md for branch mismatch handling

---

## Step 4: Extract Next Todo

```bash
# Get next incomplete todo
IN_PROGRESS_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "in_progress") | .id')

if [ -n "$IN_PROGRESS_TODO" ]; then
    NEXT_TODO="$IN_PROGRESS_TODO"
else
    NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "pending") | .id' | head -1)
fi

echo "→ Continuing with todo: $NEXT_TODO"
```

---

## Step 5: Execute Continuation

> **Purpose**: Execute next todo using Coder agent

**MANDATORY ACTION**: Invoke Coder agent with continuation context

**See**: @.claude/skills/continue-work/REFERENCE.md for agent invocation details

---

## Step 6: Update State

After Coder agent completes:

```bash
NEW_ITERATION=$((ITERATION_COUNT + 1))

# Update iteration count
UPDATED_STATE=$(echo "$STATE" | jq --argjson iteration "$NEW_ITERATION" '
  .iteration_count = $iteration |
  .last_checkpoint = (now | todate)
')

echo "$UPDATED_STATE" > "$STATE_FILE"
echo "✓ State updated: Iteration $NEW_ITERATION/$MAX_ITERATIONS"
```

**See**: @.claude/skills/continue-work/REFERENCE.md for update patterns

---

## Step 7: Verify Completion

After Coder agent completes:

```bash
# Check if all todos complete
INCOMPLETE_COUNT=$(echo "$STATE" | jq '[.todos[] | select(.status != "complete")] | length')

if [ "$INCOMPLETE_COUNT" -eq 0 ]; then
    echo ""
    echo "✅ All todos complete!"
    echo ""
    echo "→ State cleaned up automatically"
    rm -f "$STATE_FILE"
    exit 0
fi

echo "→ $INCOMPLETE_COUNT todos remaining"
echo "→ Use /99_continue to resume"
```

---

## Continuation Levels

**Configuration**:
```bash
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite
```

| Level | Behavior | Use For |
|-------|----------|---------|
| `aggressive` | Maximum continuation, minimal pauses | Automated workflows |
| `normal` (default) | Balanced continuation with visibility | Standard workflows |
| `polite` | Frequent checkpoints, user control | Manual review needed |

**See**: @.claude/skills/continue-work/REFERENCE.md for level details

---

## Error Handling

| Error | Solution |
|-------|----------|
| State not found | Run `/00_plan` then `/02_execute` |
| Invalid JSON | Automatic recovery from backup |
| Branch mismatch | Switch branch or clear state |
| Max iterations | Manual review required, then resume |

**See**: @.claude/skills/continue-work/REFERENCE.md for error recovery procedures

---

## Related Commands

- **/02_execute** - Creates continuation state, manages iterations
- **/03_close** - Verifies completion, cleans up state
- **/00_plan** - Start new work (creates fresh state)

**Detailed Reference**: @.claude/skills/continue-work/REFERENCE.md
