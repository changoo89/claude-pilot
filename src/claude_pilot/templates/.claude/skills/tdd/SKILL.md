---
name: tdd
description: Test-Driven Development (TDD) skill for Red-Green-Refactor cycle. Use when implementing features with tests first, minimal code to pass, then refactor. Isolates test execution from main orchestrator context.
---

# SKILL: Test-Driven Development (TDD)

> **Purpose**: Execute TDD Red-Green-Refactor cycle for feature implementation
> **Target**: Coder Agent implementing features with test-first methodology
> **Last Updated**: 2026-01-14
> **References**: @.claude/guides/tdd-methodology.md

---

## Quick Start (30 seconds)

### When to Use This Skill
Use this skill when you need to:
- Implement a new feature with test coverage
- Fix a bug with regression tests
- Refactor code with test safety net
- Add new functionality to existing codebase

### Quick Reference
```bash
# Red: Write failing test
pytest tests/test_feature.py -k "SC-1"  # Expected: FAIL

# Green: Write minimal code to pass
# [Implement feature]

# Green: Verify test passes
pytest tests/test_feature.py -k "SC-1"  # Expected: PASS

# Refactor: Improve quality
# [Refactor code]

# Refactor: Verify all tests still pass
pytest  # Expected: ALL PASS
```

---

## What This Skill Covers

### In Scope
- Red-Green-Refactor cycle execution
- Test-first development methodology
- Minimal implementation for Green phase
- Refactoring with test safety
- TDD micro-cycle (Ralph integration)

### Out of Scope
- Test framework selection → See @.claude/guides/test-environment.md
- Coverage thresholds → See @.claude/guides/ralph-loop.md
- Code quality standards → See @.claude/guides/vibe-coding.md
- Autonomous completion loop → See @.claude/guides/ralph-loop.md

---

## Core Concepts

### The TDD Cycle: Red-Green-Refactor

**Phase 1: Red** - Write Failing Test
```python
# tests/test_calculator.py
def test_add_two_numbers():
    """SC-1: Calculator adds two positive numbers"""
    result = calculator.add(2, 3)
    assert result == 5
```
Run test → Confirm it FAILS (❌)

**Phase 2: Green** - Minimal Implementation
```python
# src/calculator.py
def add(a, b):
    return a + b  # Just enough to pass
```
Run test → Confirm it PASSES (✅)

**Phase 3: Refactor** - Improve Quality
```python
# src/calculator.py
def add(a: int, b: int) -> int:
    """Add two integers with type safety."""
    return a + b
```
Run ALL tests → Confirm ALL PASS (✅)

### Why TDD Matters
- **Tests drive design**: API designed from usage perspective
- **Regression safety**: Refactor without fear
- **Living documentation**: Tests show intended behavior
- **Fast feedback**: Catch issues immediately

---

## Typical Workflows

### Workflow 1: Implement New Feature

**Prerequisites**:
- Plan with Success Criteria (SC-1, SC-2, ...)
- Test environment configured (pytest, npm test, etc.)

**Steps**:
1. **Red Phase**: Write test for SC-1
   ```bash
   # Create test file with failing assertion
   pytest tests/test_feature.py -k "SC-1"  # Must FAIL
   ```

2. **Green Phase**: Write minimal code to pass
   ```bash
   # Implement just enough to make test pass
   pytest tests/test_feature.py -k "SC-1"  # Must PASS
   ```

3. **Refactor Phase**: Improve quality
   ```bash
   # Apply DRY, SOLID, Early Return
   pytest tests/test_feature.py  # All must PASS
   ```

4. **Repeat**: For each Success Criteria
   ```bash
   # SC-2, SC-3, ... until complete
   ```

**Verification**:
```bash
# All tests pass
pytest

# Coverage meets threshold
pytest --cov

# Type check clean
npx tsc --noEmit  # or mypy .
```

### Workflow 2: Fix Bug with TDD

**Prerequisites**:
- Bug report with reproduction steps
- Existing test suite

**Steps**:
1. **Red Phase**: Write failing test that reproduces bug
   ```bash
   # Test should fail with current code
   pytest tests/test_bug.py -k "reproduces_issue_123"
   ```

2. **Green Phase**: Fix bug with minimal change
   ```bash
   # Smallest change that makes test pass
   pytest tests/test_bug.py -k "reproduces_issue_123"
   ```

3. **Refactor Phase**: Clean up if needed
   ```bash
   # Verify no regressions
   pytest
   ```

**Verification**:
```bash
# Bug test passes
pytest tests/test_bug.py

# No regressions
pytest
```

---

## Common Patterns

### Pattern 1: One Test Per Success Criterion
**Use case**: Implementing from plan with SC-N criteria

**Implementation**:
```python
# SC-1: User can login with valid credentials
def test_login_valid_credentials():
    response = auth.login("user@example.com", "password")
    assert response.success == True

# SC-2: User cannot login with invalid password
def test_login_invalid_password():
    response = auth.login("user@example.com", "wrong")
    assert response.success == False
```

**Caveats**:
- Don't test multiple things in one test
- Name tests to match success criteria

### Pattern 2: Test Isolation
**Use case**: Prevent tests from affecting each other

