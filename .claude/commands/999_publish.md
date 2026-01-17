---
description: Bump version, build package, and publish to PyPI with git commit
argument-hint: "[patch|minor|major] --skip-git - version bump type (default: patch), --skip-git to skip git push
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

## Step 0.5: Asset Generation (AUTOMATIC)

> **✅ AUTOMATIC**: Build hook generates assets during wheel build.
> **Script**: `src/claude_pilot/build_hook.py` (Hatchling custom hook)
> **Purpose**: Ensures PyPI package includes latest `.claude/` content

### Quick Reference

| Component | Action | Source → Dest |
|-----------|--------|--------------|
| Build Hook | Generate assets | `.claude/**` → `src/claude_pilot/assets/.claude/**` (filtered) |
| Asset Manifest | Curate content | Include/exclude patterns (see `assets.py`) |

### How It Works

The build hook automatically runs during `python3 -m build`:
1. Reads `.claude/**` source files
2. Filters using `AssetManifest` (excludes external skills, 999_publish, etc.)
3. Generates `src/claude_pilot/assets/.claude/**`
4. Packages assets in wheel

**No manual sync needed!**

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

**Verification**: Use `/scripts/verify-version-sync.sh` to check all version files match `pyproject.toml`

**Files to check**:
- `pyproject.toml` (source of truth)
- `src/claude_pilot/__init__.py`
- `src/claude_pilot/config.py`
- `install.sh`
- `.claude/.pilot-version`

**On mismatch**: Use `AskUserQuestion` with options: "Auto-fix now (recommended)" or "Abort"

---

## Step 4: Update All Version Files

**Update to `$NEW_VERSION`**:

```bash
# Update version files
sed -i '' "s/^version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
sed -i '' "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" src/claude_pilot/__init__.py
sed -i '' "s/VERSION = \"$CURRENT_VERSION\"/VERSION = \"$NEW_VERSION\"/" src/claude_pilot/config.py
sed -i '' "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$NEW_VERSION\"/" install.sh
echo "$NEW_VERSION" > .claude/.pilot-version
```

---

## Step 5: Verify Post-Update Synchronization (CRITICAL)

> **🚨 CRITICAL - POST-UPDATE VERIFICATION**
> This step MUST pass before building. Any mismatch here causes broken releases.

**Verification**: Re-run `/scripts/verify-version-sync.sh` to confirm all files match `$NEW_VERSION`

**Exit immediately** if any file doesn't match

---

## Step 6: Clean Build Artifacts

Remove `dist/`, `build/`, `*.egg-info/`.

---

## Step 7: Build Package

Run `python3 -m build`, show output on success, exit on failure.

---

## Step 7-1: Verify Package Contents (CRITICAL)

> **🚨 CRITICAL**: Package must include agents/, skills/, and AGENT.md.template

**Verify**: `python3 -m zipfile -l dist/claude_pilot-*.whl | grep -E "\.claude/(agents|skills)/"`

**Expected**: `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/templates/AGENT.md.template`

**Exit if agents/ or skills/ not found** in the package.

---

## Step 8: Upload to PyPI

Display package info and files, use AskUserQuestion to confirm upload, run `twine upload dist/*`.

---

## Step 9: Git Commit and Push

Skip if `--skip-git` flag present. Otherwise commit version files with message, push to origin.

**Commit Format**: `chore: bump version to X.Y.Z`

---

## Step 10: Verify Installation

Wait 3s for CDN propagation, run `pip3 install --dry-run` to verify version available on PyPI.

---

## Success Criteria

- [ ] Pre-publish version check passed (Step 3)
- [ ] Templates synced successfully (Step 0.5)
- [ ] Version bumped to new version
- [ ] All 5 version files synchronized (verified in Step 5)
- [ ] Post-update verification passed (Step 5)
- [ ] Package built successfully
- [ ] **Package contents verified (agents/, skills/, AGENT.md.template included)** (Step 7-1)
- [ ] Uploaded to PyPI
- [ ] Git committed and pushed (or skipped when --skip-git specified)
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

## Related Guides
- @.claude/skills/git-master/SKILL.md - Git commit conventions
- @.claude/guides/prp-framework.md - Project planning patterns

---

## References
- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`
