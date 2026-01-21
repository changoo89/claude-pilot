---
description: Bump version, create git tag, and create GitHub release for plugin distribution
argument-hint: "[patch|minor|major|x.y.z] --skip-gh --create-gh --dry-run --pre"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_release

_Release plugin version with git tag and GitHub release._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL phases below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between phases
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Phase 1 → 2 → 3 → 4 → 5 in sequence
- Only stop on ERROR or when requiring explicit user decision (e.g., --dry-run review)

---

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

**Check marketplace.json version sync**:
```bash
# Verify marketplace.json version matches plugin.json (pre-flight warning)
if [ -f .claude-plugin/marketplace.json ]; then
    MKTPLACE_VER=$(jq -r '.version' .claude-plugin/marketplace.json)
    PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)
    if [ "$MKTPLACE_VER" != "$PLUGIN_VER" ]; then
        echo "Warning: marketplace.json ($MKTPLACE_VER) != plugin.json ($PLUGIN_VER)"
        echo "Will sync marketplace.json during version bump"
    fi
fi
```

**Validate plugin.json fields** (Critical):
```bash
# Check for unsupported fields that cause install failures
UNSUPPORTED_FIELDS=("agents")
for field in "${UNSUPPORTED_FIELDS[@]}"; do
    if jq -e ".$field" .claude-plugin/plugin.json >/dev/null 2>&1; then
        echo "ERROR: plugin.json contains unsupported field '$field'"
        echo "Claude Code does not support '$field' in plugin manifest"
        echo "Remove this field before releasing"
        exit 1
    fi
done

# Verify commands/skills use string format (not array)
# Valid: "commands": "./commands/"
# Invalid: "commands": ["./commands/"]
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

**Update version files**:
```bash
# Update plugin.json (single source of truth for single plugin standard)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

# Update marketplace.json (if exists) - sync all version fields
if [ -f .claude-plugin/marketplace.json ]; then
    jq --arg v "$VERSION" '
        .version = $v |
        .metadata.version = $v |
        .plugins[0].version = $v
    ' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json
    echo "Updated marketplace.json version to $VERSION"
fi
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
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json CHANGELOG.md

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
| `.claude-plugin/marketplace.json` | Marketplace display version | `version`, `metadata.version`, `plugins[].version` |
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

### Plugin Cache Issues

**Symptom**: Plugin won't reinstall or shows old version after update

**Solution**: Clear all plugin caches
```bash
# Remove plugin from installed list
cat ~/.claude/plugins/installed_plugins.json | \
  jq 'del(.plugins["claude-pilot@claude-pilot"])' > /tmp/ip.json && \
  mv /tmp/ip.json ~/.claude/plugins/installed_plugins.json

# Remove cached plugin files
rm -rf ~/.claude/plugins/cache/claude-pilot

# Remove marketplace cache
rm -rf ~/.claude/plugins/marketplaces/claude-pilot

# Now reinstall
/plugin install claude-pilot
```

---

## Plugin Manifest Reference

### Official Plugin Structure (Recommended)

Based on analysis of official Claude Code plugins:

```
plugin-root/
├── .claude-plugin/
│   └── plugin.json      # Minimal: name, description, author
├── agents/              # Auto-detected (no manifest entry needed)
│   └── *.md
├── commands/            # Referenced in plugin.json
│   └── *.md
├── skills/              # Referenced in plugin.json
│   └── */SKILL.md
└── README.md
```

### plugin.json Best Practices

```json
{
  "name": "plugin-name",
  "description": "Short description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name",
    "url": "https://github.com/author"
  },
  "commands": "./.claude/commands/",
  "skills": "./.claude/skills/"
}
```

**Key points**:
- Keep it minimal - only include supported fields
- `agents` directory is auto-detected, do NOT add to manifest
- Use string paths, not arrays (Vercel plugin style)

---

## Related Skills

**@.claude/skills/release/SKILL.md** - Full release workflow methodology
**@.claude/skills/git-master/SKILL.md** - Git operations and commits
**@docs/ai-context/cicd-integration.md** - CI/CD integration details

---

**Version**: 4.4.6 | **Last Updated**: 2026-01-21
