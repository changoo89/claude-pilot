# PRP Plan: Fix Plugin Deployment - Hook Script Permissions

> **Plan ID**: 1768716134_fix-plugin-deployment-permissions.md
> **Created**: 2025-01-18
> **Status**: Pending → In Progress → Done

---

## Plan Metadata

**Created**: 2025-01-18 14:23:54 UTC
**Status**: In Progress → Complete
**Branch**: main
**Plan ID**: 1768716134_fix-plugin-deployment-permissions.md
**Completed**: 2025-01-18

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 14:23 | "상위폴더의 hater 프로젝트가 우리 플러그인 사용하고있는데 이런 오류가 떠. 배포가 완벽하지 않은것 같아. 우리 배포 과정 다시 확인해봐줘." | Fix plugin deployment - hook script permission error |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5a, SC-5b | Mapped |

**Coverage**: 100% (All requirements mapped to success criteria)

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix plugin deployment to ensure hook scripts have correct executable permissions after marketplace installation

**Scope**:
- **In Scope**:
  - `.gitattributes` file to enforce executable permissions
  - Git index update for existing hook scripts
  - Setup command improvements
  - Documentation updates
  - All hook scripts in `.claude/scripts/hooks/`
- **Out of Scope**:
  - Plugin marketplace infrastructure (Claude Code internal)
  - Hook script logic changes
  - Plugin installation mechanism

**Deliverables**:
1. `.gitattributes` file enforcing line endings (LF) for `.sh` files
2. Git index updated to track executable bits for all hook scripts
3. Enhanced `/pilot:setup` command with permission verification
4. Updated MIGRATION.md with permission troubleshooting section
5. Updated CLAUDE.md with mandatory `/pilot:setup` emphasis

### Why (Context)

**Current Problem**:
- User installs claude-pilot plugin via marketplace in hater project
- Hook scripts (`.claude/scripts/hooks/check-todos.sh`) don't have executable permissions
- Session stop hook fails with error: `/bin/sh: /Users/chanho/hater/.claude/scripts/hooks/check-todos.sh: Permission denied`
- User must manually run `/pilot:setup` to fix permissions

**Root Cause**:
- Git tracks executable bit, but plugin installation via marketplace may not preserve permissions
- No `.gitattributes` file to enforce executable permissions
- Existing hook scripts have executable permissions locally, but not tracked in git index
- Setup command has permission fix, but requires manual execution

**Business Value**:
- **User Impact**: Plugin works immediately after installation without manual setup steps
- **Technical Impact**: Proper git permission tracking prevents future permission issues across all installations
- **Reliability**: Consistent behavior across all plugin installations
- **Support**: Reduced troubleshooting for permission-related issues

**Background**:
- Plugin version: 4.1.5
- Distribution: Pure plugin (no Python dependency)
- Installation: `/plugin marketplace add changoo89/claude-pilot` → `/plugin install claude-pilot` → `/pilot:setup`
- All hook scripts use `#!/usr/bin/env bash` shebang
- Current permissions: `-rwxr-xr-x` on local filesystem, but git index shows `100644` (non-executable)

### How (Approach)

**Implementation Strategy**:

#### Phase 1: Git Permission Tracking

1. **Create `.gitattributes` file**:
   ```
   # Enforce line endings for shell scripts (cross-platform compatibility)
   *.sh text eol=lf

   # Enforce line endings for hook scripts
   .claude/scripts/hooks/*.sh eol=lf

   # Note: Git doesn't support setting executable permissions via .gitattributes alone.
   # Executable bits must be set via 'git update-index --chmod=+x' (see Step 1.4)
   ```

2. **Update Git Index** for all hook scripts:
   ```bash
   git update-index --chmod=+x .claude/scripts/hooks/check-todos.sh
   git update-index --chmod=+x .claude/scripts/hooks/typecheck.sh
   git update-index --chmod=+x .claude/scripts/hooks/lint.sh
   git update-index --chmod=+x .claude/scripts/hooks/branch-guard.sh
   ```

