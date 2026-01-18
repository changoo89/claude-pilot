# Continuation System Guide

> **Last Updated**: 2026-01-18
> **Version**: 1.0
> **Status**: Active

---

## Overview

The **Sisyphus Continuation System** enables agents to persist work across sessions and continue until all todos are complete. Inspired by the Greek myth of Sisyphus, the system ensures "the boulder never stops" - agents continue working until completion or manual intervention.

**Key Philosophy**: Tasks should be completed automatically without manual restart of agents.

---

## Quick Start

### Basic Usage

1. **Start a plan** with `/00_plan` - generates granular todos
2. **Execute** with `/02_execute` - creates continuation state automatically
3. **Agent continues** until todos complete or max iterations (7) reached
4. **Resume** anytime with `/00_continue` if session interrupted
5. **Complete** with `/03_close` - verifies all todos complete before closing

### Escape Hatch

Stop continuation anytime:
- `/cancel` - Cancel current work
- `/stop` - Stop and save state
- `/done` - Force completion

---

## Components

### 1. State File

**Location**: `.pilot/state/continuation.json`

**Format**:
```json
{
  "version": "1.0",
  "session_id": "uuid",
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

**Fields**:
- `version`: State format version (currently "1.0")
- `session_id`: Unique UUID for session tracking
- `branch`: Git branch name
- `plan_file`: Path to active plan
- `todos`: Array of todo items with status tracking
- `iteration_count`: Current iteration number
- `max_iterations`: Maximum iterations (default: 7)
- `last_checkpoint`: ISO 8601 timestamp of last update
- `continuation_level`: Aggressiveness level (aggressive/normal/polite)

### 2. State Management Scripts

**Location**: `.pilot/scripts/`

| Script | Purpose | Usage |
|--------|---------|-------|
| `state_read.sh` | Read continuation state | `state_read.sh [--state-dir PATH]` |
| `state_write.sh` | Write continuation state | `state_write.sh --plan-file PATH --todos JSON --iteration N` |
| `state_backup.sh` | Backup before writes | `state_backup.sh [--state-dir PATH]` |

**Features**:
- **JSON validation**: Validates JSON before reads/writes
- **Atomic writes**: Uses file locking (`flock`) to prevent race conditions
- **Safe generation**: Uses `jq` to prevent JSON injection attacks
- **Automatic backup**: Creates `.backup` file before any write

### 3. Agent Continuation Logic

**Agents with continuation**:
- `coder` - Implementation agent
- `tester` - Test execution agent
- `validator` - Type check/lint agent
- `documenter` - Documentation agent

**Continuation flow**:
1. Agent completes current task
2. **Before stopping**, checks `.pilot/state/continuation.json`
3. **If** incomplete todos exist and iterations < max:
   - Updates state with current progress
   - Continues to next todo
   - Does NOT stop
4. **Else if** all todos complete:
   - Returns completion marker
   - Stops normally

### 4. Commands

| Command | Purpose | Continuation Integration |
|---------|---------|---------------------------|
| `/00_plan` | Generate plan | Creates granular todos (≤15 min each) |
| `/02_execute` | Execute plan | Creates/resumes continuation state |
| `/00_continue` | Resume work | Loads state and continues |
| `/03_close` | Close plan | Verifies all todos complete |

---

## Configuration

### Continuation Levels

Set via environment variable:
```bash
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite
```

**Levels**:
- `aggressive`: Maximum continuation, minimal pauses
- `normal` (default): Balanced continuation
- `polite`: More frequent checkpoints, user control

### Max Iterations

Set via environment variable:
```bash
export MAX_ITERATIONS=7  # Default: 7
```

**Purpose**: Prevents infinite continuation loops

### Session Tracking

Each continuation session has unique UUID:
```json
{
  "session_id": "E6C8D636-7DA4-448D-850F-E5131DF42969"
}
```

**Benefits**:
- Track sessions across branches
- Recover from interruption
- Audit trail of work

---

## Usage Examples

### Example 1: Normal Flow

```bash
# User: /00_plan "Implement user authentication"
# System: Generates plan with 5 granular todos

