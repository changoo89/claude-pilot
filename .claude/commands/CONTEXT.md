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

## Workflow

```
/00_plan → /01_confirm → /02_execute → /03_close → /document
```

**Alternative**: `/04_fix` for simple bugs


---

## Related Skills

Each command delegates to appropriate skills:
- **spec-driven-workflow**: Plan creation
- **tdd**: Test-driven development
- **ralph-loop**: Autonomous iteration
- **git-master**: Git operations

---

**See**: Individual command files for detailed usage
