# Sisyphus Continuation System (v4.2.0)

> **Last Updated**: 2026-01-18
> **Purpose**: Intelligent agent continuation across sessions

---

## Overview

Inspired by the Greek myth of Sisyphus, the continuation system ensures "the boulder never stops" - agents continue working until completion or manual intervention. Tasks are completed automatically without manual restart.

### Key Features

**State Persistence**:
- Continuation state stored in `.pilot/state/continuation.json`
- Tracks: session UUID, branch, plan file, todos, iteration count
- Automatic backup before writes (`.backup` file)

**Agent Continuation**:
- Agents check continuation state before stopping
- Continue if incomplete todos exist and iterations < max (7)
- Escape hatch: `/cancel`, `/stop`, `/done` commands

**Granular Todo Breakdown**:
- Todos broken into ≤15 minute chunks
- Single owner per todo (coder, tester, validator, documenter)
- Enables reliable continuation progress tracking

---

## Commands

| Command | Purpose |
|---------|---------|
| `/00_continue` | Resume work from continuation state |
| `/02_execute` | Creates/resumes continuation state automatically |
| `/03_close` | Verifies all todos complete before closing |

---

## Configuration

```bash
# Set continuation aggressiveness
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite

# Set max iterations (default: 7)
export MAX_ITERATIONS=7
```

**Continuation Levels**:
- `aggressive`: Maximum continuation, minimal pauses
- `normal` (default): Balanced continuation
- `polite`: More frequent checkpoints, user control

---

## State File Format

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

---

## Components

| File | Purpose |
|------|---------|
| `.pilot/state/continuation.json` | Agent persistence state (JSON) |
| `.pilot/state/continuation.json.backup` | State backup |
| `.pilot/scripts/state_read.sh` | Read state with validation |
| `.pilot/scripts/state_write.sh` | Write state atomically |
| `.pilot/scripts/state_backup.sh` | Backup continuation state |
| `.claude/commands/00_continue.md` | Resume command |
| `.claude/guides/continuation-system.md` | Full system guide |
| `.claude/guides/todo-granularity.md` | Todo breakdown guidelines |

---

## Workflow

1. **Plan**: `/00_plan "task"` → Generates granular todos (≤15 min each)
2. **Execute**: `/02_execute` → Creates continuation state, starts work
3. **Continue**: Agent continues automatically until:
   - All todos complete, OR
   - Max iterations reached (7), OR
   - User interrupts (`/cancel`, `/stop`)
4. **Resume**: `/00_continue` → If session interrupted
5. **Close**: `/03_close` → Verifies all todos complete

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/02_execute` | Creates state | `.pilot/state/continuation.json` |
| `/00_continue` | Reads state | Loads todos, iteration count |
| `/03_close` | Validates state | Verifies all todos complete |
| Agent prompts | Read/Write state | Agents update todo status |
| `.claude/settings.json` | Config | continuation.level, maxIterations |

---

## Agent Continuation Logic

Agents with continuation checks:
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

---

## See Also

- **@.claude/guides/continuation-system.md** - Implementation guide
- **@.claude/guides/todo-granularity.md** - Granular todo breakdown
- **@CLAUDE.md** - Project standards (Tier 1)
- **@docs/ai-context/system-integration.md** - Core workflows and integration

---

**Last Updated**: 2026-01-18
**Version**: 4.2.0
