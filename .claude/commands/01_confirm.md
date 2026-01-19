---
description: Extract plan from conversation, create file in draft/, auto-apply non-BLOCKING improvements, move to pending
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
---

# /01_confirm

_Extract plan from conversation, create plan file in draft/, auto-apply review improvements (non-BLOCKING), move to pending after review._

> **MANDATORY STOP - CONFIRMATION ONLY**
> This command: 1) Extracts plan, 2) Creates file in draft/, 3) Runs auto-review, 4) Auto-applies non-BLOCKING improvements, 5) Moves to pending, 6) STOPS
> To execute, run `/02_execute` after this completes.

---

## Core Philosophy

- **No Execution**: Only creates plan file and reviews
- **Context-Driven**: Extract plan from conversation
- **English Only**: Plan file MUST be in English
- **Strict Mode Default**: BLOCKING findings trigger Interactive Recovery

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before plan confirmation
> **Skill**: @.claude/skills/confirm-plan/SKILL.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Large plan | Plan has 5+ success criteria (SC items) | Delegate to GPT Plan Reviewer |
| User explicitly requests | "ask GPT", "consult GPT", "review this plan" | Delegate to GPT Plan Reviewer |

**Implementation**:
```bash
# Check plan SC count
PLAN_SC_COUNT=$(grep -c "^SC-" "$PLAN_PATH" 2>/dev/null || echo 0)

# Check Codex CLI and delegate if applicable
if command -v codex &> /dev/null && [ "$PLAN_SC_COUNT" -ge 5 ]; then
    # Delegate to GPT Plan Reviewer
    .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/plan-reviewer.md)"
fi
```

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed trigger detection and delegation flow

---

## Step 1: Extract Plan from Conversation

> **Skill**: @.claude/skills/confirm-plan/SKILL.md

### 1.1 Review Context

Look for: User Requirements, PRP Analysis, Scope, Architecture, Execution Plan, Acceptance Criteria, Test Plan, Risks, Open Questions

**PRP Framework**: See @.claude/guides/prp-framework.md

### 1.2 Validate Completeness

Verify: [ ] User Requirements, [ ] Execution Plan, [ ] Acceptance Criteria, [ ] Test Plan

If missing: Inform user, ask if proceed

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed extraction methodology

---

## Step 1.5: Conversation Highlights Extraction

> **⚠️ CRITICAL**: Capture implementation details from `/00_plan` conversation
> **Skill**: @.claude/skills/confirm-plan/SKILL.md

**Scan For**: Code blocks (```), CLI commands, API patterns, diagrams (ASCII/Mermaid)

**Extract**:
1. Copy exact code/syntax/diagram from conversation
2. Mark with `> **FROM CONVERSATION:**` prefix
3. Add to plan under "Execution Context → Implementation Patterns"

**If none found**: Add note `> No implementation highlights found in conversation` and continue

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed extraction methodology

---

## Step 1.7: Requirements Verification

> **Full methodology**: See @.claude/guides/requirements-verification.md
> **Purpose**: Verify ALL user requirements are captured in the plan
> **Skill**: @.claude/skills/confirm-plan/SKILL.md

### 🎯 MANDATORY ACTION: Verify Requirements Coverage

**Quick Start**:
1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria from PRP Analysis (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Update plan with Requirements Coverage Check

**⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.
Use AskUserQuestion to resolve ALL BLOCKING issues before plan file creation.

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed verification methodology

---

## Step 2: Generate Plan File Name

```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"
[ -z "$WORK_NAME" ] && WORK_NAME="plan"
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_${WORK_NAME}.md"
```

---

## Step 3: Create Plan File

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content MUST be in English
> **Skill**: @.claude/skills/confirm-plan/SKILL.md

**Structure**: User Requirements (Verbatim) → Requirements Coverage Check → PRP Analysis → Scope → Test Environment → Execution Context (Explored Files, Key Decisions, Implementation Patterns) → External Service Integration [if applicable] → Architecture → Vibe Coding Compliance → Execution Plan → Acceptance Criteria → Test Plan → Risks & Mitigations → Open Questions

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed plan template structure

```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content extracted from conversation]
PLAN_EOF
echo "Plan created: $PLAN_FILE"
```

---

## Step 4: Auto-Review with Auto-Apply (Strict Mode)

> **Principle**: Plan validation with auto-apply for non-BLOCKING findings, Interactive Recovery only for BLOCKING
> **Skill**: @.claude/skills/confirm-plan/SKILL.md

### Default Behavior

Always run auto-review with strict mode:
- **Auto-apply**: Critical, Warning, Suggestion findings (non-BLOCKING)
- **Interactive Recovery**: BLOCKING findings only (require user resolution)

### Exception: --no-review and --lenient flags

- `--no-review`: Skip auto-review entirely, proceed to Step 5
- `--lenient`: Convert BLOCKING findings to WARNING, auto-apply all, proceed to Step 5

### 4.2 Onboarding Message

```
🛑 BLOCKING findings prevent execution until resolved.
Non-BLOCKING findings (Critical, Warning, Suggestion) are auto-applied.
This ensures plan quality for independent executors.
Use --lenient to bypass (converts BLOCKING → WARNING).
```

### 4.3 Auto-Invoke Plan-Reviewer Agent

> **🚀 MANDATORY ACTION**: Invoke plan-reviewer agent NOW

```markdown
Task:
  subagent_type: plan-reviewer
  description: "Review plan for completeness and gaps"
  prompt: |
    Review {PLAN_FILE}: 1) Completeness, 2) Gap Detection (APIs, DBs, async, env vars), 3) Feasibility, 4) Clarity
    Return: Severity levels (BLOCKING, Critical, Warning, Suggestion) + specific recommendations
