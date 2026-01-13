---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[focus] - optional focus areas (security, performance, accessibility, etc.)"
allowed-tools: Read, Glob, Grep, Bash(git:*), Write
---

# /90_review

*Review plans before implementation with comprehensive multi-angle analysis.*

---

## Core Philosophy

- **Type-based review**: Customized for code/docs/scenario/infra/DB/AI plans
- **Mandatory + Extended + Autonomous**: Fixed items + type-specific + self-judgment
- **Proactive investigation**: Resolve "needs investigation" items upfront
- **Efficient progression**: Severity-based conditional checks

---

## Step 0: Load the Plan

### 0.1 Find Plan to Review

Priority order:
1. Explicit path from `"$ARGUMENTS"`
2. Most recent file in `.pilot/plan/in_progress/`
3. Most recent file in `.pilot/plan/pending/`

```bash
PLAN_PATH="$(ls -1tr .pilot/plan/in_progress/*/*.md .pilot/plan/pending/*.md 2>/dev/null | head -1)"

if [ -z "$PLAN_PATH" ]; then
    echo "No plan found to review."
    exit 1
fi

echo "Reviewing plan: $PLAN_PATH"
```

### 0.2 Read Plan Content

Read and extract:
- User requirements
- Execution plan phases
- Acceptance criteria
- Test scenarios
- Constraints and risks

---

## Step 1: Proactive Investigation

> **Principle**: Investigate all "needs investigation/confirmation/review" items upfront

### 1.1 Find Investigation Items

Keywords: "need to investigate", "confirm", "TODO", "check", "verify"

### 1.2 Investigation Methods

| Target | Method | Tools |
|--------|--------|-------|
| Existing code/patterns | Search similar impl | Glob, Grep, Read |
| API docs | Check official docs | WebSearch |
| Dependencies | npm/PyPI registry | Bash(npm/pip info) |

### 1.3 Result Format

```
🔍 Investigation Complete:
[Item 1: Target description]
- Result: ✅/❌ Finding
- Plan update: Modification applied
```

---

## Step 2: Plan Type Detection

### 2.1 Analyze Plan

- Goal of the plan?
- Files/components to modify/create?
- Expected implementation steps?

### 2.2 Type Detection Matrix

| Type | Keywords | Extended Reviews |
|------|----------|------------------|
| **Code Modification** | function, component, API, bug fix | A, B, D |
| **Documentation** | CLAUDE.md, README, guide | C |
| **Scenario** | test, validation, edge cases | H |
| **Infrastructure** | Vercel, env, deploy, CI/CD | F |
| **DB Schema** | migration, table, schema | E |
| **AI/Prompts** | LLM, prompts, AI | G |

**Output**: `📋 Type: [Primary] / Extended: [A, B, D]`

---

## Step 3: Mandatory Reviews (8 items)

> Execute all 8 reviews for every plan

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
☐ Edge cases considered? (null, empty, failure cases)
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

## Step 4: Extended Reviews (By Type)

> Activate based on type detected in Step 2

| Type | Activated | Focus |
|------|-----------|-------|
| A: API Compatibility | ☐ Code mod | Signature/call site impact |
| B: Type Safety | ☐ Code mod | Avoid any, null checks |
| C: Doc Consistency | ☐ Docs | Cross-refs, code sync |
| D: Test Impact | ☐ Code mod | Breaking tests |
| E: Migration Safety | ☐ DB | Rollback, integrity |
| F: Deployment Impact | ☐ Infra | Env vars, duration |
| G: Prompt Quality | ☐ AI | Positive expression |
| H: Scenario Review | ☐ Test | Coverage, reproducibility |

---

## Step 5: Autonomous Review

> Self-judge beyond mandatory/extended items

**Perspectives to check:**
1. **Security**: Auth, input validation, sensitive data
2. **Performance**: Bottlenecks, caching opportunities
3. **UX**: Loading states, error messages, feedback
4. **Maintainability**: Readability, logging
5. **Concurrency**: Race conditions, state sync
6. **Error Recovery**: Partial failure handling

**Output Format:**
```
🧠 Autonomous Discoveries:
[1: Perspective] Issue description → Recommendation
```

---

## Step 6: User-Requested Focus

If `"$ARGUMENTS"` contains focus areas, deep-dive into those:

| Focus | Areas to Check |
|-------|---------------|
| `security` | Auth, injection, XSS, sensitive data |
| `performance` | Queries, loops, caching, bundle size |
| `accessibility` | ARIA, keyboard, contrast, screen readers |
| `api` | Backward compatibility, versioning |
| `testing` | Coverage, edge cases, integration |

---

## Step 7: Results Summary

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

## Extended Review
[Only activated items]

## Autonomous Discoveries
| # | Perspective | Issue | Priority |
|---|-------------|-------|----------|

## Issues
### 🚨 Critical (Must fix)
### ⚠️ Warning (Should fix)
### 💡 Suggestion

## Reusable Code Found
| Planned | Existing | Action |
|---------|----------|--------|
```

---

## Step 8: Apply Review Findings to Plan

> **Principle**: Review completion = Plan file is improved with findings applied

### 8.1 Identify Changes

Map all findings to their target sections:

| Issue Type | Target Section | Apply Method |
|------------|----------------|--------------|
| Missing step | Execution Plan | Add checkbox to relevant Phase |
| Unclear requirement | User Requirements / Success Criteria | Clarify wording |
| Test gap | Test Plan | Add/modify test scenario |
| Risk identified | Risks & Mitigations | Add new risk item |
| Alternative approach | How (Approach) | Add alternative or modify approach |
| Scope issue | Scope (In/Out) | Adjust scope |

### 8.2 Apply Changes

**Apply all findings** (Critical, Warning, Suggestion) to the plan:

1. Read the plan file
2. For each finding:
   - Identify target section
   - Apply modification (add/modify text)
   - Track change for history
3. Write updated plan file

**Error Handling Policy**:
- If error occurs: Keep original plan intact, log error to Review History
- If partial apply: Only log applied changes to History, note unapplied items

### 8.3 Update History

Append to plan's `## Review History` section:

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
1. **[Critical/Warning/Suggestion] Section - Item**
   - Issue: [Description]
   - Applied: [Change made]

2. **[Critical/Warning/Suggestion] Section - Item**
   - Issue: [Description]
   - Applied: [Change made]
```

If `## Review History` doesn't exist, create it.

---

## Success Criteria

| Criteria | Threshold |
|----------|-----------|
| Auto-proceed | Critical 0 + Warning ≤1 |
| User confirmation | Critical ≥1 OR Warning ≥2 |

---

## References

- **Review Extensions**: `.claude/guides/review-extensions.md`
- **3-Tier Docs**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
