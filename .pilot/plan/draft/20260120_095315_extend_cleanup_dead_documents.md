# Extend 05_cleanup for Dead Document Detection

> **Generated**: 2026-01-20 09:53:15 | **Work**: extend_cleanup_dead_documents | **Location**: .pilot/plan/draft/20260120_095315_extend_cleanup_dead_documents.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 09:17 | "05_cleaner 에서 데드코드 말고 데드문서들도 제거를 했으면 하는데 각종 백업 문서들이나 임시 문서들, 더 이상 안쓰는 고아 문서들 등등" | Extend 05_cleanup to detect and remove dead documents (backups, temporary files, orphaned docs) |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1 through SC-8 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Extend `/05_cleanup` command to detect and remove dead documents (backup files, temporary files, orphaned documentation) alongside existing dead code cleanup

**Scope**:
- **In Scope**:
  - Add new mode: `docs` (Tier 3: Dead documents)
  - Backup file detection: `*.backup`, `*.bak`, `*~`, `*.old`, `.backup*/`, `.claude.backup.*`
  - Temporary file detection: `*.tmp`, `*.temp`, `.tmp/`, `cache/`
  - Orphaned documentation detection: Markdown files not referenced in TOC, index, or other docs
  - Cross-reference validation: Check if `.md` files are linked from other files
  - Risk classification for documents (Low/Medium/High)
  - Integration with existing auto-apply workflow

- **Out of Scope**:
  - Binary file cleanup (images, PDFs, etc.)
  - External documentation systems (Notion, Confluence, etc.)
  - Auto-generated documentation (keep these)
  - Active plan files (`.pilot/plan/pending/`, `.pilot/plan/in_progress/`)

**Deliverables**:
1. Extended `05_cleanup.md` with `docs` mode
2. Document detection script (`detect-docs.sh`)
3. Cross-reference validation logic
4. Test coverage for new functionality

### Why (Context)

**Current Problem**:
- `/05_cleanup` only handles dead code (imports, files)
- Backup directories accumulate: `.claude.backup.20260115_120858/` (entire directory structure)
- Backup files scattered: `CLAUDE.md.backup`, `continuation.json.backup`, `codex-sync.sh.backup`
- Temporary files: `.tmp/` directory
- Orphaned documentation: Old plan files, unused markdown files
- Manual cleanup is tedious and error-prone

**Business Value**:
- **User impact**: Cleaner repository, reduced noise, faster git operations
- **Technical impact**: Smaller clone size, faster backups, easier navigation
- **Maintenance impact**: Automated cleanup reduces manual effort

**Background**:
- Current `05_cleanup` has 3 modes: `imports`, `files`, `all`
- Adding `docs` mode extends this to Tier 3
- Existing risk-based confirmation pattern applies
- Existing verification and rollback mechanism applies

### How (Approach)

**Implementation Strategy**:

1. **Add `docs` mode to argument parsing**
   - Extend `MODE` variable: `imports`, `files`, `docs`, `all`
   - Update argument-hint in frontmatter

2. **Create document detection script**
   - Pattern matching for backup/temp files
   - Cross-reference validation for markdown files
   - Risk classification for documents

3. **Backup file detection patterns**
   - Extensions: `*.backup`, `*.bak`, `*~`, `*.old`
   - Directories: `.backup*`, `.claude.backup.*`, `*backup*/`
   - Files: `*.backup.*`, `backup_*`, `*_backup.*`

4. **Temporary file detection patterns**
   - Extensions: `*.tmp`, `*.temp`, `*.cache`
   - Directories: `.tmp/`, `tmp/`, `cache/`, `temp/`

5. **Orphaned documentation detection** (DETAILED SPECIFICATION)

**Definition of "Orphaned Document"**: A markdown file with ZERO inbound markdown references from other files in the repository.

**Inbound Reference Types** (all counted):
- Markdown inline links: `[text](path/to/file.md)`
- Markdown reference-style links: `[text][ref]` where `[ref]: path/to/file.md`
- Links with anchors: `[text](file.md#section)` (counts as reference to file.md)
- URL-encoded paths: `[text](file%20name.md)` (decode before matching)
- Case-insensitive matching: `FILE.MD` == `file.md`

