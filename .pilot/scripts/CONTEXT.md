# .pilot/scripts - State Management Utilities (Tier 3)

> **Purpose**: State persistence, backup, and recovery utilities for continuation system
> **Last Updated**: 2026-01-18
> **Tier**: 3 (Feature - Implementation Details)
> **Component**: .pilot (Plan Execution State Management)

---

## Quick Reference

### What this is
Bash utility scripts for reading, writing, and backing up continuation state JSON files with validation and error recovery.

### Current Status
| Aspect | Status |
|--------|--------|
| Development | Stable (v4.2.0+) |
| Last Changed | 2026-01-18 |
| Test Coverage | Manual (shell scripts) |

---

## Architecture & Patterns

### Design Pattern(s) Used
- **Template Method**: All scripts follow same pattern (validate → operate → report)
- **Safe Operations**: Atomic writes, backup-before-overwrite
- **Error Recovery**: Fallback to `.backup` file on corruption

### Data Flow
```
State Read Request → state_read.sh → Validate JSON → Output state
                      ↓                      ↓
                  jq validation          Parse & format

State Write Request → state_write.sh → Create backup → Write state
                         ↓                   ↓
                   state_backup.sh      jq atomic write
```

### State Management
| State | Initial | Updates | Source |
|-------|---------|---------|--------|
| `CONTINUATION_FILE` | `.pilot/state/continuation.json` | On write | Environment variable |
| `STATE_DIR` | `.pilot/state/` | On init | Computed from project root |
| `BACKUP_FILE` | `${CONTINUATION_FILE}.backup` | On write | Derived from state file |

---

## Integration & Performance

### External Dependencies
```bash
# Required tools
jq                    # JSON processing (version 1.5+)
git                   # Branch detection (any version)
```

| Dependency | Version | Purpose |
|------------|---------|---------|
| `jq` | 1.5+ | JSON parsing and validation |
| `git` | any | Current branch detection |

### Internal Dependencies
| Script/Function | Purpose |
|-----------------|---------|
| `state_backup.sh` | Backup creation (called by state_write.sh) |
| `state_read.sh` | State loading (used by commands/agents) |
| `state_write.sh` | State persistence (used by commands/agents) |

### Performance Characteristics
- **Time Complexity**: O(n) where n = size of JSON state (typically <5KB)
- **Space Complexity**: O(1) - streaming JSON processing via jq
- **Optimization Notes**: jq is fast for small JSON files (<10ms typical)

---

## Implementation Decisions

### Decision Log
| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|-------------------------|
| 2026-01-18 | Use JSON for state | Human-readable, tool-supported | SQLite, binary format |
| 2026-01-18 | Bash scripts | Portable, no dependencies | Python, Node.js |
| 2026-01-18 | jq for JSON | Safe, validated parsing | Native bash parsing |
| 2026-01-18 | Backup strategy | Recovery from corruption | No backup (risky) |

### Trade-offs
| Choice | Benefit | Cost |
|--------|---------|------|
| JSON state file | Editable, debuggable | Larger than binary |
| Bash scripts | No runtime dependencies | Limited error handling |
| jq validation | Safe parsing | jq dependency required |
| Atomic write pattern | No corruption risk | Temporary file needed |

---

## Code Examples

### Common Usage

#### Reading State
```bash
# Source the read script
source .pilot/scripts/state_read.sh

# State loaded into environment variables:
# - CONTINUATION_STATE (full JSON)
# - SESSION_ID, BRANCH, PLAN_FILE
# - TODOS (JSON array)
# - ITERATION_COUNT, MAX_ITERATIONS
```

#### Writing State
```bash
# Source the write script
source .pilot/scripts/state_write.sh

# Call write function
write_continuation_state \
  --session-id "$UUID" \
  --branch "$BRANCH" \
  --plan-file "$PLAN_PATH" \
  --todos "$TODOS_JSON" \
  --iteration-count "$ITERATION"
```

#### Backup Creation
```bash
# Source the backup script
source .pilot/scripts/state_backup.sh

# Create backup (automatic before write)
backup_continuation_state
# Creates: .pilot/state/continuation.json.backup
```

### Edge Cases Handled

#### Corrupted State Recovery
```bash
# state_read.sh automatically falls back to backup
if ! jq empty "$CONTINUATION_FILE" 2>/dev/null; then
  if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$CONTINUATION_FILE"
  fi
fi
```

