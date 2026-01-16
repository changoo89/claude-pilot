---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern - iterate until all tests pass._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **One active plan**: Exactly one plan active per git branch
- **No drift**: Update plan and todo list if scope changes
- **Evidence required**: Never claim completion without verification output

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 1: Plan Detection (MANDATORY FIRST ACTION)

> **🚨 YOU MUST DO THIS FIRST - NO EXCEPTIONS**
> Before ANY other action, execute these Bash commands to find the plan:

```bash
ls -la .pilot/plan/pending/*.md 2>/dev/null
ls -la .pilot/plan/in_progress/*.md 2>/dev/null
```

> **ONLY proceed if you have confirmed a plan exists.**
> **DO NOT say "no plan found" without actually running these commands.**

---

### Step 1.1: Plan State Transition (ATOMIC)

> **🚨 CRITICAL - BLOCKING OPERATION**: MUST complete successfully BEFORE any other work. If fails, EXIT IMMEDIATELY.

```bash
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

if is_worktree_mode "$@"; then
    # === WORKTREE MODE (with --wt flag) ===
    check_worktree_support || exit 1

    # ATOMIC: Select and lock pending plan
    PENDING_PLAN="$(select_and_lock_pending)" || { echo "❌ No pending plans available" >&2; exit 1; }

    # Extract lock file path for cleanup
    PLAN_FILENAME="$(basename "$PENDING_PLAN")"
    LOCK_FILE="$PROJECT_ROOT/.pilot/plan/.locks/${PLAN_FILENAME}.lock"

    # Error trap: cleanup lock on ANY failure
    trap "rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

    # NOW move the plan (still holding lock)
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PENDING_PLAN" "$IN_PROGRESS_PATH" || exit 1

    # Create worktree (still holding lock until worktree is ready)
    BRANCH_NAME="$(plan_to_branch "$PLAN_FILENAME")"
    MAIN_BRANCH="main"; git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1 || MAIN_BRANCH="master"
    WORKTREE_DIR="$(create_worktree "$BRANCH_NAME" "$PLAN_FILENAME" "$MAIN_BRANCH")" || exit 1

    # Store dual active pointers BEFORE cd to worktree (SC-4)
    # This ensures main branch key is set while we're still in main project
    mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
    MAIN_KEY="$(printf "%s" "$MAIN_BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    WT_KEY="$(printf "%s" "$BRANCH_NAME" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    printf "%s" "$IN_PROGRESS_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${MAIN_KEY}.txt"
    printf "%s" "$IN_PROGRESS_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${WT_KEY}.txt"

    # Add worktree metadata to plan (with main project and lock file, SC-3, SC-7)
    add_worktree_metadata "$IN_PROGRESS_PATH" "$BRANCH_NAME" "$WORKTREE_DIR" "$MAIN_BRANCH" "$PROJECT_ROOT" "$LOCK_FILE"

    PLAN_PATH="$IN_PROGRESS_PATH"
    cd "$WORKTREE_DIR" || exit 1

    # Release lock only after worktree setup is complete
    # Lock will be cleaned up in /03_close
    # Note: Keep lock file during execution to prevent re-selection
else
    # === STANDARD MODE (without --wt flag) ===
    PLAN_PATH="${EXPLICIT_PATH}"

    # Priority: Explicit path → Oldest pending → Most recent in_progress
    [ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

    # IF pending, MUST move FIRST
    if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
        PLAN_FILENAME="$(basename "$PLAN_PATH")"
        IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
        mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
        mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "❌ FATAL: Failed to move plan" >&2; exit 1; }
        PLAN_PATH="$IN_PROGRESS_PATH"
    fi

    [ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"

    # Final validation
    [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "❌ No plan found. Run /00_plan first" >&2; exit 1; }
fi

# Set active pointer (both modes)
mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"
```

---

## Step 2: Convert Plan to Todo List

Read plan, extract: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan

