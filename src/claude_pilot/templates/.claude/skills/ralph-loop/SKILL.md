---
name: ralph-loop
description: Autonomous completion loop that iterates until all quality gates pass. Tests, type-check, lint, coverage - iterate until complete or max 7 iterations reached. Use after any code change.
---

# SKILL: Ralph Loop (Autonomous Completion)

> **Purpose**: Iterate autonomously until all quality gates pass (tests, type-check, lint, coverage)
> **Target**: Coder Agent after implementing features
> **Last Updated**: 2026-01-14
> **References**: @.claude/guides/ralph-loop.md

---

## Quick Start (30 seconds)

### When to Use This Skill
Use this skill when you need to:
- Iterate until all tests pass
- Verify type checking and linting
- Achieve coverage thresholds (80%+ overall, 90%+ core)
- Ensure code quality before committing

### Quick Reference
```bash
# Detection: Auto-detect test command
if [ -f "pyproject.toml" ]; then TEST_CMD="pytest"
elif [ -f "package.json" ]; then TEST_CMD="npm test"
elif [ -f "go.mod" ]; then TEST_CMD="go test ./..."
fi

# Run verification loop
MAX_ITERATIONS=7
ITERATION=1
while [ $ITERATION -le $MAX_ITERATIONS ]; do
    $TEST_CMD && npx tsc --noEmit && npm run lint
    if [ $? -eq 0 ] && [ $COVERAGE -ge 80 ]; then
        echo "<RALPH_COMPLETE>"; break
    fi
    ITERATION=$((ITERATION + 1))
done
```

---

## What This Skill Covers

### In Scope
- Autonomous iteration until quality gates pass
- Test command auto-detection (pytest, npm test, go test, cargo test)
- Verification: tests, type-check, lint, coverage
- Fix priority: errors > coverage > lint
- Completion marker output (<RALPH_COMPLETE>)

### Out of Scope
- Test writing methodology → See @.claude/skills/tdd/SKILL.md
- Code quality standards → See @.claude/skills/vibe-coding/SKILL.md
- Coverage thresholds → Specified in plan
- Test environment setup → See @.claude/guides/test-environment.md

---

## Core Concepts

### Ralph Loop Entry Condition (CRITICAL)

**Ralph Loop starts IMMEDIATELY after the FIRST code change.**

**Correct Entry Points**:
- ✅ After implementing first feature/function
- ✅ After fixing a bug
- ✅ After any Edit/Write tool call

**❌ WRONG**: After completing all todos, at very end

### Why Immediate Entry?
- **Fast feedback** on each change
- **Isolate failures** to specific code changes
- **Prevent accumulation** of bugs
- **True TDD compliance**

### Completion Promise

Output `<RALPH_COMPLETE>` marker **ONLY when** ALL conditions are met:
- [ ] All tests pass
- [ ] Coverage 80%+ (core modules 90%+)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

### Loop Structure

```
MAX_ITERATIONS=7
ITERATION=1

WHILE ITERATION <= MAX_ITERATIONS:
    1. Run: tests, type-check, lint, coverage
    2. Log iteration to ralph-loop-log.md
    3. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    4. ELSE:
         Fix (priority: errors > coverage > lint)
         ITERATION++
    5. IF ITERATION > MAX_ITERATIONS:
         Output: <RALPH_BLOCKED> with summary
```

---

## Typical Workflows

### Workflow 1: After Feature Implementation

**Prerequisites**:
- Feature code written
- Tests written (via TDD skill)
- Test environment configured

**Steps**:
1. **Iteration 1**: Run verification
   ```bash
   # Auto-detect and run tests
   DETECT_TEST_CMD  # Returns: pytest
   pytest           # Result: 3 failures

   # Type check
   npx tsc --noEmit  # Result: 2 type errors

   # Lint
   npm run lint      # Result: 4 warnings

   # Coverage
   pytest --cov      # Result: 65%
   ```

2. **Iteration 2**: Fix errors (highest priority)
   ```bash
   # Fix test failures first
   # [Edit code to fix failing tests]

   # Re-run
   pytest            # Result: 1 failure
   ```

3. **Iteration 3**: Continue fixing
   ```bash
   # Fix remaining test failure
   # [Edit code]

   pytest            # Result: All pass ✅
   npx tsc --noEmit  # Result: Clean ✅
   npm run lint      # Result: Clean ✅
   pytest --cov      # Result: 78% (still below 80%)
   ```

4. **Iteration 4**: Improve coverage
   ```bash
   # Add edge case tests
   # [Add tests for uncovered paths]

   pytest --cov      # Result: 82% ✅
   ```

