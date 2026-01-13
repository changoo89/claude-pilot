# [Project Name] - Claude Code Development Guide

> **Last Updated**: [Date]
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
- **Version**: [e.g., 1.0.0]
- **Stage**: [e.g., Development, Beta, Production]
- **Last Updated**: [Date]

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
│   ├── guides/             # Methodology guides
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   └── scripts/hooks/      # Type check, lint, todos
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
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

**Template Version**: claude-pilot 1.0.0
**Last Updated**: [Date]
