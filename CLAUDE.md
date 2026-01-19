# claude-pilot - Plugin Documentation

> **Version**: 4.3.1 | **Last Updated**: 2026-01-20

---

## Quick Start

```bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup
```

---

## Two-Layer Documentation

**Plugin Layer (CLAUDE.md)**: Plugin architecture, features, distribution - **This file**
**Project Layer (CLAUDE.local.md)**: Your project-specific configuration, structure, standards

**Why Two Layers?**
- Plugin docs stay clean and focused
- Your customizations stay private (gitignored)
- Plugin updates won't affect your local docs

**Create Project Template**: Run `/pilot:setup` after installation

**Template Location**: `.claude/templates/CLAUDE.local.template.md`

---

## Plugin Architecture

**Pure Plugin**: No Python dependency, native Claude Code integration

**Core Features**:
- **SPEC-First Planning**: `/00_plan "task"`
- **TDD + Ralph Loop**: `/02_execute` - Autonomous iteration until quality gates pass
- **Sisyphus Continuation**: `/00_continue` - Resume across sessions
- **Multi-Angle Review**: `/review` - Parallel verification
- **Auto-Documentation**: `/document` - 3-Tier sync

**Workflow**: Plan → Confirm → Execute → Review → Document → Close

---

## Plugin Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Commands | Slash commands (11) | `.claude/commands/` |
| Guides | Methodology (17) | `.claude/guides/` |
| Skills | TDD, Ralph Loop, Vibe Coding | `.claude/skills/` |
| Agents | Specialized roles (8) | `.claude/agents/` |
| State | Continuation system | `.pilot/state/` |

**Plugin Directory**: `@docs/ai-context/project-structure.md`

---

## Key Features

### Sisyphus Continuation (v4.2.0)
**Intelligent Agent Persistence**: Agents continue work across sessions until completion

**Commands**: `/00_continue` (resume), `/02_execute` (create state), `/03_close` (verify)

**Configuration**: `export CONTINUATION_LEVEL="normal"` (aggressive | normal | polite)

**Full Guide**: `@docs/ai-context/continuation-system.md`

### Codex Integration (v4.2.0)
**Intelligent GPT Delegation**: Context-aware, autonomous delegation to GPT experts

**Key Features**:
- **Delegation Triggers**: Architecture decisions, 2+ failures, security issues, large plans
- **Expert Mapping**: Architect (system design), Security Analyst (vulnerabilities), Plan Reviewer (validation), Code Reviewer (quality), Scope Analyst (requirements)
- **Progressive Escalation**: After 2nd failure (not first) → GPT Architect
- **Auto-Delegation**: Coder blocked → Immediate GPT Architect call
- **Graceful Fallback**: Falls back to Claude if Codex CLI not installed

**Configuration**: `export CODEX_REASONING_EFFORT="medium"` (default)

**Full Guide**: `@docs/ai-context/codex-integration.md`

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

**Full Guide**: `@docs/ai-context/cicd-integration.md`

### Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Full Guide**: `@docs/ai-context/agent-ecosystem.md`

---

## MCP Servers

**Plugin-Recommended**: context7, serena, grep-app, sequential-thinking, codex

**Full List**: `@docs/ai-context/mcp-servers.md`

---

## Plugin Skills

**TDD**: `@.claude/skills/tdd/SKILL.md` - Red-Green-Refactor cycle
**Ralph Loop**: `@.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration
**Vibe Coding**: `@.claude/skills/vibe-coding/SKILL.md` - Code quality standards
**Git Master**: `@.claude/skills/git-master/SKILL.md` - Git operations
**Frontend Design**: `@.claude/skills/frontend-design/SKILL.md` - UI/UX design thinking

---

## Quality & Hooks

**Hooks Performance** (v4.3.0):
- **Dispatcher Pattern**: O(1) project type detection (P95: 20ms)
- **Smart Caching**: Config hash-based cache invalidation
- **Gate vs Validator**: Safety checks (PreToolUse) vs quality checks (Stop)
- **Profile System**: User-configurable modes (off/stop/strict)

**Migration Guide**: `@docs/migration-guide.md`

**Pre-commit Hooks** (`.claude/hooks.json`):
- Type check validation
- Lint validation
- Custom project hooks (configure in `CLAUDE.local.md`)

**Plugin Testing**: Integration tests in `.pilot/tests/`

---

## Plugin Documentation

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` (this file) - Plugin architecture
- **Tier 2**: `docs/ai-context/*.md` - System integration
- **Tier 3**: `{component}/CONTEXT.md` - Component details

**Key Docs**:
- `@docs/ai-context/system-integration.md` - CLI workflow, Codex, MCP
- `@docs/ai-context/project-structure.md` - Plugin layout, **Local Configuration**
- `@.claude/agents/CONTEXT.md` - Agent ecosystem
- `@.claude/commands/CONTEXT.md` - Command workflows

---

## Version & Distribution

**Plugin Version**: 4.3.1 (Dead Code Cleanup Command - Auto-Apply Workflow)
**Distribution**: GitHub Marketplace (pure plugin)

**Release Process**: `@.claude/commands/999_release.md`

---

**Line Count**: 178 lines (Target: ≤200 lines) ✅

---

## Version History

### v4.3.1 (2026-01-20)

**Dead Code Cleanup Command**: Auto-apply workflow with risk-based confirmation
- Auto-apply Low/Medium risk items without confirmation (interactive TTY)
- High-risk items require user confirmation with 3 choices
- Safe flags: `--dry-run` for preview, `--apply` for force-apply
- Risk classification: Low (tests), Medium (utils), High (components/routes)
- Pre-flight safety: Auto-block modified/staged files
- Verification after each batch (max 10 deletions) and at end
- Automatic rollback on verification failure
- Non-interactive mode: CI/non-TTY defaults to --dry-run behavior (exit 2 if changes needed)
- 10 new test files (52 assertions, 100% pass rate)

