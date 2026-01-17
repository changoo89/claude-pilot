# Claude Code Pure Plugin Migration Plan

> **Plan ID**: 20260117_pure_plugin_migration
> **Created**: 2026-01-17
> **Status**: Pending
> **Branch**: main

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 00:00 | "우리 배포 방식을 pypi 에서 claudecode plugin 으로 변경하려고 해" | Migrate from PyPI to Claude Code plugin |
| UR-2 | 00:00 | "https://github.com/jarrodwatts/claude-delegator/ 이게 샘플 리포지토리야" | Reference repository for plugin structure |
| UR-3 | 00:00 | "여기사 하는것 처럼 빠른실행 라인 3개로 설치될 수 있도록 플러그인을 설정해줘" | Enable 3-line quick install setup |
| UR-4 | 00:00 | "이 리포지토리의 배포 관련 모든 코드를 확인해서 우리한테 적용랄 수 있게 해줘" | Analyze all deployment code from sample repo |
| UR-5 | 00:00 | "(깃헙 스타를 자동으로 요구하는 단계도 있으니 이런것 까지 다 꼼꼼하게 체크)" | Include GitHub star requirement check |
| UR-6 | 00:00 | "궁금한게 있는데 여전히 python 이 필요한거야? pypi 로 배포 안하는데도?" | Clarify: Pure plugin, no Python needed |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| UR-2 | ✅ | SC-1 | Mapped |
| UR-3 | ✅ | SC-2 | Mapped |
| UR-4 | ✅ | SC-1, SC-4 | Mapped |
| UR-5 | ✅ | SC-5 | Mapped |
| UR-6 | ✅ | SC-6 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Transform claude-pilot from a PyPI-distributed Python package to a pure Claude Code plugin distributed via GitHub marketplace, completely removing Python packaging while enabling 3-line installation.

**Scope**:
- **In Scope**:
  - Remove all Python packaging infrastructure
  - Create `.claude-plugin/` directory structure with manifests
  - Remove `src/claude_pilot/` directory (CLI tool, build hooks, assets)
  - Remove `pyproject.toml`, `install.sh`, and other Python-specific files
  - Create `/pilot:setup` command for MCP server configuration
  - Update README for plugin-only installation
  - Add CHANGELOG.md documenting removal of PyPI distribution

- **Out of Scope**:
  - Maintaining PyPI distribution (completely removing)
  - CLI tool functionality (no longer needed)
  - Python package installation (pip/pipx)
  - Build system (Hatchling)
  - Version synchronization across multiple files

**Deliverables**:
1. `.claude-plugin/marketplace.json` - Marketplace manifest
2. `.claude-plugin/plugin.json` - Plugin manifest
3. `.claude/commands/000_pilot_setup.md` - Setup command with GitHub star prompt
4. `.claude/hooks.json` - Hook definitions
5. Updated README.md - Plugin installation only
6. CHANGELOG.md - Document PyPI removal, plugin migration
7. MIGRATION.md - Guide for existing PyPI users

### Why (Context)

**Current Problem**:
- Python packaging adds unnecessary complexity
- PyPI distribution requires build/publish steps
- Version synchronization across 7 files is error-prone
- CLI tool (`claude-pilot` command) is redundant with Claude Code
- Updates require pip install --upgrade
- Separate from Claude Code's native plugin ecosystem

**Desired State**:
- Pure plugin distribution (no Python)
- 3-line installation: `/plugin marketplace add` → `/plugin install` → `/pilot:setup`
- Single version source (plugin.json only)
- Native Claude Code integration
- Updates via `/plugin update`
- GitHub-native distribution

**Business Value**:
- **User Impact**: Simpler installation, no Python dependency, native Claude Code integration
- **Technical Impact**: No build system, no version sync issues, simpler maintenance
- **Developer Impact**: Less code to maintain, faster releases