**Implementation**:
```python
import pytest

@pytest.fixture
def clean_database():
    """Setup: Create clean database"""
    db = Database(":memory:")
    yield db
    # Teardown: Clean up
    db.close()

def test_user_creation(clean_database):
    # Each test gets isolated database
    user = clean_database.create_user("test@example.com")
    assert user.email == "test@example.com"
```

**Caveats**:
- Always use fixtures for setup/teardown
- Never share state between tests

### Pattern 3: Mock External Dependencies
**Use case**: Test in isolation from APIs, databases

**Implementation**:
```python
from unittest.mock import patch

@patch('requests.post')
def test_api_call_succeeds(mock_post):
    # Mock the external API
    mock_post.return_value.status_code = 200

    response = api_client.create_user("test@example.com")

    assert response.status_code == 200
    mock_post.assert_called_once()
```

**Caveats**:
- Mock at boundaries (APIs, databases)
- Don't mock code you control

---

## TDD-Ralph Integration

### Ralph Micro-Cycle (CRITICAL)

**After EVERY Edit/Write tool call, you MUST run tests immediately.**

Do NOT batch multiple code changes before testing.

#### Micro-Cycle Pattern
```
1. Edit/Write code
2. Mark test todo as in_progress
3. Run tests (use detected test command)
4. Analyze results
5. Fix failures or mark test todo complete
6. Repeat from step 1 for next change
```

#### Example Workflow
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

```bash
# Auto-detect based on project type
if [ -f "pyproject.toml" ]; then
    TEST_CMD="pytest"
elif [ -f "package.json" ]; then
    TEST_CMD="npm test"
elif [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
elif [ -f "Cargo.toml" ]; then
    TEST_CMD="cargo test"
fi

echo "🧪 Detected test command: $TEST_CMD"
$TEST_CMD
```

---

## Troubleshooting

### Issue: Test passes in Red phase
**Symptoms**: Test passes when writing it (should fail)

**Diagnosis**:
```bash
# Check if test actually validates new feature
grep -A 5 "def test_" tests/test_feature.py
```

**Solution**:
- Test is testing existing functionality
- Write test for NEW behavior that doesn't exist yet
- Verify test fails before implementing

### Issue: Test flaky (sometimes fails, sometimes passes)
**Symptoms**: Non-deterministic test results

**Diagnosis**:
```bash
# Run test multiple times
pytest tests/test_flaky.py --count=10
```

**Solution**:
- Check for shared state between tests
- Add proper fixtures for isolation
- Mock time-dependent operations
- Add proper waits for async operations

### Issue: Too many test failures
**Symptoms**: Dozens of failing tests, overwhelmed

**Diagnosis**:
```bash
# Run one test at a time
pytest tests/test_feature.py -k "specific_test_name"
```

**Solution**:
- Fix one test at a time (Red → Green → Refactor)
- Use `-k` flag to run specific tests
- Don't batch-fix multiple failures

---

## Best Practices

### Do's ✅
- Write test BEFORE implementation code (Red phase)
- Run tests after EVERY code change (micro-cycle)
- One assertion per test concept
- Use descriptive test names matching success criteria
- Keep tests simple and readable
- Mock external dependencies (APIs, databases)

### Don'ts ❌
- Don't write implementation before tests
- Don't batch multiple code changes before testing
- Don't test multiple things in one test
- Don't share state between tests
- Don't write tests that always pass (no value)
- Don't ignore failing tests

---

## Integration with Other Skills

### Related Skills
- **ralph-loop**: Autonomous completion loop after TDD implementation
- **vibe-coding**: Code quality standards during refactor phase
- **git-master**: Commit implementation after tests pass

### Call Patterns
```
tdd (Red-Green-Refactor)
     ↓
ralph-loop (Verify all pass, iterate)
     ↓
vibe-coding (Refactor with standards)
     ↓
git-master (Commit working code)
```

---

## Vibe Coding Standards During TDD

**Enforce during ALL code generation**:
- Functions ≤50 lines
- Files ≤200 lines
- Nesting ≤3 levels
- SRP (Single Responsibility Principle)
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- Early Return pattern

**Generate in small increments, test immediately, never trust blindly.**

---

## Further Reading

### Internal Documentation
- @.claude/guides/tdd-methodology.md - Full TDD methodology guide
- @.claude/guides/ralph-loop.md - Autonomous completion loop
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection

### External Resources
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)

---

## FAQ

### Q: Do I always need to write tests first?
**A**: In strict TDD, yes. The Red phase ensures you're testing NEW behavior, not existing code. However, when adding tests to legacy code, you may write tests for existing functionality first (characterization tests).

### Q: How small should a test be?
**A**: One test should validate ONE success criterion. If your test has multiple assertions testing different things, split it into multiple tests.

### Q: What if the test is hard to write?
**A**: Difficulty writing a test often indicates design issues. Consider:
- Is the code doing too many things? (SRP violation)
- Are dependencies tightly coupled? (Needs abstraction)
- Should you use a mock/fake?

### Q: Do I need 100% coverage?
**A**: No. Target 80% overall, 90% for core modules. Focus on testing behavior that matters, not hitting an arbitrary percentage.
