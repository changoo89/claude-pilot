# 03_close Git Push Enhancement

- Generated: 2026-01-16 09:03:42
- Work: 03_close_git_push_enhancement
- Location: .pilot/plan/pending/20260116_090342_03_close_git_push_enhancement.md

---

## User Requirements

1. **branch-guard.sh improvement**: Remove interactive prompts (verified: already non-interactive)
2. **Update deployment verification**: Verify settings.json hook paths work correctly during plugin update
3. **Add git push to 03_close**: Push changes to remote when in a git project

---

## PRP Analysis

### What (Functionality)

**Objective**: Add safe git push functionality to 03_close command and remove interactive prompts

**Scope**:
- **In scope**:
  - Add git push step to 03_close.md
  - Remove `read -r` interactive prompt from 03_close.md (Line 211)
  - Implement safe-git-push logic with dry-run verification
- **Out of scope**:
  - branch-guard.sh modification (already non-interactive)
  - updater.py modification (already robust with apply_hooks())
  - settings.json protection (already in USER_FILES)

### Why (Context)

**Current Problem**:
- 03_close creates commits but doesn't push to remote → changes trapped in local repo
- 03_close.md Line 211 has `read -r` interactive prompt → blocks automation environments

**Desired State**:
- 03_close automatically pushes to remote after commit
- Non-interactive execution for CI/CD compatibility
- Safe push with dry-run verification

**Business Value**:
- Eliminates manual push after work completion
- Supports automated workflows

### How (Approach)

- **Phase 1**: Analyze 03_close.md and identify modification points
- **Phase 2**: Design safe git push logic
- **Phase 3**: Modify 03_close.md (apply changes)
- **Phase 4**: Verification (manual testing)
- **Phase 5**: Documentation update

### Success Criteria

```
SC-1: Remove interactive prompt from 03_close.md
- Verify: grep "read -r" .claude/commands/03_close.md
- Expected: No matches (interactive prompts removed)

SC-2: Add safe git push step to 03_close.md
- Verify: grep "git push" .claude/commands/03_close.md
- Expected: Push step present with safety checks

SC-3: Add git repository detection logic
- Verify: grep "git rev-parse" .claude/commands/03_close.md
- Expected: Git repo detection before push operations
```

### Constraints

- Must not break existing commit functionality
- Must handle non-git directories gracefully
- Must handle repos without remote gracefully
- No force push support (safety first)

---

## Scope

### In Scope
| Item | Description |
|------|-------------|
| 03_close.md | Add git push step, remove interactive prompt |
| Safe push logic | dry-run verification, remote check, branch detection |
| Git detection | Check if directory is git repo before git operations |

### Out of Scope
| Item | Reason |
|------|--------|
| branch-guard.sh | Already non-interactive, no changes needed |
| updater.py | Already handles settings.json robustly |
| settings.json | Protected in USER_FILES, no changes needed |

---

## Test Environment (Detected)

- Project Type: Python (pyproject.toml detected)
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`

Note: 03_close.md is a markdown command file, not code. Testing will be manual verification.

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/scripts/hooks/branch-guard.sh` | Protected branch guard | 51 lines | Already non-interactive |
| `src/claude_pilot/updater.py` | Update mechanism | Lines 699-752 | apply_hooks() robust |
| `src/claude_pilot/config.py` | USER_FILES config | Lines 84-90 | settings.json protected |
| `.claude/commands/03_close.md` | Close command | 267 lines | Line 211 has read -r |
| `.claude/skills/git-master/REFERENCE.md` | Git push patterns | Lines 168-254 | Reference for patterns |

### Research Findings

| Source | Topic | Key Insight |
|--------|-------|-------------|
| Claude Code Hooks Docs | Non-interactive hooks | Exit code 2 = BLOCK, hooks must be non-interactive |
| Git Automation Best Practices | Safe push pattern | dry-run → actual push pattern recommended |
| Settings Path Resolution | $CLAUDE_PROJECT_DIR | Use Claude Code provided env var |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Remove read -r entirely | Non-interactive is required | Could use timeout but adds complexity |
| Use dry-run before push | Safety verification | Could skip but risks failed pushes |
| Skip push if no remote | Graceful degradation | Could error but breaks non-remote repos |
| No force push | Safety first | Could add --force flag but too risky |

### Implementation Patterns (FROM CONVERSATION)

#### Architecture Diagram
> **FROM CONVERSATION:**
> ```
> ┌─────────────────────────────────────────────────────────────┐
> │                    03_close Git Push Flow                   │
> ├─────────────────────────────────────────────────────────────┤
> │                                                             │
> │  Step 1: Git Repo Detection                                │
> │  ├─ git rev-parse --git-dir                                │
> │  └─ If not git repo → Skip all git steps                   │
> │                                                             │
> │  Step 2: Remote Existence Check                            │
> │  ├─ git config --get remote.origin.url                     │
> │  └─ If no remote → Skip push, log warning                  │
> │                                                             │
> │  Step 3: Uncommitted Changes Check                         │
> │  ├─ git diff-index --quiet HEAD --                         │
> │  └─ If changes → Abort push, log error                     │
> │                                                             │
> │  Step 4: Dry-Run Verification                              │
> │  ├─ git push --dry-run origin $(git branch --show-current) │
> │  └─ If fail → Abort push, log error                        │
> │                                                             │
> │  Step 5: Actual Push                                       │
> │  ├─ git push origin $(git branch --show-current)           │
> │  └─ Log success/failure                                    │
> │                                                             │
> └─────────────────────────────────────────────────────────────┘
> ```

