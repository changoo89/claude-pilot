---
description: Bump version, create git tag, and create GitHub release for plugin distribution
argument-hint: "[patch|minor|major|x.y.z] --skip-gh --create-gh --dry-run --pre"
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

**CHANGELOG Workflow**: Detect previous tag → Collect commits → Parse conventional commits → Categorize → Generate entry → Prompt for review

**Methodology**: @.claude/skills/release/SKILL.md
**Details**: @.claude/skills/release/REFERENCE.md

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Security review | Keywords: "security", "auth", "credential" | Delegate to GPT Security Analyst |
| User explicitly requests | "ask GPT", "consult GPT", "security review" | Delegate to GPT Security Analyst |

**Graceful fallback**:
```bash
command -v codex &> /dev/null || { echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"; return 0; }
```

---

## Step 1: Pre-flight Checks

> **Full validation**: @.claude/skills/release/REFERENCE.md

### 1.1 Check Required Tools
```bash
command -v jq &> /dev/null || { echo "Error: jq required. Install: brew install jq (macOS) or apt install jq (Linux)"; exit 1; }
command -v git &> /dev/null || { echo "Error: git required"; exit 1; }
```

### 1.2 Detect Git Configuration
```bash
REMOTE=$(git remote 2>/dev/null | head -1); REMOTE=${REMOTE:-origin}
BRANCH=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed "s@^refs/remotes/$REMOTE/@@" || git rev-parse --abbrev-ref HEAD)
git remote | grep -q "^${REMOTE}$" || { echo "Error: Remote '$REMOTE' not found. Available: $(git remote)"; exit 1; }
```

### 1.3 Check Working Tree State
```bash
[ -n "$(git status --porcelain)" ] && { echo "Error: Working tree has uncommitted changes"; git status --short; exit 1; }
```

### 1.4 Validate Plugin Manifests
```bash
# Check for invalid agents field
jq -e '.agents' .claude-plugin/plugin.json > /dev/null 2>&1
if [ $? -eq 0 ] && [ "$(jq '.agents | type' .claude-plugin/plugin.json)" == '"array"' ]; then
    YAML_COUNT=$(find .claude/agents -name '*.yaml' -o -name '*.yml' 2>/dev/null | wc -l | tr -d ' ')
    AGENT_COUNT=$(jq '.agents | length' .claude-plugin/plugin.json)
    [ "$AGENT_COUNT" -gt 0 ] && [ "$YAML_COUNT" -eq 0 ] && { echo "Error: agents field exists but no YAML agent files found"; exit 1; }
fi

# Check marketplace.json metadata
jq -e '.metadata' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'metadata' section"; exit 1; }
jq -e '.metadata.description' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'description'"; exit 1; }
jq -e '.metadata.pluginRoot' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'pluginRoot'"; exit 1; }
jq -e '.plugins[0].homepage' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'homepage'"; exit 1; }
jq -e '.plugins[0].repository' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'repository'"; exit 1; }
jq -e '.plugins[0].license' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'license'"; exit 1; }
jq -e '.plugins[0].keywords' .claude-plugin/marketplace.json > /dev/null 2>&1 || { echo "Error: marketplace.json missing 'keywords'"; exit 1; }

# Verify source is local path, not URL
SOURCE=$(jq -r '.plugins[0].source' .claude-plugin/marketplace.json)
echo "$SOURCE" | grep -qE '^https?://' && { echo "Error: marketplace.json source must be local path (./), not URL. Current: $SOURCE"; exit 1; }
```

---

## Step 2: Parse Version Arguments

> **Full version calculation**: @.claude/skills/release/REFERENCE.md

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

VERSION_BUMP="${VERSION_BUMP:-patch}"
CURRENT=$(jq -r '.version' .claude-plugin/plugin.json)

# Calculate new version
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3)

case "$VERSION_BUMP" in
    major) VERSION="$((MAJOR + 1)).0.0" ;;
    minor) VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    patch) VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    *)
        echo "$VERSION_BUMP" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$' || { echo "Error: Invalid version format: $VERSION_BUMP"; exit 1; }
        VERSION="$VERSION_BUMP"
        ;;
esac

[ -n "$PRERELEASE" ] && VERSION="${VERSION}-${PRERELEASE}"
git tag -l | grep -q "^v${VERSION}$" && { echo "Error: Git tag v$VERSION already exists. Delete first: git tag -d v$VERSION && git push $REMOTE :refs/tags/v$VERSION"; exit 1; }
echo "Current: $CURRENT → New: $VERSION"
```

---

## Step 3: Update Version Files

> **All 2 version sources**: @.claude/skills/release/REFERENCE.md

```bash
# 3.1 Update plugin.json (PRIMARY)
jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json

# 3.2 Update marketplace.json (DUPLICATE)
jq --arg v "$VERSION" '(.plugins[] | select(.name == "claude-pilot").version) = $v' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

