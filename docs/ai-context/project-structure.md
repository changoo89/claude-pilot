# Project Structure Guide

> **Purpose**: Technology stack, directory layout, and key files
> **Last Updated**: 2026-01-21 (Updated: Skill-Only Worktree & Continuation Removal v4.4.0)

---

## Technology Stack

```yaml
Framework: Claude Code Plugin
Language: Markdown + JSON (no code runtime)
Package Manager: Claude Code Plugin System
Version: 4.3.0
Deployment: GitHub Marketplace (plugin distribution)
```

---

## Directory Layout

```
claude-pilot/
├── .claude-plugin/         # Plugin manifests
│   ├── marketplace.json    # Marketplace configuration
│   └── plugin.json         # Plugin metadata (version source of truth)
├── .github/                # GitHub Actions CI/CD (NEW v4.1.8)
│   ├── workflows/
│   │   └── release.yml     # Tag-triggered release workflow
│   └── scripts/
│       └── validate_versions.sh  # Version consistency validation
├── .gitattributes          # Git file attributes (LF line endings, executable bit enforcement for .sh files)
├── .claude/
│   ├── commands/           # Slash commands (11)
│   │   ├── CONTEXT.md      # Command folder context
│   │   ├── 000_pilot_setup.md  # Setup command (NEW v4.1.0)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan (with Step 1.5 extraction)
│   │   ├── 02_execute.md   # Execute with TDD
│   │   ├── 03_close.md     # Close & archive
│   │   ├── 04_fix.md       # Rapid bug fix workflow (NEW v4.2.0)
│   │   ├── 05_cleanup.md   # Dead code cleanup (NEW v4.3.1)
│   │   ├── 90_review.md    # Review code
│   │   ├── 91_document.md  # Update docs
│   │   ├── 92_init.md      # Initialize 3-Tier docs
│   │   └── 999_release.md  # Bump version + git tag + GitHub release (v4.1.1+)
│   ├── guides/             # Methodology guides (17)
│   │   ├── CONTEXT.md      # Guide folder context
│   │   ├── claude-code-standards.md  # Official Claude Code standards
│   │   ├── prp-framework.md          # Problem-Requirements-Plan
│   │   ├── prp-template.md           # PRP template
│   │   ├── gap-detection.md          # External service verification
│   │   ├── parallel-execution.md            # Parallel execution patterns
│   │   └── parallel-execution-REFERENCE.md  # Parallel execution deep reference (NEW 2026-01-17)
│   │   ├── 3tier-documentation.md    # Documentation system
│   │   ├── review-checklist.md       # Code review criteria
│   │   ├── test-environment.md       # Test framework detection
│   │   ├── test-plan-design.md       # Test plan methodology
│   │   ├── worktree-setup.md         # Worktree setup script
│   │   ├── requirements-tracking.md  # User Requirements Collection
│   │   ├── requirements-verification.md # Requirements Verification
│   │   ├── instruction-clarity.md    # LLM-readable instruction patterns
│   │   ├── intelligent-delegation.md # Intelligent Codex delegation (NEW v4.1.0)
│   │   └── todo-granularity.md       # Granular todo breakdown (NEW v4.2.0)
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   │   ├── prp-template.md            # PRP template
│   │   ├── gap-checklist.md
│   │   ├── CONTEXT-tier2.md.template
│   │   ├── CONTEXT-tier3.md.template
│   │   ├── feature-list.json         # Feature list template (NEW v4.1.0)
│   │   ├── init.sh                   # Init script template (NEW v4.1.0)
│   │   └── progress.md               # Progress tracking template (NEW v4.1.0)
│   ├── skills/             # Reusable skill modules (6)
│   │   ├── CONTEXT.md      # Skill folder context
│   │   ├── external/       # External skills (Vercel agent-skills)
│   │   │   └── vercel-agent-skills/  # Downloaded from GitHub
│   │   ├── documentation-best-practices/  # Documentation standards
│   │   ├── frontend-design/  # Frontend UI/UX design skill (NEW 2026-01-18)
│   │   │   ├── SKILL.md     # Design thinking framework, anti-patterns
│   │   │   ├── REFERENCE.md # Detailed design guidelines
│   │   │   └── examples/    # Example components (3 aesthetics)
│   │   ├── tdd/SKILL.md (+ REFERENCE.md)
│   │   ├── ralph-loop/SKILL.md (+ REFERENCE.md)
│   │   ├── vibe-coding/SKILL.md (+ REFERENCE.md)
│   │   └── git-master/SKILL.md (+ REFERENCE.md)
│   ├── agents/             # Specialized agent configs (8)
│   │   ├── CONTEXT.md      # Agent folder context
│   │   ├── explorer.md
│   │   ├── researcher.md
│   │   ├── coder.md
│   │   ├── tester.md
│   │   ├── validator.md
│   │   ├── plan-reviewer.md
│   │   ├── code-reviewer.md
│   │   └── documenter.md
│   ├── scripts/
│   │   ├── hooks/          # Git/workflow hooks (5) (UPDATED v4.3.0)
│   │   │   ├── quality-dispatch.sh  # O(1) dispatcher with caching (NEW)
│   │   │   ├── cache.sh             # Cache utilities (NEW)
│   │   │   ├── typecheck.sh         # TypeScript validation (optimized)
│   │   │   ├── lint.sh              # Multi-language lint (optimized)
│   │   │   └── branch-guard.sh      # Protected branch warnings
│   │   ├── codex-sync.sh   # GPT expert delegation
│   │   └── worktree-utils.sh  # Worktree utilities (lock, cleanup)
│   ├── hooks.json          # Hook definitions (NEW v4.1.0)
│   └── rules/              # Core rules
│       ├── core/workflow.md
│       ├── documentation/tier-rules.md
│       └── delegator/      # GPT delegation orchestration
│           ├── orchestration.md
│           ├── triggers.md
│           ├── intelligent-triggers.md  # Heuristic-based triggers (NEW v4.1.0)
│           ├── delegation-format.md     # Phase-specific templates (UPDATED v4.1.2)
│           ├── delegation-checklist.md  # Validation checklist (NEW v4.1.2)
│           ├── model-selection.md
│           ├── pattern-standard.md
│           ├── examples/                # Before/after examples (NEW v4.1.2)
│           │   ├── before-phase-detection.md
│           │   ├── after-phase-detection.md
│           │   ├── before-stateless.md
│           │   └── after-stateless.md
│           └── prompts/       # GPT expert prompts (5)
├── .pilot/                 # Plan management
│   ├── plan/
│   │   ├── pending/        # Awaiting confirmation
│   │   ├── in_progress/    # Currently executing
│   │   ├── done/           # Completed plans
│   │   └── active/         # Branch pointers
│   └── tests/              # Integration tests (v4.0.5)
│       ├── test_00_plan_delegation.test.sh
│       ├── test_01_confirm_delegation.test.sh
│       ├── test_91_document_delegation.test.sh
│       ├── test_graceful_fallback.test.sh
│       ├── test_no_delegation.test.sh
│       ├── test_codex_detection.test.sh    # Codex CLI detection tests (v4.1.0)
│       ├── test_path_init.test.sh          # PATH initialization tests (v4.1.0)
│       ├── test_debug_mode.test.sh         # DEBUG mode tests (v4.1.0)
│       ├── test_sc5_integration.test.sh    # Integration tests (NEW v4.2.0)
│       ├── test_github_workflow.sh         # GitHub Actions workflow tests (NEW v4.1.8)
│       ├── test_999_skip_gh.sh             # 999_release skip-gh tests (NEW v4.1.8)
│       ├── cleanup-auto.test.sh            # Auto-apply low-risk items (NEW v4.3.1)
│       ├── cleanup-confirm.test.sh         # Interactive confirmation for high-risk (NEW v4.3.1)
│       ├── cleanup-dryrun.test.sh          # Explicit dry-run mode (NEW v4.3.1)
│       ├── cleanup-apply.test.sh           # Force apply mode (NEW v4.3.1)
│       ├── cleanup-conflict.test.sh        # Both flags conflict (NEW v4.3.1)
│       ├── cleanup-verify.test.sh          # Verification after batch (NEW v4.3.1)
│       ├── cleanup-rollback.test.sh        # Rollback on failure (NEW v4.3.1)
│       ├── cleanup-preflight.test.sh       # Pre-flight safety check (NEW v4.3.1)
│       ├── cleanup-ci.test.sh              # Non-interactive default (NEW v4.3.1)
│       └── cleanup-ci-apply.test.sh        # Non-interactive with apply (NEW v4.3.1)
├── docs/                   # Project documentation
│   ├── ai-context/         # 3-Tier detailed docs
│   │   ├── system-integration.md
│   │   └── project-structure.md
│   ├── migration-guide.md  # Hooks performance migration guide (NEW v4.3.0)
│   ├── plan-gap-analysis-external-api-calls.md
│   └── slash-command-enhancement-examples.md
├── mcp.json                # Recommended MCP servers
├── CLAUDE.md               # Tier 1: Project documentation
├── README.md               # Project README
├── CHANGELOG.md            # Version history
```