**Background**:
- claude-pilot v4.0.5 currently distributed via PyPI
- Reference: jarrodwatts/claude-delegator demonstrates pure plugin approach
- All `.claude/` components already plugin-compatible
- No CLI tool needed - Claude Code provides the interface

### How (Approach)

**Implementation Strategy**:

**Phase 1: Create Plugin Manifests**
- Create `.claude-plugin/marketplace.json` with marketplace metadata
- Create `.claude-plugin/plugin.json` pointing to `.claude/` components
- Follow claude-delegator structure exactly

**Phase 2: Create Setup Command**
- Create `.claude/commands/000_pilot_setup.md`
- Implement MCP server configuration
- Add GitHub star prompt (using `gh` CLI + AskUserQuestion)
- Include fallback for missing `gh` CLI

**Phase 3: Create Hooks Configuration**
- Create `.claude/hooks.json` for pre-commit/pre-push events
- Reference existing hook scripts

**Phase 4: Remove Python Packaging**
- Delete `src/claude_pilot/` directory
- Delete `pyproject.toml`
- Delete `install.sh`
- Delete Python-specific test files
- Update documentation

**Phase 5: Update Documentation**
- Rewrite README for plugin-only installation
- Document 3-line install process
- Create migration guide for existing PyPI users
- Add CHANGELOG entry

**Dependencies**:
- GitHub repository must be public
- Claude Code v1.0+ with plugin support
- Existing `.claude/` structure (already compatible)

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing PyPI users | Medium | High | Migration guide, clear communication |
| Missing CLI functionality | Low | Medium | Claude Code interface is sufficient |
| GitHub star requirement (5+) | Low | Low | Plugin works without stars |
| MCP server conflicts | Low | Medium | Merge strategy in setup command |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: Plugin manifests created and valid
  - Verify: Schema validation against official Anthropic schemas
  - Expected: marketplace.json and plugin.json pass validation
  - Test: Manual validation in Claude Code

- [ ] **SC-2**: 3-line installation works
  - Verify: Test on fresh Claude Code installation
  - Expected: `/plugin marketplace add changoo89/claude-pilot` → `/plugin install` → `/pilot:setup` succeeds
  - Test: E2E manual testing

- [ ] **SC-3**: All commands accessible after plugin install
  - Verify: List commands after plugin installation
  - Expected: All 9 pilot commands available and functional
  - Test: Manual testing in Claude Code

- [ ] **SC-4**: Setup command configures MCP servers
  - Verify: Run `/pilot:setup` and check MCP configuration
  - Expected: Recommended MCP servers configured
  - Test: Manual testing

- [ ] **SC-5**: GitHub star prompt works in setup command
  - Verify: Run `/pilot:setup`, select "Yes, star it!"
  - Expected: Repository starred via `gh` CLI or manual link provided
  - Test: Manual testing

- [ ] **SC-6**: Python packaging completely removed
  - Verify: Check repository structure
  - Expected: No `src/`, `pyproject.toml`, `install.sh` present
  - Test: File system check

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test Method |
|----|----------|-------|----------|------|-------------|
| TS-1 | Plugin schema validation | marketplace.json, plugin.json | Both files valid | Integration | Manual validation |
| TS-2 | 3-line install process | Fresh Claude Code | Plugin installs and setup succeeds | E2E | Manual testing |
| TS-3 | Command discovery | `/list` after install | All 9 commands listed | Integration | Manual testing |
| TS-4 | Setup command MCP config | `/pilot:setup` | MCP servers configured | Integration | Manual testing |
| TS-5 | GitHub star prompt | `/pilot:setup` → select "Yes" | Repo starred or link provided | Integration | Manual testing |
| TS-6 | Python removal | File system check | No Python files present | Verification | `ls -la` check |

### Test Environment

**Configuration**:
- **Distribution**: Claude Code Plugin only (no Python)
- **Test Method**: Manual testing in Claude Code CLI
- **Plugin Files**: `.claude-plugin/`, `.claude/`

---

## Execution Plan

