# Plugin Architecture Guide

> **Purpose**: Plugin manifests, setup command, hooks configuration, version management
> **Last Updated**: 2026-01-18

---

## Overview

claude-pilot v4.1.0 is distributed as a pure Claude Code plugin via GitHub marketplace, eliminating Python packaging complexity.

---

## Plugin Manifests

| File | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Marketplace configuration (name, owner, plugins) |
| `.claude-plugin/plugin.json` | Plugin metadata (version source of truth, commands, agents, skills) |

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
Plugin: Configures MCP servers (merge strategy), prompts GitHub star
```

---

## Setup Command (`/pilot:setup`)

**Purpose**: Configure MCP servers with merge strategy and verify hook script permissions

**Features**:
- Reads `mcp.json` for recommended servers
- Merges with existing `.mcp.json` (preserves user configs)
- Atomic write pattern (prevents race conditions)
- GitHub star prompt (optional, via `gh` CLI)
- Graceful fallback for missing `gh` CLI
- **Permission verification** (v4.1.5): Automatically fixes hook script permissions

**Merge Strategy**:
1. Check if project `.mcp.json` exists
2. If exists: Merge recommended servers (preserve user's existing configurations)
3. If not exists: Create new `.mcp.json` with recommended servers
4. Conflict resolution: If server name exists, skip (preserve user's config)

---

## Hooks Configuration

**Location**: `.claude/hooks.json`

**Important**: Hook scripts must have executable permissions (`-rwxr-xr-x`) to run properly. The `.gitattributes` file enforces line endings (LF) for cross-platform compatibility, and executable bits are tracked in git index (mode 100755).

```json
{
  "pre-commit": [
    {"command": ".claude/scripts/hooks/typecheck.sh", "description": "Run type check"},
    {"command": ".claude/scripts/hooks/lint.sh", "description": "Run lint check"}
  ],
  "pre-push": [
    {"command": ".claude/scripts/hooks/branch-guard.sh", "description": "Prevent push from protected branches"}
  ]
}
```

**Permission Fix (v4.1.5)**: If hook scripts don't have executable permissions after installation, run `/pilot:setup` to automatically fix them. See `MIGRATION.md` Troubleshooting section for manual fix.

---

## Version Management

**Single Source of Truth**: `.claude-plugin/plugin.json` version field

No more version synchronization across multiple files!

**Update Process**:
1. Update version in `.claude-plugin/plugin.json`
2. Update CHANGELOG.md with release notes
3. Commit changes: `git commit -m "Bump version to X.Y.Z"`
4. Create tag: `git tag vX.Y.Z`
5. Push: `git push origin main --tags`
6. GitHub marketplace auto-detects new version from tag

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `.claude-plugin/plugin.json` | Plugin manifest | → Claude Code CLI loads plugin |
| `/pilot:setup` | MCP configuration | → `.mcp.json` (merge strategy) |
| `.claude/hooks.json` | Hook definitions | → Claude Code hooks system |
| `mcp.json` | Recommended MCPs | → Merged into project `.mcp.json` |

---

## External Skills Sync (v3.3.6)

### Overview

The external skills sync feature automatically downloads and updates Vercel agent-skills from GitHub, providing frontend developers with production-grade React optimization guidelines.

### Components

| File | Purpose |
|------|---------|
| `config.py` | EXTERNAL_SKILLS dict with Vercel configuration |
| `updater.py` | sync_external_skills(), get_github_latest_sha(), download_github_tarball(), extract_skills_from_tarball() |
| `initializer.py` | Calls sync_external_skills() during init |
| `cli.py` | `--skip-external-skills` flag for init/update |

### Sync Workflow

```
User runs: claude-pilot init/update
      │
      ├─► Check skip flag
      │   └─► skip=True → Return "skipped"
      │
      ├─► Read existing version
      │   └─► .claude/.external-skills-version
      │
      ├─► Fetch latest commit SHA
      │   └─► GitHub API: GET /repos/{owner}/{repo}/commits/{branch}
      │
      ├─► Compare versions
      │   └─► Same → Return "already_current"
      │
      ├─► Download tarball
      │   └─► GET /repos/{owner}/{repo}/tarball/{ref}
      │
      ├─► Extract skills
      │   ├─► Validate paths (no traversal)
      │   ├─► Reject symlinks
      │   └─► Copy to .claude/skills/external/
      │
      ├─► Save new version
      │   └─► Write SHA to .external-skills-version
      │
      └─► Return "success"
```

### Security Features

1. **Path Traversal Prevention**: Validates all extracted paths don't contain `..`
2. **Symlink Rejection**: Rejects all symlinks to prevent arbitrary file writes
3. **Streaming Download**: Uses chunked download for large tarballs
4. **Temp Directory**: Downloads to temp directory before atomic move

### Configuration

```python
EXTERNAL_SKILLS = {
    "vercel-agent-skills": {
        "repo": "vercel-labs/agent-skills",
        "branch": "main",
        "skills_path": "skills",
    }
}
EXTERNAL_SKILLS_DIR = ".claude/skills/external"
EXTERNAL_SKILLS_VERSION_FILE = ".claude/.external-skills-version"
```

### CLI Integration

| Command | Flag | Behavior |
|---------|------|----------|
| `claude-pilot init` | `--skip-external-skills` | Skip downloading external skills |
| `claude-pilot update` | `--skip-external-skills` | Skip syncing external skills |

### Error Handling

| Scenario | Behavior |
|----------|----------|
| Network failure | Warning message, continues with other operations |
| Rate limit (403) | Warning message, returns "failed" |
| Invalid tarball | Warning message, returns "failed" |
| Already current | Info message, returns "already_current" |

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `initializer.py` | Calls sync_external_skills() | → `.claude/skills/external/` |
| `updater.py` | GitHub API calls | → Latest commit SHA, tarball download |
| `config.py` | EXTERNAL_SKILLS config | → Repository metadata |
| `cli.py` | `--skip-external-skills` flag | → Skip conditional |

---

## See Also

- **@docs/ai-context/system-integration.md** - Component interactions and workflows
- **@CLAUDE.md** - Project standards (Tier 1)
- **@MIGRATION.md** - PyPI to plugin migration guide

---

**Last Updated**: 2026-01-18
**Version**: 4.2.0
