# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-17
> **Version**: 4.0.3
> **Template**: claude-pilot

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
│   ├── commands/           # Slash commands (7)
│   ├── guides/             # Methodology guides (10)
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

## Codex Integration (v4.0.3)

**GPT Expert Delegation**: claude-pilot supports optional GPT expert delegation via `codex-sync.sh` script for high-difficulty analysis.

**Integration Points**:
- **Commands**: `/90_review` (GPT expert review for complex plans), `/02_execute` (GPT escalation after 2+ failed attempts)
- **Agents**: `code-reviewer` (GPT Security Analyst for security code), `plan-reviewer` (GPT Plan Reviewer for large plans)
- **Delegation Rules**: `.claude/rules/delegator/` (orchestration, triggers, delegation format)

**Role Split: Claude vs GPT**:

| Situation | Claude Agent | GPT Expert |
|-----------|--------------|------------|
| General code review | code-reviewer (Opus) | - |
| **Security-related code** | code-reviewer → | **Security Analyst** |
| General plan review | plan-reviewer (Sonnet) | - |
| **Large plan (5+ SCs)** | plan-reviewer → | **Plan Reviewer** |
| **Architecture decisions** | - | **Architect** |
| **2+ failed fix attempts** | - | **Architect (fresh perspective)** |
| **Unclear scope** | - | **Scope Analyst** |

**GPT Expert Usage Guide**:
- **Reference**: `.claude/rules/delegator/orchestration.md` - Full delegation flow
- **Trigger Detection**: `.claude/rules/delegator/triggers.md` - When to delegate
- **Cost Awareness**: Use GPT for high-value tasks only (architecture, security, complex debugging)
- **Delegation Command**: `.claude/scripts/codex-sync.sh "<mode>" "<prompt>"`

**Legacy MCP Cleanup**:
- Old `mcp__codex__codex` references replaced with `codex-sync.sh` Bash script
- MCP server approach deprecated in favor of direct Codex CLI calls
- Remove codex MCP entry from `~/.claude/settings.json` if present

**See**: `.claude/rules/delegator/orchestration.md` for detailed GPT integration documentation.

---

## Testing & Quality

### Coverage Targets

| Scope | Target | Priority |
|-------|--------|----------|
| Overall | 80% | Required |
| Core Modules | 90%+ | Required |
| UI Components | 70%+ | Nice to have |

### Test Commands (Python)

```bash
# All tests
pytest

# Coverage
pytest --cov

# Watch mode
pytest -watch

# Specific test
pytest tests/test_feature.py -k "test_name"
```

### Quality Standards

- **Type Safety**: `mypy .`
- **Linting**: `ruff check .`
- **Documentation**: Public APIs documented
- **Commits**: Conventional commits with Co-Authored-By

---

## Documentation System

### 3-Tier Hierarchy

- **Tier 1**: `CLAUDE.md` (this file) - Project standards, workflows
- **Tier 2**: `docs/ai-context/*.md` - System integration, project structure
- **Tier 3**: `{component}/CONTEXT.md` - Component-level architecture

### Key Documentation Files

| File | Purpose |
|------|---------|
| `docs/ai-context/system-integration.md` | CLI workflow, external skills, Codex delegation |
| `docs/ai-context/project-structure.md` | Directory layout, key files |
| `docs/ai-context/docs-overview.md` | Navigation for all documentation |

### Component CONTEXT.md Files

| Folder | CONTEXT.md | Purpose |
|--------|-----------|---------|
| `.claude/commands/` | [CONTEXT.md](.claude/commands/CONTEXT.md) | Command workflow |
| `.claude/guides/` | [CONTEXT.md](.claude/guides/CONTEXT.md) | Methodology patterns |
| `.claude/skills/` | [CONTEXT.md](.claude/skills/CONTEXT.md) | Skill reference |
| `.claude/agents/` | [CONTEXT.md](.claude/agents/CONTEXT.md) | Agent types |

**See**: `docs/ai-context/docs-overview.md` for complete documentation navigation.

---

## Agent Ecosystem

### Model Allocation

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

### Parallel Execution

- **Planning**: Explorer + Researcher (parallel)
- **Execution**: Coder agents (parallel SC implementation)
- **Verification**: Tester + Validator + Code-Reviewer (parallel)

**See**: `.claude/guides/parallel-execution.md` for detailed patterns.

---

## MCP Servers

### Recommended MCPs

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |
| codex (Optional) | GPT expert delegation |

**Configuration**: See `.claude/settings.json` for MCP configuration.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Type errors | Run `mypy .` |
| Test failures | Check test names and fixtures |
| Hook errors | Check script permissions |
| Plan not found | Run `/00_plan` first |

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

## Project-Specific Notes

> **Customize this section for your project**

### Domain-Specific Patterns

[Add project-specific conventions here]

### Key Dependencies

[Add important dependencies and their purposes]

### Known Issues

[Document known workarounds or issues]

---

**Template Version**: claude-pilot 4.0.3
**Last Updated**: 2026-01-17
