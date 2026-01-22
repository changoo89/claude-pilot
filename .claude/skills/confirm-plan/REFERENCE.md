# Confirm Plan - Detailed Reference

> **Companion**: `SKILL.md` | **Purpose**: Detailed implementation reference for plan confirmation workflow

---

## Detailed Step Implementation

### Step 0.5: GPT Delegation Trigger Check

> **Full details**: See @.claude/skills/gpt-delegation/REFERENCE.md
> **Purpose**: Determine if GPT expert review is needed before plan confirmation

**Trigger Detection**:
- Large plan (5+ success criteria)
- User explicitly requests ("ask GPT", "consult GPT", "review this plan")

**Action**: Delegate to GPT Plan Reviewer via `codex-sync.sh`

---

### Step 1: Dual-Source Extraction

> **Purpose**: Extract from both draft decisions file AND conversation to prevent omissions
> **PRP Framework**: See @.claude/skills/spec-driven-workflow/SKILL.md

#### Step 1.1: Load Draft Decisions File

```bash
PROJECT_ROOT="$(pwd)"
DECISIONS_FILE="$(find "$PROJECT_ROOT/.pilot/plan/draft" -name "*_decisions.md" -type f 2>/dev/null | sort -r | head -1)"

if [ -n "$DECISIONS_FILE" ]; then
    echo "✓ Found decisions file: $DECISIONS_FILE"
    # Parse Decisions table (D-1, D-2, ...)
else
    echo "⚠️ No decisions file found - proceeding with conversation-only extraction"
fi
```

#### Step 1.2: Scan Conversation (LLM Context)

LLM scans entire `/00_plan` conversation to extract:
- User Requirements (Verbatim) with IDs (UR-1, UR-2, ...)
- All decisions and agreements made
- Scope confirmations (in/out)
- Approach selections
- Constraints specified

#### Step 1.3: Cross-Check

Compare draft decisions with conversation scan:

```markdown
### Cross-Check Results

| Source | Item | In Draft? | In Conversation? | Status |
|--------|------|-----------|------------------|--------|
| Draft | D-1: [decision] | ✅ | ✅ | OK |
| Draft | D-2: [decision] | ✅ | ✅ | OK |
| Conversation | [requirement] | ❌ | ✅ | ⚠️ MISSING |
```

#### Step 1.4: Resolve Omissions

If MISSING items found, use AskUserQuestion (multi-select):

```markdown
AskUserQuestion:
  question: "Items found in conversation but not in decisions log. Select items to include:"
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

**Extraction Checklist** (after resolution):
- [ ] User Requirements (Verbatim)
- [ ] PRP Analysis (What, Why, How, Success Criteria, Constraints)
- [ ] Execution Plan
- [ ] Acceptance Criteria
- [ ] Test Plan
- [ ] Risks & Mitigations
- [ ] Open Questions

**Validation**: If any required section missing, inform user and ask to proceed

---

### Step 1.5: Conversation Highlights Extraction

> **Purpose**: Ensure executor has concrete "how to implement" guidance

**Scan Conversation For**:
- Code Examples (fenced blocks, inline snippets)
- Syntax Patterns (CLI commands, API calls, configurations)
- Architecture Diagrams (ASCII art, Mermaid charts)

**Output Format**:
```markdown
### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```typescript
> function validateUser(user: User): boolean {
>   return user.email.endsWith('@example.com');
> }
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> npm install --save-dev typescript
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```mermaid
> graph TD
>   A[User] --> B[Login]
>   B --> C[Dashboard]
> ```
```

**If No Highlights Found**: Add note "No implementation highlights found in conversation"

---

### Step 1.7: Requirements Verification

> **Full methodology**: See section below

**Quick Process**:
1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria from PRP Analysis (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Update plan with Requirements Coverage Check

**Requirements Coverage Table**:
```markdown
### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1 | Mapped |
| UR-2 | ✅ | SC-2 | Mapped |
| UR-3 | ✅ | SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |
```

**BLOCKING Resolution**: Use AskUserQuestion if any requirement unmapped

---

### Step 2: Generate Plan File Name

```bash
# Project root detection
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Create pending directory
mkdir -p "$PROJECT_ROOT/.pilot/plan/pending"

# Extract work name from arguments
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"
[ -z "$WORK_NAME" ] && WORK_NAME="plan"

# Generate timestamp
TS="$(date +%Y%m%d_%H%M%S)"