### Phase 1: Create Plugin Manifests

- [ ] Create `.claude-plugin/` directory
- [ ] Write `marketplace.json` (follow claude-delegator format)
- [ ] Write `plugin.json` (reference `.claude/` components)
- [ ] Validate schema structure

### Phase 2: Create Setup Command

- [ ] Create `.claude/commands/000_pilot_setup.md`
- [ ] Add MCP server configuration logic
- [ ] Add GitHub star prompt (AskUserQuestion)
- [ ] Add `gh` CLI availability check
- [ ] Add fallback for missing `gh` CLI
- [ ] Test setup command

### Phase 3: Create Hooks Configuration

- [ ] Create `.claude/hooks.json`
- [ ] Define pre-commit hooks (typecheck, lint, check-todos)
- [ ] Define pre-push hooks (branch-guard)

### Phase 4: Remove Python Packaging

- [ ] Delete `src/claude_pilot/` directory
- [ ] Delete `pyproject.toml`
- [ ] Delete `install.sh`
- [ ] Delete `scripts/verify-version-sync.sh`
- [ ] Delete Python-specific test files
- [ ] Update `.gitignore` if needed

### Phase 5: Update Documentation

- [ ] Rewrite README.md for plugin-only
- [ ] Document 3-line installation
- [ ] Create CHANGELOG.md entry
- [ ] Create MIGRATION.md for existing users
- [ ] Update CLAUDE.md if needed

### Phase 6: Verification

- [ ] Test 3-line install in fresh Claude Code
- [ ] Verify all commands work
- [ ] Verify MCP configuration
- [ ] Verify GitHub star prompt
- [ ] Confirm no Python files remain

---

## Constraints

### Technical Constraints
- Claude Code v1.0+ required
- GitHub repository must be public
- Plugin manifests must follow official Anthropic schemas
- No Python dependencies

### Business Constraints
- Breaking change for existing PyPI users (migration guide required)
- No rollback path to PyPI (one-way migration)

### Quality Constraints
- Plugin manifests must validate against schemas
- All commands must work after plugin install
- Clear documentation for migration

---

## 📋 COMPLETE CHANGE LIST: Add/Remove

### ✅ FILES TO ADD (Create New)

| # | File Path | Purpose | Reference |
|---|-----------|---------|-----------|
| 1 | `.claude-plugin/marketplace.json` | Marketplace manifest | claude-delegator |
| 2 | `.claude-plugin/plugin.json` | Plugin manifest | claude-delegator |
| 3 | `.claude/commands/000_pilot_setup.md` | Setup command | claude-delegator/setup.md |
| 4 | `.claude/hooks.json` | Hook definitions | New file |
| 5 | `CHANGELOG.md` | Version history | Standard |
| 6 | `MIGRATION.md` | Migration guide for PyPI users | New document |

### 🔄 FILES TO MODIFY (Update)

| # | File Path | Changes | Why |
|---|-----------|---------|-----|
| 1 | `README.md` | Rewrite for plugin-only installation | Remove PyPI instructions |
| 2 | `CLAUDE.md` | Update for plugin distribution | Remove Python references |

### ❌ FILES TO REMOVE (Delete)

| # | File Path | Reason |
|---|-----------|--------|
| 1 | `src/claude_pilot/` (entire directory) | Python CLI tool |
| 2 | `pyproject.toml` | Hatchling build config |
| 3 | `install.sh` | pipx/pip installation |
| 4 | `scripts/verify-version-sync.sh` | Version sync (no longer needed) |
| 5 | `tests/test_pypi_compat.py` | PyPI compatibility tests |
| 6 | `tests/test_plugin_build.py` | Wheel build tests |
| 7 | `tests/test_version_sync.py` | Version sync tests |

### ⚠️ CRITICAL: Files to PRESERVE

| File/Component | Why Keep |
|----------------|----------|
| `.claude/` (all contents) | Plugin components |
| `.mcp.json` | MCP server configuration |
| `tests/` (non-PyPI tests) | Existing test coverage |

