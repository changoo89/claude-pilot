---
description: Update project documentation with Context Engineering (full auto, no prompts)
argument-hint: "[auto-sync from RUN_ID] | [folder_name] - auto-sync from action_plan or generate folder CONTEXT.md"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*)
---

# /document

_Update documentation with full auto-sync and hierarchical CONTEXT.md management._

## Core Philosophy

- **Full Auto**: No prompts, always full documentation sync
- **Context Engineering**: Generate/update folder-level CONTEXT.md files
- **Zero Intervention**: Complete documentation update without user interaction
- **Keep in Sync**: Documentation reflects actual implementation state

**3-Tier Documentation**: See @.claude/guides/3tier-documentation.md

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before documentation

| Trigger | Signal | Action |
|---------|--------|--------|
| Complex documentation | 3+ component CONTEXT.md files affected | Delegate to GPT Architect |
| User explicitly requests | "ask GPT", "consult GPT" | Delegate to GPT Architect |

**Delegation Flow**: STOP → MATCH expert → READ prompt → CHECK Codex → EXECUTE `codex-sync.sh` → CONFIRM

**Graceful Fallback**:
```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0
fi
```

**See**: @.claude/rules/delegator/triggers.md for full guide

---

## Step 0: Detect Mode

| Mode | Trigger | Action |
|------|---------|--------|
| Auto-Sync | `auto-sync from {RUN_ID}` | Load plan, execute Steps 1-5, archive artifacts |
| Folder | `[folder_name]` | Generate/update CONTEXT.md for folder |
| Manual | No args | Execute Steps 1-4 for entire project |

### 💡 OPTIONAL ACTION: Documenter Agent Invocation

> **For large documentation updates, you MAY invoke the documenter agent using the Task tool.**

```markdown
Task:
  subagent_type: documenter
  prompt: |
    Update documentation: Mode {MODE}, RUN_ID {RUN_ID}, Folder {FOLDER_NAME}
    - CLAUDE.md (Tier 1, max 300 lines)
    - Component CONTEXT.md (Tier 2, max 200 lines)
    - docs/ai-context/ updates
    - Archive TDD artifacts
    Return summary only.
```

**WHEN TO USE**: Large projects, complex updates

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

**Size Thresholds**: Tier 1 (CLAUDE.md): 300 lines, Tier 2 (Component CONTEXT.md): 200 lines, Tier 3 (Feature CONTEXT.md): 150 lines

**Auto-Detection**:
```bash
# Check Tier 1
if [ -f "CLAUDE.md" ]; then
    LINES=$(wc -l < CLAUDE.md)
    [ "$LINES" -gt 300 ] && echo "⚠️ CLAUDE.md exceeds 300 lines (current: $LINES)"
fi

# Check Tier 2/3
find . -name "CONTEXT.md" -type f | while read -r ctx_file; do
    LINES=$(wc -l < "$ctx_file")
    DEPTH=$(echo "$ctx_file" | tr '/' '\n' | wc -l)
    [ $DEPTH -ge 3 ] && [ "$LINES" -gt 150 ] && echo "⚠️ $ctx_file exceeds 150 lines"
    [ $DEPTH -lt 3 ] && [ "$LINES" -gt 200 ] && echo "⚠️ $ctx_file exceeds 200 lines"
done
```

**Actions**: Compress, Split, Archive, or Reorganize

**Manual triggers**: `/document auto-compress` or `/document auto-split {file}`

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

**Tier 2 (Component)**: Purpose, Key Files, Integration Points

**Tier 3 (Feature)**: Architecture & Patterns, Implementation Decisions, Code Examples

**Templates**: @.claude/templates/CONTEXT-tier2.md.template, @.claude/templates/CONTEXT-tier3.md.template

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

**test-scenarios.md**: Test ID, Scenario, File, Status

**ralph-loop-log.md**: Iteration, Tests, Types, Lint, Coverage, Status

---

## Step 5: Summary Report

```
📄 Documentation Full Auto-Sync Complete

## Core Updates
- CLAUDE.md (last-updated: YYYY-MM-DD)

## docs/ai-context/ Updates
- project-structure.md, system-integration.md, docs-overview.md

## Context Engineering (3-Tier)
- Tier 2 (Component): {component}/CONTEXT.md
- Tier 3 (Feature): {feature}/CONTEXT.md

## TDD Artifacts Archived
- test-scenarios.md, coverage-report.txt, ralph-loop-log.md

## Verification
- CLAUDE.md valid, docs/ai-context/ valid, CONTEXT.md valid

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
/02_execute ──auto──▶ /document ──▶ /03_close
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
