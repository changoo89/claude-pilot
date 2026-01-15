# Add Code-Reviewer Agent to /02_execute

- Generated: 2025-01-15 22:29:42
- Work: add_code_reviewer_to_execute
- Location: .pilot/plan/pending/20250115_222942_add_code_reviewer_to_execute.md

## User Requirements

Add code-reviewer agent invocation to `/02_execute` command with feedback loop for addressing review findings.

**Background**:
- Code-reviewer is mentioned in `/02_execute` Step 2.5 but has no actual Task tool invocation
- `parallel-execution-REFERENCE.md` Pattern 2 shows code-reviewer should run in verification phase
- User wants review findings to be reflected back into code (requires feedback loop)

## PRP Analysis

### What (Functionality)

**Objective**: Add code-reviewer agent invocation to `/02_execute` with optional feedback loop

**Scope**:
- **In scope**:
  - Add code-reviewer Task call to Step 3.5 (Parallel Verification)
  - Add Step 3.6 (Review Feedback Loop) for critical issue handling
  - Update todo management for parallel verification agents
- **Out of scope**:
  - Changes to `/03_close`
  - Changes to `/90_review`
  - Changes to code-reviewer agent definition

### Why (Context)

**Current Problem**:
- Code-reviewer is documented in parallel-execution guide but not implemented in `/02_execute`
- No mechanism to automatically address review findings
- Gap between documentation (Pattern 2) and implementation

**Desired State**:
- Code-reviewer runs as part of verification phase (parallel with Tester + Validator)
- Critical review findings trigger automatic feedback to Coder agent or user
- Consistent with parallel-execution-REFERENCE.md Pattern 2

**Business Value**:
- Catches async bugs, memory leaks, security issues (Opus strength)
- Automated quality gate before close
- Reduces manual review effort

### How (Approach)

- **Phase 1**: Add Step 3.5 (Parallel Verification) with code-reviewer Task call
- **Phase 2**: Add Step 3.6 (Review Feedback Loop) for handling critical findings
- **Phase 3**: Update Step 2.5 reference text for accuracy
- **Phase 4**: Verification (test with sample execution)

### Success Criteria

SC-1: Code-reviewer Task call added to /02_execute
- Verify: grep "code-reviewer" .claude/commands/02_execute.md
- Expected: Task invocation block with code-reviewer subagent_type

SC-2: Parallel Verification step documented
- Verify: grep "Step 3.5" .claude/commands/02_execute.md
- Expected: Step 3.5 section with Tester + Validator + Code-Reviewer

SC-3: Review Feedback Loop implemented
- Verify: grep "Review Feedback Loop" .claude/commands/02_execute.md
- Expected: Step 3.6 section with conditional feedback handling

SC-4: Existing documentation consistent
- Verify: grep -A 10 "Pattern 2" .claude/guides/parallel-execution-REFERENCE.md | grep "code-reviewer"
- Expected: Pattern 2 mentions code-reviewer in verification phase (line ~95-103)

### Constraints

- Must maintain backward compatibility with existing /02_execute workflow
- Must not break sequential execution fallback
- Code-reviewer uses Opus model (cost consideration)
- Review feedback loop should be optional (skip if no critical issues)

## Scope

### In Scope
- `.claude/commands/02_execute.md` - Add Step 3.5 and Step 3.6
- Update Step 2.5 description for accuracy

### Out of Scope
- `.claude/commands/03_close.md` - No changes
- `.claude/commands/90_review.md` - No changes
- `.claude/agents/code-reviewer.md` - No changes
- `.claude/guides/parallel-execution.md` - No changes (already documented)

## Test Environment (Detected)

- Project Type: Documentation/Configuration
- Test Framework: N/A (markdown files)
- Test Command: Manual verification via grep
- Verification: Structure and content checks

## Execution Context (Planner Handoff)

### Explored Files
| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Target file | 102-121 (Step 2.5), 123-217 (Step 3) | Missing code-reviewer Task call |
| `.claude/commands/03_close.md` | Reference | 102-139 (Step 5) | Only has documenter agent |
| `.claude/guides/parallel-execution-REFERENCE.md` | Pattern reference | 74-168 (Pattern 2) | Shows intended design |
| `.claude/agents/code-reviewer.md` | Agent definition | All | Opus model, deep review |

