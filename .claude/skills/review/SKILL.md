---
name: review
description: Comprehensive code review with multi-angle analysis using parallel agents
---

# SKILL: Multi-Angle Code Review

> **Purpose**: Comprehensive plan review with gap detection, extended reviews, and GPT expert delegation
> **Target**: plan-reviewer Agent reviewing plans before execution

---

## Quick Start

### When to Use
- Review plan before execution (/01_confirm, /review)
- Detect gaps in external service integration
- Validate test plan completeness

### Quick Reference
```bash
# Load plan → Detect type → Run reviews → Apply findings
/review .pilot/plan/pending/plan.md
```

**In Scope**: 8 mandatory reviews, extended reviews, gap detection, findings application

**Out of Scope**: Plan creation → spec-driven-workflow | Test execution → tdd | GPT delegation → @.claude/rules/delegator/orchestration.md

---

## Execution Steps

**Core Philosophy**: Comprehensive (multi-angle) | Actionable (findings map to sections) | Severity-based (BLOCKING → Interactive Recovery)

---

## ⛔ MAIN ORCHESTRATOR RESTRICTIONS

**MANDATORY** (delegate via Task tool):
- Step 2 parallel review: tester + validator + code-reviewer (parallel)
- Step 4 plan updates: documenter
- Step 9.5 multi-angle (5+ SCs): 3 parallel plan-reviewer agents

**TRIVIAL EXCEPTIONS**: Plan loading, type detection, severity classification

**WHY**: 50-80% context savings

---

## Step 1: Load Plan

```bash
PLAN_PATH="${1:-$(find "$(pwd)/.pilot/plan/pending" "$(pwd)/.pilot/plan/in_progress" -name "*.md" -type f | head -1)}"
[ -f "$PLAN_PATH" ] || { echo "❌ No plan found"; exit 1; }
```

---

## Step 2: Multi-Angle Parallel Review

Launch 3 parallel agents (60-70% faster):

**Task 2.1: Test Coverage**
```
Task: subagent_type: tester, prompt: "Review plan: $PLAN_PATH. Test coverage: SCs verifiable? commands? coverage ≥80%? Output: PASS/FAIL + findings"
```

**Task 2.2: Type Safety & Lint**
```
Task: subagent_type: validator, prompt: "Review plan: $PLAN_PATH. Type safety: types? lint? quality (SRP/DRY/KISS)? Output: PASS/FAIL + findings"
```

**Task 2.3: Code Quality**
```
Task: subagent_type: code-reviewer, prompt: "Review plan: $PLAN_PATH. Quality: architecture? size (≤50/≤200)? nesting ≤3? edge cases? Output: PASS/FAIL + findings"
```

---

## Step 3: Process Findings

| Level | Symbol | Action |
|-------|--------|--------|
| BLOCKING | 🛑 | Interactive Recovery |
| Critical | 🚨 | Must fix |
| Warning | ⚠️ | Should fix |
| Suggestion | 💡 | Nice to have |

```bash
echo "$findings" | grep -q "🛑.*BLOCKING" && { echo "🛑 BLOCKING"; return 1; }
```

---

## Step 4: Update Plan

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks | Add item |
| Missing dependency | Scope | Add requirement |

---

## Review Workflow

**Step 0**: Extract SC count
```bash
sc_count=$(grep -c "^- \[.\] \*\*SC-" "$PLAN_PATH" || echo "0")
```

**Step 1**: Search "needs investigation/confirmation/review" keywords

**Step 2**: Type detection (code, config, docs, scenario, infra, db, ai)

**Step 3**: 8 mandatory reviews
1. Development Principles: SOLID, DRY, KISS, YAGNI
2. Project Structure: File locations, naming
3. Requirement Completeness: Explicit + implicit
4. Logic Errors: Order, dependencies, edge cases
5. Existing Code Reuse: Search utilities, patterns
6. Better Alternatives: Simpler/scalable approaches
7. Project Alignment: Type-check, API docs
8. Long-term Impact: Consequences, technical debt

**Step 5**: Extended reviews (type-activated)
- A: API Compatibility | B: Type Safety | C: Documentation | D: Test Coverage
- E: Migration | F: Deployment | G: Prompt Engineering | H: Scenarios

**Step 6**: Autonomous perspectives
- Security | Performance | UX | Maintainability | Concurrency | Error Recovery

**Step 7**: Gap detection (BLOCKING → Interactive Recovery)
- 9.1: External API | 9.2: Database | 9.3: Async | 9.4: File Ops
- 9.5: Env Vars | 9.6: Error Handling | 9.7: Test Plan (BLOCKING)

**Step 9.5**: Parallel multi-angle (5+ SCs)
```bash
[ "$sc_count" -ge 5 ] && echo "🚀 Parallel Security/Quality/Architecture"
```

**Step 10**: GPT expert (5+ SCs or architecture/security/auth)
```bash
[ "$sc_count" -ge 5 ] || echo "$PLAN_PATH" | grep -qiE "architecture|security|auth" && echo "🤖 GPT"
```

---

## Further Reading

**Internal**: @.claude/skills/review/REFERENCE.md - Detailed review criteria, gap detection, GPT delegation | @.claude/rules/delegator/orchestration.md - GPT expert delegation | @.claude/skills/parallel-subagents/SKILL.md - Multi-angle parallel review | @.claude/agents/code-reviewer.md - Code reviewer output format

**External**: [Code Review by Jason Cohen](https://blog.smartbear.com/code-review/best-practices-for-code-review/) | [The Art of Readable Code](https://www.amazon.com/Art-Readable-Code-Simple/dp/1593272740)
