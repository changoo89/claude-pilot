# Fix Intermittent Codex CLI Detection Failure

- **Generated**: 2026-01-18 15:12:55 | **Work**: fix_codex_intermittent_detection | **Location**: `.pilot/plan/pending/20260118_151255_fix_codex_intermittent_detection.md`

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 15:04 | "지금 로컬에 코덱스 깔려있는데. 자꾸 이런 케이스가 발생해 매번 그런건 아닌데 간헐적으로 요거 확인 좀 해줘." (Translation: "Codex is installed locally. This case keeps happening intermittently, not every time. Please check this.") | Fix intermittent Codex CLI detection failure |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## Root Cause Analysis

**Problem**: Codex CLI (`/opt/homebrew/bin/codex`) is intermittently not detected by `codex-sync.sh`

**Root Cause**:
1. **Missing PATH entry**: `/opt/homebrew/bin` is NOT in `~/.zshrc`
2. **Non-interactive shell issue**: When `codex-sync.sh` runs in non-interactive mode (via Claude Code), it sources `~/.zshrc` but `/opt/homebrew/bin` is only added by system-wide initialization in interactive shells
3. **Intermittent nature**: Sometimes PATH is already populated from parent processes, sometimes not

**Evidence**:
```bash
# Interactive shell (current session): ✅ Works
$ command -v codex
/opt/homebrew/bin/codex

# Non-interactive shell: ❌ Fails
$ env -i bash -c 'source ~/.zshrc; command -v codex'
# Exit code 1 (not found)
```

**Current PATH from ~/.zshrc** (missing /opt/homebrew/bin):
```
/Users/chanho/Library/Python/3.9/bin:/.bun/bin:...
# Missing: /opt/homebrew/bin (where codex lives)
```

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix intermittent Codex CLI detection failure in `codex-sync.sh`

**Scope**:
- **In Scope**:
  - `~/.zshrc` - Add `/opt/homebrew/bin` to PATH
  - `.claude/scripts/codex-sync.sh` - Verify detection logic robustness
  - Verification test to confirm fix works
- **Out of Scope**:
  - Changing shell initialization system files
  - Modifying other commands' delegation logic

**Deliverables**:
1. Updated `~/.zshrc` with `/opt/homebrew/bin` in PATH
2. Verification test confirming detection works in non-interactive shells

### Why (Context)

**Current Problem**:
- Codex CLI installed at `/opt/homebrew/bin/codex`
- Intermittently not detected by `codex-sync.sh`
- Causes fallback to Claude-only analysis when GPT delegation was intended
- User experience: "자꾸 이런 케이스가 발생해" (keeps happening intermittently)

**Business Value**:
- **User Impact**: Reliable GPT delegation when Codex is installed
- **Technical Impact**: Eliminates intermittent failure mode in delegation system
- **Quality Impact**: Robust PATH initialization across shell contexts

**Background**:
- Homebrew on ARM Macs installs to `/opt/homebrew/bin`
- This path is typically added by system-wide shell initialization
- Non-interactive shells don't run system-wide init scripts
- `codex-sync.sh` already has Layer 2 fallback to check common paths, but it shouldn't rely on fallback for the primary installation path

### How (Approach)

**Implementation Strategy**:
1. Add `/opt/homebrew/bin` to PATH in `~/.zshrc`
2. Verify fix with non-interactive shell test
3. Confirm `codex-sync.sh` detection works reliably

**Dependencies**:
- None (simple PATH configuration change)

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Duplicate PATH entries if already added by system | Low | Low | Check before adding (or accept duplicates, harmless) |
| Breaking other tools that depend on different PATH order | Low | Low | Add to front of PATH for priority |
| User uses bash instead of zsh | Medium | Low | Document fix for both shells |

---

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: `/opt/homebrew/bin` added to PATH in `~/.zshrc`
  - Verify: `grep "opt/homebrew/bin" ~/.zshrc`
  - Expected: Line exists with PATH export

- [ ] **SC-2**: Codex detected in non-interactive shell
  - Verify: `env -i bash -c 'source ~/.zshrc; command -v codex'`
  - Expected: Returns `/opt/homebrew/bin/codex`

- [ ] **SC-3**: `codex-sync.sh` detects codex reliably
  - Verify: Run detection check 5 times in succession
  - Expected: 100% success rate (5/5 detections succeed)

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | PATH entry added to zshrc | Check ~/.zshrc content | Line exists: `export PATH="/opt/homebrew/bin:$PATH"` | Integration | Manual verification |
| TS-2 | Non-interactive shell detection | `env -i bash -c 'source ~/.zshrc; command -v codex'` | Returns `/opt/homebrew/bin/codex` (exit 0) | Integration | Manual verification |
| TS-3 | Reliable detection (5 iterations) | Run detection check 5 times | All 5 succeed (100% rate) | Integration | Manual verification |
| TS-4 | codex-sync.sh happy path | `DEBUG=1 .claude/scripts/codex-sync.sh "read-only" "test"` | DEBUG shows "Found via command -v: codex" | Integration | Manual verification |

### Test Environment (Detected)

