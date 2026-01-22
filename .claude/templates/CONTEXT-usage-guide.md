# CONTEXT.md Template Usage Guide

## Overview

This template provides a standardized structure for CONTEXT.md files across the claude-pilot codebase. Standardization ensures consistency, discoverability, and maintainability.

## Template Location

```
.claude/templates/CONTEXT-template.md
```

## Quick Start

### Step 1: Copy Template

```bash
cp .claude/templates/CONTEXT-template.md .claude/{directory}/CONTEXT.md
```

### Step 2: Replace Template Variables

Replace all `{variables}` with actual content.

### Step 3: Verify Structure

Ensure all sections are present and complete.

## Template Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{Directory Name}` | Capitalized directory name | "Commands", "Agents", "Skills" |
| `{items}` | Plural item type | "commands", "agents", "skills" |
| `{item}` | Singular item type | "command", "agent", "skill" |

### Section-Specific Variables

#### Purpose Section
- `{Clear statement...}`: One-sentence purpose statement

#### Key Files Table
- `{file1}`, `{file2}`: File names (alphabetical order)
- `{purpose}`: Brief description of file's purpose
- `{count}`: Line count (use `wc -l filename`)
- `{usage}`: Usage context or description
- `{N}`: Total number of files
- `{total_lines}`: Sum of all line counts
- `{avg}`: Average lines per file

#### Common Tasks Section
- `{Task Name N}`: Action-oriented task name
- `{What the task does}`: Brief task description
- `@.claude/{path-to-file}`: Cross-reference to file
- `{Expected result}`: Output or outcome
- `{Step N}`: Process steps

#### Patterns Section
- `{Pattern Name N}`: Descriptive pattern name
- `{Description...}`: Pattern explanation
- `{Code example}`: Example code block
- `{Why this pattern exists}`: Rationale

## Section Guidelines

### 1. Purpose Section

**Length**: 2-3 sentences
**Content**: What the directory contains and its system role

**Example**:
```markdown
## Purpose

Slash commands for SPEC-First development workflow. Each command manages a specific phase of the development lifecycle: planning, confirmation, execution, completion, review, documentation, initialization, and publishing.
```

### 2. Key Files Table

**Requirements**:
- Alphabetical order by file name
- Columns: File, Purpose, Lines, Usage/Description
- Include total summary at bottom

**Example**:
```markdown
## Key Files

| File | Purpose | Lines | Workflow Phase | Description |
|------|---------|-------|----------------|-------------|
| `00_plan.md` | Create SPEC-First plan | 355 | Planning | Collect requirements, explore codebase |
| `01_confirm.md` | Confirm plan + gap detection | 315 | Planning | Review plan, verify requirements coverage |
| `02_execute.md` | Execute with TDD + Ralph Loop | 654 | Execution | Plan detection, parallel verification |

**Total**: 3 commands, 1324 lines (average: 441 lines per command)
```

**Line Count Script**:
```bash
# Get line count for all files
for f in *.md; do
  echo "$f: $(wc -l < "$f")"
done
```

### 3. Common Tasks Section

**Format**: Task → File → Output → Process
**Length**: 5-10 tasks
**Order**: Most common to least common

**Example**:
```markdown
## Common Tasks

### Create a Plan
- **Task**: Generate SPEC-First plan from user request
- **Command**: `/00_plan "implement user authentication"`
- **Output**: Plan file saved to `.pilot/plan/pending/{timestamp}_{work}_{topic}.md`
- **Process**:
  1. Step 0: Collect user requirements verbatim
  2. Step 1: Explorer and Researcher agents explore codebase (parallel)
  3. Step 2-6: Plan-Reviewer agent creates SPEC-First plan
  4. Step 7: Present plan summary with User Requirements section
  5. User reviews plan
```

### 4. Patterns Section

**Content**: Reusable patterns, conventions, best practices
**Format**: Pattern Name → Description → Example → Purpose

**Example**:
```markdown
## Patterns

### Agent Invocation Pattern
All commands use MANDATORY ACTION sections for reliable agent delegation:
```markdown
> **🚨 MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW with:
- Plan path
- Success criteria
- Key constraints
```

**Purpose**: Ensures agents are invoked with correct parameters every time.
```

### 5. Category Section (Optional)

**Use When**: Directory has distinct subcategories
**Format**: Hierarchical organization

**Example**:
```markdown
## Command Categories

### Planning Phase Commands
- `00_plan`: Create plan (read-only exploration)
- `01_confirm`: Review and approve plan

### Execution Phase Commands
- `02_execute`: Implement with TDD + Ralph Loop

### Completion Phase Commands
- `03_close`: Archive and commit
```

### 6. File Organization Section

**Content**: Naming conventions, size guidelines

**Example**:
```markdown
## File Organization

### Naming Convention
- **Workflow commands**: `00` through `03` (sequential execution)
- **Quality commands**: `90` through `99` (utilities)
- **Setup commands**: `92_init` (initialization only)

### Size Guidelines
**Target**: 150-200 lines per command

**When to split**:
- If command exceeds 200 lines
- Extract methodology to skills
- Use cross-references
```

### 7. See Also Section

**Requirements**:
- Use @ syntax for cross-references
- Group by type (commands, skills, agents)
- Include claude-code-standards.md

**Example**:
```markdown
## See Also

**Workflow guides**:
- @.claude/skills/confirm-plan/SKILL.md - User Requirements Collection methodology
- @.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First requirements methodology

**Implementation guides**:
- @.claude/skills/tdd/SKILL.md - Test-Driven Development cycle
- @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop

**Documentation standards**:
- @.claude/skills/coding-standards/SKILL.md - Official Claude Code standards
```