---

## Key Files by Purpose

### Command Workflow

| File | Purpose | Lines | Agent Pattern |
|------|---------|-------|---------------|
| `.claude/commands/000_pilot_setup.md` | MCP server configuration with merge strategy, GitHub star prompt | ~150 | N/A (setup command) |
| `.claude/commands/00_plan.md` | Generate SPEC-First plan with PRP analysis, Phase Boundary Protection (Level 3) | 156 | **MANDATORY**: Parallel Explorer + Researcher (Step 0) |
| `.claude/commands/01_confirm.md` | Extract plan, create file, auto-review with Interactive Recovery | 318 | **MANDATORY**: Plan-Reviewer (Step 4) |
| `.claude/commands/02_execute.md` | Atomic plan move (Step 1), SC dependency analysis (Step 2.1), parallel Coder invocation (Step 2.2), implement with TDD + Ralph Loop | 456 | **MANDATORY**: SC Dependency Analysis (Step 2.1), Parallel Coders (Step 2.2), Auto-Delegation (Step 3.2), Parallel Verification (Step 3.5) |
| `.claude/commands/03_close.md` | Archive plan, commit changes | 247 | **MANDATORY**: Documenter (Step 5) |
| `.claude/commands/review.md` | Review code or plans with optional parallel multi-angle review | 376 | **MANDATORY**: Plan-Reviewer (single or parallel multi-angle for complex plans) |
| `.claude/commands/document.md` | Update documentation | 266 | **OPTIONAL**: Documenter |

