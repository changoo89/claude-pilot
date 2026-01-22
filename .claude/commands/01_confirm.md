---
description: Extract plan from conversation, create file in draft/, auto-apply non-BLOCKING improvements, move to pending
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
---

# /01_confirm

_Extract plan from conversation, create file, auto-review (non-BLOCKING), move to pending._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 in sequence
- Only stop for BLOCKING findings that require Interactive Recovery

---

## Core Philosophy

**No Execution**: Only creates plan file and reviews | **Context-Driven**: Extract from conversation | **English Only**: Plan MUST be in English | **Strict Mode Default**: BLOCKING → Interactive Recovery

---

## Step 1: Extract Plan from Conversation

**User Requirements (Verbatim)**: Capture all user input with IDs (UR-1, UR-2, ...)

**Success Criteria**: Extract all SC items with verify commands

**PRP Analysis**: What (Functionality), Why (Context), How (Approach)

---

## Step 2: Create Plan File in draft/

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code 실행 위치 (절대 경로 필수)
PROJECT_ROOT="$(pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_${work_name}.md"
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
```

**Note**: Do NOT use relative paths. The plan must always be created in the project where Claude Code was launched, not in any subdirectory being explored.

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

## Step 2.5: GPT Delegation Check

**Trigger**: Large plans (5+ Success Criteria) automatically trigger GPT Plan Reviewer

```bash
# Check if Codex CLI is available
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
else
  # Count Success Criteria in plan
  SC_COUNT=$(grep -c "^- \[ \] \*\*SC-" "$PLAN_FILE" 2>/dev/null || echo 0)

  if [ "$SC_COUNT" -ge 5 ]; then
    echo "Large plan detected ($SC_COUNT SCs) - delegating to GPT Plan Reviewer..."

    # Delegate to GPT Plan Reviewer using codex-sync.sh
    PLAN_CONTENT=$(cat "$PLAN_FILE")
    REVIEWER_PROMPT="You are a Plan Reviewer analyzing a large implementation plan.
PLAN CONTENT:
$PLAN_CONTENT

REVIEW CRITERIA:
- Clarity: Are requirements clear?
- Completeness: Are all SCs measurable?
- Feasibility: Is approach realistic?
- Dependencies: Are they identified?
- Risks: Are they mitigated?

OUTPUT: Quality score (1-10), issues found, recommendations"

    "$PROJECT_ROOT/.claude/scripts/codex-sync.sh" "read-only" "$REVIEWER_PROMPT" "."

    echo "GPT Plan Reviewer analysis complete"
  fi
fi
```

**Note**: Graceful fallback if Codex CLI not installed (continues with Claude-only analysis)

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
# Use same PROJECT_ROOT from Step 2
mkdir -p "$PROJECT_ROOT/.pilot/plan/pending"
mv "$PLAN_FILE" "$PROJECT_ROOT/.pilot/plan/pending/$(basename "$PLAN_FILE")"
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
