---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern - iterate until all tests pass._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **One active plan**: Exactly one plan active per git branch
- **No drift**: Update plan and todo list if scope changes
- **Evidence required**: Never claim completion without verification output

**TDD Methodology**: See @.claude/guides/tdd-methodology.md
**Ralph Loop**: See @.claude/guides/ralph-loop.md

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 1: Select Plan & Worktree Mode

### 1.1 Worktree Mode (--wt)
```bash
if is_worktree_mode "$@"; then
    check_worktree_support || { echo "Error: Git worktree not supported" >&2; exit 1; }
    PENDING_PLAN="$(select_oldest_pending)" || { echo "No pending plans. Run /00_plan first" >&2; exit 1; }
    PLAN_FILENAME="$(basename "$PENDING_PLAN")"
    BRANCH_NAME="$(plan_to_branch "$PLAN_FILENAME")"
    MAIN_BRANCH="main"; git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1 || MAIN_BRANCH="master"
    WORKTREE_DIR="$(create_worktree "$BRANCH_NAME" "$PLAN_FILENAME" "$MAIN_BRANCH")" || exit 1
    # ... (full worktree setup in backup)
    PLAN_PATH="$IN_PROGRESS_PLAN"; cd "$WORKTREE_ABS" || exit 1
fi
```

### 1.2 Determine Plan Path
Priority: 1) Explicit from args, 2) Oldest in pending/, 3) Active pointer, 4) Most recent in in_progress/

```bash
PLAN_PATH="${EXPLICIT_PATH}"
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t .pilot/plan/pending/*.md 2>/dev/null | tail -1)"
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t .pilot/plan/in_progress/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "No plan found. Run /00_plan first" >&2; exit 1; }
```

### 1.3 Move to In-Progress & Create Active Pointer
```bash
if printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"; IN_PROGRESS_PATH=".pilot/plan/in_progress/${PLAN_FILENAME}"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"; PLAN_PATH="$IN_PROGRESS_PATH"
fi
mkdir -p .pilot/plan/active; BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > ".pilot/plan/active/${KEY}.txt"
```

---

## Step 2: Convert Plan to Todo List

Read plan, extract: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan, Open Questions

Create todo list mirroring plan phases. Rules: Atomic/verifiable todos, exactly one `in_progress`, mark complete immediately after finishing

**MANDATORY**: After EVERY "Implement", "Add", "Create" todo, add a corresponding "Run tests for [X]" todo immediately after.

---

## Step 3: Execute with TDD

**TDD Cycle (Red-Green-Refactor)**: See @.claude/guides/tdd-methodology.md

### 3.1 Discovery
Search codebase: `Glob **/*{keyword}*`, `Grep {pattern}`

### 3.2 Red Phase: Write Failing Tests
For each SC-N: Generate test stub, Write assertions, Run → confirm RED

### 3.3 Green Phase: Minimal Implementation
Write ONLY enough code to pass. Run → confirm GREEN

### 3.4 Refactor Phase: Clean Up
Improve quality (DRY, SOLID), Run ALL tests → confirm GREEN

### 3.5 TDD-Ralph Integration (CRITICAL)

**After EVERY Edit/Write tool call, you MUST run tests immediately.**

**Ralph Micro-Cycle**:
1. Edit/Write code
2. Mark test todo as in_progress
3. Run tests (use detected test command)
4. Analyze results
5. Fix failures or mark test todo complete
6. Repeat

**Test Command Auto-Detection**: See @.claude/guides/test-environment.md

---

## Step 4: Ralph Loop (Autonomous Completion)

**Ralph Loop**: See @.claude/guides/ralph-loop.md

> **Principle**: Self-correcting loop until completion marker detected

### Ralph Loop Entry Condition (CRITICAL)

**Ralph Loop starts IMMEDIATELY after the FIRST code change.**

**Correct Entry Points**:
- ✅ After implementing first feature/function
- ✅ After fixing a bug
- ✅ After any Edit/Write tool call

