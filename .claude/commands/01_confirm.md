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

## Step 1: Dual-Source Extraction

### Step 1.1: Load Draft File

**Strategy**: Reuse draft from /00_plan when available, create new if not found.

```bash
PROJECT_ROOT="$(pwd)"

# First, look for *_draft.md (new naming)
DRAFT_FILE="$(find "$PROJECT_ROOT/.pilot/plan/draft" -name "*_draft.md" -type f 2>/dev/null | sort -r | head -1)"

# Backward compatibility: if no draft.md found, look for *_decisions.md (old naming)
if [ -z "$DRAFT_FILE" ]; then
    DECISIONS_FILE="$(find "$PROJECT_ROOT/.pilot/plan/draft" -name "*_decisions.md" -type f 2>/dev/null | sort -r | head -1)"
    if [ -n "$DECISIONS_FILE" ]; then
        echo "⚠️ Found legacy *_decisions.md file: $DECISIONS_FILE"
        echo "   Will rename to *_draft.md for backward compatibility"
        DRAFT_FILE="$DECISIONS_FILE"
    fi
fi

if [ -n "$DRAFT_FILE" ]; then
    echo "✓ Found draft file: $DRAFT_FILE"
    DRAFT_EXISTS=true
else
    echo "⚠️ No draft file found - will create new draft file"
    DRAFT_EXISTS=false
fi
```

**Parse Draft Content** if file exists:
- Extract Decisions table (D-1, D-2, etc.)
- Extract User Requirements table (UR-1, UR-2, etc.)
- Preserve existing content for merging

### Step 1.2: Scan Conversation (LLM Context)

LLM scans entire `/00_plan` conversation to extract:
- User Requirements (Verbatim) with IDs (UR-1, UR-2, ...)
- Decisions, scope confirmations, approach selections, constraints

### Step 1.3: Cross-Check

Compare draft vs conversation. Flag MISSING items (in conversation but not in draft).

### Step 1.4: Resolve Omissions

If MISSING items found, use AskUserQuestion (multi-select) to resolve:

```markdown
AskUserQuestion:
  question: "The following items were found in conversation but not in decisions log. Select items to include:"
  header: "Omissions"
  multiSelect: true
  options:
    - label: "[Item 1]"
      description: "Include in plan"
    - label: "[Item 2]"
      description: "Include in plan"
    - label: "Mark all as out of scope"
      description: "Exclude all missing items"
```

After resolution, proceed to Step 2.

---

## Step 2: Create or Update Plan File in draft/

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

### If Draft Exists (reuse and update)

```bash
# Use the existing DRAFT_FILE from Step 1.1
if [ "$DRAFT_EXISTS" = true ]; then
    PLAN_FILE="$DRAFT_FILE"
    echo "✓ Reusing existing draft: $PLAN_FILE"
else
    # Create new draft file
    TS="$(date +%Y%m%d_%H%M%S)"
    PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_draft.md"
    echo "✓ Creating new draft: $PLAN_FILE"
fi
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
```

**Strategy**:
- **If draft exists**: Reuse and update existing file with complete plan content (merge draft + conversation extraction)
- **If not found**: Create new draft file with complete plan content
- **Backward compatibility**: If `*_decisions.md` found, rename to `*_draft.md` before updating

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

    # Delegate to GPT Plan Reviewer using direct codex CLI
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

    codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "$REVIEWER_PROMPT"

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
