# Continuation System Guide

> **Last Updated**: 2026-01-18
> **Version**: 1.0.0
> **Status**: Active
> **See**: @.claude/guides/continuation-system-REFERENCE.md for detailed reference

---

## Overview

**Sisyphus Continuation System**: Agents persist work across sessions until todos complete. "The boulder never stops" - automatic continuation without manual restart.

---

## Quick Start

**Workflow**:
1. `/00_plan` - generates granular todos
2. `/02_execute` - creates continuation state
3. Agent continues until todos complete or max iterations (7)
4. `/00_continue` - resume if session interrupted
5. `/03_close` - verifies all todos complete

**Escape Hatch**: `/cancel`, `/stop`, `/done`

---

## Components

### 1. State File

**Location**: `.pilot/state/continuation.json`

**Key Fields**:
- `version`: State format version
- `session_id`: Unique UUID
- `branch`: Git branch name
- `plan_file`: Path to active plan
- `todos`: Array of todo items (id, status, iteration, owner)
- `iteration_count`: Current iteration
- `max_iterations`: Maximum (default: 7)
- `continuation_level`: Aggressiveness (aggressive/normal/polite)

**See**: @.claude/guides/continuation-system-REFERENCE.md for JSON schema

### 2. State Management Scripts

**Location**: `.pilot/scripts/`

| Script | Purpose | Usage |
|--------|---------|-------|
| `state_read.sh` | Read state | `state_read.sh [--state-dir PATH]` |
| `state_write.sh` | Write state | `state_write.sh --plan-file PATH --todos JSON --iteration N` |
| `state_backup.sh` | Backup before writes | `state_backup.sh [--state-dir PATH]` |

**Features**: JSON validation, Atomic writes (`flock`), Safe generation (`jq`), Automatic backup

### 3. Agent Continuation Logic

**Agents with continuation**: coder, tester, validator, documenter

**Flow**:
1. Complete current task
2. **Before stopping**, check `.pilot/state/continuation.json`
3. **If** incomplete todos exist and iterations < max: Update state → Continue to next todo
4. **Else**: Return completion marker → Stop

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

```bash
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite
```

- `aggressive`: Maximum continuation, minimal pauses
- `normal` (default): Balanced continuation
- `polite`: Frequent checkpoints, user control

### Max Iterations

```bash
export MAX_ITERATIONS=7  # Default: 7
```

**Purpose**: Prevents infinite continuation loops

---

## Agent Continuation Pattern

**Before stopping, agent MUST**:
1. Read `.pilot/state/continuation.json`
2. Check for incomplete todos
3. Check if iterations < max
4. **If both true**: Update state, continue to next todo
5. **Else**: Return completion marker

**See**: @.claude/guides/continuation-system-REFERENCE.md for implementation details

---

## State Persistence

### Backup Strategy

Every write operation:
1. Creates `.backup` file automatically
2. Validates JSON syntax
3. Uses file locking for atomic writes
4. Restores from backup if corruption detected

### Recovery

**Corruption detected**: Automatically restore from `.backup` file

**Lost state**: Run `/00_continue` to resume from last checkpoint

---

## Verification

**Test Continuation**:
```bash
bash .pilot/tests/test_00_continue.test.sh
```

**Manual Check**:
```bash
cat .pilot/state/continuation.json | jq empty  # Validate JSON
```

**Expected**: Valid JSON with all required fields

---

## Related Documentation

- **State Scripts**: @.claude/guides/continuation-system-REFERENCE.md
- **Commands**: @.claude/commands/00_continue.md, @.claude/commands/02_execute.md
- **Todo Granularity**: @.claude/guides/todo-granularity.md

---

**Version**: claude-pilot 4.2.0 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
