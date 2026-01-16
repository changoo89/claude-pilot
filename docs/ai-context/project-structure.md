# Project Structure Guide

> **Purpose**: Technology stack, directory layout, and key files
> **Last Updated**: 2026-01-16 (Updated: external skills sync)

---

## Technology Stack

```yaml
Framework: Python CLI Tool
Language: Python 3.10+
Package Manager: Poetry/pip
Version: 3.3.1
Deployment: PyPI package distribution
```

---

## Directory Layout

```
claude-pilot/
├── .claude/
│   ├── commands/           # Slash commands (6)
│   │   ├── CONTEXT.md      # Command folder context (NEW)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan (with Step 1.5 extraction)
│   │   ├── 02_execute.md   # Execute with TDD
│   │   ├── 03_close.md     # Close & archive
│   │   ├── 90_review.md    # Review code
│   │   ├── 91_document.md  # Update docs
│   │   ├── 92_init.md      # Initialize 3-Tier docs
│   │   └── 999_publish.md  # Publish to npm
│   ├── guides/             # Methodology guides (10)
│   │   ├── CONTEXT.md      # Guide folder context (NEW)
│   │   ├── claude-code-standards.md  # Official Claude Code standards (NEW)
│   │   ├── prp-framework.md          # Problem-Requirements-Plan
│   │   ├── gap-detection.md          # External service verification
│   │   ├── parallel-execution.md     # Parallel execution patterns
│   │   ├── 3tier-documentation.md    # Documentation system
│   │   ├── review-checklist.md       # Code review criteria
│   │   ├── test-environment.md       # Test framework detection
│   │   ├── requirements-tracking.md  # User Requirements Collection (NEW)
│   │   ├── requirements-verification.md # Requirements Verification (NEW)
│   │   └── instruction-clarity.md    # LLM-readable instruction patterns (NEW)
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   │   ├── gap-checklist.md
│   │   ├── CONTEXT-tier2.md.template
│   │   └── CONTEXT-tier3.md.template
│   ├── skills/             # Reusable skill modules (5)
│   │   ├── CONTEXT.md      # Skill folder context (NEW)
│   │   ├── external/       # External skills (Vercel agent-skills) (NEW)
│   │   │   └── vercel-agent-skills/  # Downloaded from GitHub
│   │   ├── documentation-best-practices/  # Documentation standards (NEW)
│   │   ├── tdd/SKILL.md (+ REFERENCE.md)
│   │   ├── ralph-loop/SKILL.md (+ REFERENCE.md)
│   │   ├── vibe-coding/SKILL.md (+ REFERENCE.md)
│   │   └── git-master/SKILL.md (+ REFERENCE.md)
│   ├── agents/             # Specialized agent configs (8)
│   │   ├── CONTEXT.md      # Agent folder context (NEW)
│   │   ├── explorer.md
│   │   ├── researcher.md
│   │   ├── coder.md
│   │   ├── tester.md
│   │   ├── validator.md
│   │   ├── plan-reviewer.md
│   │   ├── code-reviewer.md
│   │   └── documenter.md
│   ├── scripts/
│   │   ├── hooks/          # Git/workflow hooks (4)
│   │   │   ├── typecheck.sh
│   │   │   ├── lint.sh
│   │   │   ├── check-todos.sh
│   │   │   └── branch-guard.sh
│   │   └── worktree-utils.sh  # Worktree utilities (lock, cleanup)
│   └── rules/              # Core rules
│       ├── core/workflow.md
│       └── documentation/tier-rules.md
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
├── docs/                   # Project documentation
│   ├── ai-context/         # 3-Tier detailed docs
│   │   ├── system-integration.md
│   │   └── project-structure.md
│   ├── plan-gap-analysis-external-api-calls.md
│   └── slash-command-enhancement-examples.md
├── scripts/                # Sync and build scripts
│   ├── sync-templates.sh   # Pre-deploy templates sync
│   └── verify-version-sync.sh  # Version consistency check
├── src/                    # Source code
│   └── claude_pilot/       # Main package
│       ├── py.typed        # PEP 561 type marker (NEW)
│       ├── templates/      # Deployment templates (synced)
│       │   └── .claude/
│       │       ├── scripts/
│       │       │   └── statusline.sh  # Statusline script (NEW)
│       │       ├── settings.json      # StatusLine config (UPDATED)
│       │       └── rules/
│       │           └── delegator/     # Codex delegation orchestration (NEW)
│       │               ├── delegation-format.md
│       │               ├── model-selection.md
│       │               ├── orchestration.md
│       │               ├── triggers.md
│       │               └── prompts/    # GPT expert prompts (NEW)
│       │                   ├── architect.md
│       │                   ├── code-reviewer.md
│       │                   ├── plan-reviewer.md
│       │                   ├── scope-analyst.md
│       │                   └── security-analyst.md
│       ├── cli.py          # CLI with --skip-external-skills flag (UPDATED)
│       ├── codex.py        # Codex CLI detection, auth check, MCP setup (NEW)
│       ├── config.py       # EXTERNAL_SKILLS config (UPDATED)
│       ├── initializer.py  # Init with external skills + Codex sync (UPDATED)
│       └── updater.py      # External skills + Codex sync functions (UPDATED)
├── tests/                  # Test files
├── CLAUDE.md               # Tier 1: Project documentation
├── README.md               # Project README
├── pyproject.toml          # Package configuration
└── CHANGELOG.md            # Version history
```

