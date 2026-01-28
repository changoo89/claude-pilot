# Ralph Loop Reference Guide

> **Purpose**: Detailed reference for autonomous quality verification loop
> **Complements**: @./SKILL.md (core methodology)

---

## Philosophy & Core Principle

**Origin**: Named after autonomous, self-correcting nature - fast feedback prevents accumulated bugs.

**Micro-cycle vs Batch**:
```
❌ WRONG (Batch): Write code → Write code → Write code → Test → 3 bugs, hard to debug
✅ RALPH (Micro): Write code → Test ✅ → Write code → Test ✅ → 1 bug each, easy fix
```

---

## State Machine

| State | Condition | Next State | Output |
|-------|-----------|------------|--------|
| **Entry** | First code change | Verification | - |
| **Verification** | Run all gates | Success → Complete; Fail → Fix | - |
| **Fix** | iteration < 7 | Verification | - |
| **Fix** | iteration = 7 | Blocked | `<RALPH_BLOCKED>` |
| **Complete** | All gates pass | Exit | `<RALPH_COMPLETE>` |

### Exit Conditions

| Condition | Check | Output |
|-----------|-------|--------|
| **Success** | All pass + coverage≥80% + todos complete | `<RALPH_COMPLETE>` |
| **Failure** | Max 7 iterations reached | `<RALPH_BLOCKED>` |
| **Blocked** | User intervention needed | `<RALPH_BLOCKED>` |

---

## Fix Priority Strategies

### Priority Order: Errors → Type-check → Coverage → Lint

**1. Error Fixing (Highest Priority)**
```python
# Test failure
def test_user_creation():
    user = User.create("test@example.com")
    assert user.id is not None  # FAILS: id is None

# Fix
class User:
    @classmethod
    def create(cls, email):
        user = cls(email=email)
        user.save()  # Sets ID
        return user

# Re-run: PASS ✅
```

**2. Type Error Fixing**
```typescript
// ERROR: Property 'name' does not exist
function processUser(user: User): string {
    return user.name;
}

// Fix: Correct type
interface User {
    id: number;
    username: string;  // Changed from 'name'
}

function processUser(user: User): string {
    return user.username;  // ✅
}
```

**3. Coverage Improvement**
```python
# Missing: Error paths
def divide(a, b):
    if b == 0:
        return None  # Uncovered
    return a / b

# Add test
def test_divide_by_zero():
    result = divide(10, 0)
    assert result is None  # Now covered
```

**4. Lint Fixing (Lowest Priority)**
```python
# WARNING: Argument name 'x' too short
def calculate(x):
    return x * 2

# Fix
def calculate(value):  # ✅
    return value * 2
```

---

## Language-Specific Examples

| Language | Commands | Iterations |
|----------|----------|------------|
| **TypeScript** | `npm test` → `npx tsc --noEmit` → `npm run lint` | Fix errors → coverage → ✅ |
| **Python** | `pytest` → `mypy .` → `pytest --cov` | Fix errors → types → coverage → ✅ |
| **Go** | `go test ./...` → `golangci-lint run` → `go test -cover` | Fix errors → lint → coverage → ✅ |

---

## Advanced Patterns

### Pattern 1: Early Exit Strategy

**When**: Fundamental design issues detected

```python
# Iteration 1: 10 failures - all related to missing User model
# Decision: Fix design, not individual tests

# Iteration 2: Create User model
class User:
    def __init__(self, email, password):
        self.email = email
        self.password_hash = hash(password)

# Iteration 3: 3 failures (much better)
# Continue with remaining fixes
```

### Pattern 2: TDD Integration

```python
# Ralph Iteration 1: RED (test first)
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
# Output: <RALPH_COMPLETE>
```

---

## Ralph Loop Log Format

```markdown
# Ralph Loop Log - {RUN_ID}

## Iteration 1
- Tests: ❌ 3 failures → Fixed user creation, login tests
- Type: ✅ | Lint: ⚠️ 4 | Coverage: 65%
- Status: Continue

## Iteration 2
- Tests: ✅ All pass
- Coverage: 78% → Added edge tests → 82% ✅
- Status: <RALPH_COMPLETE>

## Summary
Iterations: 2 | Status: <RALPH_COMPLETE> | Coverage: 82%
```

---

## Troubleshooting

### Issue 1: Infinite Loop

**Symptom**: Ralph never exits, keeps iterating

**Diagnosis**:
```bash
grep "Iteration" ralph-loop-log.md | wc -l  # Should be ≤7
grep "<RALPH_COMPLETE>" ralph-loop-log.md
```

