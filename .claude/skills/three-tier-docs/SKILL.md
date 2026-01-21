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

## Tier 1: CLAUDE.md

**Template**:
```markdown
# project-name

> **Version**: X.Y.Z | **Last Updated**: YYYY-MM-DD

---

## Quick Start

```bash
/install/command
/usage/example
```

---

## Two-Layer Documentation

**Plugin Layer** (CLAUDE.md): Architecture, features, distribution
**Project Layer** (CLAUDE.local.md): Project-specific config, structure

---

## Plugin Architecture

**Core Features**:
- Feature 1: Description
- Feature 2: Description

**Workflow**: Plan → Confirm → Execute → Review → Document

---

## Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Component A | Description | path/to/A |
| Component B | Description | path/to/B |

---

**Line Count**: X lines (Target: ≤200 lines)
```

**Content Rules**:
- ≤200 lines (use `wc -l CLAUDE.md` to verify)
- Essential info only
- No implementation details
- Link to CONTEXT.md for component details

---

## Tier 2: CONTEXT.md

**Template**:
```markdown
# Component Context

## Purpose
[What this component does]

## Key Files

| File | Purpose | Lines |
|------|---------|-------|
| file.ts | Description | N |

## Common Tasks

### Task 1
**Command**: `example command`
**Result**: Expected output

## Integration Points
- Depends on: [other components]
- Used by: [other components]

**Line Count**: X lines (Target: ≤100 lines)
```

**Content Rules**:
- ≤100 lines per file
- Component-specific context only
- Usage examples
- Integration points

---

## Tier 3: docs/ai-context/

**Purpose**: Comprehensive documentation for complex systems

**When to create**:
- Multi-component integration patterns
- System architecture documentation
- Advanced workflows
- Migration guides

**Example structure**:
```
docs/ai-context/
├── system-integration.md
├── agent-ecosystem.md
├── continuation-system.md
└── mcp-servers.md
```

**No line limit** - This is for deep documentation

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

## Verification

### Test Documentation Sync
```bash
# Verify Tier 1 exists
test -f CLAUDE.md

# Verify Tier 1 size
test $(wc -l < CLAUDE.md) -le 200

# Verify Tier 2 files exist
find . -name "CONTEXT.md" -type f

# Verify Tier 2 size
for f in $(find . -name "CONTEXT.md" -type f); do
  test $(wc -l < "$f") -le 100 || echo "Too large: $f"
done
```

---

## Related Skills

- **spec-driven-workflow**: Documentation in planning phase
- **code-quality-gates**: PreToolUse checks for .md creation

---

**Version**: claude-pilot 4.2.0
