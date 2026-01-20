# Documentation Cleanup Exclusions for Plugin Core Files

> **Generated**: 2026-01-20 15:42:27 | **Work**: docs_cleanup_exclusions | **Location**: .pilot/plan/draft/20260120_154227_docs_cleanup_exclusions.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 2026-01-20 | "@.claude/commands/05_cleanup.md 가 문서도 제거하게 되어있는데 문서 제거에서 우리 플러그인에 기본적으로 제공되는 것들은 제외하고 검색해줘." | Exclude plugin-provided docs from cleanup detection |
| UR-2 | 2026-01-20 | ".pilot 에서 draft pending in_progress done 부분에서 '정상적으로 보이는' (backup 이나 temp 가 아닌) 것들은 남겨두게 해주고." | Protect legitimate .pilot state directory files |
| UR-3 | 2026-01-20 | "순수하게 LLM 이 작업하다가 진짜 임시로 생성한 것 같은 문서들 위주로 체크하게 해줘" | Target only truly temporary LLM-generated files |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| UR-3 | ✅ | SC-4, SC-5, SC-6 | Mapped |
| **Coverage** | **100%** | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Modify `/05_cleanup` command documentation detection (Tier 3) to exclude plugin-provided docs and protect legitimate state files while targeting only truly temporary LLM-generated files.

**Scope**:
- **In Scope**:
  - Tier 3 (Documentation) detection logic in `05_cleanup.md`
  - `check_doc_references()` function
  - Documentation file exclusion glob patterns
  - `.pilot/` directory protection patterns

- **Out of Scope**:
  - Tier 1 (Unused imports) - no changes
  - Tier 2 (Dead code files) - no changes
  - Risk classification logic - no changes
  - Apply/verify/rollback flow - no changes

**Deliverables**:
1. Updated `check_doc_references()` function with plugin-aware detection
2. Enhanced exclusion glob patterns for plugin docs
3. New protection patterns for `.pilot/` state directories
4. Updated documentation in `05_cleanup.md`

### Why (Context)

**Current Problem**:
- 218 plugin-provided markdown files exist in `.claude/`
- Many core files (e.g., `CONTEXT.md`) have zero `@` references but are essential
- Legitimate `.pilot/plan/done/` files could be deleted as "unreferenced"
- LLM generates truly temporary files that should be cleaned up (e.g., `.claude/generated/`, temp analysis files)

**Business Value**:
- **User impact**: Prevent accidental deletion of plugin documentation
- **Technical impact**: Maintain plugin integrity while allowing real cleanup
- **Safety impact**: Protect legitimate state files from being removed

**Background**:
- The `@` reference system works for cross-references but plugin core files don't need references
- `.pilot/` directory structure is part of the continuation system (Sisyphus)
- `05_cleanup` command was recently enhanced with auto-apply workflow (v4.3.1)

### How (Approach)

**Implementation Strategy**:

1. **Plugin-Provided Docs Protection**: Add explicit glob patterns to exclude `.claude/` plugin documentation
2. **Directory-Based Detection**: Instead of just `@` references, also check if file is in known plugin directories
3. **.pilot State Protection**: Exclude `.pilot/plan/{draft,pending,in_progress,done}/` directories
4. **Target Temporary Files**: Focus cleanup on truly temp locations like `.claude/generated/`, backup files

**Dependencies**:
- Existing `05_cleanup.md` command structure
- ripgrep (rg) for pattern matching
- Glob pattern system for exclusions

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Over-exclusion hides real dead docs | Low | Medium | Make exclusions explicit and well-documented |
| .pilot temp files not cleaned | Low | Low | Allow specific temp subdirectories to be scanned |
| Pattern changes break existing workflow | Medium | High | Comprehensive test coverage |

### Success Criteria

- [x] **SC-1**: Plugin `.claude/` directory excluded from docs cleanup ✅
  - Verify: `.claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep -v '\.claude/' | grep -q 'No @references' || ! .claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep '\.claude/'`
  - Expected: Zero plugin documentation files in candidates table
  - **Result**: PASS - Plugin directories excluded via glob patterns

- [x] **SC-2**: `CONTEXT.md` files protected regardless of reference count ✅
  - Verify: `.claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep -v 'CONTEXT.md' | grep -q 'No @references' || ! .claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep 'CONTEXT.md'`
  - Expected: No `CONTEXT.md` in cleanup candidates
  - **Result**: PASS - CONTEXT.md files protected via glob patterns

- [x] **SC-3**: `.pilot/plan/` state directories protected ✅
  - Verify: `.claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep -v '.pilot/plan/' | grep -q 'No @references' || ! .claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep '.pilot/plan/.*\.md'`
  - Expected: Plan files in state directories not listed as candidates
  - **Result**: PASS - .pilot/plan/ directories excluded

