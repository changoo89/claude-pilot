# Claude Code Standards Guide

> **Last Updated**: 2026-01-18
> **Purpose**: Official Claude Code directory structure, file conventions, and best practices

---

## Quick Reference

| Component | Location | Purpose | Size Limit |
|-----------|----------|---------|------------|
| **CLAUDE.md** | Project root | Project entry point | 400+ lines |
| **Commands** | `.claude/commands/` | Slash commands for workflow | 150 lines |
| **Guides** | `.claude/guides/` | Methodology and patterns | 300 lines |
| **Skills** | `.claude/skills/{name}/` | Auto-discoverable capabilities | SKILL: 100, REF: 300 |
| **Agents** | `.claude/agents/` | Specialized agent configs | 200 lines |
| **CONTEXT.md** | Each folder | Navigation and patterns | 150 lines |

---

## Core Concepts

### Official Directory Structure

```
project-root/
├── .claude/
│   ├── commands/           # Slash commands
│   ├── guides/             # Methodology guides
│   ├── skills/              # Auto-discoverable skills
│   │   └── {name}/
│   │       ├── SKILL.md     # Quick reference
│   │       └── REFERENCE.md  # Detailed guide
│   ├── agents/             # Specialized agents
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   └── scripts/hooks/      # Type check, lint, todos
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       └── done/           # Completed plans
├── CLAUDE.md               # Project entry point
└── README.md               # Project README
```

### CLAUDE.md Precedence Rules

**Rule 1**: CLAUDE.md is the single source of truth for project standards
**Rule 2**: CLAUDE.md links to CONTEXT.md for navigation
**Rule 3**: Version tracking (project version lines 4, 23; template version near end)

### Command Frontmatter

**Required**:
```yaml
---
description: {trigger-rich description}
---
```

**Guidelines**:
- Length: Under 200 characters
- Keywords: Action verbs (plan, execute, review, document)
- Scenarios: Specific use cases

**Example**:
```yaml
Good: "Create SPEC-First plan from user request. Use for new features, bug fixes."
Bad: "Planning command"
```

### Skill Auto-Discovery

**Required**:
```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

**Auto-discovery test**:
```bash
grep -r "implementing features" .claude/skills/
# Should find tdd skill
```

### Agent Model Allocation

| Model | Agents | Task Type | Rationale |
|-------|--------|-----------|-----------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, structured | Lowest cost, fastest |
| **Sonnet** | coder, tester, plan-reviewer | Balanced | Good quality/speed |
| **Opus** | code-reviewer | Deep reasoning | Best quality, critical review |

**Agent responsibilities**:

| Agent | Owns | Examples |
|-------|------|----------|
| explorer | Research | "Analyze patterns", "Find files" |
| researcher | Research | "Research best practices" |
| coder | Implementation | "Create model", "Add endpoint" |
| tester | Tests | "Write tests", "Debug failures" |
| validator | Verification | "Verify tests pass", "Check coverage" |
| plan-reviewer | Plan analysis | "Review plan", "Detect gaps" |
| code-reviewer | Deep review | "Async bugs", "Memory leaks" |
| documenter | Documentation | "Update docs", "Add CHANGELOG" |

### File Size Limits

| Type | Target | Max | Action |
|------|--------|-----|--------|
| Command | 100 | 150 | Extract to guides |
| SKILL.md | 80 | 100 | Move to REFERENCE.md |
| REFERENCE.md | 250 | 300 | Split files |
| Guide | 250 | 300 | Extract sections |
| Agent | 150 | 200 | Simplify workflow |
| CONTEXT.md | 120 | 150 | Navigation only |

---

## Best Practices

### For Commands
- Focus on workflow steps
- Extract methodology to guides/skills
- Use cross-references
- Preserve MANDATORY ACTION sections

### For Skills
- SKILL.md: Quick reference (when to use, core concepts)
- REFERENCE.md: Deep dive (detailed examples, patterns)
- Use cross-references

### For Agents
- Clear mission statement
- Concise workflow
- Use cross-references to skills

### For CONTEXT.md
- Navigation and patterns
- File-by-file overview
- Common tasks with commands
- Cross-references to related docs

---

## Cross-Reference Patterns

**Format**: `@.claude/{path}/{file}`

**Best practices**:
- Use absolute paths from `.claude/` root
- Link to specific files
- Include descriptive text
- Verify targets exist

**Example**:
```markdown
Good: > **Methodology**: @.claude/skills/tdd/SKILL.md
Bad: See the TDD skill (not clickable)
```

---

## Common Patterns

### Command Flow
```
User Request → /00_plan → /01_confirm → /02_execute → /03_close
```

### Agent Invocation
```markdown
> **⚠️ MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW
```

### Methodology Extraction
```markdown
BEFORE: ## TDD Methodology [200 lines]
AFTER: > **Methodology**: @.claude/skills/tdd/SKILL.md
```

---

## Related Documentation

**Detailed Reference**: @.claude/guides/claude-code-standards-REFERENCE.md - Advanced techniques, examples, troubleshooting

**Internal**: @.claude/skills/documentation-best-practices/SKILL.md | @.claude/guides/3tier-documentation.md | @.claude/guides/parallel-execution.md

**External**: [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) | [Official Docs](https://code.claude.com/docs/en/overview)
