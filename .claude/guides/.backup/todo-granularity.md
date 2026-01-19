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

**How to Estimate**:
- Read + understand code: 2-3 minutes
- Make changes: 5-10 minutes
- Test/verify: 2-3 minutes
- **Total**: ~15 minutes

**Warning Signs** (todo is too large):
- Contains "and" or "plus" (multiple actions)
- Spans multiple files
- Requires multiple decisions
- vague words like "implement", "refactor", "fix"

**Examples**:

| Bad (>15 min) | Good (≤15 min) |
|---------------|----------------|
| "Implement authentication system" | "Create login API endpoint" |
| "Refactor user module" | "Extract validation logic to validator.ts" |
| "Fix bugs in checkout flow" | "Fix null pointer error in checkout.ts:45" |
| "Update documentation" | "Update README.md installation section" |

---

### Rule 2: Owner Rule (Single Agent)

**Every todo must have ONE clear owner agent.**

**Rationale**: Different agents have different capabilities. Coder writes code, tester writes tests, documenter writes docs. Mixed-owner todos cause confusion and incomplete work.

**Agent Owners**:

| Agent | Owns | Example Todos |
|-------|------|---------------|
| **coder** | Implementation | "Create User model", "Add login endpoint" |
| **tester** | Tests | "Write User model tests", "Add login E2E test" |
| **validator** | Verification | "Verify all tests pass", "Check coverage ≥80%" |
| **documenter** | Documentation | "Update API docs", "Add CHANGELOG entry" |
| **explorer** | Research | "Analyze auth patterns in codebase" |
| **researcher** | External research | "Research JWT best practices" |

**Warning Signs** (multiple owners):
- "Implement and test" (coder + tester)
- "Write code and docs" (coder + documenter)
- "Fix bug and verify" (coder + validator)
- "Analyze and implement" (researcher + coder)

**Examples**:

| Bad (Multiple Owners) | Good (Single Owner) |
|-----------------------|---------------------|
| "Create and test User model" | "Create User model" (coder) + "Write User model tests" (tester) |
| "Implement auth and write docs" | "Implement auth" (coder) + "Write auth documentation" (documenter) |
| "Research and apply fix" | "Research fix approaches" (researcher) + "Apply fix" (coder) |

---

### Rule 3: Atomic Rule (One File/Component)

**Every todo must modify ONE file or component.**

**Rationale**: Multi-file changes increase complexity and risk of partial completion. Atomic todos are easier to verify and rollback.

**Scope Guidelines**:

| Todo Type | Atomic Scope | Examples |
|-----------|--------------|----------|
| **New File** | Create single file | "Create src/models/User.ts" |
| **Edit File** | Modify single file | "Add validateEmail to utils/validation.ts" |
| **Delete** | Remove single file | "Remove deprecated auth-legacy.ts" |
| **Test File** | Create single test file | "Create tests/User.test.ts" |
| **Docs** | Update single doc | "Update API.md authentication section" |
| **Config** | Modify single config | "Add TypeScript strict mode to tsconfig.json" |

**Warning Signs** (not atomic):
- File paths with "/*" (multiple files)
- Words like "module", "system", "layer" (multiple components)
- "Update all", "migrate", "refactor" (broad changes)

**Examples**:

| Bad (Not Atomic) | Good (Atomic) |
|------------------|---------------|
| "Create auth system" | "Create auth/login.ts" + "Create auth/middleware.ts" |
| "Update all models" | "Update User model" + "Update Product model" |
| "Migrate to TypeScript" | "Migrate utils/helpers.ts to TypeScript" |
| "Add tests" | "Add tests for User model" |

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
Phase 5: Documentation
```

### Step 3: Break Phases into SCs (Success Criteria)

```
SC-1: Design JWT auth flow
SC-2: Create token generation
SC-3: Create token validation
SC-4: Add auth middleware
SC-5: Write tests
SC-6: Update docs
```

### Step 4: Break SCs into Granular Todos (≤15 min each)

```
SC-1: Design JWT auth flow
  - [coder] Create auth/README.md with flow diagram (5 min)
  - [coder] Define TypeScript interfaces (5 min)

