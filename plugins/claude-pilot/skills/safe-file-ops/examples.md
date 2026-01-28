# Safe File Operations - Usage Examples

> **Real-world usage examples and output samples**

---

## Example 1: Delete Single Git-tracked File

### User Input
```
Delete src/components/LegacyButton.tsx file
```

### Execution
```bash
# Check git tracking
$ git ls-files --error-unmatch src/components/LegacyButton.tsx
src/components/LegacyButton.tsx

# Delete with git rm
$ git rm src/components/LegacyButton.tsx
rm 'src/components/LegacyButton.tsx'
```

### Output
```
✅ Git-tracked files (deleted with git rm):
  - src/components/LegacyButton.tsx

💡 To commit: git commit -m "Remove LegacyButton component"
```

---

## Example 2: Move Non-tracked Files to Trash

### User Input
```
Delete temp-debug.log file and cache/ folder
```

### Execution
```bash
# Check git tracking (no output = non-tracked)
$ git ls-files --error-unmatch temp-debug.log
$ git ls-files --error-unmatch cache/

# Move to .trash
$ mkdir -p .trash/2026-01-19
$ mv temp-debug.log .trash/2026-01-19/
$ mv cache .trash/2026-01-19/
```

### Output
```
✅ Non-tracked files (moved to .trash/):
  - temp-debug.log → .trash/2026-01-19/
  - cache/ → .trash/2026-01-19/

💡 To recover: mv .trash/2026-01-19/temp-debug.log .
```

---

## Example 3: Mixed Deletion (Git + Non-tracked)

### User Input
```
Delete docs/deprecated/ folder and build-output.log
```

### Execution
```bash
# Check git tracking
$ git ls-files docs/deprecated/
docs/deprecated/README.md
docs/deprecated/guide.md

$ git ls-files --error-unmatch build-output.log
# (No output - non-tracked)

# Separate handling
$ git rm -r docs/deprecated/
$ mkdir -p .trash/2026-01-19
$ mv build-output.log .trash/2026-01-19/
```

### Output
```
✅ Git-tracked files (deleted with git rm):
  - docs/deprecated/

✅ Non-tracked files (moved to .trash/):
  - build-output.log → .trash/2026-01-19/
```

---

## Example 4: Wildcard Pattern Batch Processing

### User Input
```
Delete all *.log files
```

### Execution
```bash
# Collect target files
$ find . -name "*.log" -type f
./debug.log
./app.log
./error.log

# Check each file and separate
for file in debug.log app.log error.log; do
    git ls-files --error-unmatch "$file" || mv "$file" .trash/
done
```

### Output
```
✅ Git-tracked files (deleted with git rm):
  - app.log

✅ Non-tracked files (moved to .trash/):
  - debug.log
  - error.log
```

---

## Example 5: Interactive Recovery

### User Input
```
I want to recover config.old from deleted files
```

### Execution
```bash
# Search in .trash
$ find .trash/ -name "config.old"
.trash/2026-01-18/config.old

# Recovery
$ mv .trash/2026-01-18/config.old .
```

### Output
```
🔄 Recovery complete: .trash/2026-01-18/config.old → ./config.old

💡 For git-tracked files: git checkout HEAD -- config.old
```

---

## Example 6: Clean Up .trash

### User Input
```
Clean up the .trash folder
```

### Execution
```bash
# Check contents
$ du -sh .trash/*
50M    .trash/2026-01-15
120M   .trash/2026-01-16

# Delete files older than 30 days
$ find .trash/ -type f -mtime +30 -delete
$ find .trash/ -type d -empty -delete
```

### Output
```
🧹 .trash cleanup complete:
  - Deleted files older than 30 days
  - Removed empty directories

💡 Complete deletion: rm -rf .trash/
```

---

## Example 7: Pre-commit Deletion Review

### User Input
```
Check deleted files and commit them
```

### Execution
```bash
# Check staged deletions
$ git status --short
D  src/old-component.tsx
D  lib/deprecated/utils.ts

# Commit
$ git commit -m "chore: remove deprecated components"
```

### Output
```
✅ Commit complete:
  [main abc1234] chore: remove deprecated components
   2 files changed, 0 insertions(+), 0 deletions(-)
   delete mode 100644 src/old-component.tsx
   delete mode 100644 lib/deprecated/utils.ts
```

---

## Example 8: Recover Accidentally Deleted File

### User Input
```
I accidentally deleted package-lock.json, can I recover it?
```

### Execution
```bash
$ git checkout HEAD~1 -- package-lock.json  # Recover from git
```

### Output
```
🔄 Recovery complete
💡 If in .trash: mv .trash/2026-01-*/package-lock.json .
```

---

## Example 9: Safe Deletion of Large Files

### User Input
```
Delete coverage/lcov-report/ folder (2.3G)
```

### Execution
```bash
$ du -sh coverage/lcov-report/  # Check size
$ mkdir -p .trash/$(date +%Y-%m-%d)
$ mv coverage/lcov-report/ .trash/$(date +%Y-%m-%d)/
```

### Output
```
✅ Non-tracked files (moved to .trash/): coverage/lcov-report/ (2.3G)
💡 Complete deletion: rm -rf .trash/2026-01-19/lcov-report/
```

---

## Tips: Everyday Usage Patterns

### Tip 1: Preview Before Deletion
```bash
# List files to delete (no deletion)
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
