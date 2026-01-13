---
description: Update project documentation with Context Engineering (full auto, no prompts)
argument-hint: "[auto-sync from RUN_ID] | [folder_name] - auto-sync from action_plan or generate folder CONTEXT.md"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*)
---

# /91_document

_Update documentation with full auto-sync and hierarchical CONTEXT.md management._

---

## Core Philosophy

- **Full Auto**: No prompts, always full documentation sync
- **Context Engineering**: Generate/update folder-level CONTEXT.md files
- **Zero Intervention**: Complete documentation update without user interaction
- **Keep in Sync**: Documentation reflects actual implementation state

> Reference: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
> Principle: 3-Tier Documentation System - Foundation/Component/Feature hierarchy

---

## Auto-Load Context

@CLAUDE.md

---

## Step 0: Detect Mode

### 0.1 Auto-Sync Mode

If invoked with `auto-sync from {RUN_ID}`:
- Load plan context from `.pilot/plan/in_progress/{RUN_ID}/`
- Execute Steps 1-5 automatically
- Archive TDD artifacts

### 0.2 Folder Mode

If invoked with `[folder_name]`:
- Generate/update CONTEXT.md for specified folder
- Execute Step 3 only

### 0.3 Manual Mode

If invoked without args:
- Execute Steps 1-4 for entire project
- Full sync always (no partial options)

---

## Step 1: Analyze Changes

### 1.1 Auto-Sync: Read Plan Context

When in auto-sync mode:

```bash
RUN_DIR=".pilot/plan/in_progress/${RUN_ID}"
```

Load and extract:
- Plan requirements from `$RUN_DIR/plan.md`
- Success criteria achieved
- Ralph Loop results from `$RUN_DIR/ralph-loop-log.md`

### 1.2 Git-Based Analysis

```bash
# Recent commits
git log --oneline --since="7 days ago" --pretty=format:"%h %s" | head -20

# Changed files
git diff --name-only HEAD~10..HEAD
```

Identify:
- New features added
- Bug fixes
- Schema changes
- API endpoint changes
- New files/folders created

---

## Step 2: Update Core Documentation

### 2.1 CLAUDE.md Updates

