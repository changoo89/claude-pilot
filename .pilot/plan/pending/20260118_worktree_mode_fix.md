# Plan: Fix Worktree Mode Implementation

> **Generated**: 2026-01-18 | Work: worktree_mode_fix | Location: .pilot/plan/pending/20260118_worktree_mode_fix.md

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

## Problem Statement

The worktree mode (`--wt` flag) in `/02_execute` command has critical issues:
1. Worktree is created but agents work in main directory (not worktree)
2. No `cd` command to switch to worktree after creation
3. Plan state management doesn't account for worktree location
4. Continuation state paths point to main repo instead of worktree

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

### SC-1: Add Worktree Creation Function
Create `.claude/scripts/worktree-create.sh` script that:
- Takes plan path and branch name as arguments
- Creates Git worktree using `git worktree add`
- Returns worktree absolute path
- Handles errors gracefully

**Verification Commands**:
- `test -f .claude/scripts/worktree-create.sh`
- `bash .claude/scripts/worktree-create.sh --help` (returns usage)
- Create test worktree: `git worktree list | grep -q "wt-test"`

### SC-2: Implement Worktree Creation in /02_execute
Update `.claude/commands/02_execute.md` Step 1.1 to:
- Check if `--wt` flag is present
- Call worktree creation script
- Extract worktree path from script output
- Add worktree metadata to plan file

**Verification Commands**:
- `grep -q "worktree-create.sh" .claude/commands/02_execute.md`
- `grep -q "## Worktree Info" "$PLAN_PATH"`
- `jq '.branch' "$PLAN_PATH" | grep -q "feature/"`

### SC-3: Add cd to Worktree Directory
Add critical step after worktree creation:
- Use `cd` command to switch to worktree directory
- Export `WORKTREE_ROOT` environment variable
- Update `PROJECT_ROOT` to point to worktree

**Verification Commands**:
- `grep -q 'cd "$WORKTREE_DIR"' .claude/commands/02_execute.md`
- Source updated execute command: `echo $PROJECT_ROOT | grep -q "wt-"`
- `echo $PILOT_WORKTREE_MODE | grep -q "1"`

### SC-4: Fix Plan State Management for Worktree
Update plan movement logic to:
- Move plan to worktree's `in_progress/` directory
- Create dual active pointers (main + worktree)
- Handle both paths correctly in subsequent operations

**Verification Commands**:
- `test -f "${WORKTREE_ROOT}/.pilot/plan/in_progress/$(basename "$PLAN_PATH")"`
- `test -f .pilot/plan/active/$(basename "$PLAN_PATH")` (dual pointer)
- `cat .pilot/plan/active/*.txt | grep -q "WORKTREE_PLAN="`

### SC-5: Fix Continuation State Path
Update continuation state logic to:
- Use worktree path for `STATE_FILE` location
- Preserve state in worktree during execution
- Ensure `/00_continue` can find state in worktree

**Verification Commands**:
- `test -f "${WORKTREE_ROOT}/.pilot/state/continuation.json"`
- `jq '.session_id' "${WORKTREE_ROOT}/.pilot/state/continuation.json"` (valid JSON)
- `jq '.plan_file' "${WORKTREE_ROOT}/.pilot/state/continuation.json" | grep -q "worktree"`

### SC-6: Verify /03_close Worktree Merge
Ensure `/03_close` properly:
- Detects worktree metadata from plan
- Switches to main directory
- Performs squash merge from worktree branch to main
- Cleans up worktree after successful merge

**Verification Commands**:
- `grep -q "do_squash_merge" .claude/commands/03_close.md`
- `grep -q "cleanup_worktree" .claude/commands/03_close.md`
- Test merge: `git log main --oneline | grep -q "worktree"`
- Verify cleanup: `! git worktree list | grep -q "wt-test"`

### SC-7: Add Worktree Mode Tests
Create integration tests for:
- Worktree creation and switching
- Plan state management in worktree
- Continuation state in worktree context
- Worktree merge and cleanup

**Coverage Target**: 100% of worktree workflow paths

**Verification Commands**:
- `bash .pilot/tests/test_worktree_create.sh` (exit 0)
- `bash .pilot/tests/test_worktree_agent_execution.sh` (exit 0)
- `bash .pilot/tests/test_worktree_continuation.sh` (exit 0)
- `bash .pilot/tests/test_worktree_merge.sh` (exit 0)
- Manual workflow test succeeds

---

## Scope

### In Scope
- Worktree creation script (`worktree-create.sh`)
- Update `/02_execute` command for worktree mode
- Fix plan state management for worktree
- Fix continuation state paths
- Verify `/03_close` worktree handling
- Create integration tests

### Out of Scope
- Changes to standard (non-worktree) mode
- Git worktree core functionality
- New worktree features beyond fixing existing bugs

---

## Test Environment (Detected)

- **Project Type**: Bash/Shell scripts
- **Test Framework**: Bash (manual integration tests)
- **Test Command**: `bash .pilot/tests/test_worktree_create.sh`
- **Coverage Command**: Manual verification (test each workflow)
- **Test Directory**: `.pilot/tests/`

---

## Execution Context (Planner Handoff)

### Key Findings from Code Analysis

1. **Worktree Creation Logic Missing**: The `worktree-setup.md` guide shows complete worktree setup, but `02_execute.md` only references it without implementing the actual creation and `cd` logic.

2. **Dual Pointer System**: The worktree setup creates dual active pointers (main repo + worktree-local), but the execute command doesn't properly use them.

3. **Continuation State Path**: State file uses `PROJECT_ROOT` which always points to main repo, not worktree.

4. **Close Command Has Worktree Logic**: The `/03_close` command already has worktree merge logic, but execute doesn't properly set up the worktree context.

### Implementation Patterns (FROM CONVERSATION)

#### Worktree Creation Pattern
> **Current approach in worktree-utils.sh**:
```bash
# Convert plan filename to branch name
plan_to_branch() {
    local plan_file="$1"
    plan_file="$(basename "$plan_file" .md)"
    # 20260113_160000_worktree_support → feature/20260113-160000-worktree-support
    printf "feature/%s" "$plan_file" | sed 's/_/-/g'
}

# Create worktree in ../project-wt-{branch-shortname}
create_worktree() {
    local branch_name="$1"
    local project_name="$(basename "$(pwd)")"
    local branch_shortname="$(printf "%s" "$branch_name" | sed 's|^feature/||')"
    worktree_dir="../${project_name}-wt-${branch_shortname}"

    git worktree add -b "$branch_name" "$worktree_dir" "$main_branch"
    cd "$worktree_dir" && pwd  # Return absolute path
}
```

#### Critical Missing Step
> **FROM CONVERSATION ANALYSIS**:
The execute command MUST add this after worktree creation:
```bash
# CRITICAL: Change to worktree directory
cd "$WORKTREE_DIR" || { echo "Failed to cd to worktree" >&2; exit 1; }

# Update PROJECT_ROOT to point to worktree
export PROJECT_ROOT="$(pwd)"
export PILOT_WORKTREE_MODE=1
export PILOT_WORKTREE_ROOT="$PROJECT_ROOT"
```

#### Plan State Management for Worktree
> **Required approach**:
```bash
# Move plan to worktree's in_progress/ (NOT main repo)
WORKTREE_IN_PROGRESS="${WORKTREE_ROOT}/.pilot/plan/in_progress"
mkdir -p "$WORKTREE_IN_PROGRESS"
mv "$PLAN_PATH" "$WORKTREE_IN_PROGRESS/$(basename "$PLAN_PATH")"

# Update plan path for subsequent operations
PLAN_PATH="${WORKTREE_IN_PROGRESS}/$(basename "$PLAN_PATH")"
```

#### Continuation State Path Fix
> **Required fix**:
```bash
# Use worktree path for state file (NOT main repo)
STATE_DIR="${WORKTREE_ROOT}/.pilot/state"
STATE_FILE="${STATE_DIR}/continuation.json"
```

### Assumptions Requiring Validation

1. **Git Worktree Support**: Assumes Git 2.5+ is available (should verify during execution)
2. **Branch Naming**: Assumes feature branch naming pattern works for all use cases
3. **Main Branch**: Assumes main branch is named `main` (may need to detect `master`)
4. **Worktree Directory**: Assumes `../project-wt-*` pattern doesn't conflict with existing directories

### Dependencies on External Resources

- **Git worktree command**: Required for worktree functionality
- **jq**: Required for JSON state management (already in use)
- **Bash 4+**: Required for associative arrays and advanced features

---

## External Service Integration

Not applicable - this is internal tooling improvement.

---

## Architecture

### Current Architecture
```
Main Repo (main branch)
├── .pilot/plan/
│   ├── pending/
│   ├── in_progress/
│   └── active/
└── .claude/commands/
    ├── 02_execute.md (references worktree guide but doesn't implement)
    └── 03_close.md (has worktree merge logic)
```

