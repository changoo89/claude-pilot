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

**3-Tier Documentation**: See @.claude/guides/3tier-documentation.md

---

## Step 0: Detect Mode

| Mode | Trigger | Action |
|------|---------|--------|
| Auto-Sync | `auto-sync from {RUN_ID}` | Load plan, execute Steps 1-5, archive artifacts |
| Folder | `[folder_name]` | Generate/update CONTEXT.md for folder |
| Manual | No args | Execute Steps 1-4 for entire project |

### 💡 OPTIONAL ACTION: Documenter Agent Invocation

> **For large documentation updates, you MAY invoke the documenter agent using the Task tool.**
> This is optional. Use this agent for complex documentation tasks requiring extensive analysis.

**OPTIONAL - USE AS NEEDED**:

```markdown
Task:
  subagent_type: documenter
  prompt: |
    Update documentation for the project:

    Mode: {MODE}
    RUN_ID: {RUN_ID} (if auto-sync)
    Folder: {FOLDER_NAME} (if folder mode)

    Execute full documentation sync:
    - CLAUDE.md (Tier 1) - update if project-level changes
    - Component CONTEXT.md (Tier 2) - generate/update for components
    - docs/ai-context/ - update project-structure.md, system-integration.md
    - Archive TDD artifacts (test-scenarios.md, coverage-report.txt, ralph-loop-log.md)

    Apply 3-Tier Documentation System:
    - Tier 1: CLAUDE.md (max 300 lines)
    - Tier 2: Component CONTEXT.md (max 200 lines)
    - Tier 3: Feature CONTEXT.md (max 150 lines)

    Return summary only.
```

**WHEN TO USE**: Large projects, complex updates, or when you want isolated context for documentation tasks.

---

## Step 1: Analyze Changes

### 1.1 Auto-Sync: Load Plan
```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

RUN_DIR="$PROJECT_ROOT/.pilot/plan/in_progress/${RUN_ID}"
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

| File | When | Content |
|------|------|---------|
| project-structure.md | New folders, tech stack changes | Git diff analysis |
| system-integration.md | Component interactions, dependencies | Import analysis |
| docs-overview.md | CONTEXT.md files added/removed | Find CONTEXT.md |

### 2.3 Verification
```bash
sed -i "s/last-updated: .*/last-updated: $(date +%Y-%m-%d)/" CLAUDE.md
npx tsc --noEmit
```

### 2.4 Document Size Management

**Purpose**: Ensure documents stay within size thresholds for optimal token usage.

**Size Thresholds**:

| Tier | File | Max Lines | Action When Exceeded |
|------|------|-----------|---------------------|
| **Tier 1** | CLAUDE.md | 300 lines | Split to docs/ai-context/ |
| **Tier 2** | Component CONTEXT.md | 200 lines | Archive old sections |
| **Tier 3** | Feature CONTEXT.md | 150 lines | Compress or split by feature |

**Auto-Detection**:

```bash
# Check Tier 1: CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    LINES=$(wc -l < CLAUDE.md)
    if [ "$LINES" -gt 300 ]; then
        echo "⚠️ CLAUDE.md exceeds 300 lines (current: $LINES)"
        echo "Recommendation: Move detailed sections to docs/ai-context/"
    fi
fi

# Check Tier 2/3: CONTEXT.md files
find . -name "CONTEXT.md" -type f | while read -r ctx_file; do
    LINES=$(wc -l < "$ctx_file")
    DEPTH=$(echo "$ctx_file" | tr '/' '\n' | wc -l)

    if [ $DEPTH -ge 3 ] || [[ "$ctx_file" =~ features/ ]]; then
        # Tier 3 (150 line limit)
        if [ "$LINES" -gt 150 ]; then
            echo "⚠️ $ctx_file exceeds 150 lines (current: $LINES)"
        fi
    else
        # Tier 2 (200 line limit)
        if [ "$LINES" -gt 200 ]; then
            echo "⚠️ $ctx_file exceeds 200 lines (current: $LINES)"
        fi
    fi
done
```

**Auto-Management Actions** (when triggered):

1. **Compress**: Summarize verbose sections, keep key information
2. **Split**: Create sub-files for large features
3. **Archive**: Move historical content to HISTORY.md
4. **Reorganize**: Restructure for better clarity

**Integration**: Automatically run when `/03_close` detects size thresholds, or manually with:
- `/91_document auto-compress` - Compress oversized documents
- `/91_document auto-split {file}` - Split a specific document

---

## Step 3: Context Engineering (Folder CONTEXT.md)

**3-Tier System**: See @.claude/guides/3tier-documentation.md

### 3.1 Identify Meaningful Folders

| Folder Pattern | Criteria | Tier |
|---------------|----------|------|
| `lib/`, `src/`, `app/` | Core modules | Tier 2 |
| `lib/*/`, `src/*/` | Sub-modules (3+ files) | Tier 2 |
| `features/*/` | Feature implementations | Tier 3 |
| Deep nested (`*/*/*/`) | Specific features | Tier 3 |

### 3.2 Templates

**Tier 2 (Component)** - @.claude/templates/CONTEXT-tier2.md.template
```markdown
# {Component Name} - Component Context (Tier 2)
## Purpose {Component responsibility}
## Key Files {Directory layout}
## Integration Points {Dependencies}
```

**Tier 3 (Feature)** - @.claude/templates/CONTEXT-tier3.md.template
```markdown
# {Feature Name} - Feature Context (Tier 3)
## Architecture & Patterns {Design, data flow}
## Implementation Decisions {Decision log}
## Code Examples {Common usage}
```

### 3.3 Auto-Update Rules

| Trigger | Action |
|---------|--------|
| New file | Add to Key Files table |
| File deleted | Remove from Key Files |
| New pattern | Add to Patterns section |
| Import changes | Update Integration Points |

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
| TS-1 | {name} | {path} | Pass |
## Coverage Summary
| Module | Coverage | Target | Status |
| Overall | X% | 80% | ✅/❌ |
```

**Update `$RUN_DIR/ralph-loop-log.md`**:
```markdown
# Ralph Loop Execution Log
| Iteration | Tests | Types | Lint | Coverage | Status |
```

---

## Step 5: Summary Report

```
📄 Documentation Full Auto-Sync Complete

## Core Updates
- CLAUDE.md (last-updated: YYYY-MM-DD)

## docs/ai-context/ Updates
- project-structure.md, system-integration.md, docs-overview.md

## Context Engineering (3-Tier)
### Tier 2 (Component): {component}/CONTEXT.md
### Tier 3 (Feature): {feature}/CONTEXT.md

## TDD Artifacts Archived
- test-scenarios.md, coverage-report.txt, ralph-loop-log.md

## Verification
- [ ] CLAUDE.md valid, [ ] docs/ai-context/ valid, [ ] CONTEXT.md valid

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

## Related Guides
- @.claude/guides/3tier-documentation.md - 3-Tier system overview
- @.claude/templates/CONTEXT-tier2.md.template - Component template
- @.claude/templates/CONTEXT-tier3.md.template - Feature template

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: `git rev-parse --abbrev-ref HEAD`
