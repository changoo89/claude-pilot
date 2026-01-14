---
description: Extract plan from conversation, create file in pending/, auto-review with Interactive Recovery
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
---

# /01_confirm

_Extract plan from conversation, create plan file in pending/, run auto-review with Interactive Recovery for BLOCKING findings._

> **MANDATORY STOP - CONFIRMATION ONLY**
> This command only: 1) Extracts plan from conversation, 2) Creates file in pending/, 3) Runs auto-review, 4) Interactive Recovery if BLOCKING, 5) STOPS
> To execute, run `/02_execute` after this completes.

---

## Core Philosophy

- **No Execution**: Only creates plan file and reviews, does NOT execute
- **Context-Driven**: Extract plan from preceding conversation
- **Standalone Output**: Created plan file must be sufficient for execution
- **Executable**: Include concrete steps, commands, checklists
- **English Only**: Plan file content MUST be in English, regardless of conversation language
- **Strict Mode Default**: Auto-run review, BLOCKING findings trigger Interactive Recovery

> **⚠️ LANGUAGE - PLAN FILE**: The plan file MUST be written in English. Extract and translate any non-English content from the conversation into English before writing to the plan file.

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

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content written to the plan file MUST be in English. If the conversation was in another language, translate all content before writing to the file.

### 3.1 Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements [From conversation]

## PRP Analysis
### What / Why / How / Success Criteria / Constraints [From conversation]

## Scope: In scope / Out of scope [From conversation]

## External Service Integration [OPTIONAL - if APIs/DB/Files/Async/Env involved]
### API Calls Required / New Endpoints / Environment Variables / Error Handling Strategy

## Implementation Details Matrix [OPTIONAL - if external services involved]
### WHO / WHAT / HOW / VERIFY table

## Gap Verification Checklist [OPTIONAL - if external services involved]
### API / DB / Async / File / Environment / Error Handling checklists

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

## Step 4: Auto-Review (Default: Strict Mode)

> **Principle**: Plan validation before execution. Interactive Recovery for BLOCKING findings.

### 4.1 Skip Checks
If `"$ARGUMENTS"` contains `--no-review`, skip to STOP
If `"$ARGUMENTS"` contains `--lenient`, set LENIENT_MODE=true

### 4.2 First-Run Onboarding Message
> **Display on first BLOCKING encounter** (heuristic: if plan mentions external services and no previous BLOCKING findings)

```
🛑 BLOCKING findings prevent execution until resolved.
This ensures plan quality for independent executors by catching vague specifications
(e.g., "Call GPT 5.1" without SDK details, "Call /api/analyze" without endpoint verification).

Use --lenient to bypass (converts BLOCKING → WARNING).
```

### 4.3 Auto-Invoke Review
```
Skill: 90_review
Args: "$PLAN_FILE"
```

### 4.4 Check for BLOCKING Findings

Parse review results for BLOCKING findings count:
- **BLOCKING > 0** AND `--lenient` NOT set → Enter Interactive Recovery Loop
- **BLOCKING > 0** AND `--lenient` set → Log warning, proceed to STOP
- **BLOCKING = 0** → Proceed to STOP

### 4.5 Interactive Recovery Loop (NEW)

> **Purpose**: Gather missing details through dialogue until plan passes review

**Loop Structure**:
```
MAX_ITERATIONS=5
ITERATION=1

WHILE BLOCKING findings > 0 AND ITERATION <= MAX_ITERATIONS:
    1. Present BLOCKING findings to user
       - Show each finding with location
       - Explain what's missing
       - Provide example of good specification

    2. For each BLOCKING finding, use AskUserQuestion:
       - "What SDK should be used?" (for unspecified API calls)
       - "What's the endpoint path?" (for vague endpoints)
       - Include "Skip this check (add as TODO)" option

    3. Update plan with user responses
       - Add to External Service Integration section
       - Or mark as skipped with warning note

    4. Re-run review: Skill 90_review

    5. Check results:
       - IF BLOCKING = 0: Exit loop, proceed to STOP
       - IF BLOCKING > 0 AND ITERATION < MAX_ITERATIONS: Continue loop
       - IF ITERATION = MAX_ITERATIONS: Log warnings, proceed to STOP

    ITERATION++
```

**AskUserQuestion Example**:
```
BLOCKING Finding: "API mechanism unspecified - missing SDK/HTTP, endpoint"
Location: "Call GPT 5.1 for analysis" in User Requirements

Question: Which implementation mechanism should be used?
Options:
- "OpenAI SDK (openai@4.x)" - Use Node.js SDK
- "HTTP: POST /api/generate" - Call existing API endpoint
- "Skip - add as TODO" - Mark as unresolved with warning
```

**Plan Update Format**:
```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| GPT Generation | Next.js API | OpenAI | N/A | openai@4.x | New | [ ] SDK installed |

[OR if skipped]
> ⚠️ SKIPPED: API mechanism deferred to implementation phase
> Original: "Call GPT 5.1 for analysis"
> Resolution: TODO - specify SDK or endpoint during execution
```

### 4.6 Lenient Mode Behavior
If `--lenient` flag provided:
- Log: "⚠️ Lenient mode: BLOCKING findings converted to warnings"
- Add section to plan: `## Lenient Mode Warnings` with all BLOCKING items
- Proceed to STOP (do not enter Interactive Recovery)

### 4.7 Verify Results
| Result | Action |
|--------|--------|
| BLOCKING = 0 | Proceed to STOP |
| BLOCKING > 0 + Interactive Recovery complete | Proceed to STOP (with warnings logged) |
| BLOCKING > 0 + --lenient | Proceed to STOP (BLOCKING logged as warnings) |

**Verify**: Check `## Review History` exists, all findings have entries, summary shows "Review findings applied: N blocking, N critical, N warning, N suggestion"

---

## Success Criteria

- [ ] Plan file created in `.pilot/plan/pending/`
- [ ] Plan content extracted from conversation context
- [ ] External Service Integration section added (if applicable)
- [ ] Vibe Coding Compliance section added
- [ ] Auto-review completed (unless `--no-review` specified)
- [ ] Zero BLOCKING findings (or `--lenient` flag used)
- [ ] Review findings applied, Review History updated
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
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
