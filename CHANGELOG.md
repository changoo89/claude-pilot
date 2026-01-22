# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- GPT auto-delegation triggers to confirm and execute commands
- Explicit command gate for phase transitions

### Fixed
- Use absolute paths for plan file creation

### Changed
- Remove worktree-create.sh, migrate to skill-based git commands

## [4.4.10] - 2026-01-22

### Fixed
- Setup now always copies statusline.sh from plugin (ensures latest version)
- Previously local file took precedence, preventing updates on /pilot:setup

## [4.4.9] - 2026-01-22

### Changed
- Make scripts self-contained (remove env.sh external dependency)
- Move worktree-create.sh from .claude/lib/ to .claude/scripts/
- Simplify statusline.sh (remove unused worktree-utils.sh reference)

### Removed
- Dead code: test-agent-names.sh, env.sh (2 locations), .claude/lib/ directory
- Outdated hooks references from plugin-architecture.md

### Documentation
- Update CONTEXT.md with current script inventory
- Update plugin-architecture.md to reflect current architecture

## [4.4.8] - 2026-01-22

### Fixed
- Unify statusline configuration into single script block
- Fix settings.json statusLine not being added due to split bash context

## [4.4.7] - 2026-01-22

### Fixed
- Refactor setup command for statusline auto-configuration

## [4.4.6] - 2026-01-21

### Added
- Add mandatory dialogue checkpoints to /00_plan command
- Add EXECUTION DIRECTIVE to prevent unnecessary user prompts
- Strengthen parallel agent execution across all commands

### Fixed
- Restore plugin.json array format and marketplace.json

### Documentation
- Move Plugin Manifest Requirements to release skill
- Add Plugin Development Troubleshooting section

## [4.4.5] - 2026-01-21

### Fixed
- Remove marketplace.json for single plugin standard

## [4.4.4] - 2026-01-21

### Changed
- Simplify plugin.json format: commands/skills from array to string
- Add agents field to plugin.json

## [4.4.3] - 2026-01-21

### Changed
- Remove MCP servers from plugin.json (users can configure locally)

## [4.4.2] - 2026-01-21

### Fixed
- Update context7 MCP package to @upstash/context7-mcp (correct package name)
- Add project-level .mcp.json for context7 configuration
- Simplify mcp.json to context7-only configuration
- Update docs with correct context7 repository URL

### Changed
- Remove filesystem and grep-app from default MCP configuration (can be added manually)

## [4.4.1] - 2026-01-21

### Fixed
- Update context7 MCP package to @upstash/context7-mcp (correct package name)
- Add project-level .mcp.json for context7 configuration
- Simplify mcp.json to context7-only configuration
- Update docs with correct context7 repository URL

### Changed
- Remove filesystem and grep-app from default MCP configuration (can be added manually)
