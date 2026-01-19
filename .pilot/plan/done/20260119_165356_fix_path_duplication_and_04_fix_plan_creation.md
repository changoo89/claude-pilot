# Fix Path Duplication and /04_fix Plan Creation

> **Generated**: 2026-01-19 16:53:56 | **Work**: fix_path_duplication_and_04_fix_plan_creation | **Location**: /Users/chanho/claude-pilot/.pilot/plan/draft/20260119_165356_fix_path_duplication_and_04_fix_plan_creation.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 13:47 | "우리 모든 계획 파일은 상위폴더의 .pilot/plan 이하에 진행이 되어야 하는데 지금 이상한 .claude-pilot 이라는 경로가 하나 더 추가가 된 것 같은데 수정해주고" | Fix incorrect path duplication (.claude-pilot/.claude-pilot/.pilot should be .pilot) |
| UR-2 | 13:47 | "03_fix 커맨드는 진행 과정에서 plan 문서를 만들지 않고 쭉 진행을 하는 형태가 되어야 하는데 간헐적으로 plan 문서를 만들던데 그러지 않도록 해줘" | Fix /04_fix to not create plan documents during execution |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | Mapped |
| UR-2 | ✅ | SC-5 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix two critical bugs in claude-pilot:
1. Path duplication bug (`.claude-pilot/.claude-pilot/.pilot` → `.pilot`)
2. `/04_fix` command creating unwanted plan documents

**Scope**:
- **In Scope**:
  - Fix all path references in command files (10 commands)
  - Fix all path references in skill files (16+ files)
  - Fix all path references in hook scripts (4 files)
  - Fix `/04_fix` workflow to skip plan document creation
  - Update continuation system paths
- **Out of Scope**:
  - Changing directory structure (keep `.pilot/` at root)
  - Modifying plan file format
  - Changing other commands' behavior

**Deliverables**:
1. Corrected path references across all files
2. `/04_fix` command that executes without creating plan files
3. Updated tests to reflect correct paths

### Why (Context)

**Current Problem**:
- **Path Duplication**: 192 occurrences of `.claude-pilot/.pilot` or `.claude-pilot/.claude-pilot/.pilot` causing plan detection failures
- **Plan Creation in /04_fix**: Rapid fix workflow creates plan documents when it should execute directly

**Business Value**:
- **User Impact**: Plan files created in wrong location, commands can't find existing plans
- **Technical Impact**: Continuation system failures, broken workflow automation
- **Workflow Impact**: `/04_fix` should be truly "rapid" without intermediate plan files

### How (Approach)

**Implementation Strategy**:
1. **Phase 1**: Fix path references in all command files (systematic find & replace)
2. **Phase 2**: Fix `/04_fix` to skip plan document creation
3. **Phase 3**: Fix path references in skill files and agents
4. **Phase 4**: Fix hook scripts and test files
5. **Phase 5**: Verification and testing

**Dependencies**:
- None (self-contained fix)

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing workflows | Medium | High | Comprehensive testing of all commands |
| Missed path references | Medium | Medium | Use grep to verify all occurrences fixed |
| /04_fix breaks rapid workflow | Low | High | Keep auto-generate internal, skip file creation |

### Success Criteria

- [ ] **SC-1**: All command files use correct `.pilot/plan/` path
  - Verify: `grep -r "\.claude-pilot/\.pilot" .claude/commands/ 2>/dev/null | wc -l` returns 0
- [ ] **SC-2**: `/04_fix` executes without creating plan documents
  - Verify: Run `/04_fix "echo test"` → `ls .pilot/plan/pending/` → No new files created
- [ ] **SC-3**: All skill files use correct path
  - Verify: `grep -r "\.claude-pilot/\.pilot" .claude/skills/ 2>/dev/null | wc -l` returns 0
- [ ] **SC-4**: All agents use correct path
  - Verify: `grep -r "\.claude-pilot/\.pilot" .claude/agents/ 2>/dev/null | wc -l` returns 0
- [ ] **SC-5**: All hook scripts use correct path
  - Verify: `grep -r "\.claude-pilot/\.pilot" .claude/scripts/hooks/ 2>/dev/null | wc -l` returns 0