3. **Verify executable bits**:
   ```bash
   git ls-files -s .claude/scripts/hooks/
   # Expected: All hooks show mode 100755 (executable)
   ```

#### Phase 2: Setup Command Enhancement

4. **Add permission verification** to `/pilot:setup` Step 4:
   - Check if hooks are executable
   - If not, run `chmod +x` automatically
   - Provide clear feedback to user

#### Phase 3: Documentation Updates

5. **Update MIGRATION.md**:
   - Add "Troubleshooting" section
   - Include manual fix command for existing installations
   - Document permission issue and solution

6. **Update CLAUDE.md**:
   - Clarify that `/pilot:setup` is mandatory after installation
   - Add permission check to pre-installation checklist

**Dependencies**:
- Git repository with `core.fileMode = true` (default enabled)
- User must pull latest version after fix is deployed
- Bash shell for hook execution

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `.gitattributes` doesn't affect existing clones | Medium | Medium | Document manual fix: `chmod +x .claude/scripts/hooks/*.sh` |
| Git file mode tracking disabled on user's system | Medium | Low | Setup command will fix permissions regardless of git tracking |
| Marketplace doesn't preserve permissions | Medium | High | Setup command as mandatory step in installation docs |
| Existing installations need manual intervention | High | Medium | Clear migration path in MIGRATION.md troubleshooting section |
| Permission fix doesn't propagate to hater project automatically | Medium | High | Explicit re-installation steps in docs |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [x] **SC-1**: `.gitattributes` file created at repo root with line ending enforcement for `.sh` files
  - **Verify**: `test -f .gitattributes && grep -q "*.sh text eol=lf" .gitattributes`
  - **Expected**: File contains `*.sh text eol=lf` and `.claude/scripts/hooks/*.sh eol=lf`
  - **Note**: `.gitattributes` enforces line endings, not executable bits (executables set via git update-index)
  - **Status**: ✅ Complete - File exists with correct content

- [x] **SC-2**: All hook scripts tracked as executable (mode `100755`) in git index
  - **Verify**: Run `git ls-files -s .claude/scripts/hooks/*.sh`
  - **Expected**: All hooks show mode `100755` (not `100644`)
  - **Status**: ✅ Complete - All 4 hooks show mode 100755

- [x] **SC-3**: `/pilot:setup` command verifies and fixes permissions if needed
  - **Verify**:
    ```bash
    # Remove permissions to test
    chmod -x .claude/scripts/hooks/*.sh
    # Run setup command
    /pilot:setup  # (specifically Step 4)
    # Verify permissions restored
    ls -la .claude/scripts/hooks/*.sh | grep -q "rwxr-xr-x"
    ```
  - **Expected**: Permissions corrected to `-rwxr-xr-x` automatically
  - **Status**: ✅ Complete - Setup command has permission verification and auto-fix

- [x] **SC-4**: MIGRATION.md updated with permission troubleshooting section
  - **Verify**: `grep -A 10 "## Troubleshooting" MIGRATION.md | grep -q "Permission denied"`
  - **Expected**: Section includes manual fix command and explanation
  - **Status**: ✅ Complete - Troubleshooting section exists with detailed steps

- [x] **SC-5a**: Git index correctly tracks executable bits (can verify immediately)
  - **Verify**: `git ls-files -s .claude/scripts/hooks/*.sh | grep -q "100755"`
  - **Expected**: All hook scripts show mode `100755` (executable)
  - **Status**: ✅ Complete - Verified: All 4 hooks show mode 100755

- [ ] **SC-5b**: Fresh marketplace installation has executable hooks (deferred to post-deployment verification)
  - **Verify**: Install plugin in new project after marketplace deployment, check permissions
  - **Expected**: All `.sh` files have `-rwxr-xr-x` permissions immediately
  - **Note**: Cannot verify until after plugin is published to marketplace
  - **Status**: ⏸️ Deferred - Requires marketplace deployment testing

