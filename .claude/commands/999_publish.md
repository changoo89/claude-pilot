---
description: Bump version, build package, and publish to PyPI with git commit
argument-hint: "[patch|minor|major] --skip-git - version bump type (default: patch), --skip-git to skip git push"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_publish

_Automated PyPI publishing workflow with version bumping and git integration._

## Core Philosophy

- **Atomic**: All steps succeed or none do
- **Safe**: Version synchronization checks BEFORE AND AFTER updates (Steps 3 & 5)
- **Interactive**: Confirmation for destructive operations, auto-fix option for mismatches
- **Traceable**: Clear git commit messages
- **Critical Exit Points**: Abort on version mismatch, failed verification, or missing package contents

---

## Step 0: Pre-flight Checks

Check tools (python3, twine, git), git status, and branch. Warn if uncommitted changes or not on main/master.

---

## Step 1: Determine Version Bump Type

Parse `$ARGUMENTS`: `major` → X.0.0, `minor` → x.Y.0, `patch` → x.y.Z (default)
If not specified, use AskUserQuestion to select bump type.

---

## Step 2: Read and Calculate New Version

Read current from `pyproject.toml`, parse components, calculate new version based on bump type.

---

## Step 3: Check Version Synchronization (CRITICAL)

> **🚨 CRITICAL - PRE-PUBLISH CHECK**
> This step MUST pass before proceeding. Version mismatch causes inconsistent deployments.
> If mismatch found, offer auto-fix before continuing.

### 3.1 Extract Versions from All Files

```bash
# Get current version from pyproject.toml (source of truth)
CURRENT_VERSION="$(grep '^version' pyproject.toml | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"

echo "=== Version Synchronization Check ==="
echo "Source of truth: pyproject.toml = $CURRENT_VERSION"
echo ""

# Extract versions from each file
PYPROJECT_VERSION="$CURRENT_VERSION"
INIT_VERSION="$(grep '__version__' src/claude_pilot/__init__.py | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"
CONFIG_VERSION="$(grep 'VERSION' src/claude_pilot/config.py | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"
INSTALL_VERSION="$(grep 'VERSION=' install.sh | head -1 | sed 's/.*=//' | tr -d '"'"'"' ')"

# Display all versions
echo "File versions:"
echo "  pyproject.toml:           $PYPROJECT_VERSION"
echo "  __init__.py:              $INIT_VERSION"
echo "  config.py:                $CONFIG_VERSION"
echo "  install.sh:               $INSTALL_VERSION"
echo ""
```

### 3.2 Check for Mismatches

```bash
MISMATCH_FOUND=false
MISMATCHED_FILES=""

if [ "$INIT_VERSION" != "$CURRENT_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES src/claude_pilot/__init__.py"
fi
if [ "$CONFIG_VERSION" != "$CURRENT_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES src/claude_pilot/config.py"
fi
if [ "$INSTALL_VERSION" != "$CURRENT_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES install.sh"
fi
```

### 3.3 Handle Mismatch

```bash
if [ "$MISMATCH_FOUND" = true ]; then
    echo "❌ VERSION MISMATCH DETECTED!"
    echo ""
    echo "Mismatched files:$MISMATCHED_FILES"
    echo ""
    echo "All version files must match pyproject.toml ($CURRENT_VERSION)"
    echo ""

    # Ask user how to proceed
    AskUserQuestion:
        - question: "Version mismatch detected. How would you like to fix?"
        - options:
            - "Auto-fix now (recommended)": Update all mismatched files to $CURRENT_VERSION
            - "Abort": Fix manually and re-run /999_publish

    if user selects "Auto-fix now":
        # Fix all files to match CURRENT_VERSION
        # Then proceed to Step 4
    else:
        echo "Aborting. Please fix version mismatch manually."
        exit 1
    fi
else
    echo "✅ All version files synchronized: $CURRENT_VERSION"
fi
```

### Expected Behavior

