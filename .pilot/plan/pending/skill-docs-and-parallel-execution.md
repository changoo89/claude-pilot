# Skill Documentation Restructure & Parallel Execution Enhancement

- Generated: 2026-01-15
- Work: skill-docs-and-parallel-execution

---

## User Requirements

1. **Skill Document Length**: Current skill files (500+ lines) exceed official recommendations (~50-100 lines). Need restructuring for context window optimization.
2. **Parallel Execution**: Clarify and enhance coder agent parallel execution in `/02_execute`.

---

## PRP Analysis

### What (Functionality)

**Objective**: Restructure skill documents using Progressive Disclosure pattern and enhance parallel execution documentation.

**Scope**:
- **In scope**: 4 SKILL.md files, 02_execute.md parallel section
- **Out of scope**: Command files, guide files, template files

### Why (Context)

**Current Problem**:
- Skill files average 500+ lines (official recommendation: 50-100 lines)
- Every session loads full skill content into context window
- Token waste and slower responses
- Parallel coder execution pattern exists but may be unclear

**Desired State**:
- SKILL.md: ~60 lines (Quick Reference only)
- REFERENCE.md: Detailed content (loaded on-demand via @import)
- Clear parallel execution guidance in 02_execute.md

**Business Value**:
- Reduced token usage per session
- Faster response times
- Clearer parallel execution for efficiency

### How (Approach)

- **Phase 1**: Create REFERENCE.md files for each skill (extract detailed content)
- **Phase 2**: Restructure SKILL.md to Quick Reference format
- **Phase 3**: Enhance 02_execute.md parallel execution section
- **Phase 4**: Verification (line counts, @import links)

---

## Success Criteria

SC-1: All SKILL.md files ≤80 lines
- Verify: `wc -l .claude/skills/*/SKILL.md`
- Expected: Each file ≤80 lines

SC-2: All REFERENCE.md files created with detailed content
- Verify: `ls .claude/skills/*/REFERENCE.md`
- Expected: 4 files exist

SC-3: SKILL.md contains @import link to REFERENCE.md
- Verify: `grep "REFERENCE.md" .claude/skills/*/SKILL.md`
- Expected: Link present in each file

SC-4: 02_execute.md has clear parallel execution guidance
- Verify: `grep -A5 "Parallel Coder" .claude/commands/02_execute.md`
- Expected: Clear checklist and pattern

---

## Test Environment (Detected)

- Project Type: Python
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/skills/vibe-coding/SKILL.md` | Code quality standards | 1-584 | Longest skill file |
| `.claude/skills/git-master/SKILL.md` | Git workflow | 1-517 | Second longest |
| `.claude/skills/ralph-loop/SKILL.md` | Autonomous loop | 1-507 | Third longest |
| `.claude/skills/tdd/SKILL.md` | TDD methodology | 1-443 | Fourth longest |
| `.claude/commands/02_execute.md` | Execution command | 135-250 | Parallel section exists |

### Research Findings

| Source | Topic | Key Insight |
|--------|-------|-------------|
| code.claude.com/docs/en/memory | CLAUDE.md guidelines | "Keep lean, use @imports" |
| code.claude.com/docs/en/slash-commands | Command organization | "50 lines for simple, modular for complex" |
| Anthropic blog | Best practices | ".claude/rules/ for 300+ line projects" |
| code.claude.com/docs/en/sub-agents | Parallel execution | "Single message with multiple Task calls = parallel" |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| SKILL.md + REFERENCE.md split | Official @import pattern | Single file with sections |
| Keep REFERENCE.md in same folder | Discoverability | Separate docs/ folder |
| ~60 lines target for SKILL.md | Between 50-80 recommended range | Strict 50 lines |

---

## Architecture

### File Changes

```
.claude/skills/
├── vibe-coding/
│   ├── SKILL.md      (584 → ~60 lines)
│   └── REFERENCE.md  (NEW, ~520 lines)
├── git-master/
│   ├── SKILL.md      (517 → ~60 lines)
│   └── REFERENCE.md  (NEW, ~450 lines)
├── ralph-loop/
│   ├── SKILL.md      (507 → ~60 lines)
│   └── REFERENCE.md  (NEW, ~440 lines)
└── tdd/
    ├── SKILL.md      (443 → ~60 lines)
    └── REFERENCE.md  (NEW, ~380 lines)

.claude/commands/
└── 02_execute.md     (enhance Step 2.3 parallel section)
```

### SKILL.md New Structure

```markdown
---
name: {skill-name}
description: {brief description}
---

# SKILL: {Name}

> **Purpose**: {one-line purpose}
> **Target**: {when to use}
> **Last Updated**: {date}

---

## Quick Start (30 seconds)

### When to Use This Skill
{3-5 bullet points}

### Quick Reference
{essential commands/rules table}

---

## What This Skill Covers

### In Scope
{bullet list}

### Out of Scope
{bullet list with @references}

---

## Core Concepts

{1-2 most important concepts only}

---

## Further Reading

### Internal Documentation
- @.claude/skills/{name}/REFERENCE.md - {description}

### External Resources
{1-2 external links}
```

---

## Execution Plan

### Phase 1: Create REFERENCE.md Files (SC-2)

For each skill (vibe-coding, git-master, ralph-loop, tdd):
1. Read current SKILL.md
2. Extract detailed sections (Workflows, Patterns, Troubleshooting, FAQ)
3. Create REFERENCE.md with extracted content
4. Keep frontmatter and section headers

### Phase 2: Restructure SKILL.md Files (SC-1, SC-3)

For each skill:
1. Keep: frontmatter, Quick Start, Core Concepts (condensed)
2. Remove: Detailed workflows, patterns, troubleshooting, FAQ
3. Add: "Further Reading" section with @REFERENCE.md link
4. Target: ~60 lines

### Phase 3: Enhance 02_execute.md (SC-4)

1. Find Step 2.3 section
2. Add clear parallel execution checklist
3. Add explicit "single message = parallel" guidance
4. Add example Task invocation pattern

### Phase 4: Verification

1. Count lines in all SKILL.md files
2. Verify REFERENCE.md files exist
3. Verify @import links work
4. Test 02_execute.md clarity

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | SKILL.md line count | `wc -l` | ≤80 each | Manual | N/A |
| TS-2 | REFERENCE.md exists | `ls` | 4 files | Manual | N/A |
| TS-3 | @import links | `grep` | Links present | Manual | N/A |
| TS-4 | Parallel guidance | `grep` | Pattern found | Manual | N/A |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Content loss during split | Low | High | Review before/after |
| Broken @import links | Low | Medium | Verify relative paths |
| Missing context in SKILL.md | Medium | Medium | Keep essential Quick Start |

---

## Constraints

- No changes to command files except 02_execute.md
- English only for all documentation
- Must follow official Claude Code patterns (@import, .claude/ structure)
- Preserve all original content in REFERENCE.md

---

## STOP

Plan saved to `.pilot/plan/pending/skill-docs-and-parallel-execution.md`

Run `/02_execute` to begin implementation.
