# TDD Reference Guide

> **Purpose**: Detailed reference for Test-Driven Development methodology
> **Complements**: @./SKILL.md (core methodology)

---

## Advanced TDD Concepts

### Test Triangle Strategy

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

### Test Coverage Strategy

| Coverage Type | Target | When to Apply |
|---------------|--------|---------------|
| **Line Coverage** | 80% overall | Baseline for all code |
| **Branch Coverage** | 70%+ | Code with conditionals |
| **Path Coverage** | 60%+ | Complex algorithms |
| **Mutation Coverage** | 50%+ | Critical systems |

**What NOT to Test**: Generated code, third-party libraries, simple getters/setters, trivial one-liners

---

## Red-Green-Refactor Deep Dive

### Red Phase: Interface-First Design

```python
# Write test FIRST to design the interface
def test_user_repository_can_save_user():
    repo = UserRepository()
    user = User(email="test@example.com", name="Test")
    repo.save(user)

    saved = repo.find_by_email("test@example.com")
    assert saved.email == "test@example.com"
```

**Common Edge Cases**: Empty inputs, Null/None values, Boundary conditions (0, -1, MAX_INT), Duplicate keys, Concurrent access

### Green Phase: Fake It Pattern

```python
# First iteration: Return literal
def calculate_total(items):
    return 100.00  # Just enough to pass

# Second iteration: Add real logic
def calculate_total(items):
    return sum(item.price for item in items)
```

### Refactor Phase: Extract Method

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

def calculate_order_total(order):
    return {"total": sum(item.price for item in order.items)}
```

### Parameterize Tests

```python
# Instead of duplicate tests, use parameterization
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-2, -3, -5),
    (2, -3, -1),
    (0, 0, 0),
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
    assert response.json()["email"] == "test@example.com"

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
    if db.find_user_by_email(user_data.email):
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

# 2. GREEN: Create migration file
class Migration001CreateUsersTable(BaseMigration):
    def up(self):
        sql = """
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL
        )
        """
        db.execute(sql)

    def down(self):
        db.execute("DROP TABLE users IF EXISTS")
```

### Async/Await TDD

```python
@pytest.mark.asyncio
async def test_async_fetch_user():
    user = await user_service.fetch_user(123)
    assert user.id == 123

async def fetch_user(self, user_id):
    return await self.db.query(
        "SELECT * FROM users WHERE id = $1", user_id
    )
```

---

## Testing Anti-Patterns to Avoid

### ❌ Testing Implementation Details
```python
# BAD: assert user._email_storage == []  # Internal structure
# GOOD: assert user.email == "test@example.com"  # Behavior
```

### ❌ Brittle Test Data
```python
# BAD: order.add_item(Item("Widget", 19.99))  # Hardcoded
# GOOD: OrderBuilder.with_items(2).of_price(25.00).build()  # Flexible
```

### ❌ Multiple Unrelated Assertions
```python
# BAD: One test asserts email, db count, and email service (3 concerns)
# GOOD: Split into 3 tests - test_sets_email, test_persists_to_db, test_sends_email
```

---

## Test Doubles Reference

| Type | Purpose | Example |
|------|---------|---------|
| **Mock** | Verify interactions | `mock_api.assert_called_with(endpoint)` |
| **Stub** | Provide test inputs | `stub_user = StubUser(id=1, name="Test")` |
| **Fake** | Working implementation | `InMemoryUserRepository()` |
| **Spy** | Record calls | `spy_logger = SpyLogger()` |

```python
# MOCK: Verify API calls
@patch('requests.post')
def test_sends_notification(mock_post):
    notifier.send_alert("System down")
    mock_post.assert_called_with("https://slack.com/api", json={"text": "System down"})

# FAKE: In-memory database
class InMemoryUserRepository:
    def __init__(self):
        self.users = {}
    def save(self, user):
        self.users[user.id] = user

# SPY: Record calls
class SpyEmailService:
    def __init__(self):
        self.calls = []
    def send_welcome(self, email):
        self.calls.append(("welcome", email))
```

---

## Performance Testing with TDD

```python
# RED: Performance requirement
def test_api_response_under_200ms():
    start = time.time()
    api.process_large_dataset(10000)
    assert (time.time() - start) * 1000 < 200

# GREEN → REFACTOR: Optimize with streaming
def process_large_dataset(self, size):
    for batch in self.fetch_in_batches(size, batch_size=1000):
        yield self.calculate(batch)
```

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

## Further Reading

### Internal Resources
- @.claude/skills/ralph-loop/SKILL.md - Autonomous verification loop
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards

### External Resources
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Last Updated**: 2026-01-22