### Key Decisions Made
| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Add to /02_execute, not /03_close | Review findings need to be addressed before close | Add to /03_close (rejected - too late for fixes) |
| Parallel verification | Matches Pattern 2, faster execution | Sequential (rejected - slower) |
| Optional feedback loop | Balance between quality and speed | Mandatory (rejected - too strict) |

### Implementation Patterns (FROM CONVERSATION)

#### Architecture Diagram
> **FROM CONVERSATION:**
> ```
> Step 3: Coder Agent (구현)
>     ↓
> Step 3.5: Parallel Verification (NEW)
>     ├── Tester (테스트)
>     ├── Validator (타입/린트)
>     └── Code-Reviewer (리뷰)
>     ↓
> Step 3.6: Review Feedback Loop (NEW - 선택적)
>     IF critical issues found:
>         ├── Present issues to Coder or User
>         ├── Re-run Coder to fix
>         └── Re-run Verification
>     ELSE:
>         └── Continue to Step 4
> ```

### Warnings & Gotchas
| Issue | Location | Recommendation |
|-------|----------|----------------|
| Opus model cost | code-reviewer agent | Consider making code-reviewer optional via flag |
| Parallel todo display | Step 2.5 | Ensure todo rules match parallel execution |

## Architecture

### Current Flow (02_execute)
```
Step 1: Plan State Transition
Step 2: Convert Plan to Todo List
Step 2.5: SC Dependency Analysis (mentions code-reviewer, no Task call)
Step 3: Delegate to Coder Agent
Step 4: Execute with TDD (DEPRECATED)
Step 5: Ralph Loop
Step 6: Todo Continuation
Step 7: Verification
Step 8: Update Plan Artifacts
Step 9: Auto-Chain to Documentation
```

### Proposed Flow
```
Step 1: Plan State Transition
Step 2: Convert Plan to Todo List
Step 2.5: SC Dependency Analysis
Step 3: Delegate to Coder Agent(s)
Step 3.5: Parallel Verification (NEW)
    - Tester Agent (tests/coverage)
    - Validator Agent (type/lint)
    - Code-Reviewer Agent (deep review)
Step 3.6: Review Feedback Loop (NEW)
    - IF critical issues: Re-invoke Coder or ask user
    - ELSE: Continue
Step 4: (DEPRECATED)
Step 5: Ralph Loop
...
```

## Vibe Coding Compliance

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Function length | ≤50 lines | N/A (markdown) | ✅ |
| File length | ≤200 lines | ~365 lines | ⚠️ (acceptable for command file) |
| Nesting depth | ≤3 levels | N/A | ✅ |

## Execution Plan

### Phase 1: Add Parallel Verification Step (Step 3.5)
1. Insert Step 3.5 after Step 3.4 in 02_execute.md
2. Add Tester, Validator, Code-Reviewer Task calls (parallel)
3. Add result processing for each agent

### Phase 2: Add Review Feedback Loop (Step 3.6)
1. Insert Step 3.6 after Step 3.5
2. Add conditional logic for critical findings
3. Add AskUserQuestion for user guidance
4. Add re-invocation logic for Coder agent

### Phase 3: Update References
1. Update Step 2.5 description for accuracy
2. Ensure consistent wording with parallel-execution guide

### Phase 4: Verification
1. Read final file and verify structure
2. Check grep patterns for SC verification

## Acceptance Criteria

