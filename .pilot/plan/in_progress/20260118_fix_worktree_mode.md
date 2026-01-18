# Plan: Fix /03_close Git Push Completion

> **Created**: 2026-01-18
> **Status**: Pending → In Progress → Done
> **Branch**: main

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 2026-01-18 | "03 클로징 모드는 반드시 깃 푸시까지 완료하는 걸 목표로 해줘" | 03_close must complete git push |
| UR-2 | 2026-01-18 | "워크트리모드에서는 메인에 병합하는 것까지 목표로 해야 돼" | Worktree mode must merge to main |
| UR-3 | 2026-01-18 | "자꾸 깃 커밋만 하고 푸시를 안 하는 케이스들이 보고되고 있어서 그래" | Users report commits without push |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3, SC-4 | Mapped |
| UR-3 | ✅ | SC-1, SC-2 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Make `/03_close` ensure git push completion in both normal and worktree modes

**Scope**:
- **In scope**:
  - Modify `/03_close.md` to make git push mandatory (blocking)
  - Modify `/03_close.md` worktree merge flow to include git push
  - Add push verification step
  - Update worktree-utils.sh if needed
- **Out of scope**:
  - Changing `/02_execute` behavior
  - Modifying git configuration
  - Force push functionality

**Deliverables**:
1. Updated `/03_close.md` with mandatory git push
2. Updated worktree merge flow with push step
3. Push failure handling with clear error messages
4. Test scenarios for verification

### Why (Context)

**Current Problem**:
- Users report commits created but not pushed (UR-3)
- Git push is "Optional, Non-Blocking" in `/03_close` Step 7.3
- Worktree mode merges to main but doesn't push changes
- Manual intervention required to push commits

**Business Value**:
- **User impact**: Eliminate manual push steps, complete workflows automatically
- **Technical impact**: Consistent git state across local and remote
- **Workflow impact**: True "close and done" experience

### How (Approach)

**Implementation Strategy**:
1. Change git push from optional to mandatory in normal mode
2. Add git push step after worktree squash merge
3. Add push verification step before marking plan complete
4. Provide clear error messages on push failure
5. Block plan closure if push fails

**Dependencies**:
- Existing worktree-utils.sh functions
- Git remote configuration
- Network connectivity

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| No remote configured | High | Medium | Detect early, skip push with warning |
| Network failure | Medium | Medium | Retry logic (3 attempts), clear error |
| Auth failure | Medium | High | Clear error message, manual push instructions |
| Protected branch | Low | High | Detect dry-run, clear error message |

#### Error Handling Strategy

| Error Scenario | Detection | Action | Exit Code | User Message |
|----------------|-----------|--------|-----------|--------------|
| No remote configured | `git config --get remote.origin.url` fails | Skip push with warning | 0 | "No remote configured - commit created locally only" |
| Network failure | `git push` exit code 128 | Retry 3x with exponential backoff | 1 | "Network error after 3 attempts - push failed" |
| Auth failure | `git push` exit code 128 + "authentication" in stderr | Fail immediately | 1 | "Authentication failed - check credentials" |
| Non-fast-forward | `git push` exit code 1 + "non-fast-forward" in stderr | Fail immediately | 1 | "Remote has new commits - run 'git pull' first" |
| Protected branch | `git push --dry-run` fails + "protected" in output | Fail immediately | 1 | "Branch is protected - cannot push directly" |
| Worktree push fails | `git push` fails in worktree flow | Skip cleanup, preserve worktree | 1 | "Worktree push failed - worktree preserved for manual push" |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: `/03_close` blocks if git push fails in normal mode
  **Verify**: `bash .pilot/tests/test_close_push_fail.sh && [ $? -eq 0 ]`
- [ ] **SC-2**: `/03_close` verifies push success before marking plan complete
  **Verify**: `bash .pilot/tests/test_verify_push.sh && [ $? -eq 0 ]`
