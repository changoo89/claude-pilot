---
description: Bump version, create git tag, and create GitHub release for plugin distribution
argument-hint: "[patch|minor|major|x.y.z] --skip-gh --create-gh --dry-run --pre"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_release

_Release plugin version with git tag and GitHub release._

## Core Philosophy

**Atomic**: All steps succeed or none | **Safe**: Pre-flight checks | **Comprehensive**: Auto-generate CHANGELOG

---

## Quick Start

```bash
/999_release              # Patch release (default)
/999_release minor        # Minor version bump
/999_release major        # Major version bump
/999_release 4.5.0        # Specific version
/999_release --dry-run    # Preview changes
```

---

## Release Workflow

### Phase 1: Pre-flight Checks

**Validate environment**:
```bash
# Check jq is installed
command -v jq >/dev/null 2>&1 || { echo "Error: jq required"; exit 1; }

# Check git working tree is clean
git diff --quiet || { echo "Error: Uncommitted changes"; exit 1; }

# Validate plugin manifest (single plugin standard)
jq -e '.version' .claude-plugin/plugin.json >/dev/null 2>&1 || { echo "Error: Invalid plugin.json"; exit 1; }
```

**Check for existing tag**:
```bash
if git tag -l | grep -q "^v${VERSION}$"; then
    echo "Error: Tag v$VERSION already exists"
    exit 1
fi
```

---

### Phase 2: Version Bump

**Parse version bump type**:
```bash
VERSION_BUMP="${1:-patch}"  # Default: patch

# Read current version from plugin.json (PRIMARY source)
CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)

# Calculate new version
case "$VERSION_BUMP" in
    major)  VERSION="$((MAJOR + 1)).0.0" ;;
    minor)  VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    patch)  VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    *)      VERSION="$VERSION_BUMP" ;;  # Custom version
esac
```

**Update version file**:
```bash
# Update plugin.json (single source of truth for single plugin standard)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json
```

**Verify version consistency**:
```bash
PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)

if [ "$PLUGIN_VER" != "$VERSION" ]; then
    echo "ERROR: Version mismatch detected"
    exit 1
fi

echo "Version: $CURRENT -> $VERSION"
```

---

### Phase 3: Auto-Generate CHANGELOG

**Parse git commits**:
```bash
# Get previous tag
PREV_TAG=$(git tag -l "v*" --sort=-v:refname | grep -v "^v${VERSION}$" | head -1)
GIT_RANGE="${PREV_TAG}..HEAD"

# Categorize commits by conventional commit format
git log "$GIT_RANGE" --pretty=format:"%h|||%s|||%an|||%ad" --date=short | while IFS='|||' read -r hash subject author date; do
    # Skip version bump commits
    if echo "$subject" | grep -qiE "^chore:.*bump version"; then
        continue
    fi

    # Extract commit type (feat, fix, docs, etc.)
    TYPE=$(echo "$subject" | sed -E 's/^([a-z]+).*$/\1/')
    DESCRIPTION=$(echo "$subject" | sed -E 's/^[a-z]+(\(.+\))?:\s*//')

    # Categorize
    case "$TYPE" in
        feat)   CATEGORY="added" ;;
        fix)    CATEGORY="fixed" ;;
        docs)   CATEGORY="documentation" ;;
        *)      CATEGORY="changed" ;;
    esac
done
```

**Build CHANGELOG entry**:
```bash
CHANGELOG_ENTRY="## [$VERSION] - $(date +%Y-%m-%d)"
CHANGELOG_ENTRY+=$'\n\n'
CHANGELOG_ENTRY+="### Added"
# ... add parsed commits ...

# Insert at top of CHANGELOG.md
{
    echo "# CHANGELOG"
    echo ""
    echo "$CHANGELOG_ENTRY"
    echo ""
    tail -n +2 CHANGELOG.md
} > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md
```

---

### Phase 4: Git Operations

**Commit and tag**:
```bash
# Stage all version files
git add .claude-plugin/plugin.json CHANGELOG.md

# Commit with conventional commit format
git commit -m "chore(release): Bump version to $VERSION

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create annotated tag
git tag -a "v$VERSION" -m "Release v$VERSION"
echo "Tag created: v$VERSION"
```

---

### Phase 5: GitHub Release (Optional)

**Default: CI/CD creates release** (recommended):
```bash
# Push tag to trigger CI/CD
git push origin main --tags

# GitHub Actions workflow automatically:
# 1. Validates version consistency
# 2. Extracts CHANGELOG section
# 3. Creates GitHub Release
```

**Local release** (skip CI/CD):
```bash
if [ "$SKIP_GH" = false ]; then
    gh release create "v$VERSION" --notes-file CHANGELOG.md
    echo "GitHub release created"
fi
```

---

## Files Modified

| File | Purpose | Version Field |
|------|---------|---------------|
| `.claude-plugin/plugin.json` | **PRIMARY** - Single source of truth (single plugin standard) | `version` |
| `CHANGELOG.md` | Release notes | N/A |

---

## CI/CD Integration

**Workflow**: `.github/workflows/release.yml`

**Trigger**: Git tag push (`v*` pattern)

**Validation**:
```bash
# CI validates these match:
- Git tag version (vX.Y.Z)
- plugin.json version
```

**Benefits**:
- No API rate limits
- No authentication setup
- Runs on GitHub's infrastructure (free for public repos)

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

---

## Related Skills

**@.claude/skills/release/SKILL.md** - Full release workflow methodology
**@.claude/skills/git-master/SKILL.md** - Git operations and commits
**@docs/ai-context/cicd-integration.md** - CI/CD integration details

---

**Version**: 4.3.3 | **Last Updated**: 2026-01-21
