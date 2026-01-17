# Ralph Loop Reference Guide

> **Purpose**: Detailed reference for autonomous quality verification loop
> **Complements**: @./SKILL.md (core methodology)

---

## Ralph Loop Deep Dive

### The Philosophy Behind Ralph Loop

**Origin**: Named after the autonomous, self-correcting nature of the loop - like Ralph Waldo Emerson's self-reliance philosophy.

**Core Principle**: Fast feedback loops prevent accumulated bugs.

**Why Immediate Entry?**
```
❌ WRONG APPROACH (Batch testing):
Write code → Write code → Write code → Test
                          ↓
                    3 bugs, hard to debug

✅ RALPH APPROACH (Micro-cycle):
Write code → Test ✅ → Write code → Test ✅ → Write code → Test ❌
                        ↓                    ↓
                   1 bug, easy fix         1 bug, easy fix
```

### Loop Mechanics Explained

#### State Machine Diagram

```
                    ┌─────────────────┐
                    │   ENTRY POINT   │
                    │  (First edit)   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Run Verification│
                    │  (Tests, Types,  │
                    │   Lint, Coverage)│
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
         All gates pass?            No, failures
                │                         │
         Yes ✅                         │
                │                         ▼
                │                ┌─────────────────┐
                │                │  Fix (Priority) │
                │                │  Errors >       │
                │                │  Coverage >     │
                │                │  Lint           │
                │                └────────┬────────┘
                │                         │
                │                         ▼
                │                ┌─────────────────┐
                │                │  Increment      │
                │                │  iteration++    │
                │                └────────┬────────┘
                │                         │
                │                         │
                │         Check max iterations (7)
                │                         │
                └─────────────┬───────────┘
                              │
                     ┌────────┴────────┐
                     │                 │
              Max reached?       Continue
                     │                 │
              Yes ❌                 │
                     │                 │
                     ▼                 ▼
            ┌────────────┐   ┌──────────────┐
            │ <RALPH_     │   │    Back to   │
            │  BLOCKED>   │   │ Verification │
            └────────────┘   └──────────────┘
```

#### Exit Conditions Detailed

| Condition | Check | Output |
|-----------|-------|--------|
| **Success** | All pass + coverage≥80% + todos complete | `<RALPH_COMPLETE>` |
| **Failure** | Max 7 iterations + unrecoverable error | `<RALPH_BLOCKED>` |
| **Blocked** | User intervention needed | `<RALPH_BLOCKED>` |

---

## Fix Priority Strategies

### 1. Error Fixing (Highest Priority)

**Strategy**: Fix test failures before anything else

```python
# Example: Test failure
def test_user_creation():
    user = User.create("test@example.com")
    assert user.id is not None  # FAILS: id is None

# Fix: Address the root cause
class User:
    @classmethod
    def create(cls, email):
        user = cls(email=email)
        user.save()  # This sets the ID
        return user

# After fix: Re-run immediately
pytest tests/test_user.py::test_user_creation -v  # PASS ✅
```

### 2. Type Error Fixing

**Strategy**: Fix type issues second

```typescript
// Example: Type error
function processUser(user: User): string {
    return user.name;  // ERROR: Property 'name' does not exist
}

// Fix: Add proper type definition
interface User {
    id: number;
    username: string;  // Changed from 'name' to 'username'
}

function processUser(user: User): string {
    return user.username;  // ✅ Type check passes
}
```

### 3. Coverage Improvement (Medium Priority)

**Strategy**: Add tests for uncovered paths

```python
# Current coverage: 70%
# Missing: Error paths, edge cases

def divide(a, b):
    if b == 0:
        return None  # Uncovered line
    return a / b

# Add test for uncovered path
def test_divide_by_zero():
    result = divide(10, 0)
    assert result is None  # Now covered

# After: Coverage 75%+
```

### 4. Lint Fixing (Lowest Priority)

**Strategy**: Fix lint warnings last

```python
# Example: Lint warning
def calculate(x):  # WARNING: Argument name 'x' too short
    return x * 2

# Fix: Use descriptive name
def calculate(value):  # ✅ No lint warning
    return value * 2
```

---

## Ralph Loop in Different Contexts

### Web Development (Node.js)

```bash
# Iteration 1: Initial run
npm test                    # 3 failures
npx tsc --noEmit           # 2 type errors
npm run lint              # 5 warnings

# Iteration 2: Fix errors
# [Fix test failures]
npm test                  # 1 failure
npx tsc --noEmit           # ✅ Clean
npm run lint              # 5 warnings (defer)

# Iteration 3: Continue fixing
# [Fix remaining test]
npm test                  # ✅ All pass

# Iteration 4: Improve coverage
npm run test:coverage     # 75% (need 80%)
# [Add edge case tests]
npm run test:coverage     # 82% ✅

# Output: <RALPH_COMPLETE>
```

### Python Development

