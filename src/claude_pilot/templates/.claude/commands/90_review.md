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
- **Agent Support**: Can be invoked via plan-reviewer agent for context isolation

**Review Checklist**: See @.claude/guides/review-checklist.md
**Gap Detection**: See @.claude/guides/gap-detection.md
**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

## Agent Invocation Pattern

This command can be invoked directly OR via the plan-reviewer agent:

### Direct Invocation
```bash
/90_review {plan_path}
```

### Via Plan-Reviewer Agent (Recommended for Complex Plans)

### 🚀 MANDATORY ACTION: Plan-Reviewer Agent Invocation

> **YOU MUST invoke the plan-reviewer agent NOW using the Task tool.**
> This is not optional. Execute this Task tool call immediately.

**EXECUTE IMMEDIATELY - DO NOT SKIP**:

```markdown
Task:
  subagent_type: plan-reviewer
  prompt: |
    Review the plan file at: {PLAN_PATH}

    Perform comprehensive analysis:
    1. Completeness Check (all sections present)
    2. Gap Detection (external services, APIs, databases, async, env vars, error handling)
    3. Feasibility Analysis (technical approach sound)
    4. Clarity & Specificity (verifiable SCs, clear steps)
    5. Multi-angle review (Security, Quality, Performance, Testing, Architecture)

    Return structured review with:
    - Severity levels (BLOCKING, Critical, Warning, Suggestion)
    - Specific recommendations for each issue
    - Positive notes for good practices
    - Overall assessment
```

**VERIFICATION**: After sending Task call, wait for plan-reviewer agent to return results before proceeding to Step 1.

### Parallel Multi-Angle Review (For Complex Plans)

### 🚀 MANDATORY ACTION: Parallel Plan-Reviewer Agent Invocation

> **For large or complex plans, YOU MUST invoke multiple plan-reviewer agents NOW using the Task tool.**
> This is not optional. Execute these Task tool calls immediately in the same message.

**EXECUTE IMMEDIATELY - DO NOT SKIP**:

```markdown
# Parallel review angles (optional, for very complex plans)
Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from SECURITY angle:
    - External API security considerations
    - Input validation
    - Authentication/authorization
    - Secret management
    Plan Path: {PLAN_PATH}

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from QUALITY angle:
    - Vibe Coding compliance
    - Code quality standards
    - Testing coverage
    - Documentation completeness
    Plan Path: {PLAN_PATH}

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from ARCHITECTURE angle:
    - System design
    - Component relationships
    - Scalability considerations
    - Integration points
    Plan Path: {PLAN_PATH}
```

**VERIFICATION**: After sending Task calls, wait for all plan-reviewer agents to return results before proceeding.

> **Todo Management for Parallel Review**: When invoking multiple plan-reviewer agents in parallel:
> - Mark all review todos as `in_progress` simultaneously
> - Use [Parallel Group N] prefix to indicate parallel execution
> - Complete all review todos together when ALL agents return

**Note**: Parallel review is resource-intensive. Use only for complex, high-stakes plans where deep analysis from multiple angles is justified.

---

## Step 0: Load Plan

```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

PLAN_PATH="$(ls -1tr "$PROJECT_ROOT/.pilot/plan/in_progress"/*/*.md "$PROJECT_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"
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

| Type | Keywords | Extended Reviews | Test File Requirement |
|------|----------|------------------|----------------------|
| **Code** | function, component, API, bug fix, src/, lib/ | A, B, D | **Required** |
| **Config** | .claude/, settings, rules, template, workflow, documentation | C | **Optional** (N/A allowed) |
| **Documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md | C | **Optional** (N/A allowed) |
| **Scenario** | test, validation, edge cases | H | **Required** |
| **Infra** | Vercel, env, deploy, CI/CD | F | **Required** |
| **DB** | migration, table, schema | E | **Required** |
| **AI** | LLM, prompts, AI | G | **Required** |

### Plan Type Auto-Detection

**Test File Conditional Logic**:

```bash
# Detect if plan is Config/Documentation type
SCOPE_CONTENT=$(grep "## Scope" "$PLAN_PATH" 2>/dev/null || echo "")
SCOPE_IN_SCOPE=$(grep "## Scope" "$PLAN_PATH" -A 20 2>/dev/null || echo "")

# Check for Config/Documentation patterns
if echo "$SCOPE_CONTENT" | grep -q "\.claude/\|settings\|rules/\|workflow\|template"; then
    PLAN_TYPE="Config"
    TEST_FILE_REQUIRED="Optional"
elif echo "$SCOPE_CONTENT" | grep -qi "CLAUDE\.md\|README\|documentation\|guide\|CONTEXT\.md"; then
    PLAN_TYPE="Documentation"
    TEST_FILE_REQUIRED="Optional"
elif echo "$SCOPE_IN_SCOPE" | grep -q "src/\|lib/\|component\|function\|API"; then
    PLAN_TYPE="Code"
    TEST_FILE_REQUIRED="Required"
else
    PLAN_TYPE="Code"
    TEST_FILE_REQUIRED="Required"
fi
```

**Conditional Test File Validation**:

| Plan Type | Test File Column Value | Acceptable Values |
|-----------|------------------------|-------------------|
| **Code** | Required | `tests/test_xxx.py`, `__tests__/xxx.test.ts`, etc. |
| **Config** | Optional | `N/A`, `Manual`, or actual test file |
| **Documentation** | Optional | `N/A`, `Manual`, or actual test file |

**Config/Documentation Plans**: When scope only includes `.claude/`, `CLAUDE.md`, `README`, `CONTEXT.md`, or documentation files, the Test File column may contain `N/A` or `Manual` without triggering a BLOCKING finding.

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

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

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

| Check | Question | Code Plans | Config/Doc Plans |
|-------|----------|------------|------------------|
| Scenarios Defined | Are there concrete test scenarios? | Required | Required |
| Test Files Specified | Does each scenario include file path? | Required | **Optional** (N/A allowed) |
| Test Command Detected | Is test command specified? | Required | Optional |
| Coverage Command | Is coverage command included? | Required | Optional |
| Test Environment | Does plan include "Test Environment (Detected)"? | Required | Optional |

**BLOCKING Conditions** (Code Plans):
- Test Plan section missing
- No test scenarios defined
- Test scenarios lack "Test File" column with valid path
- Test command not specified
- Coverage command not specified

**BLOCKING Conditions** (Config/Documentation Plans):
- Test Plan section missing
- No test scenarios defined

**Note**: For Config/Documentation plans, "Test File" column may contain `N/A` or `Manual` without triggering BLOCKING. Test command and coverage command are optional but recommended if applicable.

**Plan Type Detection**: See Step 2: Type Detection for auto-detection logic.

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
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
