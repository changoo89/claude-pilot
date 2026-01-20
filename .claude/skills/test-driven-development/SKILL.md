---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code. Red-Green-Refactor cycle ensures tests pass.
---

# SKILL: Test-Driven Development

> **Purpose**: Red-Green-Refactor cycle for reliable code with tests
> **Target**: Coder agent implementing features or bugfixes

---

## Quick Start

### When to Use This Skill
- Implementing new features
- Fixing bugs
- Refactoring existing code
- Adding new functionality

### Quick Reference
```bash
# TDD Cycle
1. RED: Write failing test
   npm test -- --watch  # See test fail

2. GREEN: Write minimal code to pass
   # Implement just enough to make test pass

3. REFACTOR: Clean up while keeping tests green
   npm run lint  # Ensure code quality

4. REPEAT: Until all acceptance criteria met
```

---

## Core Concepts

### The TDD Cycle

**Step 1: RED** - Write a failing test
```typescript
// src/auth.service.test.ts
describe('AuthService', () => {
  it('should authenticate valid user', async () => {
    const service = new AuthService();
    const result = await service.authenticate('user@example.com', 'password');
    expect(result).toBe(true);
  });
});
```

**Verify test fails**:
```bash
npm test
# FAIL: AuthService is not defined
```

**Step 2: GREEN** - Write minimal code to pass
```typescript
// src/auth.service.ts
export class AuthService {
  async authenticate(email: string, password: string): Promise<boolean> {
    // Minimal implementation
    return true;
  }
}
```

**Verify test passes**:
```bash
npm test
# PASS: AuthService authenticates
```

**Step 3: REFACTOR** - Clean up
```typescript
// src/auth.service.ts
export class AuthService {
  constructor(private users: UserRepository) {}

  async authenticate(email: string, password: string): Promise<boolean> {
    const user = await this.users.findByEmail(email);
    if (!user) return false;
    return await user.verifyPassword(password);
  }
}
```

**Verify tests still pass**:
```bash
npm test && npm run lint
# All tests pass, code is clean
```

---

## Test Patterns

### Arrange-Act-Assert

**Structure**:
```typescript
it('should calculate total with discount', () => {
  // Arrange: Setup test data
  const cart = new Cart();
  cart.addItem(new Item('Widget', 100));

  // Act: Execute the behavior
  cart.applyDiscount('SUMMER20');

  // Assert: Verify expected outcome
  expect(cart.total).toBe(80);
});
```

### Given-When-Then

**Structure**:
```typescript
it('should reject invalid credit card', () => {
  // Given: User has invalid card
  const payment = new PaymentService();
  const card = { number: 'invalid', expiry: '12/25' };

  // When: Processing payment
  const result = payment.process(card, 100);

  // Then: Payment is rejected
  expect(result.success).toBe(false);
  expect(result.error).toBe('Invalid card number');
});
```

---

## Test Coverage

### Coverage Targets

- **Overall**: ≥80% line coverage
- **Core modules**: ≥90% line coverage
- **Critical paths**: 100% coverage

### Measure Coverage
```bash
# Generate coverage report
npm test -- --coverage

# View coverage in browser
open coverage/lcov-report/index.html
```

### Coverage Example
```
File                    | Lines  | Stmts | Branch | Funcs |
------------------------|--------|-------|--------|-------|
auth.service.ts         | 95.5%  | 94.7% | 87.5%  | 100%  |
users.service.ts        | 88.2%  | 85.3% | 75.0%  | 100%  |
------------------------|--------|-------|--------|-------|
All files               | 91.8%  | 90.0% | 81.2%  | 100%  |
```

---

## Common Patterns

### Testing Async Code
```typescript
// Promise-based
it('should fetch user', async () => {
  const user = await service.getUser(1);
  expect(user.name).toBe('Alice');
});

// Callback-based
it('should emit event', (done) => {
  service.on('event', (data) => {
    expect(data).toBe('expected');
    done();
  });
  service.trigger();
});

// Timer-based
jest.useFakeTimers();
it('should timeout after 5s', () => {
  service.start();
  jest.advanceTimersByTime(5000);
  expect(service.timedOut).toBe(true);
});
```

### Mocking Dependencies
```typescript
// Mock external service
const mockRepository = {
  findByEmail: jest.fn().mockResolvedValue({ id: 1, email: 'test@example.com' })
};
const service = new AuthService(mockRepository);

await service.authenticate('test@example.com', 'password');
expect(mockRepository.findByEmail).toHaveBeenCalledWith('test@example.com');
```

### Error Testing
```typescript
it('should throw on invalid input', () => {
  expect(() => service.validate(null)).toThrow('Invalid input');
  expect(() => service.validate('')).toThrow('Email required');
});
```

---

## Ralph Loop Integration

**Autonomous iteration until all tests pass**:

1. **Entry**: Immediately after first code change
2. **Max iterations**: 7
3. **Verification**: Tests, type-check, lint, coverage
4. **Exit**: All quality gates pass

**See**: @.claude/skills/ralph-loop/SKILL.md

---

## Quality Gates

After implementation:
- [ ] All tests pass (`npm test`)
- [ ] Coverage ≥80% overall, ≥90% core (`npm test -- --coverage`)
- [ ] Type check clean (`npm run type-check`)
- [ ] Lint clean (`npm run lint`)
- [ ] No console.log statements (use proper logging)

---

## Verification

### Test TDD Workflow
```bash
# 1. Create test file
cat > src/example.test.ts << 'EOF'
test('example', () => {
  expect(true).toBe(false);
});
EOF

# 2. Run test (should fail)
npm test

# 3. Fix implementation
# 4. Run test (should pass)
npm test

# 5. Verify coverage
npm test -- --coverage
```

---

## Related Skills

- **ralph-loop**: Autonomous iteration until all tests pass
- **code-quality-gates**: Formatting, type-check, linting
- **vibe-coding**: Code quality standards (≤50 lines/function)

---

**Version**: claude-pilot 4.2.0