**Rules**:
- Atomic/verifiable todos
- **Sequential**: One `in_progress` at a time, mark complete immediately after finishing
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously, complete together when ALL agents return

**MANDATORY**: After EVERY "Implement/Add/Create" todo, add corresponding "Run tests for [X]" todo immediately after

---

## Step 2.5: SC Dependency Analysis (For Parallel Execution)

**Full parallel patterns**: See @.claude/guides/parallel-execution.md

| Group | SCs | Rationale |
|-------|-----|-----------|
| Group 1 | SC-1, SC-2, SC-3 | Independent, no shared files |
| Group 2 | SC-4, SC-5 | Depend on Group 1 |
| Group 3 | SC-6 | Depends on SC-4 |

### Parallel Execution

> **When independent SCs exist, YOU MUST invoke multiple agents NOW**

**Implementation Phase (Step 3)**:
- **Coder agents** (Sonnet): Execute independent SCs using TDD + Ralph Loop
- **File isolation**: Each agent works on different files to prevent conflicts

**Verification Phase (Step 3.5)** - Parallel Multi-Angle Check:
- **Tester** (Sonnet): Test execution and coverage analysis
- **Validator** (Haiku): Type check, lint, coverage thresholds
- **Code-Reviewer** (Opus): Deep review for async bugs, memory leaks, security issues

**Fallback**: If SCs have dependencies or share files, use sequential execution
---

## Step 3: Delegate to Coder Agent (Context Isolation)

### Default Behavior
Always delegate implementation to Coder Agent for context isolation.

### 🚀 MANDATORY ACTION: Coder Agent Invocation

> **CRITICAL**: YOU MUST invoke the Coder Agent NOW using the Task tool for context isolation.
> This is not optional. Execute this Task tool call immediately.

**Why Agent?**: Coder Agent runs in **isolated context window** (~80K tokens internally). Only summary returns here (8x token efficiency).

**EXECUTE IMMEDIATELY**:

```markdown
Task:
  subagent_type: coder
  prompt: |
    Execute the following plan:

    Plan Path: {PLAN_PATH}
    Success Criteria: {SC_LIST_FROM_PLAN}
    Test Scenarios: {TS_LIST_FROM_PLAN}

    Implement using TDD + Ralph Loop. Return summary only.

    Reference: @.claude/skills/tdd/SKILL.md, @.claude/skills/ralph-loop/SKILL.md, @.claude/skills/vibe-coding/SKILL.md
```

**Context Flow**: Main (~5K tokens) → Coder Agent (80K internal) → Summary (1K) = 8x efficiency

### 3.3 Process Coder Results

**Expected Output**: `<CODER_COMPLETE>` or `<CODER_BLOCKED>`

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | All SCs met, tests pass, coverage达标 | Proceed to next step |
| `<CODER_BLOCKED>` | Cannot complete (coverage, errors, etc.) | Use `AskUserQuestion` for guidance |

**TaskOutput Anti-Pattern**: DO NOT use `TaskOutput` after Task completion - results return inline automatically

**Error Recovery**: If agent returns error, use `AskUserQuestion` with options: "Retry", "Continue manually", "Cancel"

### 3.4 Verify Coder Output (TDD Enforcement)

> **🚨 CRITICAL - MANDATORY Verification**
> When `<CODER_COMPLETE>` received, verify these fields exist in agent output:
> - [ ] "Test files created" or "Tests written"
> - [ ] "Test run output" with PASS/FAIL counts
> - [ ] "Coverage" percentage (must be ≥80%)
> - [ ] "Ralph Loop iterations" count

**Verification Process**:

1. **Check for Test Evidence**: Look for test creation and execution in the agent summary
2. **Verify Test Results**: Confirm PASS/FAIL counts are present
3. **Check Coverage**: Coverage percentage ≥80% (overall), ≥90% (core modules)
4. **Verify Ralph Loop**: Confirm iteration count and final status