```bash
# Iteration 1
pytest                    # 2 failures
mypy .                    # 3 type errors
ruff check .              # 2 warnings

# Iteration 2: Fix test failures
# [Fix code]
pytest                    # ✅ Pass
mypy .                    # 3 type errors
ruff check .              # 2 warnings

# Iteration 3: Fix type errors
# [Fix types]
mypy .                    # ✅ Clean

# Iteration 4: Coverage
pytest --cov              # 72%
# [Add tests]
pytest --cov              # 81% ✅

# Output: <RALPH_COMPLETE>
```

### Go Development

```bash
# Iteration 1
go test ./...             # 1 failure
golangci-lint run         # 3 issues

# Iteration 2: Fix test
# [Fix code]
go test ./...             # ✅ Pass
golangci-lint run         # 3 issues

# Iteration 3: Fix lint
# [Fix lint issues]
golangci-lint run         # ✅ Clean
go test -cover ./...      # 78%

# Iteration 4: Coverage
# [Add tests]
go test -cover ./...      # 83% ✅

# Output: <RALPH_COMPLETE>
```

---

## Advanced Ralph Patterns

### Pattern 1: Early Exit Strategy

**When**: You detect fundamental design issues

```python
# Iteration 1
pytest                    # 10 failures

# Analysis: All failures related to missing User model
# Decision: Don't fix individual tests, fix the design

# Iteration 2: Create User model
class User:
    def __init__(self, email, password):
        self.email = email
        self.password_hash = hash(password)

# Iteration 3: Re-run
pytest                    # 3 failures (much better!)

# Continue with remaining fixes
```

### Pattern 2: Test-First Ralph (TDD Integration)

```python
# Ralph starts BEFORE implementation

# Ralph Iteration 1: RED (write test first)
def test_user_login():
    user = User.login("test@example.com", "password")
    assert user.is_authenticated
# Run: FAIL (expected)

# Ralph Iteration 2: GREEN (minimal implementation)
class User:
    @staticmethod
    def login(email, password):
        user = User.find_by_email(email)
        if user and user.check_password(password):
            user.is_authenticated = True
            return user
        return None
# Run: PASS ✅

# Ralph Iteration 3: REFACTOR
# Clean up while keeping tests green
# Run: PASS ✅

# Output: <RALPH_COMPLETE>
```

### Pattern 3: Parallel Ralph (Multiple Fixers)

**When**: Multiple independent failures

```python
# Ralph detects:
# - 3 test failures (different features)
# - 2 type errors (different files)
# - 5 lint warnings (different files)

# Strategy: Fix in parallel (if safe)

# Parallel fixes:
# Fixer 1: test_a.py failures
# Fixer 2: test_b.py failures
# Fixer 3: test_c.py failures

# After parallel fixes:
pytest                    # ✅ All pass
```

---

## Ralph Loop Log Format

### Log File Structure

```markdown
# Ralph Loop Log - {RUN_ID}

## Iteration 1 (2026-01-15 12:08:30)

### Verification Results
- Tests: ❌ 3 failures
  - `test_user_creation`: AssertionError
  - `test_login_invalid`: ValueError
  - `test_password_hash`: TypeError
- Type Check: ✅ Clean
- Lint: ⚠️ 4 warnings
- Coverage: 65% (target: 80%)

### Actions Taken
- Fixed user creation test: Added missing User.save() call
- Fixed login test: Added proper error handling

### Iteration Status: Continue

---

## Iteration 2 (2026-01-15 12:09:15)

### Verification Results
- Tests: ✅ All pass
- Type Check: ✅ Clean
- Lint: ⚠️ 4 warnings
- Coverage: 78% (target: 80%)

### Actions Taken
- Added edge case test for empty email
- Added test for duplicate user creation

### Iteration Status: Continue (coverage below threshold)

---

## Iteration 3 (2026-01-15 12:10:00)

### Verification Results
- Tests: ✅ All pass (15/15)
- Type Check: ✅ Clean
- Lint: ✅ Clean
- Coverage: 82% ✅

### Actions Taken
- Fixed 2 lint warnings (variable names)
- Added test for password validation edge case

### Iteration Status: <RALPH_COMPLETE>

---

## Ralph Loop Summary
- **Total Iterations**: 3
- **Final Status**: <RALPH_COMPLETE>
- **Coverage**: 82% (80% target met)
- **All Tests**: ✅ Pass
- **Type Check**: ✅ Clean
- **Lint**: ✅ Clean
```

---

## Troubleshooting Common Issues

### Issue 1: Infinite Loop

**Symptom**: Ralph never exits, keeps iterating

**Diagnosis**:
```bash
# Check iteration count
grep "Iteration" ralph-loop-log.md | wc -l  # Should be ≤7

# Check for completion marker
grep "<RALPH_COMPLETE>" ralph-loop-log.md
```

**Solution**: Identify what gate can't pass