**Path Resolution Rules**:
- Relative paths resolved from referencing file's directory
- Absolute paths (starting with `/`) resolved from repository root
- Parent directory references (`../`) handled correctly
- Index files implicit: Link to `dir/` counts as reference to `dir/README.md` or `dir/index.md`

**Scan Scope**:
- **Primary scan**: All `.md` files in repository root and `docs/` directory
- **Excluded from scan** (never checked for orphan status):
  - `.pilot/plan/pending/**` (active work)
  - `.pilot/plan/in_progress/**` (active work)
  - `.claude/**` (plugin internals)
  - `node_modules/**` (dependencies)
  - `.git/**` (git internals)
  - `vendor/**` (third-party)
  - `dist/**`, `build/**` (build artifacts)

**Auto-Generated Detection** (exclude from orphan detection):
- Files with marker comment: `<!-- AUTO-GENERATED -->` or `<!-- @generated -->`
- Files in `docs/generated/` directory
- Files with `DO NOT EDIT` header comment

**Protected Files** (always High-risk, never auto-delete):
- `README.md` (any directory)
- `CLAUDE.md`, `CLAUDE.local.md`
- `INDEX.md`, `index.md` (any directory)
- Files referenced from root `README.md`

6. **Document risk classification** (ENHANCED RULES)

**Low Risk** (auto-apply):
- Backup files by location+pattern: In `.backup*/`, `.claude.backup.*`, OR matching `*.backup*`, `*.bak`, `*~`, `*.old`
- Temporary files by location+pattern: In `.tmp/`, `tmp/`, OR matching `*.tmp`, `*.temp`
- Files in `docs/` matching `*draft*`, `*wip*`, `*scratch*`

**Medium Risk** (auto-apply):
- Old plan files in `.pilot/plan/done/` (modified >30 days ago, verified by `git log -1 --until="30 days ago"`)
- Unused docs in `docs/` (not referenced, not protected, not auto-generated)
- Files matching `*archive*`, `*deprecated*`, `*old*`

**High Risk** (confirmation required):
- `README.md`, `CLAUDE.md`, `INDEX.md`, `index.md` (explicitly enumerated)
- Files in `docs/` root directory (docs/guide.md, docs/api.md, etc.)
- Currently referenced docs (has inbound links from other files)
- ANY file with uncommitted modifications (pre-flight safety)

**Age-Based Risk Adjustment**:
- Files created/modified within last 7 days: +1 risk level (Low→Medium, Medium→High)
- Files not modified in >90 days: -1 risk level (High→Medium, Medium→Low)

7. **Integration with existing workflow**
   - Reuse `calculate_risk_level()` function with document patterns
   - Reuse `apply_file()` and `verify_and_rollback()` functions
   - Reuse pre-flight safety check for modified files
   - Follow same dry-run, auto-apply, and --apply patterns

**Deletion Mechanics and Safety Model** (CRITICAL):

**Tracked Files** (in git):
- Use `git rm` for deletion (staged for commit)
- Rollback: `git restore --source=HEAD --staged --worktree -- <file>`
- Files are recoverable from git history until commit

**Untracked Files** (not in git):
- Move to `.trash/` directory (not immediate deletion)
- Rollback: `mv .trash/$(basename <file>) $(dirname <file>)/`
- `.trash/` is gitignored

**Verification Command** (run after each batch of 10 deletions):
- For tracked files: `git status --porcelain` (verify files removed)
- For untracked files: Check `.trash/` count matches deletion count
- Final verification: Run project-specific command if defined in CLAUDE.local.md

**Quarantine Strategy** (recommended for safety):
1. **Phase 1**: Move to `.trash/` (all files)
2. **Verification**: Run tests, check for broken links
3. **Phase 2**: If verification passes, permanent delete from `.trash/`
4. **Rollback**: Restore from `.trash/` if verification fails

**Golden Output for Dry-Run** (testable format):
```markdown
| Item | Reason | Detection | Risk | Verification | Rollback |
|------|--------|-----------|------|-------------|----------|
| .claude.backup.20260115/ | Backup directory | Tier 3 | Low | git status | mv .trash/ |
| docs/draft.md | Orphaned (0 refs) | Tier 3 | Medium | git status | mv .trash/ |
```

