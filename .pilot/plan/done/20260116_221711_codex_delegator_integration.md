# Codex Delegator Integration

- Generated: 2026-01-16 22:17:11 | Work: codex_delegator_integration
- Location: .pilot/plan/pending/20260116_221711_codex_delegator_integration.md

---

## User Requirements (Verbatim)

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "만약 codex cli 가 설치가 되어있고 auth 되어있다면 우리 install 이나 update 에서 아래 내용을 다운로드" | Conditional Codex CLI detection during install/update |
| UR-2 | "상위폴더의 hater 의 .mcp.json 형태로 codex mcp 세팅 (단 모델은 gpt 5.2 로 (codex 말고)" | MCP config with GPT 5.2 model |
| UR-3 | "해당 깃헙 리포지토리의 rule 과 prompt 등 오케스트레이션을 위한 핵심 내용들을 그대로 본따서 우리에게 가져오기" | Import orchestration rules & prompts from claude-delegator |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| UR-3 | ✅ | SC-4, SC-5 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Integrate claude-delegator's GPT expert delegation system into claude-pilot as an optional feature, enabled when Codex CLI is installed and authenticated.

**Scope**:
- **In scope**:
  - Codex CLI detection (`which codex`, auth check)
  - `.mcp.json` generation with GPT 5.2 model
  - Import orchestration rules (4 files) from claude-delegator
  - Import expert prompts (5 files) from claude-delegator
  - Apply to both current project AND template (for plugin distribution)
- **Out of scope**:
  - Modifying existing skills/agents
  - Changing claude-pilot core workflow
  - Codex CLI installation (user responsibility)

### Why (Context)

**Current Problem**:
- claude-pilot has no GPT expert delegation capability
- Complex tasks (architecture, security review) handled only by Claude
- No multi-model orchestration pattern

**Desired State**:
- Optional GPT 5.2 expert delegation via Codex MCP
- Automatic detection and setup during `claude-pilot init/update`
- 5 specialized experts available (Architect, Code Reviewer, etc.)
- Project-level `.mcp.json` for portable config

**Business Value**:
- Multi-LLM orchestration (Claude + GPT)
- Specialized experts for architecture, security, code review
- Reduced manual configuration for users

### How (Approach)

- **Phase 1**: Import orchestration content
  - Download claude-delegator rules (4 files) and prompts (5 files)
  - Add to `src/claude_pilot/templates/.claude/rules/delegator/`
- **Phase 2**: Implement Codex detection
  - Add `detect_codex_cli()` function to detect installation
  - Add `check_codex_auth()` function to verify authentication
- **Phase 3**: Implement MCP setup
  - Add `setup_codex_mcp()` function to generate `.mcp.json`
  - Integrate with `perform_auto_update()` and `initialize()`
- **Phase 4**: Tests & Verification
  - Unit tests for detection functions
  - Integration test for MCP setup

### Success Criteria

**SC-1**: Codex CLI Detection
- Verify: `detect_codex_cli()` returns True when codex installed, False otherwise
- Expected: Correctly identifies Codex CLI presence

**SC-2**: Codex Authentication Check
- Verify: `check_codex_auth()` returns True when `~/.codex/auth.json` has valid tokens
- Expected: Correctly identifies authenticated state

**SC-3**: MCP Config Generation
- Verify: `.mcp.json` created with correct structure when Codex available
- Expected: File contains `{"mcpServers": {"codex": {"type": "stdio", "command": "codex", "args": ["-m", "gpt-5.2", "mcp-server"]}}}`

**SC-4**: Rules Import
- Verify: 4 orchestration rules exist in templates
- Expected: `delegation-format.md`, `model-selection.md`, `orchestration.md`, `triggers.md`

**SC-5**: Prompts Import
- Verify: 5 expert prompts exist in templates
- Expected: `architect.md`, `code-reviewer.md`, `plan-reviewer.md`, `scope-analyst.md`, `security-analyst.md`

### Constraints

- Must not break existing init/update flow when Codex not installed
- Must use GPT 5.2 model (not gpt-5.2-codex)
- Must apply to both current project AND templates
- Must preserve user's existing MCP config if present

---

## Scope

### In Scope
- Codex CLI detection (shutil.which)
- Codex authentication check (~/.codex/auth.json)
- .mcp.json generation with merge support
- Rules import (4 files)
- Prompts import (5 files)
- Integration with init and update commands

### Out of Scope
- Codex CLI installation
- Modifying existing claude-pilot agents/skills
- Global MCP configuration (project-level only)

---

## Test Environment (Detected)

| Field | Value |
|-------|-------|
| **Project Type** | Python |
| **Test Framework** | pytest |
| **Test Command** | `pytest` |
| **Coverage Command** | `pytest --cov=src/claude_pilot --cov-report=term-missing` |
| **Test Directory** | `tests/` |
| **Type Check** | `mypy .` |
| **Lint** | `ruff check .` |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `src/claude_pilot/config.py` | Config constants | L99-109 | `EXTERNAL_SKILLS` dict - extensible pattern |
| `src/claude_pilot/updater.py` | Update logic | L801-1010 | `sync_external_skills()` - GitHub tarball pattern |
| `src/claude_pilot/cli.py` | CLI entry | - | Click commands (init, update) |
| `/Users/chanho/.claude/rules/delegator/*.md` | Existing delegator rules | - | 4 files already present |
| `/Users/chanho/hater/.mcp.json` | Reference MCP config | L1-9 | GPT 5.2 model config |
| `/Users/chanho/.codex/auth.json` | Codex auth | L1-10 | Authenticated - valid tokens |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Use `shutil.which()` for detection | Cross-platform, built-in | Subprocess `which codex` |
| Project-level `.mcp.json` | Portable, per-project config | Global `~/.claude/settings.json` |
| Mirror claude-delegator structure | Consistency, familiarity | Custom organization |
| Merge existing MCP config | Preserve user settings | Overwrite entirely |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples

> **FROM CONVERSATION - MCP Config Structure:**
> ```json
> {
>   "mcpServers": {
>     "codex": {
>       "type": "stdio",
>       "command": "codex",
>       "args": ["-m", "gpt-5.2", "mcp-server"]
>     }
>   }
> }
> ```

#### Syntax Patterns

> **FROM CONVERSATION - Codex CLI Detection:**
> ```bash
> which codex && codex --version 2>/dev/null || echo "codex not found"
> ```

> **FROM CONVERSATION - Auth Check Path:**
> ```bash
> # Auth file location
> ~/.codex/auth.json
> # Check for valid tokens
> tokens.access_token field must exist
> ```

#### Architecture Diagrams

> **FROM CONVERSATION - Data Flow:**
> ```
> [init/update] → detect_codex_cli() → check_codex_auth() → setup_codex_mcp()
>                      ↓                      ↓                    ↓
>                 False: skip           False: skip          Write .mcp.json
> ```

---

## Architecture

### New Files

```
src/claude_pilot/
├── codex.py (NEW)              # Codex detection & MCP setup
└── templates/.claude/
    └── rules/
        └── delegator/
            ├── delegation-format.md (NEW)
            ├── model-selection.md (NEW)
            ├── orchestration.md (NEW)
            ├── triggers.md (NEW)
            └── prompts/
                ├── architect.md (NEW)
                ├── code-reviewer.md (NEW)
                ├── plan-reviewer.md (NEW)
                ├── scope-analyst.md (NEW)
                └── security-analyst.md (NEW)
```

### Modified Files

| File | Change |
|------|--------|
| `config.py` | Add `CODEX_MCP_CONFIG`, `CODEX_AUTH_PATH` constants |
| `updater.py` | Call `setup_codex_mcp()` in `perform_auto_update()` |
| `initializer.py` | Call `setup_codex_mcp()` in `initialize()` |

### Data Flow

```
[init/update] → detect_codex_cli() → check_codex_auth() → setup_codex_mcp()
                     ↓                      ↓                    ↓
                False: skip           False: skip          Write .mcp.json
```

---

## Vibe Coding Compliance

| Metric | Target | Plan |
|--------|--------|------|
| Function size | ≤50 lines | Each function single responsibility |
| File size | ≤200 lines | `codex.py` estimated ~100 lines |
| Nesting | ≤3 levels | Early return pattern |
| SRP | One responsibility | Separate detect/auth/setup functions |

---

## Execution Plan

| Phase | Task | Files | Effort |
|-------|------|-------|--------|
| 1.1 | Download delegator rules from claude-delegator repo | `templates/.claude/rules/delegator/` | Quick |
| 1.2 | Download expert prompts from claude-delegator repo | `templates/.claude/rules/delegator/prompts/` | Quick |
| 2.1 | Create `codex.py` with detection functions | `src/claude_pilot/codex.py` | Short |
| 2.2 | Add Codex constants to config | `src/claude_pilot/config.py` | Quick |
| 3.1 | Integrate with updater | `src/claude_pilot/updater.py` | Short |
| 3.2 | Integrate with initializer | `src/claude_pilot/initializer.py` | Short |
| 4.1 | Write unit tests | `tests/test_codex.py` | Short |
| 4.2 | Run Ralph Loop (tests, type-check, lint) | - | Medium |

---

## Acceptance Criteria

- [ ] `detect_codex_cli()` correctly identifies Codex CLI presence
- [ ] `check_codex_auth()` correctly identifies authenticated state
- [ ] `.mcp.json` created with GPT 5.2 model when Codex available
- [ ] Existing `.mcp.json` merged, not overwritten
- [ ] 4 orchestration rules exist in templates
- [ ] 5 expert prompts exist in templates
- [ ] All tests pass
- [ ] Type check clean
- [ ] Lint clean

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Codex installed | Codex CLI present | `detect_codex_cli()` returns True | Unit | `tests/test_codex.py::test_detect_codex_installed` |
| TS-2 | Codex not installed | No codex CLI | `detect_codex_cli()` returns False | Unit | `tests/test_codex.py::test_detect_codex_not_installed` |
| TS-3 | Codex authenticated | Valid auth.json | `check_codex_auth()` returns True | Unit | `tests/test_codex.py::test_codex_authenticated` |
| TS-4 | Codex not authenticated | No/invalid auth.json | `check_codex_auth()` returns False | Unit | `tests/test_codex.py::test_codex_not_authenticated` |
| TS-5 | MCP setup fresh | No existing .mcp.json | Creates new file with codex config | Integration | `tests/test_codex.py::test_setup_mcp_fresh` |
| TS-6 | MCP setup merge | Existing .mcp.json | Merges codex into existing config | Integration | `tests/test_codex.py::test_setup_mcp_merge` |
| TS-7 | MCP setup skip | Codex not installed | No .mcp.json modification | Integration | `tests/test_codex.py::test_setup_mcp_skip` |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Codex CLI path varies by OS | Medium | Low | Use `shutil.which()` for cross-platform detection |
| Auth token expired | Low | Low | Check `last_refresh` timestamp, warn if old |
| Existing .mcp.json conflict | Medium | Medium | Merge strategy - preserve existing servers |

---

## Open Questions

1. Should we add a `--skip-codex` flag to init/update commands?
2. Should we support custom model selection via config?

---

## References

- [claude-delegator](https://github.com/jarrodwatts/claude-delegator/) - Source repository
- [Codex CLI](https://github.com/openai/codex-cli) - OpenAI Codex CLI

---

## Execution Summary

### Completion Status: ✅ COMPLETE

**Completed**: 2026-01-16
**Agent**: Coder Agent (TDD + Ralph Loop)
**Iterations**: 1 (with auto-fix for pre-existing issues)

### Files Created (11 files)

1. `src/claude_pilot/codex.py` - Codex detection & MCP setup (100 lines)
2. `tests/test_codex.py` - Test suite (221 lines, 11 tests)
3. `src/claude_pilot/templates/.claude/rules/delegator/delegation-format.md`
4. `src/claude_pilot/templates/.claude/rules/delegator/model-selection.md`
5. `src/claude_pilot/templates/.claude/rules/delegator/orchestration.md`
6. `src/claude_pilot/templates/.claude/rules/delegator/triggers.md`
7. `src/claude_pilot/templates/.claude/rules/delegator/prompts/architect.md`
8. `src/claude_pilot/templates/.claude/rules/delegator/prompts/code-reviewer.md`
9. `src/claude_pilot/templates/.claude/rules/delegator/prompts/plan-reviewer.md`
10. `src/claude_pilot/templates/.claude/rules/delegator/prompts/scope-analyst.md`
11. `src/claude_pilot/templates/.claude/rules/delegator/prompts/security-analyst.md`

### Files Modified (4 files)

1. `src/claude_pilot/initializer.py` - Integrated Codex MCP setup (lines 380-392)
2. `src/claude_pilot/updater.py` - Integrated Codex MCP setup (lines 319-331)
3. `tests/test_cli.py` - Fixed missing import (pre-existing issue)
4. `tests/test_external_skills.py` - Fixed type annotations (pre-existing issue)

### Verification Results

| Quality Gate | Result | Details |
|--------------|--------|---------|
| **Tests** | ✅ PASS | 99/99 tests passing |
| **Type Check** | ✅ CLEAN | mypy: no issues in 15 source files |
| **Lint** | ✅ CLEAN | ruff: all checks passed |
| **Coverage** | ✅ 73% overall, 88% core | codex.py: 81% |
| **Code Review** | ✅ APPROVE | Production-ready |

### Success Criteria Status

| Criteria | Status | Evidence |
|----------|--------|----------|
| SC-1: Codex CLI Detection | ✅ PASS | TS-1, TS-2 |
| SC-2: Codex Authentication Check | ✅ PASS | TS-3, TS-4 |
| SC-3: MCP Config Generation | ✅ PASS | TS-5, TS-6 |
| SC-4: Rules Import (4 files) | ✅ PASS | All 4 files present |
| SC-5: Prompts Import (5 files) | ✅ PASS | All 5 files present |

### Acceptance Criteria Status

- [x] `detect_codex_cli()` correctly identifies Codex CLI presence
- [x] `check_codex_auth()` correctly identifies authenticated state
- [x] `.mcp.json` created with GPT 5.2 model when Codex available
- [x] Existing `.mcp.json` merged, not overwritten
- [x] 4 orchestration rules exist in templates
- [x] 5 expert prompts exist in templates
- [x] All tests pass
- [x] Type check clean
- [x] Lint clean

### Vibe Coding Compliance

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Function size | ≤50 lines | Max 40 lines | ✅ Pass |
| File size | ≤200 lines | 100 lines | ✅ Pass |
| Nesting | ≤3 levels | 2 levels | ✅ Pass |
| SRP | Single responsibility | Yes | ✅ Pass |
| DRY | No duplication | Yes | ✅ Pass |
| Early Return | Applied | Yes | ✅ Pass |

### Code Review Findings

**Critical Issues**: None
**Warnings**: 1 (Non-atomic file write - low risk, optional follow-up)
**Suggestions**: 3 (Minor improvements)

**Overall Assessment**: APPROVE - Production-ready

### Follow-ups

None required - all success criteria met and integration complete.

### Additional Notes

**Integration Points**:
- `initializer.py`: Codex MCP setup runs after external skills sync (lines 380-392)
- `updater.py`: Codex MCP setup runs during auto update (lines 319-331)
- Both integrations include user-friendly console output

**Template Files Verified**:
- 4 orchestration rules in `templates/.claude/rules/delegator/`
- 5 expert prompts in `templates/.claude/rules/delegator/prompts/`
- All files copied from claude-delegator repository

**TDD Methodology Applied**:
- Red Phase: Wrote failing tests first
- Green Phase: Implemented minimal code to pass tests
- Refactor Phase: Applied Vibe Coding standards
- Ralph Loop: Verified all quality gates on first iteration
