# Safe File Operations - Usage Examples

> **Real-world usage examples and output samples**

---

## Example 1: Delete Single Git-tracked File

### User Input
```
Delete src/components/LegacyButton.tsx file
```

### Execution Process
```bash
# Step 1: Check git tracking status
$ git ls-files --error-unmatch src/components/LegacyButton.tsx
src/components/LegacyButton.tsx  # Git-tracked

# Step 2: Delete with git rm
$ git rm src/components/LegacyButton.tsx
rm 'src/components/LegacyButton.tsx'
```

### Output Result
```
✅ Git-tracked files (deleted with git rm):
  - src/components/LegacyButton.tsx

💡 To commit deleted files:
   git commit -m "Remove LegacyButton component"
```

---

## Example 2: Move Non-tracked Files to Trash

### User Input
```
Delete temp-debug.log file and cache/ folder
```

### Execution Process
```bash
# Step 1: Check git tracking status
$ git ls-files --error-unmatch temp-debug.log
# (No output - non-tracked file)

$ git ls-files --error-unmatch cache/
# (No output - non-tracked folder)

# Step 2: Move to .trash
$ mkdir -p .trash/2026-01-19
$ mv temp-debug.log .trash/2026-01-19/
$ mv cache .trash/2026-01-19/
```

### Output Result
```
✅ Non-tracked files (moved to .trash/):
  - temp-debug.log → .trash/2026-01-19/
  - cache/ → .trash/2026-01-19/

💡 To recover:
   mv .trash/2026-01-19/temp-debug.log .
   mv .trash/2026-01-19/cache .
```

---

## Example 3: Mixed Deletion (Git + Non-tracked)

### User Input
```
Delete docs/deprecated/ folder and build-output.log
```

### Execution Process
```bash
# Step 1: Check git tracking
$ git ls-files docs/deprecated/
docs/deprecated/README.md
docs/deprecated/guide.md
# Git-tracked folder

$ git ls-files --error-unmatch build-output.log
# (No output - non-tracked file)

# Step 2: Separate handling
$ git rm -r docs/deprecated/
rm 'docs/deprecated/README.md'
rm 'docs/deprecated/guide.md'

$ mkdir -p .trash/2026-01-19
$ mv build-output.log .trash/2026-01-19/
```

### Output Result
```
✅ Git-tracked files (deleted with git rm):
  - docs/deprecated/

✅ Non-tracked files (moved to .trash/):
  - build-output.log → .trash/2026-01-19/

📊 Summary:
  Git deletion: 2 files
  Trash move: 1 file
```

---

## Example 4: Wildcard Pattern Batch Processing

### User Input
```
Delete all *.log files and tests/tmp/ folder
```

### Execution Process
```bash
# Step 1: Collect target files
$ find . -name "*.log" -type f
./debug.log
./app.log
./error.log

$ ls -la tests/tmp/
tests/tmp/cache.bin
tests/tmp/session.json

# Step 2: Check each file and separate
for file in debug.log app.log error.log; do
    git ls-files --error-unmatch "$file" || mv "$file" .trash/
done

for folder in tests/tmp; do
    git ls-files --error-unmatch "$folder"/* || mv "$folder" .trash/
done
```

### Output Result
```
✅ Git-tracked files (deleted with git rm):
  - app.log

✅ Non-tracked files (moved to .trash/):
  - debug.log
  - error.log
  - tests/tmp/

📁 All preserved files: .trash/2026-01-19/
```

---

## Example 5: Interactive Recovery

### User Input
```
I want to recover config.old from the deleted files
```

### Execution Process
```bash
# Step 1: Search in .trash
$ find .trash/ -name "config.old"
.trash/2026-01-18/config.old

# Step 2: Recovery confirmation
$ mv .trash/2026-01-18/config.old .
```

### Output Result
```
🔄 Recovery complete:
  .trash/2026-01-18/config.old → ./config.old

💡 For git-tracked files, use checkout:
  git checkout HEAD -- config.old
```

---

## Example 6: Clean Up .trash

### User Input
```
Clean up the .trash folder
```

### Execution Process
```bash
# Step 1: Check .trash contents
$ du -sh .trash/*
50M    .trash/2026-01-15
120M   .trash/2026-01-16
80M    .trash/2026-01-17

# Step 2: Delete files older than 30 days
$ find .trash/ -type f -mtime +30 -delete

# Step 3: Clean empty directories
$ find .trash/ -type d -empty -delete
```

