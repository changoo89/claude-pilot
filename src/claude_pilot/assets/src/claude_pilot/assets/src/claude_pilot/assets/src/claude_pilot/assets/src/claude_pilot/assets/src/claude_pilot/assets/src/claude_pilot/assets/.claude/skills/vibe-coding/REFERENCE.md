# Vibe Coding Reference Guide

> **Purpose**: Detailed reference for code quality standards and maintainability patterns
> **Complements**: @./SKILL.md (core standards)

---

## SOLID Principles Deep Dive

### S - Single Responsibility Principle (SRP)

**Definition**: A class or function should have one, and only one, reason to change.

```python
# ❌ VIOLATION: Function does multiple things
def process_user_order(user_id, order_data):
    # 1. Validate user (10 lines)
    user = db.find_user(user_id)
    if not user:
        raise Error("User not found")

    # 2. Validate order (15 lines)
    if not order_data.get("items"):
        raise Error("No items")
    for item in order_data["items"]:
        if not item.get("price"):
            raise Error("Invalid item")

    # 3. Calculate pricing (20 lines)
    subtotal = sum(item["price"] for item in order_data["items"])
    tax = subtotal * 0.1
    total = subtotal + tax

    # 4. Apply discounts (10 lines)
    if user.is_premium:
        total *= 0.9

    # 5. Process payment (15 lines)
    payment = payment_service.charge(user.payment_method, total)

    # 6. Send confirmation (10 lines)
    email_service.send_order_confirmation(user.email, order_data)

    return payment
# Total: 80+ lines, 6 responsibilities

# ✅ CORRECT: One responsibility per function
def process_user_order(user_id, order_data):
    user = validate_user(user_id)
    order = validate_order(order_data)
    pricing = calculate_pricing(order)
    final_price = apply_discounts(pricing, user)
    payment = process_payment(final_price)
    send_confirmation(user, order, payment)
    return payment
# 8 lines, orchestrates other functions

def validate_user(user_id):
    user = db.find_user(user_id)
    if not user:
        raise Error("User not found")
    return user
# 5 lines, one responsibility

def validate_order(order_data):
    if not order_data.get("items"):
        raise Error("No items")
    for item in order_data["items"]:
        if not item.get("price"):
            raise Error("Invalid item")
    return order_data
# 7 lines, one responsibility

# ... other single-purpose functions
```

### O - Open/Closed Principle (OCP)

**Definition**: Software entities should be open for extension, closed for modification.

```typescript
// ❌ VIOLATION: Must modify to add new discount types
function calculateDiscount(price: number, customerType: string): number {
    if (customerType === "premium") {
        return price * 0.9;
    } else if (customerType === "vip") {
        return price * 0.8;
    } else if (customerType === "employee") {
        return price * 0.7;
    }
    // Adding new type requires modifying this function
    return price;
}

// ✅ CORRECT: Open for extension, closed for modification
interface DiscountStrategy {
    apply(price: number): number;
}

class PremiumDiscount implements DiscountStrategy {
    apply(price: number): number { return price * 0.9; }
}

class VipDiscount implements DiscountStrategy {
    apply(price: number): number { return price * 0.8; }
}

class EmployeeDiscount implements DiscountStrategy {
    apply(price: number): number { return price * 0.7; }
}

// Add new discounts by creating new classes, not modifying existing code
class NewCustomerDiscount implements DiscountStrategy {
    apply(price: number): number { return price * 0.95; }
}

function calculateDiscount(price: number, strategy: DiscountStrategy): number {
    return strategy.apply(price);
}
```

### L - Liskov Substitution Principle (LSP)

**Definition**: Subtypes must be substitutable for their base types.

```python
# ❌ VIOLATION: Subtype changes behavior unexpectedly
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def set_width(self, width):
        self.width = width

    def set_height(self, height):
        self.height = height

    def area(self):
        return self.width * self.height

class Square(Rectangle):
    def set_width(self, width):
        self.width = width
        self.height = width  # Violates LSP!

    def set_height(self, height):
        self.height = height
        self.width = height  # Violates LSP!

# Substituting Square for Rectangle breaks things
def process_rectangle(rect):
    rect.set_width(10)
    rect.set_height(20)
    assert rect.area() == 200  # Fails for Square!

# ✅ CORRECT: Separate classes, no inheritance misuse
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

class Square:
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side * self.side
```

