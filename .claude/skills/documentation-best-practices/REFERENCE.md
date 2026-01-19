---
name: documentation-best-practices
description: Detailed Claude Code documentation patterns, examples, and external references. Use for deep documentation improvements.
---

# REFERENCE: Documentation Best Practices

> **Purpose**: Deep dive on Claude Code documentation patterns with examples
> **Target**: Documentation authors improving quality and structure

---

## Quick Start

### When to Use This Reference
- Refactoring existing documentation
- Creating complex documentation (multi-file systems)
- Troubleshooting documentation discoverability issues
- Establishing team documentation standards

### Quick Reference

| Pattern | Good | Bad | Why |
|---------|------|-----|-----|
| Command size | 100 lines | 400 lines | Faster context processing |
| Skill description | "Use when implementing TDD" | "About TDD methodology" | Trigger-rich for auto-discovery |
| Cross-references | @.claude/skills/tdd/SKILL.md | See tdd skill | Clickable navigation |
| Frontmatter | All skills have it | Missing on some | Auto-discovery fails |

## What This Reference Covers

### In Scope
- Detailed examples for each file type
- Good/bad pattern comparisons
- Cross-reference strategies
- External best practices
- Common pitfalls and solutions

### Out of Scope
- Basic file structure → @.claude/skills/documentation-best-practices/SKILL.md
- Test writing → @.claude/skills/tdd/SKILL.md
- Code quality → @.claude/skills/vibe-coding/SKILL.md

## Detailed Examples

### CLAUDE.md Structure

**Good Example** (focused, under 400 lines):

```markdown
# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-15
> **Version**: 3.3.1

---

## Project Overview

### One-Line Description
Template for Claude Code projects with SPEC-First workflow

### Technology Stack
Framework: Claude Code CLI
Language: TypeScript
...

## Quick Start

### For New Tasks
1. Planning: `/00_plan "describe your task"`
2. Confirmation: `/01_confirm`
3. Execution: `/02_execute`
4. Completion: `/03_close`

### Common Commands
| Task | Command | Description |
|------|---------|-------------|
| Create plan | `/00_plan` | Generate SPEC-First plan |
...

## Project Structure

```
project-root/
├── .claude/
│   ├── commands/     # Slash commands
│   ├── guides/       # Methodology guides
│   └── agents/       # Agent configs
...
```

## Development Workflow

> **Methodology**: See @.claude/guides/prp-framework.md

### SPEC-First Development
1. **What**: Functionality requirements
2. **Why**: Business value and rationale
3. **How**: Implementation strategy
...

## Context Engineering

> **Details**: @.claude/guides/3tier-documentation.md

- **L0** (Immediate): Quick reference
- **L1** (Structural): Architecture
- **L2** (Detailed): Implementation
- **L3** (Reference): Deep dives
```

**Bad Example** (too long, mixed concerns):

```markdown
# Project Guide (450+ lines)

[Contains everything: methodology, tutorials, API docs, troubleshooting]

## TDD Methodology (200 lines of detailed explanation)
[Should be in @.claude/skills/tdd/SKILL.md]

## Git Workflow (150 lines of commit examples)
[Should be in @.claude/skills/git-master/SKILL.md]

## Directory Structure (nested explanations)
[Should be in CONTEXT.md files]
```

**Key Principles**:
- Extract methodology to guides
- Keep tables for quick reference
- Use "> **Details**: @path" for expanded content
- Focus on project-specific standards

### Command Structure

**Good Example** (focused, 100 lines):

```markdown
---
description: Execute implementation with TDD + Ralph Loop. Use after plan confirmation to implement features.
---

# Execute Plan: TDD + Ralph Loop

## Purpose
Implement planned features using Test-Driven Development and autonomous iteration.

## Prerequisites
- Plan confirmed in `.pilot/plan/in_progress/`
- All BLOCKING findings resolved
- Tests auto-detected (pytest, npm test, go test, cargo test)

## Workflow

### Phase 1: Discovery
Read plan file, find related files, confirm integration points.

> **⚠️ MANDATORY ACTION**: YOU MUST invoke Coder Agent NOW with:
> - Plan path
> - Success criteria
> - Key constraints

### Phase 2: Implementation
Coder Agent executes TDD cycle for each SC.

> **Methodology**: @.claude/skills/tdd/SKILL.md

### Phase 3: Ralph Loop
Coder Agent iterates until all quality gates pass.

> **Methodology**: @.claude/skills/ralph-loop/SKILL.md

## Verification
- [ ] All tests pass
- [ ] Coverage 80%+ (core 90%+)
- [ ] Type check clean
- [ ] Lint clean
```

