# Coder Agent - Examples and Integration Guide

> **Companion to**: [coder.md](./coder.md)
> **Purpose**: Extended TDD examples, Ralph Loop integration, and skill references

## TDD Cycle Examples

### Example 1: Simple Feature Implementation

**Red Phase**:
```python
# tests/test_calculator.py
def test_add_two_numbers():
    result = calculator.add(2, 3)
    assert result == 5
```

```bash
pytest tests/test_calculator.py -k "test_add_two_numbers"
# Result: FAIL - calculator module doesn't exist
```

**Green Phase**:
```python
# src/calculator.py
def add(a, b):
    return a + b
```

```bash
pytest tests/test_calculator.py -k "test_add_two_numbers"
# Result: PASS
```

**Refactor Phase**:
```python
# src/calculator.py
def add(a: int, b: int) -> int:
    """Add two integers with type safety."""
    return a + b
```

```bash
pytest tests/test_calculator.py
# Result: ALL PASS
```

### Example 2: Bug Fix with Regression Tests

**Red Phase**:
```python
# tests/test_auth.py
def test_login_with_invalid_credentials():
    result = auth.login("user@example.com", "wrongpassword")
    assert result.is_success is False
    assert result.error == "Invalid credentials"
```

```bash
pytest tests/test_auth.py -k "test_login_with_invalid_credentials"
# Result: FAIL - returns success instead of error
```

**Green Phase**:
```python
# src/auth.py
def login(email, password):
    user = find_user(email)
    if not user or not verify_password(password, user.password_hash):
        return LoginResult(is_success=False, error="Invalid credentials")
    return LoginResult(is_success=True, token=generate_token(user))
```

**Refactor Phase**:
```python
# src/auth.py
def login(email: str, password: str) -> LoginResult:
    """Authenticate user with email and password."""
    user = find_user(email)
    if not _credentials_valid(user, password):
        return LoginResult(is_success=False, error="Invalid credentials")
    return LoginResult(is_success=True, token=generate_token(user))

def _credentials_valid(user, password) -> bool:
    """Verify user credentials."""
    return user and verify_password(password, user.password_hash)
```

## Ralph Loop Integration

### Full Ralph Loop Execution

```bash
# Iteration 1: Initial implementation
npm test
# Result: FAIL - 3 tests failing

# Fix failures
# [Code changes]

# Iteration 2: Run checks
npm test && npx tsc --noEmit && npm run lint
# Result: Tests PASS, type-check FAIL

# Fix type errors
# [Code changes]

# Iteration 3: Run checks
npm test && npx tsc --noEmit && npm run lint
# Result: All PASS, coverage 72%

# Add tests for coverage
# [Test additions]

# Iteration 4: Run checks
npm test && npx tsc --noEmit && npm run lint && npm run test:coverage
# Result: All PASS, coverage 85%

# Exit with <CODER_COMPLETE>
```

### Quality Gate Priority

When multiple failures occur, fix in this order:

1. **Tests** (blocking)
   - Fix test failures first
   - Cannot proceed without passing tests

2. **Type Check** (blocking)
   - Fix type errors after tests pass
   - Ensures type safety

3. **Lint** (non-blocking)
   - Fix lint violations after type check
   - Code style issues

4. **Coverage** (target)
   - Add tests if coverage < 80%
   - Last priority

## SC-Based Parallel Execution

### Independent SCs Example

```yaml
SC-1: Implement login feature
  Files: src/auth/login.ts, tests/auth/login.test.ts
  Dependencies: None

SC-2: Implement logout feature
  Files: src/auth/logout.ts, tests/auth/logout.test.ts
  Dependencies: None

SC-3: Implement password reset
  Files: src/auth/reset.ts, tests/auth/reset.test.ts
  Dependencies: SC-1 (needs login session)
```

**Parallel Execution**:
- Coder Instance 1: SC-1 (login)
- Coder Instance 2: SC-2 (logout)
- Sequential: SC-3 (reset, waits for SC-1)

### File Conflict Prevention

**Bad Example** (conflict):
```yaml
SC-1: Add user validation
  Files: src/user.ts (lines 1-50)

SC-2: Add user permissions
  Files: src/user.ts (lines 1-50)  # CONFLICT
```

**Good Example** (no conflict):
```yaml
SC-1: Add user validation
  Files: src/user/validation.ts

SC-2: Add user permissions
  Files: src/user/permissions.ts
```

## Skill References

### TDD Skill Usage

```markdown
# Invoke TDD skill
1. Red: Write failing test
2. Green: Minimal implementation
3. Refactor: Clean up code
4. Verify: All tests pass
```

Reference: `@.claude/skills/tdd/SKILL.md`

### Ralph Loop Skill Usage

```markdown
# Ralph Loop
iteration=1
while [ $iteration -le 7 ]; do
  run_checks && break || fix
  ((iteration++))
done
```

Reference: `@.claude/skills/ralph-loop/SKILL.md`

### Vibe Coding Standards

```markdown
# Code Quality Limits
- Functions ≤50 lines
- Files ≤200 lines
- Nesting ≤3 levels
- SRP, DRY, KISS, Early Return
```

Reference: `@.claude/skills/vibe-coding/SKILL.md`

### Git Master Usage

```markdown
# Commit (when user requests)
git add <files>
git commit -m "feat(scope): description\n\nCo-Authored-By: Claude <noreply@anthropic.com>"
```

Reference: `@.claude/skills/git-master/SKILL.md`

## Output Format Examples

### Success Output

```markdown
## Coder Agent Summary

### Implementation Complete ✅
- Success Criteria Met: SC-1, SC-2, SC-3
- Files Changed: 5

### Test Files (MANDATORY)
- `tests/auth/login.test.ts`: Created with 8 tests
- `tests/auth/logout.test.ts`: Created with 5 tests

### Test Results (MANDATORY)
- PASS: 25 | FAIL: 0 | SKIP: 2

### Coverage (MANDATORY)
- Overall: 87% (target: 80%) | Core: 93% (target: 90%)

### Ralph Loop (MANDATORY)
- Total Iterations: 4 | Final Status: <CODER_COMPLETE>

### Verification Results
- Type Check: ✅ | Lint: ✅
```

### Blocked Output

```markdown
## Coder Agent Summary

### Implementation Blocked ⚠️
- Status: <CODER_BLOCKED>
- Reason: Cannot achieve 80% coverage threshold
- Current Coverage: 72% (target: 80%)

### Ralph Loop (MANDATORY)
- Total Iterations: 7 (max reached) | Final Status: <CODER_BLOCKED>

### Recommendation
- Delegate to GPT Architect for coverage strategy
```

## Context Isolation Benefits

### Token Efficiency

```
Before (single context):
- Main orchestrator: 50K tokens
- Coder agent: Same 50K tokens
- Total: 50K tokens (shared)

After (isolated context):
- Main orchestrator: 5K tokens
- Coder agent: 80K tokens (isolated)
- Summary return: 1K tokens
- Total: 6K tokens (main + summary)

Efficiency: 8x improvement
```

### Parallel Execution

```
Sequential:
- SC-1: 80K tokens
- SC-2: 80K tokens
- SC-3: 80K tokens
- Total: 240K tokens

Parallel (3 agents):
- SC-1, SC-2, SC-3: 80K tokens each (simultaneous)
- Total: 80K tokens (wall time)

Speed: 3x improvement
```