### I - Interface Segregation Principle (ISP)

**Definition**: Clients should not depend on interfaces they don't use.

```typescript
// ❌ VIOLATION: Fat interface, clients depend on unused methods
interface User {
    name: string;
    email: string;
    save(): void;
    sendEmail(): void;
    delete(): void;
    auditLog(): void;
}

class EmailSender {
    // Only needs email, but depends on entire User interface
    sendWelcomeEmail(user: User): void {
        user.sendEmail();
    }
}

// ✅ CORRECT: Segregated interfaces
interface UserData {
    name: string;
    email: string;
}

interface Persistable {
    save(): void;
    delete(): void;
}

interface EmailCapable {
    sendEmail(): void;
}

interface Auditable {
    auditLog(): void;
}

// Clients depend only on what they need
class EmailSender {
    sendWelcomeEmail(user: EmailCapable): void {
        user.sendEmail();
    }
}
```

### D - Dependency Inversion Principle (DIP)

**Definition**: Depend on abstractions, not concretions.

```python
# ❌ VIOLATION: High-level module depends on low-level details
class OrderProcessor:
    def __init__(self):
        # Hardcoded dependency on concrete implementation
        self.database = PostgreSQLDatabase()

    def process(self, order):
        self.database.save(order)

# ✅ CORRECT: Depend on abstraction
class OrderProcessor:
    def __init__(self, db: Database):  # Abstract interface
        self.database = db

    def process(self, order):
        self.database.save(order)

# Easy to swap implementations
processor = OrderProcessor(MongoDatabase())  # Works!
processor = OrderProcessor(PostgreSQLDatabase())  # Works!
```

---

## Missing VIBE Principles

### Self-Documenting Code

**Definition**: Code should reveal its intent through clear naming and structure, minimizing the need for comments.

```python
# ❌ POOR: Unclear naming, requires comments
def proc(d, l):
    # Process data with limit
    r = []
    for x in d:
        if x > l:
            r.append(x * 2)
    return r

# ✅ GOOD: Self-documenting names, no comments needed
def filter_and_double_values(data, minimum_value):
    """Filter values above minimum and double them."""
    return [value * 2 for value in data if value > minimum_value]
```

**Guidelines**:
- **Variables**: `user_input` not `d`, `max_retries` not `n`
- **Functions**: `calculate_total_price` not `calc`, `send_email_notification` not `notify`
- **Booleans**: `is_active`, `has_permission`, `can_process` (prefix with is/has/can)
- **Collections**: `users`, `user_list`, `active_users` (plural names)

### Single Abstraction Level

**Definition**: Functions should operate at one conceptual level, mixing high-level strategy with low-level details.

```python
# ❌ POOR: Mixed abstraction levels
def process_order(order):
    # High-level: Validate order
    if not order.items:
        raise ValueError("No items")

    # Low-level: Parse JSON
    import json
    items = json.loads(order.items_json)

    # High-level: Calculate pricing
    total = sum(item["price"] for item in items)

    # Low-level: Database connection
    import psycopg2
    conn = psycopg2.connect("...")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO orders ...")

    # Mixed levels make code hard to understand

# ✅ GOOD: Single abstraction level
def process_order(order):
    """High-level orchestration of order processing."""
    validated_order = validate_order(order)
    pricing = calculate_pricing(validated_order)
    saved_order = save_order_to_database(pricing)
    send_confirmation(saved_order)
    return saved_order

def save_order_to_database(order):
    """Low-level database operation (separate function)."""
    import psycopg2
    conn = psycopg2.connect("...")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO orders ...")
```

**Guidelines**:
- **High-level functions**: Orchestrate other functions, reveal business logic
- **Low-level functions**: Handle implementation details (database, JSON, HTTP)
- **Rule**: One function should not mix "what" (business logic) with "how" (implementation)

### Principle of Least Surprise (POLS)

**Definition**: Code should behave predictably, following conventions and avoiding hidden side effects.