- [ ] **SC-6**: Continuation system uses correct `.pilot/state/` path
  - Verify: `grep "\.claude-pilot/\.pilot/state" .pilot/scripts/state_read.sh 2>/dev/null | wc -l` returns 0
- [ ] **SC-7**: Zero occurrences of `.claude-pilot/.pilot` remain (verified via grep)
  - Verify: `grep -r "\.claude-pilot/\.pilot" .claude/ 2>/dev/null | wc -l` returns 0

### Constraints

**Technical Constraints**:
- Must preserve existing functionality
- Must not break backward compatibility
- Bash script compatibility (macOS/Linux)

**Quality Constraints**:
- All path references must be consistent
- No hardcoded paths that break on different installations

---

## Scope

### In Scope
- Command files: 00_plan.md, 01_confirm.md, 02_execute.md, 03_close.md, 04_fix.md, 90_review.md, 91_document.md, setup.md
- Skill files: All 16+ skill files with incorrect path references
- Agent files: coder.md, tester.md, validator.md, documenter.md
- Hook scripts: check-todos.sh, worktree-utils.sh, and others
- Continuation system paths

### Out of Scope
- Changing `.pilot/` directory structure
- Modifying plan file format
- Changing other commands' behavior beyond path fixes

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| N/A | N/A | Bash scripts in `.pilot/tests/` | N/A |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Plan execution command | Multiple occurrences of `.claude-pilot/.claude-pilot/.pilot` | Needs path fix |
| `.claude/commands/04_fix.md` | Rapid bug fix command | Lines 82, 83, 88, 91, 156, 226, 227, 231 | Creates plan docs - needs fix |
| `.claude/skills/confirm-plan/SKILL.md` | Plan confirmation skill | Line 28: `.claude-pilot/.pilot/plan/pending/` | Wrong path |
| `.claude/skills/confirm-plan/REFERENCE.md` | Detailed reference | Lines 347, 357: `.claude-pilot/.pilot/plan/` | Wrong path |
| `.claude/agents/coder.md` | Implementation agent | Path references | Needs review |
| `.claude/agents/tester.md` | Test execution agent | Path references | Needs review |
| `.claude/agents/validator.md` | Quality verification agent | Path references | Needs review |
| `.claude/agents/documenter.md` | Documentation agent | Path references | Needs review |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Use `.pilot/` at project root | Correct structure per user requirement | Keep `.claude-pilot/.pilot/` (rejected - user wants `.pilot/`) |
| Skip plan doc creation in /04_fix | Rapid workflow should be all-in-one | Create plan but in temp location (rejected - user wants no plan file) |
| Systematic find & replace across all files | 192 occurrences need fixing | Manual fix per file (too time-consuming) |

### Implementation Patterns (FROM CONVERSATION)

> No implementation highlights found in conversation

### Assumptions
- `.pilot/` directory should be at project root level
- `/04_fix` should use internal plan generation but not create files
- All path references must be consistent across codebase

### Dependencies
- None

---

## Architecture

### System Design

The fix involves two main components:
1. **Path Correction**: Replace all `.claude-pilot/.pilot` with `.pilot/` across 40+ files
2. **Workflow Modification**: Modify `/04_fix` to skip plan file creation while keeping internal auto-generation

### Components

| Component | Purpose | Integration |
|-----------|---------|-------------|
| Path fix script | Batch replace incorrect paths | Runs across all file types |
| /04_fix modification | Remove plan file creation step | Keeps internal auto-gen for execution |

### Data Flow

```
User runs /04_fix
      ↓
Auto-generate minimal plan (internal only, no file)
      ↓
Execute via /02_execute
      ↓
User confirmation
      ↓
Auto-close with commit
```

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Break down replacement scripts if needed |
| File | ≤200 lines | Target individual files per change |
| Nesting | ≤3 levels | Use simple find & replace patterns |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

0. **Phase 0**: Baseline Validation (validator, 2 min)
   - Count current occurrences: `grep -r "\.claude-pilot/\.pilot" .claude/ | wc -l`
   - Create backup commit: `git commit -am "backup before path fix"`
   - Document baseline state
