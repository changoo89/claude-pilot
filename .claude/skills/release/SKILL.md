---
name: release
description: Plugin release workflow skill for version bumping, git tagging, and GitHub release creation. Use when releasing plugin versions with automated CHANGELOG generation and version synchronization.
---

# SKILL: Plugin Release Workflow

> **Purpose**: Execute plugin release workflow with version bumping, git tagging, and GitHub release
> **Target**: Plugin maintainers releasing new versions

---

## Quick Start

### When to Use This Skill
- Release new plugin version
- Bump version (patch/minor/major)
- Create git tag and GitHub release

### Quick Reference
```bash
# Standard release (patch version, CI handles GitHub release)
/999_release

# Minor version
/999_release minor

# Force local GitHub release
/999_release patch --create-gh

# Dry run (preview)
/999_release patch --dry-run
```

## What This Skill Covers

### In Scope
- Version synchronization (plugin.json, marketplace.json)
- Git tagging and pushing
- CHANGELOG auto-generation from commits
- GitHub release creation (optional)
- Pre-flight validation

### Out of Scope
- Plugin architecture → @CLAUDE.md
- Git workflow patterns → @.claude/skills/git-master/SKILL.md
- Migration guide → MIGRATION.md

---

## Core Concepts

### Single Source of Truth

**plugin.json** is the PRIMARY version source:
```json
{
  "version": "4.2.0"  // Always update this file
}
```

**Auto-synced file** (DO NOT edit manually):
- marketplace.json - Plugin entry version

### Release Workflow

**Pre-flight** → Version bump → CHANGELOG → Git tag → GitHub release

1. **Pre-flight Checks**: Validate jq, git, working tree, plugin manifests
2. **Version Bump**: Update version files atomically
3. **CHANGELOG**: Auto-generate from git commits (conventional commit format)
4. **Git Operations**: Commit, tag, push to remote
5. **GitHub Release**: Optional (local or CI/CD)

### CI/CD Integration

**Hybrid model**: Local tagging + CI/CD release creation
- Local: Bump version, create tag, push
- CI: Validates versions, creates GitHub release

**Benefits**:
- No API rate limits
- No authentication setup
- Runs on GitHub's infrastructure

---

## Execution Steps

### Parse Arguments

```bash
# Parse command-line arguments
VERSION_BUMP="${1:-patch}"  # Default: patch
DRY_RUN=false
SKIP_GH=true   # Default: Skip local GH release (let CI handle it)
CREATE_GH=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)   DRY_RUN=true ;;
        --skip-gh)   SKIP_GH=true ;;
        --create-gh) CREATE_GH=true; SKIP_GH=false ;;
        patch|minor|major) VERSION_BUMP="$arg" ;;
        *)
            if [[ "$arg" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
                VERSION_BUMP="$arg"
            fi
            ;;
    esac
done

echo "Release Configuration:"
echo "  Version Bump: $VERSION_BUMP"
echo "  Dry Run: $DRY_RUN"
echo "  Skip GitHub Release: $SKIP_GH"
echo "  Create GitHub Release: $CREATE_GH"
```

---

### Phase 1: Pre-flight Checks

**Validate environment**:
```bash
# Check jq is installed
command -v jq >/dev/null 2>&1 || {
    echo "ERROR: jq required for JSON manipulation"
    echo "Install: brew install jq (macOS) or sudo apt-get install jq (Linux)"
    exit 1
}

# Check git working tree is clean
if ! git diff --quiet; then
    echo "ERROR: Uncommitted changes detected"
    echo "Please commit or stash changes before releasing"
    git status --short
    exit 1
fi

# Validate plugin manifest (single plugin standard)
if ! jq -e '.version' .claude-plugin/plugin.json >/dev/null 2>&1; then
    echo "ERROR: Invalid plugin.json - missing version field"
    exit 1
fi

echo "✓ Pre-flight checks passed"
```

**Check marketplace.json version sync**:
```bash
# Verify marketplace.json version matches plugin.json (pre-flight warning)
if [ -f .claude-plugin/marketplace.json ]; then
    MKTPLACE_VER=$(jq -r '.version' .claude-plugin/marketplace.json)
    PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)
    if [ "$MKTPLACE_VER" != "$PLUGIN_VER" ]; then
        echo "⚠️  Warning: marketplace.json ($MKTPLACE_VER) != plugin.json ($PLUGIN_VER)"
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

---

### Phase 2: Version Bump

**Parse version bump type**:
```bash
# Read current version from plugin.json (PRIMARY source)
CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# Calculate new version
case "$VERSION_BUMP" in
    major)  NEW_VERSION="$((MAJOR + 1)).0.0" ;;
    minor)  NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    patch)  NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    *)      NEW_VERSION="$VERSION_BUMP" ;;  # Custom version (e.g., 4.5.0)
esac

echo "Version: $CURRENT → $NEW_VERSION"
```

**Check for existing tag**:
```bash
if git tag -l | grep -q "^v${NEW_VERSION}$"; then
    echo "ERROR: Tag v$NEW_VERSION already exists"
    echo "Delete existing tag first:"
    echo "  git tag -d v$NEW_VERSION"
    echo "  git push origin :refs/tags/v$NEW_VERSION"
    exit 1
fi
```

**Update version files**:
```bash
# Update plugin.json (single source of truth for single plugin standard)
jq --arg v "$NEW_VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

echo "✓ Updated plugin.json to $NEW_VERSION"

# Update marketplace.json (if exists) - sync all version fields
if [ -f .claude-plugin/marketplace.json ]; then
    jq --arg v "$NEW_VERSION" '
        .version = $v |
        .metadata.version = $v |
        .plugins[0].version = $v
    ' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json
    echo "✓ Updated marketplace.json to $NEW_VERSION"
fi
```

**Verify version consistency**:
```bash
PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)

if [ "$PLUGIN_VER" != "$NEW_VERSION" ]; then
    echo "ERROR: Version mismatch detected after update"
    echo "Expected: $NEW_VERSION"
    echo "Got: $PLUGIN_VER"
    exit 1
fi

echo "✓ Version consistency verified: $NEW_VERSION"
```

---

### Phase 3: Auto-Generate CHANGELOG

**Parse git commits**:
```bash
# Get previous tag
PREV_TAG=$(git tag -l "v*" --sort=-v:refname | head -1)

if [ -z "$PREV_TAG" ]; then
    GIT_RANGE="HEAD"
    echo "No previous tags found - using all commits"
else
    GIT_RANGE="${PREV_TAG}..HEAD"
    echo "Commits since $PREV_TAG"
fi

# Initialize category arrays
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a DOCS=()

# Categorize commits by conventional commit format
while IFS='|||' read -r hash subject author date; do
    # Skip version bump commits
    if echo "$subject" | grep -qiE "^chore.*bump version|^chore\(release\)"; then
        continue
    fi

    # Extract commit type and description
    if [[ "$subject" =~ ^([a-z]+)(\(.+\))?:\ (.+)$ ]]; then
        TYPE="${BASH_REMATCH[1]}"
        DESCRIPTION="${BASH_REMATCH[3]}"
    else
        # Non-conventional commit
        TYPE="other"
        DESCRIPTION="$subject"
    fi

    # Categorize
    case "$TYPE" in
        feat)   ADDED+=("- $DESCRIPTION ($hash)") ;;
        fix)    FIXED+=("- $DESCRIPTION ($hash)") ;;
        docs)   DOCS+=("- $DESCRIPTION ($hash)") ;;
        *)      CHANGED+=("- $DESCRIPTION ($hash)") ;;
    esac
done < <(git log "$GIT_RANGE" --pretty=format:"%h|||%s|||%an|||%ad" --date=short)

echo "Parsed ${#ADDED[@]} features, ${#FIXED[@]} fixes, ${#CHANGED[@]} changes, ${#DOCS[@]} doc updates"
```

**Build CHANGELOG entry**:
```bash
CHANGELOG_ENTRY="## [$NEW_VERSION] - $(date +%Y-%m-%d)"
CHANGELOG_ENTRY+=$'\n'

