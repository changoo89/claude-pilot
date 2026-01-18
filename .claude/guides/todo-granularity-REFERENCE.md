# Todo Granularity Reference Guide

> **Last Updated**: 2026-01-18
> **Purpose**: Detailed reference for granular todo breakdown (Sisyphus system)
> **Companion**: @.claude/guides/todo-granularity.md (Quick Reference)

---

## Overview

This reference guide provides detailed explanations, examples, and advanced techniques for breaking down work into granular todos that enable reliable agent continuation.

**Philosophy**: "The boulder never stops" - when todos are small (≤15 minutes), atomic (one file), and owned (single agent), agents can complete them reliably without stopping prematurely.

---

## The Three Rules of Granular Todos (Detailed)

### Rule 1: Time Rule (≤15 Minutes)

**Why 15 minutes?**

Agents complete one significant unit of work, then check for continuation. If a todo takes longer than 15 minutes, the agent may stop halfway through, leaving incomplete work.

**Time Estimation Formula**:

```
Total Time = Read (2-3 min) + Understand (2-3 min) + Implement (5-10 min) + Verify (2-3 min)
Target: ≤15 minutes per todo
```

**Warning Signs** (todo is too large):

| Sign | Example | Fix |
|------|---------|-----|
| Contains "and" or "plus" | "Implement auth and add tests" | Split into separate todos |
| Spans multiple files | "Update all auth files" | One file per todo |
| Requires multiple decisions | "Design and implement" | Separate design from implementation |
| Vague words | "Implement feature X" | Break into specific steps |

**Detailed Examples**:

| Bad Todo (>15 min) | Time Estimate | Good Breakdown (≤15 min each) |
|-------------------|---------------|------------------------------|
| "Implement authentication system" | 60+ min | "Create auth/login.ts (10 min)", "Create auth/logout.ts (10 min)", "Add login endpoint (10 min)" |
| "Refactor user module" | 45+ min | "Extract validation to user-validator.ts (10 min)", "Update imports in routes/user.ts (5 min)" |
| "Fix bugs in checkout flow" | 30+ min | "Fix null pointer in checkout.ts:45 (10 min)", "Fix race condition in checkout.ts:78 (10 min)" |
| "Update documentation" | 20+ min | "Update API.md authentication section (10 min)", "Add auth example to README.md (5 min)" |

---

### Rule 2: Owner Rule (Single Agent)

**Why single ownership?**

Different agents have different capabilities:
- **coder**: Writes code (Read, Write, Edit, Bash)
- **tester**: Writes tests (Read, Write, Bash)
- **validator**: Verifies quality (Bash, Read)
- **documenter**: Writes docs (Read, Write)

Mixed-owner todos cause confusion:
- Which agent runs first?
- When do we switch agents?
- How do we verify partial completion?

**Agent Capabilities Reference**:

| Agent | Model | Tools | Owns | Example Todos |
|-------|-------|-------|------|---------------|
| **explorer** | haiku | Glob, Grep, Read | Research | "Analyze auth patterns in codebase", "Find all files using X" |
| **researcher** | haiku | WebSearch, WebFetch, query-docs | Research | "Research JWT best practices", "Find external docs for Y" |
| **coder** | sonnet | Read, Write, Edit, Bash | Implementation | "Create User model", "Add login endpoint", "Fix bug in auth.ts:45" |
| **tester** | sonnet | Read, Write, Bash | Tests | "Write User model tests", "Add login E2E test", "Debug test failure" |
| **validator** | haiku | Bash, Read | Verification | "Verify all tests pass", "Check coverage ≥80%", "Run type check" |
| **documenter** | haiku | Read, Write | Documentation | "Update API docs", "Add CHANGELOG entry", "Sync documentation" |

**Warning Signs** (multiple owners):

| Bad Todo | Owners | Fix |
|----------|--------|-----|
| "Implement and test User model" | coder + tester | "Create User model (coder)" + "Write User tests (tester)" |
| "Write code and docs" | coder + documenter | "Implement feature (coder)" + "Write docs (documenter)" |
| "Fix bug and verify" | coder + validator | "Fix bug (coder)" + "Verify fix (validator)" |
| "Analyze and implement" | researcher + coder | "Research approach (researcher)" + "Implement (coder)" |