SC-2: Create token generation
  - [coder] Create auth/token-generator.ts (10 min)
  - [coder] Add generateToken() function (10 min)
  - [tester] Write token-generator.test.ts (10 min)

SC-3: Create token validation
  - [coder] Create auth/token-validator.ts (10 min)
  - [coder] Add validateToken() function (10 min)
  - [tester] Write token-validator.test.ts (10 min)

SC-4: Add auth middleware
  - [coder] Create auth/middleware.ts (10 min)
  - [coder] Add authMiddleware() function (15 min)
  - [tester] Write middleware.test.ts (10 min)

SC-5: Write tests
  - [tester] Create auth/integration.test.ts (15 min)
  - [validator] Verify all tests pass (5 min)
  - [validator] Verify coverage ≥80% (5 min)

SC-6: Update docs
  - [documenter] Update API.md with auth endpoints (10 min)
  - [documenter] Add auth example to README.md (5 min)
  - [documenter] Add CHANGELOG.md entry (5 min)
```

**Result**: 1 large goal → 6 SCs → 17 granular todos (each ≤15 min)

---

## Todo Templates by Task Type

### Template 1: Feature Implementation

```markdown
## SC-{N}: {Feature Name}

### Design Phase
- [explorer] Analyze existing patterns for {feature}
- [researcher] Research best practices for {feature}
- [coder] Design {feature} architecture (create DESIGN.md)

### Implementation Phase
- [coder] Create src/{module}/core.ts (15 min)
- [coder] Implement {function-1} in core.ts (10 min)
- [coder] Implement {function-2} in core.ts (10 min)
- [tester] Create src/{module}/core.test.ts (10 min)
- [tester] Write tests for {function-1} (10 min)
- [tester] Write tests for {function-2} (10 min)

### Integration Phase
- [coder] Integrate {feature} into main.ts (10 min)
- [tester] Create integration test for {feature} (15 min)
- [validator] Verify all tests pass (5 min)
- [validator] Verify coverage ≥80% (5 min)

### Documentation Phase
- [documenter] Update API.md for {feature} (10 min)
- [documenter] Add {feature} example to README.md (5 min)
- [documenter] Add CHANGELOG.md entry (5 min)
```

### Template 2: Bug Fix

```markdown
## SC-{N}: Fix {Bug Description}

### Investigation Phase
- [explorer] Locate bug in {file} (5 min)
- [researcher] Research root cause of {bug} (10 min)
- [coder] Design fix approach (5 min)

### Fix Phase
- [coder] Fix {bug} in {file}:{line} (10 min)
- [tester] Write regression test for {bug} (10 min)
- [tester] Verify fix resolves issue (5 min)
- [validator] Verify no regressions (5 min)

### Documentation Phase
- [documenter] Update BUGS.md with fix details (5 min)
- [documenter] Add CHANGELOG.md entry (5 min)
```

### Template 3: Refactoring

```markdown
## SC-{N}: Refactor {Component}

### Analysis Phase
- [explorer] Analyze current {component} structure (10 min)
- [coder] Design refactored structure (10 min)

### Refactoring Phase
- [coder] Extract {sub-component} to new file (10 min)
- [coder] Update imports in {component} (5 min)
- [tester] Update tests for {sub-component} (10 min)
- [validator] Verify all tests still pass (5 min)

### Cleanup Phase
- [coder] Remove old code from {component} (5 min)
- [validator] Verify no broken imports (5 min)
```

### Template 4: Documentation

```markdown
## SC-{N}: Document {Feature/Component}

### Draft Phase
- [explorer] Analyze {feature} code structure (10 min)
- [documenter] Draft {feature} documentation (15 min)

### Review Phase
- [documenter] Review documentation for completeness (5 min)
- [coder] Verify code examples are accurate (5 min)

### Publish Phase
- [documenter] Update docs/{feature}.md (10 min)
- [documenter] Update README.md with {feature} link (5 min)
- [documenter] Add CHANGELOG.md entry (5 min)
```

### Template 5: Testing

```markdown
## SC-{N}: Test Coverage for {Component}

