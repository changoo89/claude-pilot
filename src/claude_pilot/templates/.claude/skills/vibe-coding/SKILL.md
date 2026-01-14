---
name: vibe-coding
description: LLM-readable code standards for maintainable code. Functions ≤50 lines, files ≤200 lines, nesting ≤3 levels. Apply SRP, DRY, KISS, Early Return patterns during refactoring.
---

# SKILL: Vibe Coding (Code Quality Standards)

> **Purpose**: Enforce LLM-readable code standards for maintainable, testable, comprehensible code
> **Target**: Coder Agent during Green/Refactor phases
> **Last Updated**: 2026-01-14
> **References**: @.claude/guides/vibe-coding.md

---

## Quick Start (30 seconds)

### When to Use This Skill
Use this skill when you need to:
- Refactor code after tests pass (Green phase)
- Reduce function complexity
- Improve code readability
- Apply SOLID principles
- Reduce nesting levels

### Quick Reference
```bash
# Check function lines
awk '/^def / {start=NR} /^def / && start {print NR-start}' file.py

# Check file lines
wc -l file.ts

# Check nesting
# Count indentation levels in function body
```

**Targets**:
- Functions ≤50 lines
- Files ≤200 lines
- Nesting ≤3 levels

---

## What This Skill Covers

### In Scope
- Code size limits (functions, files, nesting)
- SRP (Single Responsibility Principle)
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- Early Return pattern
- AI rules for code generation

### Out of Scope
- Test writing → See @.claude/skills/tdd/SKILL.md
- Autonomous iteration → See @.claude/skills/ralph-loop/SKILL.md
- Architecture decisions → See project CLAUDE.md

---

## Core Concepts

### Size Limits

| Target | Limit | Action When Exceeded |
|--------|-------|----------------------|
| **Function** | ≤50 lines | Split functions |
| **File** | ≤200 lines | Extract modules |
| **Nesting** | ≤3 levels | Early return |

### Principles

#### SRP - Single Responsibility Principle
- One function = one responsibility
- Each function should do one thing well
- If a function does multiple things, split it

#### DRY - Don't Repeat Yourself
- No duplicate code blocks
- Extract common logic into reusable functions
- Use parameters to vary behavior instead of copying code

#### KISS - Keep It Simple, Stupid
- Simplest solution that works
- Avoid over-engineering
- Prefer clear code over clever code

#### Early Return Pattern
- Return early to reduce nesting
- Keep happy path at top level
- Avoid deep conditional nesting

---

## Typical Workflows

### Workflow 1: Refactor Large Function

**Prerequisites**:
- Tests passing (Green phase)
- Function >50 lines detected

**Steps**:
1. **Identify large function**
   ```bash
   # Find functions >50 lines
   grep -n "^def " file.py  # Note line numbers
   # Count lines between function definitions
   ```

2. **Analyze responsibilities**
   ```python
   # Before (80 lines, multiple responsibilities)
   def process_user_order(user_id, order_data):
       # 1. Validate user (10 lines)
       # 2. Validate order (15 lines)
       # 3. Calculate pricing (20 lines)
       # 4. Apply discounts (10 lines)
       # 5. Process payment (15 lines)
       # 6. Send confirmation (10 lines)
       pass
   ```

3. **Split into smaller functions**
   ```python
   # After (each function ≤20 lines)
   def process_user_order(user_id, order_data):
       user = validate_user(user_id)
       order = validate_order(order_data)
       pricing = calculate_pricing(order)
       final_price = apply_discounts(pricing, user)
       payment = process_payment(final_price)
       send_confirmation(user, order, payment)
       return payment

   def validate_user(user_id):
       # 10 lines of validation
       pass

   def validate_order(order_data):
       # 15 lines of validation
       pass

   # ... etc
   ```

4. **Verify tests still pass**
   ```bash
   pytest tests/test_order.py  # Must still pass
   ```

**Verification**:
```bash
# All functions ≤50 lines
awk '/^def / {start=NR} /^def / && start {if(NR-start>50) print "Large function"}' file.py

# Tests still pass
pytest
```

### Workflow 2: Reduce Nesting with Early Return

**Prerequisites**:
- Function with deep nesting (>3 levels)
- Tests passing

**Steps**:
1. **Identify deep nesting**
   ```python
   # Before (4 levels deep - violates ≤3)
   def process_order(order):
       if order:
           if order.items:
               if len(order.items) > 0:
                   if order.valid:
                       # Main logic here - 4 levels deep!
                       result = process_valid_order(order)
                       return result
   ```

