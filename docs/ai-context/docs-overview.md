# Documentation Overview

> **Purpose**: Navigation guide for 3-Tier documentation system
> **Last Updated**: 2026-01-25

---

## 3-Tier Documentation System

Hierarchical documentation system optimized for token usage and context management.

### Tier Structure

```
CLAUDE.md (Tier 1 - Project)
    ├── Quick reference, links, standards
    └── ≤200 lines
            ↓
docs/ai-context/ (Tier 1 - Detailed)
    ├── project-structure.md (≤200 lines)
    └── docs-overview.md (≤200 lines)
            ↓
{component}/CONTEXT.md (Tier 2)
    └── ≤200 lines per file
            ↓
{feature}/CONTEXT.md (Tier 3)
    └── ≤200 lines per file
```

---

## Tier 1: Entry Points (3 Files Only)

| File | Purpose | Size Limit |
|------|---------|------------|
| `CLAUDE.md` | Project overview, standards, workflows | ≤200 lines |
| `docs/ai-context/project-structure.md` | Tech stack, directory layout | ≤200 lines |
| `docs/ai-context/docs-overview.md` | Documentation navigation (this file) | ≤200 lines |

**Required**: CLAUDE.md must reference both ai-context files at the top.

**Validation**: `docs-verify.sh --strict` enforces line limits.

---

## Tier 2: Component CONTEXT.md

### Purpose
Component-level architecture for major modules.

### Folder Patterns

| Pattern | Criteria |
|---------|----------|
| `.claude/commands/` | 6+ command files |
| `.claude/skills/` | 4+ skill modules |
| `.claude/agents/` | 4+ agent configs |
| `src/*/`, `lib/*/` | 3+ files |

### Current Files

| Location | Notes |
|----------|-------|
| `@.claude/commands/CONTEXT.md` | Command workflows |
| `@.claude/skills/CONTEXT.md` | Skill modules |
| `@.claude/agents/CONTEXT.md` | Agent configs |

**Template**: `@.claude/templates/CONTEXT-tier2.md.template`

---

## Tier 3: Feature CONTEXT.md

### Purpose
Feature-level implementation details.

### Folder Patterns

| Pattern | Criteria |
|---------|----------|
| `features/*/` | Feature implementations |
| Deep nested (`*/*/*/`) | Specific features |

**Template**: `@.claude/templates/CONTEXT-tier3.md.template`

---

## Navigation Guide

### Quick Start
→ **CLAUDE.md**: Installation, common commands, project overview

### Workflows
→ **@.claude/commands/CONTEXT.md**: Command workflows, phase boundaries
→ **@.claude/skills/gpt-delegation/REFERENCE.md**: GPT delegation, Codex CLI

### Structure
→ **@docs/ai-context/project-structure.md**: Directory layout, key files

### Agents
→ **@.claude/agents/CONTEXT.md**: 8 agents, model selection, parallel execution

### MCP & Release
→ **@.claude/commands/setup.md**: MCP servers
→ **@.claude/commands/999_release.md**: CI/CD, version management

---

## Commands

| Command | Purpose |
|---------|---------|
| `/setup` | Initialize 3-Tier system |
| `/document` | Auto-sync all tiers |
| `/document {folder}` | Update specific folder CONTEXT.md |

---

## Size Limits

| Tier | Location | Max Lines |
|------|----------|-----------|
| 1 | CLAUDE.md, ai-context/*.md | 200 |
| 2 | {component}/CONTEXT.md | 200 |
| 3 | {feature}/CONTEXT.md | 200 |

**When Exceeded**:
- Tier 1: Extract to Tier 2 CONTEXT.md
- Tier 2: Archive to HISTORY.md or split
- Tier 3: Split by feature area

---

## Validation

```bash
# Verify all documentation
.claude/scripts/docs-verify.sh --strict

# Check specific file
wc -l CLAUDE.md  # Must be ≤200
```

---

**Version**: 4.4.42
