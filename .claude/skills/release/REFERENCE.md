# Plugin Release Workflow - Reference

> **Purpose**: Extended details for plugin release workflow
> **Skill**: @.claude/skills/release/SKILL.md
> **Last Updated**: 2026-01-22

---

## Pre-flight Checks

### Validation Requirements

| Check | Purpose | Command |
|-------|---------|---------|
| **Clean git status** | No uncommitted changes | `git status` |
| **Main branch** | On main/master branch | `git branch --show-current` |
| **Plugin manifests** | Valid JSON, required fields | `jq . .claude-plugin/*.json` |
| **Agents field** | Requires YAML files if present | Check `.claude/agents/*.yaml` |

**Critical pitfalls**:
- `agents` field in plugin.json requires actual YAML agent files (not .md)
- `source` in marketplace.json must be local path (`"./"`) NOT GitHub URL
- Missing `homepage`, `repository`, `license`, `keywords` causes installation failure

**Full validation script**: See `.claude/scripts/release.sh`

---

## Version Parsing

### Bump Types

| Type | Example | Result |
|------|---------|--------|
| `major` | 4.0.0 → | 5.0.0 |
| `minor` | 4.1.0 → | 4.2.0 |
| `patch` | 4.1.0 → | 4.1.1 |
| `X.Y.Z` | Custom | X.Y.Z |

### Prerelease Support

```bash
/999_release minor --pre beta  # 4.2.0-beta
/999_release 5.0.0-rc.1        # 5.0.0-rc.1
```

### Flags

| Flag | Purpose | Default |
|------|---------|---------|
| `--skip-gh` | Skip local GitHub release | `true` (CI handles it) |
| `--create-gh` | Create local GitHub release | `false` |
| `--dry-run` | Test without committing | `false` |
| `--pre` | Add prerelease suffix | (none) |

---

## Version File Updates

### Sources to Sync

| File | Field | Notes |
|------|-------|-------|
| `.claude-plugin/plugin.json` | `.version` | **PRIMARY source of truth** |
| `.claude-plugin/marketplace.json` | `.plugins[0].version` | Plugin entry version |

**Update commands**:
```bash
# Update plugin.json (PRIMARY)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp && mv tmp .claude-plugin/plugin.json

# Update marketplace.json (DUPLICATE)
jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp && mv tmp .claude-plugin/marketplace.json
```

**Verification**:
```bash
diff <(jq -r '.version' .claude-plugin/plugin.json) <(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)
```

---

## CHANGELOG Generation

### Auto-Generation Workflow

**Process**:
1. Detect previous tag: `git tag -l "v*" --sort=-v:refname | head -1`
2. Parse commits since last tag: `git log $PREV_TAG..HEAD --pretty=format:"%h|||%s"`
3. Categorize by conventional commit type
4. Group into categories: Added, Changed, Fixed, Removed, Performance, Docs
5. Format as Markdown with Keep a Changelog structure
6. Present for review/editing

**Conventional Commit Mapping**:

| Type | Category | Example |
|------|----------|---------|
| `feat:` | Added | feat(auth): add login endpoint |
| `fix:` | Fixed | fix(api): handle null response |
| `refactor:`, `chore:` | Changed | refactor(db): optimize query |
| `perf:` | Performance | perf(cache): reduce memory usage |
| `docs:` | Documentation | docs(readme): update install steps |
| `remove:`, `rm:` | Removed | remove(legacy): drop old API |

**Review Options**:
1. Accept as-is
2. Edit with `$EDITOR`
3. Provide custom changelog

**Full implementation**: See `.claude/scripts/release.sh` (lines 220-415)

---

## CI/CD Integration

### GitHub Actions Release

**Trigger**: Git tag push (`git push --tags`)

**Workflow**: `.github/workflows/release.yml`
- Validates version consistency across all files
- Creates GitHub Release with CHANGELOG body
- Runs on `ubuntu-latest` with `contents: write` permission

**Version validation**:
```yaml
- name: Validate versions
  run: |
    VERSION_FROM_TAG="${{ github.ref_name }}"
    PLUGIN_VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
    if [ "$VERSION_FROM_TAG" != "v$PLUGIN_VERSION" ]; then
      echo "Version mismatch"; exit 1
    fi
```

**Release creation**:
```yaml
- name: Create GitHub Release
  uses: softprops/action-gh-release@v1
  with:
    tag_name: ${{ github.ref_name }}
    body: See CHANGELOG.md for details
```

---

## Troubleshooting

### Plugin Update Doesn't Apply

**Diagnosis**:
```bash
ls -la ~/.claude/plugins/cache/claude-pilot/  # Check cached version
/plugin list | grep claude-pilot              # Check installed version
```

**Solutions** (priority order):
1. Force reinstall: `/plugin uninstall claude-pilot@changoo89 && /plugin install claude-pilot@changoo89`
2. Clear cache: `rm -rf ~/.claude/plugins/cache/claude-pilot && /plugin install claude-pilot@changoo89`
3. Verify marketplace source points to GitHub (not local path)

### Commands Show Up Twice

**Root Cause**: Local `.claude/commands/` folder exists + plugin installed

**Solution**: Remove local commands folder (plugin provides commands)
```bash
rm -rf .claude/commands  # Backup first if needed
```

### Stop Hook Permission Denied

**Note**: Pre-commit hooks were removed in v4.4.14 as part of skill-based architecture migration. This issue no longer applies.

---

## Release Workflow Summary

### Maintainer Workflow

```bash
# 1. Make changes, commit to main
git add . && git commit -m "feat: add feature"

# 2. Run release command
/999_release minor  # or major/patch/X.Y.Z

# 3. Script handles:
#   - Version bump in all files
#   - CHANGELOG generation
#   - Git commit and tag
#   - Push to remote

# 4. GitHub Actions automatically creates release
```

### User Update Workflow

```bash
# 1. Update marketplace index
/plugin marketplace update

# 2. Update plugin
/plugin update claude-pilot@changoo89

# 3. If update fails, reinstall:
/plugin uninstall claude-pilot@changoo89
rm -rf ~/.claude/plugins/cache/claude-pilot
/plugin install claude-pilot@changoo89
```

---

## Version Tracking

**Single Source of Truth**: `.claude-plugin/plugin.json`

```json
{
  "version": "4.4.11"  // Always primary, never edit manually
}
```

**Automated sync**: `/999_release` syncs to marketplace.json

**Never manually edit**: marketplace.json version (auto-synced by release script)

---

## Best Practices

### For Maintainers

1. **Always use `/999_release`** - Ensures version consistency across all files
2. **Test before releasing** - Use `--dry-run` flag to preview changes
3. **Review auto-generated CHANGELOG** - Edit if auto-categorization is wrong
4. **Document breaking changes** - Add manual notes to CHANGELOG if needed
5. **Keep plugin.json updated** - It's the single source of truth

### For Users

1. **Use GitHub marketplace source** - Not local paths in `.claude/settings.json`
2. **Don't copy commands/skills locally** - Let plugin handle it (prevents duplicates)
3. **Clear cache if updates fail** - See troubleshooting section
4. **Report issues with context** - Include `/plugin list` output and error messages

### Release Checklist

- [ ] All tests passing
- [ ] Git status clean (no uncommitted changes)
- [ ] On main/master branch
- [ ] Remote up to date (`git pull`)
- [ ] Version bump type decided (major/minor/patch)
- [ ] CHANGELOG reviewed and approved
- [ ] CI/CD pipeline healthy

---

**Lines**: 300 (Target: ≤300) ✅
