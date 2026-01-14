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
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "No plan found. Run /00_plan, then /01_confirm or /02_execute (auto-detects pending plans)" >&2; exit 1; }
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

### MANDATORY: Test Execution Todos

> **⚠️ CRITICAL - EVERY implementation task MUST be followed by a test execution todo**

**Pattern**:
```markdown
- [ ] Implement [feature X]
- [ ] Run tests for [feature X]
```

**Correct Example**:
```markdown
- [ ] Add authentication middleware
- [ ] Run tests for authentication middleware
- [ ] Add login endpoint
- [ ] Run tests for login endpoint
- [ ] Fix failing tests
- [ ] Verify all tests pass
```

**❌ ANTI-PATTERN - FORBIDDEN**:
```markdown
- [ ] Add authentication
- [ ] Add login
- [ ] Fix tests
- [ ] Verify complete  ← Tests bundled at end - WRONG!
```

**🛑 RULE**: After EVERY "Implement", "Add", "Create", "Modify", "Fix" todo, add a corresponding "Run tests for [X]" todo immediately after.

**Why?** This ensures Ralph Loop triggers test execution after each code change, not just at the end.

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

### TDD-Ralph Integration (CRITICAL)

> **⚠️ MANDATORY - Ralph Micro-Cycle**

**After EVERY Edit/Write tool call, you MUST run tests immediately.**

Do NOT wait until the end of implementation. Do NOT batch multiple code changes before testing.

#### Ralph Micro-Cycle Pattern

```
1. Edit/Write code
2. Mark test todo as in_progress
3. Run tests (use detected test command from plan)
4. Analyze results
5. Fix failures or mark test todo complete
6. Repeat from step 1 for next change
```

#### Correct Workflow

```markdown
Current in_progress: Implement login function

[Edit src/auth.ts - add login function]

→ Next: Mark "Run tests for login" as in_progress
→ Execute: pytest (or npm test, etc.)
→ Result: ❌ Fails (missing password validation)
→ Fix: Add password validation
→ Re-run: ✅ Passes
→ Mark: "Run tests for login" ✅ complete
→ Next: Move to next todo
```

#### ❌ ANTI-PATTERN - FORBIDDEN

```markdown
[Edit src/auth.ts - add login]
[Edit src/auth.ts - add register]
[Edit src/auth.ts - add logout]
[Edit src/middleware.ts - add auth guard]
→ Only now run tests ← WRONG! Too many changes, hard to debug
```

#### Test Command Auto-Detection

Use the test command detected during planning (from `Test Environment` section):
- Python: `pytest` or `python -m pytest`
- Node.js: `npm test` or `npm run test`
- Go: `go test ./...`
- Rust: `cargo test`

If not detected in plan, auto-detect now:
```bash
# Priority: pyproject.toml → package.json → go.mod → Cargo.toml
if [ -f "pyproject.toml" ]; then TEST_CMD="pytest"
elif [ -f "package.json" ]; then TEST_CMD="npm test"
elif [ -f "go.mod" ]; then TEST_CMD="go test ./..."
elif [ -f "Cargo.toml" ]; then TEST_CMD="cargo test"
else TEST_CMD="npm test"  # Fallback
fi

echo "Detected test command: $TEST_CMD"
$TEST_CMD
```

#### Why This Matters

- **Fast feedback**: Catch issues immediately after each change
- **Easy debugging**: Only one code change between test runs
- **TDD compliance**: Red-Green-Refactor cycle per change
- **Ralph efficiency**: Failures are isolated and quick to fix

---

## Step 4: Ralph Loop (Autonomous Completion)

> **Principle**: Self-correcting loop until completion marker detected

### Ralph Loop Entry Condition (CRITICAL)

> **⚠️ IMPORTANT - When does Ralph Loop start?**

**Ralph Loop starts IMMEDIATELY after the FIRST code change, NOT at the end of all implementation.**

**Correct Entry Points:**
- ✅ After implementing the first feature/function
- ✅ After fixing a bug
- ✅ After any Edit/Write tool call

**❌ WRONG - Do NOT wait until:**
- ❌ After completing all todos
- ❌ After implementing all features
- ❌ At the very end of execution

**Workflow:**
```
Step 3: TDD Cycle
  └─ Red-Green-Refactor for SC-1
      └─ After Edit/Write → IMMEDIATELY enter Ralph Loop
          └─ Run tests
          └─ If fail → Fix → Re-run tests
          └─ If pass → Continue to next SC
```

**Why immediate entry?**
- Fast feedback on each change
- Isolate failures to specific code changes
- Prevent accumulation of bugs
- True TDD compliance

### 4.1 Completion Promise
> Output `<RALPH_COMPLETE>` marker **ONLY when** ALL conditions are met:
> - [ ] All tests pass
> - [ ] Coverage 80%+ (core modules 90%+)
> - [ ] Type check clean
> - [ ] Lint clean
> - [ ] All todos completed

### 4.2 Loop Structure
```
MAX_ITERATIONS=7
ITERATION=1
COVERAGE_THRESHOLD=80
CORE_COVERAGE_THRESHOLD=90

WHILE ITERATION <= MAX_ITERATIONS AND NOT <RALPH_COMPLETE>:
    1. Run: tests, type-check, lint, coverage
    2. Log iteration to ralph-loop-log.md
    3. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    4. ELSE:
         Analyze failures
         Fix (priority: errors > coverage > lint)
         ITERATION++
    5. IF ITERATION > MAX_ITERATIONS:
         Output: <RALPH_BLOCKED> with summary
```