| Section | When to Update |
|---------|---------------|
| `last-updated` | Always (today's date) |
| API Endpoints | New routes added |
| DB Schema | Table changes |
| Slash Commands | Command changes |
| Project Structure | New folders |

### 2.2 docs/ai-context/ Updates

Update the three Tier 1 supporting documents:

#### docs/ai-context/project-structure.md

When project structure changes:
- New folders created
- Technology stack changes
- Key files added/removed

```bash
# Detect changes
git diff --name-only HEAD~5..HEAD | grep -E '^src/|^lib/'
```

Update:
- Technology Stack table
- Directory Layout diagram
- Key Files table

#### docs/ai-context/system-integration.md

When component interactions change:
- New integration patterns
- Cross-component dependencies
- Data flow changes

```bash
# Detect import changes
git diff HEAD~5..HEAD | grep -E '^import|^require'
```

Update:
- Component Interactions diagram
- Data Flow section
- Integration Points table

#### docs/ai-context/docs-overview.md

When CONTEXT.md files are added/removed:
- Update Tier 2/3 lists
- Update document map

```bash
# Find all CONTEXT.md files
find . -name "CONTEXT.md" -type f | sort
```

### 2.3 Verification

```bash
# Update last-updated
sed -i "s/last-updated: .*/last-updated: $(date +%Y-%m-%d)/" CLAUDE.md

# Type check
npx tsc --noEmit
```

---

## Step 3: Context Engineering (Folder-Level CONTEXT.md)

> **Principle**: Targeted context > massive monolithic docs
> **3-Tier System**: Tier 2 (Component) vs Tier 3 (Feature)

### 3.1 Identify Meaningful Folders

Scan for folders that should have CONTEXT.md:

| Folder Pattern | Criteria | Tier |
|---------------|----------|------|
| `lib/`, `src/`, `app/` | Core library modules | Tier 2 |
| `lib/*/`, `src/*/` | Sub-modules with 3+ files | Tier 2 |
| `components/*/` | Component groups | Tier 2 |
| `features/*/` | Feature implementations | Tier 3 |
| `pages/api/` | API routes | Tier 2 |
| `hooks/`, `utils/` | Utility folders | Tier 2 |
| `types/` | Type definitions | Tier 2 |
| Deep nested (`*/*/*/`) | Specific features | Tier 3 |

### 3.2 Determine Tier Level

**Tier 2 (Component)** - Use for:
- Major architectural components
- Cross-cutting modules (utils, hooks, types)
- Integration points
- Folders with sub-folders

**Tier 3 (Feature)** - Use for:
- Specific feature implementations
- Deep nested folders (3+ levels)
- Individual components within larger modules
- Focused functionality

```bash
# Tier detection logic
FOLDER_DEPTH=$(echo "$FOLDER" | tr '/' '\n' | wc -l)
PARENT_FILES=$(find "$(dirname "$FOLDER")" -maxdepth 1 -type f | wc -l)

# Tier 3: Deep nesting OR in a features/ folder
if [ $FOLDER_DEPTH -ge 3 ] || [[ "$FOLDER" =~ features/ ]]; then
    TIER="tier3"
else
    TIER="tier2"
fi
```

### 3.3 CONTEXT.md Templates

#### Tier 2 Template (Component)

Use `.claude/templates/CONTEXT-tier2.md.template`

For architectural components and major modules:

| Section | Content Source |
|---------|----------------|
| Purpose | Folder name and files analysis |
| Key Component Structure | Directory scan |
| Implementation Highlights | Code pattern analysis |
| Integration Points | Import/export analysis |
| Development Guidelines | Best practices from code |

```markdown
# {Component Name} - Component Context (Tier 2)

> Purpose: Component-level architecture and integration
> Last Updated: {YYYY-MM-DD}
> Tier: 2 (Component)

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

#### Tier 3 Template (Feature)

Use `.claude/templates/CONTEXT-tier3.md.template`

For specific features and deep implementations:

| Section | Content Source |
|---------|----------------|
| Architecture & Patterns | Code structure analysis |
| Integration & Performance | Dependency and performance analysis |
| Implementation Decisions | Decision log |
| Code Examples | Common patterns extracted |

```markdown
# {Feature Name} - Feature Context (Tier 3)

> Purpose: Feature-level implementation details
> Last Updated: {YYYY-MM-DD}
> Tier: 3 (Feature)

## Architecture & Patterns
{Design patterns, data flow, state}

## Integration & Performance
{Dependencies, performance characteristics}

## Implementation Decisions
{Decision log, trade-offs}

## Code Examples
{Common usage, edge cases}
```

### 3.4 Auto-Update Rules

| Trigger | Action | Tier |
|---------|--------|------|
| New file added | Add to Key Files table | Both |
| File deleted | Remove from Key Files | Both |
| New pattern | Add to Patterns section | Both |
| Import changes | Update Integration Points | Tier 2 |
| Performance change | Update Performance section | Tier 3 |
| Decision made | Add to Decision Log | Tier 3 |

---

## Step 4: Archive TDD Artifacts (Auto-Sync Mode)

When in auto-sync mode, archive to `{RUN_DIR}/`:

### 4.1 Test Coverage Report

```bash
npm run test -- --coverage > "$RUN_DIR/coverage-report.txt" 2>&1
```

### 4.2 Test Scenarios Documentation

Create `$RUN_DIR/test-scenarios.md`:

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

### 4.3 Ralph Loop Log

Update `$RUN_DIR/ralph-loop-log.md`:

```markdown
# Ralph Loop Execution Log

| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
| 1 | ... | ... | ... | ...% | ... |
```

---

## Step 5: Summary Report

**Output format** (always generated):

```
📄 Documentation Full Auto-Sync Complete

## Core Updates
- CLAUDE.md (last-updated: YYYY-MM-DD)
- {list of sections updated}

## docs/ai-context/ Updates
- project-structure.md (technology stack, directory layout)
- system-integration.md (component interactions)
- docs-overview.md (document map, Tier 2/3 lists)

## Context Engineering (3-Tier)
### Tier 2 (Component) - Created/Updated:
- {component}/CONTEXT.md
- {component}/CONTEXT.md

### Tier 3 (Feature) - Created/Updated:
- {feature}/CONTEXT.md
- {feature}/CONTEXT.md

## TDD Artifacts Archived
- test-scenarios.md
- coverage-report.txt (X% overall, X% core)
- ralph-loop-log.md (N iterations)

## Verification
- [ ] CLAUDE.md syntax valid
- [ ] docs/ai-context/ files valid
- [ ] All CONTEXT.md files valid
- [ ] Tier 2/3 templates applied correctly

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

## Workflow Position

```
/02_execute ──auto──▶ /91_document ──▶ /03_close
                         │
               [Full Auto-Sync]
               [Context Engineering]
               [TDD Artifact Archive]
```

---

## Quick Reference

### Auto-Sync Invocation (from 02_execute)

```
Skill: 91_document
Args: auto-sync from {RUN_ID}
```

### Folder Mode

```
/91_document lib
/91_document components/admin
```

### Manual Invocation

```
/91_document
```

All modes execute full sync - no partial options.

---

## References

- **3-Tier Docs**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Tier 2 Template**: `.claude/templates/CONTEXT-tier2.md.template`
- **Tier 3 Template**: `.claude/templates/CONTEXT-tier3.md.template`
- **General Template**: `.claude/templates/CONTEXT.md.template` (L0/L1/L2 system)
- **Init Command**: `/92_init` (initialize 3-Tier system for existing projects)
- **Review Extensions**: `.claude/guides/review-extensions.md`