**Non-Interactive Confirmation Testing**:
- Test with `--apply` flag (bypasses confirmation)
- Verify AskUserQuestion NOT called for Low/Medium risk
- Verify AskUserQuestion called for High risk (check log output)
- Use mock AskUserQuestion for automated testing

**Dependencies**:
- Existing `05_cleanup.md` infrastructure
- Existing risk classification system
- Existing verification and rollback mechanism

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Deleting important backup files | Medium | High | Risk classification (High-risk requires confirmation) |
| False positive orphan detection | Medium | Medium | Cross-reference validation only, exclude auto-generated |
| Accidentally removing active docs | Low | High | Exclude `pending/`, `in_progress/` plans from detection |
| Performance on large doc sets | Low | Low | Limit cross-reference scan to docs/ directory |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: Add `docs` mode to `/05_cleanup` command argument parsing
  - **Verify**: Check `MODE` variable accepts `docs` value
  - **Expected**: `MODE` can be `imports`, `files`, `docs`, or `all`

- [ ] **SC-2**: Create document detection patterns (backup, temp, orphaned)
  - **Verify**: Run detection on test repo with known backup/temp files
  - **Expected**: All backup/temp files detected, categorized correctly

- [ ] **SC-3**: Implement cross-reference validation for markdown files
  - **Verify**: Create test file with no inbound links, run detection
  - **Expected**: Orphaned file detected, referenced files not flagged

- [ ] **SC-4**: Implement document risk classification (Low/Medium/High)
  - **Verify**: Test backup file (Low), old plan (Medium), README.md (High)
  - **Expected**: Correct risk level assigned to each file type

- [ ] **SC-5**: Integrate docs mode with existing auto-apply workflow
  - **Verify**: Run `/05_cleanup mode=docs --dry-run` on test repo
  - **Expected**: Candidates table shown, same format as existing modes

- [ ] **SC-6**: Add pre-flight safety for active documentation
  - **Verify**: Create modified README.md, run docs mode
  - **Expected**: Modified files blocked (High risk), not auto-applied

- [ ] **SC-7**: Write tests for document detection functionality
  - **Verify**: Run test suite with new document detection tests
  - **Expected**: All tests pass, coverage ≥80%

- [ ] **SC-8**: Update command documentation and help text
  - **Verify**: Check frontmatter argument-hint includes docs mode
  - **Expected**: `argument-hint` shows `[mode=imports|files|docs|all]`

**Verification Method**: Manual testing + automated test suite

### Constraints

**Technical Constraints**:
- Must maintain backward compatibility with existing `imports`, `files`, `all` modes
- Must not break existing verification and rollback mechanism
- Must use existing risk-based confirmation pattern
- Must work with existing Bash test framework

**Business Constraints**:
- Must not delete active documentation without user confirmation
- Must preserve `README.md`, `CLAUDE.md`, index files unless explicitly confirmed

**Quality Constraints**:
- **Coverage**: ≥80% overall, ≥90% for detection logic
- **Type Safety**: N/A (Bash script)
- **Code Quality**: Follow Vibe Coding (≤50 lines/function, ≤200 lines/file additions)
- **Standards**: Consistent with existing `05_cleanup.md` patterns

---

## Scope

### In Scope
- Add `docs` mode to `/05_cleanup` command
- Backup file detection (`*.backup`, `*.bak`, `*~`, `*.old`, `.backup*/`, `.claude.backup.*`)
- Temporary file detection (`*.tmp`, `*.temp`, `.tmp/`, `cache/`)
- Orphaned documentation detection (markdown files with zero inbound references)
- Cross-reference validation for markdown files
- Document risk classification (Low/Medium/High)
- Integration with existing auto-apply workflow
- Pre-flight safety for active documentation
- Comprehensive test coverage

### Out of Scope
- Binary file cleanup (images, PDFs, etc.)
- External documentation systems (Notion, Confluence, etc.)
- Auto-generated documentation
- Active plan files (`.pilot/plan/pending/`, `.pilot/plan/in_progress/`)

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| Bash | N/A | `bash .pilot/tests/test_cleanup_docs.sh` | N/A (manual coverage verification) |

**Test Directory**: `.pilot/tests/`