**Solutions**:

| Can't Pass | Likely Cause | Fix |
|------------|--------------|-----|
| Tests | Flaky test or dependency | Stabilize test or mock dependency |
| Coverage | Dead code or unreachable logic | Remove dead code or accept lower threshold |
| Type Check | Wrong library types | Add type ignores or fix types |
| Lint | Code style disagreement | Configure lint rules |

### Issue 2: Coverage Plateau

**Symptom**: Coverage stuck below target

**Diagnosis**: `pytest --cov --cov-report=term-missing` to find uncovered lines

**Strategy**: Categorize (error paths, edge cases, dead code), prioritize business logic, document exceptions

### Issue 3: Type Check Failures in Library Code

**Solutions**: Type ignore (`// @ts-ignore`), type declarations (`declarations.d.ts`), exclude vendor (`tsconfig.json`)

---

## Performance Optimization

| Technique | Command | Speedup |
|-----------|---------|---------|
| **Parallel Tests** | `pytest -n auto` | 3x faster |
| **Incremental Type** | `npx tsc --noEmit --pretty` | Only changed files |
| **Incremental Lint** | `ruff check $(git diff --name-only)` | Only changed files |

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

## No-Excuses Enforcement Algorithm

### PROHIBITED Phrases

| Phrase Type | Examples | Impact |
|-------------|----------|--------|
| **Defeatist** | "I cannot...", "Unable to...", "Impossible to..." | Blocks progress |
| **Complexity Excuse** | "Too complex to...", "Beyond scope...", "Not feasible..." | Premature quit |
| **Capability Limit** | "Beyond my capabilities...", "I'm not able to..." | False limitation |

### Required Response Pattern

**on_blocker_detected Flow**:
```bash
on_blocker_detected() {
  local blocker="$1"

  # Step 1: GPT Architect delegation
  echo "Blocker detected: $blocker"
  echo "Delegating to GPT Architect for resolution strategy..."

  if gpt_architect_resolve "$blocker"; then
    echo "GPT provided solution, implementing..."
    return 0
  fi

  # Step 2: User collaboration (NOT "give up")
  echo "GPT unable to resolve independently."
  echo "Requesting user collaboration for: $blocker"
  echo "Options: [approach A], [approach B], [approach C]"

  # Step 3: Never use PROHIBITED phrases
  # WRONG: "I cannot implement this feature"
  # RIGHT: "To implement this feature, I need: [specific help]"

  return 1
}
```

### Enforcement Examples

| Scenario | PROHIBITED Response | REQUIRED Response |
|----------|---------------------|-------------------|
| API integration | "I cannot integrate this API" | "To integrate this API, I will: 1) delegate to GPT for auth strategy, 2) implement retry logic, 3) request user API key" |
| Complex algorithm | "Too complex to implement" | "Breaking down into: 1) data structure design (GPT), 2) core logic (incremental), 3) optimization (iterative)" |
| Missing dependency | "Unable to proceed without X" | "Installing dependency X, updating imports, implementing feature" |

### Exception Handling

**Only Exception**: User explicitly requests task abort

```bash
# User says: "Stop working on this, abandon the feature"
# Response: Acknowledge and halt (not a violation)

# User says: "This is hard"
# Response: Continue with alternative approaches (NOT an excuse to quit)
```

### Ralph Loop Integration

**Blocker Detection Points**:
1. Test failure after 3 iterations → on_blocker_detected
2. Type check errors persist after 2 iterations → on_blocker_detected
3. Coverage plateau after 4 iterations → on_blocker_detected
4. Max iterations (7) reached → on_blocker_detected (GPT escalation)

**Integration Example**:
```bash
while [ $iteration -lt $max_iterations ]; do
  if run_all_checks; then
    echo "<RALPH_COMPLETE>"
    break
  fi

  # Check for persistent blockers
  if is_persistent_blocker; then
    on_blocker_detected "$(get_blocker_description)"
    # Never output: "I cannot fix this"
    # Always: GPT delegation → User collaboration → Alternative approach
  fi

  fix_failures
  ((iteration++))
done
```

---

## Further Reading

**Internal**: @.claude/skills/tdd/SKILL.md - Test-Driven Development | @.claude/skills/vibe-coding/SKILL.md - Code quality standards | @.claude/skills/gpt-delegation/SKILL.md - Escalation patterns

**External**: [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Last Updated**: 2026-01-27
