# Project Structure Guide

> **Purpose**: Technology stack, directory layout, and key files
> **Last Updated**: 2026-01-24

---

## Technology Stack

```yaml
Framework: Claude Code Plugin
Language: Markdown + JSON (no code runtime)
Package Manager: Claude Code Plugin System
Version: 4.4.43
Deployment: GitHub Marketplace (plugin distribution)
```

---

## Directory Layout

```
claude-pilot/
├── .claude-plugin/         # Plugin manifests
│   ├── marketplace.json    # Marketplace configuration
│   └── plugin.json         # Plugin metadata (version source of truth)
├── .github/                # GitHub Actions CI/CD
│   ├── workflows/
│   │   └── release.yml     # Tag-triggered release workflow
│   └── scripts/
│       └── validate_versions.sh  # Version consistency validation
├── .claude/
│   ├── commands/           # Slash commands (11)
│   │   ├── CONTEXT.md      # Command folder context
│   │   ├── setup.md        # Setup command
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan
│   │   ├── 02_execute.md   # Execute with TDD
│   │   ├── 03_close.md     # Close & archive
│   │   ├── 04_fix.md       # Rapid bug fix workflow
│   │   ├── 05_cleanup.md   # Dead code cleanup
│   │   ├── review.md       # Review code
│   │   ├── document.md     # Update docs
│   │   └── 999_release.md  # Bump version + release
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   ├── skills/             # Reusable skill modules
│   │   ├── CONTEXT.md      # Skill folder context
│   │   ├── tdd/            # Test-Driven Development
│   │   ├── ralph-loop/     # Autonomous iteration
│   │   ├── vibe-coding/    # Code quality standards
│   │   ├── git-master/     # Git operations
│   │   ├── gpt-delegation/ # GPT expert delegation
│   │   ├── docs-verify/    # Documentation verification
│   │   └── frontend-design/# UI/UX design skill
│   ├── agents/             # Specialized agent configs (8)
│   │   ├── CONTEXT.md      # Agent folder context
│   │   ├── explorer.md     # Codebase exploration (haiku)
│   │   ├── researcher.md   # External docs research (haiku)
│   │   ├── coder.md        # TDD implementation (sonnet)
│   │   ├── tester.md       # Test writing (sonnet)
│   │   ├── validator.md    # Quality verification (haiku)
│   │   ├── plan-reviewer.md # Plan analysis (sonnet)
│   │   ├── code-reviewer.md # Deep code review (opus)
│   │   └── documenter.md   # Documentation sync (haiku)
│   ├── scripts/
│   │   └── statusline.sh   # Statusline display (copied to user project)
│   └── rules/              # Core rules
├── .pilot/                 # Plan management
│   ├── plan/
│   │   ├── draft/          # Draft plans
│   │   ├── pending/        # Awaiting confirmation
│   │   ├── in_progress/    # Currently executing
│   │   └── done/           # Completed plans
│   ├── issues/             # Discovered Issues tracking
│   │   ├── log.jsonl       # Event log (append-only)
│   │   └── state.json      # Materialized view
│   ├── state/              # State management
│   └── tests/              # Integration tests
├── .tmp/                   # Temporary files (gitignored)
├── docs/                   # Project documentation
│   └── ai-context/         # Tier 1 supplementary docs
│       ├── project-structure.md  # This file
│       └── docs-overview.md      # Document navigation
├── CLAUDE.md               # Tier 1: Project documentation
├── README.md               # Project README
└── CHANGELOG.md            # Version history
```

---

## Key Files by Purpose

### Commands
| File | Purpose |
|------|---------|
| `setup.md` | Initialize claude-pilot |
| `00_plan.md` | Create SPEC-First plan |
| `01_confirm.md` | Confirm plan |
| `02_execute.md` | TDD + Ralph Loop |
| `03_close.md` | Archive and commit |
| `04_fix.md` | Rapid bug fix |
| `999_release.md` | Version bump + release |

**Details**: See `@.claude/commands/CONTEXT.md`

### Skills
| Skill | Purpose |
|-------|---------|
| `tdd` | Red-Green-Refactor cycle |
| `ralph-loop` | Autonomous iteration |
| `vibe-coding` | LLM-readable code standards |
| `git-master` | Git operations |
| `gpt-delegation` | GPT expert delegation |
| `docs-verify` | Documentation verification |
| `spec-driven-workflow` | Enhanced with Context Manifest and Quick Sufficiency Test |
| `review` | Multi-angle review with enhanced code-reviewer integration |

**Details**: See `@.claude/skills/CONTEXT.md`

### Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| explorer | haiku | Fast codebase exploration |
| researcher | haiku | External docs research |
| coder | sonnet | TDD implementation |
| tester | sonnet | Test writing |
| validator | haiku | Quality verification |
| plan-reviewer | sonnet | Plan analysis |
| code-reviewer | opus | Enhanced code review with risk areas, assumptions tracking |
| documenter | haiku | Documentation sync |

**Details**: See `@.claude/agents/CONTEXT.md`

---

## Local Configuration

**Project Settings**: `.claude/settings.json`
```json
{
  "statusLine": {
    "type": "command",
    "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/statusline.sh"
  }
}
```

**Statusline Output**: `[📋 PLAN] [🔄 PHASE] [✓ SC-N] [🔴 DI:P0] [🟡 DI:P1]`

---

## Component Details

For detailed information about each component, see the corresponding CONTEXT.md:

- **Commands**: `@.claude/commands/CONTEXT.md`
- **Skills**: `@.claude/skills/CONTEXT.md`
- **Agents**: `@.claude/agents/CONTEXT.md`

---

**Line Count**: ~160 lines (Target: ≤300 lines) ✅
