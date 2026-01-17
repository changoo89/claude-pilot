# Claude Code Plugin Migration Plan

> **Plan ID**: 20260117_claude_code_plugin_migration
> **Created**: 2026-01-17
> **Status**: Pending
> **Branch**: main

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 00:00 | "우리 배포 방식을 pypi 에서 claudecode plugin 으로 변경하려고 해" | Migrate deployment from PyPI to Claude Code plugin |
| UR-2 | 00:00 | "https://github.com/jarrodwatts/claude-delegator/ 이게 샘플 리포지토리야" | Reference repository for plugin structure |
| UR-3 | 00:00 | "여기사 하는것 처럼 빠른실행 라인 3개로 설치될 수 있도록 플러그인을 설정해줘" | Enable 3-line quick install setup |
| UR-4 | 00:00 | "이 리포지토리의 배포 관련 모든 코드를 확인해서 우리한테 적용랄 수 있게 해줘" | Analyze all deployment code from sample repo |
| UR-5 | 00:00 | "(깃헙 스타를 자동으로 요구하는 단계도 있으니 이런것 까지 다 꼼꼼하게 체크)" | Include GitHub star requirement check |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| UR-2 | ✅ | SC-1, SC-2 | Mapped |
| UR-3 | ✅ | SC-2 | Mapped |
| UR-4 | ✅ | SC-1, SC-2, SC-3, SC-4 | Mapped |
| UR-5 | ✅ | Documentation + Risks section | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Transform claude-pilot from a PyPI-distributed Python package to a Claude Code plugin distributed via GitHub marketplace, enabling 3-line installation while maintaining PyPI distribution.

**Scope**:
- **In Scope**:
  - Create `.claude-plugin/` directory structure with manifests
  - Create `marketplace.json` and `plugin.json` following official schemas
  - Add `/pilot:setup` command for MCP server configuration
  - Update README with dual installation methods
  - Add CHANGELOG.md for version tracking
  - Support GitHub releases as versioning mechanism
  - Preserve all existing functionality

- **Out of Scope**:
  - Removing PyPI distribution (keep both options)
  - Changes to core pilot logic (cli.py, initializer.py, etc.)
  - Removal of existing Python package structure
  - Changes to test suite
  - MCP server implementation (already exists)

**Deliverables**:
1. `.claude-plugin/marketplace.json` - Marketplace manifest
2. `.claude-plugin/plugin.json` - Plugin manifest with all components
3. `.claude/commands/000_pilot_setup.md` - Setup command
4. Updated README.md with plugin installation
5. CHANGELOG.md for version tracking
6. Migration guide for existing users

### Why (Context)

**Current Problem**:
- PyPI distribution requires pip/pipx installation
- No integration with Claude Code's native plugin ecosystem
- Updates require `pip install --upgrade`
- Separate from Claude Code's component discovery system
- Cannot leverage plugin marketplaces for discovery
- No direct integration with Claude Code's agent/skill framework

**Desired State**:
- 3-line installation: `/plugin marketplace add` → `/plugin install` → `/pilot:setup`
- Native Claude Code plugin integration
- Automatic component discovery (commands, agents, skills, hooks)
- Eligible for marketplace directories (5+ stars required)
- Better update mechanism via `/plugin update`
- Dual distribution: PyPI + Plugin

**Business Value**:
- **User Impact**: 3-line install vs multi-step pipx setup; seamless Claude Code integration
- **Technical Impact**: Native plugin support; automatic component discovery; better update mechanism
- **Community Impact**: Eligible for marketplace directories; better discoverability

**Background**:
- claude-pilot v4.0.5 currently distributed via PyPI
- Existing `.claude/` structure already compatible with plugin format
- All components (commands, agents, skills, guides) already structured correctly
- MCP server configuration already exists (mcp.json)
- Reference: jarrodwatts/claude-delegator demonstrates successful plugin implementation

### How (Approach)

**Implementation Strategy**:

**Phase 1: Create Plugin Manifests**
- Create `.claude-plugin/marketplace.json` with marketplace metadata
- Create `.claude-plugin/plugin.json` pointing to existing `.claude/` components
- Define all commands, agents, skills, hooks in plugin.json
- Reference official Anthropic schemas for validation

**Phase 2: Add Setup Command**
- Create `.claude/commands/000_pilot_setup.md` as `/pilot:setup`
- Implement MCP server configuration (context7, serena, grep-app, sequential-thinking)
- Add user prompts for customization
- Validate installation and detect conflicts

**Phase 3: Documentation & Distribution**
- Update README with dual installation methods (PyPI + Plugin)
- Create migration guide for existing users
- Add CHANGELOG.md for version tracking
- Prepare GitHub releases for versioning
- Document 3-line install process prominently

**Phase 4: Verification & Testing**
- Test 3-line install process on fresh Claude Code installation
- Verify all commands work after plugin installation
- Test MCP server integration
- Validate marketplace.json and plugin.json schemas
- Ensure PyPI distribution remains functional

**Dependencies**:
- GitHub repository must be public
- Claude Code v1.0+ with plugin support
- Official Anthropic plugin schemas (from anthropics/claude-code repo)

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Plugin schema changes by Anthropic | Medium | High | Use official `$schema` references; version plugin.json; monitor schema updates |
| Breaking existing PyPI installs | Low | High | Keep both distributions; add migration guide; test PyPI installs |
| GitHub star requirement (5+ stars) | Low | Medium | Focus on documentation and community engagement; plugin works without stars |
| MCP server conflicts | Low | Medium | Add conflict detection in setup command; provide override options |
| Marketplace.json schema validation failure | Medium | Low | Use official `$schema` reference; validate before release; add tests |
| Component path references breaking | Medium | Medium | Use relative paths from plugin root; test all paths |
| User confusion about dual distribution | Medium | Low | Clear documentation with use cases for each method |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: Plugin manifests created and valid
  - Verify: Schema validation against official Anthropic schemas
  - Expected: marketplace.json and plugin.json pass validation with no errors
  - Test: `tests/test_plugin_manifests.py::test_schema_validation`

- [ ] **SC-2**: 3-line installation works
  - Verify: Test on fresh Claude Code installation
  - Expected: `/plugin marketplace add changoo89/claude-pilot` → `/plugin install claude-pilot` → `/pilot:setup` succeeds
  - Test: E2E manual testing

- [ ] **SC-3**: All existing commands accessible after plugin install
  - Verify: List all commands after plugin installation
  - Expected: All 9 commands (`/00_plan` through `/999_publish`) available and functional
  - Test: `tests/test_plugin_commands.py::test_command_discovery`

- [ ] **SC-4**: Setup command configures MCP servers correctly
  - Verify: Run `/pilot:setup` and check MCP configuration
  - Expected: Recommended MCP servers (context7, serena, grep-app, sequential-thinking) configured
  - Test: `tests/test_plugin_setup.py::test_setup_command`

- [ ] **SC-5**: README updated with both installation methods
  - Verify: Check README.md has both PyPI and Plugin sections
  - Expected: Clear instructions for both methods with use cases and recommendations
  - Test: Manual review

- [ ] **SC-6**: Existing PyPI distribution unaffected
  - Verify: Install from PyPI and verify all functionality works
  - Expected: No breaking changes to existing installation method; all commands work
  - Test: `tests/test_pypi_compat.py::test_pypi_installation`

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Plugin schema validation | marketplace.json, plugin.json | Both files valid against official schemas | Integration | `tests/test_plugin_manifests.py::test_schema_validation` |
| TS-2 | 3-line install process | Fresh Claude Code install | Plugin installs and setup succeeds | E2E | Manual testing required |
| TS-3 | Command discovery after plugin install | `/list` or similar | All 9 pilot commands listed | Integration | `tests/test_plugin_commands.py::test_command_discovery` |
| TS-4 | Setup command MCP configuration | `/pilot:setup` | MCP servers configured, user prompted | Integration | `tests/test_plugin_setup.py::test_setup_command` |
| TS-5 | PyPI installation unaffected | `pip install claude-pilot` | All commands work, no breaking changes | Integration | `tests/test_pypi_compat.py::test_pypi_installation` |
| TS-6 | Component registration | Plugin installation | All agents, skills, hooks registered | Integration | `tests/test_plugin_components.py::test_component_registration` |
| TS-7 | Version compatibility | Various Claude Code versions | Works with v1.0+, graceful degradation | Integration | `tests/test_plugin_compat.py::test_version_compatibility` |
| TS-8 | Marketplace star requirement | Repository with <5 stars | Plugin installs but not in directory | E2E | Manual testing required |

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Python (Hatchling build system)
- **Test Framework**: pytest
- **Test Command**: `pytest`
- **Coverage Command**: `pytest --cov`
- **Test Directory**: `tests/`
- **Coverage Target**: 80%+ overall, 90%+ core modules
- **Plugin Testing**: Manual testing in Claude Code CLI required for E2E scenarios

