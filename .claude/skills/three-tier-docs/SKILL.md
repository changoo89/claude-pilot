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
# Tier 1: Update CLAUDE.md (project instructions)
# - Architecture overview
# - Key features
# - Quick start guide

# Tier 2: Update component CONTEXT.md
# - Component purpose
# - Key files
# - Usage examples

# Tier 3: Update docs/ai-context/
# - System integration details
# - Implementation patterns
# - Advanced guides
```

---

## What This Skill Covers

### In Scope
- 3-tier documentation hierarchy (CLAUDE.md, CONTEXT.md, docs/)
- Size limits and content organization
- Auto-sync patterns after code changes

### Out of Scope
- Detailed templates → @.claude/skills/three-tier-docs/REFERENCE.md
- Verification scripts → docs-verify.sh
- Git documentation workflow → @.claude/skills/git-master/SKILL.md

---

## Core Concepts

### 3-Tier Hierarchy

**Tier 1: CLAUDE.md** (Project Root)
- **Purpose**: Project-level instructions for Claude
- **Audience**: Claude (primary), Users (reference)
- **Content**: Architecture, features, quick start
- **Size**: ≤200 lines
- **Scope**: Essential info only

**Tier 2: CONTEXT.md** (Component Directory)
- **Purpose**: Component-specific context
- **Audience**: Claude working on that component
- **Content**: Purpose, key files, patterns
- **Size**: ≤100 lines per file
- **Scope**: Component-level context

**Tier 3: docs/ai-context/** (Detailed Reference)
- **Purpose**: Deep-dive documentation
- **Audience**: Claude needing detailed info
- **Content**: System integration, advanced patterns
- **Size**: Unlimited
- **Scope**: Comprehensive reference

### Content Organization

| Tier | Location | Type | Update Frequency |
|------|----------|------|------------------|
| L0 | Root | CLAUDE.md | Project changes |
| L1 | Component dirs | CONTEXT.md | Component changes |
| L2 | docs/ai-context/ | Detailed docs | As needed |
| L3 | External | External references | Rarely |

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
   # Tier 1
   test $(wc -l < CLAUDE.md) -le 200

   # Tier 2
   for f in **/CONTEXT.md; do
     test $(wc -l < "$f") -le 100
   done
   ```

---

## Verification Failure Recovery

**Line count violations**: CLAUDE.md >200 lines → Extract to docs/ai-context/ | CONTEXT.md >100 lines → Move examples or simplify

**Broken cross-references**: Check file exists with `test -f {path}` | Use absolute paths (e.g., `@.claude/skills/...`)

**Missing frontmatter**: Add required fields (name, description) | Validate with `yamllint {file}`

**Recovery Steps**: Read error from docs-verify.sh → Find violating file → Apply fix from REFERENCE.md → Re-verify

---

## Further Reading

**Internal**: @.claude/skills/three-tier-docs/REFERENCE.md - Complete templates, examples, verification patterns | @.claude/skills/documentation-best-practices/SKILL.md - Size limits, quality standards

**External**: [Documentation System Design](https://documentation.divio.com/) | [Writing for AI](https://docs.anthropic.com/claude/docs/guide-to-writing-good-docs)

---

**Version**: claude-pilot 4.4.11
