# Skills Context

## Purpose

Auto-discoverable capabilities that Claude Code uses to match user intent to appropriate methodologies. Skills are the building blocks of agent workflows.

## Key Skills

| Skill | Purpose | Trigger Keywords |
|-------|---------|-----------------|
| `tdd` | Test-Driven Development | "implementing features", "test coverage", "TDD" |
| `ralph-loop` | Autonomous completion | "until tests pass", "quality gates", "iteration" |
| `vibe-coding` | Code quality standards | "refactor", "code quality", "clean code" |
| `git-master` | Version control workflow | "commit", "branch", "PR", "git" |
| `documentation-best-practices` | Documentation standards | "documentation", "docs", "CLAUDE.md" |
| `frontend-design` | Production-grade frontend design | "UI design", "frontend styling", "landing page" |
| `confirm-plan` | Plan confirmation workflow | "confirm plan", "plan review", "requirements verification" |
| `execute-plan` | Plan execution workflow | "execute plan", "implement SC", "parallel execution" |
| `release` | Plugin release workflow | "release version", "bump version", "git tag", "GitHub release" |
| `rapid-fix` | Rapid bug fix workflow | "fix bug", "quick fix", "one-line fix" |
| `code-cleanup` | Dead code detection and removal | "cleanup", "remove unused code", "dead code" |
| `gpt-delegation` | Intelligent Codex/GPT consultation | "GPT delegation", "Codex CLI", "escalate" |
| `quality-gates` | Pre-commit quality validation | "pre-commit", "quality check", "validate" |

**Total**: 13 skills, each with SKILL.md (~100 lines) and REFERENCE.md (~300 lines)

## Common Tasks

### Implement Features with Tests
- **Skill**: @.claude/skills/tdd/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: `/02_execute` command
- **Cycle**: Red (write test) → Green (implement) → Refactor (improve)

### Iterate Until Quality Gates Pass
- **Skill**: @.claude/skills/ralph-loop/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: After first code change in `/02_execute`
- **Max iterations**: 7

### Refactor Code for Quality
- **Skill**: @.claude/skills/vibe-coding/SKILL.md
- **Agent**: Coder (sonnet)
- **Limits**: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3 levels

### Create Git Commit
- **Skill**: @.claude/skills/git-master/SKILL.md
- **Agent**: Coder (sonnet) or user
- **Usage**: `/03_close` command (when user requests commit)
- **Format**: Conventional commits with Co-Authored-By

### Create or Review Documentation
- **Skill**: @.claude/skills/documentation-best-practices/SKILL.md
- **Agent**: Documenter (haiku) or any agent
- **Standards**: CLAUDE.md (400+), Commands (150), SKILL.md (100), REFERENCE.md (300)

### Confirm Plan After Creation
- **Skill**: @.claude/skills/confirm-plan/SKILL.md
- **Agent**: Plan-Reviewer (sonnet)
- **Usage**: `/01_confirm` command
- **Workflow**: Extract plan → Create file → Auto-review → Interactive Recovery

### Execute Plan with TDD
- **Skill**: @.claude/skills/execute-plan/SKILL.md
- **Agent**: Coder (sonnet)
- **Usage**: `/02_execute` command
- **Workflow**: Detect plan → Analyze dependencies → Implement with TDD → Iterate

## Patterns

### Auto-Discovery Pattern
Skills are auto-discovered via frontmatter `description`:
```yaml
---
name: {skill-name}
description: {trigger-rich description for auto-discovery}
---
```

### File Pair Pattern
Each skill has two files:
- **SKILL.md** (100-150 lines): Quick start, core concepts, further reading
- **REFERENCE.md** (~300 lines): Detailed examples, patterns, external resources

### Skill-Workflow Integration
Skills are integrated into agent workflows via cross-references:
```markdown
> **Methodology**: @.claude/skills/tdd/SKILL.md
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

## Size Guidelines

**SKILL.md**: ≤150 lines (updated from 100)
- Quick start (when to use)
- Core concepts (essential patterns)
- Further reading (links)

**REFERENCE.md**: ~300 lines
- Detailed examples
- Good/bad patterns
- External resources

## Frontmatter Verification

All skills require:
```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

## See Also

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command workflow and usage

**Guide specifications**:
- @.claude/guides/CONTEXT.md - Methodology guides

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and model allocation