**If Verification Fails** (missing required fields):

```
IF any mandatory field missing:
    1. Log: "⚠️ TDD verification failed: missing {field}"
    2. Re-invoke Coder Agent with explicit instruction:
       "Your output MUST include: Test Files, Test Results, Coverage, Ralph Loop"
    3. IF fails 3 times:
       Use AskUserQuestion for guidance:
       - "Accept completion without full TDD evidence?"
       - "Continue manually?"
       - "Cancel and investigate?"
```

**Example Valid Output**:
```markdown
## Coder Summary

### Test Files Created
- src/auth/login.test.ts
- src/auth/logout.test.ts

### Test Results
PASS: 12, FAIL: 0, SKIP: 0

### Coverage
Overall: 85%, Core: 92%

### Ralph Loop
Iterations: 3, Status: <RALPH_COMPLETE>
```

**Example INVALID Output** (missing test evidence):
```markdown
## Coder Summary
Implementation complete. All SCs met.
❌ MISSING: Test files, Test results, Coverage, Ralph Loop
```

---

## Step 3.5: Parallel Verification (Multi-Angle Quality Check)

> **Parallel Verification Phase**: Tester + Validator + Code-Reviewer run concurrently for comprehensive quality assessment.
> **Reference**: @.claude/guides/parallel-execution.md#pattern-2

### 3.5.1 MANDATORY ACTION: Parallel Agent Invocation

> **🚨 CRITICAL**: YOU MUST invoke all three verification agents NOW using the Task tool.
> This is not optional. Execute these Task tool calls immediately.

**Why Parallel?**: Three specialized agents verify different quality dimensions simultaneously:
- **Tester** (Sonnet): Tests execution, coverage analysis
- **Validator** (Haiku): Type check, lint, coverage thresholds
- **Code-Reviewer** (Opus): Deep review for async bugs, memory leaks, security issues

**EXECUTE IMMEDIATELY**:

```markdown
Task:
  subagent_type: tester
  prompt: |
    Run tests and verify coverage for the implemented feature.

    Plan Path: {PLAN_PATH}
    Test Command: {DETECT_TEST_CMD}
    Coverage Target: 80%+ overall, 90%+ core modules

    Run tests and capture:
    - Test results (PASS/FAIL/SKIP counts)
    - Coverage percentage (overall + core)
    - Any failing test details

    Return summary with test output and coverage metrics.

Task:
  subagent_type: validator
  prompt: |
    Run type check and lint for the implemented feature.

    Plan Path: {PLAN_PATH}
    Type Check Command: {DETECT_TYPE_CMD}
    Lint Command: {DETECT_LINT_CMD}

    Run verification and capture:
    - Type check result (clean or errors)
    - Lint result (clean or issues)
    - Error details if any

    Return summary with verification results.

Task:
  subagent_type: code-reviewer
  prompt: |
    Perform deep code review for the implemented feature.

    Plan Path: {PLAN_PATH}
    Files Changed: {FILES_FROM_CODER_SUMMARY}

    Review for:
    - Correctness: Logic errors, async bugs, memory leaks, edge cases
    - Security: Injection vulnerabilities, input validation, auth issues
    - Code Quality: Vibe Coding compliance (functions ≤50 lines, files ≤200 lines, nesting ≤3)
    - Testing: Test coverage gaps, missing edge cases
    - Documentation: Public API docs, complex logic explanation
    - Performance: Algorithmic complexity, inefficient patterns

    Categorize findings by severity:
    - Critical: Must fix (security issues, crashes, memory leaks)
    - Warning: Should fix (code quality, performance)
    - Suggestion: Nice to have (minor optimizations)

    Return structured review with:
    - Files reviewed
    - Issues found (by severity)
    - Actionable recommendations with code examples
    - Overall assessment (approve/fix needed)
```

### 3.5.2 Process Verification Results

**Expected Outputs**:

| Agent | Marker | Meaning |
|-------|--------|---------|
| **Tester** | Test results + coverage | PASS/FAIL counts, coverage percentage |
| **Validator** | Type + lint results | Clean or errors/issues |
| **Code-Reviewer** | Review summary | Issues found (critical/warning/suggestion) |

**Result Processing**:

```bash
# Tester results
IF TESTS_PASS AND COVERAGE >= 80%:
    MARK: Tests verified ✅
ELSE:
    LOG: Test failures or low coverage
    TRIGGER: Feedback loop (Step 3.6)

# Validator results
IF TYPE_CHECK_CLEAN AND LINT_CLEAN:
    MARK: Verification verified ✅
ELSE:
    LOG: Type or lint errors found
    TRIGGER: Feedback loop (Step 3.6)

# Code-Reviewer results
IF NO_CRITICAL_ISSUES:
    MARK: Review verified ✅
ELSE:
    LOG: Critical review findings
    TRIGGER: Feedback loop (Step 3.6)
```

**Error Recovery**:

- If agent returns error: Log warning, continue with other agents
- If all agents fail: Use `AskUserQuestion` for guidance
- `TaskOutput` Anti-Pattern: DO NOT use `TaskOutput` - results return inline automatically

---

## Step 3.6: Review Feedback Loop (Optional Iteration)

> **Purpose**: Address critical review findings before proceeding.
> **Trigger**: Critical issues found by any verification agent.
> **Max Iterations**: 3 (prevents infinite loops)

### 3.6.1 Check for Critical Findings

**Review verification results from Step 3.5**:

```bash
CRITICAL_ISSUES=0

# Check Tester results
IF TESTS_FAIL OR COVERAGE < 80%:
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    LOG: "Test failures or insufficient coverage"

# Check Validator results
IF TYPE_CHECK_ERRORS OR LINT_ERRORS:
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    LOG: "Type check or lint errors found"

# Check Code-Reviewer results
IF REVIEW_CONTAINS_CRITICAL_ISSUES:
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    LOG: "Critical review findings detected"
```

### 3.6.2 Feedback Loop (Auto-Fix)

**IF NO CRITICAL ISSUES** (`CRITICAL_ISSUES = 0`):
- Proceed to Step 5 (Ralph Loop) or next step

**IF CRITICAL ISSUES FOUND** (`CRITICAL_ISSUES > 0`):

> **Auto-Fix Mode**: Critical issues trigger automatic Coder Agent re-invocation without user confirmation.

```bash
ITERATION=1
MAX_ITERATIONS=3

WHILE [ $ITERATION -le $MAX_ITERATIONS ]; do
    echo "=== Auto-Fix Iteration $ITERATION ==="

    # Log critical issues found
    LOG: "Critical issues detected: ${CRITICAL_ISSUES}"
    LOG: "Test Results: {TEST_SUMMARY}"
    LOG: "Type/Lint: {VALIDATOR_SUMMARY}"
    LOG: "Code Review: {REVIEW_SUMMARY}"

    # AUTO-INVOKE Coder Agent (NO user confirmation required)
    Task:
      subagent_type: coder
      prompt: |
        Fix the following critical issues found during verification:

        **Test Failures**: {TEST_FAILURES}
        **Type/Lint Errors**: {VALIDATION_ERRORS}
        **Code Review Issues**: {CRITICAL_REVIEW_FINDINGS}

        Plan Path: {PLAN_PATH}
        Implement fixes using TDD + Ralph Loop.
        Return summary with test results and coverage.

    # Re-run verification (Step 3.5)
    # PSEUDO-CODE: Return to Step 3.5 Parallel Verification

    # Check if issues resolved
    IF CRITICAL_ISSUES == 0:
        LOG: "✅ All critical issues resolved in iteration $ITERATION"
        BREAK LOOP

    ITERATION=$((ITERATION + 1))
done

# ONLY ask user AFTER max iterations reached with remaining issues
IF [ $ITERATION -gt $MAX_ITERATIONS ] AND [ $CRITICAL_ISSUES -gt 0 ]; then
    LOG: "Max iterations reached - requires user intervention"
    AskUserQuestion:
      title: "Auto-Fix Loop Completed - Issues Remain"
      question: |
        Auto-fix completed ${MAX_ITERATIONS} iterations but critical issues remain:
        {REMAINING_ISSUES}

        How would you like to proceed?
      options:
        - label: "Continue anyway (accept with issues)"
          value: "continue"
        - label: "Fix manually"
          value: "manual"
        - label: "Cancel and investigate"
          value: "cancel"
fi
```

