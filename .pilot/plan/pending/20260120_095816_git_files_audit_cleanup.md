# Git Files Audit and Cleanup

> **Generated**: 2026-01-20 09:58:16 | **Work**: git_files_audit_cleanup | **Location**: .pilot/plan/draft/20260120_095816_git_files_audit_cleanup.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 09:17 | "plugin 프로젝트 관점에서 지금 우리 git 으로 관리되고있는 파일들 모두 점검해보자. 불필요한게 섞여들어간 것 같은데" | Git-tracked files audit for unnecessary files |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Audit and clean up unnecessary files tracked by git in the claude-pilot plugin project

**Scope**:
- **In Scope**:
  - Identify and categorize all 547 git-tracked files
  - Detect backup files, temporary files, and unnecessary artifacts
  - Identify duplicate file prefixes (`.claude-pilot/` issue)
  - Review `.pilot/plan/done/` historical plan files
  - Review external skills in `.claude/skills/external/`
  - Provide recommendations for cleanup

- **Out of Scope**:
  - Actual file deletion (implementation phase)
  - Modifying .gitignore (can be suggested, not implemented)
  - GitHub workflow configuration changes

**Deliverables**:
1. Comprehensive file audit report
2. Categorized list of files for removal
3. Updated .gitignore recommendations
4. Safe git commands for cleanup execution

### Why (Context)

**Current Problem**:
- 547 files tracked by git, including unnecessary files
- Backup files (`.backup`, `.bak`) tracked in version control
- `.claude-pilot/` prefix appears to duplicate files (7 files)
- Historical plan files accumulate in `.pilot/plan/done/` (137 files)
- External skills bundle may contain unnecessary third-party code

**Business Value**:
- **Cleaner repository**: Faster clones, smaller repository size
- **Better maintainability**: Clear signal-to-noise ratio in tracked files
- **Professional distribution**: Plugin marketplace users get clean plugin
- **Reduced confusion**: Only necessary files tracked

**Background**:
- This is a Claude Code plugin distributed via GitHub Marketplace
- Plugin files should be minimal and focused
- Development artifacts shouldn't be in production plugin
- `.pilot/` directory contains runtime state/plans (131 files) that shouldn't be tracked

### How (Approach)

**Implementation Strategy**:
1. **Categorize all 547 files** by type and purpose
2. **Identify removable files**:
   - Backup files (`.backup`, `.bak`)
   - Temporary files (`.tmp`)
   - Duplicate prefixes (`.claude-pilot/`)
   - Runtime state (`.pilot/` directory)
   - Historical plans (evaluate retention policy)
   - External skills (evaluate necessity)
3. **Verify safety**: Each file candidate checked for necessity
4. **Provide cleanup plan**: Organized by priority/risk

**Dependencies**:
- None (read-only audit complete, ready for implementation)

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Removing necessary files | Low | High | Verification checklist before deletion |
| Breaking plugin functionality | Low | High | Test after cleanup in separate branch |
| Losing historical plans | Low | Medium | Archive rather than delete if needed |

### Success Criteria

- [ ] **SC-1**: Complete audit report with file categorization
  - Verify: `grep -c "^|" audit_report.md` shows 547+ entries (header + all files)
  - Expected: Clear categories (core, backup, temp, duplicate, runtime state, historical)
  - Command: Check report file exists at `.pilot/audit_report.md`

- [ ] **SC-2**: Identify files for removal with justification
  - Verify: `grep -E "(\.backup|\.bak|\.tmp)" removable_files.txt | wc -l` shows 7 files
  - Expected: List grouped by category (backup: 6 files, temp: 1 file, runtime: 137, duplicate: 7)
  - Command: Check removal list contains all 151 files (137+7+7=151)

- [ ] **SC-3**: Provide actionable cleanup recommendations
  - Verify: Plan contains "Cleanup Commands" section with executable git commands
  - Expected: Step-by-step cleanup plan with verification steps
  - Command: `grep -E "^git rm" plan.md | wc -l` shows 4+ commands

### Constraints

- **Technical**: Bash/git commands only, no external dependencies
- **Patterns**: Follow existing .gitignore conventions
- **Quality**: Zero data loss, reversible operations (git-based cleanup)

---

## Scope

### In Scope
- File categorization and audit
- Identification of removable files
- .gitignore recommendations
- Safe cleanup commands

### Out of Scope
- Actual file deletion (implementation phase)
- GitHub workflow changes
- Plugin functionality modifications

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| N/A | N/A | N/A (audit task) | N/A (audit task) |

**Note**: This is a planning/analysis task - verification happens through user review and approval.

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.gitignore` | Git ignore patterns | Lines 1-45 | Has `*.backup`, `*.log` patterns |
| `.claude-plugin/plugin.json` | Plugin metadata | Lines 1-27 | Defines plugin structure |
| `.serena/project.yml` | Serena MCP config | Lines 1-88 | Bash language project |
| `CLAUDE.md` | Project documentation | Lines 1-178 | Plugin overview, v4.3.1 |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Add `.pilot/` to .gitignore | Runtime state/plans shouldn't be tracked | Keep historical plans (rejected: 131 files, too much noise) |
| Remove all `.backup` files | Backup files never belong in version control | Keep some backups (rejected: unnecessary clutter) |
| Remove `.claude-pilot/` prefix | Duplicate of existing `.pilot/` files | Investigate necessity (completed: confirmed duplicates) |

### Implementation Patterns (FROM CONVERSATION)

#### Git Commands for Cleanup
> **FROM CONVERSATION:**
> ```bash
# Remove runtime state and plans
git rm -r .pilot/ .claude-pilot/

