# Worktree Close Flow Improvement

- Generated: 2026-01-17T06:31:16 | Work: worktree_close_flow_improvement
- Location: .pilot/plan/pending/20260117_063116_worktree_close_flow_improvement.md

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | Start | "워크트리 모드로 실행하고 종료할 때 매끄럽지 않은 느낌인데 전체 점검좀 해줘" | Worktree close flow review |
| UR-2 | Start | "plan 을 3개 쌓아놓고 동시에 워크트리 3개를 생성해서 작업" | Multi-worktree concurrent execution |
| UR-3 | Added | "execute 커맨드도 같이 봐줘... close 의 저런 문제가 execute 에서 시작할 때 부터 생긴 오류" | Execute → Close integration issues |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-5, SC-6, SC-7 | Mapped |
| UR-2 | ✅ | SC-1, SC-4 | Mapped |
| UR-3 | ✅ | SC-2, SC-3, SC-4 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix worktree mode `/02_execute` and `/03_close` flow to handle multi-worktree concurrent execution smoothly, accounting for Claude Code's Bash environment where cwd resets to project root on each call.

**Scope**:
- **In scope**:
  - `worktree-utils.sh` - metadata storage/parsing, cleanup logic, path handling
  - `02_execute.md` - active pointer storage location/timing
  - `03_close.md` - close flow context restoration, worktree handling
  - Active pointer system (`.pilot/plan/active/`)
  - Lock file management (`.pilot/plan/.locks/`)
- **Out of scope**:
  - Plan file format changes (beyond metadata section)
  - New command creation
  - `/00_plan` or `/01_confirm` changes

### Why (Context)

**Current Problem**:
1. Claude Code Bash environment resets cwd to project root on each call
2. `/02_execute --wt` stores active pointer using worktree branch key (after cd to worktree)
3. `/03_close` runs from main project (due to cwd reset), looks for main branch key
4. Active pointer mismatch: stored as `feature_xxx.txt`, searched as `main.txt`
5. Worktree path stored as relative path (`../xxx`), breaks when cwd differs
6. `read_worktree_metadata()` uses `grep -A1` which fails for multi-line sections
7. `cleanup_worktree()` lacks `--force` option for dirty worktrees
8. No fallback when squash merge fails

**Root Cause**: Design assumed Bash session state persists between Claude tool calls, but it doesn't.

**Desired State**:
- `/03_close` works regardless of Bash cwd (reads context from plan file)
- Active pointers accessible from both main and worktree branch keys
- All paths stored as absolute paths
- Reliable metadata parsing
- Graceful handling of edge cases (dirty worktree, merge conflicts)

**Business Value**:
- Developer experience: No manual cleanup required
- Reliability: Multi-worktree concurrent execution works smoothly
- Git history: Proper squash merge instead of file copying

### How (Approach)

- **Phase 1**: Fix `worktree-utils.sh` - absolute paths, improved parsing
- **Phase 2**: Fix `02_execute.md` - dual active pointer storage
- **Phase 3**: Fix `03_close.md` - context restoration from plan file
- **Phase 4**: Add fallback strategies and improved error handling
- **Phase 5**: Testing and verification

### Success Criteria

```
SC-1: Close flow works regardless of Bash cwd
- Verify: Run /03_close after worktree work completes
- Expected: Correctly finds plan via metadata, performs cleanup

SC-2: Worktree path stored as absolute path
- Verify: Check plan file Worktree Info section after /02_execute --wt
- Expected: /absolute/path/to/worktree format (not ../relative)

SC-3: Main project path stored in metadata
- Verify: Check plan file Worktree Info section
- Expected: Main Project field with absolute path

SC-4: Active pointer accessible from both branches
- Verify: Check .pilot/plan/active/ after /02_execute --wt
- Expected: Both main.txt and feature_xxx.txt exist with same content

SC-5: Metadata parsing works reliably
- Verify: read_worktree_metadata returns all fields for valid plan
- Expected: All fields extracted correctly (branch, wt_path, main_branch, main_project)

SC-6: Worktree cleanup handles dirty state
- Verify: Run /03_close with uncommitted files in worktree
- Expected: Force removes worktree without manual intervention

SC-7: Lock files cleaned up properly
- Verify: Check .pilot/plan/.locks/ after /03_close
- Expected: No orphaned lock files for completed plans
```

### Constraints

- Must maintain backward compatibility with existing plans
- Lock mechanism must remain atomic (mkdir-based)
- Git history must be preserved (no force push)
- Changes should be minimal and focused

---

## Scope

### In Scope