| Can't Pass | Likely Cause | Fix |
|------------|--------------|-----|
| Tests | Flaky test or dependency issue | Stabilize test or mock dependency |
| Coverage | Dead code or hard-to-reach logic | Remove dead code or accept lower threshold |
| Type Check | Wrong types in library code | Add type ignores or fix types |
| Lint | Code style disagreement | Configure lint rules |

### Issue 2: Coverage Plateau

**Symptom**: Coverage stuck at 72%, target is 80%

**Diagnosis**:
```bash
# See what's not covered
pytest --cov --cov-report=term-missing

# Output shows:
# src/user.py:45: >>>>>>>  (line 45 not covered)
# src/auth.py:78: >>>>>>>  (line 78 not covered)
```

**Strategy**:
1. **Categorize uncovered lines**:
   - Error paths: Add tests for error conditions
   - Edge cases: Add tests for boundary conditions
   - Dead code: Remove if truly unreachable
   - Defensive code: Consider if needed

2. **Prioritize high-value coverage**:
   ```python
   # High value: Business logic
   def calculate_discount(user, order):
       if user.is_premium:  # Cover this
           return order.total * 0.9
       return order.total

   # Low value: Defensive checks
   def process_payment(amount):
       if amount is None:  # Maybe skip if truly impossible
           raise ValueError("Amount required")
   ```

3. **Document exceptions**:
   ```python
   # Line 78-85: External API error handling
   # Coverage exception: API never fails in test environment
   # See: https://github.com/org/repo/issues/123
   ```

### Issue 3: Type Check Failures in Library Code

**Symptom**: Type errors in `node_modules/` or vendored code

**Solutions**:

```typescript
// Option 1: Type ignores (specific)
import { externalFunc } from 'external-lib';
// @ts-ignore - external-lib has incomplete types
const result = externalFunc();

// Option 2: Type declarations (global)
// declarations.d.ts
declare module 'external-lib' {
    export function externalFunc(): string;
}

// Option 3: Skip type checking for vendor files
// tsconfig.json
{
    "exclude": ["node_modules/**"]
}
```

---

## Ralph Loop Integration Points

### With TDD (Test-Driven Development)

```
TDD Cycle                  Ralph Loop
─────────────────────────────────────────
Red: Write test         →  [Edit code]
                          Ralph starts ↓
Green: Make it pass      →  [Test fails]
                          Fix ↓
                          [Test passes]
                          Ralph: All gates?
                              No → Continue
                              Yes → <RALPH_COMPLETE>
                          Continue to TDD ↓
Refactor: Clean up      →  [Edit code]
                          Ralph starts again ↓
                          [All tests pass]
                          Ralph: Coverage OK?
                              No → Add tests
                              Yes → <RALPH_COMPLETE>
```

### With CI/CD

```yaml
# .github/workflows/test.yml
name: Ralph Loop Verification

on: [push, pull_request]

jobs:
  ralph-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Ralph Loop
        run: |
          MAX_ITER=7
          ITER=1
          while [ $ITER -le $MAX_ITER ]; do
            npm test && npx tsc --noEmit && npm run lint
            if [ $? -eq 0 ]; then
              echo "<RALPH_COMPLETE>"
              exit 0
            fi
            ITER=$((ITER + 1))
          done
          echo "<RALPH_BLOCKED>"
          exit 1
```

---

## Performance Optimization

### Parallel Test Execution

```bash
# Sequential (slow)
pytest tests/  # 5 minutes

# Parallel (fast)
pytest -n auto tests/  # 1.5 minutes (3x faster)

# Integration with Ralph
export TEST_CMD="pytest -n auto"
ralph-loop  # Uses parallel tests
```

### Incremental Verification

```bash
# Only test changed files (TypeScript)
npx tsc --noEmit --pretty

# Only test changed files (Go)
go test ./$(git diff --name-only | grep '_test\.go' | xargs dirname | sort -u)

# Only lint changed files (Python)
ruff check $(git diff --name-only | grep '\.py$')
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    RALPH LOOP QUICK REFERENCE                │
├─────────────────────────────────────────────────────────────┤
│  ENTRY: Immediately after first Edit/Write                  │
│  MAX:   7 iterations                                        │
│  GATES: Tests, Type, Lint, Coverage                         │
├─────────────────────────────────────────────────────────────┤
│  Priority: Errors > Coverage > Lint                         │
│  Output: <RALPH_COMPLETE> or <RALPH_BLOCKED>                │
├─────────────────────────────────────────────────────────────┤
│  Coverage: 80% overall, 90%+ core modules                   │
├─────────────────────────────────────────────────────────────┤
│  Test Detection: pyproject.toml → pytest                    │
│                 package.json → npm test                     │
│                 go.mod → go test ./...                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Further Reading

### Internal Resources
- @.claude/skills/tdd/SKILL.md - Test-Driven Development
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards

### External Resources
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Last Updated**: 2026-01-15