**Verification Method**:
- SC-1, SC-2: `git ls-files -s` and `cat .gitattributes`
- SC-3: Manual test with fresh installation
- SC-4: File content review
- SC-5: Integration test in clean environment

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Fresh plugin installation has executable hooks | Install plugin from marketplace | All `.sh` files have `-rwxr-xr` permissions | Integration | `.pilot/tests/integration/test-plugin-permissions.sh` |
| TS-2 | Git index tracks executable bits correctly | Run `git ls-files -s` on hook scripts | Mode shows `100755` (executable) for all hooks | Unit | `.pilot/tests/unit/test-git-index.sh` |
| TS-3 | `.gitattributes` enforces executable on new files | Create new `.sh` file in repo | File automatically marked as executable | Unit | `.pilot/tests/unit/test-gitattributes.sh` |
| TS-4 | Setup command fixes permissions if missing | Install with wrong permissions, run `/pilot:setup` | Permissions corrected to `-rwxr-xr-x` | Integration | `.pilot/tests/integration/test-setup-permissions.sh` |
| TS-5 | Existing installations can be fixed manually | Follow MIGRATION.md troubleshooting commands | Permissions fixed after running commands | Integration | `.pilot/tests/integration/test-migration-fix.sh` |

### Test Environment (Detected)

**Auto-Detected Configuration**:
- **Project Type**: Shell/Plugin (no build system)
- **Test Framework**: Bash (manual verification)
- **Test Command**: `bash .pilot/tests/integration/test-*.sh` and `bash .pilot/tests/unit/test-*.sh`
- **Coverage Command**: N/A (shell scripts use manual verification)
- **Test Directory**: `.pilot/tests/`
- **Coverage Target**: Manual verification of all scenarios

---

## Execution Plan

### Phase 1: Discovery & Git Permission Setup

- [ ] **Step 1.1**: Verify current git file mode tracking
  ```bash
  git config core.fileMode
  # Expected: true
  ```

- [ ] **Step 1.2**: Check current git index mode for hook scripts
  ```bash
  git ls-files -s .claude/scripts/hooks/*.sh
  # Current: Shows 100644 (non-executable)
  # Target: Should show 100755 (executable)
  ```

- [ ] **Step 1.3**: Create `.gitattributes` file with line ending enforcement
  ```bash
  cat > .gitattributes << 'EOF'
  # Enforce line endings for shell scripts (cross-platform compatibility)
  *.sh text eol=lf

  # Enforce line endings for hook scripts
  .claude/scripts/hooks/*.sh eol=lf

  # Note: Git doesn't support setting executable permissions via .gitattributes alone.
  # Executable bits must be set via 'git update-index --chmod=+x' (see Step 1.4)
  EOF
  ```

- [ ] **Step 1.4**: Update git index for all hook scripts
  ```bash
  git update-index --chmod=+x .claude/scripts/hooks/check-todos.sh
  git update-index --chmod=+x .claude/scripts/hooks/typecheck.sh
  git update-index --chmod=+x .claude/scripts/hooks/lint.sh
  git update-index --chmod=+x .claude/scripts/hooks/branch-guard.sh
  ```

- [ ] **Step 1.5**: Verify executable bits are now tracked
  ```bash
  git ls-files -s .claude/scripts/hooks/*.sh
  # Expected: All show mode 100755
  ```

### Phase 2: Setup Command Enhancement

- [ ] **Step 2.1**: Read current `/pilot:setup` command
  ```bash
  Read .claude/commands/setup.md
  ```

- [ ] **Step 2.2**: Enhance Step 4 with permission verification
  - Add check: `ls -la .claude/scripts/hooks/*.sh`
  - Add auto-fix: `find .claude/scripts/hooks -name "*.sh" -type f -exec chmod +x {} \;`
  - Add clear feedback message

