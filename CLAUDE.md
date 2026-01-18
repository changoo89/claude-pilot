# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-18
> **Version**: 4.1.1

---

## Quick Start

### Installation (3-Line)

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup (MANDATORY - fixes hook permissions)
/pilot:setup
```

> **⚠️ CRITICAL**: `/pilot:setup` is **mandatory** after installation to ensure hook scripts have correct executable permissions. Without this, you may encounter "Permission denied" errors when hooks run.

### Workflow Commands

| Task | Command | Description |
|------|---------|-------------|
| Plan | `/00_plan "task"` | Generate SPEC-First plan |
| Confirm | `/01_confirm` | Review plan + requirements verification |
| Execute | `/02_execute` | Implement with TDD (parallel SC execution) |
| Continue | `/00_continue` | Resume work from continuation state |
| Review | `/90_review` | Multi-angle code review (parallel optional) |
| Document | `/91_document` | Auto-sync documentation |
| Close | `/03_close` | Archive and commit |
| Setup | `/pilot:setup` | Configure MCP servers |
| Release | `/999_release [patch|minor|major]` | Bump version, git tag, GitHub release |

### Development Workflow

1. **SPEC-First**: What/Why/How/Success Criteria/Constraints
2. **TDD Cycle**: Red (failing test) → Green (minimal code) → Refactor (clean up)
3. **Ralph Loop**: Iterate until tests pass, coverage ≥80%, type-check clean, lint clean
4. **Quality Gates**: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3 levels

---

## Project Structure

```
project-root/
├── .claude-plugin/         # Plugin manifests
│   ├── marketplace.json    # Marketplace configuration
│   └── plugin.json         # Plugin metadata (version)
├── .claude/
│   ├── commands/           # Slash commands (11)
│   ├── guides/             # Methodology guides (17)
│   ├── skills/             # TDD, Ralph Loop, Vibe Coding, Git Master
│   ├── agents/             # Specialized agent configs (8)
│   ├── scripts/hooks/      # Type check, lint, todos, branch
│   ├── scripts/            # State management, Codex delegation
│   └── hooks.json          # Hook definitions
├── .pilot/
│   ├── plan/               # Plan management (pending/in_progress/done)
│   ├── state/              # Continuation state (NEW v4.2.0)
│   ├── scripts/            # State management scripts (NEW v4.2.0)
│   └── tests/              # Integration tests
├── docs/                   # Project documentation
│   └── ai-context/         # 3-Tier detailed docs
├── mcp.json                # Recommended MCP servers
├── CLAUDE.md               # This file (Tier 1: Project standards)
├── README.md               # Project README
├── CHANGELOG.md            # Version history
└── MIGRATION.md            # PyPI to plugin migration guide
```

**See**: `docs/ai-context/project-structure.md` for detailed directory layout.

---

## Plugin Distribution (v4.1.0)

**Pure Plugin Architecture**: No Python dependency, native Claude Code integration

**Installation**:
```bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup
```

**Updates**: `/plugin update claude-pilot`

**Version Source**: `.claude-plugin/plugin.json` (single source of truth)

**Migration**: See `MIGRATION.md` for PyPI to plugin migration guide

---

## Codex Integration (v4.1.0)

**Intelligent GPT Delegation**: Context-aware, autonomous delegation via `codex-sync.sh` for high-difficulty analysis.

### Delegation Triggers

**Explicit Triggers** (Keyword-Based):
- User explicitly requests: "ask GPT", "review architecture"

**Semantic Triggers** (Heuristic-Based):
- **Failure-based**: Agent fails 2+ times on same task
- **Ambiguity**: Vague requirements, no success criteria
- **Complexity**: 10+ success criteria, deep dependencies
- **Risk**: Auth/credential keywords, security-sensitive code
- **Progress stagnation**: No meaningful progress in N iterations

**Description-Based** (Claude Code Official):
- Agent descriptions with "use proactively" phrase
- Semantic task matching by Claude Code

### GPT Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** (progressive escalation) |
| Coder blocked (automatic) | **Architect** (self-assessment) |

**Configuration**:
- Default reasoning effort: `medium` (1-2min response)
- Override: `export CODEX_REASONING_EFFORT="low|medium|high|xhigh"`
- Graceful fallback: Claude-only analysis if Codex CLI not installed

**Full guide**: `.claude/guides/intelligent-delegation.md`

---

## Sisyphus Continuation System (v4.2.0)

**Intelligent Agent Continuation**: Agents persist work across sessions and continue until all todos complete.

### Overview

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

### Commands

| Command | Purpose |
|---------|---------|
| `/00_continue` | Resume work from continuation state |
| `/02_execute` | Creates/resumes continuation state automatically |
| `/03_close` | Verifies all todos complete before closing |

### Configuration

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

### State File Format

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

### Workflow

1. **Plan**: `/00_plan "task"` → Generates granular todos (≤15 min each)
2. **Execute**: `/02_execute` → Creates continuation state, starts work
3. **Continue**: Agent continues automatically until:
   - All todos complete, OR
   - Max iterations reached (7), OR
   - User interrupts (`/cancel`, `/stop`)
4. **Resume**: `/00_continue` → If session interrupted
5. **Close**: `/03_close` → Verifies all todos complete

**Full guide**: `.claude/guides/continuation-system.md`
**Todo granularity**: `.claude/guides/todo-granularity.md`

---

## CI/CD Integration

**GitHub Actions Workflow**: Automated release publishing on git tag push

### Hybrid Release Model

The release process uses a hybrid approach combining local preparation with CI/CD automation:

1. **Local Phase** (`/999_release`):
   - Bumps version across all files (plugin.json, marketplace.json, .pilot-version)
   - Generates CHANGELOG entry from git commits
   - Creates git tag (vX.Y.Z)
   - Skips GitHub release creation by default (`--skip-gh`)

2. **CI/CD Phase** (GitHub Actions):
   - Triggered on git tag push (`v*` pattern)
   - Validates version consistency across all files
   - Extracts release notes from CHANGELOG
   - Creates GitHub Release with extracted notes

### Workflow Configuration

**File**: `.github/workflows/release.yml`

**Trigger**: Git tag push matching `v*` pattern

**Validation Checks**:
```bash
# CI validates these match:
- Git tag version (vX.Y.Z)
- plugin.json version
- marketplace.json version
- .pilot-version
```

**Release Notes**: Automatically extracted from CHANGELOG.md section matching tag version

### Usage Examples

**Standard Release** (uses CI/CD):
```bash
/999_release minor          # Bump version, create tag locally
git push origin main --tags  # Trigger CI/CD to create release
```

**Local Release** (skip CI/CD):
```bash
/999_release patch --create-gh  # Create release locally
```

**Verification**:
```bash
# Check CI/CD run status
gh run list --workflow=release.yml