```python
# ❌ VIOLATION: Hidden side effects, surprising behavior
def get_user(user_id):
    user = db.find_user(user_id)
    # SURPRISE: Also logs to file (hidden side effect)
    logger.info(f"User accessed: {user_id}")
    # SURPRISE: Updates last_accessed timestamp (mutation)
    user.last_accessed = datetime.now()
    db.save(user)
    return user

# ✅ GOOD: Predictable, no surprises
def get_user(user_id):
    """Get user by ID (no side effects)."""
    return db.find_user(user_id)

def log_user_access(user_id):
    """Log user access (explicit function)."""
    logger.info(f"User accessed: {user_id}")

def update_last_accessed(user):
    """Update last accessed timestamp (explicit function)."""
    user.last_accessed = datetime.now()
    db.save(user)
```

**Guidelines**:
- **No hidden mutations**: Functions should not modify arguments unless obvious from name
- **No hidden side effects**: Logging, I/O, network calls should be explicit
- **Follow conventions**: `get_xxx` returns data, `set_xxx` modifies data, `is_xxx` returns bool
- **Consistent naming**: Similar operations have similar names

---

## Refactoring Patterns

### Extract Method Pattern

**When**: Function is too long or does multiple things

```python
# Before: One long function
def generate_report(data):
    # 50 lines of data processing
    processed = []
    for item in data:
        if item["status"] == "active":
            processed.append({
                "id": item["id"],
                "value": item["value"] * 1.1
            })

    # 30 lines of formatting
    output = []
    for item in processed:
        output.append(f"{item['id']}: {item['value']:.2f}")

    # 20 lines of writing
    with open("report.txt", "w") as f:
        f.write("\n".join(output))
    # Total: 100+ lines

# After: Extracted methods
def generate_report(data):
    processed = process_data(data)
    formatted = format_output(processed)
    write_report(formatted)
    return formatted

def process_data(data):
    """Process raw data, apply business logic."""
    processed = []
    for item in data:
        if item["status"] == "active":
            processed.append({
                "id": item["id"],
                "value": item["value"] * 1.1
            })
    return processed

def format_output(processed):
    """Format processed data for output."""
    return [f"{item['id']}: {item['value']:.2f}" for item in processed]

def write_report(formatted):
    """Write formatted data to file."""
    with open("report.txt", "w") as f:
        f.write("\n".join(formatted))
# Each function ≤20 lines, single responsibility
```

### Extract Class Pattern

**When**: Class does too many things or has too many responsibilities

```python
# Before: God class doing everything
class User:
    def __init__(self, username, email, password):
        self.username = username
        self.email = email
        self.password_hash = self._hash_password(password)

    def _hash_password(self, password):
        # 15 lines of hashing logic
        pass

    def validate_password(self, password):
        # 10 lines of validation
        pass

    def send_welcome_email(self):
        # 20 lines of email logic
        pass

    def save_to_database(self):
        # 15 lines of database logic
        pass

    def to_json(self):
        # 10 lines of serialization
        pass

# After: Separated concerns
class User:
    def __init__(self, username, email, password_hash):
        self.username = username
        self.email = email
        self.password_hash = password_hash

    def to_json(self):
        return {
            "username": self.username,
            "email": self.email
        }

class PasswordService:
    def hash_password(self, password):
        # Hashing logic
        pass

    def validate_password(self, password, hash):
        # Validation logic
        pass

class EmailService:
    def send_welcome_email(self, user):
        # Email logic
        pass

class UserRepository:
    def save(self, user):
        # Database logic
        pass
```

### Replace Conditional with Polymorphism

**When**: Complex conditional logic based on type

