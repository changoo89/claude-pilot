# Vibe Coding Reference Guide

> **Purpose**: Detailed reference for code quality standards and maintainability patterns
> **Complements**: @./SKILL.md (core standards)

---

## SOLID Principles Quick Reference

**S - Single Responsibility Principle (SRP)**: A class or function should have one, and only one, reason to change.

**O - Open/Closed Principle (OCP)**: Software entities should be open for extension, closed for modification.

**L - Liskov Substitution Principle (LSP)**: Subtypes must be substitutable for their base types.

**I - Interface Segregation Principle (ISP)**: Clients should not depend on interfaces they don't use.

**D - Dependency Inversion Principle (DIP)**: Depend on abstractions, not concretions.

**Further Reading**: [SOLID Principles Guide](https://en.wikipedia.org/wiki/SOLID) | [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

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

# ✅ GOOD: Single abstraction level
def process_order(order):
    """High-level orchestration of order processing."""
    validated_order = validate_order(order)
    pricing = calculate_pricing(validated_order)
    saved_order = save_order_to_database(pricing)
    send_confirmation(saved_order)
    return saved_order
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
# Before: One long function (100+ lines)
def generate_report(data):
    # 50 lines of data processing
    processed = []
    for item in data:
        if item["status"] == "active":
            processed.append({"id": item["id"], "value": item["value"] * 1.1})

    # 30 lines of formatting
    output = [f"{item['id']}: {item['value']:.2f}" for item in processed]

    # 20 lines of writing
    with open("report.txt", "w") as f:
        f.write("\n".join(output))

# After: Extracted methods (each ≤20 lines)
def generate_report(data):
    processed = process_data(data)
    formatted = format_output(processed)
    write_report(formatted)
    return formatted

def process_data(data):
    return [{"id": i["id"], "value": i["value"] * 1.1}
            for i in data if i["status"] == "active"]

def format_output(processed):
    return [f"{item['id']}: {item['value']:.2f}" for item in processed]

def write_report(formatted):
    with open("report.txt", "w") as f:
        f.write("\n".join(formatted))
```

---

## Code Smells and Solutions

| Code Smell | Problem | Solution |
|------------|---------|----------|
| **Long Parameter List** | Function has 5+ parameters, hard to use | Create parameter object or config class |
| **Divergent Change** | One class changes for multiple reasons | Separate classes for separate concerns (SRP) |
| **Shotgun Surgery** | One change requires modifying multiple files | Use polymorphism, consolidate related changes |
| **Duplicate Code** | Same code blocks in multiple places | Extract function or create shared module |
| **Large Class** | Class has too many responsibilities | Extract classes, apply SRP |
| **Long Method** | Function >50 lines, hard to understand | Extract methods, apply Single Abstraction Level |

---

## Early Return Pattern

**When**: Reduce nesting by returning early on validation failures

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

---

## Measuring Code Quality

### Cyclomatic Complexity

**Definition**: Number of independent paths through code

**Target**: ≤10 per function (≤5 ideal)

**High complexity symptoms**:
- Too many if/elif/else branches
- Deeply nested conditionals
- Long switch/case statements

**Solution**: Break down into smaller functions, use polymorphism for complex conditionals

**Tool**: `radon cc -s <file>` (Python) | `complexity-report` (JavaScript)

### Maintainability Index

**Formula**: `MI = 171 - 5.2 * ln(HV) - 0.23 * CC - 16.2 * ln(LOC)`

**Interpretation**:
- 85-100: Highly maintainable
- 65-85: Moderately maintainable
- <65: Difficult to maintain

**Tool**: `radon mi <file>` (Python) | `plato` (JavaScript)

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
- [SOLID Principles Guide](https://en.wikipedia.org/wiki/SOLID)

---

**Last Updated**: 2026-01-22