**Bad Example** (too long, mixed concerns):

```markdown
# Execute Plan (400+ lines)

## What is TDD? (100 lines)
[Redundant - covered in skill]

## Ralph Loop Explained (150 lines)
[Redundant - covered in skill]

## How to Write Tests (100 lines)
[Redundant - covered in skill]

## The Actual Workflow (buried at end)
```

**Key Principles**:
- Keep workflow steps clear
- Extract methodology to skills
- Use cross-references (> **Methodology**: @path)
- Preserve MANDATORY ACTION wording

### Skill Structure

**Good SKILL.md Example** (80-100 lines):

```markdown
---
name: tdd
description: Test-Driven Development cycle (Red-Green-Refactor). Use when implementing features with test coverage.
---

# SKILL: Test-Driven Development (TDD)

> **Purpose**: Execute TDD Red-Green-Refactor cycle
> **Target**: Coder Agent implementing features

---

## Quick Start

### When to Use
- Implementing new feature with tests
- Fixing bug with regression tests
- Refactoring code safely

### Quick Reference
```bash
# Red: Write failing test
pytest tests/test_feature.py -k "SC-1"  # FAIL

# Green: Implement minimal code
[Implement feature]

# Refactor: Improve quality
[Refactor code]

# Verify: All tests pass
pytest  # ALL PASS
```

## Core Concepts

### The TDD Cycle

**Phase 1: Red** - Write Failing Test
```python
def test_add_two_numbers():
    result = calculator.add(2, 3)
    assert result == 5
```
Run test → Confirm FAILS (❌)

**Phase 2: Green** - Minimal Implementation
```python
def add(a, b):
    return a + b  # Just enough to pass
```
Run test → Confirm PASSES (✅)

**Phase 3: Refactor** - Improve Quality
```python
def add(a: int, b: int) -> int:
    """Add two integers with type safety."""
    return a + b
```
Run ALL tests → Confirm ALL PASS (✅)

### Why TDD Matters
- Tests drive design (API from usage perspective)
- Regression safety (refactor without fear)
- Living documentation (tests show behavior)
- Fast feedback (catch issues immediately)

## Further Reading

**Internal**: @.claude/skills/tdd/REFERENCE.md - Advanced patterns
**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
```

**Good REFERENCE.md Example** (250-300 lines):

```markdown
---
name: tdd
description: Advanced TDD patterns, test doubles, and legacy code strategies. Use for complex testing scenarios.
---

# REFERENCE: Test-Driven Development

## Advanced Patterns

### Test-Driven Development Patterns

#### Transformation Priority Premise
Order transformations from simplest to most complex:
1. ({} -> nil) - Null to nil
2. (nil -> constant) - Nil to constant
3. (constant -> constant+) - Add to constant
4. (constant -> scalar) - Extract to variable
...

### Test Doubles

| Type | Purpose | When to Use |
|------|---------|-------------|
| Dummy | Fill parameter lists | When parameter not used |
| Stub | Provide canned answers | When testing deterministic paths |
| Spy | Verify calls | When checking interaction |
| Mock | Verify behavior | When complex interaction |
| Fake | Working implementation | When real system too slow |

### Legacy Code Strategies

#### Sprout Method
```python
# Before (hard to test)
def process_order(order):
    # 100 lines of logic
    calculate_discount(order)
    # More logic

# After (sprout new testable method)
def process_order(order):
    # Existing logic
    _calculate_new_discount(order)
    # More logic

def _calculate_new_discount(order):  # New, testable
    # Extracted logic
```

#### Seam Creation
```python
# Before (direct dependency)
class OrderProcessor:
    def save(self, order):
        Database.save(order)  # Hard to test

# After (seam for testing)
class OrderProcessor:
    def __init__(self, db=None):
        self.db = db or Database

    def save(self, order):
        self.db.save(order)  # Injectable for testing
```

## External Resources

- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
- [Test-Driven Development by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
```

**Bad Skill Examples**:

```markdown
# Bad SKILL.md (300+ lines)
[Contains detailed examples, external links, advanced patterns]
[Should be in REFERENCE.md]

# Bad REFERENCE.md (50 lines)
[Only basic concepts]
[Should be in SKILL.md]
```

