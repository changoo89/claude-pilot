# Claude-Pilot Examples

> **Purpose**: Real-world examples with "good pattern" callouts
> **Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
> **Last Updated**: 2026-01-20

---

## VIBE Coding Skill Example

**File**: @.claude/skills/vibe-coding/SKILL.md

### Good Patterns

**✅ Progressive Disclosure**: Quick reference table for fast lookup
```markdown
## Quick Reference

| Target | Limit | Action |
|--------|-------|--------|
| **Function** | ≤50 lines | Split functions |
| **File** | ≤200 lines | Extract modules |
| **Nesting** | ≤3 levels | Early return |
```

**✅ Concise Principles**: Bullet points for core concepts
```markdown
## Principles

- **SRP**: One function = one responsibility
- **DRY**: No duplicate code blocks, extract common logic
- **KISS**: Simplest solution that works, avoid over-engineering
- **Early Return**: Return early to reduce nesting, keep happy path at top
```

**✅ Cross-Reference Link**: Points to detailed reference
```markdown
**Internal**: @.claude/skills/vibe-coding/REFERENCE.md - SOLID principles, refactoring patterns
```

**Size**: 40 lines (well under 100-line limit)

---

## TDD Skill Example

**File**: @.claude/skills/tdd/SKILL.md

### Good Patterns

**✅ Clear Purpose Statement**
```markdown
> **Purpose**: Execute TDD Red-Green-Refactor cycle for feature implementation
> **Target**: Coder Agent implementing features with test-first methodology
```

**✅ Quick Start Section**
```markdown
## Quick Start

### When to Use This Skill
- Implement new feature with test coverage
- Fix bug with regression tests
```

**✅ Code Examples**: Inline examples for each phase
```python
def test_add_two_numbers():
    result = calculator.add(2, 3)
    assert result == 5
```

**Size**: 78 lines (within 100-line limit)

---

## 00_plan Command Example

**File**: @.claude/commands/00_plan.md

### Good Patterns

**✅ Description Frontmatter with Action Verbs**
```yaml
---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
---
```

**✅ Phase Boundary Protection**
```markdown
## Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan, Ask questions
- **CANNOT DO**: Edit files, Write files, Create code, Implement
```

**✅ MANDATORY ACTION Marker**
```markdown
> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion`
```

**✅ Methodology Extraction**
```markdown
**Full methodology**: @.claude/guides/prp-framework.md
```

**✅ GPT Delegation Trigger Check**
```markdown
## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

| Trigger | Signal | Action |
|---------|--------|--------|
| Architecture decision | Keywords: "tradeoffs", "design" | Delegate to GPT Architect |
```

---

## Coder Agent Example

**File**: @.claude/agents/coder.md

### Good Patterns

**✅ Complete Frontmatter**
```yaml
---
name: coder
description: Implementation agent using TDD + Ralph Loop...
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
skills: tdd, ralph-loop, vibe-coding, git-master
---
```

**✅ Clear Mission Statement**
```markdown
You are the Coder Agent. Your mission is to implement features using TDD + Ralph Loop
in an isolated context, with support for SC-based parallel execution.
```

**✅ Methodology Links**
```markdown
### Phase 2: TDD Cycle
> **Methodology**: @.claude/skills/tdd/SKILL.md

### Phase 3: Ralph Loop
> **Methodology**: @.claude/skills/ralph-loop/SKILL.md
```

**✅ Completion Markers**
```markdown
**Output**: Return `<CODER_COMPLETE>` or `<CODER_BLOCKED>`
```

---

## Cross-Reference Examples

### Good Patterns

**✅ Absolute Paths**
```markdown
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

**✅ Descriptive Text**
```markdown
**Full methodology**: @.claude/guides/prp-framework.md
```

**✅ Multiple Links**
```markdown
**Internal**: @.claude/skills/tdd/SKILL.md | @.claude/skills/ralph-loop/SKILL.md

**External**: [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
```

### Bad Patterns

**❌ Relative Paths**
```markdown
See ../skills/tdd/SKILL.md (breaks when moved)
```

**❌ Non-Clickable**
```markdown
See the TDD skill for methodology (not clickable)
```

---

## Size Limit Compliance Examples

### Within Limits (Good)

| File | Lines | Limit | Status |
|------|-------|-------|--------|
| `vibe-coding/SKILL.md` | 40 | 100 | ✅ |
| `tdd/SKILL.md` | 78 | 100 | ✅ |
| `explorer.md` (agent) | 60 | 200 | ✅ |

### Extraction Pattern (When Over Limit)

**BEFORE** (in command):
```markdown
## TDD Methodology (200 lines)
[Full TDD explanation]
```

**AFTER** (extracted to skill):
```markdown
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

**Result**: Command stays concise, methodology centralized

---

## Frontmatter Examples

### Skill Frontmatter (Good)
```yaml
---
name: vibe-coding
description: LLM-readable code standards. Functions ≤50 lines, files ≤200 lines, nesting ≤3 levels. SRP, DRY, KISS, Early Return.
---
```

**Why It Works**:
- `name` is kebab-case
- `description` has trigger keywords ("LLM-readable", "code standards")
- Size limits clearly stated
- Principles mentioned for auto-discovery

### Command Frontmatter (Good)
```yaml
---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch
---
```

**Why It Works**:
- Action verbs: "Analyze", "create"
- Scenarios: "SPEC-First execution plan"
- Constraint: "(read-only)"
- Argument hint clear

### Agent Frontmatter (Good)
```yaml
---
name: coder
description: Implementation agent using TDD + Ralph Loop for feature development. Use proactively for implementation tasks.
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
skills: tdd, ralph-loop, vibe-coding, git-master
---
```

**Why It Works**:
- All required fields present
- `description` has "use proactively" (Claude Code official pattern)
- `model` specified
- `tools` appropriate for role
- `skills` listed

---

## MANDATORY ACTION Marker Examples

### Good Usage

**✅ Clear and Specific**
```markdown
> **⚠️ MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW
```

**✅ Contextual**
```markdown
> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion` before ANY phase transition
```

**✅ Multi-Option**
```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan)
  D) Run /02_execute (start implementation)
```

---

## Completion Marker Examples

### Coder Agent
```markdown
**Output**:
- `<CODER_COMPLETE>`: All SC met, quality gates pass
- `<CODER_BLOCKED>`: Max iterations reached, needs intervention
```

### Plan-Reviewer Agent
```markdown
**Output**:
- `<PLAN_COMPLETE>`: Plan approved, no gaps
- `<PLAN_BLOCKED>`: BLOCKING gaps found
```

---

## Related Documentation

**Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
**Reference**: @.claude/skills/claude-pilot-standards/REFERENCE.md
**Templates**: @.claude/skills/claude-pilot-standards/TEMPLATES.md