## Directory-Specific Examples

### Commands Directory

```markdown
# Commands Context

## Purpose

Slash commands for SPEC-First development workflow. Each command manages a specific phase of the development lifecycle.

## Key Files

| File | Purpose | Lines | Workflow Phase | Description |
|------|---------|-------|----------------|-------------|
| `00_plan.md` | Create SPEC-First plan | 355 | Planning | Plan generation workflow |
| `01_confirm.md` | Confirm plan + gap detection | 315 | Planning | Requirements verification |
| `02_execute.md` | Execute with TDD + Ralph Loop | 654 | Execution | Implementation workflow |

**Total**: 3 commands, 1324 lines (average: 441 lines per command)
```

### Agents Directory

```markdown
# Agents Context

## Purpose

Specialized agents with distinct capabilities, model allocations, and tool access. Agents are the execution engine of the claude-pilot workflow.

## Key Agents

| Agent | Model | Lines | Tools | Purpose | Usage |
|-------|-------|-------|-------|---------|-------|
| **explorer** | haiku | 60 | Glob, Grep, Read | Fast codebase exploration | `/00_plan` - Find files |
| **coder** | sonnet | 315 | Read, Write, Edit | TDD implementation | `/02_execute` - Red-Green-Refactor |

**Total**: 2 agents, 375 lines (average: 188 lines per agent)
```

### Guides Directory

```markdown
# Guides Context

## Purpose

Methodology guides providing detailed explanations of development workflows, patterns, and best practices.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `prp-framework.md` | SPEC-First requirements methodology | 245 | Planning phase |
| `test-environment.md` | Test framework auto-detection | 212 | Execution phase |

**Total**: 2 guides, 457 lines (average: 229 lines per guide)
```

### Skills Directory

```markdown
# Skills Context

## Purpose

Auto-discoverable capabilities that Claude Code uses to match user intent to appropriate methodologies.

## Key Skills

| Skill | SKILL.md | REFERENCE.md | Purpose | Trigger Keywords |
|-------|----------|--------------|---------|-----------------|
| `tdd` | Test-Driven Development | Advanced patterns | Red-Green-Refactor cycle | "implementing features" |

**Total**: 1 skill, 2 files (SKILL.md + REFERENCE.md)
```

## Cross-Reference Guidelines

### @ Syntax

Use @ syntax for all cross-references:

```markdown
**Related guides**:
- @.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First requirements
- @.claude/skills/tdd/REFERENCE.md - Test framework detection
```

### Link Clarity

- **Good**: `@.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First requirements methodology`
- **Bad**: `@.claude/skills/spec-driven-workflow/SKILL.md`

Include brief description after each link.

### Link Grouping

Group related links by type:

```markdown
**Workflow guides**:
- @.claude/skills/confirm-plan/SKILL.md
- @.claude/skills/spec-driven-workflow/SKILL.md

**Implementation guides**:
- @.claude/skills/tdd/SKILL.md
- @.claude/skills/ralph-loop/SKILL.md
```

## Quality Checklist

Before marking CONTEXT.md as complete:

- [ ] Purpose section is clear and concise
- [ ] Key Files table is alphabetically sorted
- [ ] Line counts are accurate (use `wc -l`)
- [ ] Total summary includes count and average
- [ ] Common Tasks cover main use cases
- [ ] Patterns section includes examples
- [ ] File Organization section includes naming conventions
- [ ] See Also section uses @ syntax
- [ ] All cross-references include descriptions
- [ ] Total file length is ≤200 lines (or justified if longer)

## Maintenance

### Update Frequency

Update CONTEXT.md when:
- Adding new files to directory
- Removing files from directory
- Significant file changes (>50 line difference)
- New patterns or conventions established

### Line Count Updates

Recalculate line counts after:
- Adding/removing files
- Major file refactoring
- Monthly maintenance (if needed)

### Verification

```bash
# Verify line counts match
for f in .claude/{directory}/*.md; do
  echo "$f: $(wc -l < "$f")"
done
```

## Common Pitfalls

### 1. Missing Line Counts

**Problem**: Key Files table missing line counts
**Solution**: Use `wc -l filename` to get accurate counts

### 2. Non-Alphabetical Order

**Problem**: Files not sorted alphabetically
**Solution**: Sort files by name in table

### 3. Missing Total Summary

**Problem**: No total count and average at bottom of table
**Solution**: Add `**Total**: N files, X lines (average: Y per file)`

### 4. Uncrossed References

**Problem**: Using standard markdown links instead of @ syntax
**Solution**: Use `@.claude/path/file.md` format

### 5. Missing Descriptions

**Problem**: Cross-references without descriptions
**Solution**: Add brief description after each link

## Template Validation

### Automated Check

```bash
# Check for required sections
required_sections=("Purpose" "Key Files" "Common Tasks" "Patterns" "See Also")
for section in "${required_sections[@]}"; do
  if ! grep -q "^## $section" CONTEXT.md; then
    echo "Missing section: $section"
  fi
done
```

### Manual Review

1. Read through CONTEXT.md for clarity
2. Verify all cross-references work
3. Check line counts accuracy
4. Ensure consistent formatting

## See Also

**Template Files**:
- @.claude/templates/CONTEXT-template.md - Standardized template

**Existing Examples**:
- @.claude/commands/CONTEXT.md - Commands directory
- @.claude/agents/CONTEXT.md - Agents directory
- @.claude/skills/CONTEXT.md - Guides directory
- @.claude/skills/CONTEXT.md - Skills directory

**Documentation Standards**:
- @.claude/skills/coding-standards/SKILL.md - Official Claude Code standards
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
