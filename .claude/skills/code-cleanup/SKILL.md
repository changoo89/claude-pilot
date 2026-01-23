---
name: code-cleanup
description: Dead code detection and removal using knip (recommended) or standard tooling. Use when removing unused imports, variables, or dead files.
---

# SKILL: Code Cleanup

> **Purpose**: Dead code detection and removal using knip (recommended) or ESLint/TypeScript fallback
> **Target**: Coder Agent, cleanup commands

---

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

## Quick Start

### When to Use This Skill

- Remove unused import statements
- Detect and delete dead files (zero references)
- Clean up codebase after refactoring

### Usage

```bash
# Arguments: [mode=imports|files|all] [scope=repo|path=...] [--dry-run] [--apply]
MODE="${1:-files}"
SCOPE="${2:-repo}"
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

### Detection Tools (Choose One)

**Recommended: knip** (comprehensive, single tool)
```bash
npx knip                    # Full analysis: unused files, exports, deps
npx knip --reporter compact # Concise output
npx knip --fix              # Auto-fix safe issues
```

**Fallback: Standard tooling** (when knip not installed)
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

### Dead File Detection Procedure

```bash
#!/bin/bash
# Detect files with zero inbound imports

# Exclude patterns
EXCLUDE="--glob '!*.test.ts' --glob '!*.spec.ts' --glob '!index.ts' --glob '!main.*' --glob '!.eslintrc.*'"

# Find all source files
rg --files $EXCLUDE src/ | while read file; do
  # Count references (imports, requires)
  refs=$(rg -c "from.*['\"]$file" src/ || echo 0)

  if [ "$refs" -eq 0 ]; then
    echo "$file: 0 references"
  fi
done
```

---

## Step 2: Risk Classification (4-Level)

| Risk | File Types | Action |
|------|------------|--------|
| **SAFE** | Tests (`*.test.*`, `*.spec.*`), mocks, fixtures | auto-remove silently |
| **CAUTION** | Utils, helpers, internal modules | auto-remove + prompt summary |
| **WARNING** | Components, services, hooks | require tests pass before deletion |
| **DANGER** | Auth, database, config, API routes, models | refuse without explicit `--force` flag |

### Classification Function

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

### Auto-Apply Workflow

```bash
#!/bin/bash
# Auto-apply cleanup with risk-based confirmation

detect_dead_files() {
  rg --files --glob '!*.test.ts' src/ | while read file; do
    refs=$(rg -c "from.*['\"]$file" src/ || echo 0)
    if [ "$refs" -eq 0 ]; then
      risk=$(classify_risk "$file")
      echo "$file|$risk"
    fi
  done
}

# Auto-apply SAFE/CAUTION/WARNING
detect_dead_files | while IFS='|' read -r file risk; do
  if [ "$risk" = "SAFE" ] || [ "$risk" = "CAUTION" ] || [ "$risk" = "WARNING" ]; then
    echo "Auto-deleting: $file ($risk)"
    rm "$file"
  fi
done

# Confirm DANGER
detect_dead_files | while IFS='|' read -r file risk; do
  if [ "$risk" = "DANGER" ]; then
    echo "DANGER: $file"
    echo "  A) Delete"
    echo "  B) Skip"
    read -p "Choose [A/B]: " choice

    case $choice in
      A|a) rm "$file" && echo "Deleted: $file" ;;
      B|b) echo "Skipped: $file" ;;
    esac
  fi
done
```

---

## Step 4: Verification

### After Each Batch

```bash
#!/bin/bash
# Verify after cleanup

# 1. Run tests
if ! npm test; then
  echo "❌ Tests failed after cleanup"
  git checkout -- .
  exit 1
fi

# 2. Type check
if ! npm run type-check; then
  echo "❌ Type check failed after cleanup"
  git checkout -- .
  exit 1
fi

# 3. Lint
if ! npm run lint; then
  echo "❌ Lint failed after cleanup"
  git checkout -- .
  exit 1
fi

echo "✅ All checks passed after cleanup"
```

**Rollback on failure**: `git checkout -- .`

---

## Step 5: Execution Logging

Write cleanup results to `.cleanup/` folder (only when deletions occur):

```bash
#!/bin/bash
# Log cleanup results

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

## Parallel Detection (Optional)

Launch 3 detection agents in parallel using haiku model for speed:

```markdown
# Parallel Detection Pattern (read-only, safe)
Task A (haiku): npx knip --reporter json
Task B (haiku): eslint . --report-unused-disable-directives --format json
Task C (haiku): tsc --noUnusedLocals --noEmit 2>&1

# Result merge (sequential)
- Deduplicate findings across tools
- Apply .cleanup-ignore patterns
- Classify by risk level
```

**Why parallel is safe**: All detection commands are read-only (no file modifications).

**Fallback (knip not installed)**: Use rg-based detection, sequential execution only.

---

## Pre-flight Safety

```bash
# Block if modified or staged files exist
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  Working directory not clean"
  exit 2
fi
```

---

## Troubleshooting

### False Positives

**Issue**: File marked as dead but actually used

**Causes**: Dynamic imports | Runtime requires | Non-standard syntax

**Solution**: Manual review before deletion

### Test Failures

**Issue**: Tests fail after cleanup

**Solution**: Rollback immediately: `git checkout -- .`

---

## Best Practices

- **Run tests after each batch**: Max 10 deletions per batch
- **Conservative exclusion**: Exclude index.*, main.*, *.config.*
- **Risk-based approach**: Auto-apply Low/Medium, confirm High
- **Clean working directory**: Block if modified/staged files exist

---

## Related Skills

**safe-file-ops**: Safe deletion patterns | **vibe-coding**: Code quality standards | **parallel-subagents**: Parallel file scanning patterns

---

## Further Reading

**Internal**: @.claude/skills/code-cleanup/REFERENCE.md - Complete procedures, risk classification, auto-apply workflow, verification, troubleshooting | @.claude/skills/vibe-coding/SKILL.md - Code quality standards

**External**: [ESLint Unused Vars Rule](https://typescript-eslint.io/rules/no-unused-vars/) | [TypeScript Compiler Options](https://www.typescriptlang.org/tsconfig) | [knip](https://knip.dev/)

---

**⚠️ SAFETY**: Auto-rollback on verification failure
