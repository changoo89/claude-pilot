# Commands Context

Slash commands for SPEC-First development workflow.

## Quick Reference

| Command | Purpose | Phase |
|----------|---------|-------|
| `/setup` | Configure MCP servers | Setup |
| `/00_plan` | Create SPEC-First plan | Planning |
| `/01_confirm` | Confirm plan + gap detection | Planning |
| `/02_execute` | Execute with TDD + Ralph Loop | Execution |
| `/03_close` | Archive and commit | Completion |
| `/04_fix` | Rapid bug fix workflow | Rapid |
| `/05_cleanup` | Dead code cleanup | Maintenance |
| `/review` | Multi-angle code review | Quality |
| `/document` | Sync documentation | Maintenance |
| `/999_release` | Version bump + release | Release |

---

## Workflow Sequence

```
User Request
       ↓
/00_plan (read-only exploration)
       ↓
/01_confirm (requirements verification)
       ↓
/02_execute (TDD + Ralph Loop)
       ↓
/03_close (archive + commit)
       ↓
/review (anytime - optional)
```

**Alternative**: `/04_fix` for simple bugs

---

## Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan
- **CANNOT DO**: Edit files, Write files, Create code, Implement

**Implementation Phase**: Starts ONLY after `/01_confirm` → `/02_execute`

---

## Related Skills

Each command delegates to appropriate skills:
- **spec-driven-workflow**: Plan creation
- **execute-plan**: Agent selection and implementation orchestration
- **tdd**: Test-driven development
- **ralph-loop**: Autonomous iteration
- **git-master**: Git operations

## Agent Selection

Commands invoke specialized agents based on task type:
- `/02_execute`: Selects frontend-engineer, backend-engineer, build-error-resolver, or coder based on task keywords
- `/review`: Invokes tester, validator, security-analyst, or code-reviewer based on review type

---

**See**: Individual command files for detailed usage