2. **Apply early returns**
   ```python
   # After (1 level - complies)
   def process_order(order):
       if not order:
           return {error: "No order"}
       if not order.items:
           return {error: "No items"}
       if len(order.items) == 0:
           return {error: "Empty order"}
       if not order.valid:
           return {error: "Invalid order"}

       # Main logic here - at top level!
       return process_valid_order(order)
   ```

3. **Verify tests still pass**
   ```bash
   pytest tests/test_order.py
   ```

**Verification**:
```bash
# Count nesting levels (max 3)
# Check indentation in function body

# Tests pass
pytest
```

### Workflow 3: Extract Duplicate Code

**Prerequisites**:
- Duplicate code detected
- Tests passing for both instances

**Steps**:
1. **Identify duplication**
   ```python
   # File A
   def validate_email(email):
       if not email:
           return False
       if '@' not in email:
           return False
       if '.' not in email.split('@')[1]:
           return False
       return True

   # File B (duplicate!)
   def check_email_format(email):
       if not email:
           return False
       if '@' not in email:
           return False
       if '.' not in email.split('@')[1]:
           return False
       return True
   ```

2. **Extract to shared function**
   ```python
   # shared/validation.py
   def validate_email(email):
       """Validate email format."""
       if not email:
           return False
       if '@' not in email:
           return False
       if '.' not in email.split('@')[1]:
           return False
       return True

   # File A
   from shared.validation import validate_email

   # File B
   from shared.validation import validate_email
   ```

3. **Verify tests still pass**
   ```bash
   pytest tests/test_validation.py
   ```

**Verification**:
```bash
# No duplicate code blocks
# Use code analysis tool or manual review

# Tests pass
pytest
```

---

## Common Patterns

### Pattern 1: Split Large Functions
**Use case**: Function >50 lines, does multiple things

**Implementation**:
```python
# Before (violates ≤50 lines)
def process_user_data(user_data):
    # 80 lines of processing logic
    # Multiple responsibilities
    pass

# After (complies)
def process_user_data(user_data):
    validated = validate_user(user_data)
    enriched = enrich_user_data(validated)
    return format_user_output(enriched)

def validate_user(user):
    # 15 lines of validation logic
    pass

def enrich_user_data(user):
    # 20 lines of enrichment logic
    pass

def format_user_output(user):
    # 10 lines of formatting logic
    pass
```

**Caveats**:
- Each function should have single responsibility
- Name functions to reflect what they do
- Keep functions focused

### Pattern 2: Early Return Pattern
**Use case**: Deep nesting (>3 levels), hard to read

**Implementation**:
```typescript
// Before (violates ≤3 nesting levels)
function processOrder(order: Order): Result {
  if (order) {
    if (order.items) {
      if (order.items.length > 0) {
        if (order.valid) {
          // Main logic here - 4 levels deep!
        }
      }
    }
  }
}

// After (complies)
function processOrder(order: Order): Result {
  if (!order) return { error: "No order" };
  if (!order.items) return { error: "No items" };
  if (order.items.length === 0) return { error: "Empty order" };
  if (!order.valid) return { error: "Invalid order" };

  // Main logic here - at top level!
  return processValidOrder(order);
}
```

**Caveats**:
- Return early for error conditions
- Keep happy path at top level
- Reduce cognitive load

### Pattern 3: DRY with Parameters
**Use case**: Similar code with small variations

**Implementation**:
```python
# Before (duplicated)
def get_users_active():
    query = "SELECT * FROM users WHERE status = 'active'"
    return db.execute(query)

def get_users_inactive():
    query = "SELECT * FROM users WHERE status = 'inactive'"
    return db.execute(query)

# After (DRY)
def get_users_by_status(status):
    query = f"SELECT * FROM users WHERE status = '{status}'"
    return db.execute(query)

# Usage
active_users = get_users_by_status('active')
inactive_users = get_users_by_status('inactive')
```

**Caveats**:
- Use parameters to vary behavior
- Don't copy-paste code
- Extract common patterns

---

## AI Rules for Code Generation

| Rule | Description |
|------|-------------|
| **Small increments** | Generate code in small chunks, test immediately |
| **Test immediately** | Never trust blindly - run tests after each change |
| **Edge cases** | Always consider and handle edge cases |
| **Consistent naming** | Use clear, consistent naming conventions |
| **No secrets** | Never hardcode secrets, use environment variables |