**Key Principles**:
- SKILL.md = Quick reference (when to use, how to start)
- REFERENCE.md = Deep dive (patterns, examples, external links)
- Clear separation between essential and detailed

### Agent Structure

**Good Agent Example** (150-200 lines):

```markdown
---
name: coder
description: Implement features using TDD + Ralph Loop. Use for feature implementation, bug fixes, refactoring.
model: sonnet
tools: Read, Write, Edit, Bash
skills: tdd, ralph-loop, vibe-coding
---

You are the Coder Agent. Your mission is to implement features using TDD + Ralph Loop in an isolated context.

## Core Principles
- **Context isolation**: ~80K tokens context window
- **TDD discipline**: Red-Green-Refactor for each SC
- **Ralph Loop**: Iterate until quality gates pass
- **Concise summary**: Return ONLY summary to orchestrator

## Workflow

### Phase 1: Discovery
1. Read plan file
2. Find related files (Glob, Grep)
3. Confirm integration points

### Phase 2: TDD Cycle (for each Success Criterion)

#### Red: Write Failing Test
1. Generate test stub
2. Write assertions
3. Run tests → confirm RED

#### Green: Minimal Implementation
1. Write ONLY enough code to pass
2. Run tests → confirm GREEN

#### Refactor: Clean Up
1. Apply Vibe Coding standards
2. Run ALL tests → confirm GREEN

### Phase 3: Ralph Loop
1. Run verification (tests, type-check, lint, coverage)
2. If all pass → check completion
3. If failures → fix and continue
4. Max 7 iterations

## Output Format

```markdown
## Coder Agent Summary

### Implementation Complete ✅
- Success Criteria Met: SC-1, SC-2, SC-3
- Files Changed: 3

### Verification Results
- Tests: ✅ All pass
- Coverage: ✅ 85%

### Completion Marker
<CODER_COMPLETE>
```

## Important Notes
- Do NOT create commits (unless explicitly requested)
- Do NOT batch multiple code changes before testing
- Return summary only (1K tokens max)
```

