# Ralph Loop Guide

## Purpose

Ralph Loop is an autonomous completion loop that iterates until all quality gates pass. This guide explains when to enter the loop, how to structure iterations, and when to exit.

## Core Principle

**Self-correcting loop until completion marker detected.**

## When to Enter Ralph Loop (CRITICAL)

### Entry Condition

> **⚠️ IMPORTANT - Ralph Loop starts IMMEDIATELY after the FIRST code change, NOT at the end of all implementation.**

**Correct Entry Points:**
- ✅ After implementing the first feature/function
- ✅ After fixing a bug
- ✅ After any Edit/Write tool call

**❌ WRONG - Do NOT wait until:**
- ❌ After completing all todos
- ❌ After implementing all features
- ❌ At the very end of execution

### Workflow Diagram

```
Step 3: TDD Cycle
  └─ Red-Green-Refactor for SC-1
      └─ After Edit/Write → IMMEDIATELY enter Ralph Loop
          └─ Run tests
          └─ If fail → Fix → Re-run tests
          └─ If pass → Continue to next SC
```

### Why Immediate Entry?

- **Fast feedback** on each change
- **Isolate failures** to specific code changes
- **Prevent accumulation** of bugs
- **True TDD compliance**

## Loop Structure

### Configuration

```bash
MAX_ITERATIONS=7
ITERATION=1
COVERAGE_THRESHOLD=80
CORE_COVERAGE_THRESHOLD=90
```

### Main Loop

```bash
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

### Iteration Tracking

Log to `.pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md`:

| Iteration | Tests | Types | Lint | Coverage | Status |
|-----------|-------|-------|------|----------|--------|
| 1 | ❌ 3 fail | ✅ | ⚠️ 2 | 45% | Continue |
| 2 | ❌ 1 fail | ✅ | ✅ | 72% | Continue |
| 3 | ✅ | ✅ | ✅ | 82% | ✅ Done |

## Completion Promise

### Output `<RALPH_COMPLETE>` marker **ONLY when** ALL conditions are met:

- [ ] All tests pass
- [ ] Coverage 80%+ (core modules 90%+)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

## Exit Conditions

| Type | Criteria |
|------|----------|
| ✅ Success | All tests pass, coverage 80%+ (core 90%+), type clean, lint clean, todos complete |
| ❌ Failure | Max 7 iterations reached, unrecoverable error, user intervention needed |
| ⚠️ Blocked | `<RALPH_BLOCKED>` output - requires manual review |

## Verification Commands

### Auto-Detect Test Command

> **⚠️ Do NOT assume `npm run test` - auto-detect project type**

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
```

### Run Verification

```bash
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

## Quick Reference Table

| Project Type | Test Command | Coverage Command | Type Check | Lint |
|--------------|--------------|------------------|------------|------|
| Python (pytest) | `pytest` | `pytest --cov` | `mypy .` | `ruff check .` |
| Node.js (TypeScript) | `npm test` | `npm run test:coverage` | `npx tsc --noEmit` | `npm run lint` |
| Node.js (JavaScript) | `npm test` | `npm run test:coverage` | - | `npm run lint` |
| Go | `go test ./...` | `go test -cover ./...` | - | `golangci-lint run` |
| Rust | `cargo test` | `cargo test` | - | `cargo clippy` |

## Coverage Enforcement

> **Critical**: Coverage below threshold MUST trigger continuation

- **Overall < 80%**: Continue improving tests
- **Core modules < 90%**: Focus on core test coverage
- **Parse coverage output** to extract percentage

### Coverage Parsing Example

```bash
# npm run test -- --coverage
COVERAGE_OUTPUT=$(npm run test -- --coverage --silent 2>&1)
OVERALL=$(echo "$COVERAGE_OUTPUT" | grep -oP 'All files[^%]*\K\d+' || echo "0")
if [ "$OVERALL" -lt $COVERAGE_THRESHOLD ]; then
    echo "⚠️ Coverage ${OVERALL}% below threshold ${COVERAGE_THRESHOLD}%"
fi
```

## Fix Priority Order

When failures occur, fix in this order:

1. **Errors** (breaking functionality)
2. **Coverage** (below threshold)
3. **Lint** (code style issues)
4. **Warnings** (nice to have)

## Ralph Loop Settings

| Setting | Value |
|---------|-------|
| Max iterations | 7 |
| Overall coverage | 80% |
| Core coverage | 90%+ |
| Exit on | All pass + todos done |

## See Also

- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection
