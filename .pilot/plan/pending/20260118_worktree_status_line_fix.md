# Plan: Worktree-Aware Status Line Enhancement

> **Created**: 2026-01-18
> **Status**: Pending → In Progress → Done
> **Branch**: main
> **Plan ID**: 20260118_worktree_status_line_fix.md

---

## User Requirements (Verbatim)

| ID | Requirement | Source |
|----|-------------|--------|
| UR-1 | Status line should show pending plan count AND in-progress plan count | User input (Korean) |
| UR-2 | Status line must work correctly in worktrees (show main repo's plan counts) | User input (Korean) |
| UR-3 | Pending count should decrease when plan moves to in_progress in worktree | User input (Korean) |
| UR-4 | Create comprehensive plan for worktree status tracking | User input (Korean) |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-3 | Mapped |
| UR-2 | ✅ | SC-2, SC-4 | Mapped |
| UR-3 | ✅ | SC-3, SC-4 | Mapped |
| UR-4 | ✅ | All SCs | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix status line to correctly display plan counts in both main repository and worktrees

**Scope**:
- **In Scope**:
  - Modify `.claude/scripts/statusline.sh` to detect worktree environment
  - Add in-progress plan count display (in addition to pending count)
  - Ensure pending count is always sourced from main repository's `.pilot/plan/pending/`
  - Ensure in-progress count is sourced from main repository's `.pilot/plan/in_progress/`
  - Maintain backward compatibility with non-worktree environments
- **Out of Scope**:
  - Changing the plan state management logic (`/02_execute`)
  - Modifying worktree creation scripts
  - Changing the active plan pointer system

**Deliverables**:
1. Updated `statusline.sh` with worktree-aware plan counting
2. Status line showing both pending (P) and in-progress (I) counts: `📋 P:2 I:1`
3. Verification tests for main repo and worktree environments

### Why (Context)

**Current Problem**:
- Status line shows `📋 P:4` in main repository (correct)
- Status line shows `📋 P:0` in worktree (incorrect - should show main repo's pending count)
- No visibility into in-progress plans
- When executing plans in worktrees, pending count doesn't decrease in status line
- User loses visibility into plan execution state when working in worktrees

**Business Value**:
- **User impact**: Better visibility into plan execution state across all environments
- **Technical impact**: Correct plan tracking prevents confusion about plan state
- **Workflow impact**: Supports parallel worktree execution workflow (3-4 concurrent plans)

**Background**:
- Current development workflow: Create 3-4 plans, execute them concurrently using `--worktree` option
- Worktrees have isolated `.pilot/` directories but share Git history
- Plan state is managed in main repository's `.pilot/plan/` directory
- Status line script doesn't account for worktree environment

### How (Approach)

**Implementation Strategy**:

1. **Source worktree utilities** - Import existing `worktree-utils.sh` functions
2. **Detect worktree environment** - Use `is_in_worktree()` function
3. **Get correct pilot directory** - Use `get_main_pilot_dir()` if in worktree
4. **Count both pending and in-progress plans** - Read from correct directory
5. **Display both counts** - Format as `📋 P:{n} I:{m}`

**Dependencies**:
- Existing `.claude/scripts/worktree-utils.sh` (provides `is_in_worktree()` and `get_main_pilot_dir()`)
- Current plan state management system (pending/in_progress/done directories)
- Existing `.claude/settings.json` status line configuration

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking status line in non-worktree environments | Low | High | Add fallback to current behavior if worktree utils fail |
| Performance degradation from directory checks | Low | Medium | Cache worktree detection result, use efficient `find` commands |
| In-progress count includes active plan (double counting) | Medium | Low | Clarify semantics: I = all in_progress/, A = active/ plan (future enhancement) |
| Worktree utils not sourced correctly | Low | High | Test sourcing with both absolute and relative paths |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: Status line shows correct pending count in main repository
  - Verify: Run in main repo with 2+ pending plans
  - Expected: `📋 P:2 I:0` (or correct counts)

- [ ] **SC-2**: Status line shows correct pending count in worktree
  - Verify: Create worktree, run status line with 2+ pending plans in main repo
  - Expected: `📋 P:2 I:0` (same as main repo)

- [ ] **SC-3**: Status line shows in-progress count
  - Verify: Execute a plan (moves to in_progress/)
  - Expected: `📋 P:1 I:1` (one pending, one in-progress)

- [ ] **SC-4**: Status line works in worktree during execution
  - Verify: Execute plan with `--worktree`, check status line in worktree
  - Expected: Shows main repo's plan counts correctly

- [ ] **SC-5**: No regression in non-worktree environments
  - Verify: Test status line in project without worktrees
  - Expected: Status line works as before (with added in-progress count)

**Verification Method**:
- Manual testing in main repository
- Manual testing in worktree
- Manual testing during plan execution
- Visual verification of status line display

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Main repository status line | Main repo with 3 pending plans | `📋 P:3 I:0` | Manual | `tests/integration/statusline_test.sh::test_main_repo_pending` |
| TS-2 | Worktree status line (pending) | Worktree with 3 pending plans in main | `📋 P:3 I:0` | Manual | `tests/integration/statusline_test.sh::test_worktree_pending` |
| TS-3 | Main repository status line (in-progress) | Main repo with 1 pending, 1 in-progress | `📋 P:1 I:1` | Manual | `tests/integration/statusline_test.sh::test_main_repo_in_progress` |
| TS-4 | Worktree status line (in-progress) | Worktree with 1 pending, 1 in-progress | `📋 P:1 I:1` | Manual | `tests/integration/statusline_test.sh::test_worktree_in_progress` |
| TS-5 | Worktree detection fallback | Corrupted worktree utils | Falls back to local directory | Manual | `tests/integration/statusline_test.sh::test_fallback_behavior` |
| TS-6 | Empty plan directories | No pending or in-progress plans | `📋 P:0 I:0` | Manual | `tests/integration/statusline_test.sh::test_empty_directories` |

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Shell scripts (bash)
- **Test Framework**: Manual testing with custom bash assertions
- **Test Command**: `bash tests/integration/statusline_test.sh`
- **Test Directory**: `tests/integration/`
- **Coverage Target**: N/A (manual testing for shell scripts)

**Test Framework Details**:
- Custom bash assertion functions: `assert_eq()`, `assert_match()`, `assert_contains()`
- Test helpers: `create_test_plan()`, `cleanup_test_plans()`, `setup_worktree()`, `teardown_worktree()`
- Manual verification with visual inspection of status line output

---

## Execution Context (Planner Handoff)

### Explored Files
The following files were explored during `/00_plan` to understand the current implementation:

1. **`.claude/scripts/statusline.sh`** (lines 30-36)
   - Current pending count implementation
   - Counts from `${cwd}/.pilot/plan/pending/` directory
   - Issue: Doesn't account for worktree environment

2. **`.claude/scripts/worktree-utils.sh`**
   - `is_in_worktree()` (lines 129-143): Detects if current directory is a Git worktree
   - `get_main_pilot_dir()` (lines 309-315): Returns absolute path to main project's `.pilot` directory
   - `get_main_project_dir()` (lines 301-307): Returns the main project directory from within a worktree

3. **`.claude/commands/02_execute.md`** (lines 47-61)
   - Plan state transition logic (pending → in_progress)
   - Shows how plans are moved between directories

### Implementation Patterns (FROM CONVERSATION)

#### Current Status Line Logic
> **FROM CONVERSATION** (Explorer agent findings):
> ```bash
> # Current implementation (INCORRECT for worktrees)
> pending_dir="${cwd}/.pilot/plan/pending/"
> if [ -d "$pending_dir" ]; then
>     pending=$(find "$pending_dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ') || pending=0
> else
>     pending=0
> fi
> ```

#### Worktree-Aware Fix Pattern
> **FROM CONVERSATION** (Exploration summary):
> ```bash
> # Pseudo-fix for worktree-aware status line
> # Source worktree utilities
> WORKTREE_UTILS="${cwd}/.claude/scripts/worktree-utils.sh"
> [ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS"
>
> # Detect if in worktree and get correct pending directory
> if is_in_worktree 2>/dev/null; then
>     pending_dir="$(get_main_pilot_dir 2>/dev/null)/plan/pending/"
>     in_progress_dir="$(get_main_pilot_dir 2>/dev/null)/plan/in_progress/"
> else
>     pending_dir="${cwd}/.pilot/plan/pending/"
>     in_progress_dir="${cwd}/.pilot/plan/in_progress/"
> fi
> ```

#### Display Format
> **FROM CONVERSATION** (User requirements):
> - Current: `📋 P:{n}` (only pending count)
> - Target: `📋 P:{n} I:{m}` (pending + in-progress counts)

### Key Decisions Made
1. **Reuse existing utilities**: Use `worktree-utils.sh` functions instead of reimplementing worktree detection
2. **Graceful fallback**: If worktree utils fail to source, fall back to current behavior (local directory)
3. **Dual counts**: Show both pending (P) and in-progress (I) for complete visibility
4. **No state changes**: Only read plan counts, don't modify plan state management

### Assumptions to Validate
- `worktree-utils.sh` is available at the expected path
- Functions `is_in_worktree()` and `get_main_pilot_dir()` work correctly
- Status line script has read access to main repository's `.pilot/plan/` directory

---

## Execution Plan

### Phase 1: Discovery
- [ ] Read current `statusline.sh` implementation
- [ ] Read `worktree-utils.sh` to understand available functions
- [ ] Create test environment directory: `mkdir -p tests/integration/`
- [ ] Create test worktree for testing: `git worktree add .pilot/worktrees/test-worktree --detach 2>/dev/null || echo "Using existing worktree for testing"`
- [ ] Verify current behavior with manual tests (document baseline)

### Phase 2: Implementation (TDD Cycle)

**For each Success Criterion**:

#### Red Phase: Write Failing Test
1. Create test script structure `tests/integration/statusline_test.sh`:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   # Custom assertion functions
   assert_eq() { [ "$1" = "$2" ] || { echo "FAIL: Expected '$2', got '$1'"; return 1; }; }
   assert_match() { [[ "$1" =~ $2 ]] || { echo "FAIL: '$1' doesn't match '$2'"; return 1; }; }
   assert_contains() { [[ "$1" == *"$2"* ]] || { echo "FAIL: '$1' doesn't contain '$2'"; return 1; }; }

   # Test helpers
   create_test_plan() { echo "# Test plan" > "$1"; }
   cleanup_test_plans() { rm -f .pilot/plan/pending/test_*.md .pilot/plan/in_progress/test_*.md 2>/dev/null; }

   # Test cases
   test_main_repo_pending() { ... }
   test_worktree_pending() { ... }
   # ... (TS-1 through TS-6)
   ```
2. Implement test cases for TS-1 through TS-6 with:
   - **Setup**: Create test plan files in `.pilot/plan/pending/` and `.pilot/plan/in_progress/`
   - **Execute**: Source statusline.sh and capture output with JSON input
   - **Assert**: Verify output matches expected format `📋 P:{n} I:{m}`
   - **Teardown**: Remove test plan files
3. Make test executable: `chmod +x tests/integration/statusline_test.sh`
4. Run tests → confirm RED (failing - current implementation doesn't support worktrees)

#### Green Phase: Minimal Implementation
1. Modify `.claude/scripts/statusline.sh`:
   - Source worktree-utils.sh: `. "${cwd}/.claude/scripts/worktree-utils.sh"`
   - Detect worktree environment: `if is_in_worktree 2>/dev/null; then`
   - Get correct pilot directory: `pilot_dir="$(get_main_pilot_dir 2>/dev/null || echo "${cwd}/.pilot")"`
   - Count pending plans from correct directory: `pending_dir="${pilot_dir}/plan/pending/"`
   - Count in-progress plans from correct directory: `in_progress_dir="${pilot_dir}/plan/in_progress/"`
   - Update display format to show both counts: `status="📋 P:${pending} I:${in_progress}"`
2. Run tests → confirm GREEN (passing)

#### Refactor Phase: Clean Up
1. Add error handling for missing worktree-utils.sh
2. Add fallback behavior if worktree detection fails
3. Optimize directory counting (avoid duplicate scans)
4. Add comments explaining worktree-aware logic
5. Run ALL tests → confirm still GREEN

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: Immediately after first code change

**Loop until**:
- [ ] All tests pass (TS-1 through TS-6)
- [ ] Manual verification in main repo successful
- [ ] Manual verification in worktree successful
- [ ] Manual verification during plan execution successful

**Max iterations**: 7

### Phase 4: Verification

**Manual verification**:
- [ ] Test in main repository with various plan states
- [ ] Test in worktree with various plan states
- [ ] Test during actual plan execution
- [ ] Verify no regression in non-worktree projects
- [ ] Verify display format is clean and readable

---

## Constraints

### Technical Constraints
- Must use bash-compatible syntax (POSIX-compliant where possible)
- Must work with existing Claude Code status line JSON input format
- Must not break existing status line functionality
- Must handle edge cases (missing directories, corrupted worktree utils)

### Business Constraints
- Must maintain backward compatibility
- Must not require changes to other commands
- Must work immediately upon deployment (no migration needed)

### Quality Constraints
- **Code Quality**: Shell scripts should be readable and well-commented
- **Error Handling**: Graceful degradation if worktree utils fail
- **Performance**: Status line should execute quickly (< 100ms)
- **Standards**: Follow existing shell script patterns in the codebase

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-18 | Claude (planning) | Initial plan created | Pending Review |
| 2026-01-18 | Plan-Reviewer Agent | 1 BLOCKING (test file creation), 2 Warnings (test framework, worktree setup) | Fixed |
| 2026-01-18 | Claude (confirm) | Updated plan with test file structure, test framework details, worktree setup | Ready for Execution |

---

## Completion Checklist

**Before marking plan complete**:

- [ ] All SCs marked complete
- [ ] All manual tests pass (TS-1 through TS-6)
- [ ] Status line shows correct counts in main repo
- [ ] Status line shows correct counts in worktree
- [ ] No regression in non-worktree environments
- [ ] Code is well-commented and maintainable
- [ ] Plan archived to `.pilot/plan/done/`

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Worktree Setup**: @.claude/guides/worktree-setup.md
- **Worktree Utilities**: @.claude/scripts/worktree-utils.sh
- **Current Status Line**: @.claude/scripts/statusline.sh

---

**Template Version**: claude-pilot 4.1.2
**Last Updated**: 2026-01-18
