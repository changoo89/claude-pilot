# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
