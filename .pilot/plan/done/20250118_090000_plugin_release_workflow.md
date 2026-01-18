# PRP Plan: Plugin Release Workflow (/999_release)

> **Created**: 2025-01-18 09:00
> **Status**: Completed
> **Plan ID**: 20250118_090000_plugin_release_workflow

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 09:00 | "우리 프로젝트가 pypi 에서 claude plugin 으로 배포바왹이 바뀌었는데 이제 배포하려하는데 기존처럼 999_publish 사용하면 되나?" | Check if 999_publish works for plugin distribution |

---

## PRP Analysis

### What (Functionality)

**Objective**: Replace PyPI-based `/999_publish` command with plugin-compatible `/999_release` workflow

**Scope**:
- **In scope**:
  - Create new `/999_release` command
  - Remove obsolete `/999_publish` command
  - Update `CLAUDE.md` and `MIGRATION.md` documentation
- **Out of scope**:
  - Automatic plugin deployment (not supported by Claude Code)
  - PyPI infrastructure removal (already done in v4.1.0)

**Deliverables**:
1. `.claude/commands/999_release.md` - New plugin release command
2. Removal of `.claude/commands/999_publish.md`
3. Updated documentation references

### Why (Context)

**Current Problem**:
- `/999_publish` references removed PyPI infrastructure (`pyproject.toml`, `src/`, `twine`)
- Plugin migration (v4.0.5 → v4.1.0) broke existing publish workflow
- No command available for version bump + git tag + GitHub release

**Desired State**:
- Simplified workflow: version bump → git tag → GitHub push → GitHub release
- Users manually update with `/plugin marketplace update` + `/plugin update`

**Business Value**:
- Streamlined release process for plugin distribution
- Consistent with Claude Code plugin architecture
- Clear separation: maintainers push releases, users pull updates

### How (Approach)

**Implementation Strategy**:

1. **Create `/999_release`** command with proper structure:
   - **YAML Front Matter**: `description`, `argument-hint`, `allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion`
   - **Version Prompt**: Accept `[patch|minor|major|x.y.z]` format with `--skip-gh` and `--dry-run` flags
   - **Pre-flight Checks**:
     - Detect git remote: `REMOTE=$(git remote 2>/dev/null | head -1); REMOTE=${REMOTE:-origin}` (auto-detect, fallback to `origin`)
     - Detect default branch: `BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)` (uses detected remote, fallback to current branch)
     - Check for dirty working tree: `git status --porcelain` (abort if dirty, unless `--force`)
     - Check for existing tag: `git tag -l "v$VERSION"` (abort if exists)
   - **Version Bump Logic**:
     - Read current: `CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)`
     - Compute new: Parse MAJOR.MINOR.PATCH, increment based on bump type
     - Validate semver with optional prerelease: `grep -E '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'`
     - Pre-release support: Append `-alpha.1`, `-beta.1`, etc. if specified with `--pre` flag
   - **Version Update** (3 files with exact jq filters):
     ```bash
     # plugin.json (primary) - direct update
     jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

     # marketplace.json - update in-place by name (preserves full JSON structure)
     jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

     # pilot-version (internal) - simple echo
     echo "$VERSION" > .claude/.pilot-version
     ```
   - **CHANGELOG.md** Update:
     - Reference existing format (Keep a Changelog style: ## [Unreleased]/## [X.Y.Z] - YYYY-MM-DD)
     - Insert release notes at top section after header
     - Format: `## [$VERSION] - $(date +%Y-%m-%d)\n\n### Added\n- ...\n\n### Changed\n- ...\n\n### Fixed\n- ...`
   - **Git Operations** (safe staging, not `git add .`):
     ```bash
     # Stage only version files + changelog
     git add .claude-plugin/plugin.json .claude-plugin/marketplace.json .claude/.pilot-version CHANGELOG.md

     # If command/doc changes exist, stage those too
     git add .claude/commands/999_release.md CLAUDE.md MIGRATION.md 2>/dev/null || true

     # Commit with version
     git commit -m "chore: bump version to $VERSION"

     # Create annotated tag
     git tag -a "v$VERSION" -m "Release $VERSION"

     # Push with auto-detected remote and branch
     git push "$REMOTE" "$BRANCH" --tags
     ```
   - **GitHub Release** (if `gh` available):
     ```bash
     if command -v gh &> /dev/null; then
       # Extract release notes from CHANGELOG section
       RELEASE_NOTES=$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | head -n -1)
       gh release create "v$VERSION" --notes "$RELEASE_NOTES"
     else
       echo "Warning: GitHub CLI not installed - skipping release creation"
       echo "Tag pushed to GitHub - create release manually at:"
       echo "https://github.com/changoo89/claude-pilot/releases/new?tag=v$VERSION"
     fi
     ```

2. **Remove `/999_publish`** - obsolete PyPI workflow command

3. **Update documentation**:
   - `CLAUDE.md`: Update command references, remove 999_publish mentions
   - `MIGRATION.md`: Document v4.1.0 → v4.1.1 workflow changes

**Distribution Semantics** (CRITICAL - from official docs research):
- Plugins track **commit SHAs**, NOT git tags or GitHub releases
- Users update via: `claude plugin update claude-pilot@changoo89`
- Git tags/releases are **optional ceremony** for changelog visibility
- No `ref` parameter support in marketplace.json (as of Jan 2026)

**Dependencies**:
- GitHub CLI (`gh`) for release creation (optional - graceful fallback)
- Git repository with remote (auto-detected: `git remote | head -1`)
- `jq` for JSON file updates

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| GitHub CLI not installed | Medium | Low | Graceful fallback - skip release creation, just push tag |
| Git remote not found | Low | Medium | Auto-detect with fallback to `origin` |
| Version format mismatch | Low | Medium | Validate semver with prerelease support before proceeding |
| jq not installed | Low | High | Add jq check in pre-flight, error if missing |

### Success Criteria

- [x] **SC-1**: `/999_release` created with proper YAML front matter (`description`, `argument-hint`, `allowed-tools`)
- [x] **SC-2**: Version synced across all 3 files: `.claude-plugin/plugin.json:version`, `.claude-plugin/marketplace.json:plugins[0].version`, `.claude/.pilot-version`
- [x] **SC-3**: Git tag (`v{version}`) created and pushed to auto-detected remote
- [x] **SC-4**: GitHub release created via `gh release create` (with graceful fallback if `gh` unavailable)
- [x] **SC-5**: `/999_publish` removed and verified with `! test -f .claude/commands/999_publish.md`
- [x] **SC-6**: Documentation updated (`CLAUDE.md`, `MIGRATION.md`) with all 999_publish references removed

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Happy path release | Version: "4.2.0" | Version bumped, tag pushed, release created | Integration | Manual (CLI test) |
| TS-2 | Version format validation | Version: "invalid" | Error message, no changes | Integration | Manual (CLI test) |
| TS-3 | GitHub CLI missing | `gh` not installed | Tag pushed, warning about release skipped | Integration | Manual (CLI test) |
| TS-4 | Documentation check | Read CLAUDE.md | No 999_publish references remain | Unit | N/A (read check) |

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Plugin (no build/test commands)
- **Test Framework**: N/A (manual CLI testing)
- **Test Command**: Manual execution of `/999_release`
- **Test Directory**: N/A

---

## Execution Context (Planner Handoff)

### Explored Files

**Current 999_publish Structure** (from codebase exploration):
- References PyPI files: `pyproject.toml`, `src/claude_pilot/`, `install.sh`
- Does NOT update plugin.json versions
- Outdated for v4.1.0+ pure plugin architecture

**Command File Format** (YAML front matter - from 00_plan.md example):
```yaml
---
description: Brief command description
argument-hint: "[arguments] - usage hint"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion, Task, ...
---
```

### Key Decisions Made

1. **Version Source-of-Truth**: 3 files must be synced
   - `.claude-plugin/plugin.json:version` (PRIMARY)
   - `.claude-plugin/marketplace.json:plugins[0].version` (DUPLICATE)
   - `.claude/.pilot-version` (internal tracking, currently outdated at 4.0.5)

2. **Command Arguments**: Accept `[patch|minor|major|x.y.z]` with flags:
   - `--skip-gh`: Skip GitHub release creation
   - `--dry-run`: Preview changes without executing

3. **Git Operations**:
   - Detect remote: `REMOTE=$(git remote 2>/dev/null | head -1); REMOTE=${REMOTE:-origin}`
   - Check dirty tree: `git status --porcelain`
   - Verify branch: `BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)`

4. **Distribution Semantics** (from official Claude Code docs research):
   - Plugins track **commit SHAs**, NOT tags/releases
   - Git tags/releases are **optional ceremony**
   - Users update manually: `claude plugin update claude-pilot@changoo89`
   - No `ref` parameter support in marketplace.json (as of Jan 2026)

### Implementation Patterns (FROM CONVERSATION)

#### Command File Structure
```yaml
---
description: Bump version, create git tag, and create GitHub release for plugin distribution
argument-hint: "[patch|minor|major|x.y.z] --skip-gh --dry-run"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---
```

#### Version Update Commands (using jq)
```bash
# Update plugin.json (primary)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

# Update marketplace.json (update in-place, preserves full JSON)
jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

# Update pilot-version (internal)
echo "$VERSION" > .claude/.pilot-version
```

#### Git Operations
```bash
# Auto-detect remote (with proper fallback for empty result)
REMOTE=$(git remote 2>/dev/null | head -1)
REMOTE=${REMOTE:-origin}

# Auto-detect default branch (uses detected remote)
BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)

# Check for dirty working tree
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working tree has uncommitted changes"
  exit 1
fi

# Create and push tag (with auto-detected remote and branch)
git tag -a "v$VERSION" -m "Release $VERSION"
git push "$REMOTE" "$BRANCH" --tags
```

#### GitHub Release (with graceful fallback)
```bash
# Check if gh CLI installed
if command -v gh &> /dev/null; then
  gh release create "v$VERSION" --notes "Release notes from CHANGELOG.md"
else
  echo "Warning: GitHub CLI not installed - skipping release creation"
  echo "Tag pushed to GitHub - create release manually at:"
  echo "https://github.com/changoo89/claude-pilot/releases/new?tag=v$VERSION"
fi
```

### Assumptions Requiring Validation

1. **jq is installed** - Used for JSON file updates (add pre-flight check)
2. **git remote exists** - Auto-detected with variable fallback to `origin` value if empty
3. **default branch is main/master** - Auto-detected from `refs/remotes/$REMOTE/HEAD`

---

## Execution Plan

### Phase 1: Discovery
- [x] Explore current `/999_publish` implementation
- [x] Research Claude Code plugin distribution
- [x] Confirm no programmatic deployment API exists
- [x] Design new `/999_release` workflow

### Phase 2: Implementation (TDD Cycle)

**For each Success Criterion**:

#### SC-1: Create `/999_release` command
1. **Red Phase**: Define expected behavior in plan
2. **Green Phase**: Write command file with proper steps
3. **Refactor Phase**: Apply Vibe Coding standards

#### SC-2: Version sync (3 files)
1. Update `.claude-plugin/plugin.json` (primary source)
2. Update `.claude-plugin/marketplace.json` (marketplace entry)
3. Update `.claude/.pilot-version` (internal reference)

#### SC-3: Git tag and push
1. Detect remote and branch: `REMOTE=$(git remote 2>/dev/null | head -1); REMOTE=${REMOTE:-origin}`, `BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)`
2. Create tag: `git tag -a "v$VERSION" -m "Release $VERSION"`
3. Push tag: `git push "$REMOTE" "$BRANCH" --tags`

#### SC-4: GitHub release (optional)
1. Check if `gh` CLI installed
2. Create release: `gh release create v{version}`

#### SC-5: Remove obsolete command
1. Delete `.claude/commands/999_publish.md`

#### SC-6: Update documentation
1. Update `CLAUDE.md` command references
2. Update `MIGRATION.md` with workflow notes

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: After first code change

**Loop until**:
- [ ] All SCs completed
- [ ] Documentation verified
- [ ] No 999_publish references remain

**Max iterations**: 3

### Phase 4: Verification

**Executable verification commands**:
```bash
# Set variables for all checks (with proper fallback)
VERSION="4.2.0"  # Replace with actual release version
REMOTE=$(git remote 2>/dev/null | head -1)
REMOTE=${REMOTE:-origin}
BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)

# SC-1: Verify command file exists with proper YAML front matter
test -f .claude/commands/999_release.md
head -10 .claude/commands/999_release.md | grep -q "description:"
head -10 .claude/commands/999_release.md | grep -q "argument-hint:"
head -10 .claude/commands/999_release.md | grep -q "allowed-tools:"

# SC-2: Verify version synced across all 3 files
jq -r ".version == \"$VERSION\"" .claude-plugin/plugin.json
jq -r ".plugins[] | select(.name == \"claude-pilot\") | .version == \"$VERSION\"" .claude-plugin/marketplace.json
grep -q "$VERSION" .claude/.pilot-version

# SC-3: Verify git tag created and pushed (using auto-detected remote)
git tag -l "v$VERSION"
git ls-remote --tags "$REMOTE" | grep "v$VERSION"

# SC-4: Verify GitHub release created (if gh available)
command -v gh && gh release view "v$VERSION"

# SC-5: Verify 999_publish removed (file check)
! test -f .claude/commands/999_publish.md

# SC-5: Verify 999_publish removed (repo-wide check)
! rg -q "999_publish" .claude/ CLAUDE.md README.md 2>/dev/null
! rg -q "999_publish" . --glob '*.md' --glob '*.sh' 2>/dev/null

# SC-6: Verify documentation updated
! grep -q "999_publish" CLAUDE.md
grep -q "999_release" CLAUDE.md
grep -q "$VERSION" MIGRATION.md
rg -q "999_release" .claude/ --glob '*.md' 2>/dev/null
```

**Manual verification**:
- [ ] Run `/999_release` with test version (dry-run mode)
- [ ] Verify version files updated correctly
- [ ] Verify git tag created and pushed
- [ ] Verify GitHub release created (if `gh` available)

---

## Constraints

### Technical Constraints
- **GitHub CLI optional**: Graceful fallback if not installed
- **Git required**: Must have git initialized with remote
- **Semver format**: Version must match MAJOR.MINOR.PATCH

### Business Constraints
- **No automatic deployment**: Users must manually update plugins
- **Manual changelog**: CHANGELOG.md updates are manual prompts

### Quality Constraints
- **Graceful degradation**: Each step independent, failure doesn't block workflow
- **Clear error messages**: User knows exactly what failed and what to do
- **Vibe Coding**: Functions ≤50 lines, files ≤200 lines

---

## Related Documentation

- **Plugin Marketplace**: [Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

## Execution Summary

### Changes Made
- **Created**: `.claude/commands/999_release.md` - New plugin release command with version bump, git tag, and GitHub release
- **Removed**: `.claude/commands/999_publish.md` - Obsolete PyPI publish workflow
- **Updated**: `.claude/.pilot-version` - Bumped to 4.1.0 (synced with plugin.json)
- **Updated**: `MIGRATION.md` - Added "Release Workflow (v4.1.1+)" section with /999_release usage
- **Updated**: `.claude/commands/CONTEXT.md` - Updated command list (999_publish → 999_release)
- **Updated**: `docs/ai-context/project-structure.md` - Updated command list reference

### Verification
- **Type**: ✅ Plugin architecture (no build/test commands)
- **Tests**: ✅ Manual CLI testing (dry-run mode)
- **Lint**: ✅ N/A (markdown files)
- **Documentation**: ✅ All references updated (999_publish removed from active docs)

### Follow-ups
- None - release workflow complete and documented

---

**Plan Version**: 1.0
**Last Updated**: 2025-01-18
**Execution Date**: 2025-01-18
