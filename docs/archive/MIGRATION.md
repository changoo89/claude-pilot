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

### Step 3: Clean Legacy Project Files (CRITICAL)

> **⚠️ IMPORTANT**: If you previously used PyPI installation (v4.0.5 or earlier), your project's `.claude/` directory contains legacy files that conflict with the plugin.

**Remove legacy files BEFORE installing plugin**:

```bash
# In your project directory
cd /path/to/your/project

# 1. Remove PyPI marker file
rm -f .claude/.external-skills-version

# 2. Remove legacy backup directories
rm -rf .claude-backups/

# 3. Create backup of current settings
cp .claude/settings.json .claude/settings.json.backup

# 4. Update settings.json: Change enabledPlugins
#    FROM: "claude-pilot@claude-pilot": true
#    TO:   "claude-pilot@changoo89": true
# (See Step 4 for details)
```

**Why this is critical**: PyPI installation copied files directly to your project's `.claude/` directory. These old files will conflict with the plugin, causing version mismatches and outdated commands.

### Step 3.5: Verify Clean State

```bash
# Check for PyPI markers
ls .claude/.external-skills-version 2>/dev/null && echo "⚠️ PyPI marker found" || echo "✓ Clean"

# Check for legacy backups
ls .claude-backups/ 2>/dev/null && echo "⚠️ Legacy backups found" || echo "✓ Clean"

# Both should be clean before proceeding
```

### Step 4: Install Plugin

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

### Step 4.5: Update Project settings.json

After running `/pilot:setup`, verify your `settings.json`:

```json
{
  "enabledPlugins": {
    "claude-pilot@changoo89": true  // ✅ Correct format
  }
}
```

**Wrong format** (legacy PyPI):
```json
{
  "enabledPlugins": {
    "claude-pilot@claude-pilot": true  // ❌ Wrong - PyPI format
  }
}
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

**Symptoms**: Plugin shows as installed but commands don't work or are outdated

**Cause**: Legacy PyPI files in `.claude/` directory conflicting with plugin

**Solution**:
```bash
# 1. Remove legacy PyPI files
rm -f .claude/.external-skills-version
rm -rf .claude-backups/

# 2. Reinstall plugin to refresh cache
/plugin install claude-pilot@changoo89 --force

# 3. Verify commands
/list | grep pilot
```

**Prevention**: Always clean legacy files BEFORE installing plugin (see Step 3)

### Issue: Existing `.claude/` directory conflicts

**Symptoms**: Plugin installed but old commands still execute

**Cause**: PyPI installation copied files directly to project, overriding plugin

**Solution**:
1. Remove `.claude-backups/` directory
2. Remove `.claude/.external-skills-version`
3. Reinstall plugin: `/plugin install claude-pilot@changoo89 --force`

### Issue: Version mismatch (4.0.5 vs 4.1.5)

**Symptoms**: `.pilot-version` shows 4.0.5 but latest is 4.1.5

**Cause**: Legacy files not cleaned up before plugin installation

**Solution**:
```bash
# Remove legacy markers
rm -f .claude/.external-skills-version

# Update .pilot-version
echo "4.1.5" > .claude/.pilot-version

# Refresh plugin cache
/plugin update claude-pilot@changoo89 --force
```

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

### Issue: Permission denied when running hook scripts

**Symptoms**: Error message `/bin/sh: .claude/scripts/hooks/*.sh: Permission denied` when hooks execute

**Cause**: Hook scripts don't have executable permissions after plugin installation via marketplace. This happens because:
1. Git tracks executable bits, but marketplace installation may not preserve permissions
2. Existing installations before v4.1.6 may have incorrect permissions

**Solution** (Automatic - Recommended):
```bash
# Run setup command to fix permissions automatically
/pilot:setup
```

The setup command will detect non-executable hook scripts and fix permissions automatically.

**Solution** (Manual):
```bash
# Make all hook scripts executable
chmod +x .claude/scripts/hooks/*.sh

# Verify permissions are correct
ls -la .claude/scripts/hooks/*.sh
# Expected: -rwxr-xr-x (executable)
```

**Verify Fix**:
```bash
# Check git index tracks executable bits (mode 100755)
git ls-files -s .claude/scripts/hooks/*.sh
# Expected: All hooks show mode 100755 (executable)
```

**Prevention**: After plugin update, always run `/pilot:setup` to ensure permissions are correct.

### Issue: Plans created in wrong directory (.cgcode instead of .pilot)

**Symptoms**: `/01_confirm` creates plans in `.cgcode/plan/pending/` instead of `.pilot/plan/pending/`

**Cause**: Old plugin version with legacy directory structure

**Root Cause**: You have an old version of claude-pilot (pre-v4.0.5) that uses `.cgcode/` directory instead of `.pilot/`. The plugin files were copied to your project's `.claude/` directory and never updated.

**Solution** (Automatic - Recommended):
```bash
# Update plugin to latest version
/plugin marketplace update
/plugin update claude-pilot@changoo89

# Verify update
/list | grep pilot
```

**Solution** (Manual Refresh):
```bash
# Remove old plugin files
rm -rf .claude/

# Run setup to install fresh files
/pilot:setup
```

**Migrate Existing Plans** (if you have plans in `.cgcode/`):
```bash
# Create .pilot directory structure
mkdir -p .pilot/plan/{pending,in_progress,done,active}

# Move existing plans
mv .cgcode/plan/* .pilot/plan/ 2>/dev/null || true

# Remove old directory
rm -rf .cgcode/

# Verify migration
ls -la .pilot/plan/
```

**Verify Fix**:
```bash
# Run /01_confirm and check plan location
# Should create plan in .pilot/plan/pending/
ls -la .pilot/plan/pending/
```

**Prevention**: Keep plugin updated with `/plugin marketplace update` and `/plugin update claude-pilot@changoo89`

**Note**: Current claude-pilot (v4.2.0) uses `.pilot/plan/` directory structure. The `.cgcode/` directory is from very old versions and should not be used.

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
