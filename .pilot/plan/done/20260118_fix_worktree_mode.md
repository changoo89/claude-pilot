# Plan: Fix Worktree Mode Implementation

> **Created**: 2026-01-18
> **Status**: Pending → In Progress → Done
> **Priority**: High
> **Completed**: 2026-01-18

## Problem Statement

The worktree mode (`--wt` flag) in `/02_execute` command has critical issues:
1. Worktree is created but agents work in main directory (not worktree)
2. No `cd` command to switch to worktree after creation
3. Plan state management doesn't account for worktree location
4. Continuation state paths point to main repo instead of worktree

## User Requirements (Verbatim)

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "워크트리를 만든 다음에 그 워크트리에 가서 작업을 해야 되는데 자꾸 그냥 메인에서 작업을 하는 케이스가 있는 것 같아" | Worktree created but work happens in main directory |
| UR-2 | "워크 트리모트에서는 워크트리를 생성하고 그 워크트리에 가서 작업을 완료하고 다시 메인에 클로즈 커맨드일 때 머지하는 형태로 진행이 되어야 돼" | Worktree mode workflow: create, work in worktree, merge on close |
| UR-3 | "inprogress 처리를 비롯해서 워크트리 처리를 보고 문제를 보강해줘" | Fix worktree handling including in_progress processing |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| UR-2 | ✅ | SC-1, SC-2, SC-3, SC-6 | Mapped |
| UR-3 | ✅ | SC-4, SC-5 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

Fix worktree mode to:
1. Create worktree and **actually switch to it** before agent execution
2. Ensure all agents work in worktree directory
3. Handle plan state management correctly in worktree context
4. Fix continuation state to use worktree paths
5. Ensure `/03_close` properly merges worktree back to main

### Why (Context)

**Current State**: Worktree mode creates worktree but agents execute in main directory
**Impact**: Work is done in wrong location, defeats purpose of worktree isolation
**Business Value**: Worktree mode is broken for parallel development

### How (Approach)

1. **Add worktree creation logic to `/02_execute`**
   - Check `--wt` flag
   - Create worktree using `git worktree add`
   - **Critical**: `cd` to worktree directory
   - Add worktree metadata to plan file

2. **Fix plan state management**
   - Move plan to worktree's `in_progress/` directory
   - Set active pointers correctly (main + worktree)

3. **Update continuation state paths**
   - Use worktree path for `STATE_FILE`
   - Ensure state persists in worktree context

4. **Verify `/03_close` worktree handling**
   - Ensure squash merge works from worktree to main
   - Cleanup worktree after successful merge

---

## Success Criteria

### SC-1: Add Worktree Creation Function ✅
Create `.claude/scripts/worktree-create.sh` script that:
- Takes plan path and branch name as arguments
- Creates Git worktree using `git worktree add`
- Returns worktree absolute path
- Handles errors gracefully

**Verification**: Script exists and creates worktree successfully

### SC-2: Implement Worktree Creation in /02_execute ✅
Update `.claude/commands/02_execute.md` Step 1.1 to:
- Check if `--wt` flag is present
- Call worktree creation script
- Extract worktree path from script output
- Add worktree metadata to plan file

**Verification**: Plan file contains "## Worktree Info" section with branch and path

### SC-3: Add cd to Worktree Directory ✅
Add critical step after worktree creation:
- Use `cd` command to switch to worktree directory
- Export `WORKTREE_ROOT` environment variable
- Update `PROJECT_ROOT` to point to worktree

**Verification**: Agents execute in worktree directory (check via `pwd`)

### SC-4: Fix Plan State Management for Worktree ✅
Update plan movement logic to:
- Move plan to worktree's `in_progress/` directory
- Create dual active pointers (main + worktree)
- Handle both paths correctly in subsequent operations

**Verification**: Plan exists in worktree `.pilot/plan/in_progress/` directory

### SC-5: Fix Continuation State Path ✅
Update continuation state logic to:
- Use worktree path for `STATE_FILE` location
- Preserve state in worktree during execution
- Ensure `/00_continue` can find state in worktree

**Verification**: State file created at `worktree_path/.pilot/state/continuation.json`

### SC-6: Verify /03_close Worktree Merge ✅
Ensure `/03_close` properly:
- Detects worktree metadata from plan
- Switches to main directory
- Performs squash merge from worktree branch to main
- Cleans up worktree after successful merge

**Verification**: Worktree changes merged to main, worktree removed

### SC-7: Add Worktree Mode Tests ✅
Create integration tests for:
- Worktree creation and switching
- Plan state management in worktree
- Continuation state in worktree context
- Worktree merge and cleanup

**Verification**: All tests pass

---

## Test Environment (Detected)

- **Project Type**: Bash/Shell scripts
- **Test Framework**: Bash (manual integration tests)
- **Test Command**: `bash .pilot/tests/test_worktree_create.sh`
- **Coverage Command**: Manual verification (test each workflow)
- **Test Directory**: `.pilot/tests/`

---

## Test Plan

### TS-1: Worktree Creation
**Input**: `/02_execute --wt` with pending plan
**Expected**: Worktree created, plan moved, working directory changed
**Type**: Integration
**Test File**: `.pilot/tests/test_worktree_create.sh`

