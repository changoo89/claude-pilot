# Plugin Architecture Guide

> **Purpose**: Plugin manifests, setup command, version management
> **Last Updated**: 2026-01-22

---

## Overview

claude-pilot is distributed as a pure Claude Code plugin via GitHub marketplace, eliminating Python packaging complexity.

---

## Plugin Manifests

| File | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Marketplace configuration (name, owner, plugins) |
| `.claude-plugin/plugin.json` | Plugin metadata (version source of truth, commands, skills) |

### Installation Flow

```
User: /plugin marketplace add changoo89/claude-pilot
      ↓
Claude Code: Adds marketplace to registry
      ↓
User: /plugin install claude-pilot
      ↓
Claude Code: Downloads plugin, installs components
      ↓
User: /pilot:setup
      ↓
Plugin: Creates .pilot directories, configures statusline, prompts GitHub star
```

---

## Setup Command (`/pilot:setup`)

**Purpose**: Initialize project directories and configure statusline

**Features**:
- Creates `.pilot/plan/{draft,pending,in_progress,done}` directories
- Copies statusline.sh to project `.claude/scripts/`
- Configures statusline in `.claude/settings.json`
- GitHub star prompt (optional, via `gh` CLI)

**Statusline Configuration**:
```json
{
  "statusLine": {
    "type": "command",
    "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/statusline.sh"
  }
}
```

---

## Pre-Commit Hook

**Location**: `.claude/scripts/hooks/pre-commit.sh`

Simple validation hook (symlinked to `.git/hooks/pre-commit`):
- JSON syntax validation
- Markdown link sanity check
- Runs only on staged files

---

## Version Management

**Single Source of Truth**: `.claude-plugin/plugin.json` version field

**Update Process**:
1. Update version in `.claude-plugin/plugin.json`
2. Update marketplace.json (all version fields)
3. Update CHANGELOG.md with release notes
4. Commit changes: `git commit -m "chore(release): Bump version to X.Y.Z"`
5. Create tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
6. Push: `git push origin main --tags`
7. GitHub Actions creates GitHub Release automatically

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `.claude-plugin/plugin.json` | Plugin manifest | → Claude Code CLI loads plugin |
| `/pilot:setup` | Project initialization | → `.pilot/`, `.claude/scripts/`, `.claude/settings.json` |
| `.claude/scripts/statusline.sh` | Status display | → Claude Code statusline system |

---

## External Skills

External skills are stored in `.claude/skills/external/` directory:
- `vercel-agent-skills/` - React best practices, web design guidelines

These skills are manually synced and provide frontend development guidelines.

---

## See Also

- **@docs/ai-context/system-integration.md** - Component interactions and workflows
- **@CLAUDE.md** - Project standards (Tier 1)
- **@.claude/commands/999_release.md** - Release workflow details

---

**Last Updated**: 2026-01-22
**Version**: 4.4.9