- [x] **SC-4**: `.claude/generated/` files still cleanup targets ✅
  - Verify: `echo "test" > .claude/generated/test_unref.md && .claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep -q '.claude/generated/test_unref.md'; rm -f .claude/generated/test_unref.md`
  - Expected: `.claude/generated/` files with no references ARE candidates
  - **Result**: PASS - .claude/generated/ remains scannable

- [x] **SC-5**: Backup and temp patterns still work ✅
  - Verify: `echo "test" > test.md.bak && .claude/commands/05_cleanup mode=docs --dry-run 2>&1 | grep -v 'test.md.bak'; rm -f test.md.bak`
  - Expected: Backup patterns excluded from candidates
  - **Result**: PASS - Backup patterns still excluded

- [x] **SC-6**: Documentation updated correctly ✅
  - Verify: `grep -A 30 "### Tier 3" .claude/commands/05_cleanup.md | grep -q "\.claude/\*\*"`
  - Expected: Tier 3 section shows `.claude/` exclusion
  - **Result**: PASS - Line 284 shows all exclusions

- [x] **SC-7**: Test infrastructure created ✅
  - Verify: `test -f .pilot/tests/test-cleanup-docs.sh && test -x .pilot/tests/test-cleanup-docs.sh`
  - Expected: Test file exists and is executable
  - **Result**: PASS - Test file created and executable

### Constraints

- **Technical**: Must maintain backward compatibility with existing `05_cleanup` workflow
- **Patterns**: Must use ripgrep (rg) glob patterns for exclusions
- **Scope**: Cannot modify Tier 1 or Tier 2 detection logic

---

## Scope

### In Scope
- `.claude/commands/05_cleanup.md` - Tier 3 documentation detection
- `check_doc_references()` function
- Glob pattern exclusions for plugin docs
- `.pilot/plan/` state directory protection

### Out of Scope
- Tier 1 (unused imports) detection
- Tier 2 (dead files) detection
- Risk level classification
- Apply/verify/rollback workflow
- Other cleanup modes (imports, files)

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| Bash (Shell) | - | `bash .pilot/tests/test-cleanup-docs.sh` | - |

**Test Directory**: `.pilot/tests/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/05_cleanup.md` | Current cleanup command implementation | Lines 153-172: `check_doc_references()`, Lines 244-273: Tier 3 detection | Uses `@` reference counting via ripgrep |
| `.claude/commands/05_cleanup.md` | Documentation exclusion patterns | Line 248-253: Current glob exclusions | Excludes: `docs/**`, `README.md`, `CLAUDE.md`, `*.md.bak`, `.trash/**` |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Exclude entire `.claude/` from docs scan | All 218 plugin docs are essential, regardless of `@` references | Could track individual essential files, but over-engineering |
| Protect `.pilot/plan/` state dirs | These are part of Sisyphus continuation system | Could add timestamp-based logic, but state dirs are clearer |
| Keep `.claude/generated/` scannable | Truly temporary files should still be cleanable | Could exclude all generated, but defeats cleanup purpose |

### Implementation Patterns (FROM CONVERSATION)

> No implementation highlights found in conversation

### Assumptions
- Plugin documentation files (`.claude/**/*.md`) are always essential
- `.pilot/plan/` state directory files are part of the continuation system
- `.claude/generated/` contains temporary files that can be safely cleaned

### Dependencies
- ripgrep (rg) for glob pattern matching
- Existing `05_cleanup` command structure

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Keep `check_doc_references()` focused, add separate helper if needed |
| File | ≤200 lines | Focus changes on Tier 3 section only |
| Nesting | ≤3 levels | Use early returns for exclusion checks |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-0 | Create test directory and infrastructure | coder | 5 min | ✅ completed |
| SC-1 | Add `.claude/` glob exclusion to Tier 3 detection (line 248 in 05_cleanup.md) | coder | 10 min | ✅ completed |
| SC-2 | Add `CONTEXT.md` specific exclusion pattern | coder | 5 min | ✅ completed |
| SC-3 | Add `.pilot/plan/` state directory exclusions | coder | 10 min | ✅ completed |
| SC-4 | Verify `.claude/generated/` still scanned for cleanup | coder | 5 min | ✅ completed |
| SC-5 | Update documentation in Step 4 (Tier 3) section | coder | 10 min | ✅ completed |
| SC-6 | Write test for plugin exclusion | tester | 15 min | ✅ completed |
| SC-7 | Write test for .pilot protection | tester | 10 min | ✅ completed |
| SC-8 | Write test for generated file cleanup | tester | 10 min | ✅ completed |
| SC-9 | Run integration tests for cleanup command | validator | 5 min | ✅ completed |
| SC-10 | Verify documentation accuracy | validator | 5 min | ✅ completed |

**Granularity Verification**: ✅ All todos comply with 3 rules (≤15 min, single owner, atomic)
**Warnings**: None
**Completion Status**: All 11 todos completed successfully

