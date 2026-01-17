# Skills Context

## Purpose

Auto-discoverable capabilities that Claude Code uses to match user intent to appropriate methodologies. Skills are the building blocks of agent workflows, providing standardized approaches for common tasks.

## Key Skills

| Skill | SKILL.md | REFERENCE.md | Purpose | Trigger Keywords |
|-------|----------|--------------|---------|-----------------|
| `tdd` | Test-Driven Development | Advanced patterns, test doubles | Red-Green-Refactor cycle | "implementing features", "test coverage", "TDD" |
| `ralph-loop` | Autonomous completion | Loop mechanics, fix strategies | Iterate until quality gates pass | "until tests pass", "quality gates", "iteration" |
| `vibe-coding` | Code quality standards | SOLID principles, refactoring | Enforce size limits, clean code | "refactor", "code quality", "clean code" |
| `git-master` | Version control workflow | Branch strategies, collaboration | Commits, branches, PRs | "commit", "branch", "PR", "git" |
| `documentation-best-practices` | Documentation standards | Detailed examples, patterns | CLAUDE.md, commands, skills, agents | "documentation", "docs", "CLAUDE.md" |

**Total**: 5 skills, each with SKILL.md (100 lines) and REFERENCE.md (300 lines)

## Common Tasks

### Implement Features with Tests
- **Task**: Build feature using Test-Driven Development
- **Skill**: @.claude/skills/tdd/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: `/02_execute` command

**TDD Cycle**:
1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Improve quality while keeping tests green

**Output**: Feature code with test coverage (80%+ overall, 90%+ core)

### Iterate Until Quality Gates Pass
- **Task**: Run autonomous completion loop
- **Skill**: @.claude/skills/ralph-loop/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: After first code change in `/02_execute`

**Ralph Loop**:
- Run verification: tests, type-check, lint, coverage
- If all pass + coverage ≥ 80% + todos complete → `<RALPH_COMPLETE>`
- If failures → fix and continue
- Max 7 iterations

**Completion marker**: `<RALPH_COMPLETE>` or `<RALPH_BLOCKED>`

### Refactor Code for Quality
- **Task**: Apply code quality standards
- **Skill**: @.claude/skills/vibe-coding/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: During Refactor phase of TDD

**Size limits**:
- Functions ≤50 lines
- Files ≤200 lines
- Nesting ≤3 levels

**Principles**:
- **SRP**: Single Responsibility Principle
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid
- **Early Return**: Reduce nesting

### Create Git Commit
- **Task**: Stage and commit changes
- **Skill**: @.claude/skills/git-master/SKILL.md
- **Agent**: Coder (sonnet) or user
- **Usage**: `/03_close` command (when user requests commit)

**Commit standards**:
- Conventional commits: `type(scope): description`
- Co-Authored-By: Claude <noreply@anthropic.com>
- Only commit when user explicitly requests

**Types**: feat, fix, refactor, chore, docs, style, test

### Create or Review Documentation
- **Task**: Apply documentation standards
- **Skill**: @.claude/skills/documentation-best-practices/SKILL.md
- **Agent**: Documenter (haiku) or any agent
- **Usage**: Creating CLAUDE.md, commands, skills, agents

**Documentation standards**:
- CLAUDE.md: 400+ lines, project entry point
- Commands: 150 lines max, focus on workflow
- SKILL.md: 100 lines max, quick reference
- REFERENCE.md: 300 lines max, detailed examples
- Agents: 200 lines max, role + workflow

## Patterns

### Auto-Discovery Pattern

Skills are auto-discovered via frontmatter `description`:

```yaml
---
name: {skill-name}
description: {trigger-rich description for auto-discovery}
---
```

**How it works**:
1. Claude Code scans skill frontmatter
2. Matches user intent to skill descriptions
3. Suggests relevant skills during conversations

**Description quality**:
- Contains action keywords (use, apply, implement)
- Mentions specific scenarios (when testing, when refactoring)
- Under 200 characters

**Example**:
```yaml
Good:
name: tdd
description: Test-Driven Development cycle (Red-Green-Refactor). Use when implementing features with test coverage.

Bad:
name: tdd
description: About test driven development methodology
```

### File Pair Pattern

Each skill has two files:

**SKILL.md** (100 lines):
- Quick start (when to use, quick reference)
- Core concepts (essential patterns only)
- Further reading (links to REFERENCE.md)

**REFERENCE.md** (300 lines):
- Detailed examples
- Good/bad patterns
- External resources

**Separation principle**:
- SKILL.md = "How do I start?"
- REFERENCE.md = "Tell me more"

### Skill-Workflow Integration

Skills are integrated into agent workflows:

**Example: Coder Agent**
```markdown
## Workflow

### Phase 2: TDD Cycle
> **Methodology**: @.claude/skills/tdd/SKILL.md

### Phase 3: Ralph Loop
> **Methodology**: @.claude/skills/ralph-loop/SKILL.md
```

**Benefits**:
- Keep agent files concise
- Single source of truth for methodology
- Easy to update methodology in one place

### Further Reading Pattern

All SKILL.md files link to REFERENCE.md and external resources:

```markdown
## Further Reading

**Internal**: @.claude/skills/{skill}/REFERENCE.md - Deep dive

**External**:
- [Book: Test-Driven Development by Kent Beck](https://www.amazon.com/...)
- [Article: Growing Object-Oriented Software](https://www.amazon.com/...)
```

## Skill Categories

### Development Skills
- `tdd`: Test-Driven Development cycle
- `vibe-coding`: Code quality standards

### Workflow Skills
- `ralph-loop`: Autonomous completion loop
- `git-master`: Version control workflow

### Documentation Skills
- `documentation-best-practices`: Documentation standards

## Usage by Agents

### Coder Agent (sonnet)
- `tdd`: Red-Green-Refactor cycle
- `ralph-loop`: Iterate until quality gates pass
- `vibe-coding`: Refactor code for quality
- `git-master`: Create commits (when requested)

### Documenter Agent (haiku)
- `documentation-best-practices`: Create/review documentation

### Plan-Reviewer Agent (sonnet)
- `documentation-best-practices`: Review plan documentation

### All Agents
- `vibe-coding`: Apply code quality standards
- `documentation-best-practices`: Create clear documentation

## Frontmatter Verification

**Required frontmatter for all skills**:

```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

**Verification checklist**:
- [ ] `name` field present (kebab-case)
- [ ] `description` field present (trigger-rich)
- [ ] Description under 200 characters
- [ ] Description contains action keywords
- [ ] Description mentions specific scenarios

**Auto-discovery test**:
```bash
# Search for skill by trigger keyword
grep -r "implementing features" .claude/skills/
# Should find tdd skill
```

## Size Guidelines

**SKILL.md**: 80-100 lines
- Quick start (when to use, quick reference)
- Core concepts (essential patterns)
- Further reading (links)

**REFERENCE.md**: 250-300 lines
- Detailed examples
- Good/bad patterns
- External resources

**When to split**:
- If SKILL.md exceeds 100 lines → Move details to REFERENCE.md
- If REFERENCE.md exceeds 300 lines → Split into multiple skills

## Improvement Opportunities

**Current state**: Average 111 lines per SKILL.md (slightly over 100-line target)

**Improvements needed**:
1. `tdd/SKILL.md`: Verify description triggers
2. `ralph-loop/SKILL.md`: Ensure auto-discovery works
3. `vibe-coding/SKILL.md`: Add external links
4. `git-master/SKILL.md`: Verify completeness

**REFERENCE.md status**: Need to verify all REFERENCE.md files exist and are complete.

## Skill Relationships

### Core Development Workflow
```
tdd (Red-Green-Refactor)
    ↓
ralph-loop (Iterate until pass)
    ↓
vibe-coding (Refactor for quality)
```

### Documentation Workflow
```
documentation-best-practices (standards)
    ↓
Create CLAUDE.md, commands, skills, agents
```

### Release Workflow
```
git-master (commit standards)
    ↓
Create commit with conventional format
```

## File Organization

### Directory Structure
```
.claude/skills/
├── tdd/
│   ├── SKILL.md
│   └── REFERENCE.md
├── ralph-loop/
│   ├── SKILL.md
│   └── REFERENCE.md
├── vibe-coding/
│   ├── SKILL.md
│   └── REFERENCE.md
├── git-master/
│   ├── SKILL.md
│   └── REFERENCE.md
├── documentation-best-practices/
│   ├── SKILL.md
│   └── REFERENCE.md
└── CONTEXT.md
```

### Naming Convention
- **Directory name**: kebab-case (e.g., `vibe-coding`)
- **Files**: `SKILL.md` (uppercase), `REFERENCE.md` (uppercase)
- **Frontmatter name**: kebab-case (e.g., `name: vibe-coding`)

## Cross-Reference Patterns

### Internal Cross-References

Skills reference each other:
```markdown
## Further Reading

**Internal**: @.claude/skills/tdd/REFERENCE.md - TDD patterns | @.claude/skills/ralph-loop/SKILL.md - Completion loop
```

### External Cross-References

Skills reference external resources:
```markdown
**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/...) | [Clean Code by Robert C. Martin](https://www.amazon.com/...)
```

## See Also

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command workflow and usage

**Guide specifications**:
- @.claude/guides/CONTEXT.md - Methodology guides

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and model allocation

**Documentation standards**:
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