# View specific run
gh run view <run-id>
```

### Benefits

**Free Tier Benefits**:
- No API rate limits (GitHub Actions uses internal API)
- No authentication setup required
- Runs on GitHub's infrastructure (free for public repos)
- Consistent release formatting via CHANGELOG extraction

**Version Safety**:
- CI validates version consistency before creating release
- Prevents releases with mismatched versions
- Fails fast with clear error messages

### Troubleshooting

**Version Mismatch Error**:
```
Error: Tag version (4.1.7) does not match plugin.json version (4.1.6)
```
**Solution**: Re-run `/999_release` to ensure all versions are synchronized

**Missing CHANGELOG Entry**:
```
Release notes section not found for version 4.1.7
```
**Solution**: Manually add CHANGELOG entry or ensure commit messages are formatted for auto-generation

**CI/CD Not Triggered**:
```
git push origin main --tags  # No workflow run
```
**Solution**: Verify tag format matches `v*` pattern (e.g., `v4.1.7`, not `4.1.7`)

**Workflow Configuration**:
```yaml
# .github/workflows/release.yml
on:
  push:
    tags:
      - 'v*'  # Triggers on v1.0.0, v2.3.4, etc.
```

**Full guide**: `.claude/commands/999_release.md`

---

## Testing & Quality

| Scope | Target | Priority |
|-------|--------|----------|
| Overall | 80% | Required |
| Core Modules | 90%+ | Required |
| UI Components | 70%+ | Nice to have |

**Commands**: Project-specific test commands (depends on language/framework)

**Hooks**: Pre-commit type check, lint validation (`.claude/hooks.json`)

---

## Documentation System

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` (this file) - Project standards
- **Tier 2**: `docs/ai-context/*.md` - System integration
- **Tier 3**: `{component}/CONTEXT.md` - Component-level architecture

**Key Files**: `system-integration.md`, `project-structure.md`, `docs-overview.md`

---

## Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Parallel Execution**: Planning (Explorer + Researcher), Execution (parallel Coder agents per SC), Verification (Tester + Validator + Code-Reviewer), Review (optional parallel multi-angle)

**See**: `.claude/guides/parallel-execution.md`, `.claude/guides/parallel-execution-REFERENCE.md`, `.claude/guides/intelligent-delegation.md`

---

## MCP Servers

**Recommended**: context7 (docs), serena (code ops), grep-app (search), sequential-thinking (reasoning), codex (GPT delegation)

---

## Pre-Commit Checklist

- [ ] All tests pass (project-specific)
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean (project-specific)
- [ ] Lint clean (project-specific)
- [ ] Documentation updated
- [ ] No secrets included

---

## Related Documentation

- **System Integration**: `docs/ai-context/system-integration.md` - CLI workflow, external skills, Codex
- **Project Structure**: `docs/ai-context/project-structure.md` - Directory layout, key files
- **Documentation Overview**: `docs/ai-context/docs-overview.md` - Complete documentation navigation
- **Migration Guide**: `MIGRATION.md` - PyPI to plugin migration (v4.0.5 → v4.1.0)
- **Continuation System**: `.claude/guides/continuation-system.md` - Sisyphus agent continuation
- **Todo Granularity**: `.claude/guides/todo-granularity.md` - Granular todo breakdown (≤15 min)
- **3-Tier System**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)

---

**Template Version**: claude-pilot 4.2.0 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