**Key Principles**:
- Clear mission statement
- Model allocation rationale in description
- Tool and skill list in frontmatter
- Concise workflow (don't repeat skill content)
- Clear output format

### CONTEXT.md Structure

**Good Example** (120-150 lines):

```markdown
# Commands Context

## Purpose
Slash commands for SPEC-First development workflow.

## Key Files

| File | Purpose | Lines | Workflow |
|------|---------|-------|----------|
| `00_plan.md` | Create SPEC-First plan | 434 → 150 | Planning |
| `01_confirm.md` | Confirm plan + gap detection | 281 | Planning |
| `02_execute.md` | Execute with TDD + Ralph Loop | 679 → 150 | Execution |
| `03_close.md` | Archive and commit | 364 → 150 | Completion |
| `90_review.md` | Multi-angle code review | 376 → 150 | Quality |
| `91_document.md` | Sync documentation | 288 | Maintenance |
| `92_init.md` | Initialize new project | 209 | Setup |
| `999_publish.md` | Sync templates + deploy | 470 → 150 | Release |

## Common Tasks

### Create a Plan
- **Task**: Generate SPEC-First plan from user request
- **Command**: `/00_plan "implement user authentication"`
- **Output**: Plan file in `.pilot/plan/pending/`

### Confirm a Plan
- **Task**: Review plan, detect gaps, resolve BLOCKING issues
- **Command**: `/01_confirm`
- **Output**: Plan moved to `.pilot/plan/in_progress/`

### Execute Implementation
- **Task**: Implement features using TDD + Ralph Loop
- **Command**: `/02_execute`
- **Output**: Feature code with tests, coverage 80%+

### Close and Archive
- **Task**: Archive plan, create commit
- **Command**: `/03_close`
- **Output**: Plan in `.pilot/plan/done/`, git commit created

## Patterns

### Plan Flow Pattern
```
Request → /00_plan → Pending → /01_confirm → In Progress → /02_execute → /03_close → Done
```

### Agent Invocation Pattern
All commands use MANDATORY ACTION sections for reliable agent delegation:
```markdown
> **⚠️ MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW
```

### Cross-Reference Pattern
Methodology details extracted to guides/skills:
```markdown
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

## See Also
- @.claude/guides/prp-framework.md - SPEC-First methodology
- @.claude/guides/gap-detection.md - Gap detection review
- @.claude/guides/parallel-execution.md - Agent orchestration
- @.claude/agents/CONTEXT.md - Agent specifications
```

**Key Principles**:
- Purpose statement at top
- File table with lines and workflow phase
- Common tasks with commands
- Pattern documentation
- Cross-references to related docs

## Cross-Reference Strategies

### Internal Cross-References

**Format**: `@.claude/{path}/{file}`

**Best Practices**:
- Use absolute paths from `.claude/` root
- Link to specific files (not folders)
- Include link text: `@.claude/skills/tdd/SKILL.md - TDD methodology`
- Verify targets exist before committing

**Examples**:
```markdown
Good:
> **Methodology**: @.claude/skills/tdd/SKILL.md
See @.claude/guides/parallel-execution.md for patterns

Bad:
See the TDD skill (not clickable)
See .claude/skills/tdd (ambiguous file)
```

### Cross-Reference Verification

**Manual check**:
```bash
# Find all cross-references
grep -rh "@.claude/" .claude/ | grep -v "^#"

# Verify each target exists
ls @.claude/skills/tdd/SKILL.md
```

**Common Issues**:
- Broken links (target file renamed/moved)
- Ambiguous links (folder instead of file)
- Missing link text (no context)

## Common Pitfalls and Solutions

### Pitfall 1: Commands Too Long

**Problem**: Commands exceed 150 lines with methodology explanations

**Solution**: Extract to guides/skills
```markdown
BEFORE (in command):
## TDD Methodology
[200 lines of explanation]

AFTER (in command):
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

### Pitfall 2: Missing Frontmatter

**Problem**: Skills/agents missing frontmatter, auto-discovery fails

**Solution**: Add complete frontmatter
```yaml
---
name: {skill-name}
description: {trigger-rich description for auto-discovery}
model: {haiku|sonnet|opus}  # agents only
tools: [tool list]  # agents only
skills: [skill list]  # agents only
---
```

### Pitfall 3: Weak Descriptions

**Problem**: Descriptions don't trigger semantic matching

**Solution**: Use trigger-rich keywords
```yaml
Bad:
description: About test driven development

Good:
description: Test-Driven Development cycle (Red-Green-Refactor). Use when implementing features with test coverage.
```

### Pitfall 4: Missing CONTEXT.md

**Problem**: No navigation for folders, poor discoverability

**Solution**: Create CONTEXT.md for each major folder
```markdown
# {Folder} Context

## Purpose
[What this folder does]

## Key Files
| File | Purpose | Lines |
|------|---------|-------|

## Common Tasks
- **Task**: Description → Command

## Patterns
[Key patterns]

## See Also
[Related docs]
```

### Pitfall 5: Duplicated Content

**Problem**: Same content in multiple files

**Solution**: Single source of truth
```markdown
Command: > **Methodology**: @.claude/skills/tdd/SKILL.md
Skill: Core concepts only
Reference: Detailed examples
```

## External Best Practices

### Anthropic's Recommendations

From [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices):

1. **Keep commands concise** (50-150 lines)
   - Extract methodology to guides
   - Focus on workflow steps
   - Use cross-references

2. **CLAUDE.md as entry point**
   - Single source of truth
   - Quick reference tables
   - Link to CONTEXT.md files

3. **Skill auto-discovery**
   - Trigger-rich descriptions
   - Semantic matching
   - Action keywords

4. **Agent model allocation**
   - Haiku: Fast, repetitive tasks
   - Sonnet: Balanced implementation
   - Opus: Deep reasoning

### Industry Standards

From [My LLM coding workflow 2026 - Addy Osmani](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e):

1. **File size limits**
   - Functions ≤50 lines
   - Files ≤200 lines
   - Nesting ≤3 levels

2. **Clear naming**
   - Descriptive file names
   - Action-oriented commands
   - Semantic skill names

3. **Documentation hierarchy**
   - Quick reference at top
   - Detailed sections below
   - External links at end

## Further Reading

**Internal**:
- @.claude/skills/documentation-best-practices/SKILL.md - Quick reference for documentation standards
- @.claude/guides/claude-code-standards.md - Official directory structure and conventions
- @.claude/guides/3tier-documentation.md - Complete 3-Tier documentation system

**External**:
- [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code overview - Official Docs](https://code.claude.com/docs/en/overview)
- [My LLM coding workflow 2026 - Addy Osmani](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e)
- [Agentic Coding Best Practices - DEV.to](https://dev.to/timesurgelabs/agentic-coding-vibe-coding-best-practices-b4b)
- [Refactoring.guru](https://refactoring.guru/)
