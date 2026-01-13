---
description: Update project documentation with Context Engineering (full auto, no prompts)
argument-hint: "[auto-sync from RUN_ID] | [folder_name] - auto-sync from action_plan or generate folder CONTEXT.md"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*)
---

# /91_document

_Update documentation with full auto-sync and hierarchical CONTEXT.md management._

## Core Philosophy

- **Full Auto**: No prompts, always full documentation sync
- **Context Engineering**: Generate/update folder-level CONTEXT.md files
- **Zero Intervention**: Complete documentation update without user interaction
- **Keep in Sync**: Documentation reflects actual implementation state

> Reference: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Auto-Load Context

@CLAUDE.md

---

## Step 0: Detect Mode

| Mode | Trigger | Action |
|------|---------|--------|
| Auto-Sync | `auto-sync from {RUN_ID}` | Load plan, execute Steps 1-5, archive artifacts |
| Folder | `[folder_name]` | Generate/update CONTEXT.md for folder |
| Manual | No args | Execute Steps 1-4 for entire project |

---

## Step 1: Analyze Changes

### 1.1 Auto-Sync: Load Plan
```bash
RUN_DIR=".pilot/plan/in_progress/${RUN_ID}"
```
Load: Plan requirements, Success criteria, Ralph Loop results

### 1.2 Git Analysis
```bash
git log --oneline --since="7 days ago" | head -20
git diff --name-only HEAD~10..HEAD
```
Identify: New features, Bug fixes, Schema changes, API changes, New files

---

## Step 2: Update Core Documentation

### 2.1 CLAUDE.md Updates

| Section | When to Update |
|---------|---------------|
| `last-updated` | Always |
| API Endpoints | New routes |
| DB Schema | Table changes |
| Slash Commands | Command changes |
| Project Structure | New folders |

### 2.2 docs/ai-context/ Updates

**@docs/ai-context/project-structure.md** - When: New folders, tech stack changes, key files added/removed
```bash
git diff --name-only HEAD~5..HEAD | grep -E '^src/|^lib/'
```

**@docs/ai-context/system-integration.md** - When: Component interactions, cross-component dependencies, data flow changes
```bash
git diff HEAD~5..HEAD | grep -E '^import|^require'
```

**@docs/ai-context/docs-overview.md** - When: CONTEXT.md files added/removed
```bash
find . -name "CONTEXT.md" -type f | sort
```

### 2.3 Verification
```bash
sed -i "s/last-updated: .*/last-updated: $(date +%Y-%m-%d)/" CLAUDE.md
npx tsc --noEmit
```

---

## Step 3: Context Engineering (Folder CONTEXT.md)

> **3-Tier System**: Tier 2 (Component) vs Tier 3 (Feature)

### 3.1 Identify Meaningful Folders

| Folder Pattern | Criteria | Tier |
|---------------|----------|------|
| `lib/`, `src/`, `app/` | Core modules | Tier 2 |
| `lib/*/`, `src/*/` | Sub-modules with 3+ files | Tier 2 |
| `components/*/` | Component groups | Tier 2 |
| `features/*/` | Feature implementations | Tier 3 |
| `pages/api/`, `hooks/`, `utils/`, `types/` | Utility/API folders | Tier 2 |
| Deep nested (`*/*/*/`) | Specific features | Tier 3 |

### 3.2 Tier Detection

```bash
FOLDER_DEPTH=$(echo "$FOLDER" | tr '/' '\n' | wc -l)
# Tier 3: Deep nesting OR in features/
if [ $FOLDER_DEPTH -ge 3 ] || [[ "$FOLDER" =~ features/ ]]; then
    TIER="tier3"
else
    TIER="tier2"
fi
```

### 3.3 Templates

**Tier 2 (Component)** - @.claude/templates/CONTEXT-tier2.md.template
```markdown
# {Component Name} - Component Context (Tier 2)
> Purpose: Component-level architecture | Tier: 2
## Purpose {Component responsibility}
## Key Component Structure {Directory layout, key files}
## Implementation Highlights {Core patterns, architectural decisions}
## Integration Points {Dependencies, dependents}
## Development Guidelines {When to work here, constraints}
```

**Tier 3 (Feature)** - @.claude/templates/CONTEXT-tier3.md.template
```markdown
# {Feature Name} - Feature Context (Tier 3)
> Purpose: Feature-level implementation | Tier: 3
## Architecture & Patterns {Design patterns, data flow, state}
## Integration & Performance {Dependencies, performance}
## Implementation Decisions {Decision log, trade-offs}
## Code Examples {Common usage, edge cases}
```

### 3.4 Auto-Update Rules

| Trigger | Action | Tier |
|---------|--------|------|
| New file | Add to Key Files table | Both |
| File deleted | Remove from Key Files | Both |
| New pattern | Add to Patterns section | Both |
| Import changes | Update Integration Points | Tier 2 |
| Performance change | Update Performance | Tier 3 |
| Decision made | Add to Decision Log | Tier 3 |

---

## Step 4: Archive TDD Artifacts (Auto-Sync Mode)

```bash
npm run test -- --coverage > "$RUN_DIR/coverage-report.txt" 2>&1
```

**Create `$RUN_DIR/test-scenarios.md`**:
```markdown
# Test Scenarios
## Implemented Tests
| ID | Scenario | File | Status |
|----|----------|------|--------|
| TS-1 | {name} | {path} | Pass |
## Coverage Summary
| Module | Coverage | Target | Status |
|--------|----------|--------|--------|
| Overall | X% | 80% | ✅/❌ |
| Core | X% | 90% | ✅/❌ |
```

**Update `$RUN_DIR/ralph-loop-log.md`**:
```markdown
# Ralph Loop Execution Log
| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
```

---

## Step 5: Summary Report

```
📄 Documentation Full Auto-Sync Complete

## Core Updates
- CLAUDE.md (last-updated: YYYY-MM-DD)
- {sections updated}

## docs/ai-context/ Updates
- project-structure.md, system-integration.md, docs-overview.md

## Context Engineering (3-Tier)
### Tier 2 (Component): {component}/CONTEXT.md
### Tier 3 (Feature): {feature}/CONTEXT.md

## TDD Artifacts Archived
- test-scenarios.md, coverage-report.txt (X% overall), ralph-loop-log.md (N iterations)

## Verification
- [ ] CLAUDE.md valid, [ ] docs/ai-context/ valid, [ ] CONTEXT.md valid, [ ] Templates applied

Ready for: /03_close
```

---

## Success Criteria

| Check | Verification | Expected |
|-------|--------------|----------|
| Last-updated current | `grep "last-updated" CLAUDE.md` | Today's date |
| No broken links | Link check | 0 broken |
| CONTEXT.md exists | Priority folders | All covered |
| TDD artifacts | `ls $RUN_DIR/` | 3 files |

---

## Workflow
```
/02_execute ──auto──▶ /91_document ──▶ /03_close
               [Full Auto-Sync + Context Engineering + TDD Archive]
```

---

## Quick Reference

**Auto-Sync**: `Skill: 91_document` | `Args: auto-sync from {RUN_ID}`
**Folder**: `/91_document lib` or `/91_document components/admin`
**Manual**: `/91_document`

All modes execute full sync - no partial options

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- @.claude/templates/CONTEXT-tier2.md.template
- @.claude/templates/CONTEXT-tier3.md.template
- @.claude/templates/CONTEXT.md.template
- `/92_init` (initialize 3-Tier system)
- @.claude/guides/review-extensions.md
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