1. **Phase 1**: Fix path in command files (coder, 50 min) - 8 files
2. **Phase 2**: Fix /04_fix to skip plan doc creation (coder, 15 min)
3. **Phase 3**: Fix path in skill files (coder, 15 min) - 16 files
4. **Phase 4**: Fix path in agent files (coder, 10 min) - 4 files
5. **Phase 5**: Fix path in hook scripts (coder, 5 min) - 4 files
6. **Phase 6**: Verification (validator, 2 min) - grep check

---

## Acceptance Criteria

- [ ] **AC-1**: All commands reference `.pilot/plan/` correctly
- [ ] **AC-2**: `/04_fix` runs without creating plan files
- [ ] **AC-3**: Zero `.claude-pilot/.pilot` occurrences in codebase
- [ ] **AC-4**: All existing tests pass with new paths
- [ ] **AC-5**: Continuation system works with correct paths

---

## Test Plan

| ID | Scenario | Expected | Type | Test File |
|----|----------|----------|------|-----------|
| TS-1 | Path correctness in commands | grep -r "\.claude-pilot/\.pilot" | No matches | Integration | `.pilot/tests/test_path_fix.sh` |
| TS-2 | /04_fix creates no plan | Run `/04_fix "simple fix"` | No file in `.pilot/plan/` | Integration | `.pilot/tests/test_04_fix_no_plan.sh` |
| TS-3 | Plan detection works | Create plan → Run `/02_execute` | Plan found in `.pilot/plan/pending/` | Integration | `.pilot/tests/test_plan_detection.sh` |
| TS-4 | Continuation state path | Run `/02_execute` | State in `.pilot/state/` | Integration | `.pilot/tests/test_continuation_path.sh` |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking existing workflows | High | Medium | Comprehensive testing of all commands |
| Missed path references | Medium | Medium | Use grep to verify all occurrences fixed |
| /04_fix breaks rapid workflow | High | Low | Keep auto-generate internal, skip file creation |
| Test file path updates | Low | Low | Update test files to use correct paths |

**Rollback Strategy**:
- Pre-execution backup: `git commit -am "backup before path fix"`
- If issues occur: `git reset --hard HEAD~1` (after backup commit)
- Document rollback steps in Risk & Mitigations section

---

## Open Questions

| Question | Priority | Status | Resolution |
|----------|----------|--------|------------|
| Should we update existing plan files in `.claude-pilot/.pilot/` to `.pilot/`? | Medium | Open | Decision: NOT in scope (preserve existing plans, only fix new paths) |
| Should continuation state file path also be changed? | Medium | Open | Decision: YES (SC-6 covers continuation system path fix) |

---

## Review History

### 2026-01-19 16:53:56 - Initial Plan Creation

**Summary**: Plan created from /00_plan conversation

**Findings**:
- BLOCKING: 0
- Critical: 0
- Warning: 0
- Suggestion: 0

**Changes Made**: Initial plan creation

**Updated Sections**: All sections

---

### 2026-01-19 16:54:00 - Auto-Review with Auto-Apply

**Summary**: Plan reviewed and improvements auto-applied

**Findings**:
- BLOCKING: 0
- Critical: 2 (auto-applied)
- Warning: 3 (auto-applied)
- Suggestion: 1 (noted)

**Critical Issues Fixed**:
1. Added verification commands to all Success Criteria (SC-1 through SC-7)
   - Each SC now has explicit `Verify:` command with grep/test

2. Test Plan: Confirmed test files need to be created
   - Test files are placeholders - will be created during execution
   - Added note that test file creation is part of execution phases

**Warnings Addressed**:
1. Open questions resolved with decisions documented
2. Rollback strategy added to Risk & Mitigations
3. Phase 0 (Baseline Validation) added to Execution Plan

**Changes Made**:
- Updated Success Criteria with verification commands
- Added Phase 0 to Execution Plan
- Enhanced Risk & Mitigations with rollback strategy
- Resolved Open Questions with explicit decisions

**Updated Sections**: Success Criteria, Execution Plan, Risks & Mitigations, Open Questions

**Verdict**: ✅ APPROVED - Plan is ready for execution

---