# Create plan file path
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/pending/${TS}_${WORK_NAME}.md"
```

**Filename format**: `YYYYMMDD_HHMMSS_{work_name}.md`

---

### Step 3: Create Plan File

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content MUST be in English
> **Template**: See @.claude/commands/01_confirm.md for full plan template

**Quick Structure**:
- User Requirements (Verbatim) + Coverage Check
- PRP Analysis (What, Why, How, Success Criteria, Constraints)
- Scope (In/Out)
- Test Environment (Detected)
- Execution Context (Planner Handoff)
- External Service Integration
- Architecture
- Vibe Coding Compliance
- Execution Plan
- Acceptance Criteria
- Test Plan
- Risks & Mitigations
- Open Questions
- Review History

**Write File**:
```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content extracted from conversation]
PLAN_EOF
```

**Verification**:
```bash
if [ -f "$PLAN_FILE" ]; then
    echo "✓ Plan file exists"
    LINE_COUNT=$(wc -l < "$PLAN_FILE")
    echo "✓ Plan file: $LINE_COUNT lines"
else
    echo "✗ Plan file creation failed"
    exit 1
fi
```

---

### Step 4: Auto-Review

> **Principle**: Plan validation with Interactive Recovery for BLOCKING findings

**Default Behavior**: Always run auto-review with strict mode

**Exception Flags**:
- `--no-review`: Skip auto-review entirely
- `--lenient`: Convert BLOCKING findings to WARNING

**Auto-Invoke Plan-Reviewer Agent**:
```markdown
Task:
  subagent_type: plan-reviewer
  description: "Review plan for completeness and gaps"
  prompt: |
    Review the plan file at: {PLAN_FILE}

    Focus on:
    1. Completeness Check (all sections present)
    2. Gap Detection (external services, APIs, databases, async, env vars, error handling)
    3. Feasibility Analysis (technical approach sound)
    4. Clarity & Specificity (verifiable SCs, clear steps)

    Return structured review with severity levels:
    - BLOCKING: Prevents execution
    - Critical: Should fix
    - Warning: Consider fixing
    - Suggestion: Nice to have
```

**BLOCKING Findings Handling**:

| Condition | Action |
|-----------|--------|
| BLOCKING > 0 AND no --lenient | Enter Interactive Recovery |
| BLOCKING > 0 AND --lenient | Log warning, proceed |
| BLOCKING = 0 | Proceed |

**Interactive Recovery Loop**:
```bash
MAX_ITERATIONS=5
ITERATION=1

while [ $BLOCKING_COUNT -gt 0 ] && [ $ITERATION -le $MAX_ITERATIONS ]; do
    # Use AskUserQuestion for each BLOCKING
    # Options: Fix now, Add as TODO, Mark out of scope

    # Update plan with responses
    # Re-run plan-reviewer agent
    # Check if BLOCKING resolved

    BLOCKING_COUNT=$(grep -c "BLOCKING" "$PLAN_FILE")
    ITERATION=$((ITERATION + 1))
done
```

**Plan Update Format**:
```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status |
|------|------|----|----------|----------|--------|
| [Description] | [Service] | [Service] | [Path] | [Package] | [New] |

[OR if skipped]
> ⚠️ SKIPPED: Deferred to implementation phase
```

---

## Testing

### Manual Testing

**Standard Confirmation**:
```bash
/01_confirm "test_plan"
```
Expected: Plan created in pending/, auto-review run, BLOCKING findings resolved

**Skip Review**:
```bash
/01_confirm "test_plan" --no-review
```
Expected: Plan created, auto-review skipped

**Lenient Mode**:
```bash
/01_confirm "test_plan" --lenient
```
Expected: BLOCKING converted to WARNING

### Verification Checklist

After running `/01_confirm`:
- [ ] Plan file created in `.pilot/plan/pending/`
- [ ] User Requirements (Verbatim) section included
- [ ] Requirements Coverage Check completed
- [ ] All user requirements mapped to Success Criteria
- [ ] BLOCKING findings resolved (or --lenient used)
- [ ] Plan content extracted from conversation
- [ ] External Service Integration added (if applicable)
- [ ] Vibe Coding Compliance added
- [ ] Auto-review completed (or skipped with --no-review)
- [ ] Execution NOT started

---

**Reference Version**: claude-pilot 4.4.12
**Last Updated**: 2026-01-22
**Change**: Added Dual-Source Extraction (Step 1.1-1.4) for omission prevention
