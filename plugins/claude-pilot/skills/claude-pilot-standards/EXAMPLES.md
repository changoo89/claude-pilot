# Claude-Pilot Examples

> **Purpose**: Real-world examples with "good pattern" callouts
> **Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
> **Last Updated**: 2026-01-20

---

## VIBE Coding Skill Example

**File**: @.claude/skills/vibe-coding/SKILL.md

### Good Patterns

**✅ Quick Reference Table**
```markdown
| Target | Limit | Action |
| **Function** | ≤50 lines | Split functions |
```

**✅ Concise Principles**: SRP, DRY, KISS, Early Return

**✅ Cross-Reference**: @.claude/skills/vibe-coding/REFERENCE.md

**Size**: 40 lines ✅

---

## TDD Skill Example

**File**: @.claude/skills/tdd/SKILL.md

### Good Patterns

**✅ Purpose**: Execute TDD Red-Green-Refactor cycle
**✅ Quick Start**: When to use + code examples
**✅ Size**: 78 lines ✅

---

## 00_plan Command Example

**File**: @.claude/commands/00_plan.md

### Good Patterns

**✅ Frontmatter**: Action verbs, constraints
**✅ Phase Protection**: CAN/CANNOT DO lists
**✅ MANDATORY Marker**: Call AskUserQuestion
**✅ Methodology Link**: @.claude/skills/spec-driven-workflow/SKILL.md
**✅ GPT Delegation**: Trigger check table

---

## Coder Agent Example

**File**: @.claude/agents/coder.md

### Good Patterns

**✅ Frontmatter**: name, description, model, tools, skills
**✅ Mission**: TDD + Ralph Loop, isolated context
**✅ Methodology Links**: Phase references to SKILL.md
**✅ Completion**: `<CODER_COMPLETE>` or `<CODER_BLOCKED>`

---

## Cross-Reference Examples

### Good Patterns

**✅ Absolute**: @.claude/skills/tdd/SKILL.md
**✅ Descriptive**: Full methodology + link
**✅ Multiple**: Internal | External pipes

### Bad Patterns

**❌ Relative**: ../skills/tdd/SKILL.md
**❌ Non-Clickable**: "See TDD skill"

---

## Size Limit Compliance Examples

| File | Lines | Limit | Status |
|------|-------|-------|--------|
| `vibe-coding/SKILL.md` | 40 | 100 | ✅ |
| `tdd/SKILL.md` | 78 | 100 | ✅ |

**Extraction**: Move oversized sections to REFERENCE.md, link back

---

## Frontmatter Examples

### Skill
```yaml
name: vibe-coding
description: LLM-readable code standards. Functions ≤50 lines, files ≤200 lines, nesting ≤3 levels.
```
**Keys**: kebab-case, trigger keywords, size limits

### Command
```yaml
description: Analyze codebase and create SPEC-First execution plan (read-only)
argument-hint: "[task_description]"
allowed-tools: Read, Glob, Grep, Bash(git:*)
```
**Keys**: Action verbs, constraints, tool restrictions

### Agent
```yaml
name: coder
description: Implementation agent using TDD + Ralph Loop. Use proactively.
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash
skills: tdd, ralph-loop, vibe-coding
```
**Keys**: All fields, "use proactively", skills listed

---

## MANDATORY ACTION Marker Examples

**✅ Clear**: `⚠️ MANDATORY ACTION: YOU MUST invoke {Agent} NOW`
**✅ Contextual**: `🚨 MANDATORY: At completion, call AskUserQuestion`
**✅ Multi-Option**: A/B/C/D choices for user

---

## Completion Marker Examples

**Coder**: `<CODER_COMPLETE>` (all pass) | `<CODER_BLOCKED>` (max iterations)
**Plan-Reviewer**: `<PLAN_COMPLETE>` (approved) | `<PLAN_BLOCKED>` (gaps)

---

## Related Documentation

**Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
**Reference**: @.claude/skills/claude-pilot-standards/REFERENCE.md
**Templates**: @.claude/skills/claude-pilot-standards/TEMPLATES.md