- [ ] AC-1: Step 3.5 (Parallel Verification) exists with 3 agent calls
- [ ] AC-2: Step 3.6 (Review Feedback Loop) exists with conditional logic
- [ ] AC-3: Code-reviewer Task call matches agent definition format
- [ ] AC-4: Step 2.5 accurately describes the verification agents

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Code-reviewer invocation present | grep "code-reviewer" | Task call block found | Manual | 02_execute.md |
| TS-2 | Step 3.5 exists | grep "Step 3.5" | Section header found | Manual | 02_execute.md |
| TS-3 | Step 3.6 exists | grep "Step 3.6" | Section header found | Manual | 02_execute.md |
| TS-4 | Parallel Task calls | grep -A 20 "Step 3.5" | 3 Task blocks | Manual | 02_execute.md |
| TS-5 | Feedback loop max iterations | Mock 3+ critical findings | Stops at iteration 3, asks user | Manual | Simulated |
| TS-6 | Code-reviewer failure | Opus unavailable/timeout | Graceful degradation, continue without deep review | Manual | Simulated |
| TS-7 | Empty review findings | No critical issues found | Proceeds to next step without feedback loop | Manual | Simulated |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Opus model cost increase | Medium | Medium | Add --no-review flag option |
| Feedback loop infinite | Low | High | Max 3 iterations limit |
| File structure break | Low | High | Verify with grep after edit |

## Environment Variables (if applicable)

| Variable | Purpose | Default | Required |
|----------|---------|---------|----------|
| CLAUDE_REVIEW_MODEL | Override code-reviewer model | opus | No |
| CLAUDE_REVIEW_MAX_ITERATIONS | Max feedback loop iterations | 3 | No |

> Note: These env vars are optional and only needed for advanced configuration. Default behavior (Opus model, 3 iterations) is recommended.

## Rollback Strategy

If Step 3.5/3.6 additions cause issues:

1. **Git Revert**: `git revert <commit-hash>` to restore original 02_execute.md
2. **Verify**: Run `/02_execute` on a test plan to confirm original behavior
3. **Alternative**: Comment out Step 3.5/3.6 sections with `<!-- -->` instead of deleting
4. **Partial Rollback**: Remove only Step 3.6 (feedback loop) while keeping Step 3.5 (parallel verification)

## Open Questions (with Recommended Defaults)

1. Should code-reviewer be optional via flag (e.g., `--no-deep-review`)?
   - **RECOMMENDED: No** - Always run code-reviewer for quality assurance
   - Rationale: Code-reviewer catches critical bugs (async, memory, security) that other tools miss

2. Should feedback loop have max iteration limit (e.g., 3)?
   - **RECOMMENDED: Yes, max 3 iterations**
   - Rationale: Prevents infinite loops while allowing reasonable fix attempts

3. Should critical issues automatically re-invoke Coder, or always ask user?
   - **RECOMMENDED: Ask user first**
   - Rationale: User should decide if fix is worth the context/cost; prevents unexpected behavior

---

---

## Execution Summary

### Changes Made
1. **Added Step 3.5 (Parallel Verification)** - Lines 221-339
   - 3 parallel Task invocations: Tester, Validator, Code-Reviewer
   - Result processing and error recovery for each agent
   - Reference to parallel-execution.md Pattern 2

2. **Added Step 3.6 (Review Feedback Loop)** - Lines 342-486
   - Critical findings detection from Code-Reviewer
   - Conditional feedback loop with max 3 iterations
   - Graceful degradation if Code-Reviewer fails
   - AskUserQuestion for user guidance on critical issues

3. **Updated Step 2.5** - Lines 102-125
   - Accurate description of Implementation Phase (Coder agents)
   - Accurate description of Verification Phase (Tester + Validator + Code-Reviewer)

### Verification Results
- ✅ TS-1: code-reviewer invocation present (line 277)
- ✅ TS-2: Step 3.5 exists (line 226)
- ✅ TS-3: Step 3.6 exists (line 347)
- ✅ TS-4: 3 parallel Task calls (tester, validator, code-reviewer)
- ✅ SC-4: Pattern 2 consistency verified

### Follow-ups
- None

**Status**: Complete - Ready for `/03_close`
**Next**: `/03_close` to archive and commit

## Review Recommendations Applied

| Issue | Severity | Status |
|-------|----------|--------|
| Add error path test scenarios (TS-5, TS-6, TS-7) | Critical | ✅ Applied |
| Add automated SC-4 verification | Warning | ✅ Applied |
| Add recommended defaults to Open Questions | Warning | ✅ Applied |
| Add Environment Variables section | Suggestion | ✅ Applied |
| Add Rollback Strategy section | Suggestion | ✅ Applied |
