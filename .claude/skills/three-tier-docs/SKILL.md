---
name: three-tier-docs
description: Use after code changes. Syncs CLAUDE.md, CONTEXT.md, and docs/ai-context/ automatically.
---

# SKILL: Three-Tier Documentation

> **Purpose**: Auto-sync documentation across 3 tiers (CLAUDE.md → CONTEXT.md → docs/)
> **Target**: Documenter agent after implementation

---

## Quick Start

### When to Use This Skill
- After implementing features
- After refactoring code
- After creating new components
- Run via `/document` command

### Quick Reference
```bash
# Tier 1: Sync 3 Entry Point documents
# - CLAUDE.md (≤200 lines)
# - docs/ai-context/project-structure.md
# - docs/ai-context/docs-overview.md

# Tier 2: Component CONTEXT.md (≤200 lines)
# - Purpose, key files, patterns

# Tier 3: Feature CONTEXT.md (≤200 lines)
# - Implementation details
```

---

## What This Skill Covers

### In Scope
- 3-tier documentation hierarchy (CLAUDE.md, CONTEXT.md, docs/)
- Size limits and content organization
- Auto-sync patterns after code changes

### Out of Scope
- Detailed templates → @.claude/skills/three-tier-docs/REFERENCE.md
- Verification skills → docs-verify
- Git documentation workflow → @.claude/skills/git-master/SKILL.md

---

## Core Concepts

### 3-Tier Hierarchy

**Tier 1: Entry Points** (3 files only)
- `CLAUDE.md` - Architecture, features, Quick Start (≤200 lines)
- `docs/ai-context/project-structure.md` - Tech stack, file tree (≤200 lines)
- `docs/ai-context/docs-overview.md` - Documentation navigation, Tier mapping (≤200 lines)
- **Required**: CLAUDE.md top section must reference the other 2 files
- **Constraint**: docs/ai-context/ folder must contain exactly 2 files

**Tier 2: CONTEXT.md** (Component Directory)
- **Purpose**: Component context
- **Content**: Purpose, key files, patterns
- **Size**: ≤200 lines per file
- **Scope**: Component-level context

**Tier 3: CONTEXT.md** (Feature Directory)
- **Purpose**: Feature implementation details
- **Content**: Implementation details, deep-dive
- **Size**: ≤200 lines per file
- **Scope**: Feature-level context

### Content Organization

| Tier | Location | Files | Update Frequency |
|------|----------|-------|------------------|
| 1 | Root + docs/ai-context/ | CLAUDE.md, project-structure.md, docs-overview.md | Project changes |
| 2 | Component dirs | CONTEXT.md | Component changes |
| 3 | Feature dirs | CONTEXT.md | Feature changes |

---

## Auto-Sync Pattern

### After Implementation

1. **Check what changed**:
   ```bash
   git diff --name-only | grep -E '\.(ts|js|md)$'
   ```

2. **Update affected tiers**:
   - Architecture change? → Tier 1 (CLAUDE.md)
   - Component change? → Tier 2 (CONTEXT.md)
   - New pattern? → Tier 3 (docs/)

3. **Verify tier compliance**:
   ```bash
   # Invoke the docs-verify skill
   # Validates:
   # - All 3 Tier 1 docs ≤200 lines
   # - docs/ai-context/ has exactly 2 files
   # - Tier 2/3 CONTEXT.md files ≤200 lines
   ```

---

## Verification Failure Recovery

**Line count violations**: CLAUDE.md >200 lines → Extract to docs/ai-context/ | CONTEXT.md >200 lines → Move examples or simplify

**Broken cross-references**: Check file exists with `test -f {path}` | Use absolute paths (e.g., `@.claude/skills/...`)

**Missing frontmatter**: Add required fields (name, description) | Validate with `yamllint {file}`

**Recovery Steps**: Invoke docs-verify skill → Find violating file → Apply fix from REFERENCE.md → Re-verify

---

## Further Reading

**Internal**: @.claude/skills/three-tier-docs/REFERENCE.md - Complete templates, examples, verification patterns | @.claude/skills/documentation-best-practices/SKILL.md - Size limits, quality standards

**External**: [Documentation System Design](https://documentation.divio.com/) | [Writing for AI](https://docs.anthropic.com/claude/docs/guide-to-writing-good-docs)

---

**Version**: claude-pilot 4.4.11