5. **Output completion**
   ```bash
   echo "<RALPH_COMPLETE>"
   ```

**Verification**:
```bash
# All quality gates pass
pytest && npx tsc --noEmit && npm run lint

# Coverage meets threshold
pytest --cov  # 80%+ overall, 90%+ core
```

### Workflow 2: Iteration Tracking

**Prerequisites**:
- In Ralph Loop
- Plan with RUN_ID

**Steps**:
1. **Create log file**
   ```bash
   LOG_PATH=".pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md"
   ```

2. **Log each iteration**
   ```markdown
   | Iteration | Tests | Types | Lint | Coverage | Status |
   |-----------|-------|-------|------|----------|--------|
   | 1 | ❌ 3 fail | ✅ | ⚠️ 2 | 45% | Continue |
   | 2 | ❌ 1 fail | ✅ | ✅ | 72% | Continue |
   | 3 | ✅ | ✅ | ✅ | 82% | ✅ Done |
   ```

3. **Mark completion**
   ```markdown
   ## Ralph Loop Summary
   - Total Iterations: 3
   - Final Status: <RALPH_COMPLETE>
   - Coverage: 82% (80%+ target met)
   - All Tests: ✅ Pass
   - Type Check: ✅ Clean
   - Lint: ✅ Clean
   ```

**Verification**:
```bash
# Log file exists
cat .pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md

# Completion marker found
grep "<RALPH_COMPLETE>" .pilot/plan/in_progress/{RUN_ID}/ralph-loop-log.md
```

---

## Common Patterns

### Pattern 1: Test Command Auto-Detection
**Use case**: Detect correct test command for project type

**Implementation**:
```bash
DETECT_TEST_CMD() {
    if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        echo "pytest"
    elif [ -f "setup.py" ]; then
        echo "python -m pytest"
    elif [ -f "package.json" ]; then
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

**Caveats**:
- Check for project type files in correct order
- Fallback to npm test if unknown
- Verify command exists before running

### Pattern 2: Fix Priority Order
**Use case**: Multiple failures, need to fix in right order

**Implementation**:
```bash
# Run all verification
$TEST_CMD
TEST_RESULT=$?

if [ -f "package.json" ] && grep -q "typescript" package.json; then
    npx tsc --noEmit
    TYPE_RESULT=$?
else
    TYPE_RESULT=0
fi

if [ -f "package.json" ] && grep -q '"lint"' package.json; then
    npm run lint
    LINT_RESULT=$?
else
    LINT_RESULT=0
fi

# Fix priority: errors > coverage > lint
if [ $TEST_RESULT -ne 0 ]; then
    echo "❌ Fixing test failures first..."
    # [Fix test failures]
elif [ $TYPE_RESULT -ne 0 ]; then
    echo "❌ Fixing type errors..."
    # [Fix type errors]
elif [ $COVERAGE -lt 80 ]; then
    echo "⚠️ Improving coverage..."
    # [Add tests]
elif [ $LINT_RESULT -ne 0 ]; then
    echo "⚠️ Fixing lint issues..."
    # [Fix lint]
fi
```

**Caveats**:
- Always fix errors before warnings
- Coverage below threshold MUST trigger continuation
- Don't ignore failing tests

### Pattern 3: Coverage Parsing
**Use case**: Extract coverage percentage from output

**Implementation**:
```bash
# Python (pytest)
COVERAGE_OUTPUT=$(pytest --cov --silent 2>&1)
OVERALL=$(echo "$COVERAGE_OUTPUT" | grep -oP 'TOTAL[^%]*\K\d+' || echo "0")

# Node.js (Jest)
COVERAGE_OUTPUT=$(npm run test -- --coverage --silent 2>&1)
OVERALL=$(echo "$COVERAGE_OUTPUT" | grep -oP 'All files[^%]*\K\d+' || echo "0")

# Go
COVERAGE_OUTPUT=$(go test -cover ./... 2>&1)
OVERALL=$(echo "$COVERAGE_OUTPUT" | grep -oP 'coverage: \K\d+' || echo "0")

if [ "$OVERALL" -lt $COVERAGE_THRESHOLD ]; then
    echo "⚠️ Coverage ${OVERALL}% below threshold ${COVERAGE_THRESHOLD}%"
fi
```

**Caveats**:
- Different tools have different output formats
- Use regex to extract percentage
- Default to 0 if extraction fails

---

## Exit Conditions

| Type | Criteria | Action |
|------|----------|--------|
| ✅ Success | All tests pass, coverage 80%+ (core 90%+), type clean, lint clean, todos complete | Output `<RALPH_COMPLETE>` |
| ❌ Failure | Max 7 iterations reached, unrecoverable error, user intervention needed | Output `<RALPH_BLOCKED>` |
| ⚠️ Blocked | Requires manual review | Output `<RALPH_BLOCKED>` with summary |

---

## Troubleshooting

### Issue: Infinite loop (never reaches completion)
**Symptoms**: Loop runs forever, never exits

**Diagnosis**:
```bash
# Check iteration counter
echo $ITERATION

