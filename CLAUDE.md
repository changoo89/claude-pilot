# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-17
> **Version**: 4.1.0

---

## Quick Start

### Installation (3-Line)

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

### Workflow Commands

| Task | Command | Description |
|------|---------|-------------|
| Plan | `/00_plan "task"` | Generate SPEC-First plan |
| Confirm | `/01_confirm` | Review plan + requirements verification |
| Execute | `/02_execute` | Implement with TDD (parallel SC execution) |
| Review | `/90_review` | Multi-angle code review (parallel optional) |
| Document | `/91_document` | Auto-sync documentation |
| Close | `/03_close` | Archive and commit |
| Setup | `/pilot:setup` | Configure MCP servers |

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
│   ├── commands/           # Slash commands (10)
│   ├── guides/             # Methodology guides (15)
│   ├── skills/             # TDD, Ralph Loop, Vibe Coding, Git Master
│   ├── agents/             # Specialized agent configs (8)
│   ├── scripts/hooks/      # Type check, lint, todos, branch
│   └── hooks.json          # Hook definitions
├── .pilot/plan/            # Plan management (pending/in_progress/done)
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
- **3-Tier System**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)

---

**Template Version**: claude-pilot 4.1.0 (Pure Plugin)
**Last Updated**: 2026-01-17
