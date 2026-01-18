# CI/CD Integration

> **Last Updated**: 2026-01-18
> **Purpose**: GitHub Actions CI/CD workflow for automated releases

---

## Hybrid Release Model

The release process uses a hybrid approach combining local preparation with CI/CD automation:

### Local Phase (`/999_release`)

1. Bumps version across all files (plugin.json, marketplace.json, .pilot-version)
2. Generates CHANGELOG entry from git commits
3. Creates git tag (vX.Y.Z)
4. Skips GitHub release creation by default (`--skip-gh`)

### CI/CD Phase (GitHub Actions)

1. Triggered on git tag push (`v*` pattern)
2. Validates version consistency across all files
3. Extracts release notes from CHANGELOG
4. Creates GitHub Release with extracted notes

---

## Workflow Configuration

**File**: `.github/workflows/release.yml`

**Trigger**: Git tag push matching `v*` pattern

**Validation Checks**:
```bash
# CI validates these match:
- Git tag version (vX.Y.Z)
- plugin.json version
- marketplace.json version
- .pilot-version
```

**Release Notes**: Automatically extracted from CHANGELOG.md section matching tag version

---

## Usage Examples

### Standard Release (uses CI/CD)

```bash
/999_release minor          # Bump version, create tag locally
git push origin main --tags  # Trigger CI/CD to create release
```

### Local Release (skip CI/CD)

```bash
/999_release patch --create-gh  # Create release locally
```

### Verification

```bash
# Check CI/CD run status
gh run list --workflow=release.yml

# View specific run
gh run view <run-id>
```

---

## Benefits

### Free Tier Benefits

- No API rate limits (GitHub Actions uses internal API)
- No authentication setup required
- Runs on GitHub's infrastructure (free for public repos)
- Consistent release formatting via CHANGELOG extraction

### Version Safety

- CI validates version consistency before creating release
- Prevents releases with mismatched versions
- Fails fast with clear error messages

---

## Troubleshooting

### Version Mismatch Error

```
Error: Tag version (4.1.7) does not match plugin.json version (4.1.6)
```

**Solution**: Re-run `/999_release` to ensure all versions are synchronized

### Missing CHANGELOG Entry

```
Release notes section not found for version 4.1.7
```

**Solution**: Manually add CHANGELOG entry or ensure commit messages are formatted for auto-generation

### CI/CD Not Triggered

```bash
git push origin main --tags  # No workflow run
```

**Solution**: Verify tag format matches `v*` pattern (e.g., `v4.1.7`, not `4.1.7`)

### Workflow Configuration

```yaml
# .github/workflows/release.yml
on:
  push:
    tags:
      - 'v*'  # Triggers on v1.0.0, v2.3.4, etc.
```

---

## See Also

- **@.claude/commands/999_release.md** - Release command documentation
- **@CLAUDE.md** - Project standards (Tier 1)
