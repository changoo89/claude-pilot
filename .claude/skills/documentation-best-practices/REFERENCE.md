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
- Common pitfalls and solutions

### Out of Scope
- Basic file structure → @.claude/skills/documentation-best-practices/SKILL.md
- Test writing → @.claude/skills/tdd/SKILL.md
- Code quality → @.claude/skills/vibe-coding/SKILL.md

## File Structure Patterns

### CLAUDE.md (Target: ≤400 lines)

**Key Principles**:
- Extract methodology to guides
- Keep tables for quick reference
- Use "> **Details**: @path" for expanded content
- Focus on project-specific standards

**Content Structure**:
```markdown
# Project Name - Claude Code Development Guide
> **Version**: X.X.X | **Last Updated**: YYYY-MM-DD

## Project Overview
[One-line description, tech stack]

## Quick Start
[Common commands table]

## Project Structure
[File tree with key directories]

## Development Workflow
> **Methodology**: @.claude/skills/spec-driven-workflow/SKILL.md

## Context Engineering
> **Details**: @.claude/skills/three-tier-docs/SKILL.md
```

**Avoid**:
- Duplicating skill/command content (200+ lines)
- Deep methodology explanations
- Extensive tutorials

### Command Structure (Target: ≤100 lines)

**Key Principles**:
- Keep workflow steps clear
- Extract methodology to skills
- Use cross-references (> **Methodology**: @path)
- Preserve MANDATORY ACTION wording

**Content Structure**:
```markdown
---
description: [Trigger-rich, action-oriented]
---

# Command Name

## Purpose
[What this command does]

## Prerequisites
[Requirements before running]

## Workflow
### Phase 1: [Name]
[Brief steps]

> **⚠️ MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW

### Phase 2: [Name]
> **Methodology**: @.claude/skills/{skill}/SKILL.md

## Verification
- [ ] Checklist items
```

**Avoid**:
- Repeating skill content (100+ lines)
- Detailed methodology explanations
- Multiple verbose examples

### Skill Structure (SKILL.md ≤200, REFERENCE.md ≤300)

**SKILL.md Template**:
```markdown
---
name: skill-name
description: [Trigger-rich, when to use]
---

# SKILL: Skill Name
> **Purpose**: [What it does] | **Target**: [Who uses it]

## Quick Start
### When to Use | ### Quick Reference
[3-5 bullets] | [Code/table]

## Core Concepts
[2-3 key concepts, brief examples]

## Further Reading
**Internal**: @.claude/skills/{skill}/REFERENCE.md | **External**: [Link]
```

**REFERENCE.md Template**:
```markdown
---
name: skill-name
description: Advanced patterns and examples
---

# REFERENCE: Skill Name

## Advanced Patterns | ## Common Scenarios | ## External Resources
[1 example each] | [Table/brief] | [Links]
```

**Principles**: SKILL.md = Quick reference (when/how) | REFERENCE.md = Deep dive (patterns/links) | 1 example max

### Agent Structure (Target: ≤200 lines)

**Key Principles**:
- Clear mission statement
- Model allocation rationale in description
- Tool and skill list in frontmatter
- Concise workflow (don't repeat skill content)
- Clear output format

**Content Structure**:
```markdown
---
name: agent-name
description: [What it does, when to use]
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list]
---

You are the {Agent} Agent. [Mission statement]

## Core Principles
[Key principles as bullets]

## Workflow
### Phase 1: [Name]
[Brief steps]

### Phase 2: [Name]
[Brief steps, reference skills]

## Output Format
[Template example]

## Important Notes
[Critical constraints]
```

### CONTEXT.md Structure (Target: ≤150 lines)

**Content Structure**:
```markdown
# {Folder} Context

## Purpose
[What this folder does]

## Key Files

| File | Purpose | Lines | Workflow |
|------|---------|-------|----------|
| file1.md | Description | 150 | Phase |

## Common Tasks
- **Task**: Description → Command/Path

## Patterns
[Key patterns as bullets or table]

## See Also
[Related docs with @paths]
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
See @.claude/skills/parallel-subagents/SKILL.md for patterns

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

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Commands too long | Exceed 150 lines with methodology | Extract to skills: `> **Methodology**: @path` |
| Missing frontmatter | Auto-discovery fails | Add complete YAML with trigger-rich description |
| Weak descriptions | No semantic matching | Use action keywords: "Use when...", "Implement..." |
| Missing CONTEXT.md | Poor folder navigation | Create CONTEXT.md with purpose, files, tasks, patterns |
| Duplicated content | Same content in multiple files | Single source of truth: Command → Skill → Reference |
| Verbose examples | 100+ line code blocks | Keep 1 example per concept, max 20 lines |
| No cross-references | Users can't navigate | Use `@.claude/path/file.md` format |

## External Best Practices

**Key Guidelines**:
- Commands: 50-150 lines | CLAUDE.md: ≤400 lines | Skills: ≤200 lines | References: ≤300 lines
- Trigger-rich descriptions for auto-discovery
- Model allocation: Haiku (fast), Sonnet (balanced), Opus (deep reasoning)
- File size: Functions ≤50, Files ≤200, Nesting ≤3
- Documentation: Quick reference → Detailed sections → External links

**Sources**: [Anthropic Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices), [Addy Osmani LLM Workflow](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e)

## Further Reading

**Internal**: @.claude/skills/documentation-best-practices/SKILL.md (quick reference) | @.claude/skills/coding-standards/SKILL.md (structure) | @.claude/skills/three-tier-docs/SKILL.md (3-tier system)

**External**:
- [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code overview - Official Docs](https://code.claude.com/docs/en/overview)
- [My LLM coding workflow 2026 - Addy Osmani](https://medium.com/@addyosmani/my-llm-coding-workflow-going-into-2026-52fe1681325e)
- [Agentic Coding Best Practices - DEV.to](https://dev.to/timesurgelabs/agentic-coding-vibe-coding-best-practices-b4b)
- [Refactoring.guru](https://refactoring.guru/)
