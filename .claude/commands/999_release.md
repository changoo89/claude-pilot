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

## Step 1: Bump Version

```bash
CURRENT_VERSION="$(grep '"version"' package.json | jq -r '.')"
RELEASE_TYPE="${1:-patch}"

# Bump version
npm version "$RELEASE_TYPE" --no-git-tag-version
NEW_VERSION="$(grep '"version"' package.json | jq -r '.')"

echo "✓ Version: $CURRENT_VERSION → $NEW_VERSION"
```

---

## Step 2: Generate CHANGELOG

```bash
# Get previous tag
PREV_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "")"

# Generate changelog from commits
git log "${PREV_TAG}..HEAD" --pretty=format:"- %s" > CHANGELOG.new

# Categorize by commit type
grep -E "^feat:" CHANGELOG.new >> FEATURES.md || true
grep -E "^fix:" CHANGELOG.new >> FIXES.md || true
```

---

## Step 3: Create Git Tag

```bash
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
echo "✓ Tag created: v$NEW_VERSION"
```

---

## Step 4: GitHub Release (Optional)

```bash
if [ "$2" != "--skip-gh" ] && command -v gh &> /dev/null; then
    gh release create "v$NEW_VERSION" --notes-file CHANGELOG.md
    echo "✓ GitHub release created"
fi
```

---

## Step 5: Commit & Push

```bash
git add package.json CHANGELOG.md
git commit -m "chore(release): Bump version to $NEW_VERSION

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin main --tags
```

---

## Related Skills

**git-master**: Commit & tag operations | **git-operations**: Push with retry

---

**See**: @.claude/skills/release/SKILL.md for full methodology
