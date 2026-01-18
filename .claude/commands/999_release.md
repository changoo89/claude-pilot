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
- **Graceful**: Optional GitHub CLI with clear fallback
- **Plugin Distribution**: Git tags + releases, no PyPI

**Plugin workflow**: Users update via `/plugin marketplace update` + `/plugin update`

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

## Step 4: Update CHANGELOG.md

> **Prompt for release notes and insert at top of changelog**

### 4.1 Prepare Release Notes

```bash
RELEASE_DATE=$(date +%Y-%m-%d)
RELEASE_NOTES_HEADER="## [$VERSION] - $RELEASE_DATE"

echo ""
echo "Enter release notes for $VERSION (press Ctrl+D when done):"
echo "Format: ### Added, ### Changed, ### Fixed, ### Removed"
echo ""

# Read release notes from user
RELEASE_NOTES=$(cat)

# Build complete changelog entry
CHANGELOG_ENTRY="$RELEASE_NOTES_HEADER

$RELEASE_NOTES"
```

### 4.2 Insert into CHANGELOG.md

```bash
# Create temporary file with new entry + existing content
{
    echo "# CHANGELOG"
    echo ""
    echo "$CHANGELOG_ENTRY"
    echo ""
    # Skip header and insert new content
    tail -n +2 CHANGELOG.md
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
    # Extract release notes from CHANGELOG section
    RELEASE_BODY=$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | head -n -1)

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would create GitHub release v$VERSION"
    else
        gh release create "v$VERSION" --notes "$RELEASE_BODY"
        echo "✓ Created GitHub release v$VERSION"
    fi
fi
```

---

## Success Criteria

- [ ] Pre-flight checks passed (jq, git, remote, clean working tree)
- [ ] Version synced across all 3 files (plugin.json, marketplace.json, pilot-version)
- [ ] CHANGELOG.md updated with release notes
- [ ] Git commit created: "chore: bump version to X.Y.Z"
- [ ] Git tag created and pushed: v{version}
- [ ] GitHub release created (if gh CLI available and not --skip-gh)

---

## Usage Examples

| Command | Description |
|---------|-------------|
| `/999_release` | Patch version (x.y.Z) with GitHub release |
| `/999_release patch` | Patch version (x.y.Z) |
| `/999_release minor` | Minor version (x.Y.0) |
| `/999_release major` | Major version (X.0.0) |
| `/999_release 4.2.0` | Specific version (4.2.0) |
| `/999_release patch --skip-gh` | Skip GitHub release creation |
| `/999_release patch --dry-run` | Preview changes without executing |
| `/999_release patch --pre alpha.1` | Pre-release version (x.y.Z-alpha.1) |

---

## Error Handling

| Error | Action |
|-------|--------|
| jq not installed | Exit with install instructions |
| Git remote not found | Exit with available remotes |
| Working tree dirty | Exit with git status |
| Tag already exists | Exit with delete instructions |
| Invalid version format | Exit with format examples |
| GitHub release fails | Continue - tag already pushed |

---

## Distribution Notes

**Plugin Distribution Workflow**:
- Maintainer: `/999_release` → git tag → GitHub release
- User: `/plugin marketplace update` → `/plugin update claude-pilot@changoo89`

**No automatic deployment** - plugins track commit SHAs, not git tags or releases

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
