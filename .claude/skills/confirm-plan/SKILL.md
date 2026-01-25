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
- Create plan file in `.pilot/plan/draft/`
- Run auto-review with Interactive Recovery for BLOCKING findings
- Verify 100% requirements coverage

### Quick Reference
```bash
# Extract plan from conversation
PLAN_CONTENT=$(extract_from_conversation "$CONVERSATION")

# Generate plan file name
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_{work_name}.md"

# Requirements verification (BLOCKING if incomplete)
verify_requirements_coverage "$PLAN_CONTENT"

# Auto-review with Interactive Recovery
invoke_plan-reviewer "$PLAN_FILE"
resolve_blocking_findings "$PLAN_FILE"
```

---

## What This Skill Covers

### In Scope
- **Dual-source extraction**: Load decisions from draft file + scan conversation
- **Cross-check verification**: Compare draft vs conversation, detect omissions
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

## Core Philosophy

**No Execution**: Only creates plan file and reviews | **Context-Driven**: Extract from conversation | **English Only**: Plan MUST be in English | **Strict Mode Default**: BLOCKING → Interactive Recovery

---

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 2.5 → 3 → 4 in sequence
- Only stop for BLOCKING findings that require Interactive Recovery

---

## Execution Steps (Summary)

### Step 1: Dual-Source Extraction
1. Load draft file from `.pilot/plan/draft/` (reuse existing or create new)
2. Scan conversation for User Requirements (UR-1, UR-2, ...) and Decisions (D-1, D-2, ...)
3. Cross-check draft vs conversation, flag MISSING items
4. Resolve omissions using AskUserQuestion
5. Extract conversation highlights (code examples, diagrams, CLI commands)
6. Verify 100% requirements coverage (UR → SC mapping)
7. Verify scope completeness (scope vs SC mapping, assumptions verified)
8. Run Self-Contained verification (9-point checklist)

**BLOCKING if**: Requirements incomplete, scope gaps, or self-contained check fails

### Step 2: Create or Update Plan File
- Use absolute path based on Claude Code's initial working directory
- Reuse existing draft or create new one
- Apply full plan template (User Requirements, Context Pack, Success Criteria, PRP Analysis, etc.)
- Include Context Pack Formats and Zero-Knowledge TODO Format sections

### Step 2.5: GPT Delegation Check
- Trigger for large plans (5+ Success Criteria)
- Delegate to GPT Plan Reviewer using codex CLI
- Graceful fallback if Codex not installed

### Step 3: Auto-Review & Auto-Apply
- Invoke plan-reviewer agent
- Review criteria: requirements coverage, SC clarity, dependencies, risks
- Output: <PLAN_COMPLETE> or <PLAN_BLOCKED>
- BLOCKING → Interactive Recovery loop (max 5 iterations)
- Auto-apply Critical, Warning, Suggestion findings

### Step 4: Move to pending
- Move plan file to `.pilot/plan/pending/`
- STOP: Do NOT proceed to /02_execute automatically

---

## Argument Parsing

Parse `$ARGUMENTS` from command invocation:
- `[work_name]`: Optional work name for plan file
- `--lenient`: Bypass BLOCKING findings
- `--no-review`: Skip all review steps

---

## Further Reading

**Internal**: @.claude/skills/confirm-plan/REFERENCE.md - Detailed implementation, Context Pack formats, Zero-Knowledge TODO format, Self-Contained verification checklist | @.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First methodology (Problem-Requirements-Plan)

**External**: [Specification by Example](https://www.amazon.com/Specification-Example-Gojko-Adzic/dp/0321842733) | [User Stories Applied](https://www.amazon.com/Stories-Agile-Development-Software-Cohn/dp/0321205685)

---

**⚠️ MANDATORY**: This skill only creates plan. Run `/02_execute` to implement.
