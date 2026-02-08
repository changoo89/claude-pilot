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
/00_plan (read-only exploration via planning-team)
       ↓
/01_confirm (requirements verification via plan-reviewer)
       ↓
/02_execute (TDD + Ralph Loop via execution-team)
       ↓
/03_close (archive + commit with validator/documenter)
       ↓
/review (anytime via review-team - optional)
```

**Alternative**: `/04_fix` for simple bugs

**Agent Teams Architecture**: All workflow commands leverage Agent Teams for parallel execution and direct teammate communication.

---

## Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan
- **CANNOT DO**: Edit files, Write files, Create code, Implement

**Implementation Phase**: Starts ONLY after `/01_confirm` → `/02_execute`

---

## Related Skills

Each command delegates to appropriate skills:
- **agent-teams**: Agent Teams coordination patterns
- **spec-driven-workflow**: Plan creation with planning-team
- **execute-plan**: SC execution via execution-team (Team Lead spawns coder, frontend-engineer, backend-engineer teammates)
- **confirm-plan**: Plan verification via plan-reviewer teammate
- **close-plan**: Archive and commit with validator/documenter teammates
- **parallel-subagents**: Rewritten for Agent Teams (teammate spawn patterns)
- **tdd**: Test-driven development (used by coder teammates)
- **ralph-loop**: Autonomous iteration (used by coder teammates)
- **git-master**: Git operations

## Agent Teams Integration

### /02_execute (Execution Team)
**Team Lead** (delegate mode): Spawns teammates based on SC analysis
- **frontend-engineer**: Frontend SCs (React, UI, styling)
- **backend-engineer**: Backend SCs (API, database, server)
- **coder**: General SCs (fallback)
- **build-error-resolver**: Build error recovery

**Coordination**: Team Lead monitors progress, handles blocked teammates, aggregates results

### /review (Review Team)
**Team Lead** (delegate mode): Spawns review teammates in parallel
- **tester**: Test coverage analysis
- **validator**: Type-check, lint, coverage verification
- **code-reviewer** (Opus): Deep code review with risk assessment
- **security-analyst**: Security vulnerability analysis (on `/review security`)
- **design-reviewer**: Design quality review (on `/review --design-review`)

**Enhanced**: Reviewers discuss findings with each other via Message tool for cross-validation

### /00_plan (Planning Team)
**Team Lead** (delegate mode): Spawns exploration teammates in parallel
- **explorer**: Codebase exploration (files, patterns)
- **researcher**: External docs research (best practices)

**Coordination**: Teammates share findings via Message, Team Lead synthesizes into plan

### /01_confirm (Plan Review)
**Team Lead** (delegate mode): Spawns plan-reviewer teammate
- **plan-reviewer**: Verify requirements completeness, SC clarity, dependencies

### /03_close (Completion)
**Team Lead** (delegate mode): Spawns validation/documentation teammates sequentially
- **validator**: TODO verification and resolution
- **documenter**: Documentation sync with change detection

---

**See**: Individual command files for detailed usage
