# Plugin Release Workflow - Full Reference

> **Purpose**: Extended details for plugin release workflow
> **Skill**: @.claude/skills/release/SKILL.md
> **Last Updated**: 2026-01-19

---

## Step 1: Pre-flight Checks (Full Details)

### 1.4 Validate Plugin Manifests (Detailed)

**Purpose**: Ensure plugin manifests are valid before release

**Common pitfalls**:
- `agents` field in plugin.json requires actual YAML agent files
- `source` in marketplace.json must be local path (e.g., "./"), NOT GitHub URL
- `metadata` section is required in marketplace.json
- Missing `homepage`, `repository`, `license`, `keywords` causes installation failure

**Full validation code**:
```bash
echo "Validating plugin manifests..."

# Validate plugin.json
# Check for invalid agents field (requires YAML agent files)
if jq -e '.agents' .claude-plugin/plugin.json > /dev/null 2>&1; then
    if [ "$(jq '.agents | type' .claude-plugin/plugin.json)" == '"array"' ]; then
        AGENT_COUNT=$(jq '.agents | length' .claude-plugin/plugin.json)
        YAML_AGENT_COUNT=$(find .claude/agents -name '*.yaml' -o -name '*.yml' 2>/dev/null | wc -l | tr -d ' ')
        if [ "$AGENT_COUNT" -gt 0 ] && [ "$YAML_AGENT_COUNT" -eq 0 ]; then
            echo "Error: plugin.json has agents field but no YAML agent files found"
            echo "Either:"
            echo "  1. Remove agents field from plugin.json, OR"
            echo "  2. Create YAML agent files in .claude/agents/"
            echo ""
            echo "Found .md files in .claude/agents/:"
            ls -1 .claude/agents/*.md 2>/dev/null | head -5
            exit 1
        fi
    fi
fi

# Validate marketplace.json schema
# Check for required metadata section
if ! jq -e '.metadata' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    echo "Error: marketplace.json missing required 'metadata' section"
    echo ""
    echo "Required format:"
    echo '  "metadata": {'
    echo '    "description": "...",'
    echo '    "version": "X.Y.Z",'
    echo '    "pluginRoot": "./"'
    echo '  }'
    exit 1
fi

# Check metadata fields
if ! jq -e '.metadata.description' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    echo "Error: marketplace.json metadata missing 'description' field"
    exit 1
fi

if ! jq -e '.metadata.pluginRoot' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    echo "Error: marketplace.json metadata missing 'pluginRoot' field"
    exit 1
fi

# Validate plugin entry has all required fields
MISSING_FIELDS=()
if ! jq -e '.plugins[0].homepage' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    MISSING_FIELDS+=("homepage")
fi
if ! jq -e '.plugins[0].repository' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    MISSING_FIELDS+=("repository")
fi
if ! jq -e '.plugins[0].license' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    MISSING_FIELDS+=("license")
fi
if ! jq -e '.plugins[0].keywords' .claude-plugin/marketplace.json > /dev/null 2>&1; then
    MISSING_FIELDS+=("keywords")
fi

if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
    echo "Error: marketplace.json plugin entry missing required fields: ${MISSING_FIELDS[*]}"
    exit 1
fi

# Verify source is a local path, not a URL
SOURCE=$(jq -r '.plugins[0].source' .claude-plugin/marketplace.json)
if echo "$SOURCE" | grep -qE '^https?://'; then
    echo "Error: marketplace.json source must be a local path (e.g., './'), not a URL"
    echo "Current source: $SOURCE"
    exit 1
fi

echo "✓ Plugin manifests validated"
```

---

## Step 2: Parse Version Arguments (Full Details)

### Version Parsing and Validation

**Full version calculation and validation logic**:

