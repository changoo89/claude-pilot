# Scripts Context

## Purpose

**Skill-Only Architecture**: Scripts are minimal automation adapters. Procedures documented in skills/ directory.
Following obra/superpowers philosophy: skills as the product, scripts as optional adapters.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `codex-sync.sh` | Codex CLI thin wrapper | 103 | GPT expert consultation adapter |
| `statusline.sh` | Plan state count display | 70 | Show draft/pending/in-progress counts |
| `cleanup.sh` | Dead code cleanup | 452 | ESLint/TypeScript-based cleanup |
| `worktree-create.sh` | Worktree creation | 120 | Initialize isolated worktree |

### hooks/ Directory

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `pre-commit.sh` | Pre-commit validation | 40 | JSON syntax, markdown link checks |

## Common Tasks

### Delegate to GPT Expert
- **Script**: @.claude/scripts/codex-sync.sh
- **Process**: Check Codex CLI → Initialize PATH → Construct prompt → Execute codex command
- **Modes**: `read-only` (advisory), `workspace-write` (implementation)

### Create Worktree
- **Script**: @.claude/scripts/worktree-create.sh
- **Process**: Parse arguments → Create unique worktree → Create Git worktree
- **Cleanup**: Worktree removed by `/03_close` after completion

### Display Status Line
- **Script**: @.claude/scripts/statusline.sh
- **Output**: Model info + plan counts (D:draft P:pending I:in-progress)
- **Usage**: Configured in `.claude/settings.json` statusLine field

## Patterns

### Self-Contained Scripts
All scripts set PROJECT_DIR internally without external dependencies:
```bash
if [[ -z "${PROJECT_DIR:-}" ]]; then
    if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
        PROJECT_DIR="$CLAUDE_PROJECT_DIR"
    else
        PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi
fi
```

### Graceful Fallback Pattern
All Codex integration must include graceful fallback:
```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0  # NOT an error, continue with Claude
fi
```

## Script Categories

- **Delegation**: codex-sync.sh
- **Worktree**: worktree-create.sh
- **Status Display**: statusline.sh
- **Cleanup**: cleanup.sh
- **Hooks**: pre-commit.sh

## Integration Points

### Command Integration
- `/02_execute`: codex-sync.sh, worktree-create.sh (with --wt flag)
- `/05_cleanup`: cleanup.sh

### Setup Integration
- `/pilot:setup`: Copies statusline.sh, configures settings.json

## Size Guidelines

**Target**: 100-150 lines per script
**Current state**: Average 100 lines (within target)

## See Also

**Delegation system**:
- @.claude/skills/gpt-delegation/SKILL.md - GPT delegation methodology

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command script usage
