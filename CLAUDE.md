# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-17
> **Version**: 4.0.4

---

## Quick Start

### Workflow Commands

| Task | Command | Description |
|------|---------|-------------|
| Plan | `/00_plan "task"` | Generate SPEC-First plan |
| Confirm | `/01_confirm` | Review plan + requirements verification |
| Execute | `/02_execute` | Implement with TDD |
| Review | `/90_review` | Multi-angle code review |
| Document | `/91_document` | Auto-sync documentation |
| Close | `/03_close` | Archive and commit |

### Development Workflow

1. **SPEC-First**: What/Why/How/Success Criteria/Constraints
2. **TDD Cycle**: Red (failing test) → Green (minimal code) → Refactor (clean up)
3. **Ralph Loop**: Iterate until tests pass, coverage ≥80%, type-check clean, lint clean
4. **Quality Gates**: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3 levels

---

## Project Structure

```
project-root/
├── .claude/
│   ├── commands/           # Slash commands (9)
│   ├── guides/             # Methodology guides (12)
│   ├── skills/             # TDD, Ralph Loop, Vibe Coding, Git Master
│   ├── agents/             # Specialized agent configs (8)
│   └── scripts/hooks/      # Type check, lint, todos
├── .pilot/plan/            # Plan management (pending/in_progress/done)
├── scripts/                # Sync and build scripts
├── src/ or lib/            # Source code
├── tests/                  # Test files
├── CLAUDE.md               # This file (Tier 1: Project standards)
└── README.md               # Project README
```

**See**: `docs/ai-context/project-structure.md` for detailed directory layout.

---

## Codex Integration (v4.0.4)

**GPT Expert Delegation**: Optional GPT delegation via `codex-sync.sh` for high-difficulty analysis.

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** |

**Full guide**: `.claude/rules/delegator/orchestration.md`

---

## Testing & Quality

| Scope | Target | Priority |
|-------|--------|----------|
| Overall | 80% | Required |
| Core Modules | 90%+ | Required |
| UI Components | 70%+ | Nice to have |

**Commands**: `pytest`, `pytest --cov`, `mypy .`, `ruff check .`

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

**Parallel Execution**: Planning (Explorer + Researcher), Execution (Coders), Verification (Tester + Validator + Code-Reviewer)

**See**: `.claude/guides/parallel-execution.md`

---

## MCP Servers

**Recommended**: context7 (docs), serena (code ops), grep-app (search), sequential-thinking (reasoning), codex (GPT delegation)

---

## Pre-Commit Checklist

- [ ] All tests pass (`pytest`)
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean (`mypy .`)
- [ ] Lint clean (`ruff check .`)
- [ ] Documentation updated
- [ ] No secrets included

---

## Related Documentation

- **System Integration**: `docs/ai-context/system-integration.md` - CLI workflow, external skills, Codex
- **Project Structure**: `docs/ai-context/project-structure.md` - Directory layout, key files
- **Documentation Overview**: `docs/ai-context/docs-overview.md` - Complete documentation navigation
- **3-Tier System**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)

---

**Template Version**: claude-pilot 4.0.4
**Last Updated**: 2026-01-17