### Analysis Phase
- [explorer] Identify untested code in {component} (10 min)
- [tester] Design test scenarios (10 min)

### Test Implementation Phase
- [tester] Create tests/{component}.test.ts (15 min)
- [tester] Write unit tests for {function-1} (10 min)
- [tester] Write unit tests for {function-2} (10 min)
- [tester] Write edge case tests (10 min)

### Verification Phase
- [validator] Run all tests (5 min)
- [validator] Verify coverage ≥80% (5 min)
- [validator] Verify no test failures (5 min)
```

---

## Integration with Existing Commands

### /00_plan Integration

**When generating plans, /00_plan MUST**:

1. **Break down large SCs into granular todos**
   - If SC estimated >15 min, split into multiple todos
   - Assign single owner to each todo
   - Ensure atomic scope (one file/component)

2. **Use templates for common task types**
   - Feature implementation → Template 1
   - Bug fix → Template 2
   - Refactoring → Template 3
   - Documentation → Template 4
   - Testing → Template 5

3. **Warn if granularity rules violated**
   - If todo >15 min: "WARNING: Todo exceeds 15-minute threshold"
   - If todo has multiple owners: "WARNING: Todo has mixed ownership"
   - If todo spans multiple files: "WARNING: Todo not atomic"

**Example Plan Output**:

```markdown
## Execution Plan

### SC-1: Create JWT Token Generator
- [explorer] Analyze existing auth patterns (5 min)
- [researcher] Research JWT best practices (10 min)
- [coder] Create auth/token-generator.ts (10 min)
- [coder] Implement generateToken() function (10 min)
- [tester] Write token-generator.test.ts (10 min)
- [validator] Verify tests pass (5 min)

**Granularity Check**: All todos ≤15 min ✅
**Ownership Check**: All todos have single owner ✅
**Atomic Check**: All todos modify single file ✅
```

### /02_execute Integration

**When executing, /02_execute MUST**:

1. **Load granular todos from plan**
   - Read todos with owner assignments
   - Verify granularity compliance
   - Create continuation state file

2. **Execute todos by owner**
   - Invoke appropriate agent for each todo
   - Update todo status after completion
   - Check continuation state before stopping

3. **Enforce Sisyphus continuation**
   - Before stopping, check if ALL todos complete
   - If incomplete, continue with next todo
   - Update iteration count in state file

**Continuation Check** (in /02_execute):

```markdown
## ⚠️ CONTINUATION CHECK

Before stopping, you MUST:
1. Read `.pilot/state/continuation.json`
2. Check if ALL todos have status "complete"
3. If ANY todo is "in_progress" or "pending":
   - DO NOT STOP
   - Continue with next todo
   - Update iteration count
   - Save checkpoint