**Mixed Ownership Anti-Patterns**:

```markdown
❌ BAD: "Create and test User model"
Problem: Who does what? When to switch?
Result: Confusion, incomplete work

✅ GOOD: Two separate todos
- [coder] Create User model in src/models/User.ts (10 min)
- [tester] Create tests/User.test.ts (10 min)
Result: Clear ownership, complete work
```

---

### Rule 3: Atomic Rule (One File/Component)

**Why atomic todos?**

Multi-file changes increase complexity and risk:
- Partial completion (some files updated, others not)
- Difficult rollback (which files changed?)
- Hard to verify (what's the scope?)
- Integration conflicts (multiple agents editing same files)

**Atomic Scope Guidelines**:

| Todo Type | Atomic Scope | Examples | Non-Atomic (Avoid) |
|-----------|--------------|----------|-------------------|
| **New File** | Create single file | "Create src/models/User.ts" | "Create auth system" |
| **Edit File** | Modify single file | "Add validateEmail to utils/validation.ts" | "Update all models" |
| **Delete** | Remove single file | "Remove deprecated auth-legacy.ts" | "Delete old auth files" |
| **Test File** | Create single test file | "Create tests/User.test.ts" | "Add tests for auth" |
| **Docs** | Update single doc | "Update API.md authentication section" | "Update all docs" |
| **Config** | Modify single config | "Add TypeScript strict mode to tsconfig.json" | "Update all configs" |

**Warning Signs** (not atomic):

| Sign | Example | Fix |
|------|---------|-----|
| File paths with "/*" | "Update src/**/*.ts" | "Update src/auth/login.ts" |
| Words like "module", "system" | "Refactor user module" | "Extract validation from user.ts" |
| "Update all", "migrate" | "Migrate to TypeScript" | "Migrate utils/helpers.ts to TypeScript" |
| Broad scope words | "Implement caching layer" | "Create cache/redis.ts" |

**Atomic vs Non-Atomic Examples**:

| Non-Atomic Todo | Why Not Atomic | Atomic Breakdown |
|-----------------|----------------|-----------------|
| "Create auth system" | Multiple files, components | "Create auth/login.ts" + "Create auth/logout.ts" + "Create auth/middleware.ts" |
| "Update all models" | Wildcard, multiple files | "Update User model" + "Update Product model" |
| "Migrate to TypeScript" | Broad scope, multiple files | "Migrate utils/helpers.ts to TypeScript" |
| "Add tests" | Vague scope | "Add tests for User model" |

---

## Todo Breakdown Process (Detailed)

### Step 1: Start with Large Goal

**Example**: "Implement JWT authentication"

### Step 2: Break into Phases

```
Phase 1: Design (define interfaces, flow)
Phase 2: Core Implementation (token generation, validation)
Phase 3: Integration (middleware, routes)
Phase 4: Testing (unit tests, integration tests)
Phase 5: Documentation (API docs, examples)
```

### Step 3: Break Phases into SCs (Success Criteria)

```
SC-1: Design JWT auth flow (interfaces, flow diagram)
SC-2: Create token generation (generateToken function)
SC-3: Create token validation (validateToken function)
SC-4: Add auth middleware (authMiddleware)
SC-5: Write tests (unit + integration)
SC-6: Update docs (API.md, README.md)
```

### Step 4: Break SCs into Granular Todos (≤15 min each)

**SC-1: Design JWT auth flow**
- [explorer] Analyze existing auth patterns (5 min)
- [researcher] Research JWT best practices (10 min)
- [coder] Create auth/README.md with flow diagram (5 min)
- [coder] Define TypeScript interfaces (5 min)

**SC-2: Create token generation**
- [coder] Create auth/token-generator.ts (10 min)
- [coder] Add generateToken() function (10 min)
- [tester] Write token-generator.test.ts (10 min)

**SC-3: Create token validation**
- [coder] Create auth/token-validator.ts (10 min)
- [coder] Add validateToken() function (10 min)
- [tester] Write token-validator.test.ts (10 min)

**SC-4: Add auth middleware**
- [coder] Create auth/middleware.ts (10 min)
- [coder] Add authMiddleware() function (15 min)
- [tester] Write middleware.test.ts (10 min)

**SC-5: Write tests**
- [tester] Create auth/integration.test.ts (15 min)
- [validator] Verify all tests pass (5 min)
- [validator] Verify coverage ≥80% (5 min)

**SC-6: Update docs**
- [documenter] Update API.md with auth endpoints (10 min)
- [documenter] Add auth example to README.md (5 min)
- [documenter] Add CHANGELOG.md entry (5 min)

**Result**: 1 large goal → 6 SCs → 19 granular todos (each ≤15 min)

---

## Todo Templates by Task Type (Detailed)

### Template 1: Feature Implementation

```markdown
## SC-{N}: {Feature Name}

### Design Phase
- [explorer] Analyze existing patterns for {feature} (5-10 min)
- [researcher] Research best practices for {feature} (10 min)
- [coder] Design {feature} architecture, create DESIGN.md (10 min)

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
- [explorer] Locate bug in {file}:{line} (5 min)
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

## Common Anti-Patterns (Detailed)

### Anti-Pattern 1: The "Everything" Todo

**Bad**: "Implement user authentication with JWT, add login/register endpoints, write tests, update docs"

**Issues**:
- **Time**: >60 minutes (way over 15 min target)
- **Owner**: coder + tester + documenter (mixed ownership)
- **Atomic**: Multiple files (auth, endpoints, tests, docs)

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
- **No clear scope**: What bug?
- **No clear file**: Where is it?
- **No clear owner**: coder or tester?

**Good Breakdown**:
```markdown
- [explorer] Locate null pointer bug in checkout flow (5 min)
- [researcher] Research root cause of null pointer (10 min)
- [coder] Fix null pointer in checkout.ts:45 (10 min)
- [tester] Write regression test for null pointer fix (10 min)
- [validator] Verify fix resolves issue (5 min)
```

### Anti-Pattern 3: The "Cascade" Todo

**Bad**: "Refactor user module, update all imports, fix tests"

**Issues**:
- **Cascading changes**: user module → imports → tests
- **Multiple files**: user.ts, routes/user.ts, services/user.ts, tests/
- **High blast radius**: Affects many parts of codebase

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
- **Mixed ownership**: coder + tester
- **Unclear transition**: When to switch from coder to tester?
- **Risk of incomplete work**: Who verifies the implementation?

**Good Breakdown**:
```markdown
- [coder] Create User model in src/models/User.ts (10 min)
- [tester] Create tests/User.test.ts (10 min)
- [validator] Verify User model tests pass (5 min)
```

---

## Verification Checklist (Detailed)

Before marking a plan complete, verify:

### Granularity Check
- [ ] All todos estimated ≤15 minutes
- [ ] No todo contains "and" or "plus" (multiple actions)
- [ ] No todo spans multiple files
- [ ] No todo uses vague words ("implement", "refactor", "fix" without specificity)

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

## Examples: Good vs Bad Todos (Detailed)

### Feature Implementation

| Bad Todo | Why Bad | Good Todo |
|----------|---------|-----------|
| "Implement auth system" | Time >60 min, multiple files | "Create auth/token-generator.ts (10 min)" |
| "Add login and register" | Multiple actions (and) | "Add login endpoint (10 min)" + "Add register endpoint (10 min)" |
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

## Advanced Techniques (Detailed)

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

## Troubleshooting (Detailed)

### Problem: Agents stop before completing todos

**Symptoms**:
- Agent completes 1 todo, then stops
- Remaining todos marked "pending"
- Continuation state shows incomplete work

**Root Causes**:
1. **Granularity issue**: Todo >15 minutes
2. **Ownership issue**: Unclear who owns the todo
3. **Atomicity issue**: Todo too complex (multiple files)

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

- **Sisyphus Continuation System**: @.claude/guides/continuation-system.md
- **PRP Framework**: @.claude/guides/prp-framework.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Agent Orchestration**: @.claude/guides/parallel-execution.md

---

**Template Version**: claude-pilot 4.1.2 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
