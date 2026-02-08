# Claude-Pilot Templates

> **Purpose**: Reusable templates for component creation
> **Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
> **Last Updated**: 2026-01-22

---

## SKILL.md Template

```markdown
---
name: {skill-name}
description: {trigger-rich description with action verbs and use cases}
---

# SKILL: {Skill Title}

> **Purpose**: {What this skill provides}
> **Target**: {Who should use this skill}

## Quick Reference

| Concept | Description |
|---------|-------------|
| {Key concept 1} | {Brief description} |

## Core Concepts

### {Concept 1}
{Explanation}

## When to Use This Skill

- {Use case 1}

## Further Reading

**Internal**: @.claude/skills/{skill-name}/REFERENCE.md - {What's covered}

**External**: [{Resource Name}]({url})
```

---

## COMMAND.md Template

```markdown
---
description: {Action verbs + scenarios}
argument-hint: "[param] - {description}"
allowed-tools: [tool list]
---

# /{command-name}

_{Brief tagline}

## Core Philosophy

- **{Principle 1}**: {Explanation}

> **⚠️ CRITICAL**: {Critical note}

**Full methodology**: @.claude/skills/{skill}/SKILL.md

---

## Step 1: {Main Task}

> **Methodology**: @.claude/skills/{skill}/SKILL.md

{Task details}

### MANDATORY ACTION

> **⚠️ MANDATORY ACTION**: YOU MUST {action} NOW

---

## Success Criteria

- [ ] {Criteria 1}

---

## Related Documentation

**Methodology**: @.claude/skills/{skill}/SKILL.md
```

---

## GUIDE.md Template

```markdown
# {Guide Title}

> **Last Updated**: {date}
> **Purpose**: {What this guide covers}

---

## Quick Reference

| Component | Purpose | Key Pattern |
|-----------|---------|-------------|
| {Item 1} | {Purpose} | {Pattern} |

---

## Core Concepts

### {Concept 1}
{Explanation}

---

## Best Practices

### For {Component Type}
- {Practice 1}

---

## Common Patterns

### {Pattern Name}

**Description**: {What it does}

**Example**: {Brief example or reference}

---

## Related Documentation

**Detailed Reference**: @.claude/skills/{skill}/REFERENCE.md
```

---

## AGENT.md Template

```markdown
---
name: {agent-name}
description: {Clear purpose statement}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list if any]
---

You are the {Agent} Agent. Your mission is {specific mission}.

## Core Principles

- **{Principle 1}**: {Explanation}

## Workflow

### Phase 1: {Phase Name}

> **Methodology**: @.claude/skills/{skill}/SKILL.md

1. {Step 1}

### Phase 2: {Phase Name}

{Workflow steps}

## Output Format

{Expected response format}

**Completion Marker**: Return `<{AGENT_UPPERCASE}_COMPLETE>` or `<{AGENT_UPPERCASE}_BLOCKED>`

## Important Notes

- {Note 1}

---

## See Also

**Related Skills**: @.claude/skills/{skill}/SKILL.md
**Usage**: @.claude/commands/{command}.md
```

---

## CONTEXT.md Template

```markdown
# {Component} Context

## Purpose

{What this component provides and why it exists}

## Key Files

| File | Purpose | Usage |
|------|---------|-------|
| {file 1} | {purpose} | {when to use} |

## Common Tasks

### {Task Name}

- **Task**: {What it does}
- **File**: @.claude/{path}/{file}
- **Usage**: {when to use}

## Patterns

### {Pattern Name}

{description}

**Example**: See @.claude/{path}/{example}

## See Also

**Related**: @.claude/{path}/{file}
**Skill**: @.claude/skills/{skill}/SKILL.md
```

---

## REFERENCE.md Template

```markdown
# {Component} - Detailed Reference

> **Purpose**: Extended reference for {component}
> **Main**: @.claude/{path}/{file}
> **Last Updated**: {date}

---

## {Section 1}

### When to Use
{criteria}

### Structure Template
{template}

### Best Practices
- {practice 1}

### Common Patterns
{patterns}

### Examples
@.claude/{path}/{example}

---

## {Section 2}

{same structure}

---

## Related Documentation

**Templates**: @.claude/{path}/TEMPLATES.md
**Examples**: @.claude/{path}/EXAMPLES.md
```

---

## Usage Instructions

1. Copy the appropriate template
2. Replace `{placeholders}` with actual content
3. Remove placeholder comments
4. Verify size limits: `wc -l {file}`
5. Test auto-discovery (for skills): Check frontmatter

---

## Verification Checklist

| Type | Required Elements | Size |
|------|------------------|------|
| **SKILL.md** | `name` (kebab-case), `description` (trigger keywords), Quick Reference table, REFERENCE.md link | ≤200 lines |
| **COMMAND.md** | `description` (action verbs), Core Philosophy, MANDATORY ACTION markers, Success Criteria | ≤200 lines |
| **AGENT.md** | `name`, `description`, `model`, `tools`, Mission statement, Workflow phases, Completion marker | ≤200 lines |
| **REFERENCE.md** | When to Use, Best Practices, Examples sections, links to main file | ≤300 lines |

---

## Related Documentation

**Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
**Reference**: @.claude/skills/claude-pilot-standards/REFERENCE.md
**Examples**: @.claude/skills/claude-pilot-standards/EXAMPLES.md
