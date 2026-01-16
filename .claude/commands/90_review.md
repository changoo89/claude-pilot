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

**Full parallel patterns**: See @.claude/guides/parallel-execution.md - Pattern 4: Parallel Review

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

**For complex plans**: Use parallel multi-angle review (see guide for Security/Quality/Architecture Task templates).

**VERIFICATION**: After sending Task call(s), wait for plan-reviewer agent(s) to return results before proceeding to Step 1.

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

**Full activation matrix**: See @.claude/guides/review-checklist.md - Extended Reviews

| Type | Keywords | Test File Requirement |
|------|----------|----------------------|
| **Code** | function, component, API, bug fix, src/, lib/ | **Required** |
| **Config** | .claude/, settings, rules, template, workflow | **Optional** (N/A allowed) |
| **Documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md | **Optional** (N/A allowed) |
| **Scenario** | test, validation, edge cases | **Required** |
| **Infra** | Vercel, env, deploy, CI/CD | **Required** |
| **DB** | migration, table, schema | **Required** |
| **AI** | LLM, prompts, AI | **Required** |

**Test File Conditional Logic**:
- **Code/Scenario/Infra/DB/AI**: Test file path required (BLOCKING if missing)
- **Config/Documentation**: `N/A` or `Manual` acceptable

**Auto-detection**: See @.claude/guides/review-checklist.md for bash implementation

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

| Check | Code Plans | Config/Doc Plans |
|-------|------------|------------------|
| Scenarios Defined | Required | Required |
| Test Files Specified | Required | **Optional** (N/A allowed) |
| Test Command Detected | Required | Optional |
| Coverage Command | Required | Optional |
| Test Environment | Required | Optional |

**BLOCKING** (Code): Test Plan missing, no scenarios, no test file paths, no test/coverage commands
**BLOCKING** (Config/Doc): Test Plan missing, no scenarios
**Plan Type Detection**: See Step 2

---

## Step 8: Results Summary

```markdown
# Plan Review Results

## Summary
- **Assessment**: [Pass/Needs Revision/BLOCKED]
- **Findings**: BLOCKING: N / Critical: N / Warning: N / Suggestion: N

## Mandatory Review (8 items), Gap Detection (9.1-9.7), Vibe Coding Compliance
| Section | Status |
|---------|--------|
| Dev Principles | ✅/⚠️/❌ |
| External API | ✅/🛑 |
| Functions ≤50 lines | ✅/⚠️/❌ |
```

---

## Step 9: Apply Findings to Plan

> **Principle**: Review completion = Plan file improved with findings applied

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks | Add item |

**Apply & Update History**: Read plan → Apply modifications → Write plan → Append to Review History (findings counts)

---

## Step 10: GPT Expert Review (Optional - For Complex Plans)

> **Purpose**: Leverage GPT experts for high-difficulty analysis beyond standard review
> **Trigger**: Architecture decisions, security concerns, complex plans (5+ SCs)
> **Reference**: @.claude/rules/delegator/orchestration.md

### When to Use GPT Experts

| Scenario | GPT Expert | Trigger |
|----------|------------|---------|
| **Architecture review** | Architect | Plan involves system design, tradeoffs, scalability |
| **Security review** | Security Analyst | Plan handles auth, sensitive data, external APIs |
| **Large plan validation** | Plan Reviewer | 5+ success criteria, complex dependencies |
| **Scope ambiguity** | Scope Analyst | Unclear requirements, multiple interpretations |

### GPT Expert Call Pattern

**Delegation Flow**:

1. **Detect trigger**: Check if plan matches GPT expert scenarios
2. **Read expert prompt**: `Read .claude/rules/delegator/prompts/[expert].md`
3. **Build delegation prompt**: Use 7-section format from `rules/delegation-format.md`
4. **Call codex-sync.sh**:
   ```bash
   .claude/scripts/codex-sync.sh "read-only" "You are a software architect...

   TASK: Review the plan at {PLAN_PATH} for architectural soundness.
   EXPECTED OUTCOME: Architecture assessment with recommendations.
   CONTEXT:
   - Plan scope: {SCOPE_SUMMARY}
   - Technical approach: {APPROACH_SUMMARY}
   - Success criteria: {SC_SUMMARY}

   MUST DO:
   - Evaluate scalability, maintainability, technical feasibility
   - Identify architectural gaps or risks
   - Provide actionable recommendations

   OUTPUT FORMAT:
   Bottom line → Critical issues → Recommendations → Effort estimate"
   ```
5. **Synthesize response**: Extract key findings and apply to plan

### Example: Architecture Review for Complex Plan

**Trigger**: Plan involves microservices architecture or significant system design

```bash
# Before calling GPT, read expert prompt
Read .claude/rules/delegator/prompts/architect.md

# Then delegate
.claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/architect.md)

TASK: Review architecture approach for plan at: $PLAN_PATH

EXPECTED OUTCOME:
- Architecture assessment (sound/needs revision/risk identified)
- Critical architectural issues
- Recommendations for improvements
- Effort estimate (Quick/Short/Medium/Large)

CONTEXT:
$(extract_plan_context "$PLAN_PATH")

MUST DO:
- Evaluate technical feasibility
- Check for scalability concerns
- Identify missing architectural considerations
- Assess long-term maintainability

MUST NOT DO:
- Over-engineer for hypothetical future needs
- Introduce unnecessary complexity

OUTPUT FORMAT:
Bottom line (2-3 sentences)
→ Critical Issues (if any)
→ Recommendations (prioritized)
→ Effort estimate"
```

### Role Split: Claude vs GPT

| Situation | Use Claude Agent | Use GPT Expert |
|-----------|-----------------|----------------|
| Standard plan review | plan-reviewer (Sonnet) | - |
| Large/complex plan (5+ SCs) | plan-reviewer → | **Plan Reviewer (GPT)** |
| Architecture questions | - | **Architect (GPT)** |
| Security concerns | code-reviewer (Opus) → | **Security Analyst (GPT)** |
| Ambiguous scope | - | **Scope Analyst (GPT)** |

### Cost Awareness

- **GPT calls cost money** - Use for high-value analysis only
- **Hybrid approach**: Claude for standard review, GPT for complex cases
- **One well-structured call** beats multiple vague ones
- **Include full context** to avoid retry costs

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
