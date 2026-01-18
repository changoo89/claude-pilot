# CI/CD Integration

> **Last Updated**: 2026-01-18
> **Purpose**: GitHub Actions CI/CD workflow for automated releases

---

## Overview

GitHub Actions CI/CD integration provides automated release creation on git tag push, with version consistency validation and automatic CHANGELOG integration. This implements a hybrid model where local `/999_release` prepares and tags, while CI creates the GitHub Release.

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

## Version Validation

**Validation Script** (`.github/scripts/validate_versions.sh`):
- Checks `plugin.json` version
- Checks `marketplace.json` version
- Checks `.pilot-version` file
- Compares all versions against git tag
- Exits with error if mismatch detected

**Example**:
```bash
# Pass: All versions match tag
./validate_versions.sh "4.1.8"  # Exit 0

# Fail: Version mismatch
./validate_versions.sh "9.9.9"  # Exit 1, prints error
```

---

## CHANGELOG Integration

**Workflow extracts version section from CHANGELOG.md**:
```markdown
## [4.1.8] - 2026-01-18
### Added
- GitHub Actions CI/CD integration

### Changed
- /999_release: SKIP_GH defaults to true

### Fixed
- Version consistency validation in CI
```

**Fallback**: If CHANGELOG section not found, uses generic release body

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

## Cost Analysis

**GitHub Actions Free Tier**:
- Public repositories: Unlimited free usage
- Private repositories: 2,000 minutes/month

**Tag-triggered workflow cost**:
- Typical runtime: 30-60 seconds
- Release frequency: ~10-20 per month
- **Total**: ~10-20 minutes/month (negligible)

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

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/999_release` | Creates tag | → GitHub webhook trigger |
| `release.yml` | Listens for tag | ← Tag push event |
| `validate_versions.sh` | Validates consistency | → Workflow pass/fail |
| `softprops/action-gh-release` | Creates release | → GitHub Release API |

---

## Testing

**Test Files**:
- `.pilot/tests/test_github_workflow.sh` (11 tests, 100% pass)
- `.pilot/tests/test_999_skip_gh.sh` (4 tests, 100% pass)

**Test Coverage**:
- Workflow file structure and syntax
- Tag trigger configuration
- Permissions and action dependencies
- Version validation logic
- CHANGELOG extraction
- Default behavior change (SKIP_GH=true)

---

## Documentation

**CLAUDE.md**:
- Added CI/CD section with hybrid model explanation
- Troubleshooting guide for common issues
- Cost analysis and free tier details

**CHANGELOG.md**:
- CI/CD integration entry with feature summary

---

## Migration from Local Release

**Before (v4.1.7)**:
```bash
/999_release patch
# Local: Bump version, tag, create GitHub Release (requires gh CLI)
```

**After (v4.1.8)**:
```bash
/999_release patch
# Local: Bump version, tag, push
# CI: Validate versions, create GitHub Release (no gh CLI needed)
```

---

## See Also

- **@.claude/commands/999_release.md** - Release command documentation
- **@CLAUDE.md** - Project standards (Tier 1)
- **@docs/ai-context/system-integration.md** - Core workflows and integration

---

**Last Updated**: 2026-01-18
**Version**: 4.2.0
