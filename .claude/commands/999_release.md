---
description: Bump version, create git tag, and create GitHub release for plugin distribution
argument-hint: "[patch|minor|major|x.y.z] --skip-gh --dry-run --pre"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_release

_Release plugin version with git tag and GitHub release._

## Core Philosophy

- **Atomic**: All steps succeed or none do
- **Safe**: Pre-flight checks before any modifications
- **Comprehensive**: Auto-generate CHANGELOG from git commits
- **Graceful**: Optional GitHub CLI with clear fallback
- **Plugin Distribution**: Git tags + releases, no PyPI

**Plugin workflow**: Users update via `/plugin marketplace update` + `/plugin update`

**CHANGELOG Workflow**:
1. Detect previous tag
2. Collect all commits since previous tag
3. Parse conventional commits (feat, fix, docs, etc.)
4. Categorize into Added, Changed, Fixed, Removed, Performance, Documentation
5. Generate formatted CHANGELOG entry
6. Prompt for review/edit before inserting

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before release
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Security review | Keywords: "security", "auth", "credential" in user input | Delegate to GPT Security Analyst |
| User explicitly requests | "ask GPT", "consult GPT", "security review" | Delegate to GPT Security Analyst |

### Delegation Flow

1. **STOP**: Scan user input for trigger signals
2. **MATCH**: Identify expert type from triggers
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/security-analyst.md`
4. **CHECK**: Verify Codex CLI is installed (graceful fallback if not)
5. **EXECUTE**: Call `codex-sync.sh "read-only" "<prompt>"` or continue with Claude agents
6. **CONFIRM**: Log delegation decision

### Graceful Fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

---

## Step 1: Pre-flight Checks

> **Verify environment and tools before any modifications**

### 1.1 Check Required Tools

```bash
# Check for jq (required for JSON updates)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Install: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# Check for git (required)
if ! command -v git &> /dev/null; then
    echo "Error: git is required but not initialized"
    exit 1
fi
```

### 1.2 Detect Git Configuration

> **Auto-detect remote and default branch with proper fallbacks**

```bash
# Auto-detect remote (with fallback to 'origin' if empty)
REMOTE=$(git remote 2>/dev/null | head -1)
REMOTE=${REMOTE:-origin}
echo "Detected remote: $REMOTE"

# Auto-detect default branch (uses detected remote)
BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)
echo "Detected branch: $BRANCH"

# Verify remote exists
if ! git remote | grep -q "^${REMOTE}$"; then
    echo "Error: Git remote '$REMOTE' not found"
    echo "Available remotes: $(git remote)"
    exit 1
fi
```

### 1.3 Check Working Tree State

```bash
# Check for uncommitted changes (abort unless --force)
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working tree has uncommitted changes"
    echo "Commit or stash changes before release"
    git status --short
    exit 1
fi
```

### 1.4 Validate Plugin Manifests

> **CRITICAL**: Validate plugin.json and marketplace.json before release
>
> **Common pitfalls**:
> - `agents` field in plugin.json requires actual YAML agent files
> - `source` in marketplace.json must be local path (e.g., "./"), NOT GitHub URL
> - `metadata` section is required in marketplace.json
> - Missing `homepage`, `repository`, `license`, `keywords` causes installation failure

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
    echo ""
    echo "Required format:"
    echo '  "plugins": [{'
    echo '    "name": "...",'
    echo '    "source": "./",'
    echo '    "description": "...",'
    echo '    "category": "...",'
    echo '    "version": "...",'
    echo '    "author": { "name": "...", "email": "..." },'
    echo '    "homepage": "https://github.com/owner/repo",'
    echo '    "repository": "https://github.com/owner/repo",'
    echo '    "license": "MIT",'
    echo '    "keywords": [...]'
    echo '  }]'
    exit 1
fi

# Verify source is a local path, not a URL
SOURCE=$(jq -r '.plugins[0].source' .claude-plugin/marketplace.json)
if echo "$SOURCE" | grep -qE '^https?://'; then
    echo "Error: marketplace.json source must be a local path (e.g., './'), not a URL"
    echo "Current source: $SOURCE"
    echo ""
    echo "The source field specifies where the plugin is located WITHIN the repository,"
    echo "not the repository URL. Use './' for root-level plugins."
    exit 1
fi

echo "✓ Plugin manifests validated"
```

---

## Step 2: Parse Version Arguments

> **Determine version bump type or specific version**

### 2.1 Parse Bump Type

```bash
ARGUMENTS="${ARGUMENTS:-}"

# Parse flags
SKIP_GH=false
DRY_RUN=false
PRERELEASE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --skip-gh) SKIP_GH=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --pre) PRERELEASE="$2"; shift 2 ;;
        *) VERSION_BUMP="$1"; shift ;;
    esac
done <<< "$ARGUMENTS"

# Default to patch if not specified
VERSION_BUMP="${VERSION_BUMP:-patch}"
```

