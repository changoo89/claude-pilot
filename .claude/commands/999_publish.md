---
description: Bump version, build package, and publish to PyPI with git commit
argument-hint: "[patch|minor|major] --skip-git - version bump type (default: patch), --skip-git to skip git push"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_publish

_Automated PyPI publishing workflow with version bumping and git integration._

## Core Philosophy

- **Atomic**: All steps succeed or none do
- **Safe**: Version synchronization checks before building
- **Interactive**: Confirmation for destructive operations
- **Traceable**: Clear git commit messages

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

## Step 3: Check Version Synchronization

Verify all version files match: `pyproject.toml`, `src/claude_pilot/__init__.py`, `src/claude_pilot/config.py`, `install.sh`. Exit if mismatch found.

---

## Step 4: Update All Version Files

Use `sed` to update version in all files to `$NEW_VERSION`.

---

## Step 5: Verify Post-Update Synchronization

Re-check all files to confirm they match `$NEW_VERSION`. Exit if any mismatch.

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

- [ ] Version bumped to new version
- [ ] All version files synchronized
- [ ] Package built successfully
- [ ] **Package contents verified (agents/, skills/, AGENT.md.template included)**
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
| Build fails | Clean dist/, report error, exit |
| Upload fails | Keep dist/ for manual upload, exit |
| Version mismatch | Report mismatched files, exit |
| Git push fails | Warn: version on PyPI but not in git |

---

## References
- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`