| Item | Description |
|------|-------------|
| `worktree-utils.sh` | Fix path handling, metadata parsing, cleanup |
| `02_execute.md` | Fix active pointer storage timing/location |
| `03_close.md` | Add context restoration from plan metadata |
| Active pointer system | Dual-key storage (main + worktree branch) |

### Out of Scope

| Item | Reason |
|------|--------|
| Plan file format | Keep existing structure, only add fields to Worktree Info |
| New commands | Not needed for this fix |
| 00_plan, 01_confirm | Not related to worktree flow |

---

## Test Environment (Detected)

- **Project Type**: Bash/Shell scripts + Python
- **Test Framework**: Manual testing (shell scripts), pytest (Python)
- **Test Command**: `bash .claude/scripts/test-*.sh`, `pytest`
- **Coverage Command**: `pytest --cov`
- **Test Directory**: `tests/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/scripts/worktree-utils.sh` | Core worktree utilities | L65-88 (create), L92-111 (metadata), L116-146 (detect/read), L233-264 (cleanup) | 288 lines total |
| `.claude/commands/02_execute.md` | Execute command | L49-111 (worktree mode), L106-110 (active pointer) | Pointer stored after cd |
| `.claude/commands/03_close.md` | Close command | L28-68 (worktree context), L72-88 (plan detection) | Relies on is_in_worktree |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Store active pointer before cd to worktree | Ensures main branch key is used | Store both keys (chosen) |
| Use absolute paths for all worktree metadata | Cwd-independent resolution | Keep relative (rejected) |
| Add Main Project field to metadata | Context restoration needs main path | Derive from worktree (fragile) |
| Don't rely on is_in_worktree() in close | Bash cwd always main project | Keep current design (rejected) |

### Implementation Patterns (FROM CONVERSATION)

#### Absolute Path Conversion
```bash
# create_worktree 수정
create_worktree() {
    # ...
    worktree_dir="$(cd "$worktree_dir" && pwd)"  # 절대 경로로 변환
    printf "%s" "$worktree_dir"
}
```

#### Dual Active Pointer Storage
```bash
# 02_execute: BEFORE cd to worktree
MAIN_KEY="$(printf "%s" "$MAIN_BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${MAIN_KEY}.txt"

# ALSO store with worktree branch key
WT_KEY="$(printf "%s" "$BRANCH_NAME" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${WT_KEY}.txt"
```

#### Context Restoration in Close
```bash
# Step 1.5: Worktree Context 복원
if grep -q "## Worktree Info" "$PLAN_PATH"; then
    WT_PATH="$(grep 'Worktree Path:' "$PLAN_PATH" | sed 's/.*: //')"
    MAIN_PROJECT="$(grep 'Main Project:' "$PLAN_PATH" | sed 's/.*: //')"

    if [ -d "$WT_PATH" ]; then
        cd "$WT_PATH"
        # ... squash merge, cleanup
    fi
fi
```

#### Updated Metadata Format
```markdown
## Worktree Info

- Branch: feature/20260117-xxx
- Worktree Path: /absolute/path/to/worktree
- Main Branch: main
- Main Project: /absolute/path/to/main/project
- Lock File: /absolute/path/to/.locks/xxx.lock
- Created At: 2026-01-17T06:31:16
```

---

## Architecture

### Current Flow (Problematic)

```
/02_execute --wt
    ↓
create_worktree → branch "feature/xxx"
    ↓
cd "$WORKTREE_DIR" → now in worktree
    ↓
git rev-parse --abbrev-ref HEAD → "feature/xxx" (worktree branch!)
    ↓
Active pointer: .pilot/plan/active/feature_xxx.txt
    ↓
[Bash session ends, cwd state lost]

/03_close (new Bash session)
    ↓
pwd → /main/project (cwd reset!)
    ↓
is_in_worktree → false (because we're in main)
    ↓
Branch: "main", looks for: .pilot/plan/active/main.txt
    ↓
NOT FOUND! ❌
```

### Proposed Flow (Fixed)

```
/02_execute --wt
    ↓
create_worktree → branch "feature/xxx", absolute path
    ↓
BEFORE cd: Store active pointer with MAIN branch key
    ↓
ALSO: Store active pointer with WORKTREE branch key
    ↓
cd "$WORKTREE_DIR"
    ↓
Add metadata to plan (all absolute paths)
    ↓
[Bash session ends]

/03_close (new Bash session)
    ↓
pwd → /main/project (cwd reset - OK!)
    ↓
Find plan via active pointer (main.txt exists now!)
    ↓
Read Worktree Info from plan file
    ↓
If worktree exists: cd to worktree, squash merge
    ↓
Cleanup: worktree remove --force, branch delete, lock remove
    ↓
Move plan to done, clear BOTH pointers
```

