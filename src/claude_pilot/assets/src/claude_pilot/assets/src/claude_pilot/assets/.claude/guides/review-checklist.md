# Review Checklist Guide

## Purpose

This guide provides a comprehensive review checklist for evaluating development plans. Reviews ensure plans are complete, well-structured, and ready for execution.

## Review Structure

Reviews are divided into two categories:

| Category | Count | Activation |
|----------|-------|------------|
| **Mandatory** | 8 items | Always run for all plans |
| **Extended** | 8 items (A-H) | Activated by plan type/keywords |
| **Gap Detection** | 7 items | Always run; BLOCKING when triggered |

---

## Mandatory Reviews (8 Items)

Execute all 8 reviews for every plan.

### Review 1: Development Principles

| Principle | Check |
|-----------|-------|
| **SOLID** | Single responsibility violations? |
| **DRY** | Duplicate logic potential? |
| **KISS** | Unnecessary complexity? |
| **YAGNI** | Features not currently needed? |

### Review 2: Project Structure

| Check | Question |
|-------|----------|
| File locations | New files in correct locations? |
| Naming | Follows naming conventions? |
| Patterns | Uses same patterns as existing code? |

### Review 3: Requirement Completeness

| Check | Question |
|-------|----------|
| Explicit | All explicit requirements reflected? |
| Implicit | Implicit requirements considered? (error handling, loading states) |

### Review 4: Logic Errors

| Check | Question |
|-------|----------|
| Order | Implementation order correct? |
| Dependencies | Dependencies ready at point of use? |
| Edge cases | Edge cases considered? (null, empty, failure) |
| Async | Async handling correct? |

### Review 5: Existing Code Reuse

| Check | Method |
|-------|--------|
| Utils | Search utils/, hooks/, common/ folders |
| Domain | Check domain-related files |
| Format | `🔍 New: [name] → Found: [file]` or `→ Write new` |

### Review 6: Better Alternatives

| Check | Question |
|-------|----------|
| Simplicity | Simpler implementation? |
| Scalability | More scalable design? |
| Testability | More testable structure? |
| Best practices | Industry best practices? |

### Review 7: Project Alignment

| Check | Question |
|-------|----------|
| Type check | Type check possible? |
| API docs | External API docs checked? |
| Impact | All affected areas identified? |

### Review 8: Long-term Impact

| Check | Question |
|-------|----------|
| Consequences | Secondary consequences predicted? |
| Debt | Technical debt potential assessed? |
| Scalability | Scalability constraints identified? |
| Rollback | Rollback cost considered? |

---

## Extended Reviews (A-H)

### Activation Matrix

| Type | Keywords | Activated Reviews |
|------|----------|-------------------|
| **Code Modification** | function, component, API, bug fix, refactor | A, B, D |
| **Documentation** | CLAUDE.md, README, guide | C |
| **Scenario Validation** | test, validation, scenario, edge cases | H |
| **Infrastructure** | Docker, env, deploy, CI/CD | F |
| **DB Schema** | migration, table, column | E |
| **AI/Prompts** | GPT, Claude, prompts, LLM | G |

### Extended A: API Compatibility Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Function Signature** | Do param changes break existing callers? |
| **Return Type** | Does return value change affect logic? |
| **Required vs Optional** | If new params are required, do callers need modification? |
| **Backward Compat** | Can existing behavior be maintained with defaults? |

**Process**:
1. List functions/APIs being changed
2. Search call sites using Grep
3. Verify each call site works after change

### Extended B: Type Safety Review

**When**: TypeScript/Type-safe language plans

| Item | Question |
|------|----------|
| **Type Imports** | Are all types imported? |
| **Type Definitions** | New types defined before use? |
| **Any Usage** | Is `any` avoided? |
| **Null Checks** | Are null/undefined handled? |

### Extended C: Documentation Consistency Review

**When**: Documentation plans

| Item | Question |
|------|----------|
| **CLAUDE.md** | Project docs updated? |
| **README.md** | User docs updated? |
| **Code Comments** | Complex code explained? |
| **References** | External references accurate? |

### Extended D: Test Coverage Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Existing Tests** | Will any tests break from changes? |
| **Test Coverage** | Are tests for new code in the plan? |
| **Mocking** | Is mocking needed for new deps? |

### Extended E: Migration Safety Review

**When**: DB schema plans

| Item | Question |
|------|----------|
| **Rollback** | Can we rollback if migration fails? |
| **Data Integrity** | Is existing data preserved? |
| **Downtime** | Is service interruption required? |
| **Type Gen** | Is type generation included? |

### Extended F: Deployment Impact Review

**When**: Infrastructure/deployment plans

| Item | Question |
|------|----------|
| **Env Separation** | Are dev/staging/prod properly separated? |
| **Env Vars** | Are new env vars set in deployment platform? |
| **Rollback Plan** | Is there a rollback procedure? |
| **Timeout** | Is timeout set for long-running API calls? |

### Extended G: Prompt Quality Review

**When**: AI/prompt plans

| Item | Question |
|------|----------|
| **Positive Expression** | Using positive instead of DO NOT, NEVER? |
| **Context Balance** | Is info balanced across prompt sections? |
| **Examples** | Are success/failure examples included? |
| **Cost** | Is token usage appropriate? |

### Extended H: Test Scenario Review

**When**: Scenario validation plans

| Item | Question |
|------|----------|
| **Coverage** | Normal/edge/error cases all included? |
| **Reproducibility** | Can scenarios be consistently reproduced? |
| **Independence** | No dependency on other scenarios? |
| **Priority** | Critical scenarios verified first? |
| **Input/Output** | Are inputs and expected outputs clear? |

---

## Quick Reference

```
Code Mod → A (API compat) + B (Types) + D (Tests)
Docs     → C (Consistency)
Scenario → H (Coverage)
Infra    → F (Deployment)
DB       → E (Migration)
AI       → G (Prompts)
```

---

## Result Format

```markdown
## Mandatory Review (8 items)
| # | Item | Status |
|---|------|--------|
| 1 | Dev Principles | ✅/⚠️/❌ |
| 2 | Project Structure | ✅/⚠️/❌ |
| 3 | Requirements | ✅/⚠️/❌ |
| 4 | Logic Errors | ✅/⚠️/❌ |
| 5 | Code Reuse | ✅/⚠️/❌ |
| 6 | Alternatives | ✅/⚠️/❌ |
| 7 | Project Alignment | ✅/⚠️/❌ |
| 8 | Long-term Impact | ✅/⚠️/❌ |

## Extended Reviews
| # | Category | Status |
|---|----------|--------|
| A | API Compatibility | ✅/🛑 |
| B | Type Safety | ✅/🛑 |
| C | Documentation | ✅/🛑 |
| D | Test Coverage | ✅/🛑 |
| E | Migration Safety | ✅/🛑 |
| F | Deployment Impact | ✅/🛑 |
| G | Prompt Quality | ✅/🛑 |
| H | Test Scenarios | ✅/🛑 |
```

---

## Severity Levels

| Level | Symbol | Description | Action Required |
|-------|--------|-------------|-----------------|
| **BLOCKING** | 🛑 | Cannot proceed | Triggers Interactive Recovery (dialogue until resolved) |
| **Critical** | 🚨 | Must fix | Acknowledge and fix before execution |
| **Warning** | ⚠️ | Should fix | Advisory, but recommended |
| **Suggestion** | 💡 | Nice to have | Optional improvements |

---

## See Also

- @.claude/guides/gap-detection.md - External service verification
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
