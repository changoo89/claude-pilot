# 3-Tier Documentation System Guide

## Purpose

The 3-Tier Documentation System organizes project documentation into hierarchical layers, optimizing token usage while providing comprehensive context. This guide explains the system structure and how to maintain it.

## System Overview

The 3-Tier system separates documentation by scope and update frequency:

| Tier | Location | Purpose | Update Frequency |
|------|----------|---------|------------------|
| **Tier 1** | `CLAUDE.md` | Project standards, architecture, workflows | Rarely |
| **Tier 2** | `{component}/CONTEXT.md` | Component-level architecture | Occasionally |
| **Tier 3** | `{feature}/CONTEXT.md` | Feature-level implementation details | Frequently |

---

## Tier 1: CLAUDE.md (Project Root)

### Purpose
Project-level documentation containing standards, architecture, and workflows that apply to the entire project.

### Sections

| Section | Content | When to Update |
|---------|---------|----------------|
| **Project Overview** | One-line description, tech stack, status | Project initialization |
| **Quick Start** | Installation, common commands | New commands added |
| **Project Structure** | Directory layout, key files | New folders added |
| **Development Workflow** | Planning, execution, review phases | Workflow changes |
| **3-Tier Documentation** | Links to Tier 2/3 CONTEXT.md | New CONTEXT.md files |
| **Quality Standards** | Testing, linting, coverage targets | Standards change |

### Update Rules

| Trigger | Action |
|---------|--------|
| New feature | Update Project Structure |
| New command | Update Quick Start |
| New CONTEXT.md | Update 3-Tier Documentation links |
| Standards change | Update Quality Standards |

---

## Tier 2: Component CONTEXT.md

### Purpose
Component-level architecture documentation for major modules, libraries, or feature groups.

### Folder Patterns

| Pattern | Example | Criteria |
|---------|---------|----------|
| `src/*/`, `lib/*/` | `src/components/` | Has 3+ files |
| `components/*/` | `components/admin/` | Has 3+ files |
| Top-level | `src/`, `lib/` | Main source folders |
| `pages/api/`, `hooks/`, `utils/`, `types/` | Utility/API folders | Has 3+ files |

### Template

```markdown
# {Component Name} - Component Context (Tier 2)
> Purpose: Component-level architecture | Tier: 2

## Purpose
{Component responsibility - what does this component do?}

## Key Component Structure
{Directory layout, key files}

## Implementation Highlights
{Core patterns, architectural decisions}

## Integration Points
{Dependencies, dependents}

## Development Guidelines
{When to work here, constraints}
```

### Auto-Update Rules

| Trigger | Action |
|---------|--------|
| New file | Add to Key Files table |
| File deleted | Remove from Key Files |
| New pattern | Add to Patterns section |
| Import changes | Update Integration Points |

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

### Auto-Update Rules

| Trigger | Action |
|---------|--------|
| New file | Add to Key Files table |
| File deleted | Remove from Key Files |
| Performance change | Update Performance section |
| Decision made | Add to Decision Log |

---

## Tier Detection

```bash
FOLDER_DEPTH=$(echo "$FOLDER" | tr '/' '\n' | wc -l)
# Tier 3: Deep nesting OR in features/
if [ $FOLDER_DEPTH -ge 3 ] || [[ "$FOLDER" =~ features/ ]]; then
    TIER="tier3"
else
    TIER="tier2"
fi
```

---

## Document Size Management

### Size Thresholds

Based on Claude Code best practices and Vibe Coding principles:

| Tier | File | Max Lines | Max Tokens (Est.) | Action When Exceeded |
|------|------|-----------|-------------------|---------------------|
| **Tier 1** | CLAUDE.md | 300 lines | ~3000 tokens | Split to docs/ai-context/ |
| **Tier 2** | Component CONTEXT.md | 200 lines | ~2000 tokens | Archive old sections |
| **Tier 3** | Feature CONTEXT.md | 150 lines | ~1500 tokens | Compress or split by feature |

### Detection

```bash
# Count lines in a file
wc -l < file.md

# Estimate tokens (rough approximation: lines × 10)
LINES=$(wc -l < file.md)
TOKENS=$((LINES * 10))
```

### Auto-Management Actions

**Tier 1 (CLAUDE.md > 300 lines)**:
1. Move detailed sections to `docs/ai-context/`
2. Keep only quick-reference in CLAUDE.md
3. Use `@imports` for details when needed

**Tier 2 (CONTEXT.md > 200 lines)**:
1. Archive historical decisions to `{component}/HISTORY.md`
2. Keep only current architecture
3. Compress implementation details

**Tier 3 (CONTEXT.md > 150 lines)**:
1. Split by feature area
2. Create sub-CONTEXT.md files
3. Link from parent CONTEXT.md

### Integration with /03_close

When closing a plan (`/03_close`), document sizes are automatically checked:
- If threshold exceeded: Warning displayed
- User prompted to run `/91_document` for compression
- Auto-management can be applied with user confirmation

### Integration with /91_document

The `/91_document` command includes size management capabilities:

```bash
# Auto-manage document sizes
/91_document auto-compress
/91_document auto-split {file_path}
```

---

## Initialization

### New Projects

```bash
/92_init
```
Creates full 3-Tier from scratch:
- Tier 1: CLAUDE.md with detected tech stack
- docs/ai-context/: docs-overview.md, project-structure.md, system-integration.md
- Tier 2: CONTEXT.md for selected folders

### Existing Projects

```bash
/92_init
```
Merges existing documentation:
- Preserves existing CLAUDE.md content
- Adds new sections
- Creates docs/ai-context/
- Creates Tier 2 for selected folders

---

## Maintenance

### Auto-Sync After Implementation

```bash
/91_document auto-sync from {RUN_ID}
```

Updates:
- Tier 1: CLAUDE.md (last-updated, new sections)
- docs/ai-context/: project-structure.md, system-integration.md, docs-overview.md
- Tier 2/3: CONTEXT.md files
- Archives: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

### Manual Update for Folder

```bash
/91_document {folder_name}
```

Creates or updates CONTEXT.md for specific folder.

### Full Project Sync

```bash
/91_document
```

Updates all tiers for entire project.

---

## docs/ai-context/ Structure

### docs-overview.md

Lists all CONTEXT.md files and provides navigation.

### project-structure.md

Technology stack, directory layout, key files.

### system-integration.md

Component interactions, data flow, shared patterns, integration points.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Initialize system | `/92_init` |
| Auto-sync after work | `/91_document auto-sync from {RUN_ID}` |
| Update specific folder | `/91_document {folder_name}` |
| Full project sync | `/91_document` |

---

## See Also

- @.claude/templates/CONTEXT-tier2.md.template - Component template
- @.claude/templates/CONTEXT-tier3.md.template - Feature template
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
