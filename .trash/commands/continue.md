---
name: 99_continue
description: Resume work from continuation state (Sisyphus system)
---

# /continue

> **Purpose**: Resume work from continuation state when agents need to continue incomplete tasks
> **Usage**: `/continue` - Automatically loads state and continues with next incomplete todo

---

## Quick Start

```bash
/continue
```

The command will:
1. Check `.pilot/state/continuation.json` exists
2. Load state (todos, iteration count, plan file)
3. Resume with next incomplete todo
4. Update checkpoint on progress

---

## Step 1: Check State File

```bash
STATE_FILE=".pilot/state/continuation.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "❌ No continuation state found"
    echo "   Start with /02_execute to create continuation state"
    exit 1
fi

echo "✓ Found continuation state: $STATE_FILE"
```

---

## Step 2: Load State

```bash
# Load state
CONTINUATION_STATE="$(cat "$STATE_FILE")"
PLAN_PATH="$(echo "$CONTINUATION_STATE" | jq -r '.plan_file // empty')"
ITERATION_COUNT="$(echo "$CONTINUATION_STATE" | jq -r '.iteration_count // 0')"
MAX_ITERATIONS="$(echo "$CONTINUATION_STATE" | jq -r '.max_iterations // 7')"

# Find next incomplete todo
NEXT_TODO="$(echo "$CONTINUATION_STATE" | jq -r '.todos[] | select(.status == "pending" or .status == "in_progress") | .id' | head -1)"

if [ -z "$NEXT_TODO" ]; then
    echo "✓ All todos complete!"
    echo "   Run /03_close to finalize the plan"
    exit 0
fi

echo "📋 Resuming: $NEXT_TODO"
echo "   Iteration: $ITERATION_COUNT/$MAX_ITERATIONS"
echo "   Plan: $PLAN_PATH"
```

---

## Step 3: Update State & Continue

```bash
# Mark todo as in_progress
jq --arg todo_id "$NEXT_TODO" \
    '.todos |= map(if .id == $todo_id then .status = "in_progress" else . end)' \
    "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
```

**Continue with the task**: Invoke agent based on `NEXT_TODO` (coder/tester/code-reviewer)

---

## State Update Pattern

After completing work, update state:

```bash
# Mark todo as completed
jq --arg todo_id "$NEXT_TODO" \
    '.todos |= map(if .id == $todo_id then .status = "completed" else . end) | \
     .iteration_count += 1' \
    "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
```

---

## Related Skills

**managing-continuation**: Full continuation system | **ralph-loop**: Autonomous iteration | **spec-driven-workflow**: Todo state management

See @.claude/skills/managing-continuation/SKILL.md for complete documentation