#### Missing State Directory
```bash
# All scripts create directory if missing
STATE_DIR=".pilot/state"
mkdir -p "$STATE_DIR"
```

#### Invalid JSON Detection
```bash
# Validate before using
if ! jq -e . "$CONTINUATION_FILE" >/dev/null 2>&1; then
  echo "Error: Invalid JSON in state file" >&2
  exit 1
fi
```

### Common Modifications
| Change | Location | How to |
|--------|----------|--------|
| Add new state field | All scripts | Add to jq --arg parameters |
| Change state file path | All scripts | Modify CONTINUATION_FILE variable |
| Add validation | state_read.sh | Add jq -e check after read |
| Modify backup strategy | state_backup.sh | Change cp command parameters |

---

## Testing Strategy

### Test Coverage
| Type | Location | Coverage |
|------|----------|----------|
| Integration | `.pilot/tests/test_*.test.sh` | Manual |
| Unit | None (shell scripts) | N/A |
| E2E | `.pilot/tests/integration_test.sh` | Manual |

### Running Tests
```bash
# Run all tests
bash .pilot/tests/*.test.sh

# Run specific test
bash .pilot/tests/test_state_recovery.test.sh
```

### Key Test Cases
| Case | Description | Expected |
|------|-------------|----------|
| State creation | Create new state file | Valid JSON with all fields |
| State read | Load existing state | All variables populated |
| Backup creation | Verify backup file | `.backup` file created |
| Corruption recovery | Restore from backup | Backup loaded on corruption |
| Invalid JSON | Reject malformed JSON | Exit code 1, error message |

---

## Development Workflow

### Making Changes
1. **Modify script**: Edit `.pilot/scripts/state_*.sh`
2. **Test manually**: Run integration tests
3. **Validate JSON**: Ensure jq operations succeed
4. **Test recovery**: Verify backup/restore works

### Debugging Tips
- **Issue**: jq command fails → **Solution**: Check JSON syntax with `jq . < file`
- **Issue**: State not updating → **Solution**: Check write permissions on state directory
- **Issue**: Backup not created → **Solution**: Verify state_backup.sh is sourced
- **Issue**: Wrong plan path → **Solution**: Check PLAN_FILE variable in state

### Validation
```bash
# Validate state JSON
jq . .pilot/state/continuation.json

# Check required fields
jq -e '.version, .session_id, .branch, .plan_file, .todos' \
  .pilot/state/continuation.json

# Test read script
bash -c 'source .pilot/scripts/state_read.sh; echo $SESSION_ID'

# Test write script
bash .pilot/tests/test_state_recovery.test.sh
```

---

## Common Pitfalls

### Don't
- ❌ **Edit state manually**: Use scripts (ensures validation)
- ❌ **Skip backup**: Always backup before writes
- ❌ **Ignore jq errors**: Check exit codes
- ❌ **Hardcode paths**: Use variables for portability

### Do
- ✅ **Source scripts**: Use `source` not `bash` (preserves environment)
- ✅ **Validate JSON**: Check jq exit codes
- ✅ **Test recovery**: Verify backup/restore works
- ✅ **Use variables**: CONTINUATION_FILE, STATE_DIR, BACKUP_FILE

---

## Related Documentation

- **Parent Component (Tier 2)**: `../CONTEXT.md`
- **Project (Tier 1)**: `../../CLAUDE.md`
- **Continuation System**: `.claude/guides/continuation-system.md`
- **State Scripts Reference**: `.claude/guides/state-management.md`

---

## Notes

### Current Workarounds
- **No file locking**: Acceptable for single-process workflow
- **Manual validation**: jq exit codes checked manually

### Known Issues
| Issue | Impact | Planned Fix |
|-------|--------|-------------|
| No file locking | Potential corruption on concurrent writes | Add flock wrapper |
| 644 permissions | World-readable state file | Set 600 permissions |
| No timeout | Potential hang on NFS | Add timeout to file ops |

### Future Improvements
- **Add file locking**: Use flock for concurrent write support
- **Set permissions**: chmod 600 on state files
- **Add timeouts**: Timeout for file operations
- **Test framework**: Add bats for automated testing

### Refactoring Opportunities
- **Common validation**: Extract to shared function
- **Error handling**: Standardize error messages
- **Logging**: Add debug logging option