### Micro-Cycle Compliance

**After EVERY Edit/Write tool call, you MUST run tests immediately.**

```
1. Edit/Write code
2. Run tests
3. Analyze results
4. Fix failures
5. Repeat
```

---

## Enforcement Checklist

When generating or reviewing code, verify:

### Size Limits
- [ ] Functions ≤50 lines
- [ ] Files ≤200 lines
- [ ] Nesting ≤3 levels

### Principles
- [ ] **SRP**: One function = one responsibility?
- [ ] **DRY**: No duplicate code blocks?
- [ ] **KISS**: Simplest solution that works?
- [ ] **Early Return**: Reduced nesting?

### AI Rules
- [ ] Small increments (generate in chunks)
- [ ] Test immediately (don't batch changes)
- [ ] Edge cases handled
- [ ] Consistent naming
- [ ] No secrets hardcoded

---

## Troubleshooting

### Issue: Function can't be split (tightly coupled)
**Symptoms**: Can't extract function without breaking everything

**Diagnosis**:
```bash
# Check for shared state
grep -n "self\." file.py

# Check for global variables
grep -n "^global" file.py
```

**Solution**:
- Introduce parameter objects
- Extract dependencies
- Consider class refactoring
- Break into smaller steps

### Issue: Early return creates duplicate logic
**Symptoms**: Same code repeated in multiple return branches

**Diagnosis**:
```python
# Before early return (nested)
if condition:
    if other_condition:
        # Main logic
    else:
        # Alternative logic
else:
    # Alternative logic (duplicate!)
```

**Solution**:
```python
# Extract common logic
def process_alternative(data):
    """Common alternative logic."""
    pass

def main_function(data):
    if not condition:
        return process_alternative(data)
    if not other_condition:
        return process_alternative(data)
    # Main logic
```

### Issue: File can't be split (circular dependencies)
**Symptoms**: Extracting module creates circular imports

**Diagnosis**:
```bash
# Check import graph
# Module A imports B, B imports A
python -c "import module_a; import module_b"
```

**Solution**:
- Extract to third module
- Introduce interface/protocol
- Reorganize module structure
- Consider dependency injection

---

## Best Practices

### Do's ✅
- Apply Vibe Coding during refactor phase (after Green)
- Split functions >50 lines
- Use early return to reduce nesting
- Extract duplicate code
- Keep functions focused (SRP)
- Test after each refactor

### Don'ts ❌
- Don't apply during Red phase (tests first)
- Don't over-engineer simple solutions
- Don't split functions unnecessarily
- Don't optimize prematurely
- Don't refactor without tests

---

## Integration with Other Skills

### Related Skills
- **tdd**: Write tests first, refactor with Vibe Coding
- **ralph-loop**: Verify quality after refactoring
- **git-master**: Commit clean, refactored code

### Call Patterns
```
tdd (Red-Green-Refactor)
     ↓
[Green phase - minimal code]
     ↓
vibe-coding (Refactor with standards)
     ↓
ralph-loop (Verify all tests pass)
     ↓
git-master (Commit clean code)
```

---

## Quick Reference

| Check | Command/Method |
|-------|----------------|
| Function lines | Count lines in function body |
| File lines | `wc -l file.ts` |
| Nesting levels | Count indentation in function |

---

## Further Reading

### Internal Documentation
- @.claude/guides/vibe-coding.md - Full Vibe Coding guide
- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/ralph-loop.md - Autonomous completion loop

### External Resources
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Refactoring by Martin Fowler](https://www.amazon.com/Refactoring-Improving-Existing-Addison-Wesley-Signature/dp/0201485672)

---

## FAQ

### Q: Why these specific limits (50, 200, 3)?
**A**: Based on research and experience:
- **50 lines**: Fits on screen, easy to understand
- **200 lines**: Manageable cognitive load
- **3 levels**: Beyond this, comprehension drops significantly

### Q: Can I exceed limits for good reason?
**A**: Generally no. If you must:
- Document why (e.g., generated code)
- Consider extraction instead
- Revisit later - usually there's a better way

### Q: When should I apply Vibe Coding?
**A**: During **Refactor phase** (after Green):
1. Write test (Red)
2. Make test pass (Green) - don't worry about quality
3. Apply Vibe Coding (Refactor) - now clean up

### Q: What if splitting makes code harder to read?
**A**: You might be over-splitting. Consider:
- Do the pieces belong together? (cohesion)
- Are you adding indirection without benefit?
- Would a larger function be clearer?