**❌ WRONG**: After completing all todos, at very end

### 4.1 Completion Promise
Output `<RALPH_COMPLETE>` marker **ONLY when** ALL conditions are met:
- [ ] All tests pass
- [ ] Coverage 80%+ (core modules 90%+)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

### 4.2 Loop Structure
```
MAX_ITERATIONS=7
WHILE ITERATION <= MAX AND NOT <RALPH_COMPLETE>:
    1. Run: tests, type-check, lint, coverage
    2. Log iteration to ralph-loop-log.md
    3. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    4. ELSE:
         Fix (priority: errors > coverage > lint)
         ITERATION++
```

### 4.3 Verification Commands

**Test Detection**: See @.claude/guides/test-environment.md

```bash
# Auto-detect test command
DETECT_TEST_CMD() {
    if [ -f "pyproject.toml" ]; then echo "pytest"
    elif [ -f "package.json" ]; then echo "npm test"
    elif [ -f "go.mod" ]; then echo "go test ./..."
    elif [ -f "Cargo.toml" ]; then echo "cargo test"
    else echo "npm test"; fi
}

# Run verification
$TEST_CMD
[ -f "package.json" ] && grep -q "typescript" && npx tsc --noEmit
[ -f "package.json" ] && grep -q '"lint"' && npm run lint
```

### 4.4 Exit Conditions
| Type | Criteria |
|------|----------|
| ✅ Success | All tests pass, coverage 80%+ (core 90%+), type clean, lint clean, todos complete |
| ❌ Failure | Max 7 iterations reached, unrecoverable error |
| ⚠️ Blocked | `<RALPH_BLOCKED>` output |

### 4.5 Coverage Enforcement
- Overall < 80%: Continue improving tests
- Core modules < 90%: Focus on core test coverage

---

## Step 5: Todo Continuation Enforcement

> **Principle**: Never quit halfway

**Rules**: One `in_progress` at a time, mark complete RIGHT AFTER finishing, no batching, no abandonment

---

## Step 6: Verification

```bash
echo "Running type check..."; npx tsc --noEmit; TYPE_CHECK_RESULT=$?
echo "Running tests..."; npm run test; TEST_RESULT=$?
echo "Running lint..."; npm run lint; LINT_RESULT=$?
[ $TYPE_CHECK_RESULT -eq 0 ] && [ $TEST_RESULT -eq 0 ] && [ $LINT_RESULT -eq 0 ] && echo "✅ All passed" || { echo "❌ Some failed"; exit 1; }
```

---

## Step 7: Update Plan Artifacts

```bash
cat >> "$PLAN_PATH" << 'EOF'
## Execution Summary
### Changes Made: [List]
### Verification: Type ✅, Tests ✅ (X% coverage), Lint ✅
### Follow-ups: [Items]
EOF
```

---

## Step 8: Auto-Chain to Documentation

> **Principle**: 3-sync pattern - implementation complete → docs auto-sync

### 8.1 Trigger (all must be true)
- [ ] All todos complete, [ ] Ralph Loop exited successfully
- [ ] Coverage 80%+ overall, 90%+ core, [ ] Type + lint clean

### 8.2 Auto-Invoke
```
Skill: 91_document
Args: auto-sync from {RUN_ID}
```

### 8.3 Skip
If `--no-docs` specified, skip documentation

---

## Success Criteria

| Criteria | Verification |
|----------|-------------|
| Plan executed | All phases completed |
| Tests pass | All SC met |
| Type clean | Type check exits 0 |
| Lint clean | Lint exits 0 |
| Coverage | 80%+ overall, 90%+ core |
| Ready for close | Documentation synced |

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
                      ↓
                [Ralph Loop → TDD Cycle → 91_document]
```

---

## Related Guides
- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/ralph-loop.md - Autonomous completion loop
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection
- @.claude/guides/3tier-documentation.md - Auto-sync documentation

---

## Next Command
After successful execution: `/03_close`

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
