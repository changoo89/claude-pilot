# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.4.15] - 2026-01-23

### Fixed
- Decision tracking issue in /00_plan command
- Removed scripts in skill-based cleanup workflow

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