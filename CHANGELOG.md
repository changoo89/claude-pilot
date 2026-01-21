# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.3.4] - 2026-01-21

### Performance
  - **Hooks Simplification**: Removed over-engineered Stop hooks causing 7+ minute delays
  - Removed quality-dispatch.sh, cache.sh, typecheck.sh, lint.sh (944+ lines of code)
  - Replaced with simple pre-commit hook (40 lines) for JSON syntax validation only
  - No Claude Code hooks (Stop/PreToolUse) to avoid performance overhead on every Bash command

### Changed
  - settings.json: Removed Stop hooks configuration
  - Removed quality.mode, cache_ttl, debounce_seconds settings (no longer needed)
  - Pre-commit hook now runs only on staged files via Git native hooks

### Fixed
  - Bash commands no longer blocked by typecheck/lint after every execution
  - Simple git operations complete in seconds instead of minutes

## [4.3.3] - 2026-01-21

### Fixed
  - Exclude .claude/rules/** from dead code cleanup
  - Fix 02_execute plan detection bug
  - Fix plan detection bug and add draft status to statusline

### Changed
  - Remove runtime state and backup files from git tracking
  - Add .pilot/ and .claude-pilot/ to .gitignore
  - Complete git files audit and cleanup plan
  - Command Structure Reorganization

### Documentation
  - Add Documentation Cleanup Exclusions to /05_cleanup Command
  - Add Documentation Cleanup to /05_cleanup Command
  - Claude-Pilot Meta-Skill Documentation
  - Archive GitHub SEO optimization plan
  - Optimize GitHub SEO with updated description and badges
  - Remove .pilot-version references from documentation (deprecated in v4.3.0)
  - Update CI/CD integration docs for 2-file validation
  - Completely rewrite 999_release.md for jq-based workflow
  - Update release REFERENCE.md examples
  - Sync all version files to 4.3.3

## [5.0.0] - 2026-01-20

### ⚠️ BREAKING CHANGES

**Command Structure Reorganization**: The command structure has been reorganized for better clarity and consistency. User workflow commands (00-05) remain unchanged, but utility commands have been renamed.

#### Command Changes

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `/90_review` | `/review` | Removed numbering |
| `/91_document` | `/document` | Removed numbering |
| `/92_init` | → merged into `/setup` | Use `/setup` for initialization |
| `/99_continue` | `/continue` | Removed numbering |
| `/00_plan` | `/00_plan` | ✅ Unchanged |
| `/01_confirm` | `/01_confirm` | ✅ Unchanged |
| `/02_execute` | `/02_execute` | ✅ Unchanged |
| `/03_close` | `/03_close` | ✅ Unchanged |
| `/04_fix` | `/04_fix` | ✅ Unchanged |
| `/05_cleanup` | `/05_cleanup` | ✅ Unchanged |
| `/999_release` | `/999_release` | ✅ Unchanged (hidden) |

#### Migration Guide

**For Existing Users**:

1. **Update your documentation references**:
   - Search for `/90_review` → replace with `/review`
   - Search for `/91_document` → replace with `/document`
   - Search for `/92_init` → replace with `/setup` or remove
   - Search for `/99_continue` → replace with `/continue`

2. **Update any scripts or aliases**:
   ```bash
   # Old
   /90_review

   # New
   /review
   ```

3. **3-Tier Documentation Initialization**:
   - Old: `/92_init` to initialize 3-Tier Documentation System
   - New: Run `/setup` and choose "Yes" when prompted to initialize 3-Tier Documentation

#### What Changed

**Rationale**:
- User workflow commands (00-05) keep their numbered naming for clear ordering
- Utility commands use verb-first naming for better GitHub discoverability
- 92_init functionality merged into `/setup` to eliminate redundancy
- 999_release remains 3-digit to stay hidden (admin-only command)

**File Changes**:
- `90_review.md` → `review.md`
- `91_document.md` → `document.md`
- `99_continue.md` → `continue.md`
- `92_init.md` → deleted (merged into `setup.md`)

**Documentation Updates**:
- All references to old commands have been updated throughout the codebase
- 55+ files updated with new command names

#### Verification

After updating, verify your setup:

```bash
# Check that new commands exist
ls .claude/commands/{review.md,document.md,continue.md}

# Verify no broken references (should return 0)
grep -r "/90_review" --include="*.md" . --exclude-dir=".pilot/plan/done"
grep -r "/91_document" --include="*.md" . --exclude-dir=".pilot/plan/done"
grep -r "/92_init" --include="*.md" . --exclude-dir=".pilot/plan/done"
grep -r "/99_continue" --include="*.md" . --exclude-dir=".pilot/plan/done"
```

### Changed
- Renamed utility commands to verb-first naming (review, document, continue)
- Merged 92_init functionality into `/setup` command
- Updated all documentation references (55+ files)

### Removed
- `/92_init` command (functionality merged into `/setup`)

## [4.3.2] - 2026-01-20

### Added
  - Add /05_cleanup command for dead code cleanup.

### Changed
  - Remove language selection feature from setup.
  - Improve /05_cleanup Command - Auto-Apply Workflow.

### Documentation
  - Update Documentation: Remove PyPI Migration, Add GPT Codex Integration.

## [4.3.1] - 2026-01-19

### Performance
  - Hooks Performance Optimization - Dispatcher Pattern Implementation.

## [4.3.0] - 2026-01-19

### Added
  - Separate CLAUDE.md documentation strategy.

### Changed
  - Command workflow refactor - update all paths to .claude-pilot/.pilot/.
  - Prevent /02_execute from auto-moving plan to done.
  - Remove .pilot-version from release workflow.

### Fixed
  - Fix path duplication and /04_fix plan creation.

## [4.2.0] - 2026-01-19

### Added
  - Frontend Design Skill (`frontend-design`) for production-grade, distinctive UI development
  - SKILL.md with design thinking framework and aesthetic direction guidelines
  - REFERENCE.md with detailed examples, patterns, and comparisons
  - Example components: minimalist dashboard, warm landing page, brutalist portfolio
  - Anti-pattern prevention to avoid generic "AI slop" aesthetics
  - Integration with claude-pilot documentation (CLAUDE.md, README.md)
  - Safe-file-ops skill for secure file deletion and management
  - Converted 7 command details files to Skills for better organization
  - GitHub Actions CI/CD integration for automated release publishing
  - Hybrid release model: local preparation + CI/CD automation
  - Version validation in CI workflow (consistency checks)
  - Automatic CHANGELOG extraction for release notes
  - Enhanced 999_release command with troubleshooting and CI/CD guide

### Changed
  - Documentation structure refactoring (v4.2.0)
  - Refactored system-integration.md to router/overview file
  - Updated CLAUDE.md with Frontend Design Skill section
  - Updated README.md with frontend design features and usage examples
  - Renamed 00_continue to 99_continue for naming consistency

### Fixed
  - Correct cgcode directory path references
  - Updated troubleshooting guide with latest fixes

## [4.1.8] - 2026-01-18

### Added
  - Frontend Design Skill (`frontend-design`) for production-grade, distinctive UI development
  - SKILL.md with design thinking framework and aesthetic direction guidelines
  - REFERENCE.md with detailed examples, patterns, and comparisons
  - Example components: minimalist dashboard, warm landing page, brutalist portfolio
  - Anti-pattern prevention to avoid generic "AI slop" aesthetics
  - Integration with claude-pilot documentation (CLAUDE.md, README.md)

### Changed
  - Updated CLAUDE.md with Frontend Design Skill section
  - Updated README.md with frontend design features and usage examples

## [4.1.7] - 2026-01-18

### Added
  - Add /04_fix rapid bug fix workflow with test coverage.
  - Auto-generate CHANGELOG from git commits in /999_release.
  - CI/CD integration with GitHub Actions for automated release publishing.
  - Hybrid release model: local preparation + CI/CD automation.
  - Version validation in CI workflow (consistency checks).
  - Automatic CHANGELOG extraction for release notes.


