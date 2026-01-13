# [Project Name] - Claude Code Configuration

> **Last Updated**: [Date]
> **Template**: claude-pilot

---

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Type check
npx tsc --noEmit

# Lint
npm run lint
```

## Project Overview

**One-line description**: [What this project does]

**Tech Stack**:
- Runtime: Node.js 20+
- Language: TypeScript 5+
- Framework: [e.g., Next.js, Express, React]
- Testing: [e.g., Jest, Vitest]

## Key Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm test` | Run tests |
| `npm run lint` | Check code style |
| `npx tsc --noEmit` | Type check only |

## Development Workflow

1. **Plan**: Use `/00_plan` to create SPEC-First execution plans
2. **Confirm**: Use `/01_confirm` to save plan to pending/ (optional)
3. **Execute**: Use `/02_execute` to implement with TDD
4. **Review**: Use `/90_review` for multi-angle code analysis
5. **Document**: Use `/91_document` to sync documentation
6. **Close**: Use `/03_close` to finalize and commit

## Important Notes

- **Type Safety**: All code must pass `tsc --noEmit`
- **Linting**: Run `npm run lint` before committing
- **Testing**: Write tests for new features

## Context Files

- `CLAUDE.md` - This file (project overview)
- `.claude/templates/` - Document templates for CONTEXT.md, SKILL.md
- `.claude/commands/` - Slash command definitions