# Check if completion marker is being output
grep "<RALPH_COMPLETE>" ralph-loop-log.md
```

**Solution**:
- Ensure max iterations is enforced (7)
- Check that all gates can actually pass
- Verify coverage threshold is achievable
- Check for transient test failures

### Issue: Coverage never reaches threshold
**Symptoms**: Coverage stuck at 75%, target is 80%

**Diagnosis**:
```bash
# See what's not covered
pytest --cov --cov-report=term-missing

# Identify uncovered lines
# Lines marked with ">>>>>" are not executed
```

**Solution**:
- Add tests for uncovered paths
- Check for dead code (remove if unreachable)
- Verify threshold is realistic
- Consider excluding generated files

### Issue: Tests pass locally, fail in Ralph Loop
**Symptoms**: pytest passes manually, fails in loop

**Diagnosis**:
```bash
# Check test command being used
echo $TEST_CMD

# Run with same options
$TEST_CMD --verbose
```

**Solution**:
- Test command may differ (pytest vs python -m pytest)
- Working directory may differ
- Environment variables may differ
- Run with same command as loop

---

## Best Practices

### Do's ✅
- Start Ralph Loop immediately after first code change
- Run tests after EVERY Edit/Write call (micro-cycle)
- Fix in priority order: errors > coverage > lint
- Log iterations to ralph-loop-log.md
- Auto-detect test command (don't hardcode)
- Enforce max iterations (7)

### Don'ts ❌
- Don't wait until end to run Ralph Loop
- Don't batch multiple code changes before testing
- Don't ignore coverage below threshold
- Don't skip type check or lint
- Don't continue past max iterations
- Don't output <RALPH_COMPLETE> unless all gates pass

---

## Integration with Other Skills

### Related Skills
- **tdd**: Write tests first, then Ralph Loop verifies
- **vibe-coding**: Refactor during loop iterations
- **git-master**: Commit after <RALPH_COMPLETE>

### Call Patterns
```
tdd (Red-Green-Refactor)
     ↓
[Code change - Edit/Write]
     ↓
ralph-loop (Iterate until all pass)
     ↓
vibe-coding (Refactor with standards)
     ↓
ralph-loop (Verify quality again)
     ↓
git-master (Commit working code)
```

---

## Ralph Loop Settings

| Setting | Value | Description |
|---------|-------|-------------|
| Max iterations | 7 | Prevent infinite loops |
| Overall coverage | 80% | Minimum coverage threshold |
| Core coverage | 90%+ | Stricter threshold for core modules |
| Exit on | All pass + todos done | Completion condition |

---

## Quick Reference Table

| Project Type | Test Command | Coverage Command | Type Check | Lint |
|--------------|--------------|------------------|------------|------|
| Python (pytest) | `pytest` | `pytest --cov` | `mypy .` | `ruff check .` |
| Node.js (TS) | `npm test` | `npm run test:coverage` | `npx tsc --noEmit` | `npm run lint` |
| Node.js (JS) | `npm test` | `npm run test:coverage` | - | `npm run lint` |
| Go | `go test ./...` | `go test -cover ./...` | - | `golangci-lint run` |
| Rust | `cargo test` | `cargo test` | - | `cargo clippy` |

---

## Further Reading

### Internal Documentation
- @.claude/guides/ralph-loop.md - Full Ralph Loop guide
- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection

### External Resources
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

## FAQ

### Q: Why start Ralph Loop after first code change?
**A**: Fast feedback. Waiting until end means:
- Accumulated bugs are harder to debug
- Don't know which change broke tests
- Violates TDD micro-cycle principle

### Q: What if I can't reach coverage threshold?
**A**: Three options:
1. Add more tests for uncovered paths
2. Refactor code to make it more testable
3. Document why threshold can't be met (e.g., generated files)

### Q: Can I adjust max iterations?
**A**: No. Max 7 is enforced to prevent:
- Infinite loops on unrecoverable errors
- Token waste on hopeless situations
- User frustration from endless iteration

### Q: What's the difference between TDD and Ralph Loop?
**A**:
- **TDD**: Methodology for writing code (Red → Green → Refactor)
- **Ralph Loop**: Autonomous verification loop after code is written
- **Together**: TDD writes code, Ralph Loop verifies it's complete
