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

5. **Orphaned documentation detection** (DETAILED SPECIFICATION - SCOPE LOCKED)

**Definition of "Orphaned Document"**: A markdown file with ZERO inbound markdown references from other files in the repository.

**Inbound Reference Types** (all counted):
- Markdown inline links: `[text](path/to/file.md)`
- Markdown reference-style links: `[text][ref]` where `[ref]: path/to/file.md`
- Links with anchors: `[text](file.md#section)` (counts as reference to file.md, anchor ignored for orphan check)
- URL-encoded paths: `[text](file%20name.md)` (decode before matching: `file name.md`)
- Case-insensitive matching: `FILE.MD` == `file.md` (casefold comparison)
- Angle-bracket links: `<file.md>` (sometimes used in wikis)

**Path Resolution Rules**:
- Relative paths resolved from referencing file's directory: `docs/guide.md` + `../api.md` = `api.md`
- Absolute paths (starting with `/`) resolved from repository root
- Parent directory references (`../`) handled correctly
- Index file precedence (in order): Link to `dir/` checks `dir/README.md` first, then `dir/index.md`

**EXPLICIT SCAN SCOPE** (locked down, no contradictions):

**A. Backup/Temp Detection** (pattern-based, NOT orphan-dependent):
- Scan: All files in repository (recursive from root)
- Match by: File extension (`*.backup`, `*.bak`, `*~`, `*.old`, `*.tmp`, `*.temp`) OR directory location (`.backup*`, `.tmp/`, `tmp/`, `cache/`)
- Excludes: `.git/**`, `node_modules/**`, `vendor/**`, `dist/**`, `build/**`

**B. Orphan Detection** (markdown-only, cross-reference-based - NO CONTRADICTIONS):
- **SINGLE UNIFIED SCAN SCOPE**: All `.md` files in **repository root** AND **`docs/`** directory ONLY
- **Inbound link sources**: Same `.md` files in **repository root** AND **`docs/`** directory ONLY
- **Explicitly EXCLUDED from orphan scan**: `.pilot/plan/**` (ALL subdirectories: pending/, in_progress/, done/), `.claude/**`, `node_modules/**`, `vendor/**`, `dist/**`, `build/**`
- **Note**: `.pilot/plan/done/**` is EXCLUDED from orphan detection (too risky to auto-delete completed work)
- **Rationale**: Completed plans are historical records, not candidates for cleanup regardless of references

**C. Risk Classification Scope** (applies to ALL detected files):
- Backup/temp files: Repository-wide (any location)
- Orphan candidates: Root + `docs/` ONLY (`.pilot/plan/done/` excluded from orphan detection, see section 5B)
- Protected files: Repository-wide (any location)

**Auto-Generated Detection** (exclude from orphan detection):
- Files with marker comment: `<!-- AUTO-GENERATED -->` or `<!-- @generated -->`
- Files in `docs/generated/` directory
- Files with `DO NOT EDIT` header comment

**Protected Files** (always High-risk, never auto-delete):
- `README.md` (any directory)
- `CLAUDE.md`, `CLAUDE.local.md`
- `INDEX.md`, `index.md` (any directory)
- Files referenced from root `README.md` (extract links with `grep -o '\\[.*\\](.*\\.md)' README.md`)

6. **Document risk classification** (ENHANCED RULES - AGE-BASED)

**Low Risk** (auto-apply):
- Backup files by location+pattern: In `.backup*/`, `.claude.backup.*`, OR matching `*.backup*`, `*.bak`, `*~`, `*.old`
- Temporary files by location+pattern: In `.tmp/`, `tmp/`, OR matching `*.tmp`, `*.temp`
- Files in `docs/` matching `*draft*`, `*wip*`, `*scratch*`

**Medium Risk** (auto-apply):
- Unused docs in `docs/` (orphaned, not protected, not auto-generated)
- Files matching `*archive*`, `*deprecated*`, `*old*`
- Note: `.pilot/plan/done/` is excluded from orphan detection (too risky for auto-deletion)

**High Risk** (confirmation required):
- `README.md`, `CLAUDE.md`, `INDEX.md`, `index.md` (explicitly enumerated)
- Files in `docs/` root directory (docs/guide.md, docs/api.md, etc.)
- Currently referenced docs (has inbound links from other files in scan scope)
- ANY file with uncommitted modifications (pre-flight safety, git-based check)

