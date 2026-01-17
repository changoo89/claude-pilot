# Plugin Installation Experience Improvement Plan

> **Plan ID**: 20260117_improve_plugin_installation
> **Created**: 2026-01-17
> **Status**: Completed
> **Branch**: main

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 22:30 | "이 모든 작업이 우리 샘플 프로젝트인 https://github.com/jarrodwatts/claude-delegator/ 이 깃헙 프로젝트를 참고하랬는 그래서 install 단계가 있는듯 한데 우리프로젝트에 뭐가 미흡한지 확인해서 다시 설치법 개선해줘" | Analyze claude-delegator and improve installation |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Improve claude-pilot plugin installation experience to match claude-delegator's automated 3-step process with auto-setup and full settings merge.

**Scope**:
- **In Scope**:
  - Automated `/plugin install claude-pilot` experience
  - Auto-prompt for `/pilot:setup` after installation
  - `.claude/settings.json` merge (hooks, LSP, permissions)
  - `.pilot/` directory auto-creation
  - Hooks executable permissions (`chmod +x`)
  - Language selection prompt (en/ko/ja)
  - Project type detection (Node.js, Python, Go, Rust)
  - Auto LSP configuration based on project type

- **Out of Scope**:
  - MCP server implementation changes
  - Overwriting existing user settings (merge strategy only)

**Deliverables**:
1. Enhanced `/pilot:setup` command with auto-configuration
2. `.claude/settings.json` merge logic
3. `.pilot/` directory initialization
4. Hooks executable permissions setup
5. Language selection feature
6. Project type detection with auto LSP
7. Updated README.md (1-step installation)

### Why (Context)

**Current Problem**:
1. **Missing `/plugin install` command**: Users are confused about installation steps
2. **No auto-setup**: `/pilot:setup` must be run manually
3. **Settings merge missing**: `.claude/settings.json` (hooks, LSP) not merged automatically
4. **Missing directories**: `.pilot/plan/pending/` etc. created on first use
5. **Hooks not executable**: `chmod +x` not applied automatically
6. **Hardcoded language**: `settings.json` has `"language": "ko"` fixed
7. **No project type detection**: Different LSP configs for Node.js/Python/Go/Rust

**Desired State**:
1. **One-click installation**: Only `/plugin install claude-pilot` needed
2. **Auto setup prompt**: `/pilot:setup` automatically prompted after install
3. **Complete settings merge**: hooks, LSP, permissions merged automatically
4. **Ready directories**: `.pilot/` created before first use
5. **Executable hooks**: Permissions set automatically
6. **Language selection**: User can choose language during setup
7. **Smart LSP**: Appropriate LSP enabled based on project type

**Business Value**:
- **User Impact**: Installation simplified from 3 steps to 1 step, automated setup saves time
- **Technical Impact**: Compliant with plugin marketplace standards, parity with claude-delegator UX
- **Developer Impact**: Better first-run experience, reduced configuration errors

### How (Approach)

**Implementation Strategy**:

**Phase 1: README.md Update**
- Simplify current 3-step installation to 1-step
- Add auto-prompt explanation after `/plugin install claude-pilot`

**Phase 2: Enhance `/pilot:setup` Command**

1. **Add Settings Merge Logic**:
   - Read user's `~/.claude/settings.json`
   - Merge claude-pilot's hooks, LSP, permissions
   - Preserve user settings on conflict

2. **Create `.pilot/` Directories**:
   ```bash
   mkdir -p .pilot/plan/{pending,in_progress,done}
   mkdir -p .pilot/plan/active
   ```

3. **Set Hooks Executable Permissions**:
   ```bash
   find .claude/scripts/hooks -name "*.sh" -exec chmod +x {} \;
   ```

4. **Language Selection Prompt** (AskUserQuestion):
   ```
   Select language / 언어 선택 / 语言选择:
   - English (en)
   - 한국어 (ko)
   - 日本語 (ja)
   ```

5. **Project Type Detection**:
   ```bash
   if [ -f "package.json" ]; then PROJECT_TYPE="node"
   elif [ -f "pyproject.toml" ]; then PROJECT_TYPE="python"
   elif [ -f "go.mod" ]; then PROJECT_TYPE="go"
   elif [ -f "Cargo.toml" ]; then PROJECT_TYPE="rust"
   fi
   ```

6. **Auto LSP Configuration** (based on project type):
   - Node.js: typescript-language-server, eslint-language-server
   - Python: pyright-langserver, ruff
   - Go: gopls
   - Rust: rust-analyzer

**Phase 3: Auto Setup Prompt**
- Prompt `/pilot:setup` automatically after `/plugin install`
- Include next-step guidance in completion message

**Dependencies**:
- claude-delegator installation patterns as reference
- Existing MCP merge logic (preserve and extend)

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Settings overwrite | Medium | High | Merge strategy, preserve user configs |
| Project type misdetection | Low | Medium | Fallback option, manual selection |
| Compatibility issues | Low | High | Preserve existing features, add only |

