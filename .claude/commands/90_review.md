---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[plan_path] - path to plan file in pending/ or in_progress/"
allowed-tools: Read, Glob, Grep, Bash(*), Bash(git:*)
---

# /90_review

_Review plan for completeness, gaps, and quality issues before execution._

## Core Philosophy

- **Comprehensive**: Multi-angle review covering mandatory, extended, and gap detection
- **Actionable**: Findings map directly to plan sections
- **Severity-based**: BLOCKING → Interactive Recovery

**Review Checklist**: See @.claude/guides/review-checklist.md
**Gap Detection**: See @.claude/guides/gap-detection.md
**Vibe Coding**: See @.claude/guides/vibe-coding.md

---

## Step 0: Load Plan

```bash
PLAN_PATH="$(ls -1tr .pilot/plan/in_progress/*/*.md .pilot/plan/pending/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] && { echo "No plan found" >&2; exit 1; }
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

---

## Step 3: Mandatory Reviews (8 items)

**Full checklist**: See @.claude/guides/review-checklist.md

Execute all 8 reviews for every plan:

| # | Item | Key Checks |
|---|------|------------|
| 1 | Dev Principles | SOLID, DRY, KISS, YAGNI |
| 2 | Project Structure | File locations, naming, patterns |
| 3 | Requirement Completeness | Explicit + implicit requirements |
| 4 | Logic Errors | Order, dependencies, edge cases, async |
| 5 | Existing Code Reuse | Search utils/, hooks/, common/ |
| 6 | Better Alternatives | Simpler, scalable, testable |
| 7 | Project Alignment | Type check, API docs, affected areas |
| 8 | Long-term Impact | Consequences, debt, scalability, rollback |

---

## Step 4: Vibe Coding Compliance

**Vibe Coding**: See @.claude/guides/vibe-coding.md

| Target | Limit | Check |
|--------|-------|-------|
| Function | ≤50 lines | Plan mentions splitting? |
| File | ≤200 lines | Plan respects boundaries? |
| Nesting | ≤3 levels | Early return specified? |

---

## Step 5: Extended Reviews (By Type)

**Activation Matrix**: See @.claude/guides/review-checklist.md

| Type | Keywords | Reviews |
|------|----------|---------|
| Code Mod | function, component, API, bug fix | A (API compat), B (Types), D (Tests) |
| Documentation | CLAUDE.md, README, guide | C (Consistency) |
| Scenario | test, validation, edge cases | H (Coverage) |
| Infrastructure | Docker, env, deploy, CI/CD | F (Deployment) |
| DB Schema | migration, table, column | E (Migration) |
| AI/Prompts | GPT, Claude, prompts, LLM | G (Prompts) |

---

## Step 6: Autonomous Review

> **Self-judge beyond mandatory/extended items**

**Perspectives**: Security, Performance, UX, Maintainability, Concurrency, Error Recovery

---

## Step 7: Gap Detection Review (MANDATORY)

**Full gap detection**: See @.claude/guides/gap-detection.md

### Severity Levels

| Level | Symbol | Description |
|-------|--------|-------------|
| **BLOCKING** | 🛑 | Cannot proceed, triggers Interactive Recovery |
| **Critical** | 🚨 | Must fix before execution |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

### Gap Detection Categories (9 items)

| # | Category | Trigger Keywords |
|---|----------|-------------------|
| 9.1 | External API | API, fetch, call, endpoint, SDK, HTTP |
| 9.2 | Database Operations | database, migration, schema, table |
| 9.3 | Async Operations | async, await, timeout, promise |
| 9.4 | File Operations | file, read, write, temp, path |
| 9.5 | Environment | env, .env, environment, variable |
| 9.6 | Error Handling | try, catch, error, exception |
| 9.7 | Test Plan Verification | **BLOCKING** - Always run |

### 9.7 Test Plan Verification (BLOCKING)

**Trigger**: Run for ALL plans

| Check | Question |
|-------|----------|
| Scenarios Defined | Are there concrete test scenarios? |
| Test Files Specified | Does each scenario include file path? |
| Test Command Detected | Is test command specified? |
| Coverage Command | Is coverage command included? |
| Test Environment | Does plan include "Test Environment (Detected)"? |

**BLOCKING Conditions**:
- Test Plan section missing
- No test scenarios defined
- Test scenarios lack "Test File" column
- Test command not specified
- Coverage command not specified

---

## Step 8: Results Summary

```markdown
# Plan Review Results

## Summary
- **Assessment**: [Pass/Needs Revision/BLOCKED]
- **Findings**: BLOCKING: N / Critical: N / Warning: N / Suggestion: N

## Mandatory Review (8 items)
| # | Item | Status |
|---|------|--------|
| 1 | Dev Principles | ✅/⚠️/❌ |
| 2-8 | ... | ... |

## Gap Detection Review (MANDATORY)
| # | Category | Status |
|---|----------|--------|
| 9.1 | External API | ✅/🛑 |
| 9.2-9.7 | ... | ... |

## Vibe Coding Compliance
| Target | Status |
|--------|--------|
| Functions ≤50 lines | ✅/⚠️/❌ |
```

---

## Step 9: Apply Findings to Plan

> **Principle**: Review completion = Plan file improved with findings applied

### 9.1 Map Findings to Sections

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks | Add item |

### 9.2 Apply & Update History

1. Read plan file
2. For each finding: Identify target section, Apply modification
3. Write updated plan

**Append to Review History**:
```markdown
## Review History
### Review #N (YYYY-MM-DD)
**Findings Applied**: BLOCKING: N, Critical: N, Warning: N, Suggestion: N
```

---

## Success Criteria

- [ ] All 8 mandatory reviews completed
- [ ] Extended reviews activated by type
- [ ] Gap detection run (BLOCKING items trigger Interactive Recovery)
- [ ] Findings applied to plan
- [ ] Review history updated

---

## Related Guides
- @.claude/guides/review-checklist.md - Comprehensive review checklist
- @.claude/guides/gap-detection.md - External service verification
- @.claude/guides/vibe-coding.md - Code quality standards

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
