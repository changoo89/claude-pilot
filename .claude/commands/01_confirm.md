---
description: Extract plan from conversation, create file in pending/, auto-review with Interactive Recovery
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
---

# /01_confirm

_Extract plan from conversation, create plan file in pending/, run auto-review with Interactive Recovery for BLOCKING findings._

> **MANDATORY STOP - CONFIRMATION ONLY**
> This command only: 1) Extracts plan, 2) Creates file in pending/, 3) Runs auto-review, 4) Interactive Recovery if BLOCKING, 5) STOPS
> To execute, run `/02_execute` after this completes.

---

## Core Philosophy

- **No Execution**: Only creates plan file and reviews
- **Context-Driven**: Extract plan from conversation
- **English Only**: Plan file MUST be in English
- **Strict Mode Default**: BLOCKING findings trigger Interactive Recovery

---

## Step 1: Extract Plan from Conversation

### 1.1 Review Context
Look for: User Requirements, PRP Analysis, Scope, Architecture, Execution Plan, Acceptance Criteria, Test Plan, Risks, Open Questions

**PRP Framework**: See @.claude/guides/prp-framework.md

### 1.2 Validate Completeness
Verify: [ ] User Requirements, [ ] Execution Plan, [ ] Acceptance Criteria, [ ] Test Plan

If missing: Inform user, ask if proceed

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

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content MUST be in English

### 3.1 Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements
## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## External Service Integration [if applicable]
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
```

**Vibe Coding**: See @.claude/guides/vibe-coding.md
**Gap Detection**: See @.claude/guides/gap-detection.md

### 3.2 Write File
```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content extracted from conversation]
PLAN_EOF
echo "Plan created: $PLAN_FILE"
```

---

## Step 4: Auto-Review (Strict Mode)

> **Principle**: Plan validation with Interactive Recovery for BLOCKING findings

### 4.1 Skip Checks
- `--no-review`: Skip to STOP
- `--lenient`: BLOCKING → WARNING

### 4.2 Onboarding Message
```
🛑 BLOCKING findings prevent execution until resolved.
This ensures plan quality for independent executors.
Use --lenient to bypass (converts BLOCKING → WARNING).
```

### 4.3 Auto-Invoke Review
```
Skill: 90_review
Args: "$PLAN_FILE"
```

### 4.4 Check BLOCKING Findings
| Condition | Action |
|-----------|--------|
| BLOCKING > 0 AND no --lenient | Enter Interactive Recovery |
| BLOCKING > 0 AND --lenient | Log warning, proceed to STOP |
| BLOCKING = 0 | Proceed to STOP |

### 4.5 Interactive Recovery Loop

**Gap Detection**: See @.claude/guides/gap-detection.md

```
MAX_ITERATIONS=5
ITERATION=1

WHILE BLOCKING > 0 AND ITERATION <= MAX:
    1. Present BLOCKING findings
    2. Use AskUserQuestion for each BLOCKING
       - Include "Skip (add as TODO)" option
    3. Update plan with responses
    4. Re-run: Skill 90_review
    5. IF BLOCKING = 0: Exit loop
    ITERATION++
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

### 4.6 Verify Results
| Result | Action |
|--------|--------|
| BLOCKING = 0 | Proceed to STOP |
| BLOCKING > 0 + Recovery complete | Proceed to STOP |
| BLOCKING > 0 + --lenient | Proceed to STOP |

---

## Success Criteria

- [ ] Plan file created in `.pilot/plan/pending/`
- [ ] Plan content extracted from conversation
- [ ] External Service Integration added (if applicable)
- [ ] Vibe Coding Compliance added
- [ ] Auto-review completed (unless `--no-review`)
- [ ] Zero BLOCKING (or `--lenient` used)
- [ ] Execution NOT started

---

## STOP
> **MANDATORY STOP** - Plan created in `.pilot/plan/pending/`
> To execute: `/02_execute`
> This will: Move to `in_progress/`, create active pointer, begin TDD + Ralph Loop

---

## Related Guides
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/gap-detection.md - External service verification

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
