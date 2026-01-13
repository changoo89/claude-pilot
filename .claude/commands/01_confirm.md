---
description: Extract plan from conversation, create file in pending/, and STOP
argument-hint: "[work_name] --no-review - optional work name for the plan file; --no-review skips auto-review"
allowed-tools: Read, Glob, Grep, Write, Bash(*)
---

# /01_confirm

_Extract plan from conversation, create plan file in pending/, and STOP._

> **MANDATORY STOP - CONFIRMATION ONLY**
> This command only: 1) Extracts plan from conversation, 2) Creates file in pending/, 3) STOPS
> To execute, run `/02_execute` after this completes.

---

## Core Philosophy

- **No Execution**: Only creates plan file, does NOT execute
- **Context-Driven**: Extract plan from preceding conversation
- **Standalone Output**: Created plan file must be sufficient for execution
- **Executable**: Include concrete steps, commands, checklists

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 1: Extract Plan from Conversation

### 1.1 Review Context
Look for: User Requirements, PRP Analysis (What/Why/How/Success Criteria/Constraints), Scope, Architecture, Execution Plan, Acceptance Criteria, Test Plan, Risks, Open Questions

### 1.2 Validate Completeness
Verify: [ ] User Requirements exists, [ ] Execution Plan with phases exists, [ ] Acceptance Criteria defined, [ ] Test Plan included

If missing: Inform user, ask if proceed with incomplete plan, note gaps

---

## Step 2: Generate Plan File Name

```bash
mkdir -p .pilot/plan/pending
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"
[ -z "$WORK_NAME" ] && WORK_NAME="plan"
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE=".pilot/plan/pending/${TS}_${WORK_NAME}.md"
```

---

## Step 3: Create Plan File

### 3.1 Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements [From conversation]

## PRP Analysis
### What / Why / How / Success Criteria / Constraints [From conversation]

## Scope: In scope / Out of scope [From conversation]

## Architecture
### Data Structures / Module Boundaries [From conversation if applicable]

## Vibe Coding Compliance
> Validate plan enforces: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3, SRP/DRY/KISS

## Execution Plan [Phase breakdown from conversation]

## Acceptance Criteria [Checkbox list from conversation]

## Test Plan [From conversation]

## Risks & Mitigations [From conversation]

## Open Questions [From conversation]
```

### 3.2 Write File
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
If `"$ARGUMENTS"` contains `--no-review`, skip to STOP

### 4.2 Auto-Invoke Review
```
Skill: 90_review
Args: "$PLAN_FILE"
```

### 4.3 Verify Results
| Result | Action |
|--------|--------|
| Pass (Critical=0) | Proceed to STOP |
| Needs Revision | Findings applied via Step 8 of 90_review |

**Verify**: Check `## Review History` exists, all findings have entries, summary shows "Review findings applied: N critical, N warning, N suggestion"

---

## Success Criteria

- [ ] Plan file created in `.pilot/plan/pending/`
- [ ] Plan content extracted from conversation context
- [ ] Vibe Coding Compliance section added
- [ ] Optional review completed
- [ ] Execution NOT started

---

## STOP
> **MANDATORY STOP - DO NOT PROCEED TO EXECUTION**
>
> ✓ Plan file created in: `.pilot/plan/pending/`
> ✓ [If review ran] Review findings applied, Review History updated
> ✓ No execution has started
>
> To execute: `/02_execute`
> This will: Move plan to `in_progress/`, create active pointer, begin TDD + Ralph Loop

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- `.claude/guides/review-extensions.md`
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