---

## Key Files by Purpose

### Command Workflow

| File | Purpose | Agent Pattern |
|------|---------|---------------|
| `.claude/commands/00_plan.md` | Generate SPEC-First plan with PRP analysis, Phase Boundary Protection (Level 3) | **MANDATORY**: Parallel Explorer + Researcher (Step 0) |
| `.claude/commands/01_confirm.md` | Extract plan, create file, auto-review with Interactive Recovery | **MANDATORY**: Plan-Reviewer (Step 4) |
| `.claude/commands/02_execute.md` | Atomic plan move (Step 1), implement with TDD + Ralph Loop | **MANDATORY**: Parallel Coders (Step 2.3), Parallel Verification (Step 2.4), Coder Delegation (Step 3) |
| `.claude/commands/03_close.md` | Archive plan, commit changes | **MANDATORY**: Documenter (Step 5) |
| `.claude/commands/90_review.md` | Review code or plans | **MANDATORY**: Plan-Reviewer (single or parallel) |
| `.claude/commands/91_document.md` | Update documentation | **OPTIONAL**: Documenter |

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
| `.claude/settings.json` | MCP server configuration |
| `package.json` | npm dependencies, scripts, version |
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
- **Lines**: 247 (slightly above 200-line Vibe Coding limit, accepted)
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
- `SKILL.md`: Quick reference (~75 lines, loaded every session)
- `REFERENCE.md`: Detailed documentation (400-700 lines, loaded on-demand via @import)

| Skill | Purpose |
|-------|---------|
| `documentation-best-practices` | Claude Code documentation standards (NEW) |
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

### Hook Types

| Hook | Trigger | Purpose |
|------|---------|---------|
| PreToolUse | Before file edits | Type check, lint validation |
| PostToolUse | After file edits | Type check, lint validation |
| Stop | At command end | TODO completion, Ralph Loop enforcement |

### Hook Scripts

- `typecheck.sh`: TypeScript validation (`tsc --noEmit`)
- `lint.sh`: ESLint/Pylint/gofmt validation
- `check-todos.sh`: Ralph Loop continuation enforcement
- `branch-guard.sh`: Protected branch warnings

---

## Statusline Feature (v3.3.4)

### Overview

The statusline feature displays pending plan count in Claude Code's statusline using the format `📋 P:{n}`.

### Components

| File | Purpose |
|------|---------|
| `.claude/scripts/statusline.sh` | Script that counts pending plans and formats output |
| `.claude/settings.json` | StatusLine configuration (command type) |
| `cli.py` | `--apply-statusline` flag for opt-in updates |
| `updater.py` | `apply_statusline()` function for safe settings merge |
| `config.py` | MANAGED_FILES entry for statusline.sh |

### Usage

**New Users**: Statusline automatically configured on `claude-pilot init`

**Existing Users**: Run `claude-pilot update --apply-statusline` to add statusline

### Statusline Script Behavior

1. **Input**: JSON via stdin with `workspace.current_dir`
2. **Count**: Files in `.pilot/plan/pending/` (excludes `.gitkeep`)
3. **Output**:
   - `📁 {dirname} | 📋 P:{n}` when pending > 0
   - `📁 {dirname}` when pending = 0
4. **Fallbacks**:
   - Missing `jq`: Show directory only
   - Invalid JSON: Show directory only
   - Missing directory: Show directory only

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

### v3.4.0 (2026-01-16)

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
- `.claude/commands/CONTEXT.md` - Command folder context (NEW)
- `.claude/guides/CONTEXT.md` - Guide folder context (NEW)
- `.claude/guides/claude-code-standards.md` - Official Claude Code standards (NEW)
- `.claude/skills/CONTEXT.md` - Skill folder context (NEW)
- `.claude/agents/CONTEXT.md` - Agent folder context (NEW)
- `src/claude_pilot/CONTEXT.md` - Core package architecture (NEW)
- `.claude/skills/documentation-best-practices/SKILL.md` - Documentation standards (NEW)
- `.claude/guides/3tier-documentation.md` - 3-Tier system guide
- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan
- `.claude/skills/vibe-coding/SKILL.md` - Code quality standards (Quick Reference)
- `.claude/skills/vibe-coding/REFERENCE.md` - Code quality detailed guide
- `.claude/skills/tdd/SKILL.md` - Test-driven development (Quick Reference)
- `.claude/skills/tdd/REFERENCE.md` - TDD detailed guide
- `.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration (Quick Reference)
- `.claude/skills/ralph-loop/REFERENCE.md` - Ralph Loop detailed guide

---

**Last Updated**: 2026-01-16
**Version**: 3.4.0 (Codex integration)