### 3.6.3 Graceful Degradation

**If Code-Reviewer Fails** (Opus unavailable, timeout, error):

```bash
LOG: "⚠️ Code-Reviewer unavailable - continuing without deep review"
MARK: Code-Reviewer skipped ⚠️

# Continue with Tester + Validator only
IF TESTS_PASS AND TYPE_CHECK_CLEAN AND LINT_CLEAN:
    LOG: "✅ Basic verification passed (without deep review)"
    PROCEED to next step
ELSE:
    TRIGGER feedback loop for test/type/lint issues only
```

**If Multiple Agents Fail**:

```bash
WORKING_AGENTS=0
[ TESTER_RESULTS ] && WORKING_AGENTS=$((WORKING_AGENTS + 1))
[ VALIDATOR_RESULTS ] && WORKING_AGENTS=$((WORKING_AGENTS + 1))
[ REVIEWER_RESULTS ] && WORKING_AGENTS=$((WORKING_AGENTS + 1))

IF [ $WORKING_AGENTS -eq 0 ]; then
    AskUserQuestion:
      title: "All Verification Agents Failed"
      question: "All verification agents failed. Continue anyway or cancel?"
      options:
        - "Continue anyway"
        - "Cancel and investigate"
fi
```

---

## Step 3.7: GPT Expert Escalation (Optional - For Persistent Issues)

> **Purpose**: Leverage GPT experts for complex issues that Claude agents cannot resolve
> **Trigger**: 2+ failed Coder Agent attempts on same issue
> **Reference**: @.claude/rules/delegator/orchestration.md

### When to Escalate to GPT

| Scenario | GPT Expert | Trigger |
|----------|------------|---------|
| **Persistent bugs** | Architect | 2+ failed fix attempts on same issue |
| **Security vulnerabilities** | Security Analyst | Security-related code issues |
| **Architecture deadlock** | Architect | Design decision blocking progress |
| **Complex debugging** | Architect | Cannot identify root cause |

### GPT Escalation Flow

**Entry Condition**: After 2+ failed Coder Agent attempts on same issue

```bash
FAILED_ATTEMPTS=0
MAX_ATTEMPTS=2

# Track failed attempts in feedback loop
WHILE [ $ITERATION -le $MAX_ITERATIONS ]; do
    # Invoke Coder Agent
    TASK_RESULT=$(invoke_coder_agent)

    IF [ $TASK_RESULT == "FAILED" ]; then
        FAILED_ATTEMPTS=$((FAILED_ATTEMPTS + 1))
    fi

    IF [ $FAILED_ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        LOG: "⚠️ Max Claude attempts reached - escalating to GPT Architect"
        # PSEUDO-CODE: Proceed to Step 3.7 GPT Escalation
    fi
done
```

### GPT Expert Call Pattern

**Delegation Flow**:

1. **Read expert prompt**: `Read .claude/rules/delegator/prompts/architect.md`
2. **Check Codex CLI availability**:
   ```bash
   if ! command -v codex &> /dev/null; then
       echo "Warning: Codex CLI not installed - falling back to Claude-only debugging"
       # Skip GPT delegation, use Claude's built-in analysis
       return 0
   fi
   ```