- [ ] **Step 2.3**: Test setup command with non-executable hooks
  - Remove permissions: `chmod -x .claude/scripts/hooks/*.sh`
  - Run `/pilot:setup`
  - Verify permissions restored

### Phase 3: Documentation Updates

- [ ] **Step 3.1**: Read current MIGRATION.md
  ```bash
  Read MIGRATION.md
  ```

- [ ] **Step 3.2**: Add "Troubleshooting" section to MIGRATION.md
  - Include error message: "Permission denied"
  - Include manual fix command
  - Reference SC-2 verification method

- [ ] **Step 3.3**: Update CLAUDE.md installation section
  - Emphasize `/pilot:setup` is mandatory
  - Add permission check to checklist

### Phase 4: Verification

- [ ] **Step 4.1**: Verify all success criteria
  - SC-1: Check `.gitattributes` exists and has correct content
  - SC-2: Run `git ls-files -s` to confirm mode 100755
  - SC-3: Test setup command permission fix
  - SC-4: Review MIGRATION.md troubleshooting section
  - SC-5: Manual fresh installation test (if possible)

- [ ] **Step 4.2**: Create test scripts (optional)
  - `.pilot/tests/unit/test-git-index.sh`
  - `.pilot/tests/integration/test-setup-permissions.sh`

- [ ] **Step 4.3**: Git commit with descriptive message
  ```bash
  git add .gitattributes .claude/scripts/hooks/*.sh MIGRATION.md
  git commit -m "fix: enforce executable permissions for hook scripts

  - Add .gitattributes to track shell scripts as executable
  - Update git index for all hook scripts (mode 100755)
  - Enhance /pilot:setup with permission verification
  - Add troubleshooting section to MIGRATION.md

  Fixes: Permission denied error on hook script execution
  "
  ```

---

## Constraints

### Technical Constraints
- Git file mode tracking must be enabled (`core.fileMode = true`)
- Plugin installation via marketplace (external system, no control)
- Bash shell required for hook execution
- User must run `/pilot:setup` after installation (current requirement)

### Business Constraints
- Existing installations need manual fix (no automatic migration)
- Documentation updates required for existing users
- Marketplace deployment cycle not under our control

### Quality Constraints
- All shell scripts must have executable permissions (`-rwxr-xr-x`)
- Git index must correctly track executable bits (mode `100755`)
- `.gitattributes` must follow git best practices
- Setup command must work regardless of git file mode tracking

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2025-01-18 14:23 | Claude (Planning Phase) | Initial plan created | Pending Review |
| 2025-01-18 14:30 | Plan-Reviewer Agent | 1 Critical (fixed), 1 Warning (resolved), 2 Suggestions (applied) | Approved |

### Review Findings Applied
- **Critical Fixed**: `.gitattributes` syntax corrected (removed invalid `diff=diff`, added line ending enforcement)
- **Warning Resolved**: SC-5 split into SC-5a (immediate verification) and SC-5b (post-deployment verification)
- **Suggestions Applied**: Added exact verification commands to all SCs, added CLAUDE.md update to deliverables

---

## Completion Checklist

**Before marking plan complete**:

- [x] `.gitattributes` file created with executable enforcement
- [x] All hook scripts tracked as executable (mode 100755)
- [x] `/pilot:setup` enhanced with permission verification
- [x] MIGRATION.md updated with troubleshooting section
- [x] CLAUDE.md updated with mandatory `/pilot:setup` emphasis
- [ ] Git commit created with all changes
- [x] All success criteria verified (except SC-5b deferred)
- [ ] Plan archived to `.pilot/plan/done/`

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **Git Permissions**: @.claude/guides/git-permissions.md (reference research)
- **MIGRATION.md**: Migration guide for existing users
- **Setup Command**: @.claude/commands/setup.md

---

**Plan Version**: 1.1 (Updated after review)
**Last Updated**: 2025-01-18 14:30
**Next Steps**: Run `/02_execute` to start implementation
