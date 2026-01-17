# TDD Reference Guide

> **Purpose**: Detailed reference for Test-Driven Development methodology
> **Complements**: @./SKILL.md (core methodology)

---

## Advanced TDD Concepts

### Test Triangle Strategy

When deciding what to test, use the test triangle:

```
        /\
       /  \      Unit Tests (70%)
      /____\     - Fast, isolated, many
     /      \
    /        \   Integration Tests (20%)
   /__________\  - Medium speed, real components
  /            \
 /______________\ E2E Tests (10%)
                  - Slow, full system, few
```

**Guidelines**:
- Test business logic at unit level
- Test API contracts at integration level
- Test critical user journeys at E2E level

### Test Coverage Strategy

| Coverage Type | Target | When to Apply |
|---------------|--------|---------------|
| **Line Coverage** | 80% overall | Baseline for all code |
| **Branch Coverage** | 70%+ | Code with conditionals |
| **Path Coverage** | 60%+ | Complex algorithms |
| **Mutation Coverage** | 50%+ | Critical systems |

**What NOT to Test**:
- Generated code
- Third-party libraries
- Simple getters/setters
- Trivial one-liners

---

## Red-Green-Refactor Deep Dive

### Red Phase Strategies

#### 1. Interface-First Design
```python
# Write test FIRST to design the interface
def test_user_repository_can_save_user():
    repo = UserRepository()
    user = User(email="test@example.com", name="Test")
    repo.save(user)

    saved = repo.find_by_email("test@example.com")
    assert saved.email == "test@example.com"
    assert saved.name == "Test"
```

**Benefits**:
- API designed from usage perspective
- Better UX for code consumers
- Forced to think about interfaces first

#### 2. Edge Case Testing
```python
def test_calculator_handles_division_by_zero():
    result = calculator.divide(10, 0)
    assert result.error == "Division by zero"
    assert result.value is None
```

**Common Edge Cases**:
- Empty inputs
- Null/None values
- Boundary conditions (0, -1, MAX_INT)
- Duplicate keys in collections
- Concurrent access

### Green Phase Strategies

#### 1. Fake It Pattern
```python
# First iteration: Return literal
def calculate_total(items):
    return 100.00  # Just enough to pass

# Second iteration: Add real logic
def calculate_total(items):
    total = 0
    for item in items:
        total += item.price
    return total
```

#### 2. Triangulation
```python
# Test 1: Simple case
def test_multiply_positive_numbers():
    assert multiply(2, 3) == 6

# Implementation: return 6 (too specific)
def multiply(a, b):
    return 6

# Test 2: Different case (forces generalization)
def test_multiply_different_numbers():
    assert multiply(4, 5) == 20

# Implementation: General solution
def multiply(a, b):
    return a * b
```

### Refactor Phase Strategies

#### 1. Extract Method
```python
# Before (Green but messy)
def process_order(order):
    if not order:
        return {"error": "No order"}
    if not order.items:
        return {"error": "No items"}
    total = sum(item.price for item in order.items)
    return {"total": total}

# After (Refactored, still Green)
def process_order(order):
    if not is_valid_order(order):
        return get_error_response(order)
    return calculate_order_total(order)

def is_valid_order(order):
    return order and order.items

def get_error_response(order):
    if not order:
        return {"error": "No order"}
    return {"error": "No items"}

def calculate_order_total(order):
    return {"total": sum(item.price for item in order.items)}
```

