# Legacy Cleanup and Template Synchronization

- Generated: 2026-01-15 11:25:08 | Work: legacy_cleanup_and_template_sync
- Location: `.pilot/plan/pending/20260115_112508_legacy_cleanup_and_template_sync.md`

---

## User Requirements

Clean up legacy files from claude-pilot project and synchronize template directory with active development structure:
1. Remove backup directories created during recent restructuring
2. Fix broken documentation references (AGENTS.md in README.md)
3. Update version number in CLAUDE.md (3.2.0 → 3.3.0)
4. Delete root-level issue tracking files (all 3)
5. Synchronize template directory with active .claude/ structure

---

## PRP Analysis

### What (Functionality)

**Objective**: Remove legacy/backup files and synchronize pip package templates with current project structure

**Scope**:
- **In scope**:
  - Delete 2 backup directories (11 files total)
  - Fix README.md AGENTS.md reference (line 59)
  - Update CLAUDE.md version to 3.3.0
  - Delete 3 root-level issue files
  - Sync template agents (add 5, delete 1, update 3)
  - Sync template guides (add 1, delete 3)
- **Out of scope**:
  - Code functionality changes
  - New feature additions
  - Command file modifications

### Why (Context)

**Current Problem**:
- Backup directories clutter project structure (`.claude/agents.backup.20260115_092323/`, `.claude/backup/guides-20260115/`)
- README.md references non-existent `AGENTS.md` file (line 59)
- CLAUDE.md shows version 3.2.0 but project is at 3.3.0
- Root-level issue files no longer needed (DEPLOY.local.md, ISSUE_*.md, UPDATE_*.md)
- Template directory out of sync - pip users get outdated agent configs

**Desired State**:
- Clean project with no backup/legacy files
- All documentation references point to existing files
- Version consistency across all files
- Template directory matches active development structure

**Business Value**:
- Reduced confusion for contributors
- Correct structure for pip package users
- Cleaner repository for maintenance

### How (Approach)

- **Phase 1**: Delete backup directories
- **Phase 2**: Fix documentation references
- **Phase 3**: Delete root issue files
- **Phase 4**: Synchronize template directory
- **Phase 5**: Verification

### Success Criteria

```
SC-1: Zero backup directories in .claude/
- Verify: find .claude -type d -name "*backup*" | wc -l
- Expected: 0

SC-2: No AGENTS.md reference in README.md
- Verify: grep -c "AGENTS.md" README.md
- Expected: 0

SC-3: CLAUDE.md version is 3.3.0
- Verify: grep -c "Version.*3.3.0" CLAUDE.md
- Expected: 2 (line 4 and 421)

SC-4: Zero root-level issue files
- Verify: ls ISSUE*.md UPDATE*.md DEPLOY*.md 2>/dev/null | wc -l
- Expected: 0

SC-5: Template agents directory has 8 files matching active
- Verify: diff -rq .claude/agents/ src/claude_pilot/templates/.claude/agents/
- Expected: No output (directories match)

SC-6: Template guides has no legacy methodology files
- Verify: ls src/claude_pilot/templates/.claude/guides/{tdd,ralph,vibe}*.md 2>/dev/null | wc -l
- Expected: 0
```

### Constraints

- Preserve all existing functionality
- No breaking changes to pip package
- Keep AGENT.md.template (this is a valid template file, not legacy)

---

## Scope

### Files to Delete (17 total)

**Backup Directories (11 files)**:
- `.claude/agents.backup.20260115_092323/` (8 files)
- `.claude/backup/guides-20260115/` (3 files)

**Root Issue Files (3 files)**:
- `DEPLOY.local.md`
- `ISSUE_01_confirm_plan_extraction_gap.md`
- `UPDATE_UX_ISSUE.md`

**Template Legacy Files (4 files)**:
- `src/claude_pilot/templates/.claude/agents/reviewer.md` (replaced by code-reviewer.md)
- `src/claude_pilot/templates/.claude/guides/tdd-methodology.md` (moved to skills)
- `src/claude_pilot/templates/.claude/guides/ralph-loop.md` (moved to skills)
- `src/claude_pilot/templates/.claude/guides/vibe-coding.md` (moved to skills)

### Files to Modify (2 files)

- `README.md`: Line 59 - Change `AGENTS.md` reference
- `CLAUDE.md`: Lines 4, 421 - Update version 3.2.0 → 3.3.0

