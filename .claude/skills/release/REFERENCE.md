# Plugin Release Workflow - Reference

> **Purpose**: Extended details for plugin release workflow
> **Skill**: @.claude/skills/release/SKILL.md
> **Last Updated**: 2026-01-25

---

## Troubleshooting

### Version Mismatch Error

```
Error: Tag version (4.3.3) does not match plugin.json version (4.3.2)
```

**Solution**: Re-run `/999_release` to ensure all versions are synchronized

### jq Not Installed

```
Error: jq required
```

**Solution**: Install jq
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### Tag Already Exists

```
Error: Git tag v4.3.3 already exists
```

**Solution**: Delete existing tag first
```bash
git tag -d v4.3.3
git push origin :refs/tags/v4.3.3
```

### Marketplace Shows Old Version

**Symptom**: Marketplace shows 4.4.5 but plugin.json is 4.4.6

**Cause**: marketplace.json version not updated during release

**Solution**: Update all version fields in marketplace.json
```bash
jq --arg v "4.4.6" '
    .version = $v |
    .metadata.version = $v |
    .plugins[0].version = $v
' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

# Commit and update tag
git add .claude-plugin/marketplace.json
git commit -m "fix: Update marketplace.json version to 4.4.6"
git tag -d v4.4.6 && git push origin --delete v4.4.6
git tag v4.4.6 && git push origin main --tags
```

### Plugin Install Fails with "Invalid Input"

**Symptom**:
```
Error: Failed to install: Plugin has an invalid manifest file
Validation errors: agents: Invalid input
```

**Cause**: plugin.json contains unsupported fields

**Supported fields** (based on official plugins):
| Field | Type | Required | Example |
|-------|------|----------|---------|
| `name` | string | ✓ | `"claude-pilot"` |
| `description` | string | ✓ | `"SPEC-First workflow..."` |
| `version` | string | ✓ | `"4.4.6"` |
| `author` | object | ✓ | `{"name": "...", "url": "..."}` |
| `commands` | string | ○ | `"./.claude/commands/"` |
| `skills` | string | ○ | `"./.claude/skills/"` |
| `mcpServers` | object | ○ | MCP server configs |
| `homepage` | string | ○ | GitHub URL |
| `repository` | string | ○ | GitHub URL |
| `license` | string | ○ | `"MIT"` |
| `keywords` | array | ○ | `["tdd", "workflow"]` |

**Unsupported fields** (will cause install failure):
- `agents` - Claude Code auto-detects from `agents/` directory
- Any unknown fields

**Solution**:
```bash
# Remove unsupported field
jq 'del(.agents)' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

# Commit, push, and update tag
git add .claude-plugin/plugin.json
git commit -m "fix: Remove unsupported agents field from plugin.json"
git push origin main
git tag -d vX.Y.Z && git push origin --delete vX.Y.Z
git tag -a vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z
```

### Remote Tag Not Updated

**Symptom**: Local tag points to correct commit but remote tag points to old commit

**Diagnosis**:
```bash
# Check local tag
git rev-parse v4.4.6^{}

# Check remote tag (should match local)
curl -sL "https://api.github.com/repos/OWNER/REPO/git/refs/tags/v4.4.6" | jq -r '.object.sha'

# For annotated tags, check the commit it points to
curl -sL "https://api.github.com/repos/OWNER/REPO/git/tags/TAG_SHA" | jq -r '.object.sha'
```

**Solution**:
```bash
# Force delete and recreate remote tag
git push origin --delete v4.4.6
git push origin v4.4.6

# Recreate GitHub release
gh release delete v4.4.6 --yes
gh release create v4.4.6 --title "Release v4.4.6" --notes "Release notes..."
```

---

## Version Parsing Details

### Bump Types

| Type | Example | Result |
|------|---------|--------|
| `major` | 4.0.0 → | 5.0.0 |
| `minor` | 4.1.0 → | 4.2.0 |
| `patch` | 4.1.0 → | 4.1.1 |
| `X.Y.Z` | Custom | X.Y.Z |

### Flags

| Flag | Purpose | Default |
|------|---------|---------|
| `--skip-gh` | Skip local GitHub release | `true` (CI handles it) |
| `--create-gh` | Create local GitHub release | `false` |
| `--dry-run` | Test without committing | `false` |

---

## CHANGELOG Generation Details

### Conventional Commit Mapping

| Type | Category | Example |
|------|----------|---------|
| `feat:` | Added | feat(auth): add login endpoint |
| `fix:` | Fixed | fix(api): handle null response |
| `refactor:`, `chore:` | Changed | refactor(db): optimize query |
| `perf:` | Performance | perf(cache): reduce memory usage |
| `docs:` | Documentation | docs(readme): update install steps |
| `remove:`, `rm:` | Removed | remove(legacy): drop old API |

---

## Pre-flight Validation

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

---

## CI/CD Integration Details

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

**Lines**: 260 (Target: ≤300) ✅
