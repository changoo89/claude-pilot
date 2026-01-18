# Migration Guide: PyPI to Plugin (v4.0.5 → v4.1.0)

> **Last Updated**: 2026-01-17
> **Breaking Change**: PyPI distribution discontinued, plugin-only distribution

---

## Overview

claude-pilot **v4.1.0** is a breaking change that migrates from PyPI distribution to pure Claude Code plugin distribution.

**Key Changes**:
- No Python dependency
- Simpler installation (3 lines)
- Native Claude Code integration
- No version synchronization issues

---

## Breaking Changes

| Feature | v4.0.5 (PyPI) | v4.1.0 (Plugin) |
|---------|---------------|-----------------|
| **Installation** | `pip install claude-pilot` | `/plugin install claude-pilot` |
| **CLI Command** | `claude-pilot init` | `/92_init` |
| **Updates** | `pip install --upgrade` | `/plugin update` |
| **Python Required** | Yes (3.9+) | No |
| **Distribution** | PyPI | GitHub Marketplace |

---

## Migration Steps

### Step 1: Uninstall Python Package

Remove the old PyPI installation:

```bash
# If installed via pipx (recommended)
pipx uninstall claude-pilot

# OR if installed via pip
pip uninstall claude-pilot

# OR if installed via pip3
pip3 uninstall claude-pilot
```

### Step 2: Verify Removal

Confirm the Python package is gone:

```bash
# Should return "not found"
claude-pilot --version

# Should show empty
pip list | grep claude-pilot
```

### Step 3: Install Plugin

Follow the 3-line installation in your project:

```bash
# In Claude Code CLI
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

### Step 4: Verify Installation

Check that all commands are available:

```bash
# List all available commands
/list

# Expected: 10 pilot commands
# /00_plan, /01_confirm, /02_execute, /03_close
# /90_review, /91_document, /92_init, /999_release
# /pilot:setup (new)
```

---

## What's Preserved

All functionality is preserved from v4.0.5:

| Feature | Status |
|---------|--------|
| Commands | All 9 commands work identically |
| Agents | All 8 agents available |
| Skills | TDD, Ralph Loop, Vibe Coding, Git Master |
| Templates | CONTEXT.md, SKILL.md templates |
| Hooks | Type checking, linting, todos |
| Plans | `.pilot/` directory structure |
| Documentation | 3-Tier system |

---

## What's Changed

### Installation

**Before (v4.0.5)**:
```bash
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash
claude-pilot init .
```

**After (v4.1.0)**:
```bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup
```

### Updates

**Before (v4.0.5)**:
```bash
claude-pilot update
# OR
pip install --upgrade claude-pilot
```

**After (v4.1.0)**:
```bash
/plugin update claude-pilot
```

### Version Info

**Before (v4.0.5)**:
```bash
claude-pilot --version
# Version stored in pyproject.toml
```

**After (v4.1.0)**:
```bash
# Check .claude-plugin/plugin.json
cat .claude-plugin/plugin.json | grep version
```

---

## New Features in v4.1.0

### 1. Setup Command (`/pilot:setup`)

New command for configuring MCP servers:

```bash
/pilot:setup
```

**Features**:
- Configures recommended MCP servers
- Merge strategy for existing `.mcp.json` (preserves your configs)
- GitHub star prompt (optional)

### 2. Simplified Versioning

Single source of truth: `.claude-plugin/plugin.json`

No more version synchronization across 7 files!

---

## Troubleshooting

### Issue: Commands not found after plugin install

**Solution**:
```bash
# Verify plugin installation
/plugin list

# Reinstall if needed
/plugin install claude-pilot --force
```

### Issue: Existing `.claude/` directory conflicts

**Solution**:
The plugin preserves your existing `.claude/` files. Run `/pilot:setup` to merge new configurations.

### Issue: MCP servers not configured

**Solution**:
```bash
/pilot:setup
```

This will configure recommended MCP servers with merge strategy.

### Issue: Missing old CLI commands

**Solution**:
All functionality is now available via Claude Code slash commands:

| Old CLI Command | New Slash Command |
|----------------|-------------------|
| `claude-pilot init` | `/92_init` |
| `claude-pilot update` | `/plugin update` |
| `claude-pilot version` | Check `.claude-plugin/plugin.json` |

---

## Emergency Rollback (Not Recommended)

**WARNING**: This is a one-way migration. No automatic rollback.

If you need to revert to v4.0.5:

```bash
# Step 1: Restore from git tag
git checkout v4.0.5

# Step 2: Reinstall via PyPI
pipx install claude-pilot==4.0.5
# OR
pip install claude-pilot==4.0.5

# Step 3: Verify installation
claude-pilot --version
```

**Limitations**:
- Manual process only
- May lose changes made after migration
- Git history must be intact

**Recommendation**: Test plugin thoroughly in a separate branch before uninstalling PyPI version.

---

## Benefits of Migration

| Benefit | Description |
|---------|-------------|
| **No Python** | Plugin is pure markdown/JSON - no runtime required |
| **Simpler Updates** | `/plugin update` instead of package manager |
| **Native Integration** | Built for Claude Code from the ground up |
| **Single Version** | No more sync issues across multiple files |
| **Faster Releases** | No build/publish steps required |

---

## Need Help?

- **Documentation**: [README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/changoo89/claude-pilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/changoo89/claude-pilot/discussions)

---

## Release Workflow (v4.1.1+)

### Plugin Release Command

**v4.1.1** introduced `/999_release` for plugin versioning and GitHub releases:

```bash
# Patch release (x.y.Z) with GitHub release
/999_release

# Minor release (x.Y.0)
/999_release minor

# Major release (X.0.0)
/999_release major

# Specific version
/999_release 4.2.0

# Skip GitHub release (tag only)
/999_release patch --skip-gh

# Dry run (preview changes)
/999_release patch --dry-run

# Pre-release version
/999_release patch --pre alpha.1
```

**What `/999_release` does**:
1. Syncs version across 3 files: `plugin.json`, `marketplace.json`, `.pilot-version`
2. Updates `CHANGELOG.md` with release notes
3. Creates git commit: `chore: bump version to X.Y.Z`
4. Creates and pushes annotated git tag: `v{version}`
5. Creates GitHub release (if `gh` CLI installed)

### Distribution Flow

```
Maintainer: /999_release → git tag → GitHub release
                ↓
        Users: /plugin marketplace update
                ↓
        Users: /plugin update claude-pilot@changoo89
```

**Note**: Plugins track commit SHAs, not git tags or releases. Tags/releases are optional ceremony for changelog visibility.

---

**Migration Complete!** Welcome to claude-pilot v4.1.0 - pure plugin distribution.
