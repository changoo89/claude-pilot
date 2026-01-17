# Commands Context

## Purpose

Slash commands for SPEC-First development workflow. Each command manages a specific phase of the development lifecycle: planning, confirmation, execution, completion, review, documentation, initialization, and publishing.

## Key Files

| File | Purpose | Lines | Workflow Phase | Description |
|------|---------|-------|----------------|-------------|
| `00_plan.md` | Create SPEC-First plan | 355 | Planning | Collect user requirements verbatim, explore codebase, gather requirements, design execution plan through dialogue (read-only) |
| `01_confirm.md` | Confirm plan + gap detection + requirements verification | 315 | Planning | Review plan, verify requirements coverage (Step 2.7), run gap detection, resolve BLOCKING issues, move to in_progress |
| `02_execute.md` | Execute with TDD + Ralph Loop | 654 | Execution | Plan detection (MANDATORY), atomic lock mechanism (worktree), parallel verification |
| `03_close.md` | Archive and commit | 465 | Completion | Archive completed plan, worktree cleanup (with error trap), create git commit, safe git push with retry logic and failure tracking |
| `90_review.md` | Multi-angle code review | 268 | Quality | Run comprehensive code review with multiple agent perspectives |
| `91_document.md` | Sync documentation | 288 | Maintenance | Update CLAUDE.md, sync templates, ensure consistency |
| `92_init.md` | Initialize new project | 209 | Setup | Initialize new project with claude-pilot template |
| `999_publish.md` | Sync templates + deploy | 222 | Release | Sync templates from upstream, bump version, deploy |

**Total**: 8 commands, 2776 lines (average: 347 lines per command)

## Common Tasks

### Create a Plan
- **Task**: Generate SPEC-First plan from user request with User Requirements Collection
- **Command**: `/00_plan "implement user authentication"`
- **Output**: Plan file saved to `.pilot/plan/pending/{timestamp}_{work}_{topic}.md`
- **Process**:
  1. Step 0: Collect user requirements verbatim (UR-1, UR-2, ...)
  2. Step 1: Explorer and Researcher agents explore codebase and external docs (parallel)
  3. Step 2-6: Plan-Reviewer agent creates SPEC-First plan
  4. Step 7: Present plan summary with User Requirements (Verbatim) section
  5. User reviews plan

### Confirm a Plan
- **Task**: Review plan, verify requirements coverage, detect gaps, resolve BLOCKING issues
- **Command**: `/01_confirm`
- **Output**: Plan moved to `.pilot/plan/in_progress/`
- **Process**:
  1. Extract plan from conversation
  2. Step 2.7: Verify 100% requirements coverage (UR → SC mapping)
  3. BLOCKING if any requirement missing
  4. Plan-Reviewer agent runs gap detection review
  5. BLOCKING findings trigger Interactive Recovery (dialogue)
  6. User provides missing details
  7. Plan updated until BLOCKING = 0
  8. Plan moved to in_progress

### Execute Implementation
- **Task**: Implement features using TDD + Ralph Loop + Parallel Verification + GPT Escalation
- **Command**: `/02_execute [--wt]`
- **Output**: Feature code with tests, coverage 80%+, verified quality
- **Process**:
  1. **Step 1: Plan Detection (MANDATORY FIRST ACTION)**: Execute Bash commands to find plans in pending/ and in_progress/
  2. **Step 1.1: Plan State Transition (ATOMIC)**: Plan auto-moves from pending to in_progress (atomic operation)
  3. **Worktree mode** (`--wt`): Atomic lock prevents race conditions
  4. Coder Agent executes TDD cycle for each Success Criterion
  5. Parallel Verification (Step 3.5): Tester + Validator + Code-Reviewer agents
  6. Review Feedback Loop (Step 3.6): Address critical findings if any
  7. **GPT Expert Escalation (Step 3.7)**: After 2+ Coder failures, delegate to GPT Architect for fresh perspective
  8. Ralph Loop iterates until all quality gates pass