# User: /02_execute
# System:
#   - Creates .pilot/state/continuation.json
#   - Starts SC-1: Create auth service
#   - Completes SC-1
#   - Agent checks continuation state
#   - Sees SC-2 pending
#   - Continues to SC-2 automatically
#   - ... repeats until all 5 SCs complete

# System: All todos complete, returns success
```

### Example 2: Session Interruption

```bash
# User: /02_execute
# System: Starts work, completes SC-1, SC-2
# [NETWORK INTERRUPTION - Session lost]

# User: /00_continue
# System:
#   - Loads .pilot/state/continuation.json
#   - Sees SC-1, SC-2 complete, SC-3 in_progress
#   - Resumes from SC-3
#   - Continues until complete
```

### Example 3: Max Iterations Reached

```bash
# User: /02_execute
# System: Working through todos...
# System: Iteration 7 reached, SC-4 still pending

# System output:
# ⚠️  MAX ITERATIONS REACHED (7/7)
# → Manual review required - continuation paused
#
# Remaining todos:
#   - SC-4
#
# Use /00_continue to resume after review
```

### Example 4: Escape Hatch

```bash
# User: /02_execute
# System: Working on SC-2...
# User: /stop

# System:
#   - Saves current state to continuation.json
#   - Stops gracefully
#   - Outputs: "Work stopped. Use /00_continue to resume."
```

---

## Troubleshooting

### Problem: "Continuation state file not found"

**Cause**: State file doesn't exist (new plan or deleted)

**Solution**: Run `/02_execute` to create new state

### Problem: "Invalid JSON in continuation state"

**Cause**: State file corrupted

**Solution**:
1. Check backup: `.pilot/state/continuation.json.backup`
2. Restore: `cp .pilot/state/continuation.json.backup .pilot/state/continuation.json`
3. If backup also corrupted, delete state and run `/02_execute`

### Problem: "Agent continues indefinitely"

**Cause**: Max iterations not configured or set too high

**Solution**:
```bash
export MAX_ITERATIONS=7
/02_execute
```

### Problem: "Todos marked complete but agent continues"

**Cause**: State file out of sync with reality

**Solution**:
1. Check state: `.pilot/scripts/state_read.sh`
2. Manually update if needed
3. Run `/00_continue` to refresh

### Problem: "Branch mismatch error"

**Cause**: State file from different branch

**Solution**:
- Switch to correct branch: `git checkout <branch>`
- Or delete state and start fresh: `rm .pilot/state/continuation.json`

---

## Advanced Topics

### File Locking

State updates use `flock` for atomic read-modify-write:

```bash
(
    flock -x 9 || exit 1
    # Read, modify, write within lock
) 9>".pilot/state/continuation.json.lock"
```

**Prevents**: Race conditions during parallel agent execution

### JSON Safety

All JSON generation uses `jq` to prevent injection:

```bash
# SAFE: Uses jq for proper escaping
jq -n \
    --arg plan_file "$PLAN_FILE" \
    --argjson todos "$TODOS_JSON" \
    '{plan_file: $plan_file, todos: $todos}'
```

**Prevents**: JSON injection attacks from malicious file paths

### State Backup

Every write creates automatic backup:

```
.pilot/state/continuation.json        # Current state
.pilot/state/continuation.json.backup # Previous state
```

**Recovery**: Restore from backup if corruption detected

---

## Integration Points

### With Ralph Loop

- Each Ralph Loop iteration updates `iteration_count`
- Check `max_iterations` before continuing
- If limit reached, return `<CODER_BLOCKED>`

### With TodoWrite Tool

- Continuation state tracks TodoWrite status
- State updated when TodoWrite changes
- Agent reads state to determine next action

### With Granularity Guide

- `/00_plan` breaks down large SCs into granular todos
- Each granular todo ≤15 minutes
- Enables reliable continuation progress

---

## Related Documentation

- **Todo Granularity**: `@.claude/guides/todo-granularity/SKILL.md`
- **Ralph Loop**: `.claude/skills/ralph-loop/SKILL.md`
- **Execution Command**: `.claude/commands/02_execute.md`
- **Continue Command**: `.claude/commands/00_continue.md`

---

**Version**: 1.0
**Last Updated**: 2026-01-18