### 2.2 Read Current Version

> **Primary source: `.claude-plugin/plugin.json`**

```bash
CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)
echo "Current version: $CURRENT"
```

### 2.3 Calculate New Version

```bash
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

echo "New version: $VERSION"
```

### 2.4 Check for Existing Tag

```bash
if git tag -l | grep -q "^v${VERSION}$"; then
    echo "Error: Git tag v${VERSION} already exists"
    echo "Delete existing tag first: git tag -d v${VERSION} && git push $REMOTE :refs/tags/v${VERSION}"
    exit 1
fi
```

---

## Step 3: Update Version Files

> **Sync version across all 3 sources**

### 3.1 Update plugin.json (PRIMARY)

```bash
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json &&
mv tmp.json .claude-plugin/plugin.json
echo "✓ Updated .claude-plugin/plugin.json"
```

### 3.2 Update marketplace.json (DUPLICATE)

> **Updates plugin version in marketplace entry**

```bash
jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp.json &&
mv tmp.json .claude-plugin/marketplace.json
echo "✓ Updated .claude-plugin/marketplace.json"
```

### 3.3 Update .pilot-version (INTERNAL)

```bash
echo "$VERSION" > .claude/.pilot-version
echo "✓ Updated .claude/.pilot-version"
```

---

## Step 4: Auto-Generate CHANGELOG.md

> **Automatically analyze git commits and generate comprehensive changelog**

### 4.1 Detect Previous Tag

```bash
# Find the most recent tag before current version
PREV_TAG=$(git tag -l "v*" --sort=-v:refname | grep -v "^v${VERSION}$" | head -1)

if [ -z "$PREV_TAG" ]; then
    echo "Warning: No previous tag found - analyzing all commits"
    GIT_RANGE=""
else
    echo "Previous tag: $PREV_TAG"
    GIT_RANGE="${PREV_TAG}..HEAD"
fi
```

### 4.2 Collect and Analyze Commits

```bash
RELEASE_DATE=$(date +%Y-%m-%d)

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
declare -A CHANGED=()
declare -A FIXED=()
declare -A REMOVED=()
declare -A PERF=()
declare -A DOCS=()
declare -A OTHER=()

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
```

### 4.3 Generate CHANGELOG Entry

```bash
# Function to format category items
format_items() {
    local -n arr=$1
    local category_name=$2
    local output=""

    if [ ${#arr[@]} -gt 0 ]; then
        output="### ${category_name}"
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
```

### 4.4 Review and Edit

```bash
# Save to temporary file for review
TEMP_CHANGELOG=$(mktemp)
echo "$CHANGELOG_CONTENT" > "$TEMP_CHANGELOG"

echo "Changelog saved to: $TEMP_CHANGELOG"
echo ""
echo "Options:"
echo "  1. Accept as-is"
echo "  2. Edit with default editor"
echo "  3. Provide custom changelog"
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
```

### 4.5 Insert into CHANGELOG.md

```bash
# Read existing CHANGELOG
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

## Step 5: Git Operations

> **Stage files, commit, create tag, and push**

### 5.1 Stage Version Files

```bash
# Stage version files and changelog
git add .claude-plugin/plugin.json
git add .claude-plugin/marketplace.json
git add .claude/.pilot-version
git add CHANGELOG.md

# Stage command/doc changes if they exist
git add .claude/commands/999_release.md 2>/dev/null || true
git add CLAUDE.md MIGRATION.md 2>/dev/null || true
```

### 5.2 Commit Version Bump

```bash
git commit -m "chore: bump version to $VERSION"
echo "✓ Committed version bump"
```

### 5.3 Create Annotated Tag

```bash
git tag -a "v$VERSION" -m "Release $VERSION"
echo "✓ Created tag v$VERSION"
```

### 5.4 Push to Remote

```bash
if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would push to $REMOTE $BRANCH --tags"
else
    git push "$REMOTE" "$BRANCH" --tags
    echo "✓ Pushed to $REMOTE $BRANCH"
    echo "✓ Pushed tag v$VERSION"
fi
```

---

## Step 6: GitHub Release (OPTIONAL)

> **Create GitHub release if gh CLI available**

### 6.1 Check GitHub CLI

```bash
if ! command -v gh &> /dev/null; then
    echo ""
    echo "Note: GitHub CLI not installed - skipping release creation"
    echo "Tag pushed to GitHub - create release manually at:"
    echo "https://github.com/changoo89/claude-pilot/releases/new?tag=v$VERSION"
    echo ""
    echo "Install gh CLI: brew install gh (macOS) or https://cli.github.com/"
    exit 0
