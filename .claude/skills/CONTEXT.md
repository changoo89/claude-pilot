# Skills Context

## Purpose

Auto-discoverable capabilities that Claude Code uses to match user intent to appropriate methodologies. Skills are the building blocks of agent workflows.

## Key Skills

| Skill | Purpose | Trigger Keywords |
|-------|---------|-----------------|
| `claude-pilot-standards` | Plugin development standards | "plugin standards", "command format", "skill format" |
| `close-plan` | OOM-optimized plan closure (5 steps, 2 agents, conditional doc sync) | "close plan", "finalize", "mark complete" |
| `code-cleanup` | Dead code detection and removal | "cleanup", "remove unused code", "dead code" |
| `code-quality-gates` | Quality validation gates | "quality gates", "validation", "checks" |
| `coding-standards` | TypeScript/React/API standards | "coding standards", "best practices", "conventions" |
| `confirm-plan` | Plan confirmation workflow with SC granularity check and Proactive GPT Consultation | "confirm plan", "plan review", "requirements verification", "context pack", "self-contained verification", "SC granularity", "proactive consultation" |
| `documentation-best-practices` | Documentation standards | "documentation", "docs", "CLAUDE.md" (200+ lines) |
| `execute-plan` | Plan execution workflow with Smart Grouping and Pre-Execution Confidence check | "execute plan", "implement SC", "parallel execution", "smart grouping", "pre-execution confidence" |
| `frontend-design` | Production-grade frontend design | "UI design", "frontend styling", "landing page" |
| `git-master` | Version control workflow | "commit", "branch", "PR", "git" |
| `git-operations` | Safe git push/pull/merge | "git push", "git pull", "retry", "error handling" |
| `gpt-delegation` | Intelligent Codex/GPT consultation with confidence-based proactive consultation | "GPT delegation", "Codex CLI", "escalate", "proactive consultation", "confidence score" |
| `parallel-subagents` | Parallel agent execution with single delegation pattern | "parallel agents", "concurrent execution", "independent SCs", "single agent delegation", "context protection" |
| `quality-gates` | Pre-commit quality validation | "pre-commit", "quality check", "validate" |
| `ralph-loop` | Autonomous completion with Early Escalation option | "until tests pass", "quality gates", "iteration", "early escalation" |
| `rapid-fix` | Rapid bug fix workflow | "fix bug", "quick fix", "one-line fix" |
| `release` | Plugin release workflow | "release version", "bump version", "git tag", "GitHub release" |
| `review` | Multi-angle code review | "code review", "quality review", "parallel review" |
| `safe-file-ops` | Safe file operations | "file operations", "safe edit", "pre-flight checks" |
| `spec-driven-workflow` | SPEC-first development with Atomic SC Principle and Proactive GPT Consultation | "SPEC-first", "planning", "requirements", "external context detection", "atomic SC", "proactive consultation" |
| `tdd` | Test-Driven Development | "implementing features", "test coverage", "TDD" |
| `test-driven-development` | Advanced TDD patterns | "TDD patterns", "testing strategies", "test design" |
| `three-tier-docs` | 3-tier documentation hierarchy with integrated verification and selective validation | "documentation tiers", "CLAUDE.md", "CONTEXT.md", "line limits" |
| `using-git-worktrees` | Parallel development with worktrees | "worktrees", "parallel development", "isolated workspace" |
| `vibe-coding` | Code quality standards | "refactor", "code quality", "clean code" |

**Total**: 25 skills, each with SKILL.md (≤200 lines) and REFERENCE.md (variable length), all refactored for compliance and enhanced functionality

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
- **Workflow**: Detect plan → Analyze dependencies → Implement with TDD → E2E verification (Step 5) → Iterate

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
- **SKILL.md** (≤200 lines): Quick start, core concepts, further reading
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

**SKILL.md**: ≤200 lines
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

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and model allocation
