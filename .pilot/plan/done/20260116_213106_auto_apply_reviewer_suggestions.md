# Auto-Apply Reviewer Suggestions in /02_execute

- Generated: 2026-01-16 21:31:06 | Work: auto_apply_reviewer_suggestions
- Location: `.pilot/plan/pending/20260116_213106_auto_apply_reviewer_suggestions.md`

---

## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 2026-01-16 | "execute 단계 에서 리뷰어의 제안이 있으면 유저한티 물어볼 필요 없이 반드시 모든 제안된 내용을 다시 수정을 하도록 만들어줘" | Auto-apply all reviewer suggestions in /02_execute without user confirmation |
| UR-2 | 2026-01-16 | "현재를 유지하되 수정 제안 내용이 있다면 꼭 진행하도록" | Keep MAX_ITERATIONS=3, but MUST execute fix when suggestions exist |
| UR-3 | 2026-01-16 | "사용자에게 질문" (max iterations 후) | After max iterations, ask user if critical issues remain |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-1 | Mapped |
| UR-3 | ✅ | SC-2 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Modify `/02_execute` Step 3.6 to auto-apply reviewer suggestions without user confirmation, keeping user prompt only as fallback after max iterations.

**Scope**:
- **In scope**:
  - `.claude/commands/02_execute.md` - Step 3.6 modification
  - Template sync to `src/claude_pilot/templates/` (via sync script)
- **Out of scope**:
  - Coder agent changes (`.claude/agents/coder.md`)
  - Other commands (00, 01, 03, 90, 91)
  - Parallel execution guide (no changes needed)

### Why (Context)

**Current Problem**:
- Step 3.6의 Feedback Loop이 매번 `AskUserQuestion`으로 사용자 확인을 요구
- 리뷰어가 제안을 제공해도 사용자가 승인할 때까지 대기
- 워크플로우가 자동화되지 않아 비효율적

**Desired State**:
- 리뷰어 제안이 있으면 자동으로 Coder Agent 재호출하여 수정
- 사용자 개입 없이 최대 3회까지 자동 반복
- 3회 반복 후에도 Critical 이슈가 있으면 그때만 사용자에게 질문

**Business Value**:
- **User impact**: More automated workflow, reduced wait time
- **Technical impact**: Review-fix cycle completes automatically

### How (Approach)

- **Phase 1**: Read current `02_execute.md` (already done)
- **Phase 2**: Modify Step 3.6 logic
  - Remove mid-loop `AskUserQuestion`
  - Add auto-invocation of Coder Agent when critical issues found
  - Keep user prompt only as post-max-iteration fallback
- **Phase 3**: Template sync (via sync script)
- **Phase 4**: Verification

### Success Criteria

```
SC-1: Step 3.6에서 Critical 이슈 발견 시 자동으로 Coder Agent 재호출
- Verify: grep -A 20 "3.6.2 Feedback Loop" .claude/commands/02_execute.md
- Expected: AskUserQuestion이 루프 중간에 없고, 자동 Task 호출로 대체됨

SC-2: AskUserQuestion은 MAX_ITERATIONS (3회) 후에만 호출
- Verify: grep -B 5 -A 10 "AskUserQuestion" .claude/commands/02_execute.md
- Expected: AskUserQuestion이 MAX_ITERATIONS 체크 후에만 등장

SC-3: 자동 수정 로직이 Critical 이슈가 있을 때만 트리거
- Verify: Command file review
- Expected: IF CRITICAL_ISSUES > 0 → Auto-invoke Coder → Re-verify
```

### Constraints

- Must not break existing command syntax
- Template sync required after modification
- English-only content in command files
- Maintain MAX_ITERATIONS=3

---

## Test Environment (Detected)

- **Project Type**: Python
- **Test Framework**: pytest
- **Test Command**: `pytest`
- **Coverage Command**: `pytest --cov`
- **Test Directory**: `tests/`

*Note: This change is primarily documentation/command file modification.*

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Main target file | Lines 359-505 (Step 3.6) | Contains AskUserQuestion in loop |
| `.claude/guides/parallel-execution.md` | Parallel patterns | N/A | No changes needed |
| `.claude/agents/coder.md` | Coder agent spec | N/A | No changes needed |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Keep MAX_ITERATIONS=3 | User preference | Could increase to 5 or 7 |
| AskUserQuestion only after max iterations | Balance automation vs user control | Remove entirely |
| Auto-invoke Coder for all critical issues | Ensure all suggestions are applied | Only for specific issue types |

### Implementation Patterns (FROM CONVERSATION)

#### Current Flow (to be changed)
> **FROM CONVERSATION:**
> ```
> Critical Issues Found → AskUserQuestion (user picks: reinvoke/manual/accept) → Based on choice → Loop or Exit
> ```

#### New Flow (target state)
> **FROM CONVERSATION:**
> ```
> Critical Issues Found → Auto-invoke Coder Agent → Re-run Verification → Loop
>    ↓ (after MAX_ITERATIONS)
> AskUserQuestion (only if issues remain)
> ```

---

## Architecture

### Module Changes

| File | Change Type | Description |
|------|-------------|-------------|
| `.claude/commands/02_execute.md` | MODIFY | Step 3.6 auto-fix logic |
| `src/claude_pilot/templates/.claude/commands/02_execute.md` | SYNC | Template sync (via script) |

### Change Details

**Section 3.6.2 Feedback Loop** - Lines ~397-469:

1. **REMOVE**: `AskUserQuestion` block inside the WHILE loop (lines ~405-425)
2. **ADD**: Auto-invocation of Coder Agent when `CRITICAL_ISSUES > 0`
3. **MOVE**: `AskUserQuestion` to post-loop fallback (after `IF ITERATION > MAX_ITERATIONS`)