| Scenario | Action |
|----------|--------|
| All files match pyproject.toml | Continue to Step 4 |
| Any file mismatched | Offer auto-fix OR abort |
| User accepts auto-fix | Update files, then continue |
| User declines | Exit with error |

---

## Step 4: Update All Version Files

Use `sed` to update version in all files to `$NEW_VERSION`.

### 4.1 Apply Version Updates

```bash
echo "=== Updating All Version Files ==="
echo ""
echo "Target version: $CURRENT_VERSION → $NEW_VERSION"
echo ""

# Update pyproject.toml
echo "1. Updating pyproject.toml..."
sed -i '' "s/^version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
echo "   ✅ pyproject.toml: $CURRENT_VERSION → $NEW_VERSION"

# Update src/claude_pilot/__init__.py
echo "2. Updating src/claude_pilot/__init__.py..."
sed -i '' "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" src/claude_pilot/__init__.py
echo "   ✅ __init__.py: $CURRENT_VERSION → $NEW_VERSION"

# Update src/claude_pilot/config.py
echo "3. Updating src/claude_pilot/config.py..."
sed -i '' "s/VERSION = \"$CURRENT_VERSION\"/VERSION = \"$NEW_VERSION\"/" src/claude_pilot/config.py
echo "   ✅ config.py: $CURRENT_VERSION → $NEW_VERSION"

# Update install.sh
echo "4. Updating install.sh..."
sed -i '' "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$NEW_VERSION\"/" install.sh
echo "   ✅ install.sh: $CURRENT_VERSION → $NEW_VERSION"
echo ""

echo "=== All Version Files Updated ✅ ==="
```

### 4.2 Update Summary

| File | Pattern | Updated |
|------|---------|---------|
| `pyproject.toml` | `version = "X.Y.Z"` | ✅ |
| `src/claude_pilot/__init__.py` | `__version__ = "X.Y.Z"` | ✅ |
| `src/claude_pilot/config.py` | `VERSION = "X.Y.Z"` | ✅ |
| `install.sh` | `VERSION="X.Y.Z"` | ✅ |

---

## Step 5: Verify Post-Update Synchronization (CRITICAL)

> **🚨 CRITICAL - POST-UPDATE VERIFICATION**
> This step MUST pass before building. Any mismatch here causes broken releases.
> Exit immediately if any file doesn't match $NEW_VERSION.

### 5.1 Re-extract and Verify

```bash
echo "=== Verifying Post-Update Synchronization ==="
echo ""
echo "Expected version: $NEW_VERSION"
echo ""

# Re-extract versions from all files
PYPROJECT_VERSION="$(grep '^version' pyproject.toml | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"
INIT_VERSION="$(grep '__version__' src/claude_pilot/__init__.py | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"
CONFIG_VERSION="$(grep 'VERSION' src/claude_pilot/config.py | head -1 | sed 's/.*= *//' | tr -d '"'"'"' ')"
INSTALL_VERSION="$(grep 'VERSION=' install.sh | head -1 | sed 's/.*=//' | tr -d '"'"'"' ')"

echo "File versions after update:"
echo "  pyproject.toml:           $PYPROJECT_VERSION"
echo "  __init__.py:              $INIT_VERSION"
echo "  config.py:                $CONFIG_VERSION"
echo "  install.sh:               $INSTALL_VERSION"
echo ""
```

### 5.2 Verify All Match $NEW_VERSION

```bash
MISMATCH_FOUND=false
MISMATCHED_FILES=""

if [ "$PYPROJECT_VERSION" != "$NEW_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES pyproject.toml"
fi
if [ "$INIT_VERSION" != "$NEW_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES src/claude_pilot/__init__.py"
fi
if [ "$CONFIG_VERSION" != "$NEW_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES src/claude_pilot/config.py"
fi
if [ "$INSTALL_VERSION" != "$NEW_VERSION" ]; then
    MISMATCH_FOUND=true
    MISMATCHED_FILES="$MISMATCHED_FILES install.sh"
fi
```

