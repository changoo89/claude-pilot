# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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