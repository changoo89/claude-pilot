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

> Reference: [context-engineering-intro](https://github.com/coleam00/context-engineering-intro)
> Principle: "Context is the only lever for output quality"

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

### 2.2 Verification

```bash
# Update last-updated
sed -i "s/last-updated: .*/last-updated: $(date +%Y-%m-%d)/" CLAUDE.md

# Type check
npx tsc --noEmit
```

---

## Step 3: Context Engineering (Folder-Level CONTEXT.md)

> **Principle**: Targeted context > massive monolithic docs

### 3.1 Identify Meaningful Folders

Scan for folders that should have CONTEXT.md:

| Folder Pattern | Criteria |
|---------------|----------|
| `lib/`, `src/` | Core library modules |
| `lib/*/`, `src/*/` | Sub-modules with 3+ files |
| `components/*/` | Component groups |
| `pages/api/` | API routes |
| `types/` | Type definitions |
| Any folder | 3+ related files |

### 3.2 CONTEXT.md Template

For each meaningful folder, create/update:

```markdown
# {Folder Name} Context

> Last updated: {YYYY-MM-DD}

## Purpose

{1-2 sentences describing folder's responsibility}

## Quick Reference (L0)

### Key Files
| File | Purpose |
|------|---------|
| {file1} | {description} |
| {file2} | {description} |

### Common Tasks
- **Task 1**: Description → Command/Reference
- **Task 2**: Description → Command/Reference

## Architecture (L1)

### Component Relationships
```
[Component A] → [Component B] → [Component C]
```

### Data Flow
1. Input from [Source]
2. Processed by [Component]
3. Output to [Destination]

## Implementation Details (L2)

### Patterns Used
- **Pattern**: [Name] - Purpose and usage

### Dependencies
```typescript
// Internal
import { something } from '../related-module'

// External
import { library } from 'external-package'
```

## Integration Points

- **Imports from**: {folders}
- **Exports to**: {folders}

## Common Pitfalls

### Don't
- ❌ [Common mistake]

### Do
- ✅ [Best practice]
```

### 3.3 Auto-Update Rules

| Trigger | Action |
|---------|--------|
| New file added | Add to Key Files table |
| File deleted | Remove from Key Files |
| New pattern | Add to Patterns section |
| Import changes | Update Integration Points |

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

## Context Engineering
- Created: {new CONTEXT.md files}
- Updated: {modified CONTEXT.md files}

## TDD Artifacts Archived
- test-scenarios.md
- coverage-report.txt (X% overall, X% core)
- ralph-loop-log.md (N iterations)

## Verification
- [ ] CLAUDE.md syntax valid
- [ ] All CONTEXT.md files valid
- [ ] No broken links

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

- **Context Engineering**: `.claude/guides/context-engineering.md`
- **CONTEXT Template**: `.claude/templates/CONTEXT.md.template`
- **Ralph Loop TDD**: `.claude/guides/ralph-loop-tdd.md`
