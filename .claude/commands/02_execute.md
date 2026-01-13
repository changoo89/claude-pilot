---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern - iterate until all tests pass._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **One active plan**: Exactly one plan active per git branch
- **No drift**: Update plan and todo list if scope changes
- **Evidence required**: Never claim completion without verification output

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

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
    check_worktree_support || { echo "Error: Git worktree not supported (need Git 2.5+)" >&2; exit 1; }
    PENDING_PLAN="$(select_oldest_pending)" || { echo "No pending plans. Run /00_plan first" >&2; exit 1; }
    PLAN_FILENAME="$(basename "$PENDING_PLAN")"
    BRANCH_NAME="$(plan_to_branch "$PLAN_FILENAME")"
    MAIN_BRANCH="main"; git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1 || MAIN_BRANCH="master"
    WORKTREE_DIR="$(create_worktree "$BRANCH_NAME" "$PLAN_FILENAME" "$MAIN_BRANCH")" || exit 1
    WORKTREE_ABS="$(cd "$(dirname "$WORKTREE_DIR")" && pwd)/$(basename "$WORKTREE_DIR")"
    IN_PROGRESS_PLAN="${WORKTREE_ABS}/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$(dirname "$IN_PROGRESS_PLAN")"; mv "$PENDING_PLAN" "$IN_PROGRESS_PLAN"
    add_worktree_metadata "$IN_PROGRESS_PLAN" "$BRANCH_NAME" "$WORKTREE_ABS" "$MAIN_BRANCH"
    mkdir -p "${WORKTREE_ABS}/.pilot/plan/active"
    BRANCH_KEY="$(printf "%s" "$BRANCH_NAME" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    printf "%s" "$IN_PROGRESS_PLAN" > "${WORKTREE_ABS}/.pilot/plan/active/${BRANCH_KEY}.txt"
    cp "$IN_PROGRESS_PLAN" ".pilot/plan/in_progress/${PLAN_FILENAME}"
    echo "✅ Worktree: $WORKTREE_ABS | Branch: $BRANCH_NAME | Plan: $IN_PROGRESS_PLAN"
    PLAN_PATH="$IN_PROGRESS_PLAN"; cd "$WORKTREE_ABS" || exit 1
fi
```

### 1.2 Determine Plan Path
Priority: 1) Explicit from args, 2) Oldest in pending/, 3) Active pointer, 4) Most recent in in_progress/

```bash
PLAN_PATH="${EXPLICIT_PATH}"
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t .pilot/plan/pending/*.md 2>/dev/null | tail -1)"
[ -z "$PLAN_PATH" ] && BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)" && \
    KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')" && \
    ACTIVE_PTR=".pilot/plan/active/${KEY}.txt" && [ -f "$ACTIVE_PTR" ] && PLAN_PATH="$(cat "$ACTIVE_PTR")"
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t .pilot/plan/in_progress/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "No plan found. Run /00_plan then /01_confirm" >&2; exit 1; }
echo "Selected: $PLAN_PATH"
```

### 1.3 Move to In-Progress & Create Active Pointer
```bash
if printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"; IN_PROGRESS_PATH=".pilot/plan/in_progress/${PLAN_FILENAME}"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"; PLAN_PATH="$IN_PROGRESS_PATH"; echo "Moved to in_progress"
fi
mkdir -p .pilot/plan/active; BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > ".pilot/plan/active/${KEY}.txt"
```

---

## Step 2: Convert Plan to Todo List

Read plan, extract: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan, Open Questions

Create todo list mirroring plan phases. Rules: Atomic/verifiable todos, exactly one `in_progress`, mark complete immediately after finishing

Resolve ambiguities: Ask one clarifying question before coding if plan missing critical info

---

## Step 3: Execute with TDD (Red-Green-Refactor)

> **Principle**: Tests drive development. AI works within test guardrails.

### 3.1 Discovery
Search codebase: `Glob **/*{keyword}*`, `Grep {pattern}`. Confirm integration points, update plan if reality differs from assumptions

### 3.2 Red Phase: Write Failing Tests
For each SC-N: 1) Generate test stub, 2) Write assertions, 3) Run → confirm RED (failing)
```bash
npm run test -- --grep "SC-1"  # Expected: FAIL
```

### 3.3 Green Phase: Minimal Implementation
Write ONLY enough code to pass. No optimization/extra features. Run → confirm GREEN
```bash
npm run test -- --grep "SC-1"  # Expected: PASS
```

### 3.4 Refactor Phase: Clean Up
Improve quality (DRY, SOLID), do NOT change behavior. Run ALL tests → confirm GREEN
```bash
npm run test  # Expected: ALL PASS
```

### 3.5 Vibe Coding Enforcement
> **Enforce during ALL code generation**:
> - Functions ≤50 lines, Files ≤200 lines, Nesting ≤3 levels
> - SRP, DRY, KISS, Early Return pattern
> - Generate in small increments, test immediately, never trust blindly

### 3.6 Repeat Cycle
Iterate all SC: SC-1 Red→Green→Refactor, SC-2 Red→Green→Refactor, ...until all met

---

## Step 4: Ralph Loop (Autonomous Completion)

> **Principle**: Self-correcting loop until completion marker detected

### 4.1 Loop Structure
```
WHILE NOT <done_marker>:
    1. Run verification (tests, type-check, lint)
    2. IF all pass: Check todos; IF all complete → mark <done_marker>
    3. ELSE: Analyze failures, fix (errors > warnings > suggestions), continue
```

### 4.2 Verification Commands
```bash
npx tsc --noEmit      # Type check
npm run lint          # Lint
npm run test          # Tests
npm run test -- --coverage  # Coverage
```

### 4.3 Exit Conditions
| Type | Criteria |
|------|----------|
| ✅ Success | All tests pass, type clean, lint clean, todos complete |
| ❌ Failure | Max 7 iterations, unrecoverable error, user intervention needed |

### 4.4 Iteration Tracking
Log to `.pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md`:

| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
| 1 | ❌ 3 fail | ✅ | ⚠️ 2 | 45% | Continue |
| 2 | ❌ 1 fail | ✅ | ✅ | 72% | Continue |
| 3 | ✅ | ✅ | ✅ | 82% | ✅ Done |

---

## Step 5: Todo Continuation Enforcement

> **Principle**: Never quit halfway

**Rules**: One `in_progress` at a time, mark complete RIGHT AFTER finishing, no batching, no abandonment (create sub-task if stuck)

**Enforcement Check**: Before ending any turn, verify:
- [ ] Current in_progress todo completed or explicitly blocked
- [ ] Blocked items have clear blocker description
- [ ] Next pending item set to in_progress
- [ ] All completed items marked

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
If `"$ARGUMENTS"` contains `--no-docs`, skip documentation

---

## Success Criteria

| Criteria | Verification |
|----------|-------------|
| Plan executed | All phases completed |
| Tests pass | All SC met |
| Type clean | `npx tsc --noEmit` exits 0 |
| Lint clean | `npm run lint` exits 0 |
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

## Ralph Loop Settings

| Setting | Value |
|---------|-------|
| Max iterations | 7 |
| Overall coverage | 80% |
| Core coverage | 90%+ |
| Exit on | All pass + todos done |

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- `.claude/guides/review-extensions.md`
- **Branch**: !`git rev-parse --abbrev-ref HEAD`

---

## Next Command
After successful execution: `/03_close`