```

**VERIFICATION**: Wait for plan-reviewer agent results before proceeding to Step 4.4

### 4.4 Auto-Apply Non-BLOCKING Findings

> **⚠️ CRITICAL**: Auto-apply ALL non-BLOCKING findings without user prompt

**Auto-Apply Flow**:
1. Parse review results for Critical, Warning, Suggestion findings
2. Apply improvements to plan file automatically
3. Log changes made
4. Re-invoke plan-reviewer to verify improvements

**Implementation**:
```bash
# Extract non-BLOCKING findings
CRITICAL_COUNT=$(grep -c "Critical:" "$PLAN_FILE" 2>/dev/null || echo 0)
WARNING_COUNT=$(grep -c "Warning:" "$PLAN_FILE" 2>/dev/null || echo 0)
SUGGESTION_COUNT=$(grep -c "Suggestion:" "$PLAN_FILE" 2>/dev/null || echo 0)

# Auto-apply improvements
if [ $((CRITICAL_COUNT + WARNING_COUNT + SUGGESTION_COUNT)) -gt 0 ]; then
    echo "Auto-applying $((CRITICAL_COUNT + WARNING_COUNT + SUGGESTION_COUNT)) improvements..."
    # Apply improvements to plan file
    # Log changes made
fi
```

### 4.5 Check BLOCKING Findings

| Condition | Action |
|-----------|--------|
| BLOCKING > 0 AND no --lenient | Enter Interactive Recovery |
| BLOCKING > 0 AND --lenient | Log warning, proceed to Step 5 |
| BLOCKING = 0 | Proceed to Step 5 |

### 4.6 Interactive Recovery Loop (BLOCKING Only)

**Gap Detection**: See @.claude/guides/gap-detection.md

```bash
MAX_ITERATIONS=5
WHILE BLOCKING > 0 AND ITERATION <= MAX_ITERATIONS:
    Use AskUserQuestion for each BLOCKING → Update plan → Re-run plan-reviewer → ITERATION++
```

**Plan Update Format**: External Service Integration table (API Calls Required) OR `> ⚠️ SKIPPED: Deferred to implementation phase`

**See**: @.claude/skills/confirm-plan/REFERENCE.md for detailed implementation

### 4.7 Verify Results

| Result | Action |
|--------|--------|
| BLOCKING = 0 | Proceed to Step 5 (Move to pending) |
| BLOCKING > 0 + Recovery complete | Proceed to Step 5 (Move to pending) |
| BLOCKING > 0 + --lenient | Proceed to Step 5 (Move to pending) |

---

## Step 5: Move Plan to Pending

> **⚠️ CRITICAL**: After auto-review and auto-apply, move plan from draft/ to pending/

### 5.1 Verify Review Complete

Ensure all non-BLOCKING findings have been auto-applied and BLOCKING findings resolved.

### 5.2 Move Plan File

```bash
# Project root detection
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Move from draft/ to pending/
PENDING_FILE="$PROJECT_ROOT/.pilot/plan/pending/$(basename "$PLAN_FILE")"
mv "$PLAN_FILE" "$PENDING_FILE"

echo "Plan moved to pending: $PENDING_FILE"
```

### 5.3 Verify Move Success

```bash
if [ -f "$PENDING_FILE" ] && [ ! -f "$PLAN_FILE" ]; then
    echo "✓ Plan successfully moved from draft/ to pending/"
else
    echo "✗ Error: Plan move failed"
    exit 1
fi
```

---

## Success Criteria

- [ ] Plan file created in `.pilot/plan/draft/`
- [ ] User Requirements (Verbatim) included
- [ ] Requirements Coverage Check completed (Step 1.7)
- [ ] All user requirements mapped to SCs (100% coverage)
- [ ] Non-BLOCKING findings auto-applied (Critical, Warning, Suggestion)
- [ ] BLOCKING findings resolved via Interactive Recovery (or `--lenient` used)
- [ ] Plan extracted from conversation
- [ ] External Service Integration added (if applicable)
- [ ] Auto-review completed with auto-apply (or `--no-review` used)
- [ ] Zero BLOCKING (or `--lenient` used)
- [ ] Plan moved from draft/ to pending/
- [ ] Execution NOT started

---

## STOP

> **MANDATORY STOP** - Plan moved to `.pilot/plan/pending/`
> Next step: `/02_execute`
> This will: Move to `in_progress/`, create active pointer, begin TDD + Ralph Loop

---

## Related Guides

- @.claude/guides/requirements-verification.md - Requirements Verification
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/gap-detection.md - External service verification

---

## References

- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
