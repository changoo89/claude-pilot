---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /02_execute

_Execute a pending or in-progress plan using Ralph Loop TDD pattern - iterate until all tests pass._

---

## Core Philosophy

- **Single source of truth**: The plan file drives the work.
- **One active plan**: Keep exactly one plan active per git branch.
- **No drift**: If you change scope, update the plan and the todo list.
- **Evidence required**: Do not claim completion without verification output.

---

## Extended Thinking Mode

> **Conditional Activation**
> If the LLM model currently running in this session is a GLM model,
> proceed with maximum extended thinking throughout all phases of this command.
> This ensures deep reasoning and thorough analysis for complex tasks.

---

## Step 0: Source Worktree Utilities

```bash
# Source worktree utility functions
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
if [ -f "$WORKTREE_UTILS" ]; then
    . "$WORKTREE_UTILS"
else
    echo "Warning: Worktree utilities not found at $WORKTREE_UTILS"
fi
```

---

## Step 1.5: Worktree Mode (--wt flag)

> **When to use**: When you want to work in a parallel isolated environment using Git worktrees.

### 0.5.1 Check for Worktree Mode

```bash
if is_worktree_mode "$@"; then
    echo "Worktree mode enabled (--wt detected)"
    echo ""

    # Check Git worktree support
    if ! check_worktree_support; then
        echo "Error: Git worktree is not supported in this environment" >&2
        echo "Please upgrade to Git 2.5 or later" >&2
        exit 1
    fi

    # Select oldest pending plan
    PENDING_PLAN="$(select_oldest_pending)"

    if [ -z "$PENDING_PLAN" ]; then
        echo "No pending plans found in .pilot/plan/pending/" >&2
        echo "Create a plan first with /00_plan" >&2
        exit 1
    fi

    echo "Selected pending plan: $PENDING_PLAN"

    # Extract plan filename for branch generation
    PLAN_FILENAME="$(basename "$PENDING_PLAN")"

    # Generate branch name
    BRANCH_NAME="$(plan_to_branch "$PLAN_FILENAME")"
    echo "Creating branch: $BRANCH_NAME"

    # Determine main branch (default to 'main', but also check for 'master')
    MAIN_BRANCH="main"
    if ! git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1; then
        MAIN_BRANCH="master"
    fi

    # Create worktree
    WORKTREE_DIR="$(create_worktree "$BRANCH_NAME" "$PLAN_FILENAME" "$MAIN_BRANCH")"

    if [ -z "$WORKTREE_DIR" ]; then
        echo "Failed to create worktree" >&2
        exit 1
    fi

    # Convert to absolute path
    WORKTREE_ABS="$(cd "$(dirname "$WORKTREE_DIR")" && pwd)/$(basename "$WORKTREE_DIR")"

    # Move plan to in_progress in the worktree
    IN_PROGRESS_PLAN="${WORKTREE_ABS}/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$(dirname "$IN_PROGRESS_PLAN")"
    mv "$PENDING_PLAN" "$IN_PROGRESS_PLAN"

    # Add worktree metadata to plan
    add_worktree_metadata "$IN_PROGRESS_PLAN" "$BRANCH_NAME" "$WORKTREE_ABS" "$MAIN_BRANCH"

    # Create active pointer in worktree
    mkdir -p "${WORKTREE_ABS}/.pilot/plan/active"
    BRANCH_KEY="$(printf "%s" "$BRANCH_NAME" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    printf "%s" "$IN_PROGRESS_PLAN" > "${WORKTREE_ABS}/.pilot/plan/active/${BRANCH_KEY}.txt"

    # Copy plan to main repo's in_progress for tracking
    MAIN_IN_PROGRESS=".pilot/plan/in_progress/${PLAN_FILENAME}"
    cp "$IN_PROGRESS_PLAN" "$MAIN_IN_PROGRESS"

    echo ""
    echo "✅ Worktree created successfully!"
    echo ""
    echo "📂 Worktree location: $WORKTREE_ABS"
    echo "🌿 Branch: $BRANCH_NAME"
    echo "📝 Plan: $IN_PROGRESS_PLAN"
    echo ""
    echo "🔄 Continuing execution in worktree directory..."
    echo ""
    echo "When done, run /03_close from the worktree to squash merge and cleanup."
    echo ""

    # Update PLAN_PATH to point to the worktree location
    PLAN_PATH="$IN_PROGRESS_PLAN"

    # Change to worktree directory and continue execution
    # Claude Code will use this as the new working directory
    cd "$WORKTREE_ABS" || exit 1
fi
```