**Coverage Target**: 80%+ overall, 90%+ for detection logic

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/05_cleanup.md` | Existing dead code cleanup command | All lines | Current implementation with imports/files/all modes, risk classification, auto-apply workflow |
| `CLAUDE.md` | Project documentation | All lines | Plugin overview and architecture |
| `.claude/commands/CONTEXT.md` | Commands context | All lines | Command workflow and relationships |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Add `docs` as new mode | Extends existing Tier 1/2 pattern to Tier 3 | Create separate command (rejected: code duplication) |
| Cross-reference validation only for .md files | Markdown is primary documentation format | Include all text files (rejected: false positives) |
| Exclude active plans from detection | Safety: prevent deleting work in progress | Include all plans (rejected: data loss risk) |
| Reuse existing risk classification | Consistency with current workflow | New risk system (rejected: complexity) |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```bash
# Existing risk classification pattern from 05_cleanup.md
calculate_risk_level() {
  local file="$1"

  # Test files - Low risk
  if [[ "$file" =~ \.(test|spec|mock)\.(ts|js|go|py)$ ]] || [[ "$file" =~ _test\.(go|py)$ ]]; then
    echo "Low"
    return
  fi

  # Utility/helper files - Medium risk
  if [[ "$file" =~ (utils|helpers|lib)/.*\.(ts|js|go|py)$ ]]; then
    echo "Medium"
    return
  fi

  # Core components/routes - High risk
  if [[ "$file" =~ (components|routes|pages|controllers|models|services)/.*\.(ts|js|tsx|jsx|go|py)$ ]]; then
    echo "High"
    return
  fi

  # Default - Medium risk
  echo "Medium"
}
```

> **FROM CONVERSATION:**
> ```bash
# Existing pre-flight safety check pattern
check_file_modified() {
  local file="$1"

  # Check if file is tracked and modified
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    if ! git diff --quiet "$file" 2>/dev/null; then
      echo "true"
      return
    fi
    # Check if file is staged
    if git diff --cached --quiet "$file" 2>/dev/null; then
      :
    else
      echo "true"
      return
    fi
  fi

  echo "false"
}
```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
# Backup file patterns found in codebase
*.backup
*.bak
*~
*.old
.backup*/
.claude.backup.*
backup_*
*_backup.*
```

> **FROM CONVERSATION:**
> ```bash
# Temporary file patterns found in codebase
*.tmp
*.temp
.tmp/
tmp/
cache/
temp/
```

> **FROM CONVERSATION:**
> ```bash
# Cross-reference validation pattern
\[.*\]\(.*\.md\)
```

#### Architecture Diagrams
> No architecture diagrams found in conversation

### Assumptions
- User has Git installed (for pre-flight safety check)
- Standard Unix utilities available (find, grep, rg, etc.)
- Existing 05_cleanup infrastructure is stable
- Test environment can create temporary test repos

### Dependencies
- Existing `.claude/commands/05_cleanup.md` structure
- Existing risk classification system
- Existing verification and rollback mechanism
- Bash scripting environment
- ripgrep (rg) for efficient file searching

---

## Architecture

### System Design
Extend the existing 3-tier cleanup system to add a 4th tier for documents:
- **Tier 1**: Unused imports (existing)
- **Tier 2**: Dead files (existing)
- **Tier 3**: Dead documents (new)
- **All mode**: Tiers 1 + 2 + 3 (extended)

### Components
| Component | Purpose | Integration |
|-----------|---------|-------------|
| `05_cleanup.md` | Main command file | Extend with docs mode |
| `detect-docs.sh` | Document detection script | New file, called by 05_cleanup |
| `test_cleanup_docs.sh` | Test suite | New file in .pilot/tests/ |

