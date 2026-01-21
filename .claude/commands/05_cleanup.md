---
description: Safe dead code cleanup - detect and remove unused imports and dead files with auto-apply for Low/Medium risk
argument-hint: "[mode=imports|files|all] [scope=repo|path=...] [--dry-run] [--apply] - cleanup mode and scope"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion
---

# /05_cleanup

_Auto-apply dead code cleanup with risk-based confirmation._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 in sequence
- Only stop on ERROR or for High-risk confirmations (Step 3)

---

## Core Philosophy

**Auto-apply**: Low/Medium risk deleted without confirmation | **High-risk**: User confirmation required | **Safe flags**: `--dry-run`, `--apply` | **Verification**: Commands after each batch

---

## Usage

```bash
/05_cleanup [mode=imports|files|all] [scope=repo|path=...] [--dry-run] [--apply]
```

**Modes**: imports (unused), files (dead), all (both)

---

## Step 1: Detect Dead Code

```bash
MODE="${1:-files}"
SCOPE="${2:-repo}"

# Find unused imports
if [ "$MODE" = "imports" ]; then
    grep -r "import.*from" src/ --include="*.ts" | dead-import-detector

# Find dead files
elif [ "$MODE" = "files" ]; then
    find src/ -name "*.ts" -exec grep -l "{}" \; -print | dead-file-detector
fi
```

---

## Step 2: Risk Classification

| File Type | Risk | Action |
|-----------|------|--------|
| Tests | Low | Auto-apply |
| Utils | Medium | Auto-apply |
| Components | High | User confirmation |

---

## Step 3: Cleanup with Confirmation

```bash
for file in $DEAD_FILES; do
    RISK=$(classify_risk "$file")

    if [ "$RISK" = "high" ]; then
        AskUserQuestion: Delete "$file"? A) Yes B) No
    else
        rm "$file"
    fi
done
```

---

## Step 4: Verification

```bash
npm test
if [ $? -ne 0 ]; then
    git checkout .
    echo "❌ Tests failed - rolled back"
    exit 1
fi
```

---

## Related Skills

**safe-file-ops**: Safe deletion patterns | **vibe-coding**: Code quality standards | **parallel-subagents**: Parallel file scanning patterns

---

**⚠️ SAFETY**: Auto-rollback on verification failure