**Auto-Detected Configuration**:
- **Project Type**: Shell script / Bash
- **Test Framework**: Manual verification (bash commands)
- **Test Command**: Direct bash execution
- **Test Directory**: N/A (shell configuration test)
- **Coverage Target**: N/A (configuration change, not code)

---

## Execution Context (Planner Handoff)

### Explored Files

- `.claude/scripts/codex-sync.sh` - Multi-layered detection logic (Layer 1: command -v, Layer 2: common paths)
- `~/.zshrc` - Current PATH configuration (missing `/opt/homebrew/bin`)
- `/opt/homebrew/bin/codex` - Confirmed installation location

### Key Decisions Made

1. **Root cause identified**: Missing `/opt/homebrew/bin` in `~/.zshrc`
2. **Solution approach**: Single PATH addition to `~/.zshrc` (simpler than modifying `codex-sync.sh`)
3. **Verification strategy**: Test in non-interactive shell to simulate Claude Code environment
4. **Success criteria**: 100% detection reliability (5/5 iterations)

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```bash
> # Single change required: Add to ~/.zshrc
> export PATH="/opt/homebrew/bin:$PATH"
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> # Test non-interactive shell detection
> env -i bash -c 'source ~/.zshrc 2>/dev/null; command -v codex'
>
> # Test codex-sync.sh detection (run 5 times)
> for i in {1..5}; do
>   echo "Test $i:"
>   env -i bash -c 'source ~/.zshrc 2>/dev/null; .claude/scripts/codex-sync.sh "read-only" "test" 2>&1 | head -5'
> done
> ```

#### Root Cause Evidence
> **FROM CONVERSATION:**
> ```bash
> # Interactive shell: ✅ Works
> $ command -v codex
> /opt/homebrew/bin/codex
>
> # Non-interactive shell: ❌ Fails
> $ env -i bash -c 'source ~/.zshrc; command -v codex'
> # Exit code 1 (not found)
> ```

### Assumptions

- User uses zsh as primary shell (has `~/.zshrc`)
- User can edit `~/.zshrc` directly
- No other shell configuration conflicts
- Homebrew installation at `/opt/homebrew/bin` is standard ARM Mac location

---

## Execution Plan

### Phase 1: Discovery ✅
- [x] Read `codex-sync.sh` to understand detection logic
- [x] Test Codex CLI availability in current session
- [x] Reproduce issue in non-interactive shell
- [x] Identify root cause: Missing `/opt/homebrew/bin` in `~/.zshrc`

### Phase 2: Implementation

**Single change required**:

1. **Add `/opt/homebrew/bin` to PATH in `~/.zshrc`**
   ```bash
   # Add at the beginning of PATH setup section (after other PATH exports, or at line ~2-3)
   export PATH="/opt/homebrew/bin:$PATH"
   ```

### Phase 3: Verification

1. **Test non-interactive shell detection**:
   ```bash
   env -i bash -c 'source ~/.zshrc 2>/dev/null; command -v codex'
   ```
   Expected: `/opt/homebrew/bin/codex`

2. **Test codex-sync.sh detection** (run 5 times):
   ```bash
   for i in {1..5}; do
     echo "Test $i:"
     env -i bash -c 'source ~/.zshrc 2>/dev/null; .claude/scripts/codex-sync.sh "read-only" "test" 2>&1 | head -5'
   done
   ```
   Expected: All 5 succeed (no "Codex CLI not installed" warnings)

3. **Test in new shell session**:
   ```bash
   # Open new terminal window or run:
   bash -l -c 'command -v codex'
   ```
   Expected: `/opt/homebrew/bin/codex`

---

## Constraints

### Technical Constraints
- Must preserve existing PATH entries in `~/.zshrc`
- Must not break existing shell configuration
- Must work for both bash and zsh (user may use either)

### Business Constraints
- Quick fix (user is experiencing intermittent failures now)
- Minimal changes required (single PATH addition)

### Quality Constraints
- Verification must confirm 100% detection reliability
- No breaking changes to existing shell setup

---

## Vibe Coding Compliance

This plan involves shell configuration (not code), but execution should follow:

- **Single Responsibility**: One PATH addition, one purpose
- **KISS**: Simplest solution (add PATH, don't modify detection logic)
- **Early Return**: Verify after single change, don't over-engineer

---

## Acceptance Criteria

- [ ] All Success Criteria (SC-1, SC-2, SC-3) met
- [ ] All Test Scenarios (TS-1, TS-2, TS-3, TS-4) pass
- [ ] No breaking changes to shell configuration
- [ ] Codex detection 100% reliable (5/5 iterations)

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Duplicate PATH entries if already added by system | Low | Low | Check before adding (or accept duplicates, harmless) |
| Breaking other tools that depend on different PATH order | Low | Low | Add to front of PATH for priority |
| User uses bash instead of zsh | Medium | Low | Document fix for both shells |

---

## Open Questions

None - Root cause clearly identified, solution is straightforward.

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-18 15:12 | Plan-Reviewer (pending) | Auto-review pending | Pending |

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-18 15:12:55
