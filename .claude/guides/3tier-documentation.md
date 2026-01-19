# 3-Tier Documentation System Guide

> **Purpose**: Hierarchical documentation for token optimization
> **Full Reference**: @.claude/guides/3tier-documentation-REFERENCE.md

---

## Overview

| Tier | Location | Purpose | Max Lines |
|------|----------|---------|-----------|
| **Tier 1** | `CLAUDE.md` | Project standards | 300 |
| **Tier 2** | `{component}/CONTEXT.md` | Component architecture | 200 |
| **Tier 3** | `{feature}/CONTEXT.md` | Feature details | 150 |

---

## Tier 1: CLAUDE.md

**Sections**: Overview, Quick Start, Structure, Workflow, 3-Tier links, Quality Standards

**Update triggers**: New features, commands, CONTEXT.md files, standards changes

---

## Tier 2: Component CONTEXT.md

**Purpose**: Component-level architecture (`src/*/`, `lib/*/`, `pages/api/`, `hooks/`)

**Update rules**: Add/remove files, new patterns, import changes

**Template**: @.claude/templates/CONTEXT-tier2.md.template

---

## Tier 3: Feature CONTEXT.md

**Purpose**: Feature-level details (`features/*/`, deep nesting `*/*/*/`)

**Update rules**: Add/remove files, performance changes, decisions

**Template**: @.claude/templates/CONTEXT-tier3.md.template

---

## Size Management

| Tier | Threshold | Action |
|------|-----------|--------|
| Tier 1 | 300 lines | Move to `docs/ai-context/` |
| Tier 2 | 200 lines | Archive to `HISTORY.md` |
| Tier 3 | 150 lines | Split by feature |

**Auto-detection**: `/03_close` checks sizes, `/document` compresses

---

## Commands

| Action | Command |
|--------|---------|
| Initialize | `/setup` |
| Auto-sync | `/document auto-sync from {RUN_ID}` |
| Update folder | `/document {folder_name}` |
| Full sync | `/document` |

---

## docs/ai-context/

| File | Purpose |
|------|---------|
| **docs-overview.md** | Navigation for CONTEXT.md files |
| **project-structure.md** | Tech stack, directory layout |
| **system-integration.md** | Component interactions |

---

## See Also

- **Templates**: @.claude/templates/CONTEXT-tier2.md.template, @.claude/templates/CONTEXT-tier3.md.template
- **Standards**: @.claude/skills/vibe-coding/SKILL.md
- **Full Reference**: @.claude/guides/3tier-documentation-REFERENCE.md (templates, bash code)

---

**Version**: claude-pilot 4.2.0 (3-Tier Documentation)
**Last Updated**: 2026-01-19
