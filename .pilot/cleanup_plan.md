# Git Files Cleanup Plan

> **Generated**: 2026-01-20 09:58:16
> **Purpose**: Actionable cleanup plan for removing 244 unnecessary files from git tracking
> **Source**: Based on `.pilot/removable_files.txt` audit results

---

## Executive Summary

**Total Files to Remove**: 244 (27.1% reduction from 547 to 303 tracked files)

**Breakdown**:
- Runtime State (`.pilot/`): 233 files
- Duplicate Prefix (`.claude-pilot/`): 7 files
- Backup/Temp Files (outside .pilot/): 4 files

**Expected Outcome**: Cleaner repository with only production plugin files tracked

---

## Pre-Flight Safety Checks

**Before executing any cleanup commands, verify:**

```bash
# 1. Ensure you're on main branch
git branch --show-current  # Should output: main

# 2. Ensure working directory is clean
git status  # Should show: "nothing to commit, working tree clean"

# 3. Verify current file count
git ls-files | wc -l  # Should show: 547

# 4. Create safety backup branch (optional but recommended)
git branch backup-before-cleanup-$(date +%Y%m%d)
echo "Created backup branch: backup-before-cleanup-$(date +%Y%m%d)"
```

**If any check fails, STOP and investigate before proceeding.**

---

## Step 1: Update .gitignore (Prevent Future Tracking)

**Purpose**: Add patterns to prevent tracking runtime state and duplicate prefix files

**Commands**:
```bash
# Add .pilot/ pattern (runtime state and plans)
echo "" >> .gitignore
echo "# Runtime state and plans (generated during execution)" >> .gitignore
echo ".pilot/" >> .gitignore

# Add .claude-pilot/ pattern (legacy duplicate prefix)
echo "" >> .gitignore
echo "# Legacy duplicate prefix (historical artifact)" >> .gitignore
echo ".claude-pilot/" >> .gitignore

# Verify .gitignore changes
git diff .gitignore
```

**Expected Output**: Should show the two new sections added to .gitignore

**Commit .gitignore update** (do this before removing files):
```bash
git add .gitignore
git commit -m "chore: add .pilot/ and .claude-pilot/ to .gitignore

Prevent tracking of runtime state and legacy duplicate prefix.

- Add .pilot/ to .gitignore (233 runtime files)
- Add .claude-pilot/ to .gitignore (7 legacy files)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Step 2: Remove Runtime State Directory (233 files)

**Purpose**: Remove all `.pilot/` directory files from git tracking

**Files Affected**:
- `.pilot/plan/done/` (137 historical plan files)
- `.pilot/plan/draft/` (1 in-progress plan)
- `.pilot/tests/` (66 test files)
- `.pilot/state/` (5 continuation state files)
- `.pilot/scripts/` (3 utility scripts)
- `.pilot/docs/` (4 documentation files)
- `.pilot/audit/` (2 audit reports)
- Other runtime artifacts (11 files)

**Command**:
```bash
# Remove entire .pilot/ directory from git tracking
git rm -r .pilot/

# Verify removal count
git status | grep "deleted:" | wc -l  # Should show: 233
```

**Safety Verification**:
```bash
# Verify core plugin files are NOT affected
ls -la .claude/commands/ | head -5  # Should show command files present
ls -la .claude/agents/ | head -5    # Should show agent files present
```

---

## Step 3: Remove Duplicate Prefix Directory (7 files)

**Purpose**: Remove legacy `.claude-pilot/` directory (old naming convention)

**Files Affected**:
- `.claude-pilot/.pilot/plan/done/` (1 historical plan)
- `.claude-pilot/.pilot/plan/draft/` (1 .gitkeep)
- `.claude-pilot/.pilot/plan/in_progress/` (1 .gitkeep)
- `.claude-pilot/.pilot/plan/pending/` (1 .gitkeep)
- `.claude-pilot/.pilot/tests/` (2 test files)

**Command**:
```bash
# Remove entire .claude-pilot/ directory from git tracking
git rm -r .claude-pilot/

# Verify removal count
git status | grep "deleted:" | wc -l  # Should show: 240 (233 + 7)
```

---

## Step 4: Remove Backup and Temporary Files (4 files)

**Purpose**: Remove backup and temporary files outside .pilot/ directory

**Files Affected**:
- `.claude/commands/02_execute.md.bak` (backup file)
- `.claude/scripts/codex-sync.sh.backup` (backup file)
- `.tmp` (temporary file)
- `CLAUDE.md.backup` (backup file)

**Commands**:
```bash
# Remove backup files individually
git rm .claude/commands/02_execute.md.bak
git rm .claude/scripts/codex-sync.sh.backup
git rm .tmp
git rm CLAUDE.md.backup

# Verify final removal count
git status | grep "deleted:" | wc -l  # Should show: 244 (233 + 7 + 4)
```

**Note**: The 2 backup files inside `.pilot/` (`.pilot/state/continuation.json.backup` and `.pilot/state/continuation.json.final.backup`) were already removed in Step 2 as part of the `.pilot/` directory.

---

## Step 5: Verify Cleanup Results

**Purpose**: Confirm all removals completed successfully and core files intact

**Verification Commands**:
```bash
# 1. Check total deletions
git status | grep "deleted:" | wc -l  # Should show: 244

# 2. Verify new file count
git ls-files | wc -l  # Should show: 303 (547 - 244)