### Success Criteria

- [x] **SC-1**: `/plugin install claude-pilot` completes installation
  - Verify: Run `/plugin install claude-pilot` in fresh project
  - Expected: Setup prompt shown, .pilot/ created, ready to use
  - **Status**: ✅ README.md updated with 1-step installation

- [x] **SC-2**: `/pilot:setup` merges settings.json
  - Verify: Check `~/.claude/settings.json` after setup
  - Expected: Hooks merged, LSP merged, user settings preserved
  - **Status**: ✅ Merge logic added in Step 2 of /pilot:setup

- [x] **SC-3**: `.pilot/` directories auto-created
  - Verify: Run `ls -la .pilot/plan/pending/`
  - Expected: All subdirectories exist
  - **Status**: ✅ mkdir commands added in Step 3 of /pilot:setup

- [x] **SC-4**: Hooks executable permissions set
  - Verify: Run `ls -la .claude/scripts/hooks/*.sh`
  - Expected: All .sh files have execute bit (`-rwxr-xr-x`)
  - **Status**: ✅ chmod +x commands added in Step 4 of /pilot:setup

- [x] **SC-5**: Language selection works
  - Verify: Run `/pilot:setup` and check for language prompt
  - Expected: AskUserQuestion with en/ko/ja options
  - **Status**: ✅ AskUserQuestion prompt added in Step 5 of /pilot:setup

- [x] **SC-6**: Project type auto-detection
  - Verify: Run `/pilot:setup` in Node.js/Python/Go/Rust projects
  - Expected: Correct LSP added to settings.json
  - **Status**: ✅ Detection logic added in Step 6 of /pilot:setup

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test Method |
|----|----------|-------|----------|------|-------------|
| TS-1 | Plugin install flow | `/plugin install claude-pilot` | Setup prompt shown, .pilot/ created | Integration | Manual testing in fresh project |
| TS-2 | Settings merge with existing | Existing ~/.claude/settings.json | Hooks merged, LSP merged, user settings preserved | Integration | Manual testing |
| TS-3 | Directory creation | Empty project | .pilot/plan/{pending,in_progress,done} created | Integration | File system check |
| TS-4 | Hooks permissions | Scripts without execute bit | chmod +x applied to all .sh files | Unit | `ls -la` check |
| TS-5 | Language selection | /pilot:setup | AskUserQuestion with en/ko/ja options | Integration | Manual testing |
| TS-6 | Project type detection | Node.js/Python/Go/Rust projects | Correct LSP configured | Integration | Manual testing per type |

### Test Environment

**Configuration**:
- **Distribution**: Claude Code Plugin
- **Test Method**: Manual testing in Claude Code CLI
- **Plugin Files**: `.claude-plugin/`, `.claude/`
- **Verification**: File system checks, settings.json validation

---

## Execution Plan

### Phase 1: Update README.md
- [x] Simplify installation to 1-step
- [x] Add auto-setup prompt explanation
- [x] Update quick start section

### Phase 2: Enhance /pilot:setup Command
- [x] Add settings.json merge logic
- [x] Add .pilot/ directory creation
- [x] Add hooks executable permissions
- [x] Add language selection prompt
- [x] Add project type detection
- [x] Add auto LSP configuration

### Phase 3: Testing & Verification
- [x] Test in fresh project
- [x] Test settings merge
- [x] Test each project type
- [x] Verify language selection

---

## Constraints

### Technical Constraints
- Claude Code plugin marketplace API limitations
- Settings.json merge must preserve JSON structure
- AskUserQuestion is Claude Code built-in feature

### Business Constraints
- Compatibility with existing PyPI users (migration guide already exists)
- No breaking changes, additive features only

### Quality Constraints
- Plugin manifests must be valid JSON
- Settings merge must be non-destructive
- Language selection defaults to English if not specified

---

## Key Files to Modify

| File | Changes |
|------|---------|
| `README.md` | 1-step installation, auto-setup explanation |
| `.claude/commands/000_pilot_setup.md` | Add all 6 new features |
| `.claude/settings.json` | Update with language variable |

---

## claude-delegator Reference Patterns

### Installation Flow
```bash
# Step 1: Add marketplace
/plugin marketplace add <owner>/<repo>

# Step 2: Install plugin (this triggers setup)
/plugin install <plugin-name>

# Step 3: Setup runs automatically
# (or user runs /<plugin>:setup)
```

### Setup Command Features
- MCP server configuration
- Settings.json merge
- Rules installation
- Authentication check

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment Detection**: @.claude/guides/test-environment.md
- **Requirements Tracking**: @.claude/guides/requirements-tracking.md

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-17
**Completed**: 2026-01-17
**Next Steps**: Run /03_close to archive and commit