# Add categories (only if non-empty)
if [ ${#ADDED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+=$'\n### Added\n'
    for item in "${ADDED[@]}"; do
        CHANGELOG_ENTRY+="$item"$'\n'
    done
fi

if [ ${#FIXED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+=$'\n### Fixed\n'
    for item in "${FIXED[@]}"; do
        CHANGELOG_ENTRY+="$item"$'\n'
    done
fi

if [ ${#CHANGED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+=$'\n### Changed\n'
    for item in "${CHANGED[@]}"; do
        CHANGELOG_ENTRY+="$item"$'\n'
    done
fi

if [ ${#DOCS[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+=$'\n### Documentation\n'
    for item in "${DOCS[@]}"; do
        CHANGELOG_ENTRY+="$item"$'\n'
    done
fi

# Insert at top of CHANGELOG.md (preserve existing content)
{
    echo "# CHANGELOG"
    echo ""
    echo "$CHANGELOG_ENTRY"
    echo ""
    tail -n +3 CHANGELOG.md 2>/dev/null || true
} > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md

echo "✓ CHANGELOG.md updated"
```

---

### Phase 4: Git Operations

**Preview changes (dry-run)**:
```bash
if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "===== DRY RUN MODE ====="
    echo "Version: $CURRENT → $NEW_VERSION"
    echo ""
    echo "Files to be committed:"
    echo "  - .claude-plugin/plugin.json"
    [ -f .claude-plugin/marketplace.json ] && echo "  - .claude-plugin/marketplace.json"
    echo "  - CHANGELOG.md"
    echo ""
    echo "Git tag to be created: v$NEW_VERSION"
    echo ""
    echo "CHANGELOG preview:"
    head -n 30 CHANGELOG.md
    echo ""
    echo "Run without --dry-run to execute release"
    exit 0
fi
```

**Commit and tag**:
```bash
# Stage all version files
git add .claude-plugin/plugin.json CHANGELOG.md
[ -f .claude-plugin/marketplace.json ] && git add .claude-plugin/marketplace.json

# Commit with conventional commit format
git commit -m "chore(release): Bump version to $NEW_VERSION

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✓ Committed version bump"

# Create annotated tag
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
echo "✓ Tag created: v$NEW_VERSION"
```

**Push to remote**:
```bash
# Push commit and tag to trigger CI/CD
git push origin main --tags

echo "✓ Pushed to remote (main + tags)"
echo ""
echo "GitHub Actions will automatically create release from tag v$NEW_VERSION"
```

---

### Phase 5: GitHub Release (Optional)

**Create local release** (skip CI/CD):
```bash
if [ "$CREATE_GH" = true ]; then
    # Check if gh CLI is installed
    if ! command -v gh >/dev/null 2>&1; then
        echo "⚠️  gh CLI not installed - skipping GitHub release"
        echo "Install: brew install gh"
        exit 0
    fi

    # Extract CHANGELOG section for this version
    RELEASE_NOTES=$(awk "/^## \[$NEW_VERSION\]/,/^## \[/" CHANGELOG.md | sed '$d')

    # Create GitHub release
    gh release create "v$NEW_VERSION" \
        --title "Release v$NEW_VERSION" \
        --notes "$RELEASE_NOTES"

    echo "✓ GitHub release created: v$NEW_VERSION"
else
    echo "ℹ️  Skipping local GitHub release (CI/CD will handle it)"
fi
```

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

## Further Reading

**Internal**: @.claude/skills/release/REFERENCE.md - Full release workflow implementation details | @.claude/skills/git-master/SKILL.md - Git operations and commits | @.claude/commands/999_release.md - Release command

**External**: [Semantic Versioning](https://semver.org/) | [Conventional Commits](https://www.conventionalcommits.org/) | [Keep a Changelog](https://keepachangelog.com/)