---

## Step 1: Select the Plan to Execute

### 1.1 Determine Plan Path

Priority order:
1. Explicit path from `"$ARGUMENTS"`
2. Oldest (first created) file in `.pilot/plan/pending/`
3. Read active pointer from `.pilot/plan/active/{branch}.txt`
4. Most recent file in `.pilot/plan/in_progress/`

```bash
PLAN_PATH=""

# 1. Explicit path from arguments
if [ -n "$EXPLICIT_PATH" ]; then
    PLAN_PATH="$EXPLICIT_PATH"
fi

# 2. Oldest file in pending/
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1t .pilot/plan/pending/*.md 2>/dev/null | tail -1)"
fi

# 3. Read active pointer
if [ -z "$PLAN_PATH" ]; then
    BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
    KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

    if [ -f "$ACTIVE_PTR" ]; then
        PLAN_PATH="$(cat "$ACTIVE_PTR")"
    fi
fi

# 4. Most recent in in_progress/
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1t .pilot/plan/in_progress/*.md 2>/dev/null | head -1)"
fi

if [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ]; then
    echo "No plan found to execute."
    echo "Run /00_plan to create a plan, then /01_confirm to save it."
    exit 1
fi

echo "Selected plan: $PLAN_PATH"
```

---

## Step 1.5: Move Plan to In-Progress

> **Principle**: Auto-detect and move plans from pending/ to in_progress/.
>
> **Behavior**:
> - If plan path contains `/pending/`, automatically move to `in_progress/`
> - If plan is already in `in_progress/`, no action needed
> - This enables the workflow: `/01_confirm` (creates in pending/) → `/02_execute` (moves to in_progress/)

### 1.5.1 Check if Plan is in Pending

```bash
if printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    echo "Plan is in pending/. Moving to in_progress/..."

    # Extract filename
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH=".pilot/plan/in_progress/${PLAN_FILENAME}"

    # Move the file
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
    PLAN_PATH="$IN_PROGRESS_PATH"

    echo "Plan moved to: $PLAN_PATH"
fi
```

---

## Step 1.6: Create Active Pointer

> **Principle**: Record the active plan for this branch.

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