---

## Execution Plan

### Phase 1: Discovery & Alignment

- [x] Read plan file and understand requirements
- [x] Explore current deployment setup (pyproject.toml, build system)
- [x] Research claude-delegator sample repository
- [x] Understand Claude Code plugin architecture
- [x] Confirm integration points with existing code

### Phase 2: Create Plugin Manifests

**Step 2.1: Create marketplace.json**
- [ ] Create `.claude-plugin/` directory
- [ ] Write `marketplace.json` with marketplace metadata
- [ ] Include official `$schema` reference
- [ ] Define marketplace name, version, owner
- [ ] Add claude-pilot as plugin entry

**Step 2.2: Create plugin.json**
- [ ] Write `plugin.json` with plugin metadata
- [ ] Reference existing `.claude/` directories (commands, agents, skills, guides)
- [ ] Define all 9 commands
- [ ] Define all 8 agents (coder, tester, validator, etc.)
- [ ] Define all skills (tdd, ralph-loop, vibe-coding, git-master)
- [ ] Reference mcp.json for MCP servers

**Step 2.3: Validate manifests**
- [ ] Validate marketplace.json against schema
- [ ] Validate plugin.json against schema
- [ ] Test all path references are correct
- [ ] Verify component names match existing files

### Phase 3: Create Setup Command

**Step 3.1: Create setup command**
- [ ] Create `.claude/commands/000_pilot_setup.md`
- [ ] Add frontmatter with command metadata
- [ ] Implement MCP server configuration logic
- [ ] Add user prompts for customization
- [ ] Add installation verification
- [ ] Add conflict detection for existing MCP servers

**Step 3.2: Test setup command**
- [ ] Run `/pilot:setup` in Claude Code
- [ ] Verify MCP servers configured
- [ ] Test with existing MCP servers (conflict detection)
- [ ] Test with fresh installation

### Phase 4: Documentation & Distribution

**Step 4.1: Update README.md**
- [ ] Add "Installation" section with two methods
- [ ] Document PyPI installation (existing method)
- [ ] Document Plugin installation (new 3-line method)
- [ ] Add use cases for each method
- [ ] Update Quick Start section
- [ ] Add migration guide section

**Step 4.2: Create CHANGELOG.md**
- [ ] Create CHANGELOG.md
- [ ] Document v4.0.5 → v4.1.0 changes
- [ ] Add plugin distribution section
- [ ] Document breaking changes (none expected)
- [ ] Add migration notes

**Step 4.3: Create migration guide**
- [ ] Create `MIGRATION.md` or add to README
- [ ] Document transition from PyPI to Plugin
- [ ] Explain benefits of plugin distribution
- [ ] Provide side-by-side comparison

### Phase 5: Verification (TDD Cycle)

**For each Success Criterion**:

#### Red Phase: Write Failing Test
1. Generate test stubs for plugin manifests
2. Write schema validation tests
3. Write command discovery tests
4. Run tests → confirm RED (failing)
5. Mark test todo as in_progress

#### Green Phase: Minimal Implementation
1. Write ONLY enough code to pass the test
2. Run tests → confirm GREEN (passing)
3. Mark test todo as complete

#### Refactor Phase: Clean Up
1. Apply Vibe Coding standards (SRP, DRY, KISS, Early Return)
2. Run ALL tests → confirm still GREEN

### Phase 6: Ralph Loop (Autonomous Completion)

**Entry**: Immediately after first code change

**Loop until**:
- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean (`mypy .`)
- [ ] Lint clean (`ruff check .`)
- [ ] All todos completed
- [ ] Plugin manifests validated
- [ ] E2E testing completed

**Max iterations**: 7

### Phase 7: Final Verification