fi
```

### 6.2 Create GitHub Release

```bash
if [ "$SKIP_GH" = true ]; then
    echo "Skipping GitHub release creation (--skip-gh flag)"
else
    # Extract release notes from CHANGELOG section (remove trailing delimiter)
    RELEASE_BODY=$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | sed '$d')

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would create GitHub release v$VERSION"
    else
        gh release create "v$VERSION" --notes "$RELEASE_BODY"
        echo "✓ Created GitHub release v$VERSION"
    fi
fi
```

---

## Step 7: Post-Release User Notification

> **Notify users and provide update instructions**

### 7.1 Display Update Instructions

```bash
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Release v$VERSION Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Plugin users can update with:"
echo ""
echo "  /plugin marketplace update"
echo "  /plugin update claude-pilot@claude-pilot"
echo ""
echo "Or if updates don't apply:"
echo ""
echo "  /plugin uninstall claude-pilot@claude-pilot"
echo "  rm -rf ~/.claude/plugins/cache/claude-pilot"
echo "  /plugin install claude-pilot@claude-pilot"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
```

### 7.2 Create Release Summary (Optional)

```bash
# Generate summary for project documentation
cat > RELEASE_NOTES.md.tmp << EOF
# claude-pilot v$VERSION Release Notes

**Released**: $(date +%Y-%m-%d)

## Installation

\`\`\`bash
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot@claude-pilot
\`\`\`

## Updating from Previous Version

\`\`\`bash
# Method 1: Standard update
/plugin marketplace update
/plugin update claude-pilot@claude-pilot

# Method 2: If update fails (cache issues)
/plugin uninstall claude-pilot@claude-pilot
rm -rf ~/.claude/plugins/cache/claude-pilot
/plugin install claude-pilot@claude-pilot
\`\`\`

## What's Changed

$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | sed '$d')

EOF

cat RELEASE_NOTES.md.tmp
rm -f RELEASE_NOTES.md.tmp
```

---

## Success Criteria

- [ ] Pre-flight checks passed (jq, git, remote, clean working tree)
- [ ] Plugin manifests validated (plugin.json, marketplace.json)
  - [ ] No invalid agents field (or YAML agent files exist)
  - [ ] marketplace.json has metadata section
  - [ ] marketplace.json has all required fields (homepage, repository, license, keywords)
  - [ ] source field is local path, not URL
- [ ] Version synced across all 3 files (plugin.json, marketplace.json, pilot-version)
- [ ] CHANGELOG.md auto-generated from git commits
  - [ ] Previous tag detected
  - [ ] All commits analyzed and categorized
  - [ ] Changelog reviewed/edited by user
- [ ] Git commit created: "chore: bump version to X.Y.Z"
- [ ] Git tag created and pushed: v{version}
- [ ] GitHub release created (if gh CLI available and not --skip-gh)
- [ ] Post-release instructions displayed to user
- [ ] Update troubleshooting guide if new issues discovered

---

## Usage Examples

| Command | Description |
|---------|-------------|
| `/999_release` | Patch version (x.y.Z) with auto-generated CHANGELOG and GitHub release |
| `/999_release patch` | Patch version (x.y.Z) |
| `/999_release minor` | Minor version (x.Y.0) |
| `/999_release major` | Major version (X.0.0) |
| `/999_release 4.2.0` | Specific version (4.2.0) |
| `/999_release patch --skip-gh` | Skip GitHub release creation |
| `/999_release patch --dry-run` | Preview changes without executing |
| `/999_release patch --pre alpha.1` | Pre-release version (x.y.Z-alpha.1) |

### CHANGELOG Auto-Generation

The command automatically:
1. Detects the previous git tag
2. Collects all commits since the previous tag
3. Parses conventional commit format (feat, fix, docs, etc.)
4. Categorizes changes into Added, Changed, Fixed, Removed, Performance, Documentation
5. Generates formatted CHANGELOG entry
6. Prompts for review/edit before inserting

**Example Output**:
```
==========================================
Auto-Generated CHANGELOG for v4.1.6
==========================================

## [4.1.6] - 2026-01-18

### Added
  - Sisyphus Continuation System for agent persistence.
  - Worktree mode support in /03_close command.

### Fixed
  - Ensure git push completion in /03_close.
  - Resolve intermittent Codex CLI detection failure.

==========================================
```

---

## Error Handling