```

### /03_close Integration

**When closing, /03_close MUST**:

1. **Verify ALL granular todos complete**
   - Read continuation state file
   - Check each todo status
   - Warn if any todos incomplete

2. **Generate completion report**
   - List completed todos
   - List incomplete todos (if any)
   - Show total iterations

3. **Archive continuation state**
   - Move to `.pilot/state/archive/`
   - Only delete after user confirmation

---

## Common Anti-Patterns

### Anti-Pattern 1: The "Everything" Todo

**Bad**: "Implement user authentication with JWT, add login/register endpoints, write tests, update docs"

**Issues**:
- Time: >60 minutes
- Owner: coder + tester + documenter
- Atomic: Multiple files (auth, endpoints, tests, docs)

**Good Breakdown**:
```markdown
- [coder] Create auth/token-generator.ts (10 min)
- [coder] Create auth/middleware.ts (10 min)
- [coder] Add login endpoint to routes/auth.ts (10 min)
- [coder] Add register endpoint to routes/auth.ts (10 min)
- [tester] Write tests for token-generator.ts (10 min)
- [tester] Write tests for middleware.ts (10 min)
- [tester] Write tests for auth routes (15 min)
- [documenter] Update API.md for auth endpoints (10 min)
- [documenter] Add auth example to README.md (5 min)
```

### Anti-Pattern 2: The "Vague" Todo

**Bad**: "Fix the bug"

**Issues**:
- No clear scope (what bug?)
- No clear file (where?)
- No clear owner (coder or tester?)

**Good Breakdown**:
```markdown
- [explorer] Locate null pointer bug in checkout flow (5 min)
- [coder] Fix null pointer in checkout.ts:45 (10 min)
- [tester] Write regression test for null pointer fix (10 min)
- [validator] Verify fix resolves issue (5 min)
```

### Anti-Pattern 3: The "Cascade" Todo

**Bad**: "Refactor user module, update all imports, fix tests"

**Issues**:
- Cascading changes (user module → imports → tests)
- Multiple files affected
- High blast radius

**Good Breakdown**:
```markdown
- [coder] Extract validation logic from user.ts to user-validator.ts (10 min)
- [coder] Update imports in routes/user.ts (5 min)
- [coder] Update imports in services/user.ts (5 min)
- [tester] Update tests for user-validator.ts (10 min)
- [validator] Verify all tests pass (5 min)
```

### Anti-Pattern 4: The "Mixed Owner" Todo

**Bad**: "Implement and test User model"

**Issues**:
- Mixed ownership (coder + tester)
- Unclear when to switch owners
- Risk of incomplete work

**Good Breakdown**:
```markdown
- [coder] Create User model in src/models/User.ts (10 min)
- [tester] Create tests/User.test.ts (10 min)
```

---

## Verification Checklist

Before marking a plan complete, verify:

### Granularity Check
- [ ] All todos estimated ≤15 minutes
- [ ] No todo contains "and" or "plus" (multiple actions)
- [ ] No todo spans multiple files
- [ ] No todo uses vague words ("implement", "refactor", "fix")

### Ownership Check
- [ ] Every todo has ONE clear owner
- [ ] No todo mixes owners (e.g., "implement and test")
- [ ] Owner matches task type (coder → code, tester → tests)
- [ ] No orphaned todos (every todo has owner)

### Atomic Check
- [ ] Every todo modifies ONE file or component
- [ ] No todo uses wildcards (e.g., "update all models")
- [ ] No todo has broad scope (e.g., "module", "system")
- [ ] Every todo is independently verifiable

### Continuation Check
- [ ] Plan can be resumed from any todo
- [ ] Each todo has clear success criteria
- [ ] Each todo has clear verification step
- [ ] No dependencies between todos within same SC

---

## Examples: Good vs Bad Todos

### Feature Implementation

| Bad Todo | Why Bad | Good Todo |
|----------|---------|-----------|
| "Implement auth system" | Time >60 min, multiple files | "Create auth/token-generator.ts (10 min)" |
| "Add login and register" | Multiple actions (and) | "Add login endpoint (10 min)" |
| "Write auth tests" | Vague scope | "Write token-generator.test.ts (10 min)" |
| "Update docs for auth" | Multiple docs | "Update API.md for auth endpoints (10 min)" |

### Bug Fix

| Bad Todo | Why Bad | Good Todo |
|----------|---------|-----------|
| "Fix authentication bug" | Vague (what bug?) | "Fix null pointer in auth.ts:45 (10 min)" |
| "Debug login issues" | Not actionable | "Locate bug in login flow (5 min)" |
| "Fix and test" | Mixed owner | "Fix bug (coder)" + "Test fix (tester)" |

### Refactoring

| Bad Todo | Why Bad | Good Todo |
|----------|---------|-----------|
| "Refactor user module" | Broad scope | "Extract validation to user-validator.ts (10 min)" |
| "Clean up code" | Vague | "Remove unused imports in user.ts (5 min)" |
| "Improve performance" | Not measurable | "Cache database queries in user.ts (10 min)" |

### Documentation

| Bad Todo | Why Bad | Good Todo |
|----------|---------|-----------|
| "Write documentation" | Vague scope | "Update API.md for auth endpoints (10 min)" |
| "Add examples" | Which examples? | "Add login example to README.md (5 min)" |
| "Update all docs" | Multiple files | "Update CHANGELOG.md entry (5 min)" |

---

## Advanced Techniques

### Technique 1: Progressive Breakdown

When todos are still too large:

1. **Break into sub-phases**:
   ```
   SC-1: Implement auth
     → Phase 1: Core token logic
       → Create token-generator.ts (10 min)
       → Implement generateToken() (10 min)
     → Phase 2: Validation
       → Create token-validator.ts (10 min)
       → Implement validateToken() (10 min)
   ```

2. **Use parallel execution**:
   ```
   - [coder] Create token-generator.ts (10 min)
   - [coder] Create token-validator.ts (10 min) [parallel]
   - [tester] Write tests for token-generator.ts (10 min)
   - [tester] Write tests for token-validator.ts (10 min) [parallel]
   ```

### Technique 2: Dependency Mapping

Map dependencies between todos:

```markdown
## SC-1: Token System

