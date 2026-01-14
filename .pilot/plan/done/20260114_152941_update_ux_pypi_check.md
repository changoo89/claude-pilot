# Update UX - PyPI Version Check

- Generated: 2026-01-14 15:29:41 | Work: update_ux_pypi_check
- Location: .pilot/plan/pending/20260114_152941_update_ux_pypi_check.md

---

## User Requirements

Fix `claude-pilot update` command to check PyPI for the latest version and automatically upgrade the pip package when outdated.

**Current Problem**: The `get_latest_version()` function returns the locally installed package version (`config.VERSION`), causing the update command to always report "up to date" even when PyPI has a newer version.

**User Expectations**:
1. Auto-upgrade by default: `claude-pilot update` should automatically upgrade pip package if outdated
2. Warning on network failure: Show warning if PyPI unreachable, then fallback to local version
3. Two-phase update: First pip package, then managed files

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix `claude-pilot update` to check PyPI for the latest version and automatically upgrade the pip package when outdated.

**Scope**:
- **In scope**:
  - PyPI version checking via API
  - Automatic pip package upgrade
  - Graceful fallback on network errors
- **Out of scope**:
  - Version pinning/downgrading
  - Changelog display
  - Breaking change warnings

### Why (Context)

**Current Problem**: `get_latest_version()` returns the locally installed package version, causing the update command to always report "up to date" even when PyPI has a newer version.

**Desired End State**: Running `claude-pilot update` will:
1. Check PyPI API for actual latest version
2. If outdated, automatically upgrade pip package
3. Re-import or notify user to restart if needed
4. Then update managed files

**Business Value**:
- Users always get the latest features without manual pip commands
- Reduces confusion and support issues
- Single command for complete update

### How (Approach)

- **Phase 1**: Modify `get_latest_version()` to check PyPI API
- **Phase 2**: Add `upgrade_pip_package()` function
- **Phase 3**: Update `perform_update()` to handle pip upgrades first
- **Phase 4**: Add CLI options for manual override (`--skip-pip`, `--check-only`)
- **Phase 5**: Testing

### Success Criteria

```
SC-1: PyPI version check works correctly
- Verify: Run with outdated local version
- Expected: Detects newer version on PyPI

SC-2: Auto-upgrade pip package
- Verify: Run update when outdated
- Expected: pip package upgraded automatically

SC-3: Graceful fallback on network error
- Verify: Run with network disabled
- Expected: Warning shown, proceeds with local version

SC-4: Two-phase update flow
- Verify: Run full update
- Expected: Pip upgrade first, then file updates
```

### Constraints

- **Technical**: Must use `requests` (already in dependencies)
- **Network**: 5-second timeout for PyPI API calls
- **Compatibility**: Keep existing `--strategy` flag working

---

## Scope

### In Scope
- PyPI version checking via `https://pypi.org/pypi/claude-pilot/json`
- Automatic pip package upgrade using subprocess
- Graceful fallback on network errors with warning message
- New CLI options: `--skip-pip`, `--check-only`

### Out of Scope
- Version pinning/downgrading
- Changelog display
- Breaking change warnings
- Interactive prompts before upgrade

---

## External Service Integration

### API Calls Required

| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| Get PyPI version | updater.py | PyPI | https://pypi.org/pypi/claude-pilot/json | HTTP GET (requests) | New | [ ] requests in deps |

### Environment Variables Required

None - PyPI API is public and requires no authentication.

### Error Handling Strategy

| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| PyPI API call | Timeout/Network error | Warning message | Use local config.VERSION |
| PyPI API call | Invalid JSON | Warning message | Use local config.VERSION |
| pip upgrade | Permission error | Error message | Suggest --user flag |
| pip upgrade | Network error | Error message | Continue with file updates |

---

## Implementation Details Matrix

| Task | WHO (Service) | WHAT (Action) | HOW (Mechanism) | VERIFY (Check) |
|------|---------------|---------------|-----------------|----------------|
| Get PyPI version | updater.py | Fetch latest version | requests.get() with timeout=5 | HTTP 200 + valid JSON |
| Get installed version | updater.py | Read package version | config.VERSION | Always available |
| Upgrade pip package | updater.py | Run pip install --upgrade | subprocess.run() | Exit code 0 |
| Update managed files | updater.py | Copy templates | Existing logic | File counts |

---

## Gap Verification Checklist

