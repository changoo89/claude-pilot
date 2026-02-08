# Project Structure Guide

> **Purpose**: Technology stack, directory layout, and key files
> **Last Updated**: 2026-01-28

---

## Technology Stack

```yaml
Framework: Claude Code Plugin
Language: Markdown + JSON (no code runtime)
Package Manager: Claude Code Plugin System
Version: 4.4.50
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
│   ├── hooks/              # Agent Teams lifecycle hooks
│   │   ├── verify-task-completion.sh  # TaskCompleted hook
│   │   └── teammate-idle-check.sh     # TeammateIdle hook
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   ├── skills/             # Reusable skill modules
│   │   ├── CONTEXT.md      # Skill folder context
│   │   ├── tdd/            # Test-Driven Development
│   │   ├── ralph-loop/     # Autonomous iteration
│   │   ├── vibe-coding/    # Code quality standards
│   │   ├── git-master/     # Git operations
│   │   ├── gpt-delegation/ # GPT expert delegation
│   │   ├── docs-verify/    # Documentation verification
│   │   ├── frontend-design/# UI/UX design skill
│   │   ├── agent-teams/    # Agent Teams coordination skill
│   │   ├── execute-plan/  # TDD execution with E2E verification (Step 5)
│   │   ├── confirm-plan/   # Plan confirmation workflow with Context Manifest
│   │   ├── rapid-fix/      # Rapid bug fix
│   │   ├── release/        # Plugin release workflow
│   │   ├── review/         # Multi-angle review with enhanced code-reviewer integration
│   │   ├── code-cleanup/   # Dead code removal
│   │   └── spec-driven-workflow/ # Enhanced with Context Manifest and Quick Sufficiency Test (≤200 lines)
│   ├── agents/             # Specialized agent configs (13)
│   │   ├── CONTEXT.md      # Agent folder context
│   │   ├── explorer.md     # Codebase exploration (haiku)
│   │   ├── researcher.md   # External docs research (haiku)
│   │   ├── coder.md        # TDD implementation (sonnet) + EXAMPLES.md
│   │   ├── tester.md       # Test writing (sonnet)
│   │   ├── validator.md    # Quality verification (haiku)
│   │   ├── plan-reviewer.md # Plan analysis (sonnet)
│   │   ├── code-reviewer.md # Deep code review (opus)
│   │   ├── build-error-resolver.md # Error resolution (haiku) + TROUBLESHOOTING.md
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
| `agent-teams` | Agent Teams coordination and lifecycle hooks |
| `close-plan` | OOM-optimized plan completion (5 steps, 2 agents) |
| `docs-verify` | Pure bash verification (no external deps) |
| `execute-plan` | TDD execution with E2E verification and Chrome in Claude integration |
| `confirm-plan` | Plan confirmation workflow with Context Manifest |
| `rapid-fix` | Rapid bug fix workflow |
| `release` | Plugin release workflow |
| `review` | Multi-angle review with enhanced code-reviewer integration |
| `code-cleanup` | Dead code detection and removal |
| `spec-driven-workflow` | Enhanced with Context Manifest and Quick Sufficiency Test (≤200 lines) |

**Details**: See `@.claude/skills/CONTEXT.md`

### Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| explorer | haiku | Fast codebase exploration |
| researcher | haiku | External docs research |
| frontend-engineer | sonnet | Frontend UI/React implementation |
| backend-engineer | sonnet | Backend API/DB implementation |
| coder | sonnet | TDD implementation (general) |
| tester | sonnet | Test writing and execution |
| validator | haiku | Quality verification |
| security-analyst | sonnet | Security vulnerability analysis |
| build-error-resolver | haiku | Build/compilation error resolution |
| plan-reviewer | sonnet | Plan analysis and gaps |
| code-reviewer | opus | Enhanced code review with risk areas, assumptions tracking |
| design-reviewer | sonnet | Design quality review for high-stakes UI surfaces |
| documenter | haiku | Documentation generation |

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