- [ ] **SC-3**: Worktree mode includes git push after squash merge
  **Verify**: `bash .pilot/tests/test_close_worktree_push.sh && [ $? -eq 0 ]`
- [ ] **SC-4**: Worktree mode blocks if push fails
  **Verify**: `bash .pilot/tests/test_close_worktree_push_fail.sh && [ $? -eq 0 ]`
- [ ] **SC-5**: Clear error messages when push fails
  **Verify**: `bash .pilot/tests/test_close_push_fail.sh 2>&1 | grep -q "git push origin"`

**Verification Method**: Test with mock git repository, simulate push failures

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Normal mode successful push | Git repo with remote | Commit created, push succeeds, plan closed | Integration | `.pilot/tests/test_close_push.sh` |
| TS-2 | Normal mode push failure (no remote) | Git repo without remote | Commit created, push skipped with warning, plan closed | Integration | `.pilot/tests/test_close_no_remote.sh` |
| TS-3 | Normal mode push failure (network) | Mock network failure | Commit created, push fails with error, plan closure blocked | Integration | `.pilot/tests/test_close_push_fail.sh` |
| TS-4 | Worktree mode successful push | Worktree with remote | Squash merge, commit created, push succeeds, worktree cleaned | Integration | `.pilot/tests/test_close_worktree_push.sh` |
| TS-5 | Worktree mode push failure | Worktree, push fails | Squash merge, commit created, push fails, worktree preserved | Integration | `.pilot/tests/test_close_worktree_push_fail.sh` |
| TS-6 | Push verification after commit | Existing commit | Verify push succeeded by checking remote ref | Unit | `.pilot/tests/test_verify_push.sh` |

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Shell/Bash
- **Test Framework**: BATS (Bash Automated Testing System) or manual shell scripts
- **Test Command**: `bash .pilot/tests/test_close_*.sh`
- **Test Directory**: `.pilot/tests/`
- **Coverage Target**: All push scenarios (success, failure, worktree, normal)

#### Test Infrastructure

**Mock Git Repository Setup**:
```bash
setup_mock_repo() {
    local test_dir="$1"
    local has_remote="${2:-true}"

    # Create test repo
    mkdir -p "$test_dir"
    cd "$test_dir"
    git init

    # Configure user
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "test" > README.md
    git add README.md
    git commit -m "Initial commit"

    # Create mock remote (bare repo)
    if [ "$has_remote" = "true" ]; then
        git init --bare ../remote.git
        git remote add origin ../remote.git
    fi

    cd -
}
```

**Mock Network Failure**:
```bash
# Override git push to simulate failure
mock_git_push_failure() {
    git() {
        if [ "$1" = "push" ]; then
            echo "fatal: could not read Username for 'https://github.com': terminal prompts disabled" >&2
            return 128
        else
            command git "$@"
        fi
    }
    export -f git
}
```

**Test Cleanup**:
```bash
cleanup_mock_repo() {
    local test_dir="$1"
    rm -rf "$test_dir"
}
```

---

## Execution Plan

### Phase 1: Discovery & Analysis

- [x] Read `/03_close.md` to understand current implementation
- [x] Read `worktree-utils.sh` to understand worktree functions
- [x] Identify git push locations (Step 7.3 for normal, Step 1 for worktree)
- [x] Analyze push failure handling

### Phase 2: Design

- [x] Design mandatory push flow for normal mode
- [x] Design push step for worktree merge flow
- [x] Design error messages for push failures
- [x] Design verification step

### Phase 3: Implementation (TDD Cycle)

#### SC-1: Normal mode blocks if push fails

**Red Phase**:
- [ ] Create test: `.pilot/tests/test_close_push_fail.sh`
- [ ] Write assertion: `/03_close` should exit with error when push fails

**Green Phase**:
- [ ] Modify `/03_close.md` Step 7.3: Remove "Optional, Non-Blocking" header
- [ ] Modify `/03_close.md` Step 7.3: Add blocking behavior on push failure
- [ ] Add exit code 1 when push fails

