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

## Step 1.5: Conversation Highlights Extraction

> **⚠️ CRITICAL**: Capture implementation details from `/00_plan` conversation
> This ensures executor has concrete "how to implement" guidance without re-asking

### 1.5.1 Scan Conversation for:

- [ ] **Code Examples**: Fenced code blocks (```language) from `/00_plan` conversation
- [ ] **Syntax Patterns**: Specific format/invocation examples, CLI commands, API patterns
- [ ] **Architecture Diagrams**: ASCII art, Mermaid charts, flow diagrams

### 1.5.2 Extract Implementation Patterns

For each highlight found:
1. Copy the exact code/syntax/diagram from conversation
2. Mark with `> **FROM CONVERSATION:**` prefix
3. Add to plan under "Execution Context → Implementation Patterns" section

### 1.5.3 Output Format

```markdown
### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```typescript
> [exact code block from conversation]
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> [exact CLI invocation from conversation]
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> [exact ASCII/Mermaid diagram from conversation]
> ```
```

### 1.5.4 If No Highlights Found

If conversation contains no code examples, syntax patterns, or diagrams:
- Add note: `> No implementation highlights found in conversation`
- Continue to Step 2

---

## Step 1.7: Requirements Verification

> **Full methodology**: See @.claude/guides/requirements-verification.md

> **Purpose**: Verify ALL user requirements are captured in the plan
> **Location**: After Conversation Highlights extraction, before file creation

### 🎯 MANDATORY ACTION: Verify Requirements Coverage

> **YOU MUST verify that ALL User Requirements from /00_plan are included in the plan.**
> This prevents omissions during plan extraction.

**Quick Start**:
1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria from PRP Analysis (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Update plan with Requirements Coverage Check

> **⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.
> Use AskUserQuestion to resolve ALL BLOCKING issues before plan file creation.

---

## Step 2: Generate Plan File Name

```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

mkdir -p "$PROJECT_ROOT/.pilot/plan/pending"
WORK_NAME="$(echo "$ARGUMENTS" | sed 's/--no-review//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50 | xargs)"
[ -z "$WORK_NAME" ] && WORK_NAME="plan"
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/pending/${TS}_${WORK_NAME}.md"
```

---

## Step 3: Create Plan File

> **⚠️ ENGLISH OUTPUT REQUIRED**: All content MUST be in English

### 3.1 Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements (Verbatim)
> From /00_plan Step 0: Complete table with all user input

### Requirements Coverage Check
> From Step 1.7: Verification that all URs mapped to SCs

## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff) [if applicable]
### Explored Files
### Key Decisions Made
### Implementation Patterns (FROM CONVERSATION) [Step 1.5 output]
## External Service Integration [if applicable]
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
```

**Execution Context (Planner Handoff)**: Captures conversation state from `/00_plan`:
- Planner's recommended approach
- Key decisions made during planning
- Unresolved questions to address during execution
- Implementation Patterns (code examples, syntax patterns, diagrams from conversation)
- Assumptions that need validation
- Dependencies on external resources

This ensures continuity between planning (`/00_plan`) and execution (`/02_execute`) phases.

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md
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

### Default Behavior
Always run auto-review with strict mode (BLOCKING findings trigger Interactive Recovery).

### Exception: --no-review and --lenient flags
- `--no-review`: Skip auto-review entirely, proceed to STOP
- `--lenient`: Convert BLOCKING findings to WARNING, proceed to STOP

### 4.2 Onboarding Message
```
🛑 BLOCKING findings prevent execution until resolved.
This ensures plan quality for independent executors.
Use --lenient to bypass (converts BLOCKING → WARNING).
```

### 4.3 Auto-Invoke Plan-Reviewer Agent

### 🚀 MANDATORY ACTION: Plan-Reviewer Agent Invocation

> **YOU MUST invoke the plan-reviewer agent NOW using the Task tool.**
> This is not optional. Execute this Task tool call immediately.

**EXECUTE IMMEDIATELY**:

```markdown
Task:
  subagent_type: plan-reviewer
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

**VERIFICATION**: After sending Task call, wait for plan-reviewer agent to return results before proceeding to Step 4.4.

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
    4. Re-run: Task plan-reviewer agent
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
- [ ] User Requirements (Verbatim) section included in plan
- [ ] Requirements Coverage Check completed (Step 1.7)
- [ ] All user requirements mapped to Success Criteria (100% coverage)
- [ ] BLOCKING findings resolved (or `--lenient` used)
- [ ] Plan content extracted from conversation
- [ ] External Service Integration added (if applicable)
- [ ] Vibe Coding Compliance added
- [ ] Auto-review completed (or skipped when `--no-review` specified)
- [ ] Zero BLOCKING (or `--lenient` used)
- [ ] Execution NOT started

---

## STOP
> **MANDATORY STOP** - Plan created in `.pilot/plan/pending/`
> To execute: `/02_execute`
> This will: Move to `in_progress/`, create active pointer, begin TDD + Ralph Loop

---

## Related Guides
- @.claude/guides/requirements-verification.md - Requirements Verification methodology
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/gap-detection.md - External service verification

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: `git rev-parse --abbrev-ref HEAD`
