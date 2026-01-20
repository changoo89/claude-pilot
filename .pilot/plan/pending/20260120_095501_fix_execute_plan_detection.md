# Fix 02_execute Plan Detection Bug

> **Generated**: 2026-01-20 09:55:01 | **Work**: fix_execute_plan_detection | **Location**: .pilot/plan/draft/20260120_095501_fix_execute_plan_detection.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 09:17 | "몇번 수정했는데 여전히 02_excute 를 하면 pending 중인 계획이 있음에도 불구하고 계획을 찾을 수 없다고 할 때가 있는데 한번 확인해줘." | Fix 02_execute plan detection bug - pending plans not found despite existing |
| UR-2 | 09:17 | "클로드코드 공식 가이드문서 웹에서 찾아보고 제작해줘." | Research Claude Code official documentation for solution |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| UR-2 | ✅ | SC-4 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix the `/02_execute` command's plan detection logic to reliably find pending plans using robust file system detection methods based on Claude Code official best practices.

**Scope**:
- **In Scope**:
  - `.claude/commands/02_execute.md` Plan Detection section modification
  - File system detection logic reinforcement
  - Error message improvement (with debugging information)
  - Multi-method fallback detection system

- **Out of Scope**:
  - Complete plan state management system redesign
  - Worktree mode logic modifications

**Deliverables**:
1. Modified `02_execute.md` with robust plan detection
2. Test cases for plan detection scenarios
3. Updated error messages with debugging info

### Why (Context)

**Current Problem**:
- `/02_execute` returns "No plan found" error even when plan files exist in `pending/` directory
- `find` + `xargs` pipeline fails silently in certain conditions
- No debugging information to diagnose the root cause
- Users cannot execute plans immediately after creation

**Root Cause Analysis**:
The current detection logic at line 128 of `02_execute.md`:
```bash
find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1
```

**Issues Identified**:
1. `find` returns empty output when files exist (file system cache issue)
2. `xargs` executes nothing when input is empty
3. Pipeline complexity increases failure points
4. No fallback mechanism for failed detection

**Business Value**:
- **User Impact**: Plan execution workflow becomes reliable
- **Technical Impact**: File system detection best practices applied from Claude Code official patterns

### How (Approach)

**Implementation Strategy**:
1. **Defensive Programming**: Replace `find` + `xargs` pipeline with direct bash globbing
2. **Fallback Logic**: Implement 3-tier detection method (glob → find → ls)
3. **Verbose Mode**: Add debugging information output option
4. **Sync Safety**: Add file system synchronization check (`sync` command or pre-read)

**Dependencies**:
- Claude Code official documentation for file system patterns
- Existing `02_execute.md` command structure
- Bash shell built-in commands

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| glob expansion change breaks existing behavior | Low | Medium | Keep existing `find` logic as fallback |
| File system sync overhead | Low | Low | `ls` uses cached results, minimal overhead |
| Edge case handling gaps | Medium | Medium | 3 detection methods maximize coverage |

### Success Criteria

**Measurable, testable outcomes**:

- [ ] **SC-1**: Plan detection works with 100% reliability when files exist in pending/
  - **Target File**: `.claude/commands/02_execute.md`
  - **Target Lines**: 123-139 (Plan Detection section)
  - **Verify**: Create file in pending/, run /02_execute 10 times
  - **Expected**: 100% success rate, 0% false negative

- [ ] **SC-2**: File system synchronization safety mechanism added
  - **Target File**: `.claude/commands/02_execute.md`
  - **Target Lines**: 123-139 (Plan Detection section)
  - **Verify**: `sync` or `ls` pre-read included in detection logic
  - **Expected**: Detection succeeds immediately after file creation

- [ ] **SC-3**: Debugging information improved
  - **Target File**: `.claude/commands/02_execute.md`
  - **Target Lines**: 123-139 (error message section)
  - **Verify**: Failure messages show which step failed and file count
  - **Expected**: "No plan found in pending/ (found X files)" format

- [ ] **SC-4**: Fallback logic implemented using Claude Code official patterns
  - **Target File**: `.claude/commands/02_execute.md`
  - **Target Lines**: 123-139 (detection methods)
  - **Verify**: 3 detection methods tried in sequence (glob, find, ls)
  - **Expected**: At least one method succeeds when files exist

### Constraints

- **Technical**: Bash script only, no external dependencies beyond standard Unix tools
- **Patterns**: Must work with Claude Code's "file system is your long term state management" principle
- **Timeline**: None specified (bug fix)

---

## Scope

### In Scope
- Plan detection logic fix in `02_execute.md`
- Multi-method fallback detection system
- Error message improvement with debugging info
- Test coverage for detection scenarios

### Out of Scope
- Plan state management system redesign
- Worktree mode modifications
- Other command changes

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| Shell Script | Bash | `bash .pilot/tests/execute/test_*.sh` | N/A |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Current plan detection logic | 86-146 | Step 1: Plan Detection section |
| `.pilot/plan/in_progress/20260120_091719_claude_pilot_meta_skill.md` | Example existing plan | All | Plan that was moved from pending to in_progress |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Use multi-method detection (glob → find → ls) | Maximum reliability across different scenarios | Single robust method |
| Add file count to error messages | Better debugging for users | Generic error only |
| Keep existing logic as fallback | Backward compatibility | Complete replacement |