### 5.3 Handle Verification Failure

```bash
if [ "$MISMATCH_FOUND" = true ]; then
    echo "❌ POST-UPDATE VERIFICATION FAILED!"
    echo ""
    echo "The following files did not update correctly:$MISMATCHED_FILES"
    echo ""
    echo "Expected: $NEW_VERSION"
    echo ""
    echo "This is a critical error. Do not proceed with build."
    echo "Please investigate why sed replacements failed."
    exit 1
else
    echo "✅ All version files verified: $NEW_VERSION"
fi
```

### Expected Behavior

| Scenario | Action |
|----------|--------|
| All files match $NEW_VERSION | Continue to Step 6 (Clean Artifacts) |
| Any file mismatched | **EXIT IMMEDIATELY** - DO NOT BUILD |

---

## Step 6: Clean Build Artifacts

Remove `dist/`, `build/`, `*.egg-info/`.

---

## Step 7: Build Package

Run `python3 -m build`, show output on success, exit on failure.

---

## Step 7-1: Verify Package Contents (NEW)

Extract and verify that agents/ and skills/ directories are included in the built package:

```bash
# List contents of the built wheel/tarball
python3 -m zipfile -l dist/claude_pilot-*.whl | grep -E "(agents|skills)"

# Or extract and verify
tar -tzf dist/claude-pilot-*.tar.gz | grep -E "\.claude/(agents|skills)/"
```

Expected output should show:
- `.claude/agents/*.md` files (coder, documenter, explorer, reviewer)
- `.claude/skills/*/SKILL.md` files (git-master, ralph-loop, tdd, vibe-coding)
- `.claude/templates/AGENT.md.template`

**Exit if agents/ or skills/ not found** in the package.

---

## Step 8: Upload to PyPI

Display package info and files, use AskUserQuestion to confirm upload, run `twine upload dist/*`.

---

## Step 9: Git Commit and Push

Skip if `--skip-git` flag present. Otherwise commit version files with message, push to origin.

---

## Step 10: Verify Installation

Wait 3s for CDN propagation, run `pip3 install --dry-run` to verify version available on PyPI.

---

## Success Criteria

- [ ] Pre-publish version check passed (Step 3)
- [ ] Version bumped to new version
- [ ] All version files synchronized (verified in Step 5)
- [ ] Post-update verification passed (Step 5)
- [ ] Package built successfully
- [ ] **Package contents verified (agents/, skills/, AGENT.md.template included)** (Step 7-1)
- [ ] Uploaded to PyPI
- [ ] Git committed and pushed (unless --skip-git)
- [ ] New version verified on PyPI

---

## Usage Examples

| Command | Description |
|---------|-------------|
| `/999_publish` | Patch version (x.y.Z) |
| `/999_publish patch` | Patch version (x.y.Z) |
| `/999_publish minor` | Minor version (x.Y.0) |
| `/999_publish major` | Major version (X.0.0) |
| `/999_publish patch --skip-git` | Skip git operations |

---

## Error Handling

| Error | Action |
|-------|--------|
| **Pre-publish version mismatch** | Offer auto-fix OR abort (Step 3) |
| **Post-update verification failure** | **EXIT IMMEDIATELY** - DO NOT BUILD (Step 5) |
| Build fails | Clean dist/, report error, exit |
| Upload fails | Keep dist/ for manual upload, exit |
| Package contents missing agents/skills | **EXIT IMMEDIATELY** - DO NOT UPLOAD (Step 7-1) |
| Git push fails | Warn: version on PyPI but not in git |

### Critical Exit Points

| Step | Exit Condition | Reason |
|------|----------------|---------|
| **Step 3** | Version mismatch AND user declines auto-fix | Prevents inconsistent release |
| **Step 5** | Post-update verification fails | Prevents broken package |
| **Step 7-1** | agents/ or skills/ missing from package | Prevents incomplete release |

---

## References
- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`
