# claude-pilot - Plugin Documentation

> **Version**: 4.4.13 | **Last Updated**: 2026-01-23

---

## ⚠️ CRITICAL: Required Reference Documents

**Before starting any work, you MUST read the following documents:**

- `@docs/ai-context/project-structure.md` - Project structure, tech stack, file tree
- `@docs/ai-context/docs-overview.md` - Documentation architecture, Tier mapping, component references

These two documents are Tier 1 documents that all AI agents MUST reference before starting any work, along with CLAUDE.md.

---

## Quick Start

```bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup
```

---

## Plugin Architecture

**Pure Plugin**: No Python dependency, native Claude Code integration

**Core Features**:
- **SPEC-First Planning**: `/00_plan "task"`
- **TDD + Ralph Loop**: `/02_execute` - Autonomous iteration until quality gates pass
- **Multi-Angle Review**: `/review` - Parallel verification
- **Auto-Documentation**: `/document` - 3-Tier sync

**Workflow**: Plan (`/00_plan`) → Confirm (`/01_confirm`) → Execute (`/02_execute`) → Review (`/review`) → Document (`/document`) → Close (`/03_close`)

---

## Plugin Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Commands | Slash commands (11) | `.claude/commands/` |
| Skills | TDD, Ralph Loop, Vibe Coding | `.claude/skills/` |
| Agents | Specialized roles (8) | `.claude/agents/` |

**Plugin Directory**: `@docs/ai-context/project-structure.md`

---

## Key Features

### Codex Integration (v4.2.0)
**Intelligent GPT Delegation**: Context-aware, autonomous delegation to GPT experts

**Key Features**:
- **Delegation Triggers**: Architecture decisions, 2+ failures, security issues, large plans
- **Expert Mapping**: Architect (system design), Security Analyst (vulnerabilities), Plan Reviewer (validation), Code Reviewer (quality), Scope Analyst (requirements)
- **Progressive Escalation**: After 2nd failure (not first) → GPT Architect
- **Auto-Delegation**: Coder blocked → Immediate GPT Architect call
- **Graceful Fallback**: Falls back to Claude if Codex CLI not installed

**Configuration**: `export CODEX_REASONING_EFFORT="medium"` (default)

**Full Guide**: `@.claude/skills/gpt-delegation/REFERENCE.md`

**Delegation Flow**:
```
Trigger Detection (explicit, semantic, description-based)
      ↓
Expert Selection (Architect, Security Analyst, Code Reviewer, Plan Reviewer, Scope Analyst)
      ↓
Delegation (codex-sync.sh with 7-section prompt)
      ↓
Response Handling (synthesize, apply, verify)
```

### CI/CD Integration
**GitHub Actions**: Automated release on git tag push

**Release**: `/999_release minor` → Bump version, tag, push → CI creates GitHub Release

**Full Guide**: `@.claude/commands/999_release.md`

### Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Full Guide**: `@.claude/agents/CONTEXT.md`

---

## MCP Servers

**Plugin-Recommended**: context7, filesystem, sequential-thinking

**Setup Guide**: `@.claude/commands/setup.md`

---

## Plugin Skills

**TDD**: `@.claude/skills/tdd/SKILL.md` - Red-Green-Refactor cycle
**Ralph Loop**: `@.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration
**Vibe Coding**: `@.claude/skills/vibe-coding/SKILL.md` - Code quality standards
**Coding Standards**: `@.claude/skills/coding-standards/SKILL.md` - TypeScript, React, API, testing standards
**Git Master**: `@.claude/skills/git-master/SKILL.md` - Git operations
**Frontend Design**: `@.claude/skills/frontend-design/SKILL.md` - UI/UX design thinking

---

## Quality & Hooks

**Pre-commit Hook** (`.claude/scripts/hooks/pre-commit.sh`):
- Fast JSON syntax validation
- Markdown link sanity check
- Runs only on staged files
- Symlinked to `.git/hooks/pre-commit`

**No Claude Code Hooks**: Plugin doesn't use Stop/PreToolUse hooks to avoid performance overhead

**Plugin Testing**: Integration tests in `.pilot/tests/`

---

## Plugin Documentation

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` + `project-structure.md` + `docs-overview.md` (3 files only)
- **Tier 2**: `{component}/CONTEXT.md` - Component details
- **Tier 3**: `{component}/{feature}/CONTEXT.md` - Feature details

**Key Docs**:
- `@docs/ai-context/project-structure.md` - Plugin layout, tech stack
- `@docs/ai-context/docs-overview.md` - Documentation architecture, Tier mapping
- `@.claude/agents/CONTEXT.md` - Agent ecosystem
- `@.claude/commands/CONTEXT.md` - Command workflows

---

## Version & Distribution

**Plugin Version**: 4.4.13 (Cleanup refactor with knip + 4-level risk)
**Distribution**: GitHub Marketplace (pure plugin)

**Release Process**: `@.claude/commands/999_release.md`

---

**Line Count**: 191 lines (Target: ≤200 lines) ✅

---

## Version History

### v4.4.13 (2026-01-23)
Cleanup refactor with knip integration, parallel detection, 4-level risk classification

### v4.4.12 (2026-01-23)
Integrate /document into /03_close, 3-Tier documentation restructure, dual-source verification

### v4.4.11 (2026-01-22)
GPT auto-delegation triggers, explicit command gate, absolute paths for plan files

### v4.4.6 (2026-01-21)
Mandatory dialogue checkpoints, EXECUTION DIRECTIVE, parallel agent execution

### v4.3.4 (2026-01-21)
Hooks simplification: Removed Stop hooks, simple pre-commit hook only

### v4.3.1 (2026-01-20)
Dead code cleanup command with risk-based confirmation

**Full History**: See `CHANGELOG.md`