echo "✓ Updated all 2 version files"
```

---

## Step 4: Auto-Generate CHANGELOG.md

> **Full CHANGELOG generation**: @.claude/skills/release/REFERENCE.md

```bash
# Detect previous tag, collect commits, categorize
PREV_TAG=$(git tag -l "v*" --sort=-v:refname | grep -v "^v${VERSION}$" | head -1)
[ -z "$PREV_TAG" ] && GIT_RANGE="" || GIT_RANGE="${PREV_TAG}..HEAD"
COMMITS=$(git log $GIT_RANGE --pretty=format:"%h|||%s" --date=short 2>/dev/null)
RELEASE_DATE=$(date +%Y-%m-%d)

# Parse and categorize (full implementation in details file)
# Auto-generates: Added, Changed, Fixed, Removed, Performance, Documentation sections
# Formats and inserts into CHANGELOG.md
```

> **Implementation**: Full commit parsing, categorization, and formatting in details file.

---

## Step 5: Git Operations

```bash
# Stage and commit
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json CHANGELOG.md
git add .claude/commands/999_release.md CLAUDE.md MIGRATION.md 2>/dev/null || true
git commit -m "chore: bump version to $VERSION"
git tag -a "v$VERSION" -m "Release $VERSION"

# Push (unless dry-run)
[ "$DRY_RUN" = true ] && echo "[DRY-RUN] Would push to $REMOTE $BRANCH --tags" || { git push "$REMOTE" "$BRANCH" --tags; echo "✓ Pushed to $REMOTE $BRANCH"; echo "✓ Pushed tag v$VERSION"; }
```

---

## Step 6: GitHub Release (OPTIONAL)

> **CI/CD Integration**: @.claude/skills/release/REFERENCE.md

```bash
if [ "$SKIP_GH" = true ]; then
    echo "Skipping local GitHub release (CI will handle it)"
    echo "Use --create-gh to force local release"
elif ! command -v gh &> /dev/null; then
    echo "GitHub CLI not installed - skipping release creation"
    echo "Tag pushed to GitHub - CI will create release automatically"
    echo "Install: brew install gh (macOS) or https://cli.github.com/"
else
    [ "$DRY_RUN" = true ] && echo "[DRY-RUN] Would create GitHub release v$VERSION" || {
        RELEASE_BODY=$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | sed '$d')
        gh release create "v$VERSION" --notes "$RELEASE_BODY"
        echo "✓ Created GitHub release v$VERSION"
    }
fi
```

---

## Step 7: Post-Release User Notification

```bash
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Release v$VERSION Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Plugin users can update with:"
echo ""
echo "  /plugin marketplace update"
echo "  /plugin update claude-pilot@changoo89"
echo ""
echo "Or if updates don't apply:"
echo ""
echo "  /plugin uninstall claude-pilot@changoo89"
echo "  rm -rf ~/.claude/plugins/cache/claude-pilot"
echo "  /plugin install claude-pilot@changoo89"
echo ""
echo "════════════════════════════════════════════════════════════"
```

---

## Success Criteria

- [ ] Pre-flight checks passed (jq, git, remote, clean working tree)
- [ ] Plugin manifests validated (no invalid agents, metadata present, source is local path)
- [ ] Version synced across all 2 files (plugin.json, marketplace.json)
- [ ] CHANGELOG.md auto-generated from git commits
- [ ] Git commit created: "chore: bump version to X.Y.Z"
- [ ] Git tag created and pushed: v{version}
- [ ] GitHub release created (if gh CLI available and not --skip-gh)
- [ ] Post-release instructions displayed to user

---

## Usage Examples

| Command | Description |
|---------|-------------|
| `/999_release` | Patch version (x.y.Z) - **skips local GitHub release (CI handles it)** |
| `/999_release patch` | Patch version (x.y.Z) |
| `/999_release minor` | Minor version (x.Y.0) |
| `/999_release major` | Major version (X.0.0) |
| `/999_release 4.2.0` | Specific version (4.2.0) |
| `/999_release patch --create-gh` | **Force local GitHub release** (bypass CI) |
| `/999_release patch --dry-run` | Preview changes without executing |
| `/999_release patch --pre alpha.1` | Pre-release version (x.y.Z-alpha.1) |

---

## Troubleshooting

> **Full troubleshooting guide**: @.claude/skills/release/REFERENCE.md

| Issue | Solution |
|-------|----------|
| Plugin update doesn't apply | `/plugin uninstall` → `rm -rf ~/.claude/plugins/cache/` → `/plugin install` |
| Commands show up twice | Remove local `.claude/commands/` folder |
| Stop hook permission denied | Run `/pilot:setup` to fix permissions automatically |

---

## Best Practices

> **Full guidelines**: @.claude/skills/release/REFERENCE.md

**For Plugin Maintainers**:
1. Always use `/999_release` for version consistency
2. Test before releasing (use `--dry-run` flag)
3. Document breaking changes in CHANGELOG
4. Keep plugin.json updated (single source of truth)

**For Plugin Users**:
1. Use GitHub marketplace source (not local paths)
2. Don't copy commands/skills locally
3. Clear cache if updates fail
4. Report issues with `/plugin list` output

---

## Related Guides

- **Git Workflow**: @.claude/skills/git-master/SKILL.md
- **Plugin Marketplace**: [Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- **Migration Guide**: MIGRATION.md
