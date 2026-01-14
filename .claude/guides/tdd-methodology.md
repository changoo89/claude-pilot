# TDD Methodology Guide

## Purpose

Test-Driven Development (TDD) is a software development approach where tests drive the implementation. This guide explains the Red-Green-Refactor cycle and how to apply it during feature development.

## Core Principle

**Tests drive development. AI works within test guardrails.**

## The TDD Cycle: Red-Green-Refactor

### 1. Discovery Phase
Before writing tests, understand the codebase:
- Search codebase: `Glob **/*{keyword}*`, `Grep {pattern}`
- Confirm integration points
- Update plan if reality differs from assumptions

### 2. Red Phase: Write Failing Tests

**For each Success Criteria (SC-N):**
1. Generate test stub
2. Write assertions
3. Run tests → confirm RED (failing)

```bash
# Example: Run specific test
npm run test -- --grep "SC-1"  # Expected: FAIL
```

**Key Points:**
- Write the test BEFORE writing implementation code
- Test should fail for the right reason (missing functionality)
- One test per success criterion

### 3. Green Phase: Minimal Implementation

Write ONLY enough code to pass the test:
- No optimization
- No extra features
- Just enough to make the test pass

```bash
# Example: Run same test
npm run test -- --grep "SC-1"  # Expected: PASS
```

**Key Points:**
- Focus on making the test pass
- Don't worry about code quality yet (that's next phase)
- Keep it simple

### 4. Refactor Phase: Clean Up

Improve quality without changing behavior:
- Apply DRY (Don't Repeat Yourself)
- Apply SOLID principles
- Improve readability
- Run ALL tests → confirm GREEN

```bash
# Example: Run all tests
npm run test  # Expected: ALL PASS
```

**Key Points:**
- Behavior must remain unchanged
- All tests must still pass
- Focus on code quality

## Repeat Cycle

Iterate through all success criteria:
- SC-1: Red → Green → Refactor
- SC-2: Red → Green → Refactor
- Continue until all SC met

## Vibe Coding Standards During TDD

**Enforce during ALL code generation:**
- Functions ≤50 lines
- Files ≤200 lines
- Nesting ≤3 levels
- SRP (Single Responsibility Principle)
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- Early Return pattern

**Generate in small increments, test immediately, never trust blindly.**

## TDD-Ralph Integration

### Ralph Micro-Cycle (CRITICAL)

**After EVERY Edit/Write tool call, you MUST run tests immediately.**

Do NOT wait until the end of implementation. Do NOT batch multiple code changes before testing.

#### Micro-Cycle Pattern

```
1. Edit/Write code
2. Mark test todo as in_progress
3. Run tests (use detected test command)
4. Analyze results
5. Fix failures or mark test todo complete
6. Repeat from step 1 for next change
```

#### Correct Workflow Example

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

### Test Command Auto-Detection

Use the test command detected during planning (from `Test Environment` section):
- Python: `pytest` or `python -m pytest`
- Node.js: `npm test` or `npm run test`
- Go: `go test ./...`
- Rust: `cargo test`

If not detected in plan, auto-detect:
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

### Why This Matters

- **Fast feedback**: Catch issues immediately after each change
- **Easy debugging**: Only one code change between test runs
- **TDD compliance**: Red-Green-Refactor cycle per change
- **Ralph efficiency**: Failures are isolated and quick to fix

## Common Mistakes to Avoid

| Mistake | Solution |
|---------|----------|
| Writing tests after code | Always write tests first (Red phase) |
| Batch coding multiple features | One feature, test it, then next |
| Skipping refactor phase | Always clean up after green |
| Over-engineering in green phase | Keep implementation minimal |
| Ignoring failing tests | Never proceed without all tests passing |

## Quick Reference

| Phase | Goal | Test Status |
|-------|------|-------------|
| Red | Write failing test | ❌ FAIL |
| Green | Make test pass | ✅ PASS |
| Refactor | Improve quality | ✅ PASS |

## See Also

- @.claude/guides/ralph-loop.md - Autonomous completion loop
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection
