---
name: vibe-coding
description: LLM-readable code standards for maintainable code. Functions ≤50 lines, files ≤200 lines, nesting ≤3 levels. Apply SRP, DRY, KISS, Early Return patterns during refactoring.
---

# SKILL: Vibe Coding (Code Quality Standards)

> **Purpose**: Enforce LLM-readable code standards for maintainable, testable, comprehensible code
> **Target**: Coder Agent during Green/Refactor phases

---

## Quick Start

### When to Use This Skill
- Refactor code after tests pass (Green phase)
- Reduce function complexity
- Improve code readability
- Apply SOLID principles
- Reduce nesting levels

### Quick Reference
```bash
# Check function lines: awk '/^def / {start=NR} /^def / && start {print NR-start}' file.py
# Check file lines: wc -l file.ts
# Targets: Functions ≤50, Files ≤200, Nesting ≤3
```

## What This Skill Covers

### In Scope
- Code size limits (functions, files, nesting)
- SRP, DRY, KISS, Early Return pattern
- AI rules for code generation

### Out of Scope
- Test writing → @.claude/skills/tdd/SKILL.md
- Autonomous iteration → @.claude/skills/ralph-loop/SKILL.md

## Core Concepts

### Size Limits

| Target | Limit | Action When Exceeded |
|--------|-------|----------------------|
| **Function** | ≤50 lines | Split functions |
| **File** | ≤200 lines | Extract modules |
| **Nesting** | ≤3 levels | Early return |

### Principles

#### SRP - Single Responsibility Principle
- One function = one responsibility
- Each function should do one thing well
- If a function does multiple things, split it

#### DRY - Don't Repeat Yourself
- No duplicate code blocks
- Extract common logic into reusable functions
- Use parameters to vary behavior instead of copying code

#### KISS - Keep It Simple, Stupid
- Simplest solution that works
- Avoid over-engineering
- Prefer clear code over clever code

#### Early Return Pattern
- Return early to reduce nesting
- Keep happy path at top level
- Avoid deep conditional nesting

## Further Reading

**Internal**: @.claude/skills/vibe-coding/REFERENCE.md - SOLID principles, refactoring patterns, code smells | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop

**External**: [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) | [Refactoring by Martin Fowler](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesney-Signature/dp/0201485672)
