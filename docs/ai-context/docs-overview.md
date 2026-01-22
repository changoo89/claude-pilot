# Documentation Overview

> **Purpose**: Navigation guide for all CONTEXT.md files and project documentation
> **Last Updated**: 2026-01-18

---

## 3-Tier Documentation System

This project uses a hierarchical documentation system optimized for token usage and context management.

### Tier Structure

```
CLAUDE.md (Tier 1 - Project)
    ├── Quick reference (30-second context)
    ├── Links to detailed docs
    └── Standards and workflows
            ↓
docs/ai-context/ (Detailed Reference)
    ├── system-integration.md
    ├── project-structure.md
    └── docs-overview.md (this file)
            ↓
{component}/CONTEXT.md (Tier 2 - Component)
    ├── .claude/commands/CONTEXT.md
    ├── .claude/guides/CONTEXT.md
    └── .claude/skills/CONTEXT.md
            ↓
{feature}/CONTEXT.md (Tier 3 - Feature)
    └── Implementation details
```

---

## Tier 1: CLAUDE.md

### Purpose

Project-level documentation containing standards, architecture, and workflows that apply to the entire project.

### Location

`/CLAUDE.md` (project root)

### Contents

- **Project Overview**: One-line description, tech stack, status
- **Quick Start**: Installation, common commands
- **Project Structure**: Directory layout, key files
- **Development Workflow**: SPEC-First, TDD, Ralph Loop
- **3-Tier Documentation**: Links to Tier 2/3 CONTEXT.md files
- **Quality Standards**: Testing, linting, coverage targets

### Size Limits

- **Max Lines**: 300
- **Max Tokens**: ~3000
- **Action When Exceeded**: Move detailed sections to `docs/ai-context/`

---

## docs/ai-context/ (Detailed Reference)

### Purpose

Detailed documentation that supplements Tier 1 when it exceeds size limits. Contains comprehensive information about project structure, system integration, and workflows.

### Location

`/docs/ai-context/`

### Files

| File | Purpose | When to Reference |
|------|---------|-------------------|
| **system-integration.md** | Component interactions, workflows, integration points | Understanding how commands work together |
| **project-structure.md** | Technology stack, directory layout, key files | Understanding codebase organization |
| **cicd-integration.md** | GitHub Actions CI/CD workflow for automated releases | Understanding release automation |
| **codex-integration.md** | GPT delegation via Codex CLI for complex tasks | Understanding intelligent delegation |
| **testing-quality.md** | Testing standards, coverage targets, quality gates | Understanding quality requirements |
| **agent-ecosystem.md** | Specialized agent configurations (8 agents) | Understanding agent model selection |
| **mcp-servers.md** | Recommended MCP servers for enhanced capabilities | Understanding context and code ops tools |
| **docs-overview.md** | This file: Navigation for all documentation | Finding specific documentation |

### Size Limits

- **Max Lines per File**: 500
- **Action When Exceeded**: Split into topic-specific files

---

## Tier 2: Component CONTEXT.md

### Purpose

Component-level architecture documentation for major modules, libraries, or feature groups.

### Folder Patterns

| Pattern | Example | Criteria |
|---------|---------|----------|
| `.claude/commands/` | Command workflows | 6+ command files |
| `.claude/guides/` | Methodology guides | 8+ guide files |
| `.claude/skills/` | Reusable skills | 4+ skill modules |
| `.claude/agents/` | Specialized agents | 4+ agent configs |
| `src/*/`, `lib/*/` | Source components | 3+ files |
| `pages/api/`, `hooks/`, `utils/` | Utility folders | 3+ files |

### Template

```markdown
# {Component Name} - Component Context (Tier 2)
> Purpose: Component-level architecture | Tier: 2

## Purpose
{Component responsibility}

## Key Component Structure
{Directory layout, key files}

## Implementation Highlights
{Core patterns, architectural decisions}

## Integration Points
{Dependencies, dependents}

## Development Guidelines
{When to work here, constraints}
```

### Size Limits

- **Max Lines**: 200
- **Max Tokens**: ~2000
- **Action When Exceeded**: Archive historical decisions to `{component}/HISTORY.md`

---

## Tier 3: Feature CONTEXT.md

### Purpose

Feature-level implementation details for specific features or deeply nested implementations.

### Folder Patterns

| Pattern | Example | Criteria |
|---------|---------|----------|
| `features/*/` | `features/auth/` | Feature implementations |
| Deep nested (`*/*/*/`) | `src/components/auth/forms/` | Specific features |
| High iteration files | Frequently changed files | Implementation details |

### Template

