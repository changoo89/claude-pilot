---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[focus] - optional focus areas (security, performance, accessibility, etc.)"
allowed-tools: Read, Glob, Grep, Bash(git:*), Write
---

# /90_review

_Review plans before implementation with comprehensive multi-angle analysis._

## Core Philosophy

- **Type-based review**: Customized for code/docs/scenario/infra/DB/AI plans
- **Mandatory + Extended + Autonomous**: Fixed items + type-specific + self-judgment
- **Proactive investigation**: Resolve "needs investigation" items upfront
- **Efficient progression**: Severity-based conditional checks

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Load Plan

```bash
PLAN_PATH="$(ls -1tr .pilot/plan/in_progress/*/*.md .pilot/plan/pending/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] && { echo "No plan found to review" >&2; exit 1; }
echo "Reviewing: $PLAN_PATH"
```

Read and extract: User requirements, Execution plan, Acceptance criteria, Test scenarios, Constraints, Risks

---

## Step 1: Proactive Investigation

> **Principle**: Investigate all "needs investigation/confirmation/review" items upfront

**Keywords**: "need to investigate", "confirm", "TODO", "check", "verify"

| Target | Method | Tools |
|--------|--------|-------|
| Existing code/patterns | Search similar impl | Glob, Grep, Read |
| API docs | Check official docs | WebSearch |
| Dependencies | npm/PyPI registry | Bash(npm/pip info) |

**Output**: `🔍 Investigation Complete: [Item] → Result: ✅/❌ Finding → Plan update: Applied`

---

## Step 2: Type Detection

| Type | Keywords | Extended Reviews |
|------|----------|------------------|
| **Code** | function, component, API, bug fix | A, B, D |
| **Docs** | CLAUDE.md, README, guide | C |
| **Scenario** | test, validation, edge cases | H |
| **Infra** | Vercel, env, deploy, CI/CD | F |
| **DB** | migration, table, schema | E |
| **AI** | LLM, prompts, AI | G |

**Output**: `📋 Type: [Primary] / Extended: [A, B, D]`

---

## Step 3: Mandatory Reviews (8 items)

Execute all 8 reviews for every plan

### Review 1: Development Principles
☐ **SOLID**: Single responsibility violations?
☐ **DRY**: Duplicate logic potential?
☐ **KISS**: Unnecessary complexity?
☐ **YAGNI**: Features not currently needed?

### Review 2: Project Structure
☐ New files in correct locations?
☐ Follows naming conventions?
☐ Uses same patterns as existing code?

### Review 3: Requirement Completeness
☐ All explicit requirements reflected?
☐ Implicit requirements considered? (error handling, loading states)

### Review 4: Logic Errors
☐ Implementation order correct?
☐ Dependencies ready at point of use?
☐ Edge cases considered? (null, empty, failure)
☐ Async handling correct?

### Review 5: Existing Code Reuse
☐ Search utils/, hooks/, common/ folders
☐ Check domain-related files
☐ Format: `🔍 New: [name] → Found: [file]` or `→ Write new`

### Review 6: Better Alternatives
☐ Simpler implementation?
☐ More scalable design?
☐ More testable structure?
☐ Industry best practices?

### Review 7: Project Alignment
☐ Type check possible?
☐ External API docs checked?
☐ All affected areas identified?

### Review 8: Long-term Impact
☐ Secondary consequences predicted?
☐ Technical debt potential assessed?
☐ Scalability constraints identified?
☐ Rollback cost considered?

---

## Step 4: Vibe Coding Compliance

> **NEW: Check Vibe Coding Guidelines enforcement**

| Target | Limit | Check |
|--------|-------|-------|
| Function | ≤50 lines | Plan mentions splitting large functions? |
| File | ≤200 lines | Plan respects module boundaries? |
| Nesting | ≤3 levels | Early return pattern specified? |

☐ **SRP**: One function = one responsibility?
☐ **DRY**: No duplicate code blocks planned?
☐ **KISS**: Simplest solution that works?
☐ **Early Return**: Reduced nesting planned?

---

## Step 5: Extended Reviews (By Type)

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

