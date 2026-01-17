---
name: documentation-best-practices
description: Claude Code documentation standards for CLAUDE.md, commands, skills, agents. Use when creating or reviewing documentation files.
---

# SKILL: Documentation Best Practices

> **Purpose**: Apply Claude Code official standards for creating and reviewing documentation
> **Target**: Anyone creating CLAUDE.md, commands, skills, guides, or agents

---

## Quick Start

### When to Use This Skill
- Creating new documentation (CLAUDE.md, command, skill, agent)
- Reviewing existing documentation for quality
- Restructuring documentation to follow best practices
- Improving documentation discoverability

### Quick Reference

| File Type | Max Lines | Key Sections | Frontmatter Required |
|-----------|-----------|--------------|---------------------|
| **CLAUDE.md** | 400+ | Project overview, quick start, structure | No |
| **Command** | 150 | Description, workflow, MANDATORY ACTION | description (trigger-rich) |
| **SKILL.md** | 100 | Quick start, core concepts, further reading | name, description |
| **REFERENCE.md** | 300 | Detailed examples, patterns, external links | name, description |
| **Guide** | 300 | Purpose, quick reference, core concepts | No |
| **Agent** | 200 | Role, workflow, output format | name, description, model, tools |

## What This Skill Covers

### In Scope
- CLAUDE.md structure and precedence rules
- Command size limits and frontmatter standards
- Skill auto-discovery via description
- Agent model allocation
- File size targets for all documentation types

### Out of Scope
- Test writing methodology → @.claude/skills/tdd/SKILL.md
- Code quality standards → @.claude/skills/vibe-coding/SKILL.md
- Git workflow → @.claude/skills/git-master/SKILL.md

## Core Concepts

### CLAUDE.md: Project Entry Point

**Purpose**: Single source of truth for project standards, workflows, and structure

**Required Sections**:
- Project Overview (one-line description, tech stack, current status)
- Quick Start (planning, confirmation, execution, completion)
- Project Structure (directory layout with descriptions)
- Development Workflow (SPEC-First, TDD, Ralph Loop)
- Context Engineering (3-Tier documentation)
- Testing Strategy (coverage targets, running tests)
- Quality Standards (type safety, linting, commits)
- Environment Setup (prerequisites, installation, env vars)

**Best Practices**:
- Keep it under 400 lines (extract details to guides)
- Use tables for quick reference
- Include project-specific notes at end
- Link to CONTEXT.md files for navigation

### Command Standards

**Size Limit**: 50-150 lines (Anthropic recommendation)

**When to Extract to Guides**:
- Methodology explanations (>50 lines)
- Repeated patterns across commands
- Background information

**Frontmatter** (auto-discovery):
```yaml
---
description: {trigger-rich description for slash command discovery}
---
```

**Description Quality**:
- Contains action keywords: "plan", "execute", "review", "document"
- Mentions specific scenarios: "TDD cycle", "Ralph Loop", "commit changes"
- Under 200 characters

**Standard Structure**:
```markdown
---
description: Brief trigger-rich description
---

# Command Name

## Purpose
[What this command does]

## Prerequisites
[Required state before running]

## Workflow
### Phase 1: [Name]
> **⚠️ MANDATORY ACTION**: [Required step]

### Phase 2: [Name]
[Continue workflow...]

## Verification
[Success criteria]
```

### Skill Standards

**Auto-Discovery Mechanism**:
- Skills are auto-discovered via frontmatter `description`
- Description contains trigger keywords for semantic matching
- Example: "Use when implementing features with test coverage"

**Frontmatter** (required):
```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

**File Pair Pattern**:
- `SKILL.md`: Quick reference (~100 lines)
  - Quick start (when to use, quick reference)
  - Core concepts (essential patterns)
  - Further reading (internal + external links)
- `REFERENCE.md`: Deep dive (~300 lines)
  - Detailed examples
  - Good/bad patterns
  - External references

### Agent Standards

**Model Allocation Strategy**:

| Model | Agents | Purpose | Rationale |
|-------|--------|---------|-----------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient | Repetitive/structured tasks |
| **Sonnet** | coder, tester, plan-reviewer | Balance quality/speed | Complex implementation |
| **Opus** | code-reviewer | Deep reasoning | Critical review (async bugs, memory leaks) |

**Frontmatter** (required):
```yaml
---
name: {agent-name}
description: {clear purpose statement}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list if any]
---
```

**Standard Structure**:
```markdown
---
[frontmatter]
---

You are the {Agent} Agent. Your mission is...

## Core Principles
[Key behaviors]

## Workflow
[Step-by-step process]

## Output Format
[Expected response format]

## Important Notes
[Caveats and constraints]
```

### 3-Tier Documentation System

**Hierarchy**:
- **Tier 1**: `CLAUDE.md` - Project standards (400+ lines)
- **Tier 2**: `{folder}/CONTEXT.md` - Component architecture (150 lines)
- **Tier 3**: `{feature}/CONTEXT.md` - Feature implementation (150 lines)

**Component CONTEXT.md Purpose**:
- Navigation for folder contents
- Common tasks and patterns
- Links to detailed guides

**Standard CONTEXT.md Structure**:
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
[Key patterns in this folder]

## See Also
[Related guides and skills]
```

## Size Limits Summary

| Type | Target | Max | Action When Exceeded |
|------|--------|-----|----------------------|
| **Command** | 100 | 150 | Extract methodology to guides |
| **SKILL.md** | 80 | 100 | Move details to REFERENCE.md |
| **REFERENCE.md** | 250 | 300 | Split into multiple guides |
| **Guide** | 250 | 300 | Extract sections to separate guides |
| **Agent** | 150 | 200 | Simplify workflow description |
| **CONTEXT.md** | 120 | 150 | Focus on navigation only |

## Documentation Quality Checklist

### Structure
- [ ] Clear purpose statement at top
- [ ] Quick reference table for fast lookup
- [ ] Standard sections followed
- [ ] Cross-references to related docs

### Discoverability
- [ ] Frontmatter complete (skills, agents)
- [ ] Description is trigger-rich (skills, commands)
- [ ] CONTEXT.md exists for folder navigation

### Maintainability
- [ ] Within size limits
- [ ] No duplicated content (extract to guides)
- [ ] Examples provided
- [ ] External links included

## Further Reading

**Internal**:
- @.claude/skills/documentation-best-practices/REFERENCE.md - Detailed examples, good/bad patterns, external links
- @.claude/guides/claude-code-standards.md - Official directory structure, model allocation rationale
- @.claude/guides/3tier-documentation.md - Complete 3-Tier documentation system

**External**:
- [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code overview - Official Docs](https://code.claude.com/docs/en/overview)
- [Claude Skills and CLAUDE.md: a practical 2026 guide](https://www.gend.co/blog/claude-skills-claude-md-guide)
