# Test Plan Design Guide

> **Purpose**: Define comprehensive test scenarios with clear pass/fail criteria
> **Target**: Planning phase (Step 2 of /00_plan)

## Core Principles

- **Test-First Thinking**: Design tests before implementation
- **Coverage Goals**: 80%+ overall, 90%+ for core modules
- **Clear Criteria**: Every test has input, expected output, and verification method
- **Path Specified**: Every test scenario includes the target test file path

## Test Scenario Template

Each test scenario MUST include:

| Field | Description | Example |
|-------|-------------|---------|
| **ID** | Unique identifier (TS-1, TS-2, ...) | TS-1 |
| **Scenario** | What is being tested | User login with valid credentials |
| **Input** | Test data/conditions | email: "user@example.com", password: "secret123" |
| **Expected** | Expected result | Returns JWT token, status 200 |
| **Type** | Unit/Integration/E2E | Integration |
| **Test File** | Where test will be created | `tests/auth/login.test.ts` |

## Test Types

### Unit Tests
- Test individual functions/classes in isolation
- Mock external dependencies
- Fast execution (<1ms per test)

**Example**:
```
TS-1 | Add two numbers | 2, 3 | Returns 5 | Unit | tests/math/calculator.test.ts
```

### Integration Tests
- Test multiple components working together
- Real database, external services
- Medium execution (10-100ms per test)

**Example**:
```
TS-2 | User registration flow | Valid user data | Creates user record, sends welcome email | Integration | tests/auth/registration.test.ts
```

### E2E Tests
- Test complete user workflows
- Real browser/API interactions
- Slow execution (1-10s per test)

**Example**:
```
TS-3 | Complete purchase flow | Add item, checkout, pay | Order created, email sent | E2E | tests/e2e/purchase.test.ts
```

## Coverage Strategy

### Happy Path (Primary Success)
- Normal usage scenarios
- Expected inputs and flows
- Core business value

### Edge Cases
- Boundary conditions (empty, zero, max values)
- Unusual but valid inputs
- Concurrent operations

### Error Paths
- Invalid inputs
- Network failures
- Permission denied
- Resource exhaustion

## Test Environment Detection

Automatically detect project type and framework:

```bash
# Python
if [ -f "pyproject.toml" ]; then
    TEST_CMD="pytest"
    TEST_DIR="tests"
fi

# Node.js
if [ -f "package.json" ]; then
    TEST_CMD="npm test"
    TEST_DIR="tests"
fi

# Go
if [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
    TEST_DIR=""  # Go uses inline tests
fi
```

## Test File Organization

**Structure by Feature**:
```
tests/
├── auth/
│   ├── login.test.ts
│   ├── registration.test.ts
│   └── password-reset.test.ts
├── api/
│   ├── users.test.ts
│   └── posts.test.ts
└── e2e/
    └── purchase-flow.test.ts
```

**Or Structure by Layer**:
```
tests/
├── unit/
│   ├── utils.test.ts
│   └── validators.test.ts
├── integration/
│   └── database.test.ts
└── e2e/
    └── api.test.ts
```

## Test Scenario Checklist

Before completing test plan:

- [ ] All success criteria have corresponding test scenarios
- [ ] Happy path covered
- [ ] Edge cases identified
- [ ] Error paths defined
- [ ] Test file paths specified for all scenarios
- [ ] Test environment detected and documented
- [ ] Coverage targets achievable (80%+ overall, 90%+ core)

## Anti-Patterns

### Don't Test Implementation Details
```typescript
// Bad: Tests internal implementation
expect(component.state.items).toHaveLength(3)

// Good: Tests observable behavior
expect(screen.getAllByRole('listitem')).toHaveLength(3)
```

### Don't Write Vague Tests
```typescript
// Bad: No clear criteria
TS-1 | Make sure it works | [input] | [works properly] | Unit | [path]

// Good: Clear input/output
TS-1 | Calculate tax | Price: 100, Rate: 0.1 | Returns 10 | Unit | tests/tax/calculate.test.ts
```

### Don't Skip File Paths
```typescript
// Bad: No file specified
TS-1 | User login | Valid credentials | Returns token | Integration | [TBD]

// Good: Explicit file path
TS-1 | User login | Valid credentials | Returns token | Integration | tests/auth/login.test.ts
```

## Related Guides

- **Test Environment Detection**: @.claude/guides/test-environment.md
- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **PRP Framework**: @.claude/guides/prp-framework.md
