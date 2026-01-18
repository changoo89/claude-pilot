# .pilot - Plan Execution State Management (Tier 2)

> **Purpose**: Plan execution, continuation state, and test artifact management
> **Last Updated**: 2026-01-18
> **Tier**: 2 (Component - State Management System)
> **Maintainer**: claude-pilot

---

## Quick Reference

### What this is
Plan execution state management system that tracks work in progress, maintains continuation state for agent persistence, and stores test artifacts.

### Current Status
| Aspect | Status |
|--------|--------|
| Stability | Stable (v4.2.0+) |
| Last Major Change | 2026-01-18 (Sisyphus Continuation System) |
| Dependencies | jq (JSON processing), git (branch detection) |

---

## Component Overview

### Purpose
The `.pilot` directory manages the complete lifecycle of plan execution:
- **Plan Management**: Track plans from pending → in-progress → done
- **Continuation State**: Enable agent persistence across sessions (Sisyphus system)
- **Test Artifacts**: Store test results, coverage reports, Ralph Loop logs
- **Worktree Support**: Isolated development environments per branch

### Responsibilities
- Plan state transitions (atomic operations)
- Continuation state persistence (JSON-based state file)
- Test artifact archival (test scenarios, coverage, iteration logs)
- Worktree isolation (parallel branch development)

---

## Development Guidelines

### When to Work Here
- **Use for**: Adding new plan states, modifying continuation logic, extending test artifact formats
- **Don't use for**: Command logic (→ `.claude/commands/`), agent prompts (→ `.claude/agents/`)

### Key Constraints
- **Atomic Operations**: Plan state transitions MUST be atomic (move, not copy+delete)
- **State Validation**: Continuation state MUST be validated before reads/writes
- **Backup Strategy**: State file writes MUST create backup before overwriting
- **Branch Isolation**: Continuation state is per-branch only

---

## Key Component Structure

### Directory Layout
```
.pilot/
├── plan/                    # Plan state management
│   ├── pending/             # New plans (awaiting execution)
│   ├── in_progress/         # Active plans (currently executing)
│   ├── done/                # Completed plans (archived)
│   └── active/              # Branch-specific active plan pointers
├── state/                   # Continuation state (NEW v4.2.0)
│   └── continuation.json    # Agent persistence state
├── scripts/                 # State management utilities
│   ├── state_read.sh        # Read continuation state
│   ├── state_write.sh       # Write continuation state
│   └── state_backup.sh      # Backup before writes
└── tests/                   # Test artifacts
    ├── test_*.test.sh       # Integration tests
    └── integration_test.sh  # End-to-end tests
```

### Key Files
| File | Purpose | Notes |
|------|---------|-------|
| `state/continuation.json` | Agent persistence state | Version 1.0 JSON format |
| `scripts/state_read.sh` | Read state with validation | Exits 1 if invalid JSON |
| `scripts/state_write.sh` | Write state atomically | Creates backup before write |
| `scripts/state_backup.sh` | Backup state file | Preserves `.backup` file |
| `plan/active/{branch}.txt` | Active plan pointer | Points to in-progress plan |

---

## Implementation Highlights

### Core Patterns
- **State Machine**: Plan transitions through discrete states (pending → in-progress → done)
- **Atomic Operations**: File moves (not copy+delete) for plan transitions
- **JSON Validation**: All state reads validated with `jq empty` check
- **Backup Strategy**: Automatic `.backup` file creation before writes

### Architectural Decisions
| Decision | Rationale |
|----------|-----------|
| JSON state file | Human-readable, editable, tool-supported (jq) |
| File moves (not copies) | Atomic, prevent inconsistent state |
| Per-branch state | Avoid cross-branch contamination |
| Backup before writes | Recovery from corruption |

---

## Integration Points

