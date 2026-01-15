# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-15
> **Version**: 3.3.1
> **Template**: claude-pilot

---

## Project Overview

### One-Line Description
[Brief description of what this project does]

### Technology Stack
```yaml
Framework: [e.g., Next.js 14, React 18, Express]
Language: [e.g., TypeScript, Python, Go]
Database: [e.g., PostgreSQL, MongoDB, SQLite]
Deployment: [e.g., Vercel, AWS, Docker]
```

### Current Status
- **Version**: 3.3.4
- **Stage**: Production
- **Last Updated**: 2026-01-15

---

## Quick Start

### For New Tasks

1. **Planning**: `/00_plan "describe your task"`
2. **Confirmation**: `/01_confirm` (after reviewing plan)
3. **Execution**: `/02_execute` (TDD + Ralph Loop)
4. **Completion**: `/03_close` (archive and commit)

### Common Commands

| Task | Command | Description |
|------|---------|-------------|
| Create plan | `/00_plan` | Generate SPEC-First plan |
| Execute work | `/02_execute` | Implement with TDD |
| Review code | `/90_review` | Multi-angle analysis |
| Update docs | `/91_document` | Auto-sync documentation |
| Publish | `/999_publish` | Sync templates, bump version, deploy |

---

## Project Structure

```
project-root/
├── .claude/
│   ├── commands/           # Slash commands (6)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan
│   │   ├── 02_execute.md   # Execute with TDD
│   │   ├── 03_close.md     # Close & archive
│   │   ├── 90_review.md    # Review code
│   │   └── 91_document.md  # Update docs
│   ├── guides/             # Methodology guides (7)
│   │   ├── claude-code-standards.md  # Official Claude Code standards (NEW)
│   │   ├── prp-framework.md          # Problem-Requirements-Plan
│   │   ├── gap-detection.md          # External service verification
│   │   ├── parallel-execution.md     # Parallel execution patterns
│   │   ├── 3tier-documentation.md    # Documentation system
│   │   ├── review-checklist.md       # Code review criteria
│   │   └── test-environment.md       # Test framework detection
│   ├── skills/             # Reusable skill modules (5)
│   │   ├── documentation-best-practices/  # Documentation standards (NEW)
│   │   ├── tdd/SKILL.md (+ REFERENCE.md)
│   │   ├── ralph-loop/SKILL.md (+ REFERENCE.md)
│   │   ├── vibe-coding/SKILL.md (+ REFERENCE.md)
│   │   └── git-master/SKILL.md (+ REFERENCE.md)
│   ├── agents/             # Specialized agent configs (8)
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   └── scripts/hooks/      # Type check, lint, todos
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
├── scripts/                # Sync and build scripts
│   ├── sync-templates.sh   # Pre-deploy templates sync
│   └── verify-version-sync.sh  # Version consistency check
├── src/ or lib/            # Source code
├── tests/                  # Test files
├── CLAUDE.md               # This file
└── README.md               # Project README
```

---

## Development Workflow

### SPEC-First Development

Every feature starts with clear requirements:

1. **What** (Functionality): What needs to be built
2. **Why** (Context): Business value and rationale
3. **How** (Approach): Implementation strategy
4. **Success Criteria**: Measurable acceptance criteria
5. **Constraints**: Technical/time/resource limits

### TDD Cycle (Red-Green-Refactor)

1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Clean up while keeping tests green
4. **Repeat**: Until all criteria met

### Ralph Loop

Autonomous iteration until all tests pass:
- Run verification (tests, type-check, lint)
- If all pass -> check completion
- If failures -> fix and continue
- Max 7 iterations before review

### Enhanced Plan Workflow (External Services)

> **For plans involving external APIs, databases, file operations, async operations, or environment variables**

#### New Severity Levels

| Level | Symbol | Description | Action Required |
|-------|--------|-------------|-----------------|
| **BLOCKING** | 🛑 | Cannot proceed | Triggers Interactive Recovery (dialogue until resolved) |
| **Critical** | 🚨 | Must fix | Acknowledge and fix before execution |
| **Warning** | ⚠️ | Should fix | Advisory, but recommended |
| **Suggestion** | 💡 | Nice to have | Optional improvements |

