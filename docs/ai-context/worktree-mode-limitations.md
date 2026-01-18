# Worktree Mode Limitations in Claude Code

## Problem

The worktree mode (`--wt` flag) in `/02_execute` has a critical limitation due to how Claude Code's Bash tool works:

### Root Cause

**Claude Code Bash Tool Behavior**:
- Each Bash tool call starts in a **new shell session**
- The working directory (cwd) is **reset to project root** after each call
- Environment variables set in one call **do not persist** to the next call

### Example of the Problem

```bash
# Call 1: Create worktree and cd
WORKTREE_PATH="/path/to/worktree"
cd "$WORKTREE_PATH"
export WORKTREE_ROOT="$WORKTREE_PATH"
echo "In worktree: $(pwd)"  # Shows: /path/to/worktree

# Call 2: Read plan file (NEW SHELL SESSION)
# cwd is RESET to project root!
echo "Current dir: $(pwd)"  # Shows: /Users/chanho/claude-pilot (NOT worktree)
echo "WORKTREE_ROOT: ${WORKTREE_ROOT:-not set}"  # Shows: not set
```

### Why This Happens

1. **Shell Isolation**: Each Bash tool call is an isolated shell session
2. **Directory Reset**: Claude Code resets cwd to maintain predictable execution context
3. **No State Persistence**: Environment variables don't cross shell boundaries

## Current Implementation Status

### What Works
- ✅ Worktree creation via `git worktree add`
- ✅ Setting environment variables within a single bash call
- ✅ File operations using absolute paths

### What Doesn't Work
- ❌ `cd` command persisting across tool calls
- ❌ Environment variables (`WORKTREE_ROOT`) persisting across tool calls
- ❌ Relative paths based on assumed cwd

## Solutions

### Solution 1: Absolute Paths (RECOMMENDED)

**Use absolute paths for ALL file operations in worktree mode**

```bash
# Instead of:
cd "$WORKTREE_PATH"
ls .pilot/plan/

# Use:
ls "$WORKTREE_PATH/.pilot/plan/"
```

**Implementation**:
- Replace `$PROJECT_ROOT` with explicit worktree path
- Use `${WORKTREE_ROOT:-$PROJECT_ROOT}` pattern for conditional paths
- Store worktree path in plan file for reference

### Solution 2: Plan File Metadata

**Store worktree path in plan file**

```markdown
## Worktree Info
- Branch: wt/1234567890
- Worktree Path: /absolute/path/to/worktree
- Main Branch: main
```

**Read metadata back**:
```bash
WORKTREE_PATH="$(grep "^Worktree Path:" "$PLAN_PATH" | cut -d' ' -f3)"
```

### Solution 3: State File Tracking

**Store worktree path in continuation state**

```json
{
  "worktree_path": "/absolute/path/to/worktree",
  "worktree_branch": "wt/1234567890",
  "plan_file": "/absolute/path/to/worktree/.pilot/plan/in_progress/plan.md"
}
```

## Required Changes to /02_execute.md

### Change 1: Store Worktree Path Explicitly

After worktree creation (line 257):
```bash
# Store worktree path in a file for persistence
echo "$WORKTREE_PATH" > "$MAIN_PROJECT_ROOT/.pilot/worktree_active_path.txt"
```

### Change 2: Read Worktree Path Back

At start of each operation:
```bash
if [ -f "$MAIN_PROJECT_ROOT/.pilot/worktree_active_path.txt" ]; then
    WORKTREE_PATH="$(cat "$MAIN_PROJECT_ROOT/.pilot/worktree_active_path.txt")"
    WORKTREE_ROOT="$WORKTREE_PATH"
fi
```

### Change 3: Use Conditional Path Resolution

```bash
# Use worktree path if available, otherwise project root
PLAN_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"
PLAN_PATH="$(ls -1t "$PLAN_ROOT/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"
```

## Testing

### Test 1: Verify Worktree Path Persistence

```bash
# Create worktree
bash .claude/scripts/worktree-create.sh "wt/test" "main"
WT_PATH="/path/to/worktree"

# Store path
echo "$WT_PATH" > .pilot/worktree_active_path.txt

# Read back (in new shell)
RESTORED_PATH="$(cat .pilot/worktree_active_path.txt)"
[ "$RESTORED_PATH" = "$WT_PATH" ] && echo "✓ Path persistence works"
```

### Test 2: Verify Absolute Path Operations

```bash
# Use absolute paths
ls "$WT_PATH/.pilot/plan/"

# Should work without cd
test -f "$WT_PATH/.pilot/plan/in_progress/plan.md" && echo "✓ Absolute paths work"
```

### Test 3: Verify State File Location

```bash
# State file should be in worktree
STATE_FILE="$WT_PATH/.pilot/state/continuation.json"
test -f "$STATE_FILE" && echo "✓ State file in worktree"
```

## Recommendation

**Use Solution 1 (Absolute Paths) + Solution 2 (Plan File Metadata)**

This combination:
1. Works within Claude Code's constraints
2. Provides clear, explicit path handling
3. Maintains backward compatibility with standard mode
4. Easy to debug and verify

## Statusline Fix (v4.2.0)

**Problem**: Statusline didn't show plan counts when in worktree mode
**Root Cause**: `is_in_worktree()` function used `git rev-parse --show-superproject-working-tree` which fails intermittently

**Solution**: Fix worktree detection by checking for `.git` file instead of relying on git command output

```bash
# Old (unreliable):
is_in_worktree() {
    git rev-parse --is-inside-worktree >/dev/null 2>&1
}

# New (reliable):
is_in_worktree() {
    # Check if .git is a file (worktree marker) instead of a directory
    if [ -f ".git" ]; then
        # Verify it contains gitdir: pattern
        grep -q "^gitdir:" .git 2>/dev/null
        return $?
    fi
    return 1
}
```

**Statusline Enhancement**:
- Worktree-aware plan counting using `get_main_pilot_dir()`
- Shows main repo's plan counts when in worktree mode
- Format: `global_output | 📋 P:{pending} I:{in_progress}`

## Related Documentation

- **Worktree Setup**: @.claude/guides/worktree-setup.md
- **Execute Command**: @.claude/commands/02_execute.md
- **Close Command**: @.claude/commands/03_close.md