---

## 🎯 Version Management (Simplified)

**Single Source of Truth**: `.claude-plugin/plugin.json` version field only

No more version synchronization across multiple files!

---

## 🔍 claude-delegator Reference Implementation

**Key Findings**:
- No Python packaging at all
- Pure markdown + JSON files
- Setup command uses `gh` CLI for starring
- GitHub star is optional (soft prompt)
- No build step required

---

## External Service Integration

### GitHub CLI Integration

**Purpose**: Enable GitHub star functionality in `/pilot:setup`

**Availability Check**:
```bash
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        gh api -X PUT /user/starred/changoo89/claude-pilot
    else
        echo "Please star manually: https://github.com/changoo89/claude-pilot"
    fi
else
    echo "GitHub CLI not found. Please star manually: https://github.com/changoo89/claude-pilot"
fi
```

**Fallback**: Manual GitHub link always provided

---

## Key Files to Create

### 1. `.claude-plugin/marketplace.json`

```json
{
  "name": "claude-pilot",
  "owner": {
    "name": "changoo89",
    "url": "https://github.com/changoo89"
  },
  "plugins": [
    {
      "name": "claude-pilot",
      "source": "./.",
      "description": "SPEC-First development workflow: Plan → Confirm → Execute → Review → Document → Close",
      "category": "development",
      "version": "4.1.0",
      "author": {
        "name": "changoo89",
        "url": "https://github.com/changoo89"
      }
    }
  ]
}
```

### 2. `.claude-plugin/plugin.json`

```json
{
  "name": "claude-pilot",
  "description": "SPEC-First development workflow with TDD, Ralph Loop, and autonomous agent coordination for Claude Code",
  "version": "4.1.0",
  "author": {
    "name": "changoo89",
    "url": "https://github.com/changoo89"
  },
  "homepage": "https://github.com/changoo89/claude-pilot",
  "repository": "https://github.com/changoo89/claude-pilot",
  "license": "MIT",
  "keywords": ["tdd", "spec-first", "workflow", "agents", "testing", "documentation"],
  "commands": ["./.claude/commands/"],
  "agents": ["./.claude/agents/"],
  "skills": ["./.claude/skills/"],
  "mcpServers": "./.mcp.json",
  "hooks": "./.claude/hooks.json"
}
```

### 3. `.claude/commands/000_pilot_setup.md`

Setup command structure (based on claude-delegator/setup.md):
- MCP server configuration
- GitHub star prompt
- Installation verification

### 4. `.claude/hooks.json`

```json
{
  "pre-commit": [
    {
      "command": ".claude/scripts/hooks/typecheck.sh",
      "description": "Run type check"
    },
    {
      "command": ".claude/scripts/hooks/lint.sh",
      "description": "Run lint check"
    }
  ],
  "pre-push": [
    {
      "command": ".claude/scripts/hooks/branch-guard.sh",
      "description": "Prevent push from protected branches"
    }
  ]
}
```

---

## 3-Line Installation

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

---

## Migration Guide for Existing PyPI Users

**Breaking Change**: PyPI distribution discontinued

**Migration Steps**:
1. Uninstall Python package: `pipx uninstall claude-pilot` or `pip uninstall claude-pilot`
2. Install plugin: Follow 3-line installation above
3. All functionality preserved (commands, agents, skills)

**Benefits**:
- No Python dependency
- Simpler updates (`/plugin update`)
- Native Claude Code integration

---

## Related Documentation

- **Claude Code Plugins Reference**: https://code.claude.com/docs/en/plugins-reference
- **Sample Plugin**: https://github.com/jarrodwatts/claude-delegator
- **Marketplace Directory**: https://claudemarketplaces.com

---

**Plan Version**: 2.0 (Pure Plugin)
**Last Updated**: 2026-01-17
**Next Steps**: A) Refine plan, B) Run /01_confirm, C) Run /02_execute
