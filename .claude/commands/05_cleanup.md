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

## .cleanup-ignore Support

Create `.cleanup-ignore` file in project root to protect files from deletion:

```gitignore
# .cleanup-ignore - Protected patterns (glob syntax)

# Core infrastructure
**/auth/**
**/database/**
**/*.config.*

# Entry points
**/index.ts
**/main.ts

# Generated files
**/generated/**
**/*.gen.ts
```

**Loading order**:
1. Read `.cleanup-ignore` if exists
2. Apply patterns to detection results
3. Protected files are excluded from deletion candidates

**Note**: `.cleanup-ignore` uses gitignore-style glob patterns.

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

## Step 2: Risk Classification (4-Level)

| Risk | File Types | Action |
|------|------------|--------|
| **SAFE** | Tests (`*.test.*`, `*.spec.*`), mocks, fixtures | auto-remove silently |
| **CAUTION** | Utils, helpers, internal modules | auto-remove + prompt summary |
| **WARNING** | Components, services, hooks | require tests pass before deletion |
| **DANGER** | Auth, database, config, API routes, models | refuse without explicit `--force` flag |

**Classification Logic**:
```bash
classify_risk() {
  case "$1" in
    *.test.* | *.spec.* | */__mocks__/*) echo "SAFE" ;;
    */utils/* | */helpers/* | */lib/*) echo "CAUTION" ;;
    */components/* | */services/* | */hooks/*) echo "WARNING" ;;
    */auth/* | */database/* | *.config.* | */api/* | */models/*) echo "DANGER" ;;
    *) echo "CAUTION" ;;  # Default to CAUTION
  esac
}
```

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

## Step 5: Execution Logging

Write cleanup results to `.cleanup/` folder (only when deletions occur):

```bash
# Create log directory
mkdir -p .cleanup

# Log file path
LOG_FILE=".cleanup/$(date +%Y-%m-%d_%H%M%S).log"

# Write log (only if deletions occurred)
if [ "$DELETED_COUNT" -gt 0 ]; then
  cat > "$LOG_FILE" << EOF
# Cleanup Log - $(date +%Y-%m-%d\ %H:%M:%S)

## Summary
- Mode: $MODE
- Scope: $SCOPE
- Files deleted: $DELETED_COUNT
- Tests: PASS

## Deleted Files
$(printf '%s\n' "${DELETED_FILES[@]}")

## Risk Breakdown
- SAFE: $SAFE_COUNT
- CAUTION: $CAUTION_COUNT
- WARNING: $WARNING_COUNT
- DANGER: $DANGER_COUNT (skipped)
EOF

  echo "✓ Log saved: $LOG_FILE"
fi
```

**stdout Summary** (always shown):
```
✅ Cleanup Complete
   Deleted: 5 files (3 SAFE, 2 CAUTION)
   Skipped: 1 file (DANGER)
   Tests: PASS
   Log: .cleanup/2026-01-23_120000.log
```

---

## Related Skills

**safe-file-ops**: Safe deletion patterns | **vibe-coding**: Code quality standards | **parallel-subagents**: Parallel file scanning patterns

---

**⚠️ SAFETY**: Auto-rollback on verification failure
