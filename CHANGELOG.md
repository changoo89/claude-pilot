# CHANGELOG

## [4.4.45] - 2026-01-26

### Added
- Proactive GPT Consultation with confidence-based automatic consultation before user questions
- Confidence Score Rubric (centralized in gpt-delegation/SKILL.md): confidence = 1.0 - (architecture_keywords * 0.3) - (multiple_approaches * 0.2) - (uncertainty * 0.2)
- MUST Consult GPT section in spec-driven-workflow/SKILL.md (triggers: architecture keywords OR confidence < 0.5)
- Proactive Consultation pattern in confirm-plan/REFERENCE.md
- Pre-Execution Confidence check in execute-plan/SKILL.md (Step 2.7)
- Early Escalation option in ralph-loop/SKILL.md (--early flag OR architecture-related failure)

### Changed
- Enhanced gpt-delegation/SKILL.md with centralized Confidence Score Rubric
- Enhanced confirm-plan/REFERENCE.md with Proactive Consultation pattern and concrete example
- Enhanced execute-plan/SKILL.md with Pre-Execution Confidence evaluation before complex SCs
- Enhanced ralph-loop/SKILL.md with Early Escalation for 2-iteration escalation

## [4.4.44] - 2026-01-25

### Changed
- close(plan): execute-plan robustness improvements (096a6fa)
- close(plan): smart-documentation-update (abc2f83)
- close(plan): e2e_verification (61440fc)
- close(plan): close-plan-refactor (a96d638)
- close(plan): skill refactoring for ≤200 lines compliance (ea15089)
- close(plan): QA/QC Enhancement for claude-pilot (3480dcd)

### Documentation
- Restructure documentation per Claude Code official guidelines (9010f84)

## [4.4.43] - 2026-01-25

### Documentation
- Add single agent delegation pattern documentation (738f905)

### Changed
- close(plan): single-subagent-delegation (7a6d40a)


## [4.4.42] - 2026-01-24


## [4.4.41] - 2026-01-24

### Changed
- close(plan): self_contained_plan_enhancement_draft (a8b370e)


## [4.4.40] - 2026-01-24

### Fixed
- Restrict docs/ai-context/ to exactly 2 files - Remove system-integration.md references, enforce project-structure.md and docs-overview.md only (9882450)

### Changed
- close(plan): close_parallelization workflow (ac5416c)


## [4.4.39] - 2026-01-24

### Fixed
- Prevent step skipping in Step 3/4 of close-plan workflow (1145731)

## [4.4.38] - 2026-01-24

### Added
- Discovered Issues tracking system - Track out-of-scope issues found after /01_confirm with statusline integration (P0=🔴, P1=🟡)

### Fixed
- Apply dynamic agent selection across execute-plan and related skills


## [4.4.37] - 2026-01-24

### Added
- **Design Quality System**: Awwwards-level UI design quality system with aesthetic direction guidelines (10688b9)
- **Scope Clarity Framework**: Added to plan/confirm workflow with 4 mandatory triggers for scope validation (9ba4c3b)

### Fixed
- **Spec-driven workflow**: Add Success Criteria section to draft template (25bf3f8)

### Changed
- **Plan closure**: Reference analysis and improvements (528667f, fb1da41)

## [4.4.36] - 2026-01-24

### Fixed
- include scripts directory in plugin distribution (1dfc9f7)
- remove unused state/archive directory (03ae259)

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.4.35] - 2026-01-24

### Fixed
- **setup skill name collision**: Renamed skill from `setup` to `setup-workflow` to prevent infinite loop when command and skill have same name (1df0365)
- Reverted path transformation approach in favor of proper naming

## [4.4.34] - 2026-01-24

### Fixed
- **skill path in distribution**: Build script now transforms `@.claude/skills/` to `@skills/` in commands for proper path resolution in distributed plugin (2e69349)

## [4.4.33] - 2026-01-24

### Fixed
- **setup command infinite loop**: Changed from "Invoke the setup skill" to direct file reference to prevent Claude from interpreting as Skill tool call (0b4cd04)

## [4.4.32] - 2026-01-24

### Fixed
- **setup command**: Remove `disable-model-invocation` flag to allow `/claude-pilot:setup` execution from distributed plugin (37f2755)

## [4.4.31] - 2026-01-23

### Added
- **Internal documentation**: `.claude/docs/DEPLOYMENT-INTERNAL.md` - Deployment troubleshooting and architecture notes
- `docs/` directory excluded from distribution

## [4.4.30] - 2026-01-23

### Changed
- **Internal command exclusion**: `999_release.md` and `release/` skill excluded from distribution
- Updated README.md and CLAUDE.md with `#release` branch installation instructions
- Documented dual-branch strategy (main for dev, release for distribution)

## [4.4.29] - 2026-01-23

### Fixed
- **Build-time agent prefix**: Agent namespace prefix (`claude-pilot:`) now added during build, not in source
- Main branch uses `coder`, release branch uses `claude-pilot:coder`
- Allows development without plugin installation

## [4.4.28] - 2026-01-23

### Fixed
- **Agent namespace prefix**: All skill agent references now use `claude-pilot:` prefix (e.g., `claude-pilot:coder` instead of `coder`)
- Required for plugin installation where agents are namespaced by plugin name

## [4.4.27] - 2026-01-23

### Fixed
- Updated validate-marketplace-tree.sh for new plugins/ subdirectory structure

