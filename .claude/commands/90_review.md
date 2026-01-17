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

**Direct**: `/90_review {plan_path}`

**Via Plan-Reviewer Agent**: See @.claude/guides/parallel-execution.md - Pattern 4: Parallel Review

**🚀 MANDATORY ACTION**: Invoke plan-reviewer agent NOW using Task tool (see guide for prompt templates).

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

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Before starting review, check if GPT expert review is needed.
> See: @.claude/rules/delegator/triggers.md

### When to Delegate to GPT Plan Reviewer:

| Condition | Action |
|-----------|--------|
| Plan has 5+ success criteria | Delegate to GPT Plan Reviewer |
| Architecture decisions involved | Delegate to GPT Architect |
| Security-sensitive changes | Delegate to GPT Security Analyst |
| Simple plan (< 5 SCs) | Use Claude plan-reviewer agent |

### If Delegation Needed:

1. Check Codex CLI availability:
   ```bash
   if ! command -v codex &> /dev/null; then
       echo "Warning: Codex CLI not installed - falling back to Claude-only review"
       # Skip GPT delegation, use Claude plan-reviewer agent
   fi
   ```
2. Read expert prompt: `Read .claude/rules/delegator/prompts/plan-reviewer.md`
3. Call delegation: `.claude/scripts/codex-sync.sh "read-only" "<prompt>"`
4. Synthesize findings
5. Continue to Step 1

### If No Delegation:

Continue to Step 1 with Claude plan-reviewer agent (Step 4 below).

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

**Full delegation guide**: See @.claude/rules/delegator/orchestration.md

| Scenario | GPT Expert | Trigger |
|----------|------------|---------|
| **Architecture review** | Architect | System design, tradeoffs, scalability |
| **Security review** | Security Analyst | Auth, sensitive data, external APIs |
| **Large plan validation** | Plan Reviewer | 5+ success criteria, complex dependencies |
| **Scope ambiguity** | Scope Analyst | Unclear requirements, multiple interpretations |

**Cost Awareness**: GPT calls cost money - use for high-value analysis only

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
