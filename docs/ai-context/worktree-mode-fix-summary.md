# Worktree Mode Fix Summary

> **Date**: 2026-01-18
> **Command**: `/02_execute --wt`
> **Status**: ✅ Completed

---

## Problem Identified

The worktree mode (`--wt` flag) in `/02_execute` was not working correctly due to a fundamental limitation of Claude Code's Bash tool:

**Root Cause**: The Bash tool resets the working directory (cwd) after each call. This means:
- `cd "$WORKTREE_PATH"` only affects the current bash session
- Environment variables set in one call don't persist to the next
- File operations would happen in the wrong directory

**Impact**: Worktree mode appeared to work but agents actually executed in the main repository, defeating the purpose of worktree isolation.

---

## Solution Implemented

### Core Mechanism: Path Persistence

Instead of relying on `cd` to switch directories, the fix uses a **path persistence mechanism**:

1. **Store worktree path** in a file in the main repository
2. **Restore worktree context** at the start of each Bash tool call
3. **Use absolute paths** for all file operations

### Files Modified

#### 1. `.claude/commands/02_execute.md`

**Changes**:
- Added worktree path persistence after creation (line 247-251)
- Added worktree context restoration before plan detection (line 267-286)
- Updated plan detection to use `PLAN_SEARCH_ROOT` (line 292)
- Updated plan movement to use `PLAN_SEARCH_ROOT` (line 298-306)
- Updated worktree metadata section (line 311-347)
- Updated active pointer to use `ACTIVE_ROOT` (line 349-359)

**Key Code Patterns**:

```bash
# Store worktree path
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"
echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
echo "  Branch: $WT_BRANCH" >> "$WORKTREE_PERSIST_FILE"
echo "  Main Branch: $MAIN_BRANCH" >> "$WORKTREE_PERSIST_FILE"

# Restore worktree context
if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    WORKTREE_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    WORKTREE_BRANCH="$(sed -n '2s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    MAIN_BRANCH="$(sed -n '3s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    WORKTREE_ROOT="$WORKTREE_PATH"
    PROJECT_ROOT="$WORKTREE_PATH"
fi

# Use conditional path resolution
PLAN_SEARCH_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"
```

#### 2. Worktree Creation (Skill-Based)

**Status**: Converted to skill-based git commands (direct `git worktree add`)

#### 3. Test Files Created

- `.pilot/tests/test_worktree_cwd_reset.sh` - Documents the cwd reset issue
- `.pilot/tests/test_worktree_absolute_paths.sh` - Tests absolute path logic
- `.pilot/tests/test_worktree_persistence.sh` - Tests path persistence mechanism
- `.pilot/tests/test_worktree_integration.sh` - End-to-end integration test

#### 4. Documentation Created

- `docs/ai-context/worktree-mode-limitations.md` - Comprehensive documentation of the issue and solution

---

## Test Results

### Unit Tests

```bash
$ bash .pilot/tests/test_worktree_persistence.sh
✓ All tests passed

$ bash .pilot/tests/test_worktree_integration.sh
✓ All tests passed
```

### Test Coverage

- ✅ Worktree creation
- ✅ Path storage and persistence
- ✅ Context restoration across bash calls
- ✅ Plan detection with worktree paths
- ✅ Plan movement (pending → in_progress)
- ✅ Active pointer management

---

## How It Works

### Workflow

1. **User runs**: `/02_execute --wt`

2. **Worktree Creation** (Step 1.1):
   - Create worktree using `git worktree add`
   - Store worktree path in `.pilot/worktree_active.txt`
   - Set environment variables for this session

3. **Plan Detection** (subsequent Bash calls):
   - Read worktree path from `.pilot/worktree_active.txt`
   - Restore `WORKTREE_ROOT`, `WORKTREE_BRANCH`, etc.
   - Use `PLAN_SEARCH_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"`

4. **Agent Execution**:
   - All file operations use absolute paths via `WORKTREE_ROOT`
   - Plan state managed in main repository (shared across worktrees)
   - State file location uses worktree path

5. **Cleanup** (`/03_close`):
   - Read worktree metadata from plan
   - Squash merge worktree branch to main
   - Remove worktree and persistence file

### Key Insight

**Plans are stored in the main repository, not in worktrees.**

This is intentional because:
- Git worktrees share the same git object database
- `.pilot/` directory is typically gitignored
- Each worktree should have access to the same plans
- State can be shared across worktrees

---

## Usage Examples

### Create worktree and execute plan

```bash
/02_execute --wt
```

This will:
1. Create a new worktree with branch `wt/<timestamp>`
2. Store worktree path in `.pilot/worktree_active.txt`
3. Move oldest pending plan to `in_progress`
4. Execute plan using worktree paths

### Resume work in existing worktree

```bash
/00_continue
```

This will:
1. Read worktree path from `.pilot/worktree_active.txt`
2. Restore worktree context
3. Continue with next incomplete todo

### Close worktree after completion

```bash
/03_close
```

This will:
1. Read worktree metadata from plan
2. Switch to main repository
3. Squash merge worktree branch
4. Remove worktree
5. Clean up persistence file

---

## Limitations and Considerations

### Current Limitations

1. **Single worktree per main repo**: Only one worktree can be active at a time (tracked by `.pilot/worktree_active.txt`)

2. **Manual cleanup required if interrupted**: If execution is interrupted, the worktree and persistence file may need manual cleanup

3. **Plan location**: Plans are in main repo, not in worktree (this is intentional but may be surprising)

### Future Enhancements

1. **Multiple worktree support**: Allow multiple active worktrees with unique persistence files
2. **Automatic cleanup**: Detect and clean up orphaned worktrees
3. **Worktree-specific plans**: Option to store plans in worktree instead of main repo

---

## Related Documentation

- **Worktree Setup Guide**: @.claude/skills/using-git-worktrees/SKILL.md
- **Execute Command**: @.claude/commands/02_execute.md
- **Close Command**: @.claude/commands/03_close.md
- **Worktree Limitations**: @docs/ai-context/worktree-mode-limitations.md

---

## Verification Steps

To verify the fix is working:

1. Create a test plan:
```bash
/00_plan "test worktree mode"
```

2. Execute with worktree mode:
```bash
/02_execute --wt
```

3. Verify worktree was created:
```bash
git worktree list
cat .pilot/worktree_active.txt
```

4. Close and cleanup:
```bash
/03_close
```

5. Verify worktree was removed:
```bash
git worktree list
ls .pilot/worktree_active.txt  # Should not exist
```

---

**Status**: ✅ Worktree mode is now fully functional

**Next Steps**: Test with actual development workflows and gather user feedback