```python
# Before: Complex conditionals
def calculate_salary(employee):
    if employee.type == "full_time":
        base = employee.monthly_salary
        bonus = base * 0.1
        return base + bonus
    elif employee.type == "part_time":
        return employee.hourly_rate * employee.hours_worked
    elif employee.type == "contractor":
        return employee.hourly_rate * employee.hours_worked * 1.2
    elif employee.type == "intern":
        return employee.stipend
    # Adding new type requires modifying this function

# After: Polymorphic
from abc import ABC, abstractmethod

class Employee(ABC):
    @abstractmethod
    def calculate_salary(self):
        pass

class FullTimeEmployee(Employee):
    def calculate_salary(self):
        base = self.monthly_salary
        bonus = base * 0.1
        return base + bonus

class PartTimeEmployee(Employee):
    def calculate_salary(self):
        return self.hourly_rate * self.hours_worked

class Contractor(Employee):
    def calculate_salary(self):
        return self.hourly_rate * self.hours_worked * 1.2

class Intern(Employee):
    def calculate_salary(self):
        return self.stipend

# Usage: simple and extensible
salary = employee.calculate_salary()
```

---

## Code Smells and Solutions

### Long Parameter List

**Problem**: Function has too many parameters (hard to use, error-prone)

```python
# ❌ CODE SMELL
def create_user(username, email, password, first_name, last_name,
                age, country, phone, newsletter_subscribed):
    # 20+ lines
    pass

# ✅ SOLUTION: Parameter object
class UserData:
    def __init__(self, username, email, password, first_name, last_name,
                 age, country, phone, newsletter_subscribed):
        self.username = username
        self.email = email
        # ... etc

def create_user(user_data: UserData):
    # Clean, single parameter
    pass
```

### Divergent Change

**Problem**: One class/file changes for multiple reasons

```python
# ❌ CODE SMELL: User class changes for auth, database, validation
class User:
    def save_to_db(self): pass
    def validate_email(self): pass
    def hash_password(self): pass
    def send_notification(self): pass
    def calculate_discount(self): pass

# ✅ SOLUTION: Separate classes for separate concerns
class User:
    def __init__(self, username, email):
        self.username = username
        self.email = email

class UserRepository:
    def save(self, user): pass

class EmailValidator:
    def validate(self, email): pass

class PasswordService:
    def hash(self, password): pass
```

### Shotgun Surgery

**Problem**: One change requires modifying multiple files

```python
# ❌ CODE SMELL: Adding user type requires changes everywhere
# user.py
def process_user(user):
    if user.type == "premium":
        # logic
        pass

# order.py
def process_order(order):
    if order.user.type == "premium":
        # logic
        pass

# discount.py
def calculate_discount(user):
    if user.type == "premium":
        # logic
        pass

# ✅ SOLUTION: Use polymorphism
class User(ABC):
    @abstractmethod
    def get_discount(self): pass

class PremiumUser(User):
    def get_discount(self):
        return 0.1

class RegularUser(User):
    def get_discount(self):
        return 0.0

# Changes now localized to one place
```

---

## Advanced Early Return Patterns

### Guard Clauses for Validation

```python
# ❌ DEEP NESTING: Hard to read
def process_payment(user, amount):
    if user:
        if user.is_active:
            if amount > 0:
                if user.balance >= amount:
                    # Main logic here, 4 levels deep!
                    user.balance -= amount
                    return True
                else:
                    return False
            else:
                return False
        else:
            return False
    else:
        return False

# ✅ EARLY RETURN: Happy path at top level
def process_payment(user, amount):
    if not user:
        return {"error": "No user provided"}
    if not user.is_active:
        return {"error": "User not active"}
    if amount <= 0:
        return {"error": "Invalid amount"}
    if user.balance < amount:
        return {"error": "Insufficient funds"}

    # Main logic here, at top level!
    user.balance -= amount
    return {"success": True, "new_balance": user.balance}
```

### Fail Fast Principle

```python
def process_order(order):
    # Validate all preconditions first
    if not order:
        raise ValueError("Order cannot be None")

    if not order.items:
        raise ValueError("Order must have items")

    if not order.shipping_address:
        raise ValueError("Order must have shipping address")

    if not order.payment_method:
        raise ValueError("Order must have payment method")

    # All validations passed, safe to proceed
    return _fulfill_order(order)

def _fulfill_order(order):
    # Complex fulfillment logic, safe because preconditions validated
    inventory.reserve_items(order.items)
    payment.charge(order.payment_method, order.total)
    shipping.schedule_delivery(order.shipping_address)
    return OrderStatus.PROCESSING
```