printf "%s" "$PLAN_PATH" > "$ACTIVE_PTR"
echo "Active plan recorded for branch: $BRANCH"
```

---

## Step 2: Convert Plan to Todo List

### 1.1 Read the Plan

Read `.pilot/plan/in_progress/{RUN_ID}/plan.md` and extract:
- Deliverables
- Phases and tasks
- Acceptance criteria
- Test plan
- Open questions

### 1.2 Create Todo List

Create a detailed todo list that mirrors the plan phases.

**Rules**:
- Each todo is atomic and verifiable
- Exactly one `in_progress` at a time
- Mark todos complete immediately after finishing

### 1.3 Resolve Ambiguities

If the plan has missing critical information, ask one clarifying question before coding.

---

## Step 3: Execute with TDD (Red-Green-Refactor)

> **Principle**: Tests drive development. AI works within test guardrails.

### 2.1 Discovery

Search the codebase for relevant files/patterns:
```bash
# Find related code
Glob **/*{keyword}*
Grep {pattern}
```

Confirm integration points. Update the plan if discovered reality differs from assumptions.

### 2.2 Red Phase: Write Failing Tests

For each Success Criterion (SC-N):
1. Generate test stub from requirement
2. Write specific assertions
3. Run test → confirm RED (failing)

```bash
# Run specific test
npm run test -- --grep "SC-1"
# Expected: FAIL
```

### 2.3 Green Phase: Minimal Implementation

1. Write ONLY enough code to pass the test
2. No optimization, no extra features
3. Run test → confirm GREEN (passing)

```bash
npm run test -- --grep "SC-1"
# Expected: PASS
```

### 2.4 Refactor Phase: Clean Up

1. Improve code quality (DRY, SOLID)
2. Do NOT change behavior
3. Run ALL tests → confirm still GREEN

```bash
npm run test
# Expected: ALL PASS
```

### 2.5 Repeat Cycle

Iterate through all Success Criteria:
- SC-1: Red → Green → Refactor
- SC-2: Red → Green → Refactor
- ...until all criteria met

---

## Step 4: Ralph Loop (Autonomous Completion)

> **Principle**: Self-correcting loop until completion marker detected.

### 3.1 Loop Structure

```
WHILE NOT <done_marker> detected:
    1. Run verification (tests, type-check, lint)
    2. IF all pass:
        - Check todo list completion
        - IF all todos complete → mark <done_marker>
    3. ELSE:
        - Analyze failures
        - Fix issues (prioritize: errors > warnings > suggestions)
        - Continue loop
```

### 3.2 Verification Commands

```bash
# Type check
npx tsc --noEmit

# Lint
npm run lint

# Tests
npm run test

# Coverage
npm run test -- --coverage
```

### 3.3 Loop Exit Conditions

| Exit Type | Criteria |
|-----------|----------|
| ✅ Success | All tests pass, type check clean, lint clean, todos complete |
| ❌ Failure | Max iterations (7) reached, unrecoverable error, user intervention needed |

### 3.4 Iteration Tracking

Log to `.pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md`:

| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
| 1 | ❌ 3 fail | ✅ | ⚠️ 2 | 45% | Continue |
| 2 | ❌ 1 fail | ✅ | ✅ | 72% | Continue |
| 3 | ✅ | ✅ | ✅ | 82% | ✅ Done |

---

## Step 5: Todo Continuation Enforcement

> **Principle**: Never quit halfway.

### Rules

1. **One in_progress at a time**: Exactly one todo must be in_progress
2. **Immediate completion**: Mark complete RIGHT AFTER finishing
3. **No batching**: Don't batch multiple completions
4. **No abandonment**: If stuck, create sub-task, don't skip

### Enforcement Check

Before ending any turn, verify:
- [ ] Current in_progress todo is completed or explicitly blocked
- [ ] Blocked items have clear blocker description
- [ ] Next pending item is set to in_progress
- [ ] All completed items are marked

---

## Step 6: Verification

Run the most relevant checks available in the repo.

**Evidence rule**:
- Record which commands were run
- Record whether they succeeded

```bash
# Example verification
echo "Running type check..."
npx tsc --noEmit
TYPE_CHECK_RESULT=$?

echo "Running tests..."
npm run test
TEST_RESULT=$?

echo "Running lint..."
npm run lint
LINT_RESULT=$?

# Check results
if [ $TYPE_CHECK_RESULT -eq 0 ] && [ $TEST_RESULT -eq 0 ] && [ $LINT_RESULT -eq 0 ]; then
    echo "✅ All verifications passed"
else
    echo "❌ Some verifications failed"
    exit 1
fi
```

---

## Step 7: Update Plan Artifacts

Add a short section to the plan with:
- What changed
- How it was verified
- Any follow-ups
- Remaining open questions

```bash
# Append to plan.md
cat >> "$PLAN_PATH" << 'EOF'

## Execution Summary

### Changes Made
- [List changes]

### Verification
- Type check: ✅ Pass
- Tests: ✅ Pass (X% coverage)
- Lint: ✅ Pass

### Follow-ups
- [Any remaining items]
EOF
```

---

## Step 8: Auto-Chain to Documentation

> **Principle**: 3-sync pattern - implementation complete → docs auto-sync

### 7.1 Auto-Chain Trigger

After ALL of the following are true:
- [ ] All todos marked complete
- [ ] Ralph Loop exited successfully
- [ ] Coverage threshold met (80%+ overall, 90%+ core)
- [ ] Type check + lint clean

### 7.2 Auto-Invoke Documentation

Use Skill tool to invoke documentation command:

```
Skill: 91_document
Args: auto-sync from {RUN_ID}
```

### 7.3 Skip Auto-Chain

If `"$ARGUMENTS"` contains `--no-docs`, skip documentation.

---

## Success Criteria

| Criteria | Verification |
|----------|-------------|
| Plan executed | All phases in plan completed |
| Tests pass | All success criteria met |
| Type check clean | `npx tsc --noEmit` exits 0 |
| Lint clean | `npm run lint` exits 0 |
| Coverage met | 80%+ overall, 90%+ core |
| Ready for close | Documentation synced |

---

## Workflow

```
/00_plan → /01_confirm → /02_execute → /03_close
                            ↓
                      [Ralph Loop]
                            ↓
                      [TDD Cycle]
                            ↓
                      [91_document]
                            ↓
                         Ready
```

---

## Ralph Loop Settings

| Setting | Value | Description |
|---------|-------|-------------|
| Max iterations | 7 | 3 Red-Green-Refactor cycles + buffer |
| Overall coverage | 80% | Minimum project coverage |
| Core coverage | 90%+ | Core modules requirement |
| Exit on | All pass + todos done | Success condition |

---

## References

- **3-Tier Docs**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Review Extensions**: `.claude/guides/review-extensions.md`

---

## Next Command

After successful execution:

```
/03_close
```
