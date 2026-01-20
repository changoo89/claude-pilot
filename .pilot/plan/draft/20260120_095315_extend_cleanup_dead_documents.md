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

5. **Orphaned documentation detection**
   - Find all `.md` files
   - Check cross-references: `\[.*\]\(.*\.md\)` patterns
   - Exclude auto-generated, active plans, index files
   - Detect files with zero inbound references

6. **Document risk classification**
   - **Low**: Backup files, temporary files, orphaned drafts
   - **Medium**: Old plan files (`.pilot/plan/done/` older than 30 days), unused docs in `docs/`
   - **High**: README.md, CLAUDE.md, docs/ index files, currently referenced docs

7. **Integration with existing workflow**
   - Reuse `calculate_risk_level()` function with document patterns
   - Reuse `apply_file()` and `verify_and_rollback()` functions
   - Reuse pre-flight safety check for modified files
   - Follow same dry-run, auto-apply, and --apply patterns

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

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Detect backup files | Test repo with `*.backup`, `*.bak` files | All backup files detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_backup_detection` |
| TS-2 | Detect temp files | Test repo with `.tmp/`, `*.tmp` files | All temp files detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_temp_detection` |
| TS-3 | Detect orphaned docs | Test repo with unreferenced `.md` file | Orphaned file detected | Unit | `.pilot/tests/test_cleanup_docs.sh::test_orphan_detection` |
| TS-4 | Cross-reference validation | Test repo with linked `.md` files | Referenced files NOT flagged | Unit | `.pilot/tests/test_cleanup_docs.sh::test_crossref_validation` |
| TS-5 | Risk classification | Test backup (Low), old plan (Medium), README (High) | Correct risk levels | Unit | `.pilot/tests/test_cleanup_docs.sh::test_risk_classification` |
| TS-6 | Pre-flight safety | Modified README.md in test repo | Modified file blocked | Integration | `.pilot/tests/test_cleanup_docs.sh::test_preflight_safety` |
| TS-7 | Dry-run mode | `/05_cleanup mode=docs --dry-run` | Shows candidates, no deletion | Integration | `.pilot/tests/test_cleanup_docs.sh::test_dry_run` |
| TS-8 | Auto-apply Low/Medium risk | Test repo with Low/Medium risk docs | Auto-applied without confirmation | Integration | `.pilot/tests/test_cleanup_docs.sh::test_auto_apply` |
| TS-9 | High-risk confirmation | Test repo with High-risk docs | AskUserQuestion called | Integration | `.pilot/tests/test_cleanup_docs.sh::test_high_risk_confirm` |
| TS-10 | Exclude active plans | Test repo with `pending/`, `in_progress/` plans | Active plans excluded | Unit | `.pilot/tests/test_cleanup_docs.sh::test_exclude_active_plans` |

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

### 2026-01-20 - Auto-Review

**Summary**: Plan created from /00_plan conversation

**Findings**:
- BLOCKING: 0
- Critical: 0
- Warning: 0
- Suggestion: 0

**Changes Made**: Initial plan creation

**Updated Sections**: All sections