## [4.4.26] - 2026-01-23

### Fixed
- **Plugin source path**: Changed from `"."` to `"./plugins/claude-pilot"` (matches official anthropic pattern)
- Plugin now placed in `plugins/claude-pilot/` subdirectory on release branch
- Fixes "Invalid schema: plugins.0.source" validation error

## [4.4.25] - 2026-01-23

### Fixed
- **Marketplace recursion fix**: Moved marketplace.json to release branch only, using local source `"."` instead of GitHub ref
- Marketplace now served from `changoo89/claude-pilot#release` (not main branch)
- Build script generates marketplace.json with correct local source reference

## [4.4.24] - 2026-01-23

### Fixed
- **Source format correction**: Fixed marketplace.json source format to use proper `github` type with separate `ref` field instead of URL fragment (`#release`)
- Official format: `{"source": "github", "repo": "owner/repo", "ref": "release"}`

## [4.4.23] - 2026-01-23

### Fixed
- **Marketplace name collision**: Renamed marketplace from `claude-pilot` to `claude-pilot-marketplace` to prevent infinite recursion in cache path (`{marketplace}/{plugin}/{version}/...`)
- Adopted superpowers-style source format (`url` instead of `github`) for reliable plugin installation

## [4.4.22] - 2026-01-23

### Fixed
- Remove `pluginRoot` from marketplace.json to prevent infinite recursion during plugin installation (6ad18e4)

## [4.4.21] - 2026-01-23

### Added
- **Release branch strategy** for marketplace deployment
- Build and validation scripts for marketplace tree structure (`scripts/build-marketplace-tree.sh`, `scripts/validate-marketplace-tree.sh`)
- GitHub Actions workflow for automatic release branch publishing (`.github/workflows/release-branch.yml`)
- Integration tests for plugin deployment verification

### Changed
- **marketplace.json**: Updated source to GitHub ref format (source: github, repo: changoo89/claude-pilot, ref: release)
- **plugin.json**: Cleaned to metadata only (removed commands, skills, mcpServers fields - auto-detected by Claude Code)
- Plugin now uses standard marketplace structure (agents/, commands/, skills/ at root) for release branch

### Fixed
- Plugin deployment now correctly publishes to GitHub marketplace with standard directory structure
- Agents auto-detection works correctly when installed from marketplace

## [4.4.18] - 2026-01-23

### Added
- **Read-only enforcement** for `/00_plan` command to prevent code modifications during planning
- Tool restriction warnings (Edit tool FORBIDDEN, Write tool ONLY for draft files)
- Natural language interpretation rules with Korean/English examples
- Clarified that phrases like "진행해" and "proceed" mean continue planning, not implement

### Changed
- Enhanced `spec-driven-workflow/SKILL.md` with comprehensive tool restrictions
- Added response templates for planning phase interactions

## [4.4.17] - 2026-01-23

### Fixed
- Revert unsupported `agents` field from plugin.json
- Plugin manifest now uses minimal supported fields only

## [4.4.16] - 2026-01-23

### Fixed
- **Plugin manifest validation**: Remove unsupported `agents` field from plugin.json
- Plugin installation now works correctly with official Claude Code plugin format

### Changed
- plugin.json now uses minimal supported fields only
- Agents are auto-detected from `agents/` directory by Claude Code


## [4.4.15] - 2026-01-23

### Changed
- **Superpowers-style command refactoring**: All 10 commands simplified to ~10 lines
- Commands now invoke skills directly (single source of truth pattern)
- All execution logic moved from commands to skills
- Git push with retry (exponential backoff) added to /03_close

### Added
- `setup/SKILL.md` - New skill for setup command
- Git push retry with exponential backoff (2s, 4s, 8s) in git-operations skill
- Command-skill contract documentation in plan files

### Fixed
- /03_close now pushes to remote (previously only committed)
- Duplicate logic between commands and skills eliminated
- Decision tracking issue in /00_plan command

### Migration Notes
- Commands reduced from 80-480 lines to ~10 lines each
- Skills expanded to contain all execution logic (200-560 lines)
- Pattern: `Invoke the [skill-name] skill and follow it exactly`

## [4.4.14] - 2026-01-23

### Removed
- filesystem MCP from plugin distribution (path placeholder not supported)
- filesystem references from README.md and setup.md

### Fixed
- Documentation cleanup for MCP server recommendations

## [4.4.13] - 2026-01-23

### Added
- Refactor /05_cleanup with knip integration for dead code detection
- Parallel detection support in cleanup workflow
- 4-level risk classification system (Low, Medium, High, Critical)

## [4.4.12] - 2026-01-23

### Added
- Integrate /document into /03_close with strict Tier 1 validation
- Dual-source verification to prevent plan omissions in workflow
- MCP server instructions per official Claude Code guide
- Question filtering and selection vs execution logic in /00_plan
- Automated documentation verification system

### Fixed
- Standardize documentation line limits to 200 lines
- Add explicit prohibition against auto-moving plans to done
- Auto-run documentation sync in /03_close

### Changed
- Restructure 3-tier documentation system
- Reduce REFERENCE.md file sizes to ≤300 lines
- Unify line limits across skills documentation

### Removed
- Unused template files
- Obsolete files for plugin distribution
- Duplicate external skills and zip archives

## [4.4.11] - 2026-01-22

### Added
