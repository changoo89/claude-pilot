# Confirm Plan - Detailed Reference

> **Companion**: `SKILL.md` | **Purpose**: Detailed implementation reference for plan confirmation workflow

---

## Detailed Step Implementation

### Step 0.5: GPT Delegation Trigger Check (Detailed)

> **Purpose**: Determine if GPT expert review is needed before plan confirmation
> **Decision**: Based on plan complexity and user requests

#### Trigger Detection Table

| Trigger | Signal | Action |
|---------|--------|--------|
| Large plan | Plan has 5+ success criteria (SC items) | Delegate to GPT Plan Reviewer |
| User explicitly requests | "ask GPT", "consult GPT", "review this plan" | Delegate to GPT Plan Reviewer |

#### Implementation

```bash
# Check plan SC count
PLAN_SC_COUNT=$(grep -c "^SC-" "$PLAN_PATH" 2>/dev/null || echo 0)

# Check for user request keywords
USER_REQUEST=$(cat "$PLAN_PATH" | head -50)
EXPLICIT_REQUEST=$(echo "$USER_REQUEST" | grep -qiE "ask GPT|consult GPT|review this plan" && echo "true" || echo "false")

# Decision logic
if [ "$PLAN_SC_COUNT" -ge 5 ] || [ "$EXPLICIT_REQUEST" = "true" ]; then
    # Check Codex CLI availability
    if ! command -v codex &> /dev/null; then
        echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
        USE_GPT_DELEGATION="false"
    else
        USE_GPT_DELEGATION="true"
    fi

    # Delegate to GPT Plan Reviewer
    if [ "$USE_GPT_DELEGATION" = "true" ]; then
        .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/plan-reviewer.md)"
    fi
fi
```

#### Delegation Prompt Template

**For GPT Plan Reviewer**:
```markdown
You are a plan review expert. Review this plan for completeness and clarity.

TASK: Review plan document for implementation completeness.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on plan clarity and completeness.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: [plan content]
- Goals: [what the plan is trying to achieve]

CONSTRAINTS:
- This is a PLAN review - do NOT check file system
- Focus on clarity, completeness, verifiability
- Assume implementation hasn't started

MUST DO:
- Evaluate all 4 criteria (Clarity, Verifiability, Completeness, Big Picture)
- Simulate implementing from the plan
- Provide specific improvements if rejecting

MUST NOT DO:
- Check file system for files that don't exist yet
- Expect implementation to be complete
- Rubber-stamp without real analysis

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
Summary: [4-criteria assessment]
[If REJECT: Top 3-5 critical improvements needed]
```

---

### Step 1: Extract Plan from Conversation (Detailed)

> **Purpose**: Extract plan content from /00_plan conversation
> **PRP Framework**: See @.claude/skills/spec-driven-workflow/SKILL.md

#### 1.1 Review Context

**Look for these sections**:
- **User Requirements**: What the user wants to accomplish
- **PRP Analysis**:
  - What (Functionality): Objective
  - Why (Context): Business value, rationale
  - How (Approach): Implementation strategy
  - Success Criteria: Measurable acceptance criteria
  - Constraints: Limitations, dependencies
- **Scope**: Inclusions and exclusions
- **Architecture**: System design, components
- **Execution Plan**: Phases, tasks, timeline
- **Acceptance Criteria**: Definition of done
- **Test Plan**: Test scenarios, coverage
- **Risks**: Potential issues, mitigations
- **Open Questions**: Unresolved items

**Validation Checklist**:
```bash
# Check for required sections
REQUIRED_SECTIONS=(
    "User Requirements"
    "PRP Analysis"
    "Execution Plan"
    "Acceptance Criteria"
    "Test Plan"
)

MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "$section" "$CONVERSATION"; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
    echo "Warning: Missing sections: ${MISSING_SECTIONS[*]}"
    echo "Ask user if they want to proceed with incomplete plan"
fi
```

#### 1.2 Validate Completeness

**Verify**: These sections MUST exist before creating plan file
- [ ] User Requirements
- [ ] Execution Plan
- [ ] Acceptance Criteria
- [ ] Test Plan

**If missing**: Inform user and ask if proceed