```bash
# Parse flags
SKIP_GH=true  # Default: skip local GitHub release (CI handles it)
DRY_RUN=false
PRERELEASE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --skip-gh) SKIP_GH=true; shift ;;
        --create-gh) SKIP_GH=false; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --pre) PRERELEASE="$2"; shift 2 ;;
        *) VERSION_BUMP="$1"; shift ;;
    esac
done

# Default to patch if not specified
VERSION_BUMP="${VERSION_BUMP:-patch}"

# Read current version from plugin.json (PRIMARY source)
CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)

# Parse semver components
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3)

# Calculate based on bump type
case "$VERSION_BUMP" in
    major)
        VERSION="$((MAJOR + 1)).0.0"
        ;;
    minor)
        VERSION="${MAJOR}.$((MINOR + 1)).0"
        ;;
    patch)
        VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
        ;;
    *)
        # Validate custom version format (semver with optional prerelease)
        if ! echo "$VERSION_BUMP" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'; then
            echo "Error: Invalid version format: $VERSION_BUMP"
            echo "Expected: X.Y.Z or X.Y.Z-PRERELEASE"
            exit 1
        fi
        VERSION="$VERSION_BUMP"
        ;;
esac

# Append prerelease if specified
if [ -n "$PRERELEASE" ]; then
    VERSION="${VERSION}-${PRERELEASE}"
fi

# Check for existing tag
if git tag -l | grep -q "^v${VERSION}$"; then
    echo "Error: Git tag v$VERSION already exists"
    echo "Delete existing tag first:"
    echo "  git tag -d v$VERSION"
    echo "  git push $REMOTE :refs/tags/v$VERSION"
    exit 1
fi

echo "Current version: $CURRENT"
echo "New version: $VERSION"
```

---

## Step 3: Update Version Files (Full Details)

### Version Synchronization

**All 2 version sources**:

1. **plugin.json** (PRIMARY) - Single source of truth for plugin version
2. **marketplace.json** (DUPLICATE) - Plugin entry version

**Update commands**:
```bash
# 3.1 Update plugin.json (PRIMARY)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

# 3.2 Update marketplace.json (DUPLICATE)
jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

# Verification
echo "✓ Updated all 2 version files"
```

**Version verification**:
```bash
# Verify all files have same version
PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)
MARKET_VER=$(jq -r '.plugins[] | select(.name == "claude-pilot").version' .claude-plugin/marketplace.json)

echo "plugin.json: $PLUGIN_VER"
echo "marketplace.json: $MARKET_VER"

if [ "$PLUGIN_VER" != "$VERSION" ] || [ "$MARKET_VER" != "$VERSION" ]; then
    echo "ERROR: Version mismatch detected"
    exit 1
fi
```

---

## Step 4: Auto-Generate CHANGELOG.md (Full Implementation)

### CHANGELOG Generation Workflow

**Full commit parsing, categorization, and formatting**:

```bash
# Detect previous tag
PREV_TAG=$(git tag -l "v*" --sort=-v:refname | grep -v "^v${VERSION}$" | head -1)

if [ -z "$PREV_TAG" ]; then
    echo "Warning: No previous tag found - analyzing all commits"
    GIT_RANGE=""
else
    echo "Previous tag: $PREV_TAG"
    GIT_RANGE="${PREV_TAG}..HEAD"
fi

# Get commit list with proper formatting
if [ -n "$GIT_RANGE" ]; then
    COMMITS=$(git log $GIT_RANGE --pretty=format:"%h|||%s|||%an|||%ad" --date=short)
    COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
else
    COMMITS=$(git log --pretty=format:"%h|||%s|||%an|||%ad" --date=short)
    COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
fi

echo "Analyzing $COMMIT_COUNT commits..."

# Initialize categories
declare -A ADDED=()
declare -a CHANGED=()
declare -a FIXED=()
declare -a REMOVED=()
declare -a PERF=()
declare -a DOCS=()
declare -a OTHER=()

# Parse commits by conventional commit format
while IFS='|||' read -r hash subject author date; do
    # Skip version bump commits
    if echo "$subject" | grep -qiE "^chore:.*bump version"; then
        continue
    fi

    # Extract commit type and scope
    if echo "$subject" | grep -qE "^[a-z]+(\(.+\))?: "; then
        TYPE=$(echo "$subject" | sed -E 's/^([a-z]+).*$/\1/')
        SCOPE=$(echo "$subject" | sed -nE 's/^[a-z]+\(([^)]+)\).*/\1/p')
        DESCRIPTION=$(echo "$subject" | sed -E 's/^[a-z]+(\(.+\))?:\s*//')
    else
        TYPE="other"
        DESCRIPTION="$subject"
    fi

    # Normalize type
    case "$TYPE" in
        feat)   CATEGORY="added" ;;
        fix)    CATEGORY="fixed" ;;
        refactor|chore) CATEGORY="changed" ;;
        perf)   CATEGORY="perf" ;;
        docs)   CATEGORY="docs" ;;
        remove|rm) CATEGORY="removed" ;;
        *)      CATEGORY="other" ;;
    esac

    # Add to appropriate category array (deduplicate)
    if [ -n "$DESCRIPTION" ]; then
        KEY="$DESCRIPTION"
        case "$CATEGORY" in
            added)   [ -z "${ADDED[$KEY]}" ] && ADDED[$KEY]="$hash" ;;
            changed) [ -z "${CHANGED[$KEY]}" ] && CHANGED[$KEY]="$hash" ;;
            fixed)   [ -z "${FIXED[$KEY]}" ] && FIXED[$KEY]="$hash" ;;
            removed) [ -z "${REMOVED[$KEY]}" ] && REMOVED[$KEY]="$hash" ;;
            perf)    [ -z "${PERF[$KEY]}" ] && PERF[$KEY]="$hash" ;;
            docs)    [ -z "${DOCS[$KEY]}" ] && DOCS[$KEY]="$hash" ;;
            other)   [ -z "${OTHER[$KEY]}" ] && OTHER[$KEY]="$hash" ;;
        esac
    fi
done <<< "$COMMITS"

# Function to format category items
format_items() {
    local -n arr=$1
    local category_name=$2
    local output=""

    if [ ${#arr[@]} -gt 0 ]; then
        output="### $category_name"
        output+=$'\n'
        for key in "${!arr[@]}"; do
            # Capitalize first letter
            formatted=$(echo "$key" | sed -E 's/^([a-z])/\U\1/')
            # Add period if missing
            [[ ! "$formatted" =~ \.$ ]] && formatted="${formatted}."
            output+="  - ${formatted}"
            output+=$'\n'
        done
        output+=$'\n'
    fi

    echo "$output"
}

# Build changelog entry
CHANGELOG_CONTENT="## [$VERSION] - $RELEASE_DATE"
CHANGELOG_CONTENT+=$'\n'

# Add each category
CHANGELOG_CONTENT+="$(format_items ADDED "Added")"
CHANGELOG_CONTENT+="$(format_items CHANGED "Changed")"
CHANGELOG_CONTENT+="$(format_items FIXED "Fixed")"
CHANGELOG_CONTENT+="$(format_items REMOVED "Removed")"
CHANGELOG_CONTENT+="$(format_items PERF "Performance")"
CHANGELOG_CONTENT+="$(format_items DOCS "Documentation")"

# Add "other" category if it exists and has meaningful content
if [ ${#OTHER[@]} -gt 0 ]; then
    CHANGELOG_CONTENT+="### Other"
    CHANGELOG_CONTENT+=$'\n'
    for key in "${!OTHER[@]}"; do
        formatted=$(echo "$key" | sed -E 's/^([a-z])/\U\1/')
        [[ ! "$formatted" =~ \.$ ]] && formatted="${formatted}."
        CHANGELOG_CONTENT+="  - ${formatted}"
        CHANGELOG_CONTENT+=$'\n'
    done
    CHANGELOG_CONTENT+=$'\n'
fi

# Display summary
echo ""
echo "=========================================="
echo "Auto-Generated CHANGELOG for v$VERSION"
echo "=========================================="
echo ""
echo "$CHANGELOG_CONTENT"
echo "=========================================="
echo ""

# Save to temporary file for review
TEMP_CHANGELOG=$(mktemp)
echo "$CHANGELOG_CONTENT" > "$TEMP_CHANGELOG"

echo "Changelog saved to: $TEMP_CHANGELOG"
echo ""
echo "Options:"
echo "  1) Accept as-is"
echo "  2) Edit with default editor"
echo "  3) Provide custom changelog"
echo ""
read -p "Choose option (1/2/3): " CHOICE

case "$CHOICE" in
    2)
        # Open in editor
        ${EDITOR:-vi} "$TEMP_CHANGELOG"
        CHANGELOG_CONTENT=$(cat "$TEMP_CHANGELOG")
        ;;
    3)
        # Custom changelog
        echo "Enter custom changelog (press Ctrl+D when done):"
        CHANGELOG_CONTENT=$(cat)
        ;;
    *)
        # Accept as-is
        CHANGELOG_CONTENT=$(cat "$TEMP_CHANGELOG")
        ;;
esac

# Cleanup
rm -f "$TEMP_CHANGELOG"

# Insert into CHANGELOG.md
if [ -f CHANGELOG.md ]; then
    EXISTING_CONTENT=$(tail -n +2 CHANGELOG.md)
else
    EXISTING_CONTENT=""
    echo "# CHANGELOG" > CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> CHANGELOG.md
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

# Insert new entry at the top
{
    echo "# CHANGELOG"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    echo "$CHANGELOG_CONTENT"
    echo "$EXISTING_CONTENT"
} > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md

echo "✓ Updated CHANGELOG.md"
```