### Files to Copy (6 files)

**Agents to Template**:
- `.claude/agents/code-reviewer.md` → `src/claude_pilot/templates/.claude/agents/`
- `.claude/agents/plan-reviewer.md` → `src/claude_pilot/templates/.claude/agents/`
- `.claude/agents/researcher.md` → `src/claude_pilot/templates/.claude/agents/`
- `.claude/agents/tester.md` → `src/claude_pilot/templates/.claude/agents/`
- `.claude/agents/validator.md` → `src/claude_pilot/templates/.claude/agents/`

**Guides to Template**:
- `.claude/guides/parallel-execution.md` → `src/claude_pilot/templates/.claude/guides/`

### Files to Update in Template (3 files)

- `src/claude_pilot/templates/.claude/agents/coder.md` (sync with active)
- `src/claude_pilot/templates/.claude/agents/documenter.md` (sync with active)
- `src/claude_pilot/templates/.claude/agents/explorer.md` (sync with active)

---

## Test Environment (Detected)

- Project Type: Python
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/agents.backup.20260115_092323/` | Backup from agent restructuring | All | Safe to delete |
| `.claude/backup/guides-20260115/` | Backup from guide→skill migration | All | Safe to delete |
| `README.md` | Project documentation | 59 | References non-existent AGENTS.md |
| `CLAUDE.md` | Project config | 4, 421 | Version outdated (3.2.0) |
| `DEPLOY.local.md` | Legacy deploy guide | All | Superseded by /999_publish |
| `ISSUE_01_confirm_plan_extraction_gap.md` | Issue tracking | All | User confirmed deletion |
| `UPDATE_UX_ISSUE.md` | Issue tracking | All | User confirmed deletion |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Delete all 3 root issue files | User explicitly requested | Archive to docs/issues/ |
| Keep AGENT.md.template | Valid template, not legacy | Delete as part of cleanup |
| Sync full agents to template | Package users need latest | Minimal sync (only changes) |

### Implementation Patterns (FROM CONVERSATION)

#### Verification Commands
> **FROM CONVERSATION:**
> ```bash
> # Check for backup directories
> find .claude -type d -name "*backup*"
>
> # Compare active vs template
> diff -rq .claude/agents/ src/claude_pilot/templates/.claude/agents/
> diff -rq .claude/guides/ src/claude_pilot/templates/.claude/guides/
> ```

---

## Vibe Coding Compliance

| Target | Limit | Status |
|--------|-------|--------|
| Function | ≤50 lines | N/A (no code changes) |
| File | ≤200 lines | N/A (no code changes) |
| Nesting | ≤3 levels | N/A (no code changes) |

Note: This plan involves file operations (delete, copy, edit) only, no code changes.

---

## Execution Plan

### Phase 1: Delete Backup Directories

- [ ] 1.1 Delete `.claude/agents.backup.20260115_092323/` directory
- [ ] 1.2 Delete `.claude/backup/` directory (includes guides-20260115/)

### Phase 2: Fix Documentation References

- [ ] 2.1 Edit `README.md` line 59: Change `AGENTS.md` to `agents/` directory description
- [ ] 2.2 Edit `CLAUDE.md` line 4: Change `3.2.0` to `3.3.0`
- [ ] 2.3 Edit `CLAUDE.md` line 421: Change `3.2.0` to `3.3.0`

### Phase 3: Delete Root Issue Files

- [ ] 3.1 Delete `DEPLOY.local.md`
- [ ] 3.2 Delete `ISSUE_01_confirm_plan_extraction_gap.md`
- [ ] 3.3 Delete `UPDATE_UX_ISSUE.md`

### Phase 4: Synchronize Template Directory

#### 4.1 Delete Legacy Template Files
- [ ] 4.1.1 Delete `src/claude_pilot/templates/.claude/agents/reviewer.md`
- [ ] 4.1.2 Delete `src/claude_pilot/templates/.claude/guides/tdd-methodology.md`
- [ ] 4.1.3 Delete `src/claude_pilot/templates/.claude/guides/ralph-loop.md`
- [ ] 4.1.4 Delete `src/claude_pilot/templates/.claude/guides/vibe-coding.md`

#### 4.2 Copy New Agent Files to Template
- [ ] 4.2.1 Copy `code-reviewer.md` to template agents
- [ ] 4.2.2 Copy `plan-reviewer.md` to template agents
- [ ] 4.2.3 Copy `researcher.md` to template agents
- [ ] 4.2.4 Copy `tester.md` to template agents
- [ ] 4.2.5 Copy `validator.md` to template agents

#### 4.3 Update Existing Agent Files in Template
- [ ] 4.3.1 Sync `coder.md` to template
- [ ] 4.3.2 Sync `documenter.md` to template
- [ ] 4.3.3 Sync `explorer.md` to template

#### 4.4 Copy New Guide Files to Template
- [ ] 4.4.1 Copy `parallel-execution.md` to template guides

### Phase 5: Verification

- [ ] 5.1 Verify SC-1: No backup directories
- [ ] 5.2 Verify SC-2: No AGENTS.md reference
- [ ] 5.3 Verify SC-3: Version is 3.3.0
- [ ] 5.4 Verify SC-4: No root issue files
- [ ] 5.5 Verify SC-5: Template agents synced
- [ ] 5.6 Verify SC-6: No legacy guides in template

---

## Acceptance Criteria

| ID | Criteria | Verification |
|----|----------|--------------|
| AC-1 | All backup directories removed | `find .claude -name "*backup*" -type d` returns empty |
| AC-2 | README.md has valid file references | `grep AGENTS.md README.md` returns empty |
| AC-3 | CLAUDE.md version matches project | Version 3.3.0 in both locations |
| AC-4 | No orphan issue files in root | No ISSUE*.md, UPDATE*.md, DEPLOY*.md |
| AC-5 | Template directory synchronized | `diff -rq` shows no differences |

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Backup removal verification | `find` command | 0 directories found | Manual | N/A |
| TS-2 | README reference validation | `grep` command | 0 matches | Manual | N/A |
| TS-3 | Version consistency check | `grep` command | 2 matches for 3.3.0 | Manual | N/A |
| TS-4 | Root file cleanup | `ls` command | No files found | Manual | N/A |
| TS-5 | Template sync validation | `diff -rq` | No output (identical) | Manual | N/A |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Accidentally delete needed backup | Low | Medium | Backups are from today; current agents/ verified working |
| Break pip package | Low | High | Verify template structure before commit |
| Miss a reference to legacy files | Medium | Low | Grep entire project for deleted file names |

---

## Open Questions

None - all decisions confirmed by user.

---

## Execution Summary

### Status: ✅ COMPLETE

**Date**: 2026-01-15
**Branch**: main
**Runtime**: < 5 minutes

### Changes Made

**Files Deleted (17 total)**:
- 2 backup directories (11 files): `.claude/agents.backup.20260115_092323/`, `.claude/backup/`
- 3 root issue files: `DEPLOY.local.md`, `ISSUE_01_confirm_plan_extraction_gap.md`, `UPDATE_UX_ISSUE.md`
- 4 legacy template files: `reviewer.md`, `tdd-methodology.md`, `ralph-loop.md`, `vibe-coding.md`

**Files Modified (2 files)**:
- `README.md`: Line 59 - Changed `AGENTS.md` to `.claude/agents/`
- `CLAUDE.md`: Lines 4, 421 - Updated version 3.2.0 → 3.3.0

**Files Copied (6 files)**:
- 5 new agent configs: `code-reviewer.md`, `plan-reviewer.md`, `researcher.md`, `tester.md`, `validator.md`
- 1 new guide: `parallel-execution.md`

**Files Synced (3 files)**:
- `coder.md`, `documenter.md`, `explorer.md`

### Verification Results

| SC | Criteria | Status | Command Result |
|----|----------|--------|----------------|
| SC-1 | Zero backup directories | ✅ PASS | 0 found |
| SC-2 | No AGENTS.md reference | ✅ PASS | 0 matches |
| SC-3 | Version is 3.3.0 | ✅ PASS | 2 matches |
| SC-4 | Zero root issue files | ✅ PASS | 0 found |
| SC-5 | Template agents synced | ✅ PASS | No diff output |
| SC-6 | No legacy guides | ✅ PASS | 0 found |

### Quality Gates
- Type Check: N/A (no code changes)
- Lint: N/A (no code changes)
- Tests: N/A (manual verification only)

### Follow-ups
None - all cleanup tasks completed successfully.

