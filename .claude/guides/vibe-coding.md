# Vibe Coding Guide

## Purpose

Vibe Coding defines LLM-readable code standards that ensure code remains maintainable, testable, and comprehensible for both humans and AI systems. This guide explains the standards and how to enforce them during code generation.

## Core Standards

| Target | Limit | Action |
|--------|-------|--------|
| **Function** | ≤50 lines | Split functions |
| **Class/File** | ≤200 lines | Extract modules |
| **Nesting** | ≤3 levels | Early return |

## Principles

### SRP - Single Responsibility Principle
- One function = one responsibility
- Each function should do one thing well
- If a function does multiple things, split it

### DRY - Don't Repeat Yourself
- No duplicate code blocks
- Extract common logic into reusable functions
- Use parameters to vary behavior instead of copying code

### KISS - Keep It Simple, Stupid
- Simplest solution that works
- Avoid over-engineering
- Prefer clear code over clever code

### Early Return Pattern
- Return early to reduce nesting
- Keep happy path at the top level
- Avoid deep conditional nesting

## AI Rules for Code Generation

| Rule | Description |
|------|-------------|
| **Small increments** | Generate code in small chunks, test immediately |
| **Test immediately** | Never trust blindly - run tests after each change |
| **Edge cases** | Always consider and handle edge cases |
| **Consistent naming** | Use clear, consistent naming conventions |
| **No secrets** | Never hardcode secrets, use environment variables |

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

## Common Refactoring Patterns

### Split Large Functions

**Before** (violates ≤50 lines):
```typescript
function processUserData(userData: User): ProcessedUser {
  // 80 lines of processing logic
  // Multiple responsibilities
}
```

**After** (complies):
```typescript
function processUserData(userData: User): ProcessedUser {
  const validated = validateUser(userData);
  const enriched = enrichUserData(validated);
  return formatUserOutput(enriched);
}

function validateUser(user: User): User {
  // 15 lines of validation logic
}

function enrichUserData(user: User): EnrichedUser {
  // 20 lines of enrichment logic
}

function formatUserOutput(user: EnrichedUser): ProcessedUser {
  // 10 lines of formatting logic
}
```

### Early Return Pattern

**Before** (violates ≤3 nesting levels):
```typescript
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
```

**After** (complies):
```typescript
function processOrder(order: Order): Result {
  if (!order) return { error: "No order" };
  if (!order.items) return { error: "No items" };
  if (order.items.length === 0) return { error: "Empty order" };
  if (!order.valid) return { error: "Invalid order" };

  // Main logic here - at top level!
  return processValidOrder(order);
}
```

## When to Apply Vibe Coding

### During Planning
- Verify plan mentions splitting large functions
- Check plan respects module boundaries
- Confirm early return pattern is specified

### During Code Generation
- Enforce limits while writing code
- Apply principles automatically
- Generate in small increments

### During Review
- Check all size limits
- Verify all principles applied
- Ensure AI rules followed

## Integration with Other Methodologies

### TDD
- Write test first (Red phase)
- Implement minimal code to pass (Green phase)
- Apply Vibe Coding during refactor phase

### Ralph Loop
- Vibe Coding violations trigger iteration
- Continue until all standards met
- Output `<RALPH_COMPLETE>` only when compliant

## Quick Reference

| Check | Command/Method |
|-------|----------------|
| Function lines | Count lines in function body |
| File lines | `wc -l file.ts` |
| Nesting levels | Count indentation in function |

## See Also

- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/ralph-loop.md - Autonomous completion loop