**Example**:
```
⚠️  Plan is incomplete
Missing sections:
- Test Plan
- Acceptance Criteria

Options:
1) Add missing sections now
2) Proceed with incomplete plan (not recommended)

Choose option (1/2):
```

---

### Step 1.5: Conversation Highlights Extraction (Detailed)

> **⚠️ CRITICAL**: Capture implementation details from `/00_plan` conversation
> **Purpose**: Ensure executor has concrete "how to implement" guidance

#### 1.5.1 Scan Conversation For

**Code Examples**:
- Fenced code blocks (```language, ```)
- Inline code snippets
- Function signatures
- Class definitions

**Syntax Patterns**:
- CLI commands with specific flags/options
- API invocation examples
- Package installation commands
- Configuration examples

**Architecture Diagrams**:
- ASCII art diagrams
- Mermaid charts (```mermaid)
- Flow diagrams
- Sequence diagrams

#### 1.5.2 Extraction Process

**Step 1**: Scan conversation for code blocks
```bash
# Extract all fenced code blocks
grep -A 10 '```' "$CONVERSATION" | head -100
```

**Step 2**: Extract CLI commands
```bash
# Extract command patterns
grep -oE '(npm|yarn|pip|git|curl|wget)[^[:space:]]+' "$CONVERSATION"
```

**Step 3**: Extract diagrams
```bash
# Extract Mermaid charts
grep -A 20 '```mermaid' "$CONVERSATION"
```

**Step 4**: Format for plan file
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

#### 1.5.3 Output Format

**Add to plan under**:
```markdown
## Execution Context (Planner Handoff)

### Implementation Patterns (FROM CONVERSATION)
[Extracted highlights]
```

#### 1.5.4 If No Highlights Found

```markdown
### Implementation Patterns (FROM CONVERSATION)
> No implementation highlights found in conversation
```

Continue to Step 2.

---

### Step 1.7: Requirements Verification (Detailed)

> **Full methodology**: See @.claude/skills/confirm-plan/REFERENCE.md
> **Purpose**: Verify ALL user requirements are captured in the plan

#### 🎯 MANDATORY ACTION: Verify Requirements Coverage

**Quick Start**:
1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria from PRP Analysis (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Update plan with Requirements Coverage Check

#### Extraction Process

**Step 1**: Extract User Requirements (Verbatim)
```markdown
## User Requirements (Verbatim)

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "Fix authentication bug" | Auth fix needed |
| UR-2 | "Add user profile page" | New feature |
| UR-3 | "Optimize database queries" | Performance |
```

**Step 2**: Extract Success Criteria
```markdown
## Success Criteria

- SC-1: Authentication works correctly
- SC-2: User profile page created
- SC-3: Database queries optimized
```

**Step 3**: Verify Mapping
```bash
# Check each UR has corresponding SC
for ur_id in 1 2 3; do
    ur_summary=$(grep "^UR-$ur_id" "$PLAN_PATH" | cut -d'|' -f3)
    sc_found=$(grep -i "$ur_summary" "$PLAN_PATH" | grep -c "^SC-")

    if [ "$sc_found" -eq 0 ]; then
        echo "BLOCKING: UR-$ur_id not mapped to any SC"
        BLOCKING_COUNT=$((BLOCKING_COUNT + 1))
    fi
done
```

**Step 4**: Requirements Coverage Check
```markdown
### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1 | Mapped |
| UR-2 | ✅ | SC-2 | Mapped |
| UR-3 | ✅ | SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

**BLOCKING** if any requirement missing
```

#### Step 5: BLOCKING Resolution

**If BLOCKING findings exist**:
```
🛑 BLOCKING: Requirements Coverage Incomplete

Missing mappings:
- UR-3: "Optimize database queries" → No SC found

Interactive Recovery Options:
A) Add missing SC to plan
B) Mark requirement as out of scope
C) Cancel and revise plan

Choose option (A/B/C):
```

**Use AskUserQuestion** to resolve ALL BLOCKING issues before plan file creation.

**⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.

---

### Step 2: Generate Plan File Name (Detailed)

```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Create pending directory if not exists
mkdir -p "$PROJECT_ROOT/.pilot/plan/pending"

# Extract work name from arguments (or default to "plan")
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"
[ -z "$WORK_NAME" ] && WORK_NAME="plan"