3. **Build delegation prompt**: Include full context of what was attempted
4. **Call codex-sync.sh**:
   ```bash
   .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/architect.md)

   TASK: Debug and fix the following issue that resisted 2+ fix attempts.

   PREVIOUS ATTEMPTS:
   - Attempt 1: {WHAT_WAS_TRIED_1}
     Error: {ERROR_1}
     Files modified: {FILES_1}
   - Attempt 2: {WHAT_WAS_TRIED_2}
     Error: {ERROR_2}
     Files modified: {FILES_2}

   EXPECTED OUTCOME:
   - Root cause analysis
   - Working fix that resolves the issue
   - Files modified

   CONTEXT:
   - Plan: {PLAN_PATH}
   - Success Criteria: {SC_LIST}
   - Current implementation: {RELEVANT_CODE}

   MUST DO:
   - Analyze why previous attempts failed
   - Identify the root cause
   - Provide a working solution

   OUTPUT FORMAT:
   Summary → Root cause → Fix approach → Files modified"
   ```
4. **Synthesize response**: Extract fix and apply via Coder Agent

### Example: Persistent Bug Escalation

**Trigger**: Same bug failed 2 times with Claude Coder Agent

```bash
# Read expert prompt first
Read .claude/rules/delegator/prompts/architect.md

# Build delegation prompt with full context
.claude/scripts/codex-sync.sh "read-only" "You are a software architect...

TASK: Fix the persistent race condition in payment processing.

PREVIOUS ATTEMPTS:
- Attempt 1: Added mutex lock
  Error: Still getting duplicate charges
  Files: src/payment/processor.ts
- Attempt 2: Added transaction ID check
  Error: Race condition still occurs
  Files: src/payment/processor.ts, src/database.ts

EXPECTED OUTCOME:
- Root cause of the race condition
- Fix that prevents duplicate charges
- Verification approach

CONTEXT:
$(cat <<EOF
Payment flow:
1. User submits payment
2. Processor creates charge
3. Database saves transaction
4. Return success

Race condition occurs between steps 2-3 when multiple requests arrive simultaneously.
EOF
)

MUST DO:
- Identify the exact race condition
- Provide atomic operation fix
- Suggest verification test

OUTPUT FORMAT:
Root cause → Fix approach → Code example → Verification"
```

### Role Split: When to Use GPT vs Claude

| Situation | Claude Coder | GPT Architect |
|-----------|--------------|---------------|
| First attempt at bug fix | ✅ Use Claude | - |
| Second attempt (retry) | ✅ Use Claude | - |
| **Third attempt (escalation)** | - | ✅ **Use GPT** |
| Simple implementation | ✅ Use Claude | - |
| Architecture decisions | - | ✅ **Use GPT** |
| Security fixes | code-reviewer → | ✅ **Security Analyst** |

### Cost Awareness

- **Escalate after 2+ Claude attempts** - Avoid premature GPT calls
- **Include full context** - All previous attempts, errors, and code
- **One comprehensive call** - Better than multiple small calls
- **Verify GPT fix** - Still need to run tests after applying GPT suggestion

### After GPT Escalation

```bash
# Apply GPT suggestion via Coder Agent
IF GPT_PROVIDED_FIX:
    Task:
      subagent_type: coder
      prompt: |
        Implement the fix suggested by GPT Architect:

        {GPT_SUGGESTION}

        Plan Path: {PLAN_PATH}
        Implement using TDD + Ralph Loop.

    # Re-run verification
    # PSEUDO-CODE: Return to Step 3.5 Parallel Verification
```

---

## Step 4: Execute with TDD (DEPRECATED - Use Agent Instead)

> **⚠️ DEPRECATED - Legacy Step**
> **This step is preserved for backward compatibility only.**
>
> **New Approach**: Use **Step 3: Delegate to Coder Agent** instead, which includes:
> - TDD Red-Green-Refactor cycle
> - Ralph Loop autonomous completion
> - Context isolation for 8x token efficiency
> - Mandatory TDD verification
>
> **Migration Path**: If you're using this legacy step, migrate to Step 3 (Coder Agent delegation).

