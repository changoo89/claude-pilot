# Scripts Context

## Purpose

Utility scripts for Codex integration, state management, worktree operations, and Git hooks. Scripts provide automation for delegation, continuation tracking, atomic locks, and quality verification.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `codex-sync.sh` | Codex CLI integration for GPT delegation | 193 | Delegate to GPT experts with stateless prompts |
| `worktree-utils.sh` | Git worktree atomic lock management, glob-safe plan detection | 371 | Prevent race conditions in `/02_execute --wt`, select oldest pending plan |
| `worktree-create.sh` | Create worktree with atomic lock | 120 | Initialize isolated worktree for parallel execution |
| `statusline.sh` | Plan state count display (Draft/Pending/In-Progress) | 65 | Display plan counts in Claude Code statusline (v4.3.2: added draft count) |
| `hooks/check-todos.sh` | Pre-commit todo validation | 84 | Verify todos complete before commit |
| `hooks/branch-guard.sh` | Pre-commit branch validation | 51 | Prevent commits to protected branches |
| `hooks/lint.sh` | Pre-commit lint validation | 87 | Run project linter |
| `hooks/typecheck.sh` | Pre-commit type check validation | 42 | Run project type checker |
| `test-agent-names.sh` | Agent name verification | 16 | Validate agent frontmatter names |
| `simple_test.sh` | Simple test script | 2 | Test command execution |
| `simple_post_hook.sh` | Simple post-commit hook | 2 | Post-commit test |

**Total**: 11 files, 1,133 lines (average: 103 lines per script)

## Common Tasks

### Delegate to GPT Expert
- **Task**: Call GPT expert via Codex CLI
- **Script**: @.claude/scripts/codex-sync.sh
- **Output**: Expert consultation response
- **Process**:
  1. Check Codex CLI installation (graceful fallback)
  2. Source shell rc file to initialize PATH
  3. Multi-layer Codex detection (standard PATH, common paths)
  4. Construct delegation prompt with expert instructions
  5. Execute `codex` command with mode (read-only or workspace-write)
  6. Return response or fallback to Claude-only analysis

**Modes**:
- `read-only`: Advisory tasks (analysis, recommendations)
- `workspace-write`: Implementation tasks (making changes)

**Environment Variables**:
- `CODEX_MODEL`: gpt-5.2 (default)
- `CODEX_TIMEOUT`: 300s (default)
- `CODEX_REASONING_EFFORT`: medium (default: low/medium/high/xhigh)

### Manage Atomic Locks (Worktree Mode)
- **Task**: Prevent race conditions in parallel execution
- **Script**: @.claude/scripts/worktree-utils.sh
- **Output**: Atomic lock acquisition/release
- **Functions**:
  - `acquire_lock(plan_file)`: Create lock file with exclusive access
  - `release_lock(plan_file)`: Remove lock file
  - `is_locked(plan_file)`: Check lock status
  - `wait_for_lock(plan_file, timeout)`: Wait for lock release

**Usage in `/02_execute --wt`**:
```bash
acquire_lock "$PLAN_FILE"
# ... execute implementation ...
release_lock "$PLAN_FILE"
```

**Error Handling**:
- Trap on EXIT/INT/TERM to auto-release lock
- Prevents stale locks if command interrupted

### Create Worktree with Lock
- **Task**: Initialize isolated Git worktree for parallel execution
- **Script**: @.claude/scripts/worktree-create.sh
- **Output**: New worktree directory with atomic lock
- **Process**:
  1. Parse command-line arguments (plan file, branch name)
  2. Create unique worktree name from plan timestamp
  3. Create Git worktree: `git worktree add <path> -b <branch>`
  4. Acquire atomic lock via `worktree-utils.sh`
  5. Return worktree path for command execution

**Cleanup**: Worktree removed by `/03_close` after completion