### 4.3 Verification Commands

> **⚠️ AUTO-DETECT TEST COMMAND - Do NOT assume `npm run test`**

**First, detect project type and test command:**
```bash
# Auto-detect test command based on project type
DETECT_TEST_CMD() {
    if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        echo "pytest"
    elif [ -f "setup.py" ]; then
        echo "python -m pytest"
    elif [ -f "package.json" ]; then
        # Check if test script exists
        if grep -q '"test"' package.json; then
            echo "npm run test"
        else
            echo "npm test"
        fi
    elif [ -f "go.mod" ]; then
        echo "go test ./..."
    elif [ -f "Cargo.toml" ]; then
        echo "cargo test"
    elif [ -f "pom.xml" ]; then
        echo "mvn test"
    elif [ -f "build.gradle" ]; then
        echo "gradle test"
    else
        echo "npm test"  # Fallback
    fi
}

TEST_CMD=$(DETECT_TEST_CMD)
echo "🧪 Detected test command: $TEST_CMD"

# Type check (language-specific)
if [ -f "package.json" ] && grep -q "typescript" package.json; then
    echo "Running type check..."; npx tsc --noEmit; TYPE_CHECK_RESULT=$?
elif [ -f "pyproject.toml" ] && grep -q "mypy" pyproject.toml; then
    echo "Running type check..."; mypy .; TYPE_CHECK_RESULT=$?
else
    echo "No type check configured"; TYPE_CHECK_RESULT=0
fi

# Lint (language-specific)
if [ -f "package.json" ] && grep -q '"lint"' package.json; then
    echo "Running lint..."; npm run lint; LINT_RESULT=$?
elif [ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml; then
    echo "Running lint..."; ruff check .; LINT_RESULT=$?
else
    echo "No lint configured"; LINT_RESULT=0
fi

# Tests
echo "Running tests..."; $TEST_CMD; TEST_RESULT=$?

# Coverage (project-specific)
if [ -f "package.json" ] && grep -q '"test:coverage"' package.json; then
    echo "Running coverage..."; npm run test:coverage; COVERAGE_RESULT=$?
elif [ -f "pyproject.toml" ]; then
    echo "Running coverage..."; pytest --cov; COVERAGE_RESULT=$?
elif [ -f "go.mod" ]; then
    echo "Running coverage..."; go test -cover ./...; COVERAGE_RESULT=$?
else
    echo "No coverage command configured"; COVERAGE_RESULT=0
fi

# Overall check
[ $TYPE_CHECK_RESULT -eq 0 ] && [ $TEST_RESULT -eq 0 ] && [ $LINT_RESULT -eq 0 ] && [ $COVERAGE_RESULT -eq 0 ] && echo "✅ All passed" || { echo "❌ Some failed"; return 1; }
```

**Quick Reference Table:**
| Project Type | Test Command | Coverage Command | Type Check | Lint |
|--------------|--------------|------------------|------------|------|
| Python (pytest) | `pytest` | `pytest --cov` | `mypy .` | `ruff check .` |
| Node.js (TypeScript) | `npm test` | `npm run test:coverage` | `npx tsc --noEmit` | `npm run lint` |
| Node.js (JavaScript) | `npm test` | `npm run test:coverage` | - | `npm run lint` |
| Go | `go test ./...` | `go test -cover ./...` | - | `golangci-lint run` |
| Rust | `cargo test` | `cargo test` | - | `cargo clippy` |

### 4.4 Exit Conditions
| Type | Criteria |
|------|----------|
| ✅ Success | All tests pass, coverage 80%+ (core 90%+), type clean, lint clean, todos complete |
| ❌ Failure | Max 7 iterations reached, unrecoverable error, user intervention needed |
| ⚠️ Blocked | `<RALPH_BLOCKED>` output - requires manual review |

### 4.5 Iteration Tracking
Log to `.pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md`:

| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
| 1 | ❌ 3 fail | ✅ | ⚠️ 2 | 45% | Continue |
| 2 | ❌ 1 fail | ✅ | ✅ | 72% | Continue |
| 3 | ✅ | ✅ | ✅ | 82% | ✅ Done |

### 4.6 Coverage Enforcement
> **Critical**: Coverage below threshold MUST trigger continuation
> - Overall < 80%: Continue improving tests
> - Core modules < 90%: Focus on core test coverage
> - Parse coverage output to extract percentage

**Coverage Parsing Example**:
```bash
# npm run test -- --coverage
COVERAGE_OUTPUT=$(npm run test -- --coverage --silent 2>&1)
OVERALL=$(echo "$COVERAGE_OUTPUT" | grep -oP 'All files[^%]*\K\d+' || echo "0")
if [ "$OVERALL" -lt $COVERAGE_THRESHOLD ]; then
    echo "⚠️ Coverage ${OVERALL}% below threshold ${COVERAGE_THRESHOLD}%"
fi
```

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
- **Branch**: !`git rev-parse --abbrev-ref HEAD`

---

## Next Command
After successful execution: `/03_close`
