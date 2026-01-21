# Scripts Context

## Purpose

**Skill-Only Architecture**: Scripts are minimal automation adapters. Procedures documented in skills/ directory.
Following obra/superpowers philosophy: skills as the product, scripts as optional adapters.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `codex-sync.sh` | Codex CLI thin wrapper | 103 | GPT expert consultation adapter |
| `statusline.sh` | Plan state count display | 76 | Show draft/pending/in-progress counts |
| `cleanup.sh` | Dead code cleanup | 452 | ESLint/TypeScript-based cleanup |
| `worktree-utils.sh` | Worktree utilities | 372 | Plan detection, metadata parsing |

### lib/ Directory (Safety-Critical Adapters)

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `worktree-lock.sh` | Atomic lock management | 74 | Prevent race conditions |
| `worktree-create.sh` | Worktree creation | 120 | Initialize isolated worktree |

### hooks/ Directory (Opt-In Quality Gates)

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `branch-guard.sh` | Pre-commit branch validation | 51 | Prevent commits to protected branches |
| `lint.sh` | Pre-commit lint validation | 87 | Run project linter |
| `typecheck.sh` | Pre-commit type check validation | 42 | Run project type checker |

## Common Tasks

### Delegate to GPT Expert
- **Script**: @.claude/scripts/codex-sync.sh
- **Process**: Check Codex CLI → Initialize PATH → Construct prompt → Execute codex command
- **Modes**: `read-only` (advisory), `workspace-write` (implementation)

### Manage Atomic Locks (Worktree Mode)
- **Script**: @.claude/scripts/worktree-utils.sh
- **Functions**: acquire_lock(), release_lock(), is_locked(), wait_for_lock()
- **Usage**: `/02_execute --wt` for parallel execution safety

### Create Worktree with Lock
- **Script**: @.claude/scripts/worktree-create.sh
- **Process**: Parse arguments → Create unique worktree → Create Git worktree → Acquire lock
- **Cleanup**: Worktree removed by `/03_close` after completion

### Run Pre-Commit Hooks
- **Scripts**: @.claude/scripts/hooks/
- **Hooks**: branch-guard.sh, lint.sh, typecheck.sh
- **Configuration**: Hooks defined in `.claude/hooks.json`

### Display Git Status Line
- **Script**: @.claude/scripts/statusline.sh
- **Output**: Colored status line (branch, dirty status)
- **Usage**: Displayed in shell prompts via PS1 integration

## Patterns

### Graceful Fallback Pattern
All Codex integration must include graceful fallback:
```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0  # NOT an error, continue with Claude
fi
```

### Multi-Layer Detection Pattern
Non-interactive shell PATH initialization for Codex CLI detection across standard paths.

### Atomic Lock Pattern
Prevent race conditions with file-based locks using acquire_lock/release_lock with trap on EXIT/INT/TERM.

### Hook Validation Pattern
Pre-commit hooks return pass/fail status with exit codes: 0 (pass), 1 (fail).

## Script Categories

- **Delegation**: codex-sync.sh
- **State Management**: worktree-utils.sh, worktree-create.sh
- **Status Display**: statusline.sh
- **Hooks**: branch-guard.sh, lint.sh, typecheck.sh

## Integration Points

### Command Integration
- `/02_execute`: codex-sync.sh, worktree-create.sh, worktree-utils.sh
- `/03_close`: worktree-utils.sh (lock release + cleanup)

### Hook Integration
Pre-commit hooks defined in `.claude/settings.json` trigger automatically on Git commits.

## Size Guidelines

**Target**: 100-150 lines per script
**Current state**: Average 103 lines (within target)

## See Also

**Delegation system**:
- @.claude/skills/gpt-delegation/SKILL.md - GPT delegation methodology

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command script usage

**Documentation standards**:
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation standards