**Refactor Phase**:
- [ ] Apply Vibe Coding standards
- [ ] Run all tests

#### SC-2: Verify push success before marking complete

**Red Phase**:
- [ ] Create test: `.pilot/tests/test_verify_push.sh`
- [ ] Write assertion: Push verification succeeds only when remote ref matches local

**Green Phase**:
- [ ] **Clarification**: Reuse existing Step 7.4 verification logic (checks `PUSH_RESULTS` array)
- [ ] **Enhancement**: Add SHA comparison verification to existing logic
- [ ] Modify `/03_close.md` Step 7.4: Enhance existing push verification check
- [ ] Add verification: `git rev-parse HEAD` == `git rev-parse origin/$BRANCH` after push

**Refactor Phase**:
- [ ] Apply Vibe Coding standards
- [ ] Run all tests

#### SC-3: Worktree mode includes push after squash merge

**Red Phase**:
- [ ] Create test: `.pilot/tests/test_close_worktree_push.sh`
- [ ] Write assertion: Worktree merge flow includes git push

**Green Phase**:
- [ ] **Exact Insertion Point**: Modify `/03_close.md` Step 1, insert AFTER line 107 (after `do_squash_merge` success block, BEFORE `cleanup_worktree`)
- [ ] Add git push step after squash merge success
- [ ] Reuse git_push_with_retry function (defined in `/03_close.md` Step 7.2.5, lines 522-557)
- [ ] **Insertion Code**:
  ```bash
  # Push after squash merge (insert between lines 107-108)
  echo "Pushing squash merge to remote..."
  cd "$MAIN_PROJECT_DIR" || exit 1
  PUSH_OUTPUT="$(git_push_with_retry "origin" "$WT_MAIN" 2>&1)"
  PUSH_EXIT=$?

  if [ "$PUSH_EXIT" -ne 0 ]; then
      ERROR_MSG="$(get_push_error_message $PUSH_EXIT "$PUSH_OUTPUT")"
      echo "ERROR: Push failed - $ERROR_MSG" >&2
      echo "Worktree preserved for manual push" >&2
      rm -rf "$LOCK_FILE" 2>/dev/null
      trap - EXIT ERR
      exit 1
  fi
  ```
- [ ] Add push success verification: Check `git log origin/$WT_MAIN..HEAD` is empty

**Refactor Phase**:
- [ ] Apply Vibe Coding standards
- [ ] Run all tests

#### SC-4: Worktree mode blocks if push fails

**Red Phase**:
- [ ] Create test: `.pilot/tests/test_close_worktree_push_fail.sh`
- [ ] Write assertion: Worktree preserved when push fails

**Green Phase**:
- [ ] Modify `/03_close.md` Step 1: Add error handling for push failure
- [ ] Skip cleanup_worktree when push fails
- [ ] Clear lock file but preserve worktree
- [ ] Return exit code 1

**Refactor Phase**:
- [ ] Apply Vibe Coding standards
- [ ] Run all tests

#### SC-5: Clear error messages when push fails

**Red Phase**:
- [ ] Update existing tests to check for error messages
- [ ] Write assertion: Error message includes actionable instructions

**Green Phase**:
- [ ] Modify `/03_close.md`: Enhance error messages in push failure handling
- [ ] Add manual push instructions: `git push origin <branch>`
- [ ] Include failure reason in message

**Refactor Phase**:
- [ ] Apply Vibe Coding standards
- [ ] Run all tests

### Phase 4: Ralph Loop (Autonomous Completion)

**Entry**: After first code change

**Loop until**:
- [ ] All tests pass
- [ ] Push verification works in both modes
- [ ] Error messages are clear and actionable
- [ ] No regression in existing functionality

**Max iterations**: 7

### Phase 5: Verification (Parallel)

**Parallel verification** (3 agents):
- [ ] **Tester**: Run all test scenarios, verify coverage
- [ ] **Validator**: Check bash syntax, verify no broken references
- [ ] **Code-Reviewer**: Review code quality, error handling