### Data Flow
1. User runs `/05_cleanup mode=docs`
2. Argument parsing sets MODE=docs
3. Detection phase calls detect-docs.sh
4. detect-docs.sh scans for backup/temp/orphaned files
5. Cross-reference validation identifies orphaned docs
6. Risk classification assigns Low/Medium/High
7. Candidates table generated
8. Auto-apply for Low/Medium, confirmation for High
9. Verification and rollback on failure

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Extract document detection to separate script, modular functions |
| File | ≤200 lines | Keep 05_cleanup.md concise, delegate to detect-docs.sh |
| Nesting | ≤3 levels | Early return pattern in risk classification |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1 | Add `docs` to MODE variable in argument parsing section (Step 1) | coder | 5 min | pending |
| SC-1 | Update frontmatter argument-hint to include docs mode | coder | 3 min | pending |
| SC-2 | Create `.claude/scripts/detect-docs.sh` script with backup patterns | coder | 15 min | pending |
| SC-2 | Add temporary file detection patterns to detect-docs.sh | coder | 10 min | pending |
| SC-3 | Implement cross-reference validation function in detect-docs.sh | coder | 15 min | pending |
| SC-3 | Add orphan detection logic with exclusion rules | coder | 10 min | pending |
| SC-4 | Extend calculate_risk_level() with document patterns | coder | 10 min | pending |
| SC-5 | Add Tier 3 detection phase (docs mode) to Step 4 | coder | 15 min | pending |
| SC-5 | Update candidates table format for document types | coder | 5 min | pending |
| SC-6 | Add active plan exclusion to detection logic | coder | 5 min | pending |
| SC-7 | Write test_backup_detection test case | tester | 10 min | pending |
| SC-7 | Write test_temp_detection test case | tester | 10 min | pending |
| SC-7 | Write test_orphan_detection test case | tester | 15 min | pending |
| SC-7 | Write test_crossref_validation test case | tester | 15 min | pending |
| SC-7 | Write test_risk_classification test case | tester | 10 min | pending |
| SC-7 | Write test_preflight_safety test case | tester | 10 min | pending |
| SC-7 | Write test_dry_run test case | tester | 10 min | pending |
| SC-7 | Write test_auto_apply test case | tester | 10 min | pending |
| SC-7 | Write test_high_risk_confirm test case | tester | 10 min | pending |
| SC-7 | Write test_exclude_active_plans test case | tester | 10 min | pending |
| SC-7 | Run all tests and verify coverage ≥80% | validator | 5 min | pending |
| SC-8 | Update command description in frontmatter | documenter | 5 min | pending |
| SC-8 | Add docs mode examples to Safety & Examples section | documenter | 10 min | pending |
| SC-8 | Update Step 9 verification command detection for docs | coder | 5 min | pending |

**Granularity Verification**: ✅ All 23 todos comply with 3 rules
- Time: All ≤15 minutes
- Owner: Single clear owner (coder, tester, validator, documenter)
- Atomic: Each todo modifies one file/component

**Warnings**: None

---

## Acceptance Criteria