### Close and Archive
- **Task**: Archive plan, worktree cleanup, create git commit, safe git push
- **Command**: `/03_close`
- **Output**: Plan in `.pilot/plan/done/`, worktree removed, git commit created, changes pushed to remote
- **Process**:
  1. Move plan from in_progress to done
  2. **Worktree mode**: Complete cleanup (worktree, branch, directory, lock)
  3. **Error trap**: Auto-releases lock on any failure
  4. Generate commit message from plan content
  5. Create git commit (if user approves)
  6. **Safe git push** (dry-run verification, retry logic, failure tracking, summary):
     - Helper functions: `get_push_error_message()`, `git_push_with_retry()`, `print_push_summary()`
     - Retry logic: 3 attempts with exponential backoff (2s, 4s, 8s) for transient failures
     - Error tracking: `PUSH_FAILURES` and `PUSH_RESULTS` arrays store push outcomes
     - Simplified error messages: User-friendly messages instead of raw git output
     - Non-blocking: Push failures don't exit workflow; summary shown at end
  7. Update active plan pointer

### Git Push Behavior (Step 7.3)
The `/03_close` command implements robust git push handling:

**Features**:
- **Dry-run verification**: Tests push before actual execution
- **Retry logic**: Transient failures (network, auth) retry up to 3 times
- **Exponential backoff**: Wait times of 2s, 4s, 8s between retries
- **Error simplification**: Maps git exit codes to user-friendly messages
- **Failure tracking**: Stores all push failures and displays summary at end
- **Non-blocking**: Workflow continues even if push fails

**Error Messages**:
- Non-fast-forward: "Remote has new commits - run 'git pull' before pushing"
- Authentication failed: "Authentication failed - check your credentials"
- Network error: "Network error - connection failed"
- Repository not found: "Remote repository not found - check remote URL"
- Branch protected: "Branch is protected - push not allowed directly"

**Output Example**:
```
⚠️  Git Push Summary
════════════════════════════════════════════════════════════
Push failed for 1 repository:

  📁 /Users/user/project
     ❌ Remote has new commits - run 'git pull' before pushing

💡 Tip: Commits were created successfully. Push manually with:
   git push origin <branch>
════════════════════════════════════════════════════════════
```

### Review Code
- **Task**: Multi-angle code review with GPT expert option
- **Command**: `/90_review`
- **Output**: Comprehensive review report
- **Process**:
  1. Tester Agent: Test coverage and quality
  2. Validator Agent: Type safety and linting
  3. Code-Reviewer Agent: Deep analysis (async bugs, memory leaks)
  4. **GPT Expert Review (Step 10)**: For complex plans (5+ SCs) or architecture review
     - GPT Architect: System design, tradeoffs
     - GPT Plan Reviewer: Large plan validation
  5. Plan-Reviewer Agent: Requirements verification

### Document Project
- **Task**: Sync documentation
- **Command**: `/91_document`
- **Output**: Updated CLAUDE.md, synced docs
- **Process**:
  1. Documenter Agent scans codebase
  2. Updates CLAUDE.md with current structure
  3. Syncs templates if needed

### Initialize New Project
- **Task**: Initialize new project with template
- **Command**: `/92_init`
- **Output**: New project with claude-pilot structure
- **Process**:
  1. Interactive project setup
  2. Copy template files
  3. Customize CLAUDE.md
  4. Initialize git repository

### Publish Release
- **Task**: Sync templates, bump version, deploy
- **Command**: `/999_publish`
- **Output**: Version bumped, templates synced, deployed
- **Process**:
  1. Sync templates from upstream
  2. Bump version in CLAUDE.md and package.json
  3. Run verification tests
  4. Deploy to production

## Patterns

### Plan Flow Pattern
```
User Request
       ↓
/00_plan (Step 0: Collect URs verbatim)
       ↓
/01_confirm (Step 2.7: Verify 100% coverage)
       ↓
/02_execute → Implementation (code + tests)
       ↓
/03_close → .pilot/plan/done/ + commit
```

### Agent Invocation Pattern
All commands use MANDATORY ACTION sections for reliable agent delegation:
```markdown
> **🚨 MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW with:
- Plan path
- Success criteria
- Key constraints
```