#### 2. Parameterize Tests
```python
# Before: Duplicate tests
def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-2, -3) == -5

def test_add_mixed_numbers():
    assert add(2, -3) == -1

# After: Parameterized
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-2, -3, -5),
    (2, -3, -1),
    (0, 0, 0),
    (100, -100, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

---

## TDD for Different Architectures

### RESTful API TDD

```python
# 1. RED: Test endpoint behavior
def test_create_user_returns_201_and_user_data():
    response = client.post("/api/users", json={
        "email": "test@example.com",
        "name": "Test User"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["id"] > 0

# 2. GREEN: Minimal implementation
@app.post("/api/users")
def create_user(user_data: UserData):
    user = db.create_user(user_data)
    return {"id": user.id, "email": user.email}, 201

# 3. REFACTOR: Add validation
@app.post("/api/users")
def create_user(user_data: UserData):
    if not user_data.email:
        return {"error": "Email required"}, 400

    existing = db.find_user_by_email(user_data.email)
    if existing:
        return {"error": "Email already exists"}, 409

    user = db.create_user(user_data)
    return {"id": user.id, "email": user.email}, 201
```

### Database Migration TDD

```python
# 1. RED: Test migration creates table
def test_migration_001_creates_users_table():
    migrator = MigrationRunner()
    migrator.up("001_create_users_table")

    tables = db.get_tables()
    assert "users" in tables
    assert "email" in db.get_columns("users")

# 2. GREEN: Create migration file
class Migration001CreateUsersTable(BaseMigration):
    def up(self):
        sql = """
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        )
        """
        db.execute(sql)

# 3. REFACTOR: Add down migration
def down(self):
    db.execute("DROP TABLE users IF EXISTS")
```

### Async/Await TDD

```python
import pytest

@pytest.mark.asyncio
async def test_async_fetch_user():
    # RED
    user = await user_service.fetch_user(123)
    assert user.id == 123
    assert user.name == "Expected Name"

# GREEN
async def fetch_user(self, user_id):
    return await self.db.query(
        "SELECT * FROM users WHERE id = $1", user_id
    )
```

---

## Testing Anti-Patterns to Avoid

### ❌ Testing Implementation Details
```python
# BAD: Tests internal structure
def test_user_has_email_attribute():
    user = User()
    assert hasattr(user, "email")
    assert user._email_storage == []  # Implementation detail

# GOOD: Tests behavior
def test_user_can_set_and_get_email():
    user = User()
    user.email = "test@example.com"
    assert user.email == "test@example.com"
```

### ❌ Brittle Test Data
```python
# BAD: Hardcoded, fragile
def test_order_total():
    order = Order()
    order.add_item(Item("Widget", 19.99))
    order.add_item(Item("Gadget", 29.99))
    assert order.total == 49.98  # What if prices change?

# GOOD: Builder pattern, flexible
def test_order_total():
    order = OrderBuilder.with_items(2).of_price(25.00).build()
    assert order.total == 50.00
```

### ❌ Asserting Multiple Unrelated Things
```python
# BAD: One test, multiple concerns
def test_user_creation():
    user = User.create("test@example.com")
    assert user.email == "test@example.com"
    assert user.created_at is not None
    assert db.row_count("users") == 1  # Different concern!
    assert email_service.was_called()  # Different concern!

# GOOD: One test, one concern
def test_user_creation_sets_email():
    user = User.create("test@example.com")
    assert user.email == "test@example.com"

def test_user_creation_persists_to_db():
    user = User.create("test@example.com")
    assert db.row_count("users") == 1

def test_user_creation_sends_welcome_email():
    user = User.create("test@example.com")
    assert email_service.was_called()
```

---

## Test Doubles Reference

### Mock vs Stub vs Fake vs Spy

| Type | Purpose | Example |
|------|---------|---------|
| **Mock** | Verify interactions | `mock_api.assert_called_with(endpoint)` |
| **Stub** | Provide test inputs | `stub_user = StubUser(id=1, name="Test")` |
| **Fake** | Working implementation | `InMemoryUserRepository()` |
| **Spy** | Record calls for verification | `spy_logger = SpyLogger()` |

### When to Use Each

```python
# MOCK: Verify API was called correctly
@patch('requests.post')
def test_sends_notification_to_slack(mock_post):
    notifier.send_alert("System down")
    mock_post.assert_called_with(
        "https://slack.com/api/chat.postMessage",
        json={"text": "System down"}
    )

# STUB: Provide fixed test data
def test_user_premium_status():
    user = StubUser(premium=True)
    assert user.has_access_to_premium_features()

# FAKE: In-memory database for speed
class InMemoryUserRepository:
    def __init__(self):
        self.users = {}

    def save(self, user):
        self.users[user.id] = user

    def find_by_id(self, user_id):
        return self.users.get(user_id)

# SPY: Record method calls
class SpyEmailService:
    def __init__(self):
        self.calls = []

    def send_welcome(self, email):
        self.calls.append(("welcome", email))

def test_new_user_receives_welcome_email():
    spy = SpyEmailService()
    user_service.register("test@example.com", email_service=spy)
    assert ("welcome", "test@example.com") in spy.calls
```

---

## Performance Testing with TDD

```python
# 1. RED: Performance requirement test
def test_api_response_under_200ms():
    start = time.time()
    api.process_large_dataset(10000)
    duration = (time.time() - start) * 1000

    assert duration < 200, f"Response took {duration}ms"

# 2. GREEN: Initial implementation
def process_large_dataset(self, size):
    data = self.fetch_all_data(size)
    return self.calculate(data)

# 3. REFACTOR: Optimize
def process_large_dataset(self, size):
    # Stream instead of loading all
    for batch in self.fetch_in_batches(size, batch_size=1000):
        yield self.calculate(batch)
```

---

## Further Reading

### Internal Resources
- @.claude/skills/ralph-loop/SKILL.md - Autonomous verification loop
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection

### External Resources
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

## Quick Reference Table

| Concept | Command/Pattern | Expected Result |
|---------|-----------------|-----------------|
| Run failing test | `pytest -k "test_name"` | FAIL (❌) |
| Run passing test | `pytest -k "test_name"` | PASS (✅) |
| Run all tests | `pytest` | ALL PASS |
| Coverage report | `pytest --cov` | 80%+ |
| Type check | `mypy .` or `npx tsc --noEmit` | Clean |
| Mock external API | `@patch('module.function')` | Isolated test |
| Parameterize tests | `@pytest.mark.parametrize` | Multiple cases |

---

**Last Updated**: 2026-01-15
