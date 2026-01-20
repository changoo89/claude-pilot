# Claude-Pilot Standards Reference

> **Purpose**: Extended component authoring reference
> **Main**: @.claude/skills/claude-pilot-standards/SKILL.md

---

## Skills

### Structure
```
.claude/skills/{name}/
├── SKILL.md (≤100 lines)
└── REFERENCE.md (≤300 lines)
```

### Frontmatter
```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

### SKILL.md Pattern
- Purpose + target
- Quick reference table
- Core concepts (bulleted)
- Link to REFERENCE.md

### REFERENCE.md Pattern
- Comprehensive methodology
- Step-by-step instructions
- Examples + patterns
- Troubleshooting

---

## Commands

### Structure
Single `.md` with frontmatter + sections

### Frontmatter
```yaml
---
description: {action verbs + scenarios}
---
```

### Sections Pattern
1. Core Philosophy
2. Step 0: Setup
3. Step 1-N: Main tasks
4. Success Criteria

### Key Patterns
**MANDATORY marker**:
```markdown
> **⚠️ MANDATORY ACTION**: YOU MUST {action} NOW
```

**Methodology link**:
```markdown
> **Methodology**: @.claude/skills/{skill}/SKILL.md
```

---

## Guides

### Structure
```
.claude/guides/{name}/
├── {name}.md (≤150 lines)
└── {name}-REFERENCE.md (≤300 lines)
```

### Quick Ref Pattern
- Purpose + version
- Quick reference table
- Core concepts summary
- Link to detailed reference

---

## Agents

### Frontmatter (Required)
```yaml
---
name: {agent-name}
description: {clear purpose}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list]
---
```

### Structure Pattern
- Mission statement
- Core principles
- Workflow (phases numbered)
- Output format
- Completion markers

### Model Allocation
| Model | Use | Rationale |
|-------|------|-----------|
| haiku | Fast tasks | Lowest cost |
| sonnet | Implementation | Balanced |
| opus | Deep reasoning | Best quality |

---

## Rules

### Structure
```
.claude/rules/
├── core/              # Workflow rules
├── delegator/         # GPT delegation
│   ├── prompts/       # Expert instructions
│   └── examples/      # Before/after patterns
└── documentation/     # Doc standards
```

### 7-Section Delegation Format
1. TASK: [One sentence]
2. EXPECTED OUTCOME: [Success description]
3. CONTEXT: [Current state]
4. CONSTRAINTS: [Technical limits]
5. MUST DO: [Requirements]
6. MUST NOT DO: [Forbidden actions]
7. OUTPUT FORMAT: [Response structure]

---

## VIBE Coding (Codified)

### Principles
- **SRP**: One function = one responsibility
- **DRY**: Extract common logic
- **KISS**: Simplest solution
- **Early Return**: Reduce nesting

### Size Limits
| Target | Limit | Action |
|--------|-------|--------|
| Function | ≤50 lines | Split |
| File | ≤200 lines | Extract |
| Nesting | ≤3 levels | Early return |

---

## Cross-Reference System

### Format
```markdown
@.claude/{path}/{file}
```

### Best Practices
- Absolute paths from `.claude/`
- Link to specific files
- Include descriptive text
- Verify targets exist

---

## Size Verification

```bash
# Check all component types
wc -l .claude/skills/*/SKILL.md
wc -l .claude/commands/*.md
wc -l .claude/agents/*.md
```

### Limits Reference
| Type | Target | Max |
|------|--------|-----|
| SKILL.md | 80 | 100 |
| REFERENCE.md | 250 | 300 |
| Command | 100 | 150 |
| Agent | 150 | 200 |
| Guide | 250 | 300 |

---

## Related

**Templates**: @.claude/skills/claude-pilot-standards/TEMPLATES.md

**Examples**: @.claude/skills/claude-pilot-standards/EXAMPLES.md

**External**: [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