#### Gap Detection Review

All plans with external service keywords trigger automatic Gap Detection Review:
- **External API**: SDK vs HTTP, endpoint verification, error handling
- **Database Operations**: Migration files, rollback strategy
- **Async Operations**: Timeouts, concurrent limits, race conditions
- **File Operations**: Path resolution, existence checks, cleanup
- **Environment**: Env var documentation, existence checks, no secrets
- **Error Handling**: No silent catches, user notification, graceful degradation

#### Interactive Recovery

When BLOCKING findings are detected, `/01_confirm` enters dialogue mode:
1. Present each BLOCKING finding with context
2. Use `AskUserQuestion` to gather missing details
3. Update plan with user responses
4. Re-run review to verify fixes
5. Continue until BLOCKING = 0 or max 5 iterations

#### Escape Hatches

| Flag | Purpose | Effect |
|------|---------|--------|
| `--lenient` | Bypass strict verification | BLOCKING → WARNING, plan saved with warnings |
| `--no-review` | Skip auto-review entirely | No review run, faster workflow |

#### Plan Structure for External Services

Plans involving external services must include:

**External Service Integration** section:
- API Calls Required table (From, To, Endpoint, SDK/HTTP, Status, Verification)
- New Endpoints to Create table
- Environment Variables Required table
- Error Handling Strategy table

**Implementation Details Matrix**:
- WHO (Service), WHAT (Action), HOW (Mechanism), VERIFY (Check)

**Gap Verification Checklist**:
- 6 categories with 3-4 verification questions each

---

## Context Engineering

### Hierarchical Documentation

Optimized token usage with layered docs:

- **L0** (Immediate): Quick reference, 30-second context
- **L1** (Structural): Architecture, patterns, workflows
- **L2** (Detailed): Implementation details, best practices
- **L3** (Reference): Deep dives, history, alternatives

### Folder CONTEXT.md

Each major folder should have a CONTEXT.md:

```markdown
# [Folder Name] Context

## Purpose
[What this folder does]

## Key Files
| File | Purpose |
|------|---------|

## Common Tasks
- **Task**: Description -> Command

## Patterns
- **Pattern**: Description
```

---

## Testing Strategy

### Coverage Targets

| Scope | Target | Priority |
|-------|--------|----------|
| Overall | 80% | Required |
| Core Modules | 90%+ | Required |
| UI Components | 70%+ | Nice to have |

### Running Tests

```bash
# All tests
npm test

# Coverage
npm run test:coverage

# Watch mode
npm test -- --watch

# Specific test
npm test -- --grep "test name"
```

---

## Quality Standards

### Code Quality

- **Type Safety**: Use TypeScript (or equivalent)
- **Linting**: Pass all lint rules
- **Formatting**: Consistent code style
- **Documentation**: Public APIs documented

### Commit Standards

- Conventional commits: `type(scope): description`
- Types: feat, fix, refactor, chore, docs, style, test
- Include Co-Authored-By: Claude <noreply@anthropic.com>

---

## Environment Setup

### Prerequisites

- Node.js 18+ (or equivalent for your language)
- Claude Code CLI
- Git

### Installation

```bash
# Install dependencies
npm install

# Copy claude-pilot files (if using)
git clone https://github.com/changoo89/claude-pilot.git
cp -r claude-pilot/.claude ./
```

### Environment Variables

```bash
# Required
ENV_VAR=value

# Optional
OPTIONAL_VAR=value
```

---

## Hooks Configuration

### Enabled Hooks

- **PreToolUse**: Type check, lint before edits
- **PostToolUse**: Type check after edits
- **Stop**: Todo completion check

### Hook Scripts

Located in `.claude/scripts/hooks/`:
- `typecheck.sh`: TypeScript validation
- `lint.sh`: ESLint/Pylint/gofmt
- `check-todos.sh`: Ralph continuation enforcement
- `branch-guard.sh`: Protected branch warnings

---

## MCP Servers

### Recommended MCPs

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |

### Configuration

See `.claude/settings.json` for MCP configuration.

---

## Agent Ecosystem

### Model Allocation Strategy

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient for repetitive/structured tasks |
| **Sonnet** | coder, tester, plan-reviewer | Balance of quality and speed for complex tasks |
| **Opus** | code-reviewer | Deep reasoning for critical review (async bugs, memory leaks) |

### Agent Types

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| explorer | haiku | Glob, Grep, Read | Fast codebase exploration |
| researcher | haiku | WebSearch, WebFetch, query-docs | External docs research |
| coder | sonnet | Read, Write, Edit, Bash | TDD implementation |
| tester | sonnet | Read, Write, Bash | Test writing and execution |
| validator | haiku | Bash, Read | Type check, lint, coverage |
| plan-reviewer | sonnet | Read, Glob, Grep | Plan analysis and gap detection |
| code-reviewer | opus | Read, Glob, Grep, Bash | Deep code review |
| documenter | haiku | Read, Write | Documentation generation |

### Parallel Execution Patterns

The workflow supports parallel execution for maximum efficiency:

- **Planning**: Explorer + Researcher (parallel exploration) - Step 0 of `/00_plan`
- **Execution**: Coder agents (parallel SC implementation) - Step 3 of `/02_execute`
- **Verification**: Tester + Validator + Code-Reviewer (parallel verification) - Step 3.5 of `/02_execute`
- **Review Feedback**: Optional Coder re-invoation for critical findings - Step 3.6 of `/02_execute`
- **Review**: Optional parallel multi-angle review - `/90_review`

**Agent Invocation**: All commands use **MANDATORY ACTION** sections with imperative language ("YOU MUST invoke... NOW") to ensure reliable agent delegation.

See `.claude/guides/parallel-execution.md` for detailed patterns.

---

## Important Notes

### Before Committing

- [ ] All tests pass
- [ ] Type check clean
- [ ] Lint clean
- [ ] Documentation updated
- [ ] No secrets included

### Before Deploying

- [ ] Run test suite
- [ ] Check environment variables
- [ ] Review migration files (if DB)
- [ ] Verify API compatibility

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Type errors | Run `npx tsc --noEmit` |
| Test failures | Check test names and fixtures |
| Hook errors | Check script permissions |
| Plan not found | Run `/00_plan` first |

---

## Related Documentation

### 3-Tier Documentation System

This project uses a hierarchical documentation system:

- **Tier 1**: `CLAUDE.md` (this file) - Project standards, workflows
- **Detailed Docs**: `docs/ai-context/` - System integration, project structure
- **Tier 2**: `{component}/CONTEXT.md` - Component-level architecture
- **Tier 3**: `{feature}/CONTEXT.md` - Feature-level implementation

### docs/ai-context/ Files

| File | Purpose |
|------|---------|
| `docs/ai-context/system-integration.md` | Command workflows, integration points |
| `docs/ai-context/project-structure.md` | Directory layout, key files |
| `docs/ai-context/docs-overview.md` | Navigation for all documentation |

### Component CONTEXT.md Files (Tier 2)

| Folder | CONTEXT.md | Purpose |
|--------|-----------|---------|
| `.claude/commands/` | [CONTEXT.md](.claude/commands/CONTEXT.md) | Command workflow, file list |
| `.claude/guides/` | [CONTEXT.md](.claude/guides/CONTEXT.md) | Guide usage, methodology patterns |
| `.claude/skills/` | [CONTEXT.md](.claude/skills/CONTEXT.md) | Skill list, auto-discovery mechanism |
| `.claude/agents/` | [CONTEXT.md](.claude/agents/CONTEXT.md) | Agent types, model allocation |

### External References

- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit) - 3-Tier Documentation System

---

## Project-Specific Notes

> **Customize this section for your project**

### Domain-Specific Patterns

[Add project-specific conventions here]

### Key Dependencies

[Add important dependencies and their purposes]

### Known Issues

[Document known workarounds or issues]

---

**Template Version**: claude-pilot 3.3.4
**Last Updated**: 2026-01-15