---

## Acceptance Criteria

- [x] **AC-1**: Plugin `.claude/` documentation files excluded from cleanup ✅
- [x] **AC-2**: `.pilot/plan/` state directories protected from deletion ✅
- [x] **AC-3**: `.claude/generated/` temporary files still cleanable ✅
- [x] **AC-4**: Backup patterns (*.md.bak) remain excluded ✅
- [x] **AC-5**: Documentation accurately reflects new behavior ✅
- [x] **AC-6**: All tests pass (TS-1 through TS-5) ✅ (5/5 tests passed)

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Plugin .claude/ directory excluded | Run: `mode=docs` in plugin root | No `.claude/` core docs in candidates | Integration | `.pilot/tests/test-cleanup-docs.sh::test_plugin_excluded` |
| TS-2 | CONTEXT.md files protected | Scan for `CONTEXT.md` | All `CONTEXT.md` excluded | Integration | `.pilot/tests/test-cleanup-docs.sh::test_context_protected` |
| TS-3 | .pilot state dirs protected | Check `.pilot/plan/done/` | Plan files not candidates | Integration | `.pilot/tests/test-cleanup-docs.sh::test_pilot_protected` |
| TS-4 | Generated files still targeted | Create unreferenced file in `.claude/generated/` | File IS cleanup candidate | Unit | `.pilot/tests/test-cleanup-docs.sh::test_generated_cleaned` |
| TS-5 | Backup patterns still work | Create `test.md.bak` | Excluded from cleanup | Unit | `.pilot/tests/test-cleanup-docs.sh::test_backup_excluded` |

### Test Fixtures

**Setup**:
- Create `.pilot/tests/fixtures/cleanup/` directory for test data
- Create `.claude/generated/test_unref.md` (no references) for TS-4
- Create `test.md.bak` in root for TS-5 (should be excluded)

**Teardown**:
- Remove test fixtures after test execution
- Use `trap` command for cleanup on test exit: `trap 'rm -f test.md.bak .claude/generated/test_unref.md' EXIT`

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Over-exclusion hides real dead docs | Medium | Low | Make exclusions explicit and well-documented in comments |
| .pilot temp files not cleaned | Low | Low | Allow specific temp subdirectories to be scanned |
| Pattern changes break existing workflow | High | Medium | Comprehensive test coverage before release |
| Large repo scan performance | Low | Medium | Benchmark with 200+ files; consider `--max-depth` if needed |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| Should `.claude/generated/` have its own risk level? | Medium | Open |
| Should we add timestamp-based aging for `.pilot/plan/done/` files? | Low | Open |

---

## Review History

### 2026-01-20 - Auto-Review (Completed)

**Summary**: Plan reviewed and auto-applied improvements

**Findings**:
- BLOCKING: 2 (Test infrastructure, Non-executable verification)
- Critical: 0
- Warning: 2 (Missing implementation details, No test fixtures)
- Suggestion: 2 (Rollback test, Performance consideration)

**Changes Made**:
1. Added SC-7: Test infrastructure creation
2. Updated all SC verification commands to executable bash commands
3. Added test fixtures section (setup/teardown)
4. Added performance risk to mitigations
5. Added line number references in granular todos

**Updated Sections**:
- Success Criteria (SC-1 through SC-7)
- Granular Todo Breakdown (added SC-0, updated SC-1 with line number)
- Test Plan (added Test Fixtures section)
- Risks & Mitigations (added performance risk)

### 2026-01-20 - Execution (Completed)

**Summary**: All 11 todos completed successfully

**Execution Details**:
- **Total Iterations**: 1 (Ralph Loop)
- **Files Modified**: 2
  - `.claude/commands/05_cleanup.md`: Added plugin-aware documentation exclusions
  - `.pilot/tests/test-cleanup-docs.sh`: Created comprehensive test suite (289 lines)

**Test Results**:
- Tests run: 5
- Tests passed: 5 (100%)
- Tests failed: 0

**Implementation Summary**:
1. Added `--hidden` flag to ripgrep command for hidden directory scanning
2. Added specific glob exclusions for plugin subdirectories:
   - `.claude/agents/**`, `.claude/commands/**`, `.claude/guides/**`
   - `.claude/hooks/**`, `.claude/skills/**`, `.claude/templates/**`, `.claude/tests/**`
   - `.claude/**/CONTEXT.md` and `**/CONTEXT.md`
   - `.pilot/plan/**`
3. `.claude/generated/` remains scannable for cleanup
4. Documentation updated to reflect new exclusions (line 284)

**Verification**:
- All SC-1 through SC-7 passed
- All acceptance criteria (AC-1 through AC-6) met
- Test coverage: 100% of success criteria

---

**Plan Template Version**: 1.0
**Last Updated**: 2026-01-19
**Execution Date**: 2026-01-20
**Execution Status**: ✅ COMPLETED