**Result Format**:
```
[Changed: functionName()]
- Original: (param1: Type1) => ReturnType
- Changed: (param1: Type1, param2?: Type2) => ReturnType
- Backward compatible: Yes/No
- Call site impact: N files
```

### Extended B: Type Safety Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Type Location** | Are new types in `types/` directory? |
| **Generic Complexity** | Are generics unnecessarily complex? |
| **any Usage** | Are concrete types used instead of `any`? |
| **null Check** | Are `?.` and `??` properly used? |
| **Type Guards** | Are type guards present where needed? |

### Extended C: Document Consistency Review

**When**: Documentation plans

| Item | Question |
|------|----------|
| **Cross-refs** | Are other docs referencing this? Are links valid? |
| **Code-Doc Sync** | Does content match actual code? |
| **Version Info** | Is last-updated date updated? |
| **Example Code** | Do examples match current API? |

### Extended D: Test Impact Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Existing Tests** | Will any tests break from changes? |
| **Test Coverage** | Are tests for new code in the plan? |
| **Mocking** | Is mocking needed for new deps? |

### Extended E: Migration Safety

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

**Result Format**:
```
[Scenario: Name]
- Coverage: Normal/Edge/Error
- Reproducible: Yes/No
- Independent: Yes/No
```

### Quick Reference

```
Code Mod → A (API compat) + B (Types) + D (Tests)
Docs     → C (Consistency)
Scenario → H (Coverage)
Infra    → F (Deployment)
DB       → E (Migration)
AI       → G (Prompts)
```

---

## Step 6: Autonomous Review

> **Self-judge beyond mandatory/extended items**

**Perspectives**: Security (auth, validation), Performance (bottlenecks, caching), UX (loading, errors), Maintainability (readability), Concurrency (race conditions), Error Recovery (partial failure)

**Output**: `🧠 Autonomous Discoveries: [1: Perspective] Issue → Recommendation`

---

## Step 7: User-Requested Focus

If `"$ARGUMENTS"` contains focus areas, deep-dive:

| Focus | Areas |
|-------|-------|
| `security` | Auth, injection, XSS, sensitive data |
| `performance` | Queries, loops, caching, bundle size |
| `accessibility` | ARIA, keyboard, contrast, screen readers |
| `api` | Backward compatibility, versioning |
| `testing` | Coverage, edge cases, integration |

---

## Step 8: Results Summary

```markdown
# Plan Review Results

## Summary
- **Assessment**: [Pass/Needs Revision]
- **Type**: [Primary / Extended: A,B,D]
- **Findings**: Critical: N / Warning: N / Suggestion: N

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

## Vibe Coding Compliance
| Target | Status |
|--------|--------|
| Functions ≤50 lines | ✅/⚠️/❌ |
| Files ≤200 lines | ✅/⚠️/❌ |
| Nesting ≤3 levels | ✅/⚠️/❌ |

## Extended Review [Activated items only]
## Autonomous Discoveries
## Issues
### 🚨 Critical (Must fix)
### ⚠️ Warning (Should fix)
### 💡 Suggestion
## Reusable Code Found
```

---

## Step 9: Apply Findings to Plan

> **Principle**: Review completion = Plan file improved with findings applied

### 9.1 Map Findings to Sections

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements / Success Criteria | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks & Mitigations | Add item |
| Alternative approach | How (Approach) | Add/modify |
| Scope issue | Scope (In/Out) | Adjust scope |

### 9.2 Apply & Update History

1. Read plan file
2. For each finding: Identify target section, Apply modification, Track change
3. Write updated plan

**Error Handling**: If error, keep original intact, log to History

**Append to Review History**:
```markdown
## Review History

### Review #N (YYYY-MM-DD HH:MM)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | N | N |
| Warning | N | N |
| Suggestion | N | N |

**Changes Made**:
1. **[Type] Section - Item**
   - Issue: [Description]
   - Applied: [Change made]
```

---

## Success Criteria

| Criteria | Threshold |
|----------|-----------|
| Auto-proceed | Critical 0 + Warning ≤1 |
| User confirmation | Critical ≥1 OR Warning ≥2 |

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