### Auto-Invocation Implementation Example

The new Step 3.6.2 should follow this pattern:

```markdown
### 3.6.2 Feedback Loop (Auto-Fix)

**IF CRITICAL ISSUES FOUND** (`CRITICAL_ISSUES > 0`):

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
    GOTO Step 3.5

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

**Key Differences from Current**:
- NO `AskUserQuestion` inside WHILE loop
- Coder Agent auto-invoked immediately on critical issues
- User prompt ONLY after MAX_ITERATIONS exhausted

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Infinite loop (if auto-fix fails) | Low | High | MAX_ITERATIONS=3 limit enforced |
| Coder Agent repeats same fix | Medium | Medium | Pass specific error details (Critical: lines containing "Critical:" extracted as bullet list) |
| Command file breaks workflow | Low | High | Test manually before sync, keep git backup, can revert via `git checkout` |

---

## Vibe Coding Compliance

| Target | Limit | Expected |
|--------|-------|----------|
| **Function** | ≤50 lines | N/A (markdown file) |
| **File** | ≤200 lines | Total file ~650 lines (acceptable for command file) |
| **Nesting** | ≤3 levels | Bash blocks maintain ≤3 |

---

## Execution Plan

| Phase | Task | Deliverable |
|-------|------|-------------|
| 1 | Read current Step 3.6.2 in 02_execute.md | Understanding of current structure |
| 2 | Modify Step 3.6.2 - Remove mid-loop AskUserQuestion | Edited section |
| 3 | Add auto-invocation logic for Coder Agent | Edited section |
| 4 | Move AskUserQuestion to post-max-iteration fallback | Edited section |
| 5 | Sync templates via `scripts/sync-templates.sh` | Synced templates |
| 6 | Verify changes with grep/read | Verification output |

---

## Acceptance Criteria

- [ ] Step 3.6.2 no longer has `AskUserQuestion` inside the WHILE loop
- [ ] Auto Coder Agent invocation added when `CRITICAL_ISSUES > 0`
- [ ] `AskUserQuestion` appears only after `MAX_ITERATIONS` check
- [ ] Template synced to `src/claude_pilot/templates/`
- [ ] No syntax errors in command file

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Auto-fix triggered | Critical issue found | Coder Agent auto-invoked | Manual | N/A |
| TS-2 | Max iterations reached | 3 iterations, issues remain | AskUserQuestion shown | Manual | N/A |
| TS-3 | No critical issues | All verification clean | Skip feedback loop | Manual | N/A |
| TS-4 | Coder fails all iterations | 3 auto-fixes, all fail | AskUserQuestion with clear failure context | Manual | N/A |

---

## Open Questions

None - requirements clarified via user dialogue.

---

## Execution Summary

### Changes Made
1. **Step 3.6.2 Title**: Changed from "Feedback Loop (Conditional)" to "Feedback Loop (Auto-Fix)"
2. **Removed**: Mid-loop `AskUserQuestion` block (lines 405-448 in original)
3. **Removed**: User choice processing logic (`IF USER_CHOICE == "reinvest"` branch)
4. **Added**: Auto-invocation comment: "AUTO-INVOKE Coder Agent (NO user confirmation required)"
5. **Added**: Log statements for critical issues detection
6. **Moved**: `AskUserQuestion` to post-MAX_ITERATIONS fallback only
7. **Updated**: Title to "Auto-Fix Loop Completed - Issues Remain"
8. **Added**: "Fix manually" option to fallback options

### Files Modified
- `.claude/commands/02_execute.md` (Step 3.6.2)
- `src/claude_pilot/templates/.claude/commands/02_execute.md` (synced)

### Verification Results

| SC | Description | Status |
|----|-------------|--------|
| SC-1 | Auto Coder Agent invocation when critical issues found | ✅ Verified - Line 412: "# AUTO-INVOKE Coder Agent (NO user confirmation required)" |
| SC-2 | AskUserQuestion only after MAX_ITERATIONS (3) | ✅ Verified - Line 438: "IF [ $ITERATION -gt $MAX_ITERATIONS ] AND [ $CRITICAL_ISSUES -gt 0 ]" |
| SC-3 | Auto-fix triggers only on critical issues | ✅ Verified - Line 395: "**IF CRITICAL ISSUES FOUND** (`CRITICAL_ISSUES > 0`)" |

### Test Scenarios (Manual Verification)

| TS | Scenario | Expected | Status |
|----|----------|----------|--------|
| TS-1 | Auto-fix triggered | Coder Agent auto-invoked on critical issues | ✅ Logic verified |
| TS-2 | Max iterations reached | AskUserQuestion shown after 3 iterations | ✅ Logic verified |
| TS-3 | No critical issues | Skip feedback loop entirely | ✅ Logic preserved |
| TS-4 | Coder fails all iterations | AskUserQuestion with clear failure context | ✅ Fallback exists |

### Test Coverage

Since this is a documentation/command file modification (not executable code):
- **Manual Verification**: ✅ All logic flows verified via grep/read
- **Template Sync**: ✅ Confirmed synced to `src/claude_pilot/templates/`
- **Syntax Check**: ✅ Markdown structure valid, bash code blocks properly formatted

### Follow-ups

None - all success criteria met.

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-16 | Initial plan created |
| 1.1 | 2026-01-16 | Added auto-invocation implementation example, rollback strategy, TS-4 edge case (per review feedback) |
| 1.2 | 2026-01-16 | Execution complete - Step 3.6.2 modified to auto-fix mode |
