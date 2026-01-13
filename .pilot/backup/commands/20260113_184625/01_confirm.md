---
description: Extract plan from conversation, create file in pending/, and STOP
argument-hint: "[work_name] --no-review - optional work name for the plan file; --no-review skips auto-review"
allowed-tools: Read, Glob, Grep, Write, Bash(*)
---

```
═══════════════════════════════════════════════════════════
  MANDATORY STOP - CONFIRMATION ONLY
═══════════════════════════════════════════════════════════

This command (/01_confirm) ONLY:
1. Extracts the plan from the conversation context
2. Creates a plan file in .pilot/plan/pending/
3. STOPS - does NOT proceed to execution

To execute the plan, run /02_execute after this command completes.

═══════════════════════════════════════════════════════════
```

# /01_confirm

_Extract the plan from conversation context, create plan file in pending/, and STOP._

---

## Core Philosophy

- **No Execution**: This command only creates the plan file. It does NOT execute.
- **Context-Driven**: Extract the plan from the preceding conversation.
- **Standalone Output**: The created plan file must be sufficient for execution.
- **Evidence-driven**: Convert vague intent into verifiable acceptance criteria.
- **Executable**: Include concrete steps, commands, and checklists.

---

## Extended Thinking Mode

> **Conditional Activation**
> If the LLM model currently running in this session is a GLM model,
> proceed with maximum extended thinking throughout all phases of this command.
> This ensures deep reasoning and thorough analysis for complex tasks.

---

## Inputs

- Work name (optional - defaults to "plan" if not provided)
- `--no-review` flag (optional - skips auto-review)
- Plan content from preceding conversation context

---

## Step 1: Extract Plan from Conversation

### 1.1 Review Conversation Context

Look for the plan structure in the preceding conversation:
- User Requirements section
- PRP Analysis (What, Why, How, Success Criteria, Constraints)
- Scope (In/Out)
- Architecture
- Execution Plan with phases
- Acceptance Criteria
- Test Plan
- Risks & Mitigations
- Open Questions

### 1.2 Validate Completeness

Verify the plan contains:
- [ ] User Requirements section exists
- [ ] Execution Plan with phases exists
- [ ] Acceptance Criteria defined
- [ ] Test Plan included

If any required sections are missing:
- Inform user of missing sections
- Ask if they want to proceed with incomplete plan
- If yes, note gaps in plan

---

## Step 2: Generate Plan File Name

### 2.1 Create Timestamp and Work Name

```bash
mkdir -p .pilot/plan/pending

# Extract work name from arguments or default to "plan"
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"

if [ -z "$WORK_NAME" ]; then
    WORK_NAME="plan"
fi

# Create timestamp
TS="$(date +%Y%m%d_%H%M%S)"

# Generate filename
PLAN_FILE=".pilot/plan/pending/${TS}_${WORK_NAME}.md"
```

---

## Step 3: Create Plan File in Pending/

### 3.1 Plan Structure

Create the plan file with the following structure:

```markdown
# {Work Name}

- Generated at: {timestamp}
- Work name: {work_name}
- Location: {plan_path}

## User Requirements

[From conversation context]

## PRP Analysis

### What (Functionality)
[From conversation]

### Why (Context)
[From conversation]

### How (Approach)
[From conversation]

### Success Criteria
[From conversation]

### Constraints
[From conversation]

## Scope

### In scope
[From conversation]

### Out of scope
[From conversation]

## Architecture

### Data Structures
[From conversation if applicable]

### Module Boundaries
[From conversation if applicable]

## Execution Plan

[Phase breakdown from conversation]

## Acceptance Criteria

[Checkbox list from conversation]

## Test Plan

[From conversation]

## Risks & Mitigations

[From conversation]

## Open Questions

[From conversation]
```

### 3.2 Write Plan File

```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content extracted from conversation]
PLAN_EOF

echo "Plan created: $PLAN_FILE"
```

---

## Step 4: Auto-Review (Optional)

> **Principle**: Plan validation before execution. No user intervention needed.

### 4.1 Skip Check

If `"$ARGUMENTS"` contains `--no-review`, skip to STOP section.

### 4.2 Auto-Invoke Review

Use Skill tool to invoke review:

```
Skill: 90_review
Args: "$PLAN_FILE"
```

This automatically:
1. Loads the plan from `$PLAN_FILE`
2. Runs mandatory reviews
3. Runs extended reviews by type
4. Reports findings

### 4.3 Review Results

After review completes, verify findings were applied:

| Result | Action |
|--------|--------|
| Pass (Critical=0) | Proceed to STOP |
| Needs Revision | Findings applied to plan via Step 8 of 90_review |

**Verify Apply Completion**:
- Check plan file has `## Review History` section
- Confirm all findings (Critical/Warning/Suggestion) have entries
- Review summary includes: "Review findings applied: N critical, N warning, N suggestion"

---

## Success Criteria

- Plan file created in `.pilot/plan/pending/`
- Plan content extracted from conversation context
- Optional review completed
- Execution NOT started

---

## STOP

```
═══════════════════════════════════════════════════════════
  MANDATORY STOP - DO NOT PROCEED TO EXECUTION
═══════════════════════════════════════════════════════════

This command (/01_confirm) has completed the CONFIRMATION phase:
✓ Plan file created in: .pilot/plan/pending/
[If review ran] ✓ Review findings applied to plan
[If review ran] ✓ Review History updated with N changes
✓ No execution has started

To execute this plan, run:

    /02_execute

This will:
1. Move the plan from pending/ to in_progress/
2. Create an active pointer for this branch
3. Begin execution with TDD and Ralph Loop

═══════════════════════════════════════════════════════════
```

---

## References

- **3-Tier Docs**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Review Extensions**: `.claude/guides/review-extensions.md`