**Full TDD methodology**: See @.claude/skills/tdd/SKILL.md

| Phase | Action | Command |
|-------|--------|---------|
| **Discovery** | Search codebase | `Glob`, `Grep` |
| **Red** | Write failing test | Run test → confirm FAIL |
| **Green** | Implement minimal code | Run test → confirm PASS |
| **Refactor** | Improve quality (DRY, SOLID) | Run ALL tests → confirm PASS |

**Micro-Cycle**: After EVERY Edit/Write, run tests immediately (mark todo in_progress → test → fix/complete)

**Test Detection**: See @.claude/guides/test-environment.md

---

## Step 5: Ralph Loop (Autonomous Completion)

**Full Ralph Loop methodology**: See @.claude/skills/ralph-loop/SKILL.md

### Entry Condition (CRITICAL)

**Ralph Loop starts IMMEDIATELY after the FIRST code change.**

✅ **Correct**: After implementing first feature, fixing bug, any Edit/Write
❌ **WRONG**: After completing all todos, at very end

### Completion Promise

Output `<RALPH_COMPLETE>` **ONLY when** ALL conditions are met:
- [ ] All tests pass
- [ ] Coverage 80%+ (core modules 90%+)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

### Loop Structure

```
MAX_ITERATIONS=7
WHILE ITERATION <= MAX AND NOT <RALPH_COMPLETE>:
    1. Run: tests, type-check, lint, coverage
    2. Log iteration to ralph-loop-log.md
    3. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    4. ELSE: Fix (priority: errors > coverage > lint), ITERATION++
```

**Exit Conditions**:
- ✅ **Success**: All tests pass, coverage 80%+ (core 90%+), type clean, lint clean, todos complete
- ❌ **Failure**: Max 7 iterations reached, unrecoverable error
- ⚠️ **Blocked**: `<RALPH_BLOCKED>` output

**Test Detection**: See @.claude/guides/test-environment.md

---

## Step 6: Todo Continuation Enforcement

**Default Rule**: One `in_progress` at a time (sequential), mark complete RIGHT AFTER finishing

**Parallel Group Rule**: Mark ALL parallel items as `in_progress` simultaneously, complete together when ALL agents return

---

## Step 7: Verification

```bash
# Run all checks
npx tsc --noEmit && npm test && npm run lint
[ $? -eq 0 ] && echo "✅ All passed" || { echo "❌ Some failed"; exit 1; }
```

---

## Step 8: Update Plan Artifacts

```bash
cat >> "$PLAN_PATH" << 'EOF'
## Execution Summary
### Changes Made: [List]
### Verification: Type ✅, Tests ✅ (X% coverage), Lint ✅
### Follow-ups: [Items]
EOF
```

---

## Step 9: Auto-Chain to Documentation

**Trigger**: All todos complete, Ralph Loop success, coverage 80%+ (core 90%+), type + lint clean

**Auto-Invoke**: `/91_document` (3-sync pattern: implementation → docs auto-sync)

**Skip**: If `--no-docs` specified, skip documentation

---

## Success Criteria

| Criteria | Verification |
|----------|-------------|
| Plan executed | All phases completed |
| Tests pass | All SC met |
| Type clean | Type check exits 0 |
| Lint clean | Lint exits 0 |
| Coverage | 80%+ overall, 90%+ core |
| Ready for close | Documentation synced |

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
                      ↓
                [Ralph Loop → TDD → 91_document]
```

---

## Related Guides
- @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle
- @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/test-environment.md - Test framework detection
- @.claude/guides/3tier-documentation.md - Auto-sync documentation
- @.claude/guides/parallel-execution.md - Parallel execution patterns

---

## Next Command
After successful execution: `/03_close`