### Dependencies (Inbound)
| Component | Interface | Purpose |
|-----------|-----------|---------|
| `/02_execute` | Creates state | Initializes continuation.json on execution start |
| `/00_continue` | Reads state | Loads continuation state for resume |
| `/03_close` | Validates state | Verifies all todos complete before closure |
| Agent prompts | Read/Write state | Agents update todo status via state scripts |

### Dependents (Outbound)
| Component | Interface | Purpose |
|-----------|-----------|---------|
| `.claude/commands/` | Plan state | Commands check plan state for execution |
| `.claude/agents/` | Continuation | Agents read state to determine next action |
| `check-todos.sh` hook | State validation | Hook checks incomplete todos on agent stop |

---

## Critical Implementation Details

### Performance Considerations
- **State File Size**: Typically <5KB (JSON with ~10 todos)
- **Read/Write Frequency**: Once per todo completion (not per tool call)
- **JSON Parsing**: `jq` operations are fast (<10ms for typical state)

### Security Considerations
- **File Permissions**: State files SHOULD be 600 (user-only) - current: 644
- **JSON Injection**: Mitigated by `jq --arg/--argjson` (safe interpolation)
- **Path Traversal**: Prevented by hardcoded `.pilot/state/` directory

### Error Handling Strategy
- **Invalid JSON**: Fallback to `.backup` file if state corrupted
- **Missing State**: Create new state with default values
- **Write Failures**: Preserve previous state (backup not overwritten)

---

## Development Notes

### Common Tasks
| Task | Description | Reference |
|------|-------------|-----------|
| Create new plan | Move plan file to `pending/` | `/00_plan` command |
| Start execution | Move plan `pending/` → `in_progress/` | `/02_execute` Step 1 |
| Resume work | Load state from `continuation.json` | `/00_continue` command |
| Complete plan | Move plan `in_progress/` → `done/` | `/03_close` command |
| Update todo status | Write state with new todo status | `state_write.sh` |

### Testing Guidelines
- **Integration tests**: `.pilot/tests/test_*.test.sh`
- **Running tests**: `bash .pilot/tests/test_*.test.sh`
- **Coverage**: Manual testing (shell scripts lack automated coverage)

### Known Limitations
- **No File Locking**: Concurrent writes NOT supported (single-process assumption)
- **Branch Switching**: State file NOT automatically cleaned on branch switch
- **Session Isolation**: No cross-session state persistence (restart = lost state)

---

## Common Pitfalls

### Don't
- ❌ **Modify state manually**: Use `state_write.sh` script (ensures validation)
- ❌ **Copy plan files**: Use `mv` for atomic state transitions
- ❌ **Ignore state validation**: Always check `jq` exit codes
- ❌ **Assume state exists**: Check file existence before reads

### Do
- ✅ **Use state scripts**: `state_read.sh`, `state_write.sh`, `state_backup.sh`
- ✅ **Validate JSON**: Check `jq` exit codes before using state data
- ✅ **Create backups**: Always backup before writes (handled by scripts)
- ✅ **Check branch**: Verify branch name in state matches current branch

---

## Related Documentation

- **Tier 1 (Project)**: `../CLAUDE.md`
- **Tier 3 (Scripts)**: `scripts/CONTEXT.md`
- **Continuation System**: `.claude/guides/continuation-system.md`
- **Todo Granularity**: `@.claude/guides/todo-granularity/SKILL.md`

---

## Notes

### Workarounds
- **No file locking**: Acceptable for current single-process workflow
- **Branch mismatch**: Manual cleanup required: `rm .pilot/state/continuation.json`

### Technical Debt
- **File permissions**: State files currently 644 (world-readable) → should be 600
- **No timeout**: File operations lack timeout (potential hang on NFS)
- **jq error suppression**: Errors redirected to `/dev/null` (hard to debug)

### Future Enhancements
- **File locking**: Add `flock` wrapper for parallel execution support
- **Auto cleanup**: Detect branch switches and clean up stale state
- **Test coverage**: Add shell script testing framework (bats)