**Age-Based Risk Adjustment** (git-based, fallback to filesystem):
- For tracked files: Use `git log -1 --format="%ct" -- <file>` to get last commit timestamp
- For untracked files: Use `stat -f "%m" <file>` or `stat -c "%Y" <file>` (filesystem modification time)
- Files created/modified within last 7 days: +1 risk level (Low→Medium, Medium→High)
- Files not modified in >90 days: -1 risk level (High→Medium, Medium→Low), floor at Low

7. **Integration with existing workflow**
   - Reuse `calculate_risk_level()` function with document patterns
   - Reuse `apply_file()` and `verify_and_rollback()` functions
   - Reuse pre-flight safety check for modified files
   - Follow same dry-run, auto-apply, and --apply patterns

**Deletion Mechanics and Safety Model** (CRITICAL - CONSISTENT STRATEGY):

**PRIMARY STRATEGY**: Two-tier deletion (tracked vs untracked)

**Tracked Files** (in git):
- **Direct deletion**: Use `git rm` for immediate removal (staged for commit)
- **Rollback**: `git restore --source=HEAD --staged --worktree -- <file>`
- **Recoverability**: Files are recoverable from git history until commit
- **Verification**: `git status --porcelain` shows deleted files as `D  <file>`

**Untracked Files** (not in git):
- **Quarantine**: Move to `.trash/<timestamp>_/<relative_path>` (timestamped subdirectories prevent collisions)
- **Rollback**: `mv .trash/<timestamp>_/<relative_path> <original_dir>/`
- **Recoverability**: Files remain in `.trash/` until manual cleanup
- **Verification**: Check `.trash/` directory count matches expected deletions

**CRITICAL: .trash/ Collision Prevention**:
- **Problem**: Two files with same basename (e.g., `a/file.md` and `b/file.md`) collide in `.trash/`
- **Solution**: Store full relative path with timestamp prefix: `.trash/20260120_120000/a/file.md`
- **Rollback command**: `mv ".trash/20260120_120000/$relative_path" "$repo_root/$relative_path"`
- **Directory recreation**: `mkdir -p "$(dirname "$repo_root/$relative_path")"` before restore

**Batch Verification** (after each 10 deletions):
```bash
# For tracked files
git status --porcelain | grep "^D " | wc -l  # Count deleted tracked files

# For untracked files
# Use $TIMESTAMP_PREFIX variable set at invocation time (consistent across session)
ls -la .trash/ | grep "$TIMESTAMP_PREFIX" | wc -l  # Count files in current timestamp batch

# Final verification (if defined in CLAUDE.local.md)
if grep -q "verification_command:" CLAUDE.local.md 2>/dev/null; then
  $(grep "verification_command:" CLAUDE.local.md | cut -d: -f2)
fi
```

**Timestamp Unit**: One timestamp directory per `/05_cleanup` invocation (all files in one batch share same timestamp prefix)

**Directory Handling** (explicit commands):
```bash
# Tracked files (including directories)
git rm -r <directory>  # For directories
git rm <file>           # For single files

# Untracked files (quarantine to .trash/)
TIMESTAMP_PREFIX=$(date +%Y%m%d_%H%M%S)
mv <directory> .trash/$TIMESTAMP_PREFIX/<relative_path>/  # For directories (mv handles directories)
mv <file> .trash/$TIMESTAMP_PREFIX/<relative_path>         # For single files

# Directory recreation during rollback
mkdir -p "$(dirname "$repo_root/$relative_path")"
mv .trash/$TIMESTAMP_PREFIX/$relative_path $repo_root/$relative_path
```

**NO Separate Quarantine Phase**: The "quarantine strategy" mentioned earlier is simplified to:
- **Tracked**: Direct `git rm` (git history serves as quarantine until commit)
- **Untracked**: Move to `.trash/` with timestamp prefix (serves as quarantine)

**Golden Output for Dry-Run** (testable format):
```markdown
| Item | Reason | Detection | Risk | Verification | Rollback |
|------|--------|-----------|------|-------------|----------|
| .claude.backup.20260115/ | Backup directory | Tier 3 | Low | git status | git restore |
| docs/draft.md | Orphaned (0 refs) | Tier 3 | Medium | git status | mv .trash/ |
```

