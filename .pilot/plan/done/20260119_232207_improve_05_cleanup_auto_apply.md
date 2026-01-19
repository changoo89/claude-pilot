# Improve /05_cleanup Command - Auto-Apply Workflow

> **Generated**: 2026-01-19 23:22:07 | **Work**: improve_05_cleanup_auto_apply | **Location**: .pilot/plan/draft/20260119_232207_improve_05_cleanup_auto_apply.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 23:22 | "우리 05_cleanup 커맨드가 좀 애매모호한거같은데 확인좀 해줘. 커맨드를 실행하면 알아서 정리가 되어야 할 것 같은데 자꾸 딴소리하네" | /05_cleanup should auto-clean without friction |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Improve `/05_cleanup` command to provide automatic cleanup without manual confirmation while maintaining safety guarantees.

**Scope**:
- **In Scope**: Modify default behavior to auto-apply for Low/Medium risk items, support both `--dry-run` and `--apply` flags (mutually exclusive), implement confirmation gating logic, interactive confirmation for High-risk items, non-interactive/CI behavior, verification + rollback mechanics
- **Out of Scope**: Changing Tier 1/Tier 2 detection logic (what counts as unused/dead), safe-file-ops integration

**Deliverables**:
1. Modified `/05_cleanup` command with auto-apply default behavior
2. Risk level classification logic (Low/Medium/High)
3. Interactive confirmation for High-risk items
4. `--dry-run` flag for explicit dry-run mode
5. Updated command description and documentation

### Why (Context)

**Current Problem**:
- Users expect `/05_cleanup` to "just work" (auto-clean)
- Current 2-step workflow (dry-run → --apply) feels like "딴소리" (unnecessary friction)
- Every cleanup requires two commands: `/05_cleanup` then `/05_cleanup --apply`
- Dry-run is default, requiring manual `--apply` flag every time

**Business Value**:
- **User Impact**: Better UX - single command execution for common cases
- **Technical Impact**: Same safety guarantees with smarter automation
- **Workflow Impact**: Reduced cognitive load - no need to remember `--apply` flag

### How (Approach)

**Implementation Strategy**:

1. **Flag Semantics** (GPT Architect recommendation):
   - Support both `--dry-run` and `--apply` flags (mutually exclusive)
   - Default (interactive TTY): auto-apply Low/Medium, confirm High-risk
   - `--dry-run`: never modifies files, never prompts, prints what would happen
   - `--apply`: apply everything (including High-risk) without prompting
   - Both flags present: hard error with usage hint

2. **High-Risk Confirmation UX**:
   - Per-batch (single prompt for all High-risk items)
   - AskUserQuestion choices:
     * "Apply all high-risk" - proceed to delete all High-risk
     * "Skip high-risk" - apply Low/Medium only, report skipped list
     * "Review one-by-one" - iterate High-risk files with y/N
   - Show compact summary before prompting: counts + top N files per risk
   - Default answer is safe (Skip) if user closes prompt/empty response

3. **Verification + Rollback Mechanics**:
   - Pre-flight safety: Never delete modified/staged files (treat as High-risk "blocked")
   - Verification timing: After each batch of N deletions (N=10), once at end
   - Verification command resolution: Use existing detection; if none found, run `git diff --name-status` + `git diff --check` and warn
   - Rollback on failure:
     * Maintain run manifest (deleted tracked paths + trashed untracked paths + trash location)
     * Restore tracked: `git restore --source=HEAD --staged --worktree -- <paths>`
     * Restore untracked: move back from trash
     * Stop execution, return exit code 1

4. **Non-Interactive Behavior** (CI/non-TTY):
   - Default: behaves like `--dry-run` (no modifications)
   - Exit code 2 if changes needed, else 0
   - With `--apply`: apply everything (incl. High-risk), run verification/rollback

