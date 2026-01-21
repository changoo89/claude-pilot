---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[plan_path] - path to plan file in pending/ or in_progress/"
allowed-tools: Read, Glob, Grep, Bash(*), Bash(git:*)
---

# /review

_Review plan for completeness, gaps, and quality issues before execution._

## Core Philosophy

**Comprehensive**: Multi-angle review | **Actionable**: Findings map to plan sections | **Severity-based**: BLOCKING → Interactive Recovery

---

## Step 1: Load Plan

```bash
PLAN_PATH="${1:-$(find .pilot/plan/pending .pilot/plan/in_progress -name "*.md" -type f 2>/dev/null | head -1)}"
[ -f "$PLAN_PATH" ] || { echo "❌ No plan found"; exit 1; }
```

---

## Step 2: Multi-Angle Parallel Review

Launch 3 parallel agents for comprehensive review from different perspectives:

### Task 2.1: Test Coverage Review

```markdown
Task:
  subagent_type: tester
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate test coverage and verification:
    - Are all SCs verifiable with test commands?
    - Do verify: commands exist and executable?
    - Is coverage threshold specified (≥80%)?
    - Are test scenarios comprehensive?
    Output: TEST_PASS or TEST_FAIL with findings
```

### Task 2.2: Type Safety & Lint Review

```markdown
Task:
  subagent_type: validator
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate type safety and code quality:
    - Are types specified for APIs/functions?
    - Is lint check included in verification?
    - Any potential type-related issues?
    - Code quality standards (SRP, DRY, KISS)?
    Output: VALIDATE_PASS or VALIDATE_FAIL with findings
```

### Task 2.3: Code Quality Review

```markdown
Task:
  subagent_type: code-reviewer
  prompt: |
    Review plan: $PLAN_PATH
    Evaluate code quality and design:
    - Architecture and design patterns?
    - Function/file size limits (≤50/≤200 lines)?
    - Early return pattern applied?
    - Nesting level (≤3)?
    - Potential bugs or edge cases?
    Output: REVIEW_PASS or REVIEW_FAIL with findings
```

**Expected Speedup**: 60-70% faster review (test + type + quality in parallel)

---

## Step 3: Process Findings

**BLOCKING**: Interactive Recovery with AskUserQuestion
**Critical/Warning/Suggestion**: Auto-apply improvements

---

## Step 4: Update Plan

```bash
if [ "$FINDINGS" != "APPROVE" ]; then
    # Edit plan with improvements
    echo "✓ Plan updated with review findings"
fi
```

---

## Related Skills

**gpt-delegation**: Codex integration | **confirm-plan**: Plan validation workflow | **parallel-subagents**: Multi-angle parallel review

---

**Multi-Angle**: Mandatory + Extended + Gap Detection (3 parallel agents)
