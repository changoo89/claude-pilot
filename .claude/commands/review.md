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

## Step 2: Invoke Plan-Reviewer Agent

```markdown
Task: subagent_type: plan-reviewer
prompt: |
  Review plan: $PLAN_PATH
  Evaluate: Clarity, Verifiability, Completeness, Big Picture
  Output: APPROVE/REJECT with justification
```

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

**gpt-delegation**: Codex integration | **confirm-plan**: Plan validation workflow

---

**Multi-Angle**: Mandatory + Extended + Gap Detection
