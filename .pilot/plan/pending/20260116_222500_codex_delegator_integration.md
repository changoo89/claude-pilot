# Codex Delegator Integration

- Generated: 2026-01-16 22:25:00 | Work: codex_delegator_integration
- Location: .pilot/plan/pending/20260116_222500_codex_delegator_integration.md

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
  - Codex CLI detection (`shutil.which("codex")`, auth check)
  - `.mcp.json` generation with GPT 5.2 model
  - Copy orchestration rules (4 files) from claude-delegator to templates
  - Copy expert prompts (5 files) from claude-delegator to templates
  - Apply to both current project AND template (for plugin distribution)
- **Out of scope**:
  - Modifying existing skills/agents
  - Changing claude-pilot core workflow
  - Codex CLI installation (user responsibility)
  - Runtime GitHub downloads (files bundled in package)

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

- **Phase 1**: Copy orchestration content to templates
  - Manually copy claude-delegator rules (4 files) to `src/claude_pilot/templates/.claude/rules/delegator/`
  - Manually copy expert prompts (5 files) to `src/claude_pilot/templates/.claude/rules/delegator/prompts/`
  - Files bundled in package, deployed via existing `sync-templates.sh`
- **Phase 2**: Implement Codex detection
  - Add `detect_codex_cli()` function using `shutil.which()`
  - Add `check_codex_auth()` function to check `~/.codex/auth.json`
- **Phase 3**: Implement MCP setup
  - Add `setup_codex_mcp()` function to generate/merge `.mcp.json`
  - Integrate with `perform_auto_update()` and `initialize()`
- **Phase 4**: Tests & Verification
  - Unit tests for detection functions
  - Integration test for MCP setup

### Success Criteria

**SC-1**: Codex CLI Detection
- Verify (Python): `python -c "from claude_pilot.codex import detect_codex_cli; print(detect_codex_cli())"`
- Verify (Shell): `which codex && echo "True" || echo "False"`
- Expected: Correctly identifies Codex CLI presence

**SC-2**: Codex Authentication Check
- Verify (Python): `python -c "from claude_pilot.codex import check_codex_auth; print(check_codex_auth())"`
- Verify (Shell): `test -f ~/.codex/auth.json && jq -e '.tokens.access_token' ~/.codex/auth.json && echo "True" || echo "False"`
- Expected: Correctly identifies authenticated state

**SC-3**: MCP Config Generation
- Verify: `cat .mcp.json | jq '.mcpServers.codex'`
- Expected: `{"type": "stdio", "command": "codex", "args": ["-m", "gpt-5.2", "mcp-server"]}`

**SC-4**: Rules Import
- Verify:
  ```bash
  test -f src/claude_pilot/templates/.claude/rules/delegator/delegation-format.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/model-selection.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/orchestration.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/triggers.md && echo "All 4 rules exist"
  ```
- Expected: All 4 files exist

**SC-5**: Prompts Import
- Verify:
  ```bash
  test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/architect.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/code-reviewer.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/plan-reviewer.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/scope-analyst.md && \
  test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/security-analyst.md && echo "All 5 prompts exist"
  ```
- Expected: All 5 files exist

**SC-6**: Test Coverage
- Verify: `pytest --cov=src/claude_pilot/codex --cov-report=term-missing`
- Expected: Coverage 80%+ for codex.py module

### Constraints

- Must not break existing init/update flow when Codex not installed
- Must use GPT 5.2 model (not gpt-5.2-codex)
- Must apply to both current project AND templates
- Must preserve user's existing MCP config if present
- No runtime GitHub API calls (files bundled in package)

---

## Scope

### In Scope
- Codex CLI detection (shutil.which)
- Codex authentication check (~/.codex/auth.json)
- .mcp.json generation with merge support
- Rules copy to templates (4 files)
- Prompts copy to templates (5 files)
- Integration with init and update commands