### Output Result
```
🧹 .trash cleanup complete:
  - Deleted files older than 30 days
  - Removed empty directories

💡 Complete deletion:
  rm -rf .trash/
```

---

## Example 7: Pre-commit Deletion Review

### User Input
```
Check the files I just deleted with git rm and commit them
```

### Execution Process
```bash
# Step 1: Check staged deletions
$ git status --short
D  src/old-component.tsx
D  lib/deprecated/utils.ts

# Step 2: Commit
$ git commit -m "chore: remove deprecated components

- Remove old-component.tsx (no longer used)
- Remove deprecated/utils.ts (replaced by new utils)"
```

### Output Result
```
✅ Commit complete:
  [main abc1234] chore: remove deprecated components
   2 files changed, 0 insertions(+), 0 deletions(-)
   delete mode 100644 src/old-component.tsx
   delete mode 100644 lib/deprecated/utils.ts

📝 Commit message:
  chore: remove deprecated components

  - Remove old-component.tsx (no longer used)
  - Remove deprecated/utils.ts (replaced by new utils)
```

---

## Example 8: Recover Accidentally Deleted File

### User Input
```
I accidentally deleted package-lock.json, can I recover it?
```

### Execution Process
```bash
# Step 1: Check git history
$ git log --all --full-history -- package-lock.json

# Step 2: Recover file
$ git checkout HEAD~1 -- package-lock.json
```

### Output Result
```
🔄 Recovery complete:
  git checkout HEAD~1 -- package-lock.json

💡 Recover from specific commit:
  git checkout <commit-hash> -- package-lock.json

💡 If in .trash:
  mv .trash/2026-01-*/package-lock.json .
```

---

## Example 9: Periodic Log File Cleanup

### User Input
```
Clean up log files older than 7 days in logs/ folder
```

### Execution Process
```bash
# Step 1: Check target files
$ find logs/ -name "*.log" -mtime +7
logs/app-20260112.log
logs/debug-20260110.log

# Step 2: Move to .trash (keep for 1 week)
$ mkdir -p .trash/logs-$(date +%Y-%m-%d)
$ find logs/ -name "*.log" -mtime +7 -exec mv {} .trash/logs-$(date +%Y-%m-%d)/ \;
```

### Output Result
```
✅ Non-tracked files (moved to .trash/):
  - logs/app-20260112.log
  - logs/debug-20260110.log

📁 Preserved at: .trash/logs-2026-01-19/

💡 Auto-delete after 30 days:
  find .trash/ -name "*.log" -mtime +30 -delete
```

---

## Example 10: Safe Deletion of Large Files

### User Input
```
The coverage/lcov-report/ folder is too large, I want to delete it
```

### Execution Process
```bash
# Step 1: Check folder size
$ du -sh coverage/lcov-report/
2.3G    coverage/lcov-report/

# Step 2: Check git tracking (usually non-tracked)
$ git ls-files --error-unmatch coverage/lcov-report/ | head -5
# (No output - non-tracked)

# Step 3: Move to .trash
$ mkdir -p .trash/$(date +%Y-%m-%d)
$ mv coverage/lcov-report/ .trash/$(date +%Y-%m-%d)/
```

### Output Result
```
✅ Non-tracked files (moved to .trash/):
  - coverage/lcov-report/ (2.3G)

📁 Preserved at: .trash/2026-01-19/

💡 Disk space freed:
  2.3G freed

💡 Complete deletion:
  rm -rf .trash/2026-01-19/lcov-report/
```

---

## Tips: Everyday Usage Patterns

### Tip 1: Preview Before Deletion

```bash
# Check list of files to delete (no actual deletion)
git ls-files | grep -E "\.(log|tmp)$"
find . -name "*.log" -type f
```

### Tip 2: Skip Patterns

```bash
# Skip node_modules/, .git/, .trash/
find . -type f -not -path "*/node_modules/*" \
            -not -path "*/.git/*" \
            -not -path "*/.trash/*" \
            -name "*.log"
```

### Tip 3: Interactive Confirmation

```bash
# Confirm before each deletion
for file in *.log; do
    read -p "Delete $file? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "$file" .trash/
    fi
done
```

---

## Related Documentation

- **SKILL.md**: Main skill documentation
- **REFERENCE.md**: Detailed technical reference
- **Claude Code Skills**: https://code.claude.com/docs/en/skills

---

**Version**: 1.0.0
**Last Updated**: 2026-01-19