# Remove backup and temporary files
git rm .claude/guides/.backup/*
git rm .claude/scripts/codex-sync.sh.backup
git rm CLAUDE.md.backup
git rm .tmp

# Commit changes
git commit -m "chore: remove runtime state and backup files from git tracking"
> ```

#### .gitignore Updates
> **FROM CONVERSATION:**
> ```bash
# Add to .gitignore
echo ".pilot/" >> .gitignore
> ```

#### File Count Analysis
> **FROM CONVERSATION:**
> ```bash
# Total files tracked
git ls-files | wc -l  # Output: 547

# Backup files found
git ls-files | grep -E "(\.backup|\.bak|~|\.old|\.orig|\.tmp)"  # 8 files

# .pilot/ files
git ls-files | grep "\.pilot/plan/" | wc -l  # 131 files
> ```

### Assumptions
- User wants clean plugin distribution for marketplace
- Historical plan files have value but shouldn't be in git
- Backup files were added before .gitignore rules were established
- `.claude-pilot/` prefix is historical artifact, not actively used

### Dependencies
- None

---

## Architecture

### System Design
This is a repository cleanup task, not a software architecture change. The cleanup affects:
1. Git repository size and clone speed
2. Plugin distribution package
3. Development workflow (runtime state no longer tracked)

### Components
| Component | Purpose | Integration |
|-----------|---------|-------------|
| .gitignore | Define ignored patterns | No integration needed |
| Core plugin files | `.claude/` directory | Unchanged |
| Runtime state | `.pilot/` directory | Removed from git tracking |

### Data Flow
No data flow changes - this is a repository hygiene task.

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | N/A (bash commands, not functions) |
| File | ≤200 lines | N/A (git commands, not code files) |
| Nesting | ≤3 levels | N/A (simple linear commands) |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

1. **Phase 1: Update .gitignore** (coder, 5 min)
   - Add `.pilot/` to .gitignore
   - Verify pattern coverage with `git check-ignore -v .pilot/plan/test.md`

2. **Phase 2: Remove Runtime State** (coder, 5 min)
   - `git rm -r .pilot/` (137 files)
   - `git rm -r .claude-pilot/` (7 files)

3. **Phase 3: Remove Backup Files** (coder, 5 min)
   - Remove `.claude/guides/.backup/*` (3 files)
   - Remove `.claude/scripts/codex-sync.sh.backup`
   - Remove `.pilot/state/continuation.json.backup`
   - Remove `.pilot/state/continuation.json.final.backup`
   - Remove `CLAUDE.md.backup`
   - Remove `.tmp`

4. **Phase 4: Verify and Commit** (validator, 5 min)
   - Verify `git status` shows expected 151 removals
   - Commit with descriptive message
   - Verify repository still functional

---

## Acceptance Criteria

- [ ] **AC-1**: All 547 files categorized
  - Verify: Categorization report complete
  - Expected: Clear categories with counts

- [ ] **AC-2**: .gitignore updated with `.pilot/`
  - Verify: `.gitignore` contains `.pilot/` pattern
  - Expected: Pattern present and effective

- [ ] **AC-3**: 151 files removed from git tracking
  - Verify: `git ls-files | wc -l` shows ~396 files (down from 547)
  - Expected: 137 .pilot/ + 7 .claude-pilot/ + 7 backup/temp = 151 files removed
  - Command: `git status | grep "deleted:" | wc -l` shows 151

- [ ] **AC-4**: Plugin functionality preserved
  - Verify: Plugin structure intact
  - Expected: `.claude/` directory unchanged, all core files present

---

## Test Plan

| ID | Scenario | Expected | Type |
|----|----------|----------|------|
| TS-1 | File categorization complete | All 547 files categorized | N/A (report generation) |
| TS-2 | Backup file detection | 7 backup/temp files found | N/A (analysis) |
| TS-3 | Runtime state detection | 137 `.pilot/` files identified | N/A (analysis) |
| TS-4 | Duplicate detection | 7 `.claude-pilot/` files identified | N/A (analysis) |
| TS-5 | Cleanup commands execute | `git status` shows 151 deletions | Integration |
| TS-6 | Plugin verification | `.claude/commands/` still present | Integration |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Accidental removal of necessary files | High | Low | Verification checklist, review before commit |
| Break plugin functionality | High | Low | Test in separate branch first |
| Loss of historical plans | Medium | Low | Archive to `docs/archive/plans/` if needed |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| Should historical `.pilot/plan/done/` files be archived before removal? | Medium | Open |
| Are external skills in `.claude/skills/external/` necessary? | Low | Open |

---

## Review History

### 2026-01-20 09:58 - Plan Creation

**Summary**: Initial plan created from /00_plan conversation

**Status**: Draft - pending auto-review

**Findings**: Pending review