### Implementation Patterns (FROM CONVERSATION)

#### Current Problematic Code
> **FROM CURRENT CODE (.claude/commands/02_execute.md:128)**:
> ```bash
> [ -z "$PLAN_PATH" ] && PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1)"
> ```

#### Proposed Fix Pattern
> **PROPOSED FIX**:
> ```bash
> # Step 1: File system cache flush (sync safety)
> ls "$PLAN_SEARCH_ROOT/.pilot/plan/pending" >/dev/null 2>&1 || true
>
> # Step 2: Method 1 - Direct globbing (most reliable)
> PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | head -1)"
>
> # Step 3: Method 2 - find only (no xargs)
> [ -z "$PLAN_PATH" ] && PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -1)"
>
> # Step 4: Method 3 - ls direct (last resort)
> [ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1tr "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"
>
> # Step 5: Debugging information
> if [ -z "$PLAN_PATH" ]; then
>     COUNT=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
>     echo "❌ No plan found in pending/ (found $COUNT files)" >&2
>     exit 1
> fi
> ```

### Assumptions
- Claude Code official docs are authoritative for file system patterns
- Existing plan detection issue is caused by `find` + `xargs` pipeline complexity
- File system cache issues cause intermittent detection failures

### Dependencies
- Claude Code official documentation for file system state management
- Existing `02_execute.md` structure and workflow

---

## Architecture

### System Design

The fix implements a **3-tier fallback detection system**:

1. **Tier 1 (Primary)**: Direct bash globbing with file existence check
2. **Tier 2 (Fallback)**: `find` command only (no `xargs`)
3. **Tier 3 (Last Resort)**: `ls` command direct listing

Each tier is tried in sequence until a plan is found or all methods fail.

### Components

| Component | Purpose | Integration |
|-----------|---------|-------------|
| File system sync | Cache flush before detection | Runs before all detection methods |
| Multi-method detector | 3-tier fallback system | Sequential execution with early exit |
| Debugging logger | Enhanced error messages | Shows file count when detection fails |

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Extract detection logic into separate function if needed |
| File | ≤200 lines | Modify only Step 1 section of 02_execute.md |
| Nesting | ≤3 levels | Use early return for each detection method |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Phase 1: Modify Plan Detection Logic
- [ ] Backup current 02_execute.md: `cp .claude/commands/02_execute.md .claude/commands/02_execute.md.bak`
- [ ] Replace Step 1 Plan Detection section in 02_execute.md (lines 123-139)
- [ ] Implement 3-tier fallback detection system
- [ ] Add file system sync safety check
- [ ] Verify backup exists: `test -f .claude/commands/02_execute.md.bak`

### Phase 2: Enhanced Error Messages
- [ ] Add debugging information to error output
- [ ] Include file count in failure messages

### Phase 3: Testing & Verification
- [ ] Verify test directory exists: `mkdir -p .pilot/tests/execute`
- [ ] Test with empty pending/ directory
- [ ] Test with single pending plan
- [ ] Test with multiple pending plans
- [ ] Test immediate execution after plan creation

---

## Acceptance Criteria

- [ ] **AC-1**: Plan detection succeeds 100% of time when file exists
  - **Test**: Create 10 plans in pending/, run /02_execute each time
  - **Expected**: 10/10 success rate

- [ ] **AC-2**: Error message shows file count on failure
  - **Test**: Empty pending/ directory, run /02_execute
  - **Expected**: "No plan found in pending/ (found 0 files)"

- [ ] **AC-3**: Oldest plan selected when multiple exist
  - **Test**: Create 3 plans with timestamps, run /02_execute
  - **Expected**: Oldest plan moved to in_progress/

- [ ] **AC-4**: Fallback methods work when primary fails
  - **Test**: Simulate glob failure, verify find method works
  - **Expected**: Detection succeeds with fallback method

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Plan exists in pending/ | Create file in pending/, run /02_execute | Plan found and moved to in_progress/ | Integration | `.pilot/tests/execute/test_plan_detection.sh` |
| TS-2 | Empty pending directory | No files in pending/ | "No plan found" error with file count (0) | Unit | `.pilot/tests/execute/test_empty_pending.sh` |
| TS-3 | Multiple pending plans | 3 files in pending/ with different timestamps | Oldest plan selected | Integration | `.pilot/tests/execute/test_multiple_plans.sh` |
| TS-4 | File system sync edge case | Create plan, immediately run /02_execute | Plan detected reliably | Integration | `.pilot/tests/execute/test_sync_edge_case.sh` |
| TS-5 | In-progress plan exists | File in in_progress/, no pending | In-progress plan selected | Integration | `.pilot/tests/execute/test_in_progress_selection.sh` |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| glob expansion behavior change | Medium | Low | Keep existing `find` logic as fallback |
| File system sync overhead | Low | Low | `ls` pre-read is cached, minimal cost |
| Edge case handling gaps | Medium | Medium | 3 detection methods provide redundancy |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| None identified | - | - |

---

## Sources

**Claude Code Official Documentation**:
- [Claude Code overview - Claude Code Docs](https://code.claude.com/docs/en/overview) - File system as state management principle
- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices) - Official patterns

**claude-pilot Codebase**:
- `.claude/commands/02_execute.md` - Current plan detection logic (lines 86-146)
- `.claude/skills/vibe-coding/SKILL.md` - Code quality standards

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-20 09:55:01
