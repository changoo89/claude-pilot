# Claude-Pilot Templates

> **Purpose**: Reusable templates for component creation
> **Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
> **Last Updated**: 2026-01-20

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
| {Key concept 2} | {Brief description} |

## Core Concepts

### {Concept 1}
{Explanation}

### {Concept 2}
{Explanation}

## When to Use This Skill

- {Use case 1}
- {Use case 2}

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
- **{Principle 2}**: {Explanation}

> **⚠️ CRITICAL**: {Critical note}

**Full methodology**: @.claude/guides/{guide}.md

---

## Step 0: {Setup Phase}

{Setup instructions}

---

## Step 1: {Main Task}

> **Methodology**: @.claude/skills/{skill}/SKILL.md

{Task details}

### MANDATORY ACTION

> **⚠️ MANDATORY ACTION**: YOU MUST {action} NOW

---

## Success Criteria

- [ ] {Criteria 1}
- [ ] {Criteria 2}

---

## Related Documentation

**Methodology**: @.claude/skills/{skill}/SKILL.md
**Guide**: @.claude/guides/{guide}.md
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
| {Item 2} | {Purpose} | {Pattern} |

---

## Core Concepts

### {Concept 1}
{Explanation}

### {Concept 2}
{Explanation}

---

## Best Practices

### For {Component Type}
- {Practice 1}
- {Practice 2}

---

## Common Patterns

### {Pattern Name}

**Description**: {What it does}

**Example**:
```markdown
{Code or text example}
```

---

## Related Documentation

**Detailed Reference**: @.claude/guides/{guide}-REFERENCE.md
**Skills**: @.claude/skills/{skill}/SKILL.md
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
- **{Principle 2}**: {Explanation}

## Workflow

### Phase 1: {Phase Name}

> **Methodology**: @.claude/skills/{skill}/SKILL.md

{Workflow steps}

1. {Step 1}
2. {Step 2}

### Phase 2: {Phase Name}

{Workflow steps}

## Output Format

{Expected response format}

**Completion Marker**: Return `<{AGENT_UPPERCASE}_COMPLETE>` or `<{AGENT_UPPERCASE}_BLOCKED>`

## Important Notes

- {Note 1}
- {Note 2}

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
| {file 2} | {purpose} | {when to use} |

## Common Tasks

### {Task Name}

- **Task**: {What it does}
- **File**: @.claude/{path}/{file}
- **Usage**: {when to use}

{Details}

## Patterns

### {Pattern Name}

{description}

**Example**:
```markdown
{example}
```

## See Also

**Related**: @.claude/{path}/{file}
**Guide**: @.claude/guides/{guide}.md
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
- {practice 2}

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
4. Verify size limits (wc -l)
5. Test auto-discovery (for skills)

---

## Verification Checklist

### For SKILL.md
- [ ] `name` present (kebab-case)
- [ ] `description` has trigger keywords
- [ ] Quick reference table present
- [ ] ≤100 lines
- [ ] Links to REFERENCE.md

### For COMMAND.md
- [ ] `description` has action verbs
- [ ] Core philosophy section
- [ ] MANDATORY ACTION markers
- [ ] Success criteria listed
- [ ] ≤150 lines

### For AGENT.md
- [ ] `name`, `description`, `model`, `tools` present
- [ ] Mission statement clear
- [ ] Workflow phases numbered
- [ ] Completion marker specified
- [ ] ≤200 lines

---

## Related Documentation

**Main Skill**: @.claude/skills/claude-pilot-standards/SKILL.md
**Reference**: @.claude/skills/claude-pilot-standards/REFERENCE.md
**Examples**: @.claude/skills/claude-pilot-standards/EXAMPLES.md
