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
CONTINUATION_LEVEL=$(echo "$STATE" | jq -r '.continuation_level // "normal"')

echo ""
echo "📋 Continuation State"
echo "   Session: $SESSION_ID"
echo "   Branch: $BRANCH"
echo "   Plan: $PLAN_FILE"
echo "   Iterations: $ITERATION_COUNT/$MAX_ITERATIONS"
echo "   Level: $CONTINUATION_LEVEL"
```

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

---

## Step 4: Extract Todos

```bash
# Get all todos
ALL_TODOS=$(echo "$STATE" | jq -r '.todos[]')

# Count incomplete todos
INCOMPLETE_COUNT=$(echo "$STATE" | jq '[.todos[] | select(.status != "complete")] | length')

echo ""
echo "📊 Todo Status"
echo "   Total: $(echo "$STATE" | jq '.todos | length')"
echo "   Completed: $(echo "$STATE" | jq '[.todos[] | select(.status == "complete")] | length')"
echo "   In Progress: $(echo "$STATE" | jq '[.todos[] | select(.status == "in_progress")] | length')"
echo "   Pending: $(echo "$STATE" | jq '[.todos[] | select(.status == "pending")] | length')"
echo ""

if [ "$INCOMPLETE_COUNT" -eq 0 ]; then
    echo "✅ All todos complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Review implementation: /90_review"
    echo "  2. Update documentation: /91_document"
    echo "  3. Close plan: /03_close"
    echo ""
    
    # Ask if user wants to clean up state
    read -p "Clean up continuation state? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$STATE_FILE"
        echo "✓ State file removed"
    fi
    
    exit 0
fi
```

---

## Step 5: Find Next Todo

```bash
# Find next incomplete todo (in_progress first, then pending)
NEXT_TODO=$(echo "$STATE" | jq -r '.todos[] | select(.status == "in_progress" or .status == "pending") | .id' | head -1)

if [ -z "$NEXT_TODO" ]; then
    echo "❌ No incomplete todos found (this shouldn't happen)"
    exit 1
fi

# Get todo details
NEXT_TODO_STATUS=$(echo "$STATE" | jq -r ".todos[] | select(.id == \"$NEXT_TODO\") | .status")
NEXT_TODO_OWNER=$(echo "$STATE" | jq -r ".todos[] | select(.id == \"$NEXT_TODO\") | .owner // \"coder\"")
NEXT_TODO_ITERATION=$(echo "$STATE" | jq -r ".todos[] | select(.id == \"$NEXT_TODO\") | .iteration // 0")

echo "➡️  Next todo: $NEXT_TODO"
echo "   Status: $NEXT_TODO_STATUS"
echo "   Owner: $NEXT_TODO_OWNER"
echo "   Previous attempts: $NEXT_TODO_ITERATION"
echo ""
```

---

## Step 6: Check Max Iterations

```bash
if [ "$ITERATION_COUNT" -ge "$MAX_ITERATIONS" ]; then
    echo "⚠️ MAX ITERATIONS REACHED"
    echo ""
    echo "   Current: $ITERATION_COUNT"
    echo "   Maximum: $MAX_ITERATIONS"
    echo ""
    echo "Manual review required before continuation."
    echo ""
    echo "Options:"
    echo "  1. Review work and fix issues manually"
    echo "  2. Increase max_iterations in state file"
    echo "  3. Reset iteration count: jq '.iteration_count = 0' .pilot/state/continuation.json"
    echo ""
    exit 1
fi
```

---

## Step 7: Update State and Continue

```bash
# Mark next todo as in_progress
UPDATED_STATE=$(echo "$STATE" | jq \
    --arg todo_id "$NEXT_TODO" \
    '
    if .todos then
        .todos |= map(
            if .id == $todo_id then
                .status = "in_progress"
            else
                .
            end
        )
    else
        .
    end |
    .iteration_count += 1 |
    .last_checkpoint = now | todate
    ')

# Write updated state
echo "$UPDATED_STATE" | "$STATE_WRITE"

echo "✓ State updated"
echo "   Todo marked as in_progress: $NEXT_TODO"
echo "   Iteration: $((ITERATION_COUNT + 1))"
echo ""
```

---

## Step 8: Resume Work

```bash
echo "════════════════════════════════════════════════════════════"
echo "🚀 RESUMING WORK"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Loading plan: $PLAN_FILE"
echo ""

# Read plan file
if [ ! -f "$PLAN_FILE" ]; then
    echo "❌ Plan file not found: $PLAN_FILE"
    echo ""
    echo "The plan file may have been moved or deleted."
    echo "Please update the plan_file path in continuation state."
    exit 1
fi

# Display plan summary
echo "📋 Plan Summary"
echo "   File: $PLAN_FILE"
grep -E "^# " "$PLAN_FILE" | head -5
echo ""

echo "➡️  Continuing with todo: $NEXT_TODO"
echo ""
echo "Agent invocation will be handled by the orchestrator."
echo ""
```

---

## Step 9: Agent Continuation

The continuation system will now invoke the appropriate agent based on the todo owner:

```bash
# Based on NEXT_TODO_OWNER, invoke appropriate agent
case "$NEXT_TODO_OWNER" in
    "coder")
        echo "Invoking Coder agent for: $NEXT_TODO"
        # Agent invocation handled by orchestrator
        ;;
    "tester")
        echo "Invoking Tester agent for: $NEXT_TODO"
        # Agent invocation handled by orchestrator
        ;;
    "validator")
        echo "Invoking Validator agent for: $NEXT_TODO"
        # Agent invocation handled by orchestrator
        ;;
    "documenter")
        echo "Invoking Documenter agent for: $NEXT_TODO"
        # Agent invocation handled by orchestrator
        ;;
    *)
        echo "Invoking Coder agent (default) for: $NEXT_TODO"
        # Agent invocation handled by orchestrator
        ;;
esac
```

---

## Success Criteria

- [ ] Continuation state file exists and is valid
- [ ] Branch matches state (or user confirmed mismatch)
- [ ] Incomplete todos found
- [ ] Next todo identified
- [ ] State updated with in_progress status
- [ ] Agent invoked with next todo

---

## Related Commands

- **/02_execute**: Creates continuation state automatically
- **/03_close**: Verifies all todos complete before cleanup
- **/00_plan**: Creates plans with granular todos

---

## Troubleshooting

### Issue: "No continuation state found"

**Cause**: No previous execution session exists

**Solution**:
```bash
# Start fresh with new plan
/00_plan "task description"
/02_execute
```

### Issue: "Invalid continuation state (corrupted JSON)"

**Cause**: State file corrupted

**Solution**:
```bash
# Recover from backup
cp .pilot/state/continuation.json.backup .pilot/state/continuation.json

# Or start fresh
rm .pilot/state/continuation.json
```

### Issue: "Branch mismatch detected"

**Cause**: State was created on different branch

**Solution**:
```bash
# Switch to state branch
git checkout <state-branch>

# Or clear state and start fresh
rm .pilot/state/continuation.json
```

### Issue: "MAX ITERATIONS REACHED"

**Cause**: Agent has attempted 7 times without completion

**Solution**:
```bash
# Review work manually
# Fix issues
# Reset iteration count
jq '.iteration_count = 0' .pilot/state/continuation.json > /tmp/state.json
mv /tmp/state.json .pilot/state/continuation.json

# Resume
/99_continue
```

---

**Version**: 1.0.0
**Last Updated**: 2026-01-18