### Module Changes

| Module | Current | Proposed |
|--------|---------|----------|
| `create_worktree()` | Returns relative path | Returns absolute path |
| `add_worktree_metadata()` | 3 fields | 5 fields (+ Main Project, Lock File) |
| `read_worktree_metadata()` | grep -A1 (broken) | Multi-line extraction |
| `cleanup_worktree()` | No --force | Try normal, then --force |
| `02_execute` L106-110 | Store after cd | Store BEFORE cd, dual keys |
| `03_close` Step 1 | Relies on is_in_worktree | Read context from plan file |

---

## Vibe Coding Compliance

| Target | Current | After Change |
|--------|---------|--------------|
| `worktree-utils.sh` | 288 lines | ~320 lines (under 400) |
| `02_execute.md` | 825 lines | ~835 lines (documentation) |
| `03_close.md` | 465 lines | ~490 lines (documentation) |
| Functions | ≤50 lines each | ✅ Maintained |
| Nesting | ≤3 levels | ✅ Maintained |

---

## Execution Plan

| Step | Task | Files | Dependency |
|------|------|-------|------------|
| 1 | Fix `create_worktree()` to return absolute path | `worktree-utils.sh` | None |
| 2 | Update `add_worktree_metadata()` with new fields | `worktree-utils.sh` | Step 1 |
| 3 | Fix `read_worktree_metadata()` parsing | `worktree-utils.sh` | Step 2 |
| 4 | Add `--force` to `cleanup_worktree()` | `worktree-utils.sh` | Step 3 |
| 5 | Move active pointer storage BEFORE cd in `02_execute` | `02_execute.md` | Step 4 |
| 6 | Add dual-key active pointer storage | `02_execute.md` | Step 5 |
| 7 | Refactor `03_close` to read context from plan file | `03_close.md` | Step 6 |
| 8 | Add squash merge fallback strategy | `03_close.md` | Step 7 |
| 9 | Integration testing | Manual | Step 8 |

---

## Acceptance Criteria

- [ ] AC-1: `/03_close` succeeds when run after worktree work (regardless of terminal)
- [ ] AC-2: Multi-worktree (3 concurrent) close flow completes without errors
- [ ] AC-3: Active pointer found from both main and worktree branch
- [ ] AC-4: All paths in Worktree Info section are absolute
- [ ] AC-5: Dirty worktrees (uncommitted files) cleaned up automatically
- [ ] AC-6: Lock files removed after close
- [ ] AC-7: Git history shows proper squash merge commits

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Single worktree execute+close | /02_execute --wt, work, /03_close | Plan in done/, worktree removed | Integration |
| TS-2 | Multi-worktree concurrent | 3x /02_execute --wt, work, 3x /03_close | All 3 plans closed correctly | Integration |
| TS-3 | Close with dirty worktree | /03_close with uncommitted files | Force removes worktree | Integration |
| TS-4 | Active pointer dual-key | Check .pilot/plan/active/ after execute | Both main.txt and feature_xxx.txt | Unit |
| TS-5 | Metadata parsing | read_worktree_metadata on plan with 5 fields | All 5 fields returned | Unit |
| TS-6 | Squash merge failure fallback | Simulate merge conflict | Graceful error message | Integration |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing workflows | Medium | High | Backward-compat: keep old functions, add new |
| Path resolution edge cases | Medium | Medium | Use absolute paths everywhere, test edge cases |
| Lock cleanup race condition | Low | Medium | Keep mkdir-based atomic lock |
| Dual pointer cleanup missed | Low | Low | Clear both pointers in close |

---

## Open Questions

1. **Squash merge fallback**: If squash merge fails, should we:
   - A) Copy files and commit (current manual workaround)
   - B) Ask user for guidance
   - C) Abort and leave worktree for manual resolution
   - **Recommendation**: Option B - AskUserQuestion with options

2. **Orphaned worktree detection**: Should we add a cleanup command for orphaned worktrees?
   - **Recommendation**: Out of scope for this fix, consider for future

---

## References

- User logs from `/03_close` execution showing errors
- Git worktree best practices research
- Claude Code Bash environment behavior analysis

## Worktree Metadata
- Branch: 063116-worktree-close-flow-improvement
- Worktree: /Users/chanho/claude-pilot/../worktree-063116-worktree-close-flow-improvement
- Base Branch: main