### Target Architecture
```
Main Repo (main branch)
├── .pilot/plan/
│   └── active/ (dual pointers to worktree plans)

Worktree (feature branch)
├── .pilot/plan/
│   ├── in_progress/ (actual plan location)
│   └── active/ (local pointer)
├── .pilot/state/
│   └── continuation.json (state in worktree)
└── .claude/scripts/
    └── worktree-create.sh (NEW - worktree creation)
```

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

## Error Handling Strategy

### Worktree Creation Failures

**SC-1: worktree-create.sh error handling**:
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined variable, pipe failure

# Handle existing worktree
if git worktree list | grep -q "$branch_name"; then
    echo "Error: Worktree for $branch_name already exists" >&2
    exit 1
fi

# Handle git worktree command failure
if ! git worktree add -b "$branch_name" "$worktree_dir" "$main_branch"; then
    echo "Error: Failed to create worktree" >&2
    exit 1
fi
```

### cd Failures (SC-3)

**Critical: Exit if cd fails**:
```bash
# Critical: Exit if cd fails
cd "$WORKTREE_DIR" || {
    echo "Error: Failed to cd to worktree: $WORKTREE_DIR" >&2
    exit 1
}
```

### State File Creation Failures (SC-5)

**Ensure state directory exists**:
```bash
# Ensure state directory exists
mkdir -p "$(dirname "$STATE_FILE")" || {
    echo "Error: Failed to create state directory" >&2
    exit 1
}

# Validate state file creation
echo '{}' > "$STATE_FILE" || {
    echo "Error: Failed to create state file" >&2
    exit 1
}
```

### Rollback Strategy

**If worktree creation fails**:
1. Remove any partially created worktree directory
2. Remove worktree from git's worktree list: `git worktree remove <path>`
3. Restore plan to main repo's `in_progress/` if moved
4. Clean up any created pointers in `.pilot/plan/active/`

**Implementation**:
```bash
# Cleanup function
cleanup_worktree() {
    local worktree_dir="$1"

    # Remove from git worktree list
    if git worktree list | grep -q "$worktree_dir"; then
        git worktree remove "$worktree_dir" 2>/dev/null || true
    fi

    # Remove directory if exists
    if [ -d "$worktree_dir" ]; then
        rm -rf "$worktree_dir"
    fi

    echo "Cleanup complete: $worktree_dir"
}

# Usage with trap
trap 'cleanup_worktree "$WORKTREE_DIR"' ERR
```

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

## Acceptance Criteria

- [ ] Worktree creation script created and functional
- [ ] `/02_execute --wt` creates worktree and switches to it
- [ ] Agents execute in worktree directory
- [ ] Plan moved to worktree's `in_progress/` directory
- [ ] Continuation state stored in worktree
- [ ] `/03_close` merges worktree to main and cleans up
- [ ] All integration tests pass

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

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking standard mode | Medium | High | Add explicit `--wt` flag check, default to standard mode |
| Worktree creation fails | Low | Medium | Error handling with fallback to standard mode |
| Merge conflicts on close | Medium | Medium | Preserve worktree for manual resolution |
| State file conflicts | Low | Medium | Use worktree-specific state paths |

---

## Open Questions

None - all requirements clear from user input.

---

## Related Documentation

- **Worktree Setup Guide**: @.claude/guides/worktree-setup.md
- **Worktree Utilities**: @.claude/scripts/worktree-utils.sh
- **Execute Command**: @.claude/commands/02_execute.md
- **Close Command**: @.claude/commands/03_close.md
- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

## Gap Detection Review (MANDATORY)

| # | Category | Status |
|---|----------|--------|
| 9.1 | External API | ✅ (N/A - internal tooling) |
| 9.2 | Database Operations | ✅ (N/A - no database) |
| 9.3 | Async Operations | ✅ (N/A - synchronous scripts) |
| 9.4 | File Operations | ✅ (paths resolved, cleanup strategy defined) |
| 9.5 | Environment | ✅ (WORKTREE_ROOT, PROJECT_ROOT, PILOT_WORKTREE_MODE documented) |
| 9.6 | Error Handling | ✅ (Error handling strategy added) |
| 9.7 | Test Plan Verification | ✅ (4 test scenarios with file paths, coverage target defined) |

**Result**: 0 BLOCKING findings - Ready for execution
