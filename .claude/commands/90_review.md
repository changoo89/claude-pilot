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

**Review Skill**: See @.claude/skills/review/SKILL.md
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

PLAN_PATH="$(ls -1tr "$PROJECT_ROOT/.claude-pilot/.pilot/plan/in_progress"/*/*.md "$PROJECT_ROOT/.claude-pilot/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] && { echo "No plan found" >&2; exit 1; }
echo "Reviewing: $PLAN_PATH"
```

Read and extract: User requirements, Execution plan, Acceptance criteria, Test scenarios, Constraints, Risks

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Before starting review, check if GPT expert review is needed.
> See: @.claude/rules/delegator/triggers.md

| Condition | Action |
|-----------|--------|
| Plan has 5+ success criteria | Delegate to GPT Plan Reviewer |
| Architecture decisions involved | Delegate to GPT Architect |
| Security-sensitive changes | Delegate to GPT Security Analyst |
| Simple plan (< 5 SCs) | Use Claude plan-reviewer agent |

**Implementation**:
```bash
# Check plan SC count and keywords
PLAN_SC_COUNT=$(grep -c "^SC-" "$PLAN_PATH" 2>/dev/null || echo 0)
HAS_ARCHITECTURE=$(grep -qiE "architecture|tradeoff|design" "$PLAN_PATH" && echo "true" || echo "false")
HAS_SECURITY=$(grep -qiE "auth|credential|security|token" "$PLAN_PATH" && echo "true" || echo "false")

# Check Codex CLI and delegate if applicable
if command -v codex &> /dev/null && ([ "$PLAN_SC_COUNT" -ge 5 ] || [ "$HAS_ARCHITECTURE" = "true" ] || [ "$HAS_SECURITY" = "true" ]); then
    # Delegate to appropriate GPT expert
    .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/[expert].md)"
fi
```

**See**: @.claude/skills/review/REFERENCE.md for detailed trigger detection and delegation flow

---

## Step 1: Type Detection

| Type | Keywords | Test File Required |
|------|----------|---------------------|
| **Code** | function, component, API, bug fix, src/, lib/ | Yes |
| **Config** | .claude/, settings, rules, template, workflow | No (N/A allowed) |
| **Documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md | No (N/A allowed) |
| **Scenario** | test, validation, edge cases | Yes |
| **Infra** | Vercel, env, deploy, CI/CD | Yes |
| **DB** | migration, table, schema | Yes |
| **AI** | LLM, prompts, AI | Yes |

**Test File Logic**: Code/Scenario/Infra/DB/AI require test file paths (BLOCKING if missing). Config/Documentation allow N/A.

**See**: @.claude/skills/review/REFERENCE.md for auto-detection implementation

---

## Step 2: Mandatory Reviews (8 items)

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

**See**: @.claude/skills/review/REFERENCE.md for detailed review criteria

---

## Step 3: Vibe Coding Compliance

| Target | Limit | Check |
|--------|-------|-------|
| Function | ≤50 lines | Plan mentions splitting? |
| File | ≤200 lines | Plan respects boundaries? |
| Nesting | ≤3 levels | Early return specified? |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Step 4: Extended Reviews (By Type)

| Type | Reviews |
|------|---------|
| Code Mod | A (API compat), B (Types), D (Tests) |
| Documentation | C (Consistency) |
| Scenario | H (Coverage) |
| Infrastructure | F (Deployment) |
| DB Schema | E (Migration) |
| AI/Prompts | G (Prompts) |

**See**: @.claude/skills/review/REFERENCE.md for extended review details

---

## Step 5: Gap Detection Review (MANDATORY)

| Level | Symbol | Description |
|-------|--------|-------------|
| **BLOCKING** | 🛑 | Cannot proceed, triggers Interactive Recovery |
| **Critical** | 🚨 | Must fix before execution |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

**Categories**:
- 9.1 External API
- 9.2 Database Operations
- 9.3 Async Operations
- 9.4 File Operations
- 9.5 Environment Variables
- 9.6 Error Handling
- 9.7 Test Plan Verification (BLOCKING)

**See**: @.claude/guides/gap-detection.md for full gap detection methodology

---

## Step 6: Results Summary

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

## Step 7: Apply Findings to Plan

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks | Add item |

**Process**: Read plan → Apply modifications → Write plan → Append to Review History

**See**: @.claude/skills/review/REFERENCE.md for detailed application process

---

## Step 8: Optional Parallel Multi-Angle Review

> **Trigger**: Complex plans (5+ SCs), high-stakes features, system-wide changes
> **Note**: Uses Claude agents in parallel (different from GPT delegation)

**When to Use**: 5+ SCs, security payments auth, system-wide changes
**When NOT to Use**: Simple plans, cost constraints, time-sensitive

**Implementation**:
```bash
# Invoke 3 plan-reviewer agents concurrently
Task: subagent_type=plan-reviewer, prompt="Review from SECURITY angle..."
Task: subagent_type=plan-reviewer, prompt="Review from QUALITY angle..."
Task: subagent_type=plan-reviewer, prompt="Review from ARCHITECTURE angle..."
# Wait for all, merge findings, apply to plan
```

**See**: @.claude/skills/review/REFERENCE.md for parallel review implementation

---

## Step 9: GPT Expert Review (Optional)

> **Trigger**: Architecture decisions, security concerns, complex plans (5+ SCs)

| Scenario | GPT Expert | Trigger |
|----------|------------|---------|
| **Architecture review** | Architect | System design, tradeoffs, scalability |
| **Security review** | Security Analyst | Auth, sensitive data, external APIs |
| **Large plan validation** | Plan Reviewer | 5+ success criteria, complex dependencies |
| **Scope ambiguity** | Scope Analyst | Unclear requirements, multiple interpretations |

**Cost Awareness**: GPT calls cost money - use for high-value analysis only

**See**: @.claude/rules/delegator/orchestration.md for delegation guide

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