---

## Measuring Code Quality

### Cyclomatic Complexity

**Definition**: Number of independent paths through code

```python
# Complexity = 1 (baseline)
def simple_function(x):
    return x * 2

# Complexity = 3 (1 + 2 conditions)
def medium_function(x):
    if x > 0:        # +1
        return x * 2
    elif x < 0:      # +1
        return x * -2
    return 0

# Complexity = 8 (1 + 7 conditions) - TOO HIGH!
def complex_function(x, y, z):
    if x > 0:                # +1
        if y > 0:            # +1
            if z > 0:        # +1
                return x + y + z
            else:            # +1
                return x + y
        else:                # +1
            return x
    elif x < 0:              # +1
        if y > 0:            # +1
            return y
    return 0                  # +1

# ✅ SOLUTION: Break down into smaller functions
def complex_function_refactored(x, y, z):
    if x > 0:
        return _handle_positive(x, y, z)
    elif x < 0:
        return _handle_negative(x, y)
    return 0

def _handle_positive(x, y, z):
    if y > 0:
        return _calculate_sum(x, y, z)
    return x

def _calculate_sum(x, y, z):
    return x + y + z if z > 0 else x + y

def _handle_negative(x, y):
    return y if y > 0 else x
```

### Maintainability Index

**Formula**: `MI = 171 - 5.2 * ln(HV) - 0.23 * CC - 16.2 * ln(LOC)`

Where:
- HV = Halstead Volume (complexity of operators/operands)
- CC = Cyclomatic Complexity
- LOC = Lines of Code

**Interpretation**:
- 85-100: Highly maintainable
- 65-85: Moderately maintainable
- <65: Difficult to maintain

---

## Language-Specific Patterns

### TypeScript Patterns

```typescript
// ✅ Use union types for early returns
type Result<T> =
    | { success: true; data: T }
    | { success: false; error: string };

function processUser(user: User): Result<string> {
    if (!user.email) {
        return { success: false, error: "No email" };
    }
    if (!user.isValid()) {
        return { success: false, error: "Invalid user" };
    }

    return { success: true, data: user.email };
}

// ✅ Use type guards
function isError(result: Result<any>): result is { success: false; error: string } {
    return !result.success;
}

// Usage
const result = processUser(user);
if (isError(result)) {
    console.error(result.error);
} else {
    console.log(result.data);
}
```

### Python Patterns

```python
# ✅ Use dataclasses for clean data structures
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    username: str
    email: str
    age: Optional[int] = None

    def is_adult(self) -> bool:
        return self.age is not None and self.age >= 18

# ✅ Use context managers for resource management
from contextlib import contextmanager

@contextmanager
def database_transaction():
    transaction = db.begin()
    try:
        yield transaction
        transaction.commit()
    except Exception:
        transaction.rollback()
        raise

# Usage
with database_transaction() as tx:
    user.save()
    order.save()
    # Both committed or both rolled back
```

---

## Quick Reference Checklist

### Before Committing Code

- [ ] All functions ≤50 lines
- [ ] All files ≤200 lines
- [ ] Nesting ≤3 levels everywhere
- [ ] No duplicate code blocks (DRY)
- [ ] Each function has one responsibility (SRP)
- [ ] No deep nesting (use early returns)
- [ ] Complex logic extracted to named functions
- [ ] Magic numbers replaced with constants
- [ ] Consistent naming conventions
- [ ] No hardcoded secrets

### Refactoring Triggers

| Symptom | Action |
|---------|--------|
| Function >50 lines | Extract methods |
| File >200 lines | Extract module |
| Nesting >3 levels | Early return |
| Duplicate code | Extract function |
| Long parameter list | Parameter object |
| Complex conditionals | Polymorphism |
| Hard to test | Break dependencies |
| Hard to name | Split responsibility |

---

## Further Reading

### Internal Resources
- @.claude/skills/tdd/SKILL.md - Test-Driven Development
- @.claude/skills/ralph-loop/SKILL.md - Quality verification loop

### External Resources
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Refactoring by Martin Fowler](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesley-Signature/dp/0201485672)

---

**Last Updated**: 2026-01-15
