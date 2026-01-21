---
name: documentation-best-practices
description: Claude Code documentation standards for CLAUDE.md, commands, skills, agents. Use when creating or reviewing documentation files.
---

# SKILL: Documentation Best Practices

> **Purpose**: Apply Claude Code documentation standards based on Superpowers reference
> **Target**: Anyone creating CLAUDE.md, commands, skills, guides, or agents

---

## Quick Start

### When to Use This Skill
- Creating new documentation (CLAUDE.md, command, skill, agent)
- Reviewing existing documentation for quality
- Restructuring documentation to follow best practices

### Quick Reference

| File Type | Target | Max | Action When Exceeded |
|-----------|--------|-----|----------------------|
| **SKILL.md** | 120 | **150** | >300 → Create REFERENCE.md |
| **Agent** | 250 | **300** | >450 → Simplify required |
| **Command** | 150 | **200** | >300 → Extract to guide |
| **CONTEXT.md** | 150 | **200** | >300 → Simplify required |
| **REFERENCE.md** | 250 | 300 | Split into multiple files |

## What This Skill Covers

### In Scope
- File size targets based on Superpowers standards
- Frontmatter standards for auto-discovery
- SKILL.md/REFERENCE.md separation pattern
- Agent model allocation

### Out of Scope
- Test writing → @.claude/skills/tdd/SKILL.md
- Code quality → @.claude/skills/vibe-coding/SKILL.md
- Git workflow → @.claude/skills/git-master/SKILL.md

## Core Concepts

### Superpowers Standard

> "The context window is a public good. Skills share the context window with everything else Claude needs."

**Baseline**: SKILL.md <500 words (~100-150 lines)

### Frontmatter Standards

**Skills** (required):
```yaml
---
name: {skill-name}
description: {trigger-rich description for semantic matching}
---
```

**Commands** (auto-discovery):
```yaml
---
description: {action-rich description for slash command discovery}
---
```

**Agents** (required):
```yaml
---
name: {agent-name}
description: {clear purpose statement}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list]
---
```

### SKILL.md/REFERENCE.md Pattern

**SKILL.md** (≤150 lines):
- Quick Start (when to use, quick reference)
- Core Concepts (essential patterns)
- Further Reading (link to REFERENCE.md)

**REFERENCE.md** (≤300 lines):
- Detailed examples
- Good/bad patterns
- Troubleshooting
- External references

### Agent Model Allocation

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient |
| **Sonnet** | coder, tester, plan-reviewer | Balanced quality/speed |
| **Opus** | code-reviewer | Deep reasoning |

### 3-Tier Documentation

- **Tier 1**: `CLAUDE.md` - Project standards (400+ lines)
- **Tier 2**: `{folder}/CONTEXT.md` - Component architecture (≤200 lines)
- **Tier 3**: `{feature}/CONTEXT.md` - Feature implementation (≤200 lines)

## Documentation Quality Checklist

### Structure
- [ ] Clear purpose statement
- [ ] Quick reference table
- [ ] Standard sections
- [ ] Cross-references

### Discoverability
- [ ] Frontmatter complete
- [ ] Description is trigger-rich
- [ ] CONTEXT.md for navigation

### Maintainability
- [ ] Within size limits
- [ ] No duplicated content
- [ ] Examples provided

## Further Reading

**Internal**: @.claude/skills/documentation-best-practices/REFERENCE.md - Detailed examples, good/bad patterns, external links | @.claude/guides/claude-code-standards.md - Official directory structure | @.claude/guides/3tier-documentation.md - Complete 3-Tier system

**External**: [Claude Code Best Practices - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices) | [Superpowers - obra/superpowers](https://github.com/obra/superpowers)