- [ ] **AC-1**: `/05_cleanup mode=docs` command accepts docs mode
- [ ] **AC-2**: Backup files (*.backup, *.bak, *~, *.old) are detected
- [ ] **AC-3**: Temporary files (*.tmp, *.temp, .tmp/) are detected
- [ ] **AC-4**: Orphaned markdown files (zero inbound links) are detected
- [ ] **AC-5**: Document risk classification works correctly
- [ ] **AC-6**: Auto-apply works for Low/Medium risk documents
- [ ] **AC-7**: High-risk documents require confirmation
- [ ] **AC-8**: All tests pass with coverage ≥80%

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File | Verification Method |
|----|----------|-------|----------|------|-----------|---------------------|
| TS-1 | Detect backup files | Test repo with `*.backup`, `*.bak` files | All backup files detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_backup_detection` | Count matches `find -name "*.backup" -o -name "*.bak"` |
| TS-2 | Detect temp files | Test repo with `.tmp/`, `*.tmp` files | All temp files detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_temp_detection` | Count matches `find .tmp/ -o -name "*.tmp"` |
| TS-3 | Detect orphaned docs | Test repo with unreferenced `.md` file | Orphaned file detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_orphan_detection` | Unreferenced file in candidates table |
| TS-4 | Cross-reference validation | Test repo with linked `.md` files | Referenced files NOT flagged | Unit | `.pilot/tests/test_cleanup_docs.sh::test_crossref_validation` | Referenced file NOT in candidates table |
| TS-5 | Risk classification | Test backup (Low), old plan (Medium), README (High) | Correct risk levels | Unit | `.pilot/tests/test_cleanup_docs.sh::test_risk_classification` | Risk column shows Low/Medium/High |
| TS-6 | Pre-flight safety | Modified README.md in test repo | Modified file blocked | Integration | `.pilot/tests/test_cleanup_docs.sh::test_preflight_safety` | Risk shows "High (blocked)", rollback in place |
| TS-7 | Dry-run mode | `/05_cleanup mode=docs --dry-run` | Shows candidates, no deletion | Integration | `.pilot/tests/test_cleanup_docs.sh::test_dry_run` | Output table non-empty, files still exist |
| TS-8 | Auto-apply Low/Medium risk | Test repo with Low/Medium risk docs | Auto-applied without confirmation | Integration | `.pilot/tests/test_cleanup_docs.sh::test_auto_apply` | Files moved to .trash/, no AskUserQuestion in log |
| TS-9 | High-risk confirmation | Test repo with High-risk docs | AskUserQuestion called | Integration | `.pilot/tests/test_cleanup_docs.sh::test_high_risk_confirm` | Log contains "AskUserQuestion" for High risk |
| TS-10 | Exclude active plans | Test repo with `pending/`, `in_progress/` plans | Active plans excluded | Unit | `.pilot/tests/test_cleanup_docs.sh::test_exclude_active_plans` | Active plans NOT in candidates table |

**Coverage Verification** (objective measure):
- **Function coverage**: Each detection function has dedicated test (backup, temp, orphan, crossref, risk)
- **Branch coverage**: Risk classification tests all 3 levels (Low, Medium, High)
- **Integration coverage**: End-to-end workflow tested (dry-run, auto-apply, confirmation)
- **Assertion count**: Minimum 30 assertions across all test functions
- **Pass rate**: 100% (all tests must pass)

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| False positive orphan detection | Medium | Medium | Cross-reference validation only, exclude auto-generated |
| Deleting important backup files | High | Medium | Risk classification (High-risk requires confirmation) |
| Performance on large doc sets | Low | Low | Limit cross-reference scan to docs/ directory |
| Breaking existing modes | High | Low | Additive changes only, no modification to existing logic |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| None | - | All requirements clear |

---

## Review History

### 2026-01-20 - GPT Plan Reviewer (BLOCKING → Fixed)

**Summary**: GPT Plan Reviewer rejected initial plan due to underspecified behaviors

**Findings** (BLOCKING):
- BLOCKING: 5 critical issues identified
  1. "Orphaned doc" definition not precise enough
  2. Scan scope and exclusions not locked down
  3. Deletion mechanics and safety model not specified
  4. Risk classification rules too loose
  5. Tests not objectively verifiable

**Changes Made** (Interactive Recovery):
1. **Added detailed orphan detection specification**:
   - Defined all inbound reference types (inline, reference-style, anchors, URL-encoded, case-insensitive)
   - Specified path resolution rules (relative, absolute, parent, index)
   - Listed scan scope and exclusions (pending/, in_progress/, .claude/, node_modules/, etc.)
   - Added auto-generated detection rules
   - Enumerated protected files (README.md, CLAUDE.md, INDEX.md, index.md)

2. **Enhanced risk classification rules**:
   - Low Risk: Backup/temp files by location+pattern
   - Medium Risk: Old plans (>30 days), unused docs, archive/deprecated/old files
   - High Risk: Protected files, docs root files, currently referenced, modified files
   - Added age-based risk adjustment (+7 days, -90 days)

3. **Specified deletion mechanics and safety model**:
   - Tracked files: `git rm`, rollback with `git restore`
   - Untracked files: Move to `.trash/`, rollback with `mv`
   - Verification commands after each batch
   - Quarantine strategy (move → verify → permanent delete)
   - Golden output format for dry-run testing
   - Non-interactive confirmation testing methods

4. **Made tests objectively verifiable**:
   - Added "Verification Method" column with specific commands
   - Added objective coverage measures (function, branch, integration)
   - Specified assertion count (minimum 30) and pass rate (100%)

**Updated Sections**: How (Approach) - Sections 5, 6, 7; Test Plan; Review History

### 2026-01-20 - Auto-Review

**Summary**: Plan created from /00_plan conversation

**Findings**:
- BLOCKING: 0
- Critical: 0
- Warning: 0
- Suggestion: 0

**Changes Made**: Initial plan creation

**Updated Sections**: All sections