**Risk Level Classification**:
- **Low Risk**: Test files (*.test.ts, *.spec.ts, *.mock.ts, *_test.go)
- **Medium Risk**: Utility/helper files (src/utils/*, lib/helpers/*)
- **High Risk**: Core components/routes (src/components/*, src/routes/*, src/pages/*)

**Dependencies**:
- `safe-file-ops` skill (git rm, .trash/ directory)
- Existing detection logic (Tier 1: unused imports, Tier 2: dead files)

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Deleting important files | Low | High | Keep verification commands, ask for High-risk only |
| Breaking existing workflows | Low | Medium | Support `--dry-run` flag for backward compatibility |
| False positives in detection | Medium | Medium | Conservative detection already in place |

### Success Criteria

- [ ] **SC-1**: `/05_cleanup` auto-applies Low/Medium risk items without confirmation (interactive TTY)
- [ ] **SC-2**: High-risk items show per-batch confirmation dialog with 3 choices (Apply all, Skip, Review one-by-one)
- [ ] **SC-3**: `--dry-run` flag shows candidates only, no deletion, no prompts
- [ ] **SC-4**: `--apply` flag applies everything including High-risk without prompting
- [ ] **SC-5**: Both `--dry-run` and `--apply` flags present → hard error with usage hint
- [ ] **SC-6**: Verification commands execute after each batch (N=10) and at end
- [ ] **SC-7**: Rollback on verification failure: tracked files restored via git, untracked from trash
- [ ] **SC-8**: Pre-flight safety: modified/staged files auto-blocked as High-risk "blocked"
- [ ] **SC-9**: Non-interactive (CI/non-TTY): defaults to `--dry-run` behavior, exit code 2 if changes needed
- [ ] **SC-10**: Non-interactive with `--apply`: applies everything, runs verification/rollback

### Constraints

**Technical**:
- Must maintain backward compatibility with `--dry-run` flag
- Must keep safety checks (verification commands, rollback)
- Must work with existing `safe-file-ops` skill

**Patterns**:
- Follow existing command structure in `.claude/commands/`
- Use `AskUserQuestion` for interactive confirmation
- Use Vibe Coding standards (@.claude/skills/vibe-coding/SKILL.md)

**Timeline**: Quick implementation (user is frustrated)

---

## Scope

### In Scope
- **Default Behavior**: Auto-apply Low/Medium risk items in interactive shells
- **Flag Support**: Both `--dry-run` and `--apply` flags (mutually exclusive)
- **Confirmation Gating**: Risk-based classification logic for confirmation policy (Low/Medium/High)
- **High-Risk Confirmation**: Per-batch AskUserQuestion with 3 choices (Apply all, Skip, Review one-by-one)
- **Non-Interactive Behavior**: CI/non-TTY defaults to `--dry-run`-like behavior (exit code 2 if changes needed)
- **Verification + Rollback**: Pre-flight checks, batch verification, rollback mechanics
- **Pre-flight Safety**: Never delete modified/staged files (auto-block as High-risk)
- **Documentation**: Update command description, argument hints, usage examples

### Out of Scope
- **Detection Logic**: Tier 1/Tier 2 detection algorithms (what counts as unused/dead)
- **Safe-File-Ops**: git rm vs .trash/ integration (existing skill handles this)
- **Verification Detection**: Project-specific verification command detection (keep existing logic)

---

## Test Environment (Detected)

| Framework | Test Command | Coverage Command | Test Directory |
|-----------|--------------|------------------|----------------|
| Shell Script (bash) | `bash .pilot/tests/cleanup-*.test.sh` | N/A | `.pilot/tests/` |

**Project Type**: Shell script (bash)
**Coverage Target**: N/A (shell script)

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/05_cleanup.md` | Current cleanup command implementation | Lines 1-187 | Uses `--apply` flag, dry-run default |
| `.claude/skills/safe-file-ops/SKILL.md` | Safe file deletion operations | Referenced | git rm for tracked, .trash/ for untracked |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Auto-apply by default (inverse from current) | User wants "just work" experience | Keep --apply but make it optional |
| Risk-based confirmation (High only) | Reduce friction while maintaining safety | Confirm all deletions |
| Replace --apply with --dry-run | More intuitive flag naming | Keep both flags (confusing) |
| AskUserQuestion for High-risk items | Native Claude Code interaction | Terminal prompt (less integrated) |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```bash
> # Risk Level Classification Logic
> calculate_risk_level() {
>   local file="$1"
>
>   # Test files - Low risk
>   if [[ "$file" =~ \.(test|spec|mock)\.(ts|js|go)$ ]]; then
>     echo "Low"
>     return
>   fi
>
>   # Utility/helper files - Medium risk
>   if [[ "$file" =~ (utils|helpers|lib)/.*\.(ts|js)$ ]]; then
>     echo "Medium"
>     return
>   fi
>
>   # Core components/routes - High risk
>   if [[ "$file" =~ (components|routes|pages|controllers|models)/.*\.(ts|js|tsx|jsx)$ ]]; then
>     echo "High"
>     return
>   fi
>
>   # Default - Medium risk
>   echo "Medium"
> }
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> # Current: /05_cleanup mode=imports --apply
> # New:    /05_cleanup mode=imports (auto-applies Low/Medium)
> # Dry-run: /05_cleanup mode=imports --dry-run
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> Risk Level → Action Mapping:
> Low    → Auto-delete immediately (no confirmation)
> Medium → Auto-delete immediately (no confirmation)
> High   → Show summary, ask user (confirmation required)
> ```

### Assumptions
- User wants single-command execution for most cases
- High-risk items are rare (mostly components/routes)
- Safe-file-ops skill handles git-tracked vs untracked correctly
- Verification commands exist in most projects (npm test, pytest, go test)

### Dependencies
- `.claude/skills/safe-file-ops/SKILL.md` - Safe file deletion
- `AskUserQuestion` tool - Interactive confirmation
- Existing Tier 1/Tier 2 detection logic

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Extract `calculate_risk_level()` function, keep other functions focused |
| File | ≤200 lines | Current file is 187 lines - may need to extract helper functions |
| Nesting | ≤3 levels | Use early return in risk classification logic |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1 | Implement auto-apply for Low/Medium risk items (interactive TTY default) | coder | 15 min | pending |
| SC-2 | Implement per-batch AskUserQuestion for High-risk with 3 choices (Apply all, Skip, Review one-by-one) | coder | 20 min | pending |
| SC-3 | Implement `--dry-run` flag (never modifies, never prompts, prints plan) | coder | 10 min | pending |
| SC-4 | Implement `--apply` flag (applies everything including High-risk, no prompts) | coder | 10 min | pending |
| SC-5 | Implement flag conflict detection (both --dry-run and --apply → error) | coder | 5 min | pending |
| SC-6 | Implement `calculate_risk_level()` function with Low/Medium/High classification | coder | 10 min | pending |
| SC-7 | Implement pre-flight safety check (auto-block modified/staged files) | coder | 15 min | pending |
| SC-8 | Implement verification after each batch (N=10) and at end | coder | 10 min | pending |
| SC-9 | Implement rollback on verification failure (git restore + trash restore) | coder | 15 min | pending |
| SC-10 | Implement non-interactive detection (CI/non-TTY) with default --dry-run behavior | coder | 10 min | pending |
| SC-11 | Update command description, argument hints, usage examples | documenter | 15 min | pending |
| SC-12 | Write test scenarios (10 tests covering all flag combinations and edge cases) | tester | 30 min | pending |
| SC-13 | Verify all Success Criteria met (SC-1 through SC-10) | validator | 10 min | pending |

**Total Estimated Time**: ~175 minutes (2 hours 55 minutes)
**GPT Architect Effort Estimate**: Medium (complex due to flag semantics, verification, rollback)

---

## Acceptance Criteria

- [ ] **AC-1**: `/05_cleanup mode=imports` (interactive TTY) auto-applies Low/Medium without confirmation
- [ ] **AC-2**: `/05_cleanup mode=files` with High-risk items shows per-batch AskUserQuestion with 3 choices
- [ ] **AC-3**: `/05_cleanup mode=imports --dry-run` shows candidates only, no deletion, no prompts, exit 0
- [ ] **AC-4**: `/05_cleanup mode=files --apply` applies everything including High-risk without prompting
- [ ] **AC-5**: `/05_cleanup mode=imports --dry-run --apply` shows error with usage hint, exit 1
- [ ] **AC-6**: Verification commands execute every 10 deletions and at end
- [ ] **AC-7**: Rollback on verification failure restores tracked files (git restore) and untracked (trash)
- [ ] **AC-8**: Pre-flight safety blocks modified/staged files from deletion (High-risk "blocked")
- [ ] **AC-9**: Non-interactive (CI/non-TTY) defaults to --dry-run behavior, exit 2 if changes needed
- [ ] **AC-10**: Non-interactive with --apply applies everything, runs verification/rollback

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Auto-cleanup low-risk items | `/05_cleanup mode=imports` (interactive TTY) | Auto-applies unused imports without confirmation | Integration | `.pilot/tests/cleanup-auto.test.sh` |
| TS-2 | Interactive confirmation for high-risk | `/05_cleanup mode=files` (High-risk detected) | Shows AskUserQuestion dialog with 3 choices (Apply all, Skip, Review one-by-one) | Integration | `.pilot/tests/cleanup-confirm.test.sh` |
| TS-3 | Explicit dry-run mode | `/05_cleanup mode=imports --dry-run` | Shows candidates table only, no deletion, no prompts, exit 0 | Integration | `.pilot/tests/cleanup-dryrun.test.sh` |
| TS-4 | Force apply mode | `/05_cleanup mode=files --apply` | Applies everything including High-risk without prompting | Integration | `.pilot/tests/cleanup-apply.test.sh` |
| TS-5 | Both flags conflict | `/05_cleanup mode=imports --dry-run --apply` | Hard error with usage hint, exit 1 | Integration | `.pilot/tests/cleanup-conflict.test.sh` |
| TS-6 | Verification after batch | Auto-apply with 10+ items | Runs verification command every 10 items and at end | Integration | `.pilot/tests/cleanup-verify.test.sh` |
| TS-7 | Rollback on failure | Verification fails during batch | Rolls back current batch via git restore + trash restore, stops, exit 1 | Integration | `.pilot/tests/cleanup-rollback.test.sh` |
| TS-8 | Pre-flight safety check | `/05_cleanup` with modified/staged files | Modified/staged files auto-blocked as High-risk "blocked", not deleted | Integration | `.pilot/tests/cleanup-preflight.test.sh` |
| TS-9 | Non-interactive default | `/05_cleanup` in CI/non-TTY | Behaves like --dry-run, exit 2 if changes needed | Integration | `.pilot/tests/cleanup-ci.test.sh` |
| TS-10 | Non-interactive with apply | `/05_cleanup --apply` in CI/non-TTY | Applies everything including High-risk, runs verification/rollback | Integration | `.pilot/tests/cleanup-ci-apply.test.sh` |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Accidental deletion of important files | High | Low | Keep verification commands, pre-flight safety (block modified/staged), High-risk confirmation |
| Users surprised by new auto-apply default | Medium | Medium | Very explicit summary output ("Applied: X, Confirmed: Y, Skipped: Z"), keep `--dry-run` |
| Breaking existing automation scripts | Medium | Low | Support `--apply` flag for backward compatibility, CI defaults to safe (`--dry-run`-like) |
| Rollback cannot restore uncommitted edits | High | Low | Never delete modified/staged files (pre-flight block), require explicit manual handling |
| CI starts failing due to exit code 2 | Low | Medium | Document "run locally once" or run `/05_cleanup --apply` in dedicated job |
| AskUserQuestion not working in shell context | Medium | Low | Fallback to terminal prompt if AskUserQuestion unavailable |

**GPT Architect Additional Risks**:
- Risk: Verification command resolution may fail in some projects → Mitigation: Fallback to `git diff --name-status` + `git diff --check` with warning
- Risk: Run manifest may become large for many deletions → Mitigation: Store in temp file, clean up on success

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| Should we add a `--yes` flag to skip even High-risk confirmation? | Low | Open (deferred to implementation) |
| Should we add color coding to risk levels in output? | Low | Open (nice to have) |

---

## Review History

### 2026-01-19 23:22 - Plan Creation

**Status**: Plan created, pending auto-review

**Summary**: Extracted from /00_plan conversation, requirements coverage verified (100%)

### 2026-01-19 23:25 - GPT Plan Reviewer Review (BLOCKING)

**Status**: REJECTED - 5 BLOCKING findings identified

**Summary**:
- Clarity: Medium (goal clear, mechanics underspecified)
- Verifiability: Medium-Low (tests listed but interactive/rollback undefined)
- Completeness: Medium-Low (missing migration strategy, non-interactive behavior)
- Big Picture: Medium (good safety intent, risk model conflicts)

**BLOCKING Findings**:
1. Flag semantics unclear (--apply vs --dry-run compatibility)
2. High-risk confirmation UX undefined (per-file vs per-batch)
3. Verification + rollback mechanics underspecified
4. Scope contradiction on risk logic
5. Non-interactive behavior undefined

### 2026-01-19 23:30 - GPT Architect Consultation (RESOLVED)

**Status**: All BLOCKING findings resolved with specific implementation recommendations

**Summary**: GPT Architect provided comprehensive solutions for all 5 BLOCKING findings

**Resolutions Applied**:
1. **Flag semantics**: Support both `--dry-run` and `--apply` (mutually exclusive), default auto-apply Low/Medium in interactive TTY
2. **High-risk confirmation UX**: Per-batch AskUserQuestion with 3 choices (Apply all, Skip, Review one-by-one)
3. **Verification + rollback**: Pre-flight safety checks, batch verification (N=10), rollback via git restore + trash restore
4. **Scope contradiction**: Reframed "risk logic" as "confirmation gating" (in-scope)
5. **Non-interactive behavior**: CI/non-TTY defaults to `--dry-run`-like behavior (exit code 2 if changes needed)

**Changes Made**:
- Updated Scope section (in-scope: confirmation gating, non-interactive behavior, verification+rollback)
- Updated Implementation Strategy with 4 detailed sections (Flag Semantics, High-Risk UX, Verification+Rollback, Non-Interactive)
- Updated Success Criteria (SC-1 through SC-10)
- Updated Test Plan (10 test scenarios)
- Updated Execution Plan (13 granular todos)
- Updated Acceptance Criteria (AC-1 through AC-10)
- Updated Risks & Mitigations with GPT Architect additional risks

**Effort Estimate**: Medium (~175 minutes / 2 hours 55 minutes)

**Ready for**: `/02_execute` implementation

---

## Execution History

### 2026-01-20 - Implementation Complete ✅

**Status**: ALL SUCCESS CRITERIA MET

**Implementation Summary**:
- **SC-1**: Auto-apply for Low/Medium risk items (interactive TTY default) ✅
- **SC-2**: Per-batch AskUserQuestion for High-risk with 3 choices ✅
- **SC-3**: `--dry-run` flag (never modifies, never prompts, prints plan) ✅
- **SC-4**: `--apply` flag (applies everything including High-risk, no prompts) ✅
- **SC-5**: Flag conflict detection (both --dry-run and --apply → error) ✅
- **SC-6**: `calculate_risk_level()` function with Low/Medium/High classification ✅
- **SC-7**: Pre-flight safety check (auto-block modified/staged files) ✅
- **SC-8**: Verification after each batch (N=10) and at end ✅
- **SC-9**: Rollback on verification failure (git restore + trash restore) ✅
- **SC-10**: Non-interactive detection (CI/non-TTY) with default --dry-run behavior ✅
- **SC-11**: Documentation updated (command description, argument hints, usage examples) ✅
- **SC-12**: Test scenarios written (10 tests covering all flag combinations and edge cases) ✅
- **SC-13**: All Success Criteria verified (SC-1 through SC-10) ✅

**Files Modified**:
- `.claude/commands/05_cleanup.md`: Complete rewrite with all SCs implemented

**Test Files Created** (10 tests, 52 assertions, 100% pass rate):
- `.pilot/tests/cleanup-auto.test.sh` (TS-1)
- `.pilot/tests/cleanup-confirm.test.sh` (TS-2)
- `.pilot/tests/cleanup-dryrun.test.sh` (TS-3)
- `.pilot/tests/cleanup-apply.test.sh` (TS-4)
- `.pilot/tests/cleanup-conflict.test.sh` (TS-5)
- `.pilot/tests/cleanup-verify.test.sh` (TS-6)
- `.pilot/tests/cleanup-rollback.test.sh` (TS-7)
- `.pilot/tests/cleanup-preflight.test.sh` (TS-8)
- `.pilot/tests/cleanup-ci.test.sh` (TS-9)
- `.pilot/tests/cleanup-ci-apply.test.sh` (TS-10)

**Verification Results**:
- All 10 Success Criteria verified PASS
- All 52 test assertions PASS
- Code quality assessment: No issues found

**Recommendation**: Ready for `/91_document` (auto-documentation) and `/03_close` (move plan to done)

---

**Ready for**: `/91_document` → `/03_close`