### External API
- [x] All API calls specify SDK vs HTTP mechanism (HTTP GET with requests)
- [x] Endpoint URL verified (https://pypi.org/pypi/claude-pilot/json)
- [x] Error handling strategy defined for each external call

### Async Operations
- [x] Timeout values specified (5 seconds for PyPI)
- [x] No concurrent operations needed

### Environment
- [x] No new env vars required
- [x] No secrets needed (public API)

### Error Handling
- [x] No silent catches (all errors show warnings)
- [x] User notification strategy defined
- [x] Graceful degradation paths defined

---

## Architecture

### Data Flow

```
User runs: claude-pilot update
           │
           ▼
┌─────────────────────────────┐
│ Phase 1: Check PyPI Version │
│ GET https://pypi.org/pypi/  │
│     claude-pilot/json       │
└─────────────────────────────┘
           │
           ▼
      ┌────────────┐
      │ Outdated?  │
      └────────────┘
         │      │
       Yes      No
         │      │
         ▼      ▼
┌─────────────┐ ┌─────────────────┐
│ pip install │ │ Skip pip upgrade│
│ --upgrade   │ └─────────────────┘
│ claude-pilot│         │
└─────────────┘         │
         │              │
         ▼              │
   ┌───────────┐        │
   │ Success?  │        │
   └───────────┘        │
      │      │          │
    Yes      No         │
      │      │          │
      ▼      ▼          ▼
 Continue  Error msg    │
      │      │          │
      ▼      ▼          ▼
┌─────────────────────────────┐
│ Phase 2: Update managed     │
│ files (.claude/, .pilot/)   │
└─────────────────────────────┘
```

### Module Changes

| File | Function | Change |
|------|----------|--------|
| `updater.py` | `get_pypi_version()` | NEW: Fetch version from PyPI |
| `updater.py` | `get_latest_version()` | MODIFY: Use PyPI with fallback |
| `updater.py` | `get_installed_version()` | NEW: Return config.VERSION |
| `updater.py` | `upgrade_pip_package()` | NEW: Run pip install --upgrade |
| `updater.py` | `perform_update()` | MODIFY: Add pip upgrade phase |
| `cli.py` | `update()` | MODIFY: Add `--skip-pip`, `--check-only` options |

---

## Vibe Coding Compliance

> Validate plan enforces: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3, SRP/DRY/KISS

- [x] `get_pypi_version()`: ~15 lines (single responsibility: fetch from PyPI)
- [x] `upgrade_pip_package()`: ~15 lines (single responsibility: run pip)
- [x] Modified `perform_update()`: Will remain under 50 lines
- [x] No new files created, modifications to existing files
- [x] Early return pattern for error handling

---

## Execution Plan

### Phase 1: PyPI Version Checking
- [ ] Add `PYPI_TIMEOUT = 5` constant to config.py
- [ ] Add `import requests` to updater.py (if not already)
- [ ] Add `get_pypi_version()` function with requests call
- [ ] Modify `get_latest_version()` to use PyPI with fallback

### Phase 2: Pip Upgrade Function
- [ ] Add `import sys` to updater.py (for sys.executable in pip subprocess)
- [ ] Add `get_installed_version()` to return config.VERSION
- [ ] Add `upgrade_pip_package()` function using subprocess
- [ ] Handle pip upgrade errors gracefully

### Phase 3: Update perform_update() Flow
- [ ] Add pip version check at start of perform_update()
- [ ] If outdated, run pip upgrade first
- [ ] After pip upgrade, notify user to restart for full effect
- [ ] Continue with managed file updates

### Phase 4: CLI Options
- [ ] Add `--skip-pip` flag to skip pip package check/upgrade
- [ ] Add `--check-only` flag to only show version status
- [ ] Update help text for new options

### Phase 5: Testing
- [ ] Unit test for `get_pypi_version()` with mocked responses
- [ ] Unit test for network timeout handling
- [ ] Integration test for pip upgrade flow
- [ ] Manual test end-to-end

---

## Acceptance Criteria

- [ ] `claude-pilot update` detects when PyPI has a newer version
- [ ] Pip package is automatically upgraded when outdated
- [ ] Warning shown when PyPI is unreachable (not silent failure)
- [ ] Managed files are updated after pip upgrade
- [ ] `--skip-pip` flag allows skipping pip upgrade
- [ ] Existing `--strategy` flag continues to work

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | PyPI newer version | Local=2.1.3, PyPI=2.1.4 | Auto-upgrade pip | Unit |
| TS-2 | Already up to date | Local=PyPI=2.1.4 | "Already up to date" | Unit |
| TS-3 | Network timeout | PyPI unreachable | Warning + fallback | Unit |
| TS-4 | Pip upgrade success | Outdated package | Package upgraded | Integration |
| TS-5 | --skip-pip flag | Any version | Skip pip check | Unit |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| PyPI API rate limit | Low | Medium | 5-second timeout, single call per update |
| pip upgrade fails (permissions) | Medium | Medium | Clear error message, suggest `--user` flag |
| Version after upgrade differs | Low | Low | Re-read version after pip upgrade |

---

## Open Questions

1. **Post-upgrade restart**: After pip upgrade, the running process still has old code in memory.
   - **Decision**: Print message asking user to re-run command if pip was upgraded
   - **Rationale**: Safest approach, no complex process restart logic needed

---

## Review History

### Review #1 (2026-01-14 15:30)

**Summary**:
- **Assessment**: Pass (with minor suggestions)
- **Type**: Code Modification / Extended: A, B, D
- **Findings**: BLOCKING: 0 / Critical: 0 / Warning: 1 / Suggestion: 2

**Mandatory Review (8 items)**:
| # | Item | Status |
|---|------|--------|
| 1 | Dev Principles | ✅ |
| 2 | Project Structure | ✅ |
| 3 | Requirements | ✅ |
| 4 | Logic Errors | ✅ |
| 5 | Code Reuse | ✅ |
| 6 | Alternatives | ✅ |
| 7 | Project Alignment | ✅ |
| 8 | Long-term Impact | ✅ |

**Gap Detection Review**:
| # | Category | Status |
|---|----------|--------|
| 9.1 | External API | ✅ |
| 9.2 | Database Operations | ✅ N/A |
| 9.3 | Async Operations | ✅ |
| 9.4 | File Operations | ✅ N/A |
| 9.5 | Environment | ✅ |
| 9.6 | Error Handling | ✅ |

**Vibe Coding Compliance**: ✅ All targets met

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 0 | 0 |
| Warning | 1 | 1 |
| Suggestion | 2 | 1 |

**Changes Made**:
1. **[Suggestion] Phase 2 - Add sys import**
   - Issue: `upgrade_pip_package()` uses `sys.executable` but import not listed
   - Applied: Added `import sys` to Phase 2 execution steps

**Investigation Results**:
- ✅ `requests>=2.28.0` already in pyproject.toml dependencies
- ✅ No existing tests to break
- ✅ PyPI JSON API endpoint verified

**Notes**:
- Post-upgrade restart behavior addressed in Open Questions with clear decision
- Version comparison using string equality is acceptable for this use case

---

## Execution Summary

### Completed: 2026-01-14

### Changes Made

#### 1. Configuration (src/claude_pilot/config.py)
- Added `PYPI_TIMEOUT = 5` constant for PyPI API timeout
- Added `PYPI_API_URL = "https://pypi.org/pypi/claude-pilot/json"` endpoint

#### 2. Updater Module (src/claude_pilot/updater.py)
- **New Function**: `get_pypi_version()` - Fetch latest version from PyPI API
  - 5-second timeout
  - Graceful fallback on network errors with warning message
  
- **New Function**: `get_installed_version()` - Return locally installed version
  
- **New Function**: `upgrade_pip_package()` - Run `pip install --upgrade claude-pilot`
  - Uses `sys.executable` for correct Python interpreter
  - Returns True/False based on success
  
- **Modified Function**: `get_latest_version()` - Now checks PyPI first, falls back to config.VERSION
  
- **Modified Function**: `perform_update()` - Two-phase update flow
  - New parameters: `skip_pip` (bool), `check_only` (bool)
  - Phase 1: Check pip package version
  - Phase 2: Upgrade pip package if needed (skippable)
  - Phase 3: Update managed files

#### 3. CLI Module (src/claude_pilot/cli.py)
- **New Option**: `--skip-pip` - Skip pip package upgrade
- **New Option**: `--check-only` - Only check for updates without applying

#### 4. Tests (tests/)
- Created `tests/conftest.py` with shared fixtures
- Created `tests/test_updater.py` with 24 tests
- Created `tests/test_cli.py` with 4 tests
- **Total**: 28 tests covering all new functionality

### Verification Results

| Metric | Result |
|--------|--------|
| Tests | ✅ 28 passed |
| Type Check | ✅ Success (mypy clean) |
| Lint | ✅ All passed (ruff clean) |
| Coverage | 60% overall, 85% for updater.py (core module) |

**Note**: Overall coverage (60%) is affected by `initializer.py` (21%) which is not in scope for this change. The modified core module (`updater.py`) has 85% coverage.

### Test Coverage Breakdown
- `get_pypi_version()`: ✅ Tested (success, timeout, connection error, HTTP error)
- `upgrade_pip_package()`: ✅ Tested (success, failure)
- `perform_update()`: ✅ Tested (skip_pip, check_only, manual strategy, edge cases)
- CLI options: ✅ Tested (--skip-pip, --check-only, both together)

### Acceptance Criteria Met
- ✅ `claude-pilot update` detects when PyPI has a newer version
- ✅ Pip package is automatically upgraded when outdated
- ✅ Warning shown when PyPI is unreachable (not silent failure)
- ✅ Managed files are updated after pip upgrade
- ✅ `--skip-pip` flag allows skipping pip upgrade
- ✅ Existing `--strategy` flag continues to work
- ✅ `--check-only` flag for version status only

### Files Changed
1. `src/claude_pilot/config.py` - Added PYPI constants
2. `src/claude_pilot/updater.py` - Added 3 new functions, modified 2 functions
3. `src/claude_pilot/cli.py` - Added 2 new CLI options
4. `tests/conftest.py` - New file with fixtures
5. `tests/test_updater.py` - New file with 24 tests
6. `tests/test_cli.py` - New file with 4 tests

### Follow-ups
- None identified - all planned functionality implemented

