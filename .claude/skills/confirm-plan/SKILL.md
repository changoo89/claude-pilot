---
name: confirm-plan
description: Plan confirmation workflow - extract plan from conversation, create file, auto-review with Interactive Recovery. Use for confirming plans after /00_plan.
---

# SKILL: Confirm Plan (Plan Confirmation Workflow)

> **Purpose**: Extract plan from conversation, create plan file, run auto-review with Interactive Recovery
> **Target**: Plan-Reviewer Agent confirming plans after `/00_plan`

---

## Quick Start

### When to Use This Skill
- Confirm plan after `/00_plan` completes
- Create plan file in `.pilot/plan/pending/`
- Run auto-review with Interactive Recovery for BLOCKING findings
- Verify 100% requirements coverage

### Quick Reference
```bash
# Extract plan from conversation
PLAN_CONTENT=$(extract_from_conversation "$CONVERSATION")

# Generate plan file name
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/pending/${TS}_{work_name}.md"

# Requirements verification (BLOCKING if incomplete)
verify_requirements_coverage "$PLAN_CONTENT"

# Auto-review with Interactive Recovery
invoke_plan-reviewer "$PLAN_FILE"
resolve_blocking_findings "$PLAN_FILE"
```

---

## What This Skill Covers

### In Scope
- Plan extraction from `/00_plan` conversation
- Plan file creation with full template structure
- Requirements verification (100% coverage required)
- Conversation highlights extraction (code examples, diagrams)
- Auto-review with Interactive Recovery for BLOCKING findings
- GPT delegation for large plans (5+ SCs)

### Out of Scope
- Plan creation → `/00_plan` command
- Plan execution → `/02_execute` command
- TDD methodology → @.claude/skills/tdd/SKILL.md

---

## Core Concepts

### Requirements Verification (BLOCKING)

**Step 1.7**: Verify 100% requirements coverage before creating plan file

**Quick Start**:
1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Use AskUserQuestion to resolve before proceeding

**⚠️ CRITICAL**: Do NOT proceed to plan file creation if BLOCKING findings exist.

### Conversation Highlights Extraction

**Step 1.5**: Capture implementation details from `/00_plan` conversation

**Scan For**:
- Code blocks (```language, ```)
- CLI commands with specific flags
- API invocation examples
- Architecture diagrams (ASCII/Mermaid)

**Output Format**: Mark with `> **FROM CONVERSATION:**` prefix in plan file

### Auto-Review with Interactive Recovery

**Step 4**: Plan validation with Interactive Recovery for BLOCKING findings

**Default**: Strict mode (BLOCKING → Interactive Recovery)
**Exceptions**: `--no-review` (skip), `--lenient` (BLOCKING → WARNING)

**Workflow**:
1. Invoke plan-reviewer agent
2. Check for BLOCKING findings
3. If BLOCKING > 0 → Interactive Recovery loop
4. Use AskUserQuestion to resolve each BLOCKING
5. Re-run plan-reviewer after updates
6. Continue until BLOCKING = 0 or max iterations (5)

### GPT Delegation

**Trigger**: Plan has 5+ success criteria OR user explicitly requests

**Action**: Delegate to GPT Plan Reviewer via `codex-sync.sh`

**Phase**: PLANNING (files don't exist yet - validate PLAN completeness)

---

## Further Reading

**Internal**: @.claude/skills/confirm-plan/REFERENCE.md - Detailed implementation, step-by-step methodology, Interactive Recovery patterns | @.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First methodology (Problem-Requirements-Plan)

**External**: [Specification by Example](https://www.amazon.com/Specification-Example-Gojko-Adzic/dp/0321842733) | [User Stories Applied](https://www.amazon.com/Stories-Agile-Development-Software-Cohn/dp/0321205685)