#### Code Example - Safe Git Push Script
> **FROM CONVERSATION:**
> ```bash
> #!/bin/bash
> set -euo pipefail
>
> # Safe git push hook for 03_close command
> BRANCH=$(git branch --show-current 2>/dev/null || echo "")
> [[ -z "$BRANCH" ]] && exit 1
>
> # Check uncommitted changes
> if ! git diff-index --quiet HEAD --; then
>     echo "[SAFE-PUSH] ERROR: Uncommitted changes present" >&2
>     exit 1
> fi
>
> # Check remote exists
> if ! git config --get remote.origin.url >/dev/null 2>&1; then
>     echo "[SAFE-PUSH] ERROR: No remote configured" >&2
>     exit 1
> fi
>
> # Dry run verification
> if ! git push --dry-run origin "$BRANCH" 2>/dev/null; then
>     echo "[SAFE-PUSH] ERROR: Push would fail - check permissions/network" >&2
>     exit 1
> fi
>
> # Actual push
> if git push origin "$BRANCH"; then
>     echo "[SAFE-PUSH] SUCCESS: Pushed to $BRANCH"
>     exit 0
> else
>     echo "[SAFE-PUSH] ERROR: Push failed" >&2
>     exit 1
> fi
> ```

---

## Architecture

### Safe Git Push Flow

```
[03_close command]
       │
       ▼
┌──────────────────┐
│ Git Repo Check   │──No──▶ Skip git operations
└────────┬─────────┘
         │Yes
         ▼
┌──────────────────┐
│ Remote Check     │──No──▶ Log warning, skip push
└────────┬─────────┘
         │Yes
         ▼
┌──────────────────┐
│ Uncommitted?     │──Yes─▶ Log error, skip push
└────────┬─────────┘
         │No
         ▼
┌──────────────────┐
│ Dry-run Push     │──Fail─▶ Log error, skip push
└────────┬─────────┘
         │Success
         ▼
┌──────────────────┐
│ Actual Push      │──▶ Log result
└──────────────────┘
```

### Integration Points

- **Location**: Add after existing commit step in 03_close.md
- **Dependencies**: git CLI availability
- **Environment Variables**: None (uses git defaults)

---

## Vibe Coding Compliance

| Metric | Target | Expected |
|--------|--------|----------|
| Function length | ≤50 lines | N/A (markdown command) |
| File length | ≤200 lines | 03_close.md ~280 lines (acceptable for command) |
| Nesting depth | ≤3 levels | Will maintain |

---

## Execution Plan

### Phase 1: Analysis (Read-only)
1. Read current 03_close.md structure
2. Identify exact line for read -r removal
3. Identify insertion point for git push

### Phase 2: Implementation
1. Remove/replace read -r interactive prompt (Line 211)
2. Add git repo detection step
3. Add remote existence check
4. Add dry-run verification
5. Add actual push step

### Phase 3: Verification
1. Manual test: Git repo with remote
2. Manual test: Git repo without remote
3. Manual test: Non-git directory

---

## Acceptance Criteria

- [ ] AC-1: `grep "read -r" .claude/commands/03_close.md` returns no matches
- [ ] AC-2: `grep "git push" .claude/commands/03_close.md` returns matches
- [ ] AC-3: `grep "git rev-parse" .claude/commands/03_close.md` returns matches
- [ ] AC-4: Git push step includes dry-run verification
- [ ] AC-5: Non-git directories handled gracefully

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test Method |
|----|----------|-------|----------|------|-------------|
| TS-1 | Git repo with remote | Normal git repo | Commit + push success | Manual | Run 03_close in test repo |
| TS-2 | Git repo without remote | Repo without origin | Push skipped, warning logged | Manual | Run 03_close in local-only repo |
| TS-3 | Non-git directory | Folder without .git | All git steps skipped | Manual | Run 03_close in non-git folder |
| TS-4 | Protected branch | On main branch | Warning logged, continues | Manual | Run 03_close on main |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Push failure (permissions) | Medium | Medium | dry-run verification before actual push |
| Protected branch push | Low | High | branch-guard warning maintained |
| Remote not configured | Low | Low | Check remote, graceful skip |
| Network issues | Low | Medium | dry-run catches before actual push |

---

## Open Questions

1. **Push failure behavior**: Log error and continue vs abort?
   - **Decision**: Log error and continue (commit already complete)

2. **Force push support**: Add --force flag?
   - **Decision**: No (safety first, not supported)

3. **Multiple remotes**: Which remote to push to?
   - **Decision**: Use "origin" as default (standard convention)

---

## Execution Summary

### Changes Made
- **SC-1**: Removed interactive prompt (`read -r`) from Line 211 - replaced with environment variable-based external repo specification
- **SC-2**: Added safe git push step with dry-run verification, remote check, and graceful degradation
- **SC-3**: Added git repository detection logic before all push operations

### Verification
- **Type**: Command file enhancement (no type check required)
- **Tests**: Manual verification completed
  - Git repo detection: Verified
  - Remote existence check: Verified
  - Dry-run verification: Verified
  - Graceful degradation (no remote/non-git): Verified
- **Lint**: N/A (markdown file)

### Files Modified
- `.claude/commands/03_close.md`: Added safe git push step (89 new lines), removed interactive prompt (11 lines replaced)

### Documentation Updates
- `.claude/commands/CONTEXT.md`: Updated line count (236 → 325), description includes "safe git push"
- Plan file: Added execution summary

### Follow-ups
- None (implementation complete)

---

## Status

- [x] Plan created
- [x] Implementation completed
- [x] Documentation updated
- [x] Archived to done