### Sequential Todos (must execute in order)
- [coder] Create auth/token-generator.ts (10 min) [1]
- [coder] Implement generateToken() (10 min) [2, depends on 1]
- [tester] Write token-generator.test.ts (10 min) [3, depends on 2]

### Parallel Todos (can execute simultaneously)
- [coder] Create auth/token-validator.ts (10 min) [1, parallel]
- [coder] Implement validateToken() (10 min) [2, depends on 1, parallel]
- [tester] Write token-validator.test.ts (10 min) [3, depends on 2, parallel]
```

### Technique 3: Estimation Adjustment

If todos consistently exceed estimates:

1. **Track actual vs estimated time**
2. **Adjust future estimates** (add buffer)
3. **Break down further** if consistently >15 min

**Example**:
```
Estimated: "Create auth middleware (10 min)"
Actual: 25 min (took longer)
Action: Break into smaller todos
  → "Create auth/middleware.ts (5 min)"
  → "Add authMiddleware() skeleton (5 min)"
  → "Add token validation logic (10 min)"
  → "Add error handling (5 min)"
```

---

## Troubleshooting

### Problem: Agents stop before completing todos

**Symptoms**:
- Agent completes 1 todo, then stops
- Remaining todos marked "pending"
- Continuation state shows incomplete work

**Solutions**:
1. **Check granularity**: Are todos truly ≤15 min?
2. **Check ownership**: Is owner clearly specified?
3. **Check atomicity**: Is todo focused on one file?
4. **Add continuation prompt**: Remind agent to check remaining todos

### Problem: Plans have too many todos

**Symptoms**:
- Plan has 50+ todos
- Overwhelming to review
- Hard to track progress

**Solutions**:
1. **Group related todos into SCs**
2. **Use phases to organize**
3. **Hide implementation details in sub-bullets**
4. **Focus on high-level SCs in summary**

### Problem: Todo estimates are inaccurate

**Symptoms**:
- Todos consistently take longer than estimated
- Agents run out of tokens before completing
- Poor time planning

**Solutions**:
1. **Add buffer time** (estimate × 1.5)
2. **Track actual time** for future reference
3. **Break down further** if consistently >15 min
4. **Use parallel execution** for independent todos

---

## Related Documentation

- **Sisyphus Continuation System**: `.claude-pilot/.pilot/plan/in_progress/...sisyphus_continuation_system.md`
- **PRP Framework**: `.claude/guides/prp-framework.md`
- **Ralph Loop**: `.claude/skills/ralph-loop/SKILL.md`
- **Parallel Execution**: `.claude/guides/parallel-execution.md`
- **Agent Orchestration**: `.claude/guides/parallel-execution.md`

---

## Summary

**The Three Rules**:
1. **Time Rule**: ≤15 minutes per todo
2. **Owner Rule**: Single agent owner
3. **Atomic Rule**: One file/component per todo

**Key Practices**:
- Use templates for common task types
- Warn if granularity rules violated
- Verify with checklist before execution
- Integrate with continuation state system

**Result**: Reliable agent continuation, higher completion rates, better progress tracking.

---

**Template Version**: claude-pilot 4.1.2 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