**Parallel verification** (3 agents):
- [ ] Tester: Run tests, verify coverage, test 3-line install
- [ ] Validator: Type check, lint, schema validation
- [ ] Code-Reviewer: Review code quality, documentation

### Phase 8: Handoff

- [ ] Documentation updated (README, CHANGELOG)
- [ ] Migration guide created
- [ ] GitHub release prepared (v4.1.0)
- [ ] Summary of changes created

---

## Constraints

### Technical Constraints
- Must maintain Python 3.9+ compatibility
- Must work with Claude Code v1.0+
- Plugin manifests must follow official Anthropic schemas
- GitHub repository must be public for plugin distribution
- Must preserve all existing functionality
- No changes to core pilot logic (cli.py, initializer.py, etc.)

### Business Constraints
- No breaking changes to existing PyPI users
- Dual distribution support (PyPI + Plugin)
- Target 5+ GitHub stars for marketplace directory inclusion
- Clear documentation for both installation methods

### Quality Constraints
- **Coverage**: ≥80% overall, ≥90% core modules
- **Type Safety**: Type check must pass (`mypy .`)
- **Code Quality**: Lint must pass (`ruff check .`)
- **Standards**: Vibe Coding (functions ≤50 lines, files ≤200 lines, nesting ≤3 levels)
- **Schema Validation**: Plugin manifests must validate against official schemas

---

## Key Files to Create

### 1. `.claude-plugin/marketplace.json`

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "claude-pilot",
  "version": "4.1.0",
  "description": "SPEC-First development workflow with TDD, Ralph Loop, and autonomous agent coordination",
  "owner": {
    "name": "changoo89",
    "email": "changoo89@users.noreply.github.com"
  },
  "plugins": [
    {
      "name": "claude-pilot",
      "description": "Complete SPEC-First development workflow: Plan → Confirm → Execute → Review → Document → Close",
      "source": "./.",
      "category": "development",
      "version": "4.1.0",
      "author": {
        "name": "changoo89",
        "email": "changoo89@users.noreply.github.com"
      }
    }
  ]
}
```

### 2. `.claude-plugin/plugin.json`

```json
{
  "name": "claude-pilot",
  "version": "4.1.0",
  "description": "SPEC-First development workflow with TDD, Ralph Loop, and autonomous agent coordination for Claude Code",
  "author": {
    "name": "changoo89",
    "url": "https://github.com/changoo89"
  },
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

New setup command with:
- MCP server configuration
- User prompts for customization
- Installation verification
- Conflict detection

### 4. `CHANGELOG.md`

Version history tracking:
- v4.1.0: Plugin distribution added
- v4.0.5: Current PyPI version
- Migration notes

---

## GitHub Star Requirement

**Requirement**: 5+ GitHub stars for marketplace directory inclusion

**Current Status**: Unknown (to be checked)

**Strategy**:
1. Focus on clear documentation and examples
2. Engage with Claude Code community (Reddit, GitHub discussions)
3. Submit to claudemarketplaces.com after reaching 5 stars
4. List in awesome-claude-plugins curated list

**Note**: Plugin works regardless of star count. Stars only affect directory inclusion, not functionality.

---

## Installation Methods Comparison

| Aspect | PyPI Distribution | Plugin Distribution |
|--------|------------------|---------------------|
| **Installation** | `pipx install claude-pilot` | 3-line: `/plugin marketplace add` → `/plugin install` → `/pilot:setup` |
| **Updates** | `pip install --upgrade` | `/plugin update` |
| **Discovery** | PyPI search, documentation | GitHub, marketplace directories |
| **Components** | CLI commands only | Commands + agents + skills + hooks + MCP |
| **Integration** | Separate CLI tool | Native Claude Code integration |
| **Language** | Python-only | Language-agnostic |
| **Use Case** | Users wanting CLI tool | Claude Code users wanting native integration |

---

## Related Documentation

- **Claude Code Plugins Reference**: https://code.claude.com/docs/en/plugins-reference
- **Official Marketplace Schema**: https://github.com/anthropics/claude-code/blob/main/.claude-plugin/marketplace.json
- **Sample Plugin**: https://github.com/jarrodwatts/claude-delegator
- **Marketplace Directory**: https://claudemarketplaces.com

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-17
**Next Steps**: A) Refine plan, B) Explore alternatives, C) Run /01_confirm, D) Run /02_execute