| Error | Action |
|-------|--------|
| jq not installed | Exit with install instructions |
| Git remote not found | Exit with available remotes |
| Working tree dirty | Exit with git status |
| **Invalid agents field** | Exit: Remove agents field or create YAML agent files |
| **Missing metadata section** | Exit: Add metadata with description, version, pluginRoot |
| **Missing plugin fields** | Exit: Add homepage, repository, license, keywords |
| **Invalid source (URL)** | Exit: Change source to local path (e.g., "./") |
| Tag already exists | Exit with delete instructions |
| Invalid version format | Exit with format examples |
| GitHub release fails | Continue - tag already pushed |

### Common Manifest Errors (from real debugging)

**Error**: `plugins.0.source: Invalid input`
- **Cause**: source field contains GitHub URL instead of local path
- **Fix**: Change `"source": "https://github.com/..."` to `"source": "./"`

**Error**: `agents: Invalid input`
- **Cause**: plugin.json has agents field but no YAML agent files exist
- **Fix**: Either remove agents field OR create *.yaml files in .claude/agents/

**Error**: `Invalid schema`
- **Cause**: marketplace.json missing metadata section or required fields
- **Fix**: Add metadata section with description, version, pluginRoot

---

## Troubleshooting

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
   /plugin uninstall claude-pilot@claude-pilot
   /plugin install claude-pilot@claude-pilot
   ```

2. **Clear cache**:
   ```bash
   rm -rf ~/.claude/plugins/cache/claude-pilot
   /plugin install claude-pilot@claude-pilot
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

**Solution**: Add execute permissions:
```bash
find .claude/scripts/hooks -name "*.sh" -exec chmod +x {} \;
```

### Issue: Wrong Marketplace Source

**Symptoms**: Plugin installs from wrong source or outdated version.

**Diagnosis**:
```bash
# Check marketplace configuration
cat .claude/settings.json | jq '.extraKnownMarketplaces'

# Should see:
# {
#   "claude-pilot": {
#     "source": {
#       "source": "github",
#       "repo": "changoo89/claude-pilot"
#     }
#   }
# }
```

**Solution**: Update settings.json to use GitHub marketplace source.

---

## CI/CD Automation (Recommended)

### GitHub Actions Workflow

Create `.github/workflows/release.yml` for automated releases:

```yaml
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

### Benefits

- ✅ Automatic GitHub release creation on tag push
- ✅ No manual release steps needed
- ✅ Consistent release process
- ✅ Integrates with `/999_release` workflow

### Usage with /999_release

```bash
# Step 1: Run /999_release as usual
/999_release minor

# Step 2: Push tag (triggers GitHub Actions)
git push origin main --tags

# Step 3: GitHub Actions automatically creates release
# No manual intervention needed!
```

---

## Best Practices

### For Plugin Maintainers

1. **Always use `/999_release`** - Ensures version consistency
2. **Test before releasing** - Use `--dry-run` flag
3. **Document breaking changes** - Add to CHANGELOG manually if needed
4. **Keep plugin.json updated** - Single source of truth for version
5. **Monitor user issues** - Update troubleshooting guide as needed

### For Plugin Users

1. **Use GitHub marketplace source** - Not local paths
2. **Don't copy commands/skills locally** - Let plugin handle it
3. **Clear cache if updates fail** - See troubleshooting above
4. **Report issues with details** - Include `/plugin list` output

---

## Distribution Notes

### Plugin Distribution Workflow

**Maintainer (You)**:
1. `/999_release` - Bump version, tag, push to GitHub
2. Git tag triggers plugin update detection

**User (Plugin Consumers)**:
```bash
# Update marketplace to get latest version info
/plugin marketplace update

# Update plugin to latest version
/plugin update claude-pilot@claude-pilot

# If updates don't apply (cache issues):
/plugin uninstall claude-pilot@claude-pilot
rm -rf ~/.claude/plugins/cache/claude-pilot
/plugin install claude-pilot@claude-pilot
```

### Why Updates Don't Auto-Apply

**Common Issue**: Users run `/plugin marketplace update` but don't get latest changes.

**Root Causes**:
1. **Plugin cache stores old versions** - cached in `~/.claude/plugins/cache/`
2. **Commit SHA tracking** - plugins track specific commits, not latest tag
3. **No force-refresh** - `/plugin update` doesn't always clear cache

**Solution**: Document cache clearing in release notes (Step 7.1)

### Version Tracking

**Single Source of Truth**: `.claude-plugin/plugin.json`

```json
{
  "version": "4.1.8"  // Always update this file
}
```

**Never manually edit**:
- `.claude-plugin/marketplace.json` version (auto-synced)
- `.pilot-version` (auto-synced)

---

## Related Guides

- **Git Workflow**: @.claude/skills/git-master/SKILL.md
- **Plugin Marketplace**: [Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- **Migration Guide**: MIGRATION.md

---

## References

- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Remote**: `git remote | head -1` (fallback: `origin`)
- **Status**: `git status --porcelain`