# Generate timestamp
TS="$(date +%Y%m%d_%H%M%S)"

# Create plan file path
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/pending/${TS}_${WORK_NAME}.md"

echo "Plan file: $PLAN_FILE"
```

**Filename format**: `YYYYMMDD_HHMMSS_{work_name}.md`

**Examples**:
- `20260119_143022_fix_auth_bug.md`
- `20260119_143022_add_user_profile.md`
- `20260119_143022_optimize_database.md`

---

### Step 3: Create Plan File (Detailed)

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content MUST be in English

#### 3.1 Plan Template Structure

```markdown
# {Work Name}

> **Generated**: {timestamp} | **Work**: {work_name} | **Location**: {plan_path}

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | [{timestamp}] | "{user input verbatim}" | {summary} |
| UR-2 | [{timestamp}] | "{user input verbatim}" | {summary} |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1 | Mapped |
| UR-2 | ✅ | SC-2 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: {clear objective statement}

**Scope**:
- **In Scope**: {what's included}
- **Out of Scope**: {what's excluded}

### Why (Context)

**Current Problem**: {problem description}

**Business Value**: {why this matters}

### How (Approach)

**Implementation Strategy**:
1. {Step 1}
2. {Step 2}
3. {Step 3}

### Success Criteria

- [ ] **SC-1**: {Success criterion 1}
- [ ] **SC-2**: {Success criterion 2}
- [ ] **SC-3**: {Success criterion 3}

### Constraints

- **Technical**: {technical limitations}
- **Patterns**: {existing conventions}
- **Timeline**: {time constraints}

---

## Scope

### In Scope
- {Item 1}
- {Item 2}

### Out of Scope
- {Item 1}
- {Item 2}

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| {Framework} | {version} | {command} | {command} |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| {file} | {purpose} | {lines} | {notes} |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| {Decision} | {rationale} | {alternative} |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```{language}
> [exact code from conversation]
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> [exact command from conversation]
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> [exact diagram from conversation]
> ```

### Assumptions
- {Assumption 1}
- {Assumption 2}

### Dependencies
- {Dependency 1}
- {Dependency 2}

---

## External Service Integration

### API Calls Required

| Call | From | To | Endpoint | SDK/HTTP | Status |
|------|------|----|----------|----------|--------|
| [{Description}] | [{Service}] | [{Service}] | [{Path}] | [{Package}] | [New] |

### New Endpoints to Create

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|

### Environment Variables Required

| Variable | Purpose | Default | Required |
|----------|--------|---------|---------|
| [{VAR}] | [{purpose}] | [{default}] | [Yes/No] |

### Error Handling Strategy

- {Strategy 1}
- {Strategy 2}

---

## Architecture

### System Design
{Description}

### Components
| Component | Purpose | Integration |
|-----------|---------|-------------|
| [{Component}] | [{purpose}] | [{integration}] |

### Data Flow
{Description}

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | {strategy} |
| File | ≤200 lines | {strategy} |
| Nesting | ≤3 levels | {strategy} |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

1. **Phase 1**: {description} ({owner}, {time})
2. **Phase 2**: {description} ({owner}, {time})
3. **Phase 3**: {description} ({owner}, {time})

---

## Acceptance Criteria

- [ ] **AC-1**: {criteria 1}
- [ ] **AC-2**: {criteria 2}
- [ ] **AC-3**: {criteria 3}

---

## Test Plan

| ID | Scenario | Expected | Type |
|----|----------|----------|------|
| TS-1 | {scenario 1} | {expected} | {type} |
| TS-2 | {scenario 2} | {expected} | {type} |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| {risk} | {impact} | {probability} | {mitigation} |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| {question} | {High/Medium/Low} | {Open/Resolved} |

---

## Review History

### {Date} - Auto-Review

**Summary**: {assessment}

**Findings**:
- BLOCKING: {count}
- Critical: {count}
- Warning: {count}
- Suggestion: {count}

**Changes Made**: {description}

**Updated Sections**: {list}
```

#### 3.2 Write File

```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content extracted from conversation]
PLAN_EOF

echo "✓ Plan created: $PLAN_FILE"
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

### Step 4: Auto-Review (Detailed)

> **Principle**: Plan validation with Interactive Recovery for BLOCKING findings

#### 4.1 Default Behavior

Always run auto-review with strict mode (BLOCKING findings trigger Interactive Recovery).

**Exception Flags**:
- `--no-review`: Skip auto-review entirely, proceed to STOP
- `--lenient`: Convert BLOCKING findings to WARNING, proceed to STOP

#### 4.2 Onboarding Message

```
🛑 BLOCKING findings prevent execution until resolved.
This ensures plan quality for independent executors.
Use --lenient to bypass (converts BLOCKING → WARNING).
```

#### 4.3 Auto-Invoke Plan-Reviewer Agent

**🚀 MANDATORY ACTION**: Plan-Reviewer Agent Invocation

```markdown
Task:
  subagent_type: plan-reviewer
  description: "Review plan for completeness and gaps"
  prompt: |
    Review the plan file at: {PLAN_FILE}

    Perform comprehensive analysis:
    1. Completeness Check (all sections present)
    2. Gap Detection (external services, APIs, databases, async, env vars, error handling)
    3. Feasibility Analysis (technical approach sound)
    4. Clarity & Specificity (verifiable SCs, clear steps)

    Return structured review with:
    - Severity levels (BLOCKING, Critical, Warning, Suggestion)
    - Specific recommendations for each issue
    - Positive notes for good practices
    - Overall assessment

    Focus on:
    - External Service Integration gaps (API calls, env vars, error handling)
    - Database Operations gaps (migrations, rollback)
    - Async Operations gaps (timeouts, concurrent limits)
    - File Operations gaps (path resolution, cleanup)
    - Success Criteria verification commands
```

#### 4.4 Check BLOCKING Findings

| Condition | Action |
|-----------|--------|
| BLOCKING > 0 AND no --lenient | Enter Interactive Recovery |
| BLOCKING > 0 AND --lenient | Log warning, proceed to STOP |
| BLOCKING = 0 | Proceed to STOP |

#### 4.5 Interactive Recovery Loop

**Gap Detection**: See @.claude/skills/confirm-plan/REFERENCE.md

```bash
MAX_ITERATIONS=5
ITERATION=1

while [ $BLOCKING_COUNT -gt 0 ] && [ $ITERATION -le $MAX_ITERATIONS ]; do
    # Present BLOCKING findings
    echo "🛑 BLOCKING Findings (Iteration $ITERATION)"
    echo ""

    # Use AskUserQuestion for each BLOCKING
    for finding in "${BLOCKING_FINDINGS[@]}"; do
        AskUserQuestion:
          questions:
            - question: "Finding: $finding"
              header: "BLOCKING Issue"
              options:
                - label: "Fix now"
                  description: "Provide solution now"
                - label: "Add as TODO"
                  description: "Add to plan as TODO item"
                - label: "Mark out of scope"
                  description: "Remove from plan scope"
              multiSelect: false

    # Update plan with responses
    # (implementation details)

    # Re-run plan-reviewer agent
    # (re-invoke agent)

    # Check if BLOCKING resolved
    BLOCKING_COUNT=$(grep -c "BLOCKING" "$PLAN_FILE")

    if [ $BLOCKING_COUNT -eq 0 ]; then
        echo "✓ All BLOCKING findings resolved"
        break
    fi

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

#### 4.6 Verify Results

| Result | Action |
|--------|--------|
| BLOCKING = 0 | Proceed to STOP |
| BLOCKING > 0 + Recovery complete | Proceed to STOP |
| BLOCKING > 0 + --lenient | Proceed to STOP |
| BLOCKING > 0 + Max iterations reached | Halt, require manual intervention |

---

## Testing

### Manual Testing

**Test Standard Plan Confirmation**:
```bash
/01_confirm "test_plan"
```
Expected: Plan created in pending/, auto-review run, BLOCKING findings resolved

**Test --no-review Flag**:
```bash
/01_confirm "test_plan" --no-review
```
Expected: Plan created, auto-review skipped

**Test --lenient Flag**:
```bash
/01_confirm "test_plan" --lenient
```
Expected: Plan created, BLOCKING converted to WARNING

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

**Reference Version**: claude-pilot 4.2.0
**Last Updated**: 2026-01-19
