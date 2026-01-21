---
name: managing-continuation
description: Use when executing long-running plans across sessions. Automatically persists work state and resumes without manual restart.
---

# SKILL: Managing Continuation (Sisyphus System)

> **Purpose**: Agents persist work across sessions until todos complete. "The boulder never stops" - automatic continuation.
> **Target**: Coder, Tester, Validator, Documenter agents executing multi-step plans

---

## Quick Start

### When to Use This Skill
- Executing plans with 10+ todos
- Work that spans multiple sessions
- Autonomous completion without manual restart
- Ralph Loop iterations (max 7)

### Quick Reference
```bash
# State file location
STATE_FILE=".pilot/state/continuation.json"

# Create state
cat > "$STATE_FILE" << EOF
{
  "plan_file": ".pilot/plan/in_progress/plan.md",
  "iteration_count": 0,
  "max_iterations": 7,
  "todos": [
    {"id": "SC-1", "status": "pending", "iteration": 0},
    {"id": "SC-2", "status": "pending", "iteration": 0}
  ]
}
EOF

# Update state after completing todo
update_state() {
  local todo_id="$1" todo_status="$2" iteration="$3"
  jq --arg id "$todo_id" --arg status "$todo_status" --argjson iter "$iteration" \
    '.todos |= map(if .id == $id then .status = $status | .iteration = $iter else . end) | .iteration_count += 1' \
    "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Check if should continue
should_continue() {
  local incomplete=$(jq '[.todos[] | select(.status == "pending" or .status == "in_progress")] | length' "$STATE_FILE")
  local iterations=$(jq '.iteration_count' "$STATE_FILE")
  local max=$(jq '.max_iterations' "$STATE_FILE")
  [ "$incomplete" -gt 0 ] && [ "$iterations" -lt "$max" ]
}
```

---

## Core Concepts

### State File Structure

**Location**: `.pilot/state/continuation.json`

**Required Fields**:
- `plan_file`: Path to active plan (in_progress/)
- `iteration_count`: Current iteration number (starts at 0)
- `max_iterations`: Maximum iterations (default: 7)
- `todos`: Array of todo items
  - `id`: Success Criteria ID (SC-1, SC-2, ...)
  - `status`: pending | in_progress | completed
  - `iteration`: Last iteration this todo was worked on

**Example**:
```json
{
  "plan_file": ".pilot/plan/in_progress/20260120_skill_refactor.md",
  "iteration_count": 2,
  "max_iterations": 7,
  "todos": [
    {"id": "SC-1", "status": "completed", "iteration": 1},
    {"id": "SC-2", "status": "in_progress", "iteration": 2},
    {"id": "SC-3", "status": "pending", "iteration": 0}
  ]
}
```

### Pending → Progress → Done Flow

**State Transitions**:

1. **pending** → Todo not started yet
2. **in_progress** → Currently working on this todo
3. **completed** → Todo verified complete

**Update Pattern**:
```bash
# Mark in_progress (start working)
update_state "SC-1" "in_progress" 1

# Mark completed (verified)
update_state "SC-1" "completed" 1

# Get next pending todo
next_todo=$(jq -r '.todos[] | select(.status == "pending") | .id' "$STATE_FILE" | head -1)
```

### Continuation Levels

**Configuration**:
```bash
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite
```

- **aggressive**: Maximum continuation, minimal pauses (for autonomous execution)
- **normal** (default): Balanced continuation (checkpoints every 2-3 todos)
- **polite**: Frequent checkpoints, user control (stop after each todo)

### Agent Continuation Pattern

**Before stopping, agent MUST**:

1. Read state file: `cat .pilot/state/continuation.json`
2. Check for incomplete todos: `jq '.todos[] | select(.status != "completed")'`
3. Check iteration count: `jq '.iteration_count < .max_iterations'`
4. **If both true**: Update state, continue to next pending todo
5. **Else**: Return `<COMPLETE>` marker

**Example**:
```bash
# Agent continuation logic
if should_continue; then
  next_todo=$(jq -r '.todos[] | select(.status == "pending") | .id' "$STATE_FILE" | head -1)
  update_state "$next_todo" "in_progress" $((iteration + 1))
  # Continue working on $next_todo
else
  echo "<COMPLETE>"
  exit 0
fi
```

---

## Integration Points

### Commands

| Command | Continuation Role |
|---------|-------------------|
| `/00_plan` | Creates granular todos (≤15 min each) |
| `/02_execute` | Creates/resumes continuation state |
| `/00_continue` | Loads state and continues from checkpoint |
| `/03_close` | Verifies all todos complete, archives state |

### Agents

**Agents with continuation**: coder, tester, validator, documenter

**Flow**:
1. Complete current task
2. **Before stopping**, check `.pilot/state/continuation.json`
3. **If** incomplete todos exist and iterations < max: Update state → Continue
4. **Else**: Return completion marker → Stop

---

## State Persistence

### Backup Strategy

Every write operation:
1. Creates `.backup` file automatically
2. Validates JSON syntax with `jq empty`
3. Uses atomic writes (`mv` after successful write)
4. Restores from backup if corruption detected

**Example**:
```bash
# Safe state write with backup
write_state() {
  local new_content="$1"
  local state_file=".pilot/state/continuation.json"
  local backup_file="${state_file}.backup"

  # Create backup
  cp "$state_file" "$backup_file"

  # Validate JSON
  echo "$new_content" | jq empty > /dev/null 2>&1 || { echo "Invalid JSON" >&2; return 1; }

  # Atomic write
  echo "$new_content" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
}
```

### Recovery

**Corruption detected**: Automatically restore from `.backup` file

**Lost state**: Run `/00_continue` to resume from last checkpoint

---

## Verification

### Test Continuation
```bash
# Verify state file exists and valid
test -f .pilot/state/continuation.json
jq empty .pilot/state/continuation.json

# Check incomplete todos
jq '[.todos[] | select(.status == "pending" or .status == "in_progress")] | length' .pilot/state/continuation.json

# Verify iteration count
jq '.iteration_count < .max_iterations' .pilot/state/continuation.json
```

### Expected Results
- Valid JSON with all required fields
- At least one incomplete todo (until plan complete)
- Iteration count < max iterations (until plan complete)

---

## Related Skills

- **ralph-loop**: Autonomous iteration (max 7) - calls managing-continuation
- **parallel-subagents**: Concurrent agent execution with state coordination
- **spec-driven-workflow**: Plan state management (pending → progress → done)

---

**Version**: claude-pilot 4.2.0 (Sisyphus Continuation System)