### Out of Scope
- Codex CLI installation
- Modifying existing claude-pilot agents/skills
- Global MCP configuration (project-level only)
- Runtime GitHub downloads

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
| `src/claude_pilot/updater.py` | Update logic | L290-326 | `perform_auto_update()` - integration point |
| `src/claude_pilot/initializer.py` | Init logic | - | `initialize()` - integration point |
| `/Users/chanho/.claude/rules/delegator/*.md` | Existing delegator rules | - | 4 files already present |
| `/Users/chanho/hater/.mcp.json` | Reference MCP config | L1-9 | GPT 5.2 model config |
| `/Users/chanho/.codex/auth.json` | Codex auth | L1-10 | Authenticated - valid tokens |
| `scripts/sync-templates.sh` | Deploy script | - | Handles template sync |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Use `shutil.which()` for detection | Cross-platform, built-in | Subprocess `which codex` |
| Project-level `.mcp.json` | Portable, per-project config | Global `~/.claude/settings.json` |
| Bundle files in package | No runtime downloads, simpler | GitHub API at runtime |
| Merge existing MCP config | Preserve user settings | Overwrite entirely |
| Skip & warn on failure | Non-blocking, existing features work | Abort entire init/update |

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
> ```python
> import shutil
> def detect_codex_cli() -> bool:
>     return shutil.which("codex") is not None
> ```

> **FROM CONVERSATION - Auth Check:**
> ```python
> import json
> from pathlib import Path
>
> def check_codex_auth() -> bool:
>     auth_path = Path.home() / ".codex" / "auth.json"
>     if not auth_path.exists():
>         return False
>     try:
>         data = json.loads(auth_path.read_text())
>         return bool(data.get("tokens", {}).get("access_token"))
>     except (json.JSONDecodeError, OSError):
>         return False
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
├── codex.py (NEW)              # Codex detection & MCP setup (~80 lines)
└── templates/.claude/
    └── rules/
        └── delegator/
            ├── delegation-format.md (NEW - copied from claude-delegator)
            ├── model-selection.md (NEW - copied from claude-delegator)
            ├── orchestration.md (NEW - copied from claude-delegator)
            ├── triggers.md (NEW - copied from claude-delegator)
            └── prompts/
                ├── architect.md (NEW - copied from claude-delegator)
                ├── code-reviewer.md (NEW - copied from claude-delegator)
                ├── plan-reviewer.md (NEW - copied from claude-delegator)
                ├── scope-analyst.md (NEW - copied from claude-delegator)
                └── security-analyst.md (NEW - copied from claude-delegator)
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
                False: skip           False: skip          Write/Merge .mcp.json
                (warn user)           (warn user)          (preserve existing)
```

### Error Handling Strategy

| Error Type | Detection | User Notification | Graceful Degradation |
|------------|-----------|-------------------|---------------------|
| Codex not installed | `shutil.which()` returns None | "Codex CLI not found. Skipping GPT delegation setup." | Skip codex setup, continue normally |
| Codex not authenticated | No valid tokens in auth.json | "Codex not authenticated. Run 'codex auth' first." | Skip codex setup, continue normally |
| .mcp.json write error | OSError during file write | "Could not write .mcp.json: {error}" | Skip codex setup, continue normally |
| Malformed existing .mcp.json | JSONDecodeError | "Existing .mcp.json is invalid. Skipping merge." | Skip codex setup, continue normally |

---

## Vibe Coding Compliance

| Metric | Target | Plan |
|--------|--------|------|
| Function size | ≤50 lines | Each function single responsibility |
| File size | ≤200 lines | `codex.py` estimated ~80 lines |
| Nesting | ≤3 levels | Early return pattern |
| SRP | One responsibility | Separate detect/auth/setup functions |

---

## Execution Plan

| Phase | Task | Files | Effort |
|-------|------|-------|--------|
| 1.1 | Copy delegator rules to templates | `templates/.claude/rules/delegator/*.md` | Quick |
| 1.2 | Copy expert prompts to templates | `templates/.claude/rules/delegator/prompts/*.md` | Quick |
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
- [ ] Existing init/update works when Codex not installed

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
| TS-8 | Malformed .mcp.json | Invalid JSON | Skip merge, warn user | Unit | `tests/test_codex.py::test_setup_mcp_malformed` |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Codex CLI path varies by OS | Medium | Low | Use `shutil.which()` for cross-platform detection |
| Auth token expired | Low | Low | Check `access_token` exists, let Codex handle refresh |
| Existing .mcp.json conflict | Medium | Medium | Merge strategy - preserve existing servers |
| claude-delegator repo changes | Low | Low | Files bundled at build time, not runtime |

---

## Open Questions

1. ~~Should we add a `--skip-codex` flag to init/update commands?~~ → No, skip automatically if not installed
2. ~~Should we support custom model selection via config?~~ → No, hardcode gpt-5.2 per user request

---

## References

- [claude-delegator](https://github.com/jarrodwatts/claude-delegator/) - Source repository
- [Codex CLI](https://github.com/openai/codex-cli) - OpenAI Codex CLI