**Non-Interactive Confirmation Testing**:
- Test with `--apply` flag: Bypasses ALL AskUserQuestion calls
- Test without `--apply`: Mock AskUserQuestion with environment variable `ASK_USER_QUESTION_RESPONSE=<choice_index>`
- Log-based verification: Check output for "AskUserQuestion" string to confirm confirmation was requested
- Automated test fixture: Source `.claude/mocks/ask-user-question.sh` which provides non-interactive responses

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
  - **Expected**: All tests pass, minimum 30 assertions, all detection functions covered

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
- **Test Coverage**: All 4 detection functions tested, all 3 risk levels tested, minimum 30 assertions (NO %-based targets, Bash scripts lack coverage tools)
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

**Coverage Target**: All 4 detection functions tested, all 3 risk levels tested, minimum 30 assertions (NO %-based targets, Bash scripts lack coverage tools)

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
| SC-7 | Run all tests and verify minimum 30 assertions, all detection functions covered | validator | 5 min | pending |
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
- [ ] **AC-8**: All tests pass with minimum 30 assertions, all detection functions covered

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

**Coverage Verification** (objective measure, NO tool-based coverage):
- **Detection function coverage**: All 4 detection functions tested (backup, temp, orphan, crossref)
  - Verify: Each function has dedicated test in test_cleanup_docs.sh
  - Check: `grep -c "test_.*_detection\|test_.*_validation" test_cleanup_docs.sh | wc -l` >= 4
- **Risk classification coverage**: All 3 risk levels tested (Low, Medium, High)
  - Verify: Risk level tested for each category
  - Check: Test includes `assert_contains "Low"`, `assert_contains "Medium"`, `assert_contains "High"`
- **Integration coverage**: End-to-end workflow tested
  - Verify: Dry-run, auto-apply, high-risk confirmation all tested
  - Check: `grep -c "test_dry_run\|test_auto_apply\|test_high_risk_confirm" test_cleanup_docs.sh | wc -l` >= 3
- **Assertion count**: Minimum 30 assertions across all test functions
  - Verify: `grep -c "assert\|verify\|check" test_cleanup_docs.sh | wc -l` >= 30
- **Pass rate**: 100% (all tests must pass)
  - Verify: Test script returns 0 only if all assertions pass

**Note**: Bash scripts don't have standard coverage tools like Istanbul/nyc. The above measures provide objective verification without requiring additional tools.

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

### 2026-01-20 - GPT Plan Reviewer (Round 4 - Final)

**Summary**: GPT Plan Reviewer found 3 remaining BLOCKING issues after Round 3; all have been addressed in this round.

**Findings** (BLOCKING - Round 4 → All Fixed):
1. ✅ Todo list "verify coverage ≥80%" contradiction RESOLVED
2. ✅ `mv -r` invalid option RESOLVED
3. ✅ .trash/ verification TIMESTAMP_PREFIX recompute RESOLVED

**Changes Made** (Interactive Recovery Round 4):
1. **Fixed todo list coverage contradiction**:
   - Updated line 545: Changed "verify coverage ≥80%" to "verify minimum 30 assertions, all detection functions covered"
   - Now consistent with Round 3 fix that removed %-based targets

2. **Fixed mv -r invalid option**:
   - Updated line 223: Changed `mv -r <directory>` to `mv <directory>` (mv handles directories without -r flag)
   - Added comment clarifying mv handles directories automatically

3. **Fixed .trash/ verification TIMESTAMP_PREFIX recompute**:
   - Removed recomputation of TIMESTAMP_PREFIX with `$(date ...)` in verification section
   - Added comment: "Use $TIMESTAMP_PREFIX variable set at invocation time (consistent across session)"
   - Removed alternative verification command that recomputed timestamp

**Updated Sections**: Execution Plan (line 545), Directory Handling (line 223), Batch Verification (lines 200-202), Review History

**Status**: All Round 4 BLOCKING issues resolved. Ready for Round 5 GPT Plan Reviewer verification.

### 2026-01-20 - GPT Plan Reviewer (Round 3 - Final)

**Summary**: GPT Plan Reviewer found 3 remaining BLOCKING issues after Round 2; all have been addressed in this round.

**Findings** (BLOCKING - Round 3 → All Fixed):
1. ✅ Orphan scope contradiction RESOLVED
2. ✅ Coverage contradiction RESOLVED
3. ✅ .trash/ verification semantics RESOLVED

