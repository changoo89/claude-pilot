---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern. Single source of truth: plan file drives work._

---

## Step 1: Plan Detection

```bash
# Find plan in pending/ or in_progress/
PLAN_PATH="$(find .pilot/plan/pending .pilot/plan/in_progress -name "*.md" -type f 2>/dev/null | sort | head -1)"

if [ -z "$PLAN_PATH" ]; then
    echo "❌ No plan found"
    echo "   Create plan first: /00_plan \"describe your task\""
    exit 1
fi

# Move from pending/ to in_progress/
if echo "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH=".pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p .pilot/plan/in_progress
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

echo "✓ Plan: $PLAN_PATH"
```

---

## Step 2: Extract Success Criteria

```bash
# Extract all SCs from plan
SC_LIST="$(grep -E "^- \[ \] \*\*SC-" "$PLAN_PATH" | sed 's/.*\*\*SC-\([0-9]*\)\*\*.*/SC-\1/')"

if [ -z "$SC_LIST" ]; then
    echo "❌ No Success Criteria found in plan"
    exit 1
fi

SC_COUNT="$(echo "$SC_LIST" | wc -l | tr -d ' ')"
echo "✓ Found $SC_COUNT Success Criteria"
```

---

## Step 3: Create Continuation State

```bash
STATE_FILE=".pilot/state/continuation.json"
mkdir -p .pilot/state

# Build todos array
TODOS_JSON="$(echo "$SC_LIST" | while read sc; do
    echo "{\"id\": \"$sc\", \"status\": \"pending\", \"iteration\": 0}"
done | jq -s '.')"

# Create state file
cat > "$STATE_FILE" << EOF
{
  "plan_file": "$PLAN_PATH",
  "iteration_count": 0,
  "max_iterations": 7,
  "todos": $TODOS_JSON
}
EOF

echo "✓ Continuation state created"
```

---

## Step 4: Execute with Ralph Loop

```markdown
Task: subagent_type: coder, prompt: Execute $PLAN_PATH using tdd, ralph-loop, managing-continuation
```

**Quality Gates**: Tests pass, Coverage ≥80%, Type-check clean, Lint clean

**State Update**: `jq '.todos |= map(if .id == $SC then .status = "completed" else . end)' "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"`

---

## Related Skills

ralph-loop | tdd | managing-continuation | parallel-subagents | spec-driven-workflow

---

**⚠️ CRITICAL**: Plan stays in `.pilot/plan/in_progress/`. Only `/03_close` can move to done.
