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

| Method | Command | Use Case |
|--------|---------|----------|
| Check tracked | `git ls-files --error-unmatch <filepath>` | Single file status |
| List tracked in folder | `git ls-files <folderpath>` | Folder contents |
| Detailed status | `git status <filepath>` | Full file state |

**Result Interpretation**:

| Result | Meaning | Action |
|--------|---------|--------|
| File path output | Git-tracked | Use `git rm` |
| Empty output (exit 1) | Non-tracked | Move to `.trash/` |
| `modified:` prefix | Modified tracked | Use `git rm` |
| `untracked:` prefix | New non-tracked | Move to `.trash/` |

### Git rm Options

| Option | Command | Purpose |
|--------|---------|---------|
| Basic | `git rm <filepath>` | Delete + stage |
| Recursive | `git rm -r <folderpath>` | Delete folder |
| Force | `git rm -f <filepath>` | Delete modified |
| Cache-only | `git rm --cached <filepath>` | Untrack only |
| Dry-run | `git rm --dry-run -r <path>` | Verify before delete |

### .trash Directory Structure

```
.trash/
├── 2026-01-19/          # Date-based subdirectories
│   ├── old-file.ts
│   └── deprecated-folder/
├── 2026-01-20/
│   └── temp.dat
└── .trash-index.json    # Optional: move history
```

**Date-based subdirectories recommended**: Prevents conflicts, tracks deletion date

---

## Implementation Scenarios

### Scenario 1: Pre-refactoring Cleanup

```bash
# Create deletion list
cat > files-to-remove.txt <<EOF
src/components/old/Button.tsx
src/components/old/Input.tsx
EOF

# Separate and process
git_files=()
trash_files=()

while IFS= read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        git_files+=("$file")
    else
        trash_files+=("$file")
    fi
done < files-to-remove.txt

# Batch process
for f in "${git_files[@]}"; do git rm "$f"; done

trash_dir=".trash/$(date +%Y-%m-%d)"
mkdir -p "$trash_dir"
for f in "${trash_files[@]}"; do mv "$f" "$trash_dir/"; done
```

### Scenario 2: Node Modules Cache Cleanup

```bash
# node_modules/ usually in .gitignore (non-tracked)
mkdir -p .trash
mv node_modules .trash/
[ -f package-lock.json ] && mv package-lock.json .trash/
```

### Scenario 3: Build Artifacts Cleanup

```bash
for build_dir in dist build out; do
    [ ! -d "$build_dir" ] && continue

    if git ls-files --error-unmatch "$build_dir" >/dev/null 2>&1; then
        git rm -r "$build_dir"
    else
        mkdir -p .trash && mv "$build_dir" .trash/
    fi
done
```

---

## Troubleshooting

### Problem 1: "Path too long" Error

**Symptom**: Path length exceeds 260 characters (Windows)

**Solution**: Use date subdirectories with maintained structure
```bash
mkdir -p .trash/$(date +%Y-%m-%d)/$(dirname "$file")
mv "$file" ".trash/$(date +%Y-%m-%d)/$file"
```

### Problem 2: Git rm Failed ("changes staged")

**Symptom**: `error: the following file has changes staged in the index`

**Solutions**:
```bash
# Option 1: Force deletion
git rm -f <filepath>

# Option 2: Unstage first
git reset HEAD <filepath> && git rm <filepath>
```

### Problem 3: .trash Permission Issues

**Symptom**: "Permission denied" when moving to `.trash/`

**Solutions**:
```bash
# Fix ownership and permissions
sudo chown -R $USER:$USER .trash/
chmod -R u+rw .trash/

# Or copy then delete
cp -r <file> .trash/ && rm -rf <file>
```

### Problem 4: Same-name File Conflicts

**Solution 1**: Date-based subdirectories
```bash
mkdir -p .trash/$(date +%Y-%m-%d)
mv <file> ".trash/$(date +%Y-%m-%d)/"
```

**Solution 2**: Auto-renaming function
```bash
move_to_trash() {
    local file="$1"
    local trash_dir=".trash"
    local base_name=$(basename "$file")
    local target="$trash_dir/$base_name"

    mkdir -p "$trash_dir"

    if [ -e "$target" ]; then
        local counter=1
        while [ -e "$target" ]; do
            local name="${base_name%.*}"
            local ext="${base_name##*.}"
            target="$trash_dir/${name}_$counter.$ext"
            ((counter++))
        done
    fi

    mv "$file" "$target"
    echo "✅ $file → $target"
}
```

---

## Advanced Usage

### Custom Cleanup Script

**Note**: The cleanup.sh script was removed in v4.4.14 as part of skill-based architecture migration. Use the /05_cleanup command with knip directly instead.

**Usage**: Create `.cleanup-list.txt` with file paths, then use `/05_cleanup mode=files` command

### .trash Cleanup Automation

**Cron job** (add to `crontab -e`):
```bash
# Auto-delete files older than 30 days
0 2 * * * find /path/to/project/.trash/ -type f -mtime +30 -delete
0 3 * * 0 find /path/to/project/.trash/ -type d -empty -delete
```

### Git Alias Registration

Add to `.gitconfig`:
```bash
[alias]
    trash = "!f() { mkdir -p .trash; mv \"$@\" .trash/; }; f"
    gitrm-all = "!git ls-files --deleted | xargs git rm"
```

**Usage**:
```bash
git trash temp.dat        # Move non-tracked to .trash
git gitrm-all            # git rm all deleted files
```

### Audit Log

**`.trash/.trash-index.json` example**:
```json
{"moved_at": "2026-01-19T10:30:00Z", "files": [{"original_path": "src/old.ts", "trash_path": ".trash/2026-01-19/old.ts", "git_managed": false, "size_bytes": 2048}]}
```

---

## Best Practices

**Workflow**: Check status → Apply skill → Commit → Update `.gitignore` (add `.trash/`)

**Team Setup**: Add `.trash/` to `.gitignore`, document in `CONTRIBUTING.md`

---

## Related Resources

- **Git Docs**: https://git-scm.com/docs/git-rm
- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **SKILL.md**: `.claude/skills/safe-file-ops/SKILL.md`

---

**Version**: 1.0.0
**Last Updated**: 2026-01-19