**Purpose**: Ensures agents are invoked with correct parameters every time.

### Phase Boundary Protection
Commands enforce strict phase boundaries:
- `/00_plan`: Read-only (planning phase)
- `/02_execute`: Implementation phase only
- `/03_close`: Completion phase only

**Example from `/00_plan`**:
```markdown
> **⚠️ CRITICAL**: DO NOT start implementation during /00_plan.
> - ❌ NO code editing, test writing, or file creation
> - ✅ OK: Exploration (Glob, Grep, Read), Analysis, Planning, Dialogue
```

### Parallel Execution Pattern
Commands orchestrate multiple agents in parallel for efficiency:
- `/00_plan`: Explorer + Researcher (parallel exploration)
- `/02_execute Step 3.5`: Tester + Validator + Code-Reviewer (parallel verification)
- `/90_review`: Tester + Validator + Code-Reviewer (parallel verification)

**See**: @.claude/guides/parallel-execution.md for detailed patterns

### Methodology Extraction Pattern
Methodology details extracted to guides/skills to keep commands focused:
```markdown
> **Methodology**: @.claude/skills/tdd/SKILL.md
> **Details**: @.claude/guides/prp-framework.md
```

**Purpose**: Keep commands concise (target: 150 lines), delegate methodology to docs.

### Auto-Discovery Pattern
All commands have frontmatter for slash command discovery:
```yaml
---
description: {trigger-rich description}
argument-hint: "[args] - optional description"
allowed-tools: [tool list]
---
```

**Description guidelines**:
- Under 200 characters
- Action keywords (plan, execute, review, etc.)
- Specific scenarios mentioned

### Ambiguous Confirmation Handling
`/00_plan` uses `AskUserQuestion` to resolve ambiguous confirmations:
```markdown
> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion` before ANY phase transition.
>
> **CRITICAL**: Do NOT try to detect specific words or phrases. ANY ambiguous confirmation MUST trigger the `AskUserQuestion` flow.
```

**Purpose**: Prevent accidental phase transitions when user says "go ahead" or "proceed".

## Command Relationships

### Planning Phase Commands
- `00_plan`: Create plan (read-only exploration)
- `01_confirm`: Review and approve plan

### Execution Phase Commands
- `02_execute`: Implement with TDD + Ralph Loop

### Completion Phase Commands
- `03_close`: Archive and commit

### Quality Commands
- `90_review`: Multi-angle code review

### Maintenance Commands
- `91_document`: Sync documentation
- `999_publish`: Release and deploy

### Setup Commands
- `92_init`: Initialize new project

## File Organization

### Naming Convention
- **Workflow commands**: `00` through `03` (sequential execution)
- **Quality commands**: `90` through `99` (utilities)
- **Setup commands**: `92_init` (initialization only)

### Argument Hints
Commands use `argument-hint` in frontmatter for parameter discovery:
```yaml
argument-hint: "[task_description] - required description of the work"
```

### Allowed Tools
Commands specify `allowed-tools` in frontmatter to restrict operations:
```yaml
# Planning command (read-only)
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion

# Execution command (write-enabled)
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
```

## Phase 2 Refactoring Complete (2026-01-15)

**Status**: All command files reduced to ≤300 lines
**Total reduction**: 999 lines (29.7%) | 3361 → 2362 lines
**Methodology details extracted to**: @.claude/guides/ and @.claude/skills/
**All MANDATORY ACTION sections preserved**: ✅ Functionality maintained

## See Also

**Workflow guides**:
- @.claude/guides/requirements-tracking.md - User Requirements Collection methodology
- @.claude/guides/requirements-verification.md - Requirements Verification methodology
- @.claude/guides/prp-framework.md - SPEC-First requirements methodology
- @.claude/guides/gap-detection.md - Gap detection review for external services
- @.claude/guides/parallel-execution.md - Agent orchestration patterns

**Implementation guides**:
- @.claude/skills/tdd/SKILL.md - Test-Driven Development cycle
- @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and model allocation

**Documentation standards**:
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