### Documentation

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Tier 1: Project-level documentation (quick reference) |
| `docs/ai-context/system-integration.md` | Component interactions, workflows |
| `docs/ai-context/project-structure.md` | This file: tech stack, layout |
| `.claude/guides/3tier-documentation.md` | 3-Tier system guide |

### Configuration

| File | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Marketplace manifest |
| `.claude-plugin/plugin.json` | Plugin manifest (version source of truth) |
| `.claude/settings.json.example` | Optimized hooks configuration (Gate vs Validator split) (NEW v4.3.0) |
| `.claude/quality-profile.json.template` | Quality profile template (off/stop/strict modes) (NEW v4.3.0) |
| `.claude/settings.json` | Example MCP server configuration |
| `.claude/hooks.json` | Hook definitions (pre-commit, pre-push) |
| `.claude/scripts/codex-sync.sh` | GPT expert delegation with PATH initialization, multi-layered detection, reasoning effort configuration |
| `.gitattributes` | Git file attributes (LF line endings for .sh files, executable bit enforcement) |
| `mcp.json` | Recommended MCP servers |
| `.gitignore` | Git exclusions |

### Templates

| File | Purpose |
|------|---------|
| `.claude/templates/gap-checklist.md` | External service verification checklist |
| `.claude/templates/CONTEXT-tier2.md.template` | Component CONTEXT.md template |
| `.claude/templates/CONTEXT-tier3.md.template` | Feature CONTEXT.md template |

---

## /01_confirm Command Structure

### Updated with Step 1.5 (2026-01-14)

The `/01_confirm` command now includes **Step 1.5: Conversation Highlights Extraction** to capture implementation details from the `/00_plan` conversation.

### Command File

- **Location**: `.claude/commands/01_confirm.md`
- **Lines**: 247 (within 300-line limit for commands)
- **Sections**:
  1. Extract Plan from Conversation
  1.5. Conversation Highlights Extraction (NEW)
  2. Generate Plan File Name
  3. Create Plan File
  4. Auto-Review with Interactive Recovery

### Step 1.5 Highlights

Extracts three types of implementation patterns:

1. **Code Examples**: Fenced code blocks (```language) from conversation
2. **Syntax Patterns**: CLI commands, API invocation examples
3. **Architecture Diagrams**: ASCII art, Mermaid charts, flow diagrams

Output is marked with `> **FROM CONVERSATION:**` and added to plan under "Execution Context → Implementation Patterns" section.

---

## Plan File Structure

### Template Location

`.claude/commands/01_confirm.md` (Step 3.1)

### Sections

```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements
## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff)
### Explored Files
### Key Decisions Made
### Implementation Patterns (FROM CONVERSATION)  <-- Step 1.5 output
## External Service Integration [if applicable]
### API Calls Required
### New Endpoints to Create
### Environment Variables Required
### Error Handling Strategy
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
## Review History
## Execution Summary
```

---

## 3-Tier Documentation

### Overview

| Tier | Location | Purpose | Max Lines |
|------|----------|---------|-----------|
| **Tier 1** | `CLAUDE.md` | Project standards, architecture, workflows | 300 |
| **Tier 2** | `{component}/CONTEXT.md` | Component-level architecture | 200 |
| **Tier 3** | `{feature}/CONTEXT.md` | Feature-level implementation details | 150 |

### Tier 1 (CLAUDE.md)

- Quick reference for project standards
- Installation and common commands
- Development workflow overview
- Links to Tier 2/3 CONTEXT.md files

### Tier 2 (Component CONTEXT.md)

- Located in major folders (src/, lib/, components/)
- Component purpose and architecture
- Key files and patterns
- Integration points

### Tier 3 (Feature CONTEXT.md)

- Located in feature folders or deep nesting
- Implementation details and decisions
- Performance characteristics
- Code examples

### docs/ai-context/

When Tier 1 exceeds 300 lines, detailed sections move here:

- `system-integration.md`: Component interactions, workflows
- `project-structure.md`: Technology stack, directory layout
- `docs-overview.md`: Navigation for all CONTEXT.md files

---

## Skills and Agents

### Skills (Reusable Modules)

Located in `.claude/skills/{skill_name}/`:

**Progressive Disclosure Pattern** (v3.3.2+):
- `SKILL.md`: Quick reference (~50 lines, loaded every session)
- `REFERENCE.md`: Detailed documentation (400-700 lines, loaded on-demand via @import)

| Skill | Purpose |
|-------|---------|
| `documentation-best-practices` | Claude Code documentation standards (NEW) |
| `frontend-design` | Frontend UI/UX design thinking framework, anti-patterns, aesthetic guidelines (NEW 2026-01-18) |
| `tdd` | Test-driven development cycle |
| `ralph-loop` | Autonomous iteration until tests pass |
| `vibe-coding` | Code quality enforcement |
| `git-master` | Git operations and commits |

### Agents (Specialized Roles)

Located in `.claude/agents/{agent_name}.md`:

**YAML Format Requirements** (as of v3.2.0):
- `tools`: Comma-separated string (e.g., `tools: Read, Write, Edit`)
- `skills`: Comma-separated string (e.g., `skills: tdd, ralph-loop`)
- `instructions`: Body content after `---` (NOT in frontmatter field)

**Valid Format Example**:
```yaml
---
name: coder
description: TDD implementation agent
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
skills: tdd, ralph-loop, vibe-coding, git-master
---

You are the Coder Agent. Implement features using TDD...
```

**Model Allocation:**

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient for repetitive/structured tasks |
| **Sonnet** | coder, tester, plan-reviewer | Balance of quality and speed for complex tasks |
| **Opus** | code-reviewer | Deep reasoning for critical review (async bugs, memory leaks) |

**Agent Details:**

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| `explorer` | haiku | Glob, Grep, Read | Codebase exploration and analysis |
| `researcher` | haiku | WebSearch, WebFetch, query-docs | External documentation and API research |
| `coder` | sonnet | Read, Write, Edit, Bash | Implementation with TDD |
| `tester` | sonnet | Read, Write, Bash | Test writing and execution |
| `validator` | haiku | Bash, Read | Type check, lint, coverage verification |
| `plan-reviewer` | sonnet | Read, Glob, Grep | Plan analysis and gap detection |
| `code-reviewer` | opus | Read, Glob, Grep, Bash | Deep code review (async, memory, security) |
| `documenter` | haiku | Read, Write | Documentation synchronization |

---

## Hooks

### Location

`.claude/scripts/hooks/`

### Performance Optimization (v4.3.0)

**Dispatcher Pattern**: Single entry point with O(1) project type detection
- **P95 latency**: 20ms (target: <100ms)
- **Cache hit rate**: 100%
- **External process reduction**: 75-100%

**Gate vs Validator Separation**:
- **Gates** (PreToolUse): Safety checks that MUST block operations (e.g., branch-guard)
- **Validators** (Stop): Quality checks that can be deferred (e.g., typecheck, lint)

**Profile System**: User-configurable modes
- **off**: All validators disabled
- **stop**: Batch validation on session stop (default)
- **strict**: Per-operation validation (old behavior)

### Hook Scripts

| Script | Purpose | Optimized (v4.3.0) |
|--------|---------|-------------------|
| `quality-dispatch.sh` | O(1) dispatcher with caching | NEW |
| `cache.sh` | Cache utilities (hash-based invalidation) | NEW |
| `typecheck.sh` | TypeScript validation (`tsc --noEmit`) | Yes (early exit + cache) |
| `lint.sh` | ESLint/Pylint/gofmt validation | Yes (early exit + cache) |
| `branch-guard.sh` | Protected branch warnings | No (already fast) |

**Note**: Todo validation moved to `/03_close` command (skill-only architecture)

### Migration Guide

See `@docs/migration-guide.md` for detailed migration instructions.

---

## Statusline Feature (v3.3.4, v4.3.2)

### Overview

The statusline feature displays plan state counts in Claude Code's statusline using the format `📋 D:{n} P:{n} I:{n}` (Draft, Pending, In-Progress).

### Components

| File | Purpose | Updated |
|------|---------|---------|
| `.claude/scripts/statusline.sh` | Script that counts plans and formats output | v4.3.2 (added draft count) |
| `.claude/settings.json` | StatusLine configuration (command type) | - |
| `cli.py` | `--apply-statusline` flag for opt-in updates | - |
| `updater.py` | `apply_statusline()` function for safe settings merge | - |
| `config.py` | MANAGED_FILES entry for statusline.sh | - |

### Usage

**New Users**: Statusline automatically configured on `claude-pilot init`

**Existing Users**: Run `claude-pilot update --apply-statusline` to add statusline

### Statusline Script Behavior

1. **Input**: JSON via stdin with `workspace.current_dir`
2. **Count**: Files in `.pilot/plan/draft/`, `.pilot/plan/pending/`, `.pilot/plan/in_progress/` (excludes `.gitkeep`)
3. **Output**:
   - `📁 {dirname} | 📋 D:{n} P:{n} I:{n}` (always show all three states)
   - Example: `📁 claude-pilot | 📋 D:1 P:2 I:0`
4. **Fallbacks**:
   - Missing `jq`: Show directory only
   - Invalid JSON: Show directory only
   - Missing directory: Show directory only

### Version History

- **v4.3.2** (2026-01-20): Added draft count display (D:{n})
- **v3.3.4** (2026-01-15): Initial statusline with pending count (P:{n})

### Integration Points

```
Claude Code CLI
      │
      ▼ (stdin: JSON)
┌─────────────────────────────────┐
│   .claude/scripts/statusline.sh │
│   ─────────────────────────────│
│   1. Read JSON from stdin       │
│   2. Extract workspace.current_dir │
│   3. Count .pilot/plan/pending/ │
│   4. Format: 📁 dir | 📋 P:N   │
└─────────────────────────────────┘
      │
      ▼ (stdout: string)
Claude Code Statusline Display
```

### Update Flow

```
claude-pilot update --apply-statusline
      │
      ├─► Backup settings.json
      ├─► Read current settings
      ├─► Check if statusLine exists
      │   └─► Skip if already present
      ├─► Add statusLine configuration
      └─► Write atomically
```

---

## Version History

### v4.3.2 (2026-01-20)

**Plan Detection Fix and Statusline Enhancement**: Glob-safe plan detection and draft count display
- **Plan detection fix**: Fixed zsh glob failure in `/02_execute` when plan directories empty
  - Root cause: `ls -1t .../*.md` fails with "no matches found" in zsh when no files exist
  - Solution: Use `find` with `xargs` for portable empty-directory handling
  - Fixed locations: `/02_execute.md` (Line 128, 138), `worktree-utils.sh` (Line 19, 30)
  - Cross-shell compatibility: Works in both bash and zsh
- **Statusline enhancement**: Added draft plan count to statusline display
  - New format: `📋 D:{n} P:{n} I:{n}` (Draft, Pending, In-Progress)
  - Always show all three states for consistency
- **Test results**: 7 tests passing (100% pass rate)
- **Verification**: All 4 success criteria met (SC-1 through SC-4)

### v4.3.1 (2026-01-20)

**Dead Code Cleanup Command**: Auto-apply workflow with risk-based confirmation
- **Auto-apply default**: Low/Medium risk items deleted without confirmation (interactive TTY)
- **Risk-based confirmation**: High-risk items require user confirmation with 3 choices (Apply all, Skip, Review one-by-one)
- **Safe flags**: `--dry-run` for preview, `--apply` for force-apply (mutually exclusive)
- **Risk classification**: Low (tests), Medium (utils), High (components/routes)
- **Pre-flight safety**: Auto-block modified/staged files from deletion
- **Verification**: Project-specific commands after each batch (max 10 deletions) and at end
- **Rollback**: Automatic restore via git restore (tracked) and trash restore (untracked)
- **Non-interactive mode**: CI/non-TTY defaults to --dry-run behavior (exit 2 if changes needed)
- **Updated file**: `.claude/commands/05_cleanup.md` (complete rewrite, 465 lines)
- **New tests**: 10 test files covering all flag combinations and edge cases (52 assertions, 100% pass rate)
- **Verification**: All 13 success criteria met (SC-1 through SC-13)

### v4.3.0 (2026-01-19)

**Hooks Performance Optimization**: Dispatcher pattern with caching and profile system
- **Dispatcher pattern**: O(1) project type detection with P95 latency of 20ms
- **Smart caching**: Config hash-based cache invalidation prevents redundant checks
- **Gate vs Validator separation**: Safety checks (PreToolUse) vs quality checks (Stop)
- **Profile system**: User-configurable modes (off/stop/strict) for quality checks
- **New files**: `quality-dispatch.sh` (247 lines), `cache.sh` (256 lines), `settings.json.example` (60 lines), `quality-profile.json.template` (50 lines), `migration-guide.md` (889 lines)
- **Optimized files**: `typecheck.sh`, `lint.sh` (early exit + caching)
- **Performance impact**: 99.4-99.8% reduction in hook overhead (10-25s → 30-60ms for 100 edits)
- **Test results**: 7/8 test suites passing (87.5%), 100% cache hit rate, 75-100% external process reduction
- **New tests**: 8 test files for dispatcher, cache, debounce, profiles, backward compatibility
- **Critical fixes**: Race condition (flock), input validation (mode validation), cleanup handlers (trap)
- **Backward compatible**: Auto-detection for existing settings.json
- Verification: All 7 success criteria met (SC-1 through SC-7)

### v4.2.1 (2026-01-18)

**Frontend Design Skill**: Production-grade UI/UX design thinking framework
- **New skill**: `frontend-design/` with SKILL.md, REFERENCE.md, examples/
- **Design thinking**: Purpose, Tone, Constraints, Differentiation framework
- **Aesthetic guidelines**: Typography, Color & Theme, Motion, Spatial Composition
- **Anti-patterns**: "NEVER use" section to avoid generic AI slop (Inter, purple gradients)
- **Examples**: 3 example components (minimalist dashboard, warm landing, brutalist portfolio)
- **Updated files**: CLAUDE.md, README.md, CHANGELOG.md, project-structure.md
- Verification: All 6 success criteria met (SC-1 through SC-6)

### v4.1.2 (2026-01-18)

**GPT Delegation Prompt Improvements**: Phase-specific context and validation
- Enhanced 7-section format with Planning vs Implementation phase templates
- Updated Plan Reviewer prompt with automatic phase detection logic
- Enhanced orchestration guide with context engineering best practices
- New validation checklist (48 items) for delegation prompt quality
- New example files (4 before/after pairs) demonstrating improvements
- Updated files: `delegation-format.md`, `prompts/plan-reviewer.md`, `orchestration.md`
- New files: `delegation-checklist.md`, `examples/*.md` (4 files)
- Problem solved: GPT Plan Reviewer no longer checks file system during planning phase
- Verification: All 5 success criteria met (SC-1 through SC-5)

### v4.1.1 (2026-01-18)

- **Plugin Release Workflow**: New `/999_release` command for plugin versioning
  - Created: `.claude/commands/999_release.md` (415 lines)
  - Removed: `.claude/commands/999_publish.md` (obsolete PyPI workflow)
  - Features: Version bump (3-file sync), git tag, GitHub release
  - Arguments: `[patch|minor|major|x.y.z] [--skip-gh] [--dry-run] [--pre]`
  - Pre-flight checks: jq, git, remote, clean working tree
  - Auto-detection: Git remote and default branch
  - Graceful fallback: GitHub CLI optional (skip release if gh not installed)
  - Verification: All success criteria met (SC-1 through SC-6)

### v4.1.0 (2026-01-17)

- **Pure Plugin Migration**: Breaking change - PyPI distribution removed
  - Plugin manifests: `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`
  - Setup command: `.claude/commands/000_pilot_setup.md` (MCP merge + GitHub star)
  - Hooks configuration: `.claude/hooks.json`
  - Updated README: Plugin-only installation (3-line)
  - Updated CLAUDE.md: Plugin distribution references
  - Removed: `src/`, `pyproject.toml`, `install.sh`, `tests/`
  - Version bump: 4.0.5 → 4.1.0 (breaking change)
  - All functionality preserved (10 commands, 8 agents, 5 skills)

- **Intelligent Codex Delegation**: Context-aware, autonomous decision-making
  - Heuristic-based triggers (failure, ambiguity, complexity, risk, progress)
  - Description-based routing (Claude Code official pattern)
  - Agent self-assessment with confidence scoring (0.0-1.0)
  - Progressive escalation (delegate after 2nd failure, not first)
  - Long-running task templates (feature-list.json, init.sh, progress.md)
  - New files: `intelligent-triggers.md`, `intelligent-delegation.md`
  - Updated: Agent descriptions with "use proactively" phrase
  - Updated: `triggers.md` with hybrid approach (explicit + semantic + description)
  - Verification: All 7 success criteria met (SC-1 through SC-7)

- **Parallel Execution Improvement**: Enhanced parallel execution for independent tasks
  - SC dependency analysis algorithm (Step 2.1 in 02_execute.md)
  - Parallel Coder invocation for independent SCs (Step 2.2)
  - Optional parallel multi-angle review (Step 9.5 in 90_review.md)
  - Result integration pattern and partial failure handling
  - Todo management pattern for parallel groups
  - New file: `parallel-execution-REFERENCE.md` (deep reference)
  - Updated: `02_execute.md` (SC dependency analysis, parallel coders), `90_review.md` (parallel multi-angle review)
  - Updated: `codex-sync.sh` (PATH initialization, multi-layered command detection)
  - Updated documentation: `system-integration.md`, `project-structure.md`
  - Verification: All 7 success criteria met (SC-1 through SC-7)

### v4.0.5 (2026-01-17)

- **GPT Delegation Improvements**: Auto-delegation and performance optimization
  - Auto-delegation on CODER_BLOCKED: `/02_execute` now automatically delegates to GPT Architect when coder is blocked (no user prompt needed)
  - Reasoning effort optimization: Default changed from empty (xhigh) to "medium" for faster response times (1-2min vs 5+ minutes)
  - Graceful fallback: `codex-sync.sh` now checks for Codex CLI installation and gracefully falls back to Claude-only analysis if not installed
  - Environment variable configuration: Added `CODEX_REASONING_EFFORT` for per-task reasoning effort tuning
  - Updated files: `.claude/commands/02_execute.md`, `.claude/scripts/codex-sync.sh`, `.claude/rules/delegator/orchestration.md`
  - Updated documentation: `docs/ai-context/system-integration.md` with reasoning effort levels and usage examples
  - Verification: All 3 success criteria met (auto-delegation, response time, environment variable override)

### v4.0.4 (2026-01-17)

- **SSOT Assets Build Hook**: Single Source of Truth for Claude Code assets
  - Build-time asset generation via Hatchling hook (no committed templates mirror)
  - `AssetManifest` class for curated subset (include/exclude patterns)
  - Wheel contains only generated assets (`src/claude_pilot/assets/.claude/**`)
  - sdist contains `.claude/**` inputs for build hook
  - Conservative settings.json merge (never overwrite user settings)
  - Wheel content verification (required/forbidden paths)
- **New files**: `src/claude_pilot/assets.py`, `src/claude_pilot/build_hook.py`
- **New tests**: `tests/test_assets.py` (13 tests), `tests/test_build_hook.py` (8 tests)
- **Updated files**: `config.py` (templates → assets path), `pyproject.toml` (build hook config)
- **Worktree Close Flow Improvement**: Fixed worktree mode `/02_execute` and `/03_close` for multi-worktree concurrent execution
- **Absolute paths**: `create_worktree()` now returns absolute paths (no more relative paths breaking on cwd reset)
- **Enhanced metadata**: `add_worktree_metadata()` stores 5 fields (added Main Project, Lock File)
- **Dual-key storage**: Active pointers stored before cd to worktree (both main + worktree branch keys)
- **Context restoration**: `/03_close` reads context from plan file instead of relying on cwd
- **Force cleanup**: `cleanup_worktree()` supports --force option for dirty worktrees
- **Fixed parsing**: `read_worktree_metadata()` uses multi-line extraction (not grep -A1)
- **New tests**: `test_worktree_utils.py` with 8 tests covering worktree utilities
- **Updated files**: worktree-utils.sh, 02_execute.md, 03_close.md, test_worktree_utils.py
- **Verification**: All 8 success criteria met (SC-1 through SC-8)

### v4.2.0 (2026-01-18)

- **Plan Detection Fix**: Fixed intermittent "No plan found" errors in /02_execute
- **MANDATORY ACTION pattern**: Added explicit plan detection step with strong guard language
- **Step 1 restructure**: Plan Detection (MANDATORY FIRST ACTION) before any other work
- **Root cause addressed**: Claude reads markdown as prompt, not executable bash script
- **Guard condition**: "DO NOT say 'no plan found' without actually running these commands"
- **Updated files**: 02_execute.md (Step 1 added, Step 1.1 renamed from Step 1)
- **Verification**: All success criteria met (SC-1, SC-2, SC-3)

### v3.3.7 (2026-01-16)

- **Instruction Clarity Improvement**: Refactored command files for LLM readability
- **New guide**: instruction-clarity.md (271 lines) with clear conditional patterns
- **Pattern improvements**: Default Behavior First, Positive Framing, Separate Sections
- **Eliminated**: "DO NOT SKIP (unless...)" pattern from all command files
- **Reduced**: "unless" pattern to 0 occurrences in command files
- **Updated files**: 00_plan.md, 01_confirm.md, 02_execute.md, 03_close.md, 999_publish.md
- **Added**: 4 "Default Behavior" + "Exception" section pairs

### v3.3.6 (2026-01-16)

- **User Requirements Tracking & Verification**: Added UR collection to /00_plan, verification to /01_confirm
- **New guides**: requirements-tracking.md (192 lines), requirements-verification.md (254 lines)
- **Enhanced /00_plan**: Step 0 (User Requirements Collection) with verbatim recording
- **Enhanced /01_confirm**: Step 2.7 (Requirements Verification) with BLOCKING condition
- **Code review fixes**: File length reduction, nested checkboxes, step numbering normalized
- **External Skills Sync**: GitHub API integration for Vercel agent-skills
- **New flag**: `--skip-external-skills` for init/update commands
- **New functions**: sync_external_skills(), get_github_latest_sha(), download_github_tarball(), extract_skills_from_tarball()
- **New config**: EXTERNAL_SKILLS dict with Vercel agent-skills configuration
- **New tests**: 25 external skills tests (90% coverage for new code)
- **Security features**: Path traversal prevention, symlink rejection in tarball extraction

### v3.3.5 (2026-01-16)

- **Statusline Feature**: Added pending plan count display to Claude Code statusline
- **New script**: `.claude/scripts/statusline.sh` with jq parsing and error handling
- **Opt-in updates**: `claude-pilot update --apply-statusline` for existing users
- **Settings template**: Updated with statusLine configuration
- **Tests**: 21 statusline tests, 100% feature coverage
- **Vibe Coding**: apply_statusline() compliant (48 lines)

### v3.3.4 (2026-01-15)

- **Worktree Architecture Fix**: Critical fixes for parallel plan execution
- **Atomic lock mechanism**: `select_and_lock_pending()` prevents race conditions
- **Worktree cleanup**: Complete cleanup in `/03_close` with error trap
- **.gitignore handling**: Auto-add `.pilot/` on init/update
- **Type safety**: Added `src/claude_pilot/py.typed` for PEP 561 compliance
- **Lock lifecycle**: Lock held from selection until mv completes
- **TOCTOU fix**: Plan verification after lock acquisition

### v3.3.2 (2026-01-15)

- **SKILL.md Progressive Disclosure**: Restructured 4 SKILL.md files (400-500+ lines -> ~75 lines)
- **Created REFERENCE.md files**: 4 new reference files with detailed content (15-19KB each)
- **Token optimization**: ~85% reduction in SKILL.md token usage per session
- **Enhanced parallel execution**: Improved `/02_execute` Step 2.3 with MANDATORY ACTION headers
- **@import pattern**: All SKILL.md files now link to respective REFERENCE.md for on-demand loading

### v3.3.1 (2026-01-15)

- Fixed version triple-split issue (all 6 files now synced to 3.3.1)
- Added `scripts/sync-templates.sh` for pre-deploy template sync
- Added `scripts/verify-version-sync.sh` for version consistency checks
- Enhanced `/999_publish` with Step 0.5 (automatic templates sync)
- Synced 44 template files with current `.claude` content
- Updated `config.py` MANAGED_FILES (3 added, 3 removed)
- Templates folder now fully synchronized with development files

### v3.2.1 (2026-01-15)

- Enhanced `/00_plan` with Phase Boundary Protection (Level 3)
- Added MANDATORY AskUserQuestion at plan completion boundary
- Implemented pattern-based ambiguous confirmation handling (language-agnostic)
- Added multi-option confirmation template (4 options: A-D)
- Documented valid execution triggers to prevent misinterpretation
- **Restructured `/02_execute` Step 1** with atomic plan state transition
- **Added BLOCKING markers** and early exit guards for plan movement
- **Applied atomic pattern to Worktree mode** for consistency
- Updated system-integration.md with `/02_execute` workflow details

### v3.2.0 (Current)

- Fixed agent YAML format for Claude Code CLI recognition
- Converted tools/skills from YAML arrays to comma-separated strings
- Moved instructions content from frontmatter field to body after `---`
- Converted agent invocation patterns from descriptive to imperative
- Added MANDATORY ACTION sections with "YOU MUST invoke... NOW" commands
- Added EXECUTE IMMEDIATELY - DO NOT SKIP emphasis headers
- Added VERIFICATION wait instructions after agent invocations
- Enhanced parallel execution support with explicit "send in same message" instructions
- Improved agent delegation reliability through direct imperative language
- **Removed duplicate Guide files** (tdd-methodology, ralph-loop, vibe-coding)
- **Updated all references to use Skill files** instead of Guide files
- **Reduced token usage by ~35%** for `/02_execute` command

### v3.1.4

- Added parallel workflow optimization with 8 specialized agents
- New agents: researcher, tester, validator, plan-reviewer, code-reviewer
- Renamed reviewer.md → code-reviewer.md (model: haiku → opus)
- Updated commands with parallel execution patterns
- Added parallel-execution.md guide

### v3.1.0

- Added Skills and Agents for context isolation
- Enhanced /01_confirm with Step 1.5 (Conversation Highlights Extraction)
- Updated plan template to include Implementation Patterns
- Added docs/ai-context/ for detailed documentation

### v3.0.0

- 3-Tier Documentation System
- Enhanced Gap Detection Review
- Interactive Recovery for BLOCKING findings

---

## Related Documentation

- `CLAUDE.md` - Tier 1: Project documentation
- `.claude/commands/CONTEXT.md` - Command folder context
- `.claude/guides/CONTEXT.md` - Guide folder context
- `.claude/guides/claude-code-standards.md` - Official Claude Code standards
- `.claude/skills/CONTEXT.md` - Skill folder context
- `.claude/agents/CONTEXT.md` - Agent folder context
- `.claude/skills/documentation-best-practices/SKILL.md` - Documentation standards
- `.claude/guides/3tier-documentation.md` - 3-Tier system guide
- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan
- `.claude/skills/vibe-coding/SKILL.md` - Code quality standards (Quick Reference)
- `.claude/skills/vibe-coding/REFERENCE.md` - Code quality detailed guide
- `.claude/skills/tdd/SKILL.md` - Test-driven development (Quick Reference)
- `.claude/skills/tdd/REFERENCE.md` - TDD detailed guide
- `.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration (Quick Reference)
- `.claude/skills/ralph-loop/REFERENCE.md` - Ralph Loop detailed guide

---

**Last Updated**: 2026-01-19 (Two-Layer Documentation v4.2.0)
**Version**: 4.2.0

---

## Local Configuration (NEW v4.2.0)

### Two-Layer Documentation Strategy

claude-pilot uses a two-layer approach to separate plugin documentation from project-specific configuration:

**Plugin Layer (CLAUDE.md)**:
- Plugin architecture and features
- Distribution and installation
- Core feature documentation
- Plugin-specific components

**Project Layer (CLAUDE.local.md)**:
- Your project structure
- Your testing strategy
- Your quality standards
- Your MCP server configuration
- Your documentation conventions

### Creating CLAUDE.local.md

After plugin installation, run `/pilot:setup` to create `CLAUDE.local.md`:

**Template Location**: `.claude/templates/CLAUDE.local.template.md`

**What to Include**:
- Project structure and organization
- Testing framework and coverage targets
- Quality standards and pre-commit hooks
- MCP server configuration
- Documentation conventions
- Common use case examples

**Gitignore Behavior**: `CLAUDE.local.md` and `.claude/*.local.md` are automatically gitignored

**Full Guide**: See `@CLAUDE.md` → "Project Template" section
