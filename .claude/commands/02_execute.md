---
description: Execute the current in-progress plan with Ralph Loop TDD pattern
argument-hint: "[--no-docs] - optional flag to skip auto-documentation"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /02_execute

_Execute the current in-progress plan using Ralph Loop TDD pattern - iterate until all tests pass._

---

## Core Philosophy

- **Single source of truth**: The plan file drives the work.
- **One active plan**: Keep exactly one plan active per git branch.
- **No drift**: If you change scope, update the plan and the todo list.
- **Evidence required**: Do not claim completion without verification output.

---

## Step 0: Select the Plan to Execute

### 0.1 Determine Plan Path

Priority order:
1. Explicit path from `"$ARGUMENTS"`
2. Read active pointer from `.pilot/plan/active/{branch}.txt`
3. Most recent file in `.pilot/plan/in_progress/`

```bash
# Find active pointer
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

if [ -f "$ACTIVE_PTR" ]; then
    RUN_DIR="$(cat "$ACTIVE_PTR")"
    PLAN_PATH="$RUN_DIR/plan.md"
fi

# Fallback to most recent
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1tr .pilot/plan/in_progress/*/*.md 2>/dev/null | head -1)"
    RUN_DIR="$(dirname "$PLAN_PATH")"
fi

if [ -z "$PLAN_PATH" ]; then
    echo "No in-progress plan found."
    echo "Run /00_plan and /01_confirm first."
    exit 1
fi
```

---

## Step 1: Convert Plan to Todo List

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

## Step 2: Execute with TDD (Red-Green-Refactor)

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

## Step 3: Ralph Loop (Autonomous Completion)

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

## Step 4: Todo Continuation Enforcement

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

## Step 5: Verification

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

## Step 6: Update Plan Artifacts

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

## Step 7: Auto-Chain to Documentation

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

- **Plan Template**: `.claude/templates/PRP.md.template`
- **TDD Guide**: `.claude/guides/ralph-loop-tdd.md`
- **Context Engineering**: `.claude/guides/context-engineering.md`

---

## Next Command

After successful execution:

```
/03_close
```