# 3. Verify core plugin structure intact
ls -la .claude/commands/  # Should show 11+ command files
ls -la .claude/agents/    # Should show 8+ agent files
ls -la .claude/skills/    # Should show skill directories

# 4. Verify .pilot/ files no longer tracked
git ls-files | grep "\.pilot/" | wc -l  # Should show: 0

# 5. Verify .claude-pilot/ files no longer tracked
git ls-files | grep "\.claude-pilot/" | wc -l  # Should show: 0

# 6. Verify backup files no longer tracked
git ls-files | grep -E "(\.backup|\.bak|\.tmp)" | wc -l  # Should show: 0
```

**Expected Results**:
- Total deletions: 244
- New file count: 303
- Core plugin files: intact
- No .pilot/ or .claude-pilot/ files tracked
- No backup/temp files tracked

---

## Step 6: Commit Cleanup Changes

**Purpose**: Commit all removals with descriptive message

**Commit Message Template**:
```bash
git commit -m "chore: remove runtime state and backup files from git tracking

Cleanup repository by removing 244 unnecessary files (27.1% reduction):

Removed:
- .pilot/ directory (233 files): runtime state, plans, tests
- .claude-pilot/ directory (7 files): legacy duplicate prefix
- Backup/temp files (4 files): .backup, .bak, .tmp files

Updated:
- .gitignore: added .pilot/ and .claude-pilot/ patterns

Impact:
- Faster clones and smaller repository size
- Cleaner plugin distribution for marketplace
- Only production plugin files now tracked

Verification:
- Core .claude/ directory unchanged
- All plugin functionality preserved
- Backup branch created: backup-before-cleanup-YYYYMMDD

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Alternative Short Commit**:
```bash
git commit -m "chore: remove 244 runtime state and backup files (27.1% reduction)

- Remove .pilot/ (233 files), .claude-pilot/ (7 files), backup/temp (4 files)
- Update .gitignore to prevent future tracking
- Backup branch: backup-before-cleanup-\$(date +%Y%m%d)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Post-Cleanup Verification

**After committing, verify repository is functional:**

```bash
# 1. Verify commit created
git log -1 --oneline  # Should show cleanup commit

# 2. Verify working directory clean
git status  # Should show: "nothing to commit, working tree clean"

# 3. Verify .pilot/ ignored (local files should exist but not tracked)
ls -la .pilot/  # Should show local files exist
git ls-files | grep "\.pilot/" | wc -l  # Should show: 0 (not tracked)

# 4. Test plugin still works (if you have Claude Code active)
# Run: /00_plan test (or another command) to verify functionality
```

---

## Rollback Procedure

**If you need to undo the cleanup:**

### Option 1: Reset to Backup Branch

```bash
# Switch to backup branch
git checkout backup-before-cleanup-YYYYMMDD

# If you want to restore main from backup
git checkout main
git reset --hard backup-before-cleanup-YYYYMMDD
git push origin main --force  # Use --force with caution!
```

### Option 2: Revert Cleanup Commit

```bash
# Revert the cleanup commit
git revert HEAD --no-edit

# This creates a new commit that restores all deleted files
# Push to apply revert
git push origin main
```

### Option 3: Manual File Restoration

```bash
# Find the cleanup commit hash
git log --oneline | grep "remove runtime state"

# Restore specific files from before cleanup
git checkout COMMIT_HASH_BEFORE_CLEANUP -- .pilot/file/to/restore
```

---

## Risk Assessment and Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking plugin functionality | LOW | HIGH | Core .claude/ files unchanged; tested after cleanup |
| Losing historical plans | LOW | MEDIUM | Plans are runtime artifacts; backup branch available |
| Accidental deletion of necessary files | LOW | HIGH | Verification checklist before commit |
| Need to restore files later | LOW | LOW | All changes reversible with git; backup branch created |

---

## Summary Checklist

**Before Cleanup**:
- [ ] Verified on main branch
- [ ] Working directory clean
- [ ] Current file count: 547
- [ ] Created backup branch
- [ ] Reviewed all 244 files in `.pilot/removable_files.txt`

**During Cleanup**:
- [ ] Updated .gitignore
- [ ] Committed .gitignore changes
- [ ] Removed .pilot/ directory (233 files)
- [ ] Removed .claude-pilot/ directory (7 files)
- [ ] Removed backup/temp files (4 files)
- [ ] Verified 244 total deletions

**After Cleanup**:
- [ ] New file count: 303
- [ ] Core plugin files intact
- [ ] .pilot/ no longer tracked
- [ ] .claude-pilot/ no longer tracked
- [ ] Backup files no longer tracked
- [ ] Committed with descriptive message
- [ ] Verified repository functional

---

## Next Steps

**After cleanup is complete and verified:**

1. **Push changes to remote** (if working in feature branch):
   ```bash
   git push origin main
   ```

2. **Create pull request** (if working in separate branch):
   ```bash
   gh pr create --title "chore: remove 244 runtime state and backup files" \
                --body "Cleanup repository by removing unnecessary files (27.1% reduction)"
   ```

3. **Monitor CI/CD** (if configured):
   - Ensure GitHub Actions workflows pass
   - Verify plugin build process succeeds

4. **Communicate to team** (if applicable):
   - Notify developers of .gitignore changes
   - Explain that .pilot/ files are now local-only

---

**End of Cleanup Plan**

For questions or issues, refer to:
- `.pilot/removable_files.txt` - Detailed file list with justifications
- `.pilot/audit_report.md` - Full audit analysis
- `.gitignore` - Updated ignore patterns