```markdown
# {Feature Name} - Feature Context (Tier 3)
> Purpose: Feature-level implementation | Tier: 3

## Architecture & Patterns
{Design patterns, data flow, state}

## Integration & Performance
{Dependencies, performance}

## Implementation Decisions
{Decision log, trade-offs}

## Code Examples
{Common usage, edge cases}
```

### Size Limits

- **Max Lines**: 150
- **Max Tokens**: ~1500
- **Action When Exceeded**: Compress or split by feature

---

## Current CONTEXT.md Files

### Existing Tier 2 Files

| Location | Status | Notes |
|----------|--------|-------|
| `.claude/commands/CONTEXT.md` | Created | Documents 8 command files |
| `.claude/guides/CONTEXT.md` | Created | Documents 10+ guide files |
| `.claude/skills/CONTEXT.md` | Created | Documents 5 skill modules (tdd, ralph-loop, vibe-coding, git-master, documentation-best-practices) |
| `.claude/agents/CONTEXT.md` | Created | Documents 8 agent configs |
| `src/claude_pilot/CONTEXT.md` | Created | Core Python package architecture (cli.py, codex.py, config.py, assets.py, build_hook.py, initializer.py, updater.py) |

### To Create

Use `/document {folder_name}` to create CONTEXT.md for any folder:

```bash
/document .claude/commands
/document .claude/guides
/document .claude/skills
/document .claude/agents
```

---

## Navigation Guide

### For Quick Reference

Start with **Tier 1 (CLAUDE.md)** for:
- Installation instructions
- Common commands
- Project overview

### For Workflow Details

See **@docs/ai-context/system-integration.md** for:
- Command workflows
- Integration points
- Ralph Loop logic
- Interactive Recovery flow

See **@docs/ai-context/codex-integration.md** for:
- GPT delegation triggers and patterns
- Codex CLI integration
- Intelligent escalation

See **@docs/ai-context/cicd-integration.md** for:
- GitHub Actions CI/CD workflow
- Automated release process
- Version validation

### For Codebase Structure

See **@docs/ai-context/project-structure.md** for:
- Directory layout
- Key files by purpose
- Technology stack
- Version history

### For Quality & Testing

See **@docs/ai-context/testing-quality.md** for:
- Testing standards and coverage targets
- Quality gates (TDD, Ralph Loop)
- Pre-commit checklist

### For Agent Configuration

See **@docs/ai-context/agent-ecosystem.md** for:
- 8 specialized agent configurations
- Model selection (Haiku, Sonnet, Opus)
- Parallel execution patterns

### For MCP Servers

See **@docs/ai-context/mcp-servers.md** for:
- Recommended MCP servers
- Context enhancement tools
- Code operations integrations

### For Component Details

See **Tier 2 CONTEXT.md** files for:
- Component architecture
- Key files and patterns
- Integration points

### For Implementation Details

See **Tier 3 CONTEXT.md** files for:
- Implementation decisions
- Code examples
- Performance characteristics

---

## Maintenance Commands

### Initialize 3-Tier System

```bash
/setup
```

Creates full 3-Tier from scratch:
- Tier 1: CLAUDE.md with detected tech stack
- docs/ai-context/: docs-overview.md, project-structure.md, system-integration.md
- Tier 2: CONTEXT.md for selected folders

### Auto-Sync After Implementation

```bash
/document auto-sync from {RUN_ID}
```

Updates:
- Tier 1: CLAUDE.md (last-updated, new sections)
- docs/ai-context/: project-structure.md, system-integration.md, docs-overview.md
- Tier 2/3: CONTEXT.md files
- Archives: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

### Update Specific Folder

```bash
/document {folder_name}
```

Creates or updates CONTEXT.md for specific folder.

### Full Project Sync

```bash
/document
```

Updates all tiers for entire project.

---

## Document Size Management

### Check Sizes

```bash
# Count lines in CLAUDE.md
wc -l CLAUDE.md

# Count lines in all CONTEXT.md files
find . -name "CONTEXT.md" -exec wc -l {} \;
```

### Auto-Compress

```bash
/document auto-compress
```

Automatically compresses documentation that exceeds thresholds:
- Tier 1: Moves detailed sections to docs/ai-context/
- Tier 2: Archives historical decisions to HISTORY.md
- Tier 3: Splits by feature area

---

## Related Documentation

- `CLAUDE.md` - Tier 1: Project documentation
- `.claude/guides/3tier-documentation.md` - 3-Tier system guide
- `.claude/templates/CONTEXT-tier2.md.template` - Component template
- `.claude/templates/CONTEXT-tier3.md.template` - Feature template

---

**Last Updated**: 2026-01-22
**Version**: 4.4.11 (Documentation Consistency Audit)
