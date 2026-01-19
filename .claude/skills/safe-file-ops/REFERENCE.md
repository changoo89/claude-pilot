# Safe File Operations - Detailed Reference

> **Detailed reference documentation for SKILL.md progressive disclosure**
> **Purpose**: Complex scenarios, troubleshooting, advanced usage

---

## Table of Contents

1. [Technical Details](#technical-details)
2. [Implementation Scenarios](#implementation-scenarios)
3. [Troubleshooting](#troubleshooting)
4. [Advanced Usage](#advanced-usage)

---

## Technical Details

### Git File Status Detection

**3 ways to check git file status**:

```bash
# Method 1: Check if file is tracked (output means tracked)
git ls-files --error-unmatch <filepath>

# Method 2: List all tracked files in folder
git ls-files <folderpath>

# Method 3: Detailed file status
git status <filepath>
```

**Result Interpretation**:

| Result | Meaning | Handling |
|--------|---------|----------|
| File path output | Git-tracked | Use `git rm` |
| Empty output (exit code 1) | Non-tracked | Move to `.trash/` |
| `modified:` prefix | Modified tracked file | Use `git rm` |
| `untracked:` prefix | New non-tracked file | Move to `.trash/` |

### Git rm Options Detail

```bash
# Basic deletion (delete file + stage)
git rm <filepath>

# Recursive folder deletion
git rm -r <folderpath>

# Force deletion (delete modified files too)
git rm -f <filepath>

# Cache-only deletion (keep file, untrack)
git rm --cached <filepath>

# Dry-run mode (verify only, no actual deletion)
git rm --dry-run -r <folderpath>
```

### .trash Directory Structure

```
project-root/
├── .trash/
│   ├── 2026-01-19/
│   │   ├── old-file.ts
│   │   └── deprecated-folder/
│   ├── 2026-01-20/
│   │   └── temp.dat
│   └── .trash-index.json  # (optional) move history
├── src/
└── docs/
```

**Recommend date-based subdirectories**:

- Pros: Prevents same-name conflicts, tracks deletion date
- Implementation: `mkdir -p .trash/$(date +%Y-%m-%d)`

---

## Implementation Scenarios

### Scenario 1: Pre-refactoring Cleanup

**Situation**: Need to delete 50 old component files

```bash
# Step 1: Create deletion list
cat > files-to-remove.txt <<EOF
src/components/old/Button.tsx
src/components/old/Input.tsx
src/components/old/Modal.tsx
...
EOF

# Step 2: Separate git and non-git files
git_managed_files=()
non_git_files=()

while IFS= read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        git_managed_files+=("$file")
    else
        non_git_files+=("$file")
    fi
done < files-to-remove.txt

# Step 3: Batch process
# Git-tracked files
for file in "${git_managed_files[@]}"; do
    git rm "$file"
done

# Non-tracked files
trash_dir=".trash/$(date +%Y-%m-%d)"
mkdir -p "$trash_dir"
for file in "${non_git_files[@]}"; do
    mv "$file" "$trash_dir/"
done

echo "✅ Git-tracked: ${#git_managed_files[@]} files deleted"
echo "✅ Non-tracked: ${#non_git_files[@]} files moved"
```

### Scenario 2: Node Modules Cache Cleanup

```bash
# node_modules/ usually in .gitignore, so non-tracked
mkdir -p .trash
mv node_modules .trash/

# package-lock.json to .trash if needed
if [ -f package-lock.json ]; then
    mv package-lock.json .trash/
fi

echo "✅ Moved node_modules to .trash/"
echo "💡 To recover: mv .trash/node_modules ."
```

### Scenario 3: Build Artifacts Cleanup

```bash
# Clean dist/, build/, out/ build outputs
for build_dir in dist build out; do
    if [ -d "$build_dir" ]; then
        # Check git tracking
        if git ls-files --error-unmatch "$build_dir" >/dev/null 2>&1; then
            echo "📂 $build_dir is git-tracked."
            git rm -r "$build_dir"
        else
            echo "📦 $build_dir is non-tracked."
            mkdir -p .trash
            mv "$build_dir" .trash/
        fi
    fi
done
```

---

## Troubleshooting

### Problem 1: "Path too long" Error

**Symptom**: "Path too long" or "File name too long" when moving files

**Cause**: Windows path length limit (260 characters)

**Solution**:
```bash
# Use WSL/Git Bash (supports long paths)
# Or use \\?\\\ UNC path (Windows)

# Maintain subdirectory structure in .trash
mkdir -p .trash/$(date +%Y-%m-%d)/$(dirname "$file")
mv "$file" ".trash/$(date +%Y-%m-%d)/$file"
```

### Problem 2: Git rm Failed ("changes staged in the index")

**Symptom**: `git rm` error "error: the following file has changes staged in the index"

**Cause**: File modified in staging area

**Solution**:
```bash
# Force deletion (discard changes and delete)
git rm -f <filepath>

# Or unstage first then delete
git reset HEAD <filepath>
git rm <filepath>
```

### Problem 3: .trash Directory Permission Issues

**Symptom**: "Permission denied" when moving to `.trash/`

**Cause**: Read-only files or ownership mismatch

**Solution**:
```bash
# Change ownership then move (sudo if needed)
sudo chown -R $USER:$USER .trash/
chmod -R u+rw .trash/

# Or use cp (preserves permissions)
cp -r <file> .trash/
rm -rf <file>
```

### Problem 4: Same-name File Conflicts in .trash

**Symptom**: Overwriting when moving same-name files multiple times

**Solution 1**: Date-based subdirectories
```bash
mkdir -p .trash/$(date +%Y-%m-%d)
mv <file> ".trash/$(date +%Y-%m-%d)/"
```

**Solution 2**: Timestamp suffix
```bash
timestamp=$(date +%H%M%S)
mv <file> ".trash/<filename>_$timestamp.<ext>"
```

**Solution 3**: Auto-renaming on conflict
```bash
move_to_trash() {
    local file="$1"
    local trash_dir=".trash"
    local base_name=$(basename "$file")
    local target="$trash_dir/$base_name"

    mkdir -p "$trash_dir"

    # Check conflict
    if [ -e "$target" ]; then
        local counter=1
        while [ -e "$target" ]; do
            local name_without_ext="${base_name%.*}"
            local ext="${base_name##*.}"
            target="$trash_dir/${name_without_ext}_$counter.$ext"
            ((counter++))
        done
    fi

    mv "$file" "$target"
    echo "✅ $file → $target"
}
```

---

## Advanced Usage

### Custom Script Integration

**`.claude/skills/safe-file-ops/scripts/cleanup.sh`**:

```bash
#!/bin/bash
# Automatic file cleanup script

set -euo pipefail

TRASH_DIR=".trash"
DATE_DIR="$TRASH_DIR/$(date +%Y-%m-%d)"
mkdir -p "$DATE_DIR"

# Process files passed as arguments
process_files() {
    local files=("$@")
    local git_count=0
    local trash_count=0

    for file in "${files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "⚠️  Not found: $file"
            continue
        fi

        if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            git rm -rf "$file"
            ((git_count++))
        else
            mv "$file" "$DATE_DIR/"
            ((trash_count++))
        fi
    done

    echo "✅ Complete: Git $git_count, Trash $trash_count"
}

# Read from file list
if [ -f ".cleanup-list.txt" ]; then
    readarray -t files < .cleanup-list.txt
    process_files "${files[@]}"
else
    echo "❌ .cleanup-list.txt not found."
    exit 1
fi
```

**Call script from SKILL.md**:
```markdown
## Automatic Cleanup

To clean multiple files at once:

1. Create `.cleanup-list.txt` with file paths
2. Run script:

```bash
bash .claude/skills/safe-file-ops/scripts/cleanup.sh
```
```

### .trash Cleanup Automation

**Cron job for periodic cleanup**:

```bash
# Auto-delete files older than 30 days in .trash
# Add to crontab -e:

0 2 * * * find /path/to/project/.trash/ -type f -mtime +30 -delete
0 3 * * 0 find /path/to/project/.trash/ -type d -empty -delete
```

### Git Alias Registration

**Add custom commands to `.gitconfig`**:

```bash
# .gitconfig
[alias]
    trash = "!f() { mkdir -p .trash; mv \"$@\" .trash/; }; f"
    gitrm-all = "!git ls-files --deleted | xargs git rm"
```

**Usage**:
```bash
# Move non-tracked files to .trash with git alias
git trash temp.dat

# git rm all deleted files at once
git gitrm-all
```

### Audit Log

**Store deletion history in `.trash/.trash-index.json`**:

```json
{
  "moved_at": "2026-01-19T10:30:00Z",
  "files": [
    {
      "original_path": "src/old.ts",
      "trash_path": ".trash/2026-01-19/old.ts",
      "git_managed": false,
      "size_bytes": 2048
    }
  ]
}
```

**Log generation script**:
```bash
log_trash_operation() {
    local file="$1"
    local trash_path="$2"
    local is_git="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat >> .trash/.trash-index.json <<EOF
{
  "moved_at": "$timestamp",
  "files": [
    {
      "original_path": "$file",
      "trash_path": "$trash_path",
      "git_managed": $is_git,
      "size_bytes": $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
    }
  ]
}
EOF
}
```

---

## Best Practices

### Best Practice 1: Project Cleanup Workflow

```bash
# Step 1: Check target files
git status --short

# Step 2: Use this skill for safe deletion

# Step 3: Commit changes
git commit -m "chore: remove deprecated files

- Remove old components using safe-file-ops skill
- Moved non-tracked files to .trash/
- See .trash/ for recovered items"

# Step 4: Update .gitignore if needed
echo ".trash/" >> .gitignore
git add .gitignore
git commit -m "chore: add .trash/ to gitignore"
```

### Best Practice 2: Team Collaboration .trash Management

**`.gitignore` setup**:
```gitignore
# Exclude .trash directory from version control
.trash/

# Allow local trash for each team member
# (each team member has their own .trash)
```

**Documentation**:
```markdown
# CONTRIBUTING.md

## File Deletion

Use `safe-file-ops` skill when deleting files:
- Git-tracked files: `git rm` for safe deletion
- Non-tracked files: Move to `.trash/`

`.trash/` is added to `.gitignore` in team projects.
```

---

## Related Resources

- **Git Official Docs**: https://git-scm.com/docs/git-rm
- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **Project Skill**: `.claude/skills/safe-file-ops/SKILL.md`

---

**Version**: 1.0.0
**Last Updated**: 2026-01-19
