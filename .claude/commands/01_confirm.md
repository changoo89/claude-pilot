---
description: Extract plan from conversation, create file in draft/, auto-apply non-BLOCKING improvements, move to pending
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
---

# /01_confirm

_Extract plan from conversation, create file, auto-review (non-BLOCKING), move to pending._

## Core Philosophy

**No Execution**: Only creates plan file and reviews | **Context-Driven**: Extract from conversation | **English Only**: Plan MUST be in English | **Strict Mode Default**: BLOCKING → Interactive Recovery

---

## Step 1: Extract Plan from Conversation

**User Requirements (Verbatim)**: Capture all user input with IDs (UR-1, UR-2, ...)

**Success Criteria**: Extract all SC items with verify commands

**PRP Analysis**: What (Functionality), Why (Context), How (Approach)

---

## Step 2: Create Plan File in draft/

```bash
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE=".pilot/plan/draft/${TS}_${work_name}.md"
mkdir -p .pilot/plan/draft
```

**Plan Template**:
```markdown
# Work Title

## User Requirements (Verbatim)
[UR table with 100% coverage check]

## Success Criteria
- [ ] **SC-1**: [Outcome] - Verify: [command]

## PRP Analysis
### What, Why, How

## Test Plan
[Test scenarios]
```

---

## Step 3: Auto-Review & Auto-Apply

**Invoke plan-reviewer agent** for analysis:

**Findings**:
- **BLOCKING**: Interactive Recovery (AskUserQuestion)
- **Critical**: Auto-apply
- **Warning**: Auto-apply
- **Suggestion**: Auto-apply

**Auto-apply pattern**: Edit plan file with improvements

---

## Step 4: Move to pending

```bash
mkdir -p .pilot/plan/pending
mv "$PLAN_FILE" ".pilot/plan/pending/$(basename "$PLAN_FILE")"
echo "✓ Plan ready for execution: /02_execute"
```

---

## GPT Delegation

| Trigger | Action |
|---------|--------|
| 5+ SCs | Delegate to GPT Plan Reviewer |
| User requests | Delegate to GPT Plan Reviewer |

**Fallback**: `if ! command -v codex &> /dev/null; then echo "Falling back to Claude-only"; return 0; fi`

---

## Related Skills

**confirm-plan**: Full confirmation workflow | **gpt-delegation**: Codex integration with fallback

---

**⚠️ MANDATORY**: This command only creates plan. Run `/02_execute` to implement.