---

## Step 6: GitHub Release (OPTIONAL) - CI/CD Integration

### GitHub Actions Workflow

**Tag-triggered release workflow**: Full CI/CD integration details

```yaml
# .github/workflows/release.yml

name: Plugin Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate versions
        run: |
          VERSION_FROM_TAG="${{ github.ref_name }}"
          PLUGIN_VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
          MARKET_VERSION=$(jq -r '.plugins[] | select(.name == "claude-pilot").version' .claude-plugin/marketplace.json)
          MARKET_META_VERSION=$(jq -r '.metadata.version' .claude-plugin/marketplace.json)

          if [ "$VERSION_FROM_TAG" != "v$PLUGIN_VERSION" ] || \
             [ "$VERSION_FROM_TAG" != "v$MARKET_VERSION" ] || \
             [ "$VERSION_FROM_TAG" != "v$MARKET_META_VERSION" ]; then
            echo "Version mismatch detected"
            exit 1
          fi

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          name: Release ${{ github.ref_name }}
          body: See CHANGELOG.md for details
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Troubleshooting (Full Guide)

### Issue: Plugin Update Doesn't Apply

**Symptoms**: User runs `/plugin marketplace update` and `/plugin update` but still has old version.

**Diagnosis**:
```bash
# Check cached version
ls -la ~/.claude/plugins/cache/claude-pilot/claude-pilot/

# Check installed version
/plugin list | grep claude-pilot
```

**Solutions** (in order):
1. **Force reinstall**:
   ```bash
   /plugin uninstall claude-pilot@changoo89
   /plugin install claude-pilot@changoo89
   ```

2. **Clear cache**:
   ```bash
   rm -rf ~/.claude/plugins/cache/claude-pilot
   /plugin install claude-pilot@changoo89
   ```

3. **Verify marketplace source**:
   ```bash
   # Should point to GitHub, NOT local path
   cat .claude/settings.json | jq '.extraKnownMarketplaces'
   ```

### Issue: Commands Show Up Twice

**Symptoms**: Commands appear with and without `claude-pilot:` prefix.

**Root Cause**: Project has local `.claude/commands/` folder AND uses plugin.

**Solution**: Remove local commands folder:
```bash
# Backup first
cp -r .claude/commands .claude/commands.backup

# Remove local commands
rm -rf .claude/commands

# Reload Claude Code
```

### Issue: Stop Hook Permission Denied

**Symptoms**: `Stop hook error: Permission denied` for hook scripts.

**Solution** (Automatic - Recommended):
```bash
/pilot:setup
```

**Solution** (Manual):
```bash
# Make all hook scripts executable
chmod +x .claude/scripts/hooks/*.sh

# Verify permissions
ls -la .claude/scripts/hooks/*.sh
# Expected: -rwxr-xr-x (executable)
```

**Prevention**: After plugin update, always run `/pilot:setup` to ensure permissions are correct.

---

## Best Practices (Full Guidelines)

### For Plugin Maintainers

1. **Always use `/999_release`** - Ensures version consistency
2. **Test before releasing** - Use `--dry-run` flag
3. **Document breaking changes** - Add to CHANGELOG manually if needed
4. **Keep plugin.json updated** - Single source of truth for version

### For Plugin Users

1. **Use GitHub marketplace source** - Not local paths
2. **Don't copy commands/skills locally** - Let plugin handle it
3. **Clear cache if updates fail** - See troubleshooting above
4. **Report issues with details** - Include `/plugin list` output

### Release Workflow

**Maintainer (You)**:
1. `/999_release` - Bump version, tag, push to GitHub
2. Git tag triggers plugin update detection

**User (Plugin Consumers)**:
```bash
# Update marketplace to get latest version info
/plugin marketplace update

# Update plugin to latest version
/plugin update claude-pilot@changoo89

# If updates don't apply (cache issues):
/plugin uninstall claude-pilot@changoo89
rm -rf ~/.claude/plugins/cache/claude-pilot
/plugin install claude-pilot@changoo89
```

### Version Tracking

**Single Source of Truth**: `.claude-plugin/plugin.json`

```json
{
  "version": "4.1.8"  // Always update this file
}
```

**Never manually edit**:
- `.claude-plugin/marketplace.json` version (auto-synced)