**Changes Made** (Interactive Recovery Round 3):
1. **Fixed orphan scope contradiction**:
   - Clarified `.pilot/plan/**` is EXCLUDED from orphan detection (ALL subdirectories)
   - Removed `.pilot/plan/done/` from orphan candidates (too risky)
   - Single unified scan scope: root + `docs/` ONLY
   - Updated Medium Risk: Removed old plans mention
   - Added rationale: Completed plans are historical records

2. **Resolved coverage contradiction**:
   - Removed ALL %-based targets from Quality Constraints
   - Updated SC-7: "minimum 30 assertions, all detection functions covered" (no %)
   - Updated Test Environment: "NO %-based targets, Bash scripts lack coverage tools"
   - Updated AC-8: Same as SC-7 (consistency)
   - Added note: "Bash scripts lack coverage tools, using grep-based verification"

3. **Clarified .trash/ verification semantics**:
   - Timestamp unit: One timestamp directory per `/05_cleanup` invocation
   - Added verification commands for current batch
   - Explicit directory handling commands (git rm -r, mv -r)
   - Directory recreation during rollback specified

**Updated Sections**: How (Approach) - Section 5B (Orphan Detection), Section 6 (Risk Classification), Section 7 (Deletion Mechanics), Quality Constraints, Test Environment, SC-7, AC-8, Review History

### 2026-01-20 - GPT Plan Reviewer (Round 2 - BLOCKING → Fixed)

**Summary**: GPT Plan Reviewer found 5 remaining BLOCKING issues about scope contradictions, quarantine consistency, .trash/ rollback, non-interactive testing, and coverage measurement

**Findings** (BLOCKING - Round 2):
1. Scope contradictions between orphan scan and .pilot/plan/done/
2. Quarantine/deletion strategy conflicts
3. .trash/ rollback collision bugs
4. Non-interactive confirmation mocking not specified
5. Coverage requirements not measurable

**Changes Made** (Interactive Recovery Round 2):
1. **Locked down scan scope** (no contradictions):
   - Explicit A/B/C scan scopes for backup/temp, orphan detection, and risk classification
   - Orphan scan NOW includes `.pilot/plan/done/**` (old plans can be orphans)
   - Inbound link sources limited to root + `docs/` (plugin internals excluded)
   - Clear explicit inclusion/exclusion lists for each scan type

2. **Unified deletion strategy** (consistent, no conflicts):
   - Tracked: Direct `git rm` (git history is quarantine)
   - Untracked: Move to `.trash/<timestamp>_/<relative_path>` (quarantine)
   - NO separate quarantine phase - simplified model

3. **Fixed .trash/ rollback collision prevention**:
   - Timestamped subdirectories: `.trash/20260120_120000/a/file.md`
   - Full relative path preserved (no basename collisions)
   - Rollback with directory recreation: `mkdir -p "$(dirname "$repo_root/$relative_path")"`

4. **Specified non-interactive confirmation**:
   - `--apply` flag bypasses ALL AskUserQuestion calls
   - Mock with environment variable: `ASK_USER_QUESTION_RESPONSE=<choice_index>`
   - Log-based verification: Check output for "AskUserQuestion" string
   - Test fixture: `.claude/mocks/ask-user-question.sh`

5. **Replaced coverage with objective measures** (no tool-based coverage):
   - Detection function coverage: Count test functions (>=4 required)
   - Risk classification coverage: Check for all 3 levels tested
   - Integration coverage: Count workflow tests (>=3 required)
   - Assertion count: Minimum 30 assertions
   - Pass rate: 100%
   - Note: Bash has no Istanbul/nyc, using grep-based verification

**Updated Sections**: How (Approach) - Sections 5, 6, 7 (Deletion Mechanics); Test Plan (Coverage Verification); Review History

### 2026-01-20 - GPT Plan Reviewer (Round 1 - BLOCKING → Fixed)

**Summary**: GPT Plan Reviewer rejected initial plan due to underspecified behaviors

**Findings** (BLOCKING - Round 1):
- BLOCKING: 5 critical issues identified
  1. "Orphaned doc" definition not precise enough
  2. Scan scope and exclusions not locked down
  3. Deletion mechanics and safety model not specified
  4. Risk classification rules too loose
  5. Tests not objectively verifiable

**Changes Made** (Interactive Recovery Round 1):
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
