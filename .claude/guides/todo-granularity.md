# Todo Granularity Guidelines

> **Last Updated**: 2026-01-18
> **Purpose**: Ensure todos are granular enough for reliable agent continuation (Sisyphus system)
> **Status**: Active Standard

---

## Overview

Granular todos are the foundation of reliable agent continuation. When todos are small, atomic, and clearly owned, agents can complete them reliably without stopping prematurely.

**Philosophy**: "The boulder never stops" - todos broken into small chunks that agents can complete in 15 minutes or less.

**Key Benefits**:
- Higher completion rates (agents finish before stopping)
- Better continuation (clear progress checkpoints)
- Easier debugging (small, isolated changes)
- Faster iteration (quick feedback loops)

---

## The Three Rules of Granular Todos

### Rule 1: Time Rule (≤15 Minutes)

**Every todo must be completable in 15 minutes or less.**

**Rationale**: Agents often stop after completing one significant unit of work. If a todo takes 30+ minutes, the agent may stop halfway through.

**Estimation**:
- Read + understand: 2-3 min
- Make changes: 5-10 min
- Test/verify: 2-3 min

**Examples**:

| Bad (>15 min) | Good (≤15 min) |
|---------------|----------------|
| "Implement authentication system" | "Create login API endpoint" |
| "Refactor user module" | "Extract validation logic to validator.ts" |
| "Fix bugs in checkout flow" | "Fix null pointer in checkout.ts:45" |

### Rule 2: Owner Rule (Single Agent)

**Every todo must have ONE clear owner.**

**Rationale**: Different agents have different capabilities. Coder writes code, tester writes tests, documenter writes docs. Mixed-owner todos cause confusion.

**Agent Owners**:

| Agent | Owns | Example Todos |
|-------|------|---------------|
| **coder** | Implementation | "Create User model", "Add login endpoint" |
| **tester** | Tests | "Write User model tests", "Add login E2E test" |
| **validator** | Verification | "Verify all tests pass", "Check coverage ≥80%" |
| **documenter** | Documentation | "Update API docs", "Add CHANGELOG entry" |

**Warning Signs**: "Implement and test" (coder + tester), "Write code and docs" (coder + documenter)

### Rule 3: Atomic Rule (One File/Component)

**Every todo must modify ONE file or component.**

**Rationale**: Multi-file changes increase complexity and risk of partial completion. Atomic todos are easier to verify and rollback.

**Scope**:

| Type | Atomic Scope | Example |
|------|--------------|---------|
| **New File** | Create single file | "Create src/models/User.ts" |
| **Edit** | Modify single file | "Add validateEmail to utils/validation.ts" |
| **Delete** | Remove single file | "Remove deprecated auth-legacy.ts" |
| **Test** | Create single test file | "Create tests/User.test.ts" |

**Warning Signs**: File paths with "/*", words like "module" or "system", "Update all"

---

## Todo Breakdown Process

### Step 1: Start with Large Goal
**Example**: "Implement JWT authentication"

### Step 2: Break into Phases
```
Phase 1: Design
Phase 2: Core Implementation
Phase 3: Testing
Phase 4: Integration
```

### Step 3: Break Phases into SCs
```
SC-1: Design JWT auth flow
SC-2: Create token generation
SC-3: Create token validation
SC-4: Add auth middleware
SC-5: Write tests
```

### Step 4: Break SCs into Granular Todos
```
SC-1: Design JWT auth flow
  - [coder] Create auth/README.md (5 min)
  - [coder] Define TypeScript interfaces (5 min)

SC-2: Create token generation
  - [coder] Create auth/token-generator.ts (10 min)
  - [coder] Add generateToken() (10 min)
  - [tester] Write tests (10 min)
```

**Result**: 1 goal → 5 SCs → 17 granular todos

---

## Verification Checklist

Before marking plan complete:

### Granularity
- [ ] All todos ≤15 minutes
- [ ] No "and" or "plus" in todos
- [ ] No vague words ("implement", "refactor")

### Ownership
- [ ] Every todo has ONE owner
- [ ] No mixed ownership

### Atomic
- [ ] Every todo modifies ONE file
- [ ] No wildcards or broad scope

---

## Common Anti-Patterns

### Anti-Pattern 1: "Everything" Todo
**Bad**: "Implement auth with JWT, add endpoints, write tests"

**Good**:
- "Create auth/token-generator.ts (10 min)"
- "Add login endpoint (10 min)"
- "Write token-generator.test.ts (10 min)"

### Anti-Pattern 2: "Vague" Todo
**Bad**: "Fix the bug"

**Good**:
- "Locate bug in checkout flow (5 min)"
- "Fix null pointer in checkout.ts:45 (10 min)"

### Anti-Pattern 3: "Mixed Owner"
**Bad**: "Implement and test User model"

**Good**:
- "Create User model (coder)"
- "Write User tests (tester)"

---

## Related Documentation

**Detailed Reference**: @.claude/guides/todo-granularity-REFERENCE.md - Advanced techniques, troubleshooting, examples

**Internal**: @.claude/guides/continuation-system.md - Sisyphus continuation | @.claude/guides/prp-framework.md - PRP methodology | @.claude/guides/parallel-execution.md - Parallel execution

---

**Template Version**: claude-pilot 4.1.2 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