---

## Constraints

### Technical Constraints
- Must maintain backward compatibility with `no-commit` flag
- Must handle repos without remote gracefully (skip push with warning)
- Must work with existing worktree-utils.sh functions

### Business Constraints
- Cannot force push (security risk)
- Must provide clear error messages
- Must preserve commit on push failure

### Quality Constraints
- All test scenarios must pass
- Error messages must be actionable
- No regression in existing functionality
- Vibe Coding standards applied (functions ≤50 lines)

---

## Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1-T1 | Read /03_close.md Step 7.3 current implementation | coder | 5 min | pending |
| SC-1-T2 | Remove "Optional, Non-Blocking" header from Step 7.3 | coder | 2 min | pending |
| SC-1-T3 | Add blocking behavior: exit 1 if PUSH_RESULTS contains failed | coder | 10 min | pending |
| SC-1-T4 | Create test_close_push_fail.sh test | tester | 10 min | pending |
| SC-1-T5 | Verify SC-1 test passes | validator | 2 min | pending |
| SC-2-T1 | Read /03_close.md Step 7.4 current implementation | coder | 5 min | pending |
| SC-2-T2 | Add push verification: compare local/remote SHA | coder | 15 min | pending |
| SC-2-T3 | Create test_verify_push.sh test | tester | 10 min | pending |
| SC-2-T4 | Verify SC-2 test passes | validator | 2 min | pending |
| SC-3-T1 | Read /03_close.md Step 1 worktree flow | coder | 5 min | pending |
| SC-3-T2 | Add git push step after do_squash_merge in Step 1 | coder | 10 min | pending |
| SC-3-T3 | Reuse git_push_with_retry function from Step 7.2.5 | coder | 5 min | pending |
| SC-3-T4 | Create test_close_worktree_push.sh test | tester | 15 min | pending |
| SC-3-T5 | Verify SC-3 test passes | validator | 2 min | pending |
| SC-4-T1 | Add error handling for worktree push failure in Step 1 | coder | 10 min | pending |
| SC-4-T2 | Skip cleanup_worktree when push fails | coder | 5 min | pending |
| SC-4-T3 | Clear lock file but preserve worktree on failure | coder | 5 min | pending |
| SC-4-T4 | Return exit code 1 on worktree push failure | coder | 2 min | pending |
| SC-4-T5 | Create test_close_worktree_push_fail.sh test | tester | 15 min | pending |
| SC-4-T6 | Verify SC-4 test passes | validator | 2 min | pending |
| SC-5-T1 | Enhance error messages in push failure handling | coder | 10 min | pending |
| SC-5-T2 | Add manual push instructions to error messages | coder | 5 min | pending |
| SC-5-T3 | Update all tests to verify error messages | tester | 10 min | pending |
| SC-5-T4 | Verify SC-5 tests pass | validator | 2 min | pending |

**Granularity Verification**: ✅ All todos comply with 3 rules (≤15 min, single owner, atomic)
**Warnings**: None

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-18 | Claude (Planner) | Plan created with PRP analysis, test plan, granular todos | Ready for review |
| 2026-01-18 | Plan-Reviewer Agent | 3 Critical, 2 Warning, 3 Suggestion | Needs revision |
| 2026-01-18 | Claude (Reviser) | Applied all Critical fixes, applied Warning fixes | Revised and approved |

---

## Completion Checklist

**Before marking plan complete**:

- [ ] All SCs marked complete
- [ ] All tests pass (TS-1 through TS-6)
- [ ] Normal mode blocks on push failure
- [ ] Normal mode verifies push success
- [ ] Worktree mode includes push step
- [ ] Worktree mode blocks on push failure
- [ ] Error messages are clear and actionable
- [ ] No regression in existing functionality
- [ ] Plan archived to `.pilot/plan/done/`

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Todo Granularity**: @.claude/guides/todo-granularity.md
- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

**Template Version**: claude-pilot 4.2.0 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