### Run Pre-Commit Hooks
- **Task**: Verify code quality before commit
- **Scripts**: @.claude/scripts/hooks/
- **Output**: Pass/fail status for each hook
- **Hooks**:
  - `check-todos.sh`: Verify all todos complete
  - `branch-guard.sh`: Prevent commits to main/master
  - `lint.sh`: Run project linter (eslint, ruff, gofmt)
  - `typecheck.sh`: Run type checker (tsc, mypy)

**Configuration**: Hooks defined in `.claude/hooks.json`

### Display Git Status Line
- **Task**: Format repository status for prompts
- **Script**: @.claude/scripts/statusline.sh
- **Output**: Colored status line (branch, dirty status)
- **Process**:
  1. Get current branch name
  2. Check for uncommitted changes
  3. Format status line with colors
  4. Output: `main ✓` or `feature ✗`

**Usage**: Displayed in shell prompts via PS1 integration

## Patterns

### Graceful Fallback Pattern

**All Codex integration must include graceful fallback**:

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0  # NOT an error, continue with Claude
fi
```

**Key Points**:
- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

### Multi-Layer Detection Pattern

**Non-interactive shell PATH initialization**:

```bash
# Source shell rc file to populate PATH
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc 2>/dev/null
elif [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc 2>/dev/null
fi

# Layer 1: Standard PATH detection
command -v codex &> /dev/null && return 0

# Layer 2: Common installation paths
CODEX_PATHS=(
    "/opt/homebrew/bin"      # macOS ARM
    "/usr/local/bin"         # macOS Intel / Linux
    "/usr/bin"               # Linux system
    "$HOME/.local/bin"       # User local
    "$HOME/bin"              # User bin
)

for path in "${CODEX_PATHS[@]}"; do
    if [ -x "$path/codex" ]; then
        export PATH="$path:$PATH"
        return 0
    fi
done

return 1  # Codex not found
```

**Purpose**: Ensures Codex CLI found even in non-interactive shells (used by Claude Code).

### Atomic Lock Pattern

**Prevent race conditions with file-based locks**:

```bash
acquire_lock() {
    local plan_file="$1"
    local lock_file="${plan_file}.lock"

    # Check if already locked
    if [ -f "$lock_file" ]; then
        echo "Error: Plan is locked by another process"
        return 1
    fi

    # Create lock file with PID
    echo $$ > "$lock_file"
    echo "Lock acquired: $lock_file"
}

release_lock() {
    local plan_file="$1"
    local lock_file="${plan_file}.lock"

    rm -f "$lock_file"
    echo "Lock released: $lock_file"
}

# Trap to auto-release on exit/interrupt
trap 'release_lock "$PLAN_FILE"' EXIT INT TERM
```

**Usage**: `/02_execute --wt` (worktree mode) for parallel execution safety.

### Hook Validation Pattern

**Pre-commit hooks return pass/fail status**:

```bash
#!/bin/bash
# Example: check-todos.sh

PLAN_FILE=".pilot/plan/in_progress/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "No active plan - skipping todo check"
    exit 0  # Pass (no plan to check)
fi

# Extract incomplete todos
INCOMPLETE=$(grep -c "status: \"pending\"" "$PLAN_FILE")

if [ "$INCOMPLETE" -gt 0 ]; then
    echo "Error: $INCOMPLETE todos pending - complete before commit"
    exit 1  # Fail
fi

echo "All todos complete - commit allowed"
exit 0  # Pass
```

**Exit codes**: 0 (pass), 1 (fail)

### Environment Variable Configuration

**Codex behavior via environment variables**:

```bash
# Set model (default: gpt-5.2)
export CODEX_MODEL="gpt-5.2"

# Set timeout in seconds (default: 300s)
export CODEX_TIMEOUT="300"

# Set reasoning effort (default: medium)
export CODEX_REASONING_EFFORT="medium"  # low|medium|high|xhigh
```

**Reasoning Effort Levels**:
- `low`: Fast response (~30s), simple questions
- `medium`: Balanced (~1-2min), default for most tasks
- `high`: Deep analysis (~3-5min), complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough

## Script Categories

### Delegation Scripts
- `codex-sync.sh`: GPT expert consultation

### State Management Scripts
- `worktree-utils.sh`: Atomic lock management
- `worktree-create.sh`: Worktree initialization

### Status Display Scripts
- `statusline.sh`: Git status formatting

### Hook Scripts
- `check-todos.sh`: Todo validation
- `branch-guard.sh`: Branch protection
- `lint.sh`: Lint validation
- `typecheck.sh`: Type check validation

### Test Scripts
- `test-agent-names.sh`: Agent name verification
- `simple_test.sh`: Simple test execution
- `simple_post_hook.sh`: Post-commit test

## File Organization

### Naming Convention
- **Utility scripts**: `{name}.sh` (kebab-case)
- **Hook scripts**: `hooks/{name}.sh`
- **Test scripts**: `test-{name}.sh` or `{name}_test.sh`

### Shebang Standard
All scripts must use:
```bash
#!/bin/bash
# or
#!/bin/bash -e
```

**`-e` flag**: Exit immediately if any command fails (error handling).

### Permission Standard
All scripts must be executable:
```bash
chmod +x .claude/scripts/*.sh
chmod +x .claude/scripts/hooks/*.sh
```

**Setup**: `/pilot:setup` command sets executable permissions.

## Size Guidelines

**Target**: 100-150 lines per script

**Current state**: Average 103 lines (within target)

**Exceptions**:
- `worktree-utils.sh` (371 lines): Comprehensive lock management
- `codex-sync.sh` (193 lines): Multi-layer detection + graceful fallback

**When to split**:
- If script exceeds 200 lines
- Extract functions to separate library files
- Use `source` to include shared functions

## Integration Points

### Command Integration

**`/02_execute`**:
- `codex-sync.sh`: GPT escalation (Step 3.7)
- `worktree-create.sh`: Worktree initialization (with `--wt` flag)
- `worktree-utils.sh`: Atomic lock management

**`/03_close`**:
- `worktree-utils.sh`: Lock release + worktree cleanup

### Hook Integration

**Pre-commit hooks** (`.claude/hooks.json`):
```json
{
  "pre-commit": [
    ".claude/scripts/hooks/check-todos.sh",
    ".claude/scripts/hooks/branch-guard.sh",
    ".claude/scripts/hooks/lint.sh",
    ".claude/scripts/hooks/typecheck.sh"
  ]
}
```

**Trigger**: Git commits automatically run hooks before allowing commit.

### Shell Integration

**`statusline.sh`** in PS1 prompt:
```bash
# Add to ~/.bashrc or ~/.zshrc
update_prompt() {
    STATUS=$(.claude/scripts/statusline.sh)
    export PS1="\u@\h:\w [$STATUS]\$ "
}

PROMPT_COMMAND=update_prompt
```

## Error Handling

### Trap Pattern

**Auto-cleanup on interrupt**:
```bash
# Trap EXIT, INT, TERM signals
trap 'cleanup_function' EXIT INT TERM

cleanup_function() {
    echo "Cleaning up..."
    release_lock "$LOCK_FILE"
    exit 0
}
```

**Usage**: Prevents stale locks and partial cleanup.

### Exit Code Pattern

**Standard exit codes**:
- `0`: Success
- `1`: Generic error
- `2`: Misuse of shell command
- `126`: Command invoked cannot execute
- `127`: Command not found
- `130`: Script terminated by Ctrl+C (SIGINT)

**Example**:
```bash
if ! command -v codex &> /dev/null; then
    echo "Error: Codex CLI not found"
    exit 1  # Generic error
fi
```

## See Also

**Delegation system**:
- @.claude/rules/delegator/orchestration.md - Delegation orchestration
- @.claude/rules/delegator/triggers.md - When to delegate

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command script usage

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent script integration

**Documentation standards**:
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