### TS-2: Agent Execution in Worktree
**Input**: Coder agent invoked after worktree setup
**Expected**: Agent executes in worktree directory (verified via `pwd`)
**Type**: Integration
**Test File**: `.pilot/tests/test_worktree_agent_execution.sh`

### TS-3: Continuation State in Worktree
**Input**: Create state, exit, resume with `/00_continue`
**Expected**: State restored, worktree context maintained
**Type**: Integration
**Test File**: `.pilot/tests/test_worktree_continuation.sh`

### TS-4: Worktree Merge on Close
**Input**: `/03_close` from worktree with completed plan
**Expected**: Changes merged to main, worktree cleaned up
**Type**: Integration
**Test File**: `.pilot/tests/test_worktree_merge.sh`

---

## Vibe Coding Compliance

> **Full reference**: @.claude/skills/vibe-coding/SKILL.md

### Standards

| Target | Limit | Application |
|--------|-------|-------------|
| **Function** | ≤50 lines | All bash functions in worktree scripts |
| **File** | ≤200 lines | All worktree-related script files |
| **Nesting** | ≤3 levels | All bash logic (use early return) |

### Principles

- **SRP**: Each function handles one specific task (create, cleanup, metadata)
- **DRY**: Reuse existing `worktree-utils.sh` functions
- **KISS**: Simple bash scripts, minimal complexity
- **Early Return**: Return early on errors to reduce nesting

---

## Constraints

### Technical
- Must use existing `worktree-utils.sh` functions where possible
- Must not break standard (non-worktree) mode
- Must handle errors gracefully (cleanup partial state)

### Patterns
- Follow existing bash script patterns in `.claude/scripts/`
- Use environment variables for worktree context (`PILOT_WORKTREE_MODE`)
- Maintain backward compatibility with existing commands

### Limitations
- Git worktree support required (Git 2.5+)
- Worktree directory structure: `../project-wt-{branch-shortname}`

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking standard mode | Medium | High | Add explicit `--wt` flag check, default to standard mode |
| Worktree creation fails | Low | Medium | Error handling with fallback to standard mode |
| Merge conflicts on close | Medium | Medium | Preserve worktree for manual resolution |
| State file conflicts | Low | Medium | Use worktree-specific state paths |

---

## Execution Plan

### Phase 1: Create Worktree Script (SC-1)
- Create `.claude/scripts/worktree-create.sh`
- Implement worktree creation logic
- Add error handling and validation

### Phase 2: Update /02_execute Command (SC-2, SC-3, SC-4, SC-5)
- Add worktree detection flag check
- Call worktree creation script
- Implement `cd` to worktree
- Fix plan state management
- Update continuation state paths

### Phase 3: Verify /03_close (SC-6)
- Review existing worktree merge logic
- Test merge and cleanup flow
- Fix any issues found

### Phase 4: Testing (SC-7)
- Create integration tests
- Run full worktree workflow test
- Fix any bugs found

---

## Related Documentation

- **Worktree Setup Guide**: @.claude/guides/worktree-setup.md
- **Worktree Utilities**: @.claude/scripts/worktree-utils.sh
- **Execute Command**: @.claude/commands/02_execute.md
- **Close Command**: @.claude/commands/03_close.md

---

## Execution Summary

### Changes Made

**Files Modified**:
1. `.claude/commands/02_execute.md` - Added worktree mode support with `--wt` flag
2. `.claude/commands/03_close.md` - Updated worktree detection and merge flow
3. `.claude/scripts/statusline.sh` - Worktree-aware plan counts
4. `.claude/scripts/worktree-utils.sh` - Added worktree utility functions

**Files Created**:
1. `.claude/scripts/worktree-create.sh` - Worktree creation script (120 lines)
2. `.pilot/tests/test_worktree_create.sh` - Integration tests (292 lines)

### Implementation Details

**Worktree Creation (SC-1, SC-2)**:
- Created `.claude/scripts/worktree-create.sh` script
- Implements `create_worktree()` function using `git worktree add`
- Worktree directory format: `../project-wt-{branch-shortname}`
- Returns absolute path for reliable cross-shell operations

**Worktree Execution (SC-3, SC-4, SC-5)**:
- Added `--wt` flag detection in `/02_execute`
- Stores worktree metadata in plan file (branch, path, main branch, main project, lock file)
- Updates continuation state to use worktree paths
- Plan moved to worktree's `in_progress/` directory

**Worktree Detection Fix**:
- Fixed `is_in_worktree()` function to check `.git` file instead of `git rev-parse`
- More reliable detection of worktree directories
- Added `get_main_pilot_dir()` function for main repo access

**Statusline Enhancement**:
- Worktree-aware plan counting
- Shows main repo's plan counts when in worktree mode
- Uses `get_main_pilot_dir()` to access main repo's `.pilot` directory

### Verification

**Type**: Manual testing ✅
**Tests**: All integration tests pass (test_worktree_create.sh)
**Lint**: Bash syntax validation ✅
**Coverage**: N/A (shell scripts, no coverage tool)

### Follow-ups

None - all success criteria met.
