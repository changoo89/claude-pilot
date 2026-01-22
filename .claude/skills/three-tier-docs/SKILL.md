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
# Tier 1: 3개 Entry Point 문서 동기화
# - CLAUDE.md (≤200 lines)
# - docs/ai-context/project-structure.md
# - docs/ai-context/docs-overview.md

# Tier 2: Component CONTEXT.md (≤100 lines)
# - Purpose, key files, patterns

# Tier 3: Feature CONTEXT.md (≤150 lines)
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
- Verification scripts → docs-verify.sh
- Git documentation workflow → @.claude/skills/git-master/SKILL.md

---

## Core Concepts

### 3-Tier Hierarchy

**Tier 1: Entry Points** (3개 파일)
- `CLAUDE.md` - 아키텍처, 기능, Quick Start (≤200 lines)
- `docs/ai-context/project-structure.md` - 기술 스택, 파일 트리
- `docs/ai-context/docs-overview.md` - 문서 네비게이션, Tier 맵핑
- **필수**: CLAUDE.md 상단에 나머지 2개 파일 참조 포함

**Tier 2: CONTEXT.md** (Component Directory)
- **Purpose**: 컴포넌트별 컨텍스트
- **Content**: Purpose, key files, patterns
- **Size**: ≤100 lines per file
- **Scope**: Component-level context

**Tier 3: CONTEXT.md** (Feature Directory)
- **Purpose**: 기능별 구현 세부사항
- **Content**: Implementation details, deep-dive
- **Size**: ≤150 lines per file
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
