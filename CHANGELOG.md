# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.3] - 2026-01-18

### Fixed
- Fix marketplace.json source field: "." → "https://github.com/changoo89/claude-pilot"
- Claude Code plugins require GitHub URL in source field for marketplace installation

## [4.1.2] - 2026-01-18

### Fixed
- Remove invalid `agents` field from plugin.json to fix installation error
- The agents directory contains documentation (.md files), not YAML agent configs

## [4.1.1] - 2026-01-18

### Added
- **Release command** (`/999_release`): Bump version, create git tag, and GitHub release
- **Intelligent Codex delegation**: Phase-specific templates (Planning vs Implementation)
- **Enhanced setup verification**: Formatted status report for MCP server configuration

### Changed
- GPT delegation prompts with phase-specific context engineering
- Parallel execution improvements for agent coordination
- Renamed `000_pilot_setup.md` to `setup.md` for consistency

### Fixed
- Codex CLI detection for non-interactive shells
- marketplace.json source path for GitHub plugin detection
- Plugin structure verification and installation documentation


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.2] - 2026-01-18

### Fixed
- Remove invalid `agents` field from plugin.json to fix installation error
- The agents directory contains documentation (.md files), not YAML agent configs

## [4.1.1] - 2026-01-18

### Added
- **Release command** (`/999_release`): Bump version, create git tag, and GitHub release
- **Intelligent Codex delegation**: Phase-specific templates (Planning vs Implementation)
- **Enhanced setup verification**: Formatted status report for MCP server configuration

### Changed
- GPT delegation prompts with phase-specific context engineering
- Parallel execution improvements for agent coordination
- Renamed `000_pilot_setup.md` to `setup.md` for consistency

### Fixed
- Codex CLI detection for non-interactive shells
- marketplace.json source path for GitHub plugin detection
- Plugin structure verification and installation documentation


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.1] - 2026-01-18

### Added
- **Release command** (`/999_release`): Bump version, create git tag, and GitHub release
- **Intelligent Codex delegation**: Phase-specific templates (Planning vs Implementation)
- **Enhanced setup verification**: Formatted status report for MCP server configuration

### Changed
- GPT delegation prompts with phase-specific context engineering
- Parallel execution improvements for agent coordination
- Renamed `000_pilot_setup.md` to `setup.md` for consistency

### Fixed
- Codex CLI detection for non-interactive shells
- marketplace.json source path for GitHub plugin detection
- Plugin structure verification and installation documentation


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2026-01-17

### Breaking Changes
- **PyPI distribution removed**: No longer distributed via Python Package Index
- **Installation method changed**: From `pip install` to Claude Code plugin (`/plugin install`)
- **CLI tool removed**: `claude-pilot` command no longer available
- **Python dependency removed**: No Python runtime required

### Added
- **Pure plugin distribution**: Now distributed as Claude Code plugin via GitHub marketplace
- **3-line installation**: `/plugin marketplace add` → `/plugin install` → `/pilot:setup`
- **Setup command** (`/pilot:setup`): Configure MCP servers with merge strategy
- **GitHub star prompt**: Optional repository starring via GitHub CLI
- **Plugin manifests**: `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json`
- **Hooks configuration**: `.claude/hooks.json` for pre-commit/pre-push hooks
- **Migration guide**: `MIGRATION.md` for existing PyPI users

### Changed
- **Version source**: Single source of truth in `.claude-plugin/plugin.json` (no more sync)
- **Update mechanism**: Use `/plugin update` instead of `pip install --upgrade`
- **Project structure**: Removed `src/`, `pyproject.toml`, `install.sh`, `tests/`

### Removed
- Python packaging infrastructure (`src/claude_pilot/`, `pyproject.toml`, `install.sh`)
- CLI tool (`claude-pilot` command)
- Python build system (Hatchling)
- Version sync scripts (`scripts/verify-version-sync.sh`)
- Python test files (`tests/test_*.py`)
- Python cache directories (`.mypy_cache/`, `.ruff_cache/`, `.pytest_cache/`)

### Migration Notes
- Existing PyPI users: Run `pipx uninstall claude-pilot` or `pip uninstall claude-pilot`
- Install plugin via 3-line installation (see README.md)
- All functionality preserved (commands, agents, skills work identically)

---

## [4.0.5] - Previous

### Fixed
- **Agent name case-sensitivity**: Fixed researcher agent name inconsistency in `/00_plan` command documentation
  - Changed "Researcher Agent" to "researcher Agent" throughout `.claude/commands/00_plan.md`
  - Added case-sensitivity warning to `.claude/guides/parallel-execution.md`
  - Created test script `.claude/scripts/test-agent-names.sh` to verify lowercase agent names
  - Prevents silent failures when invoking agents with incorrect case

### Documentation
- Updated Agent Coordination table in `/00_plan` command to use lowercase "researcher"
- Updated Result Merge section to use lowercase "researcher"
- Updated checklist items to use lowercase "researcher"
- Added critical warning about case-sensitive agent names in parallel execution guide

---

## Previous Versions
