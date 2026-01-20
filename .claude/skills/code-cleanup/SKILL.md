# SKILL: Code Cleanup

> **Purpose**: Dead code detection and removal using standard tooling (ESLint, TypeScript)
> **Target**: Coder Agent, cleanup commands

---

## Quick Start

### When to Use This Skill
- Remove unused import statements
- Detect and delete dead files (zero references)
- Clean up codebase after refactoring

### Quick Reference
```bash
# Unused imports (ESLint)
eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error'

# Unused locals/parameters (TypeScript)
tsc --noUnusedLocals --noUnusedParameters --noEmit

# Dead files (ripgrep)
rg --files -g '!*.test.ts' -g '!*.spec.ts' | while read f; do
  refs=$(rg -c "from.*$f" . 2>/dev/null || echo 0)
  [ "$refs" -eq 0 ] && echo "$f"
done
```

---

## What This Skill Covers

### In Scope
- Unused import detection (ESLint-based)
- Unused local variable/parameter detection (TypeScript-based)
- Dead file detection (ripgrep-based reference counting)
- Safe deletion with rollback

### Out of Scope
- Custom static analysis tools → Use standard tooling instead
- Complex dependency analysis → Manual review required
- Runtime code coverage → Use coverage tools (istanbul, c8)

---

## Core Concepts

### Tier System

**Tier 1**: Unused imports (ESLint + TypeScript)
- `@typescript-eslint/no-unused-vars` rule
- `--noUnusedLocals --noUnusedParameters` flags
- Fast, reliable, zero false positives

**Tier 2**: Dead files (ripgrep reference counting)
- Files with zero inbound imports
- Conservative exclusion patterns (index.*, main.*, *.config.*)
- Risk-based classification (Low/Medium/High)

**Why Standard Tooling?**
- ESLint/TypeScript are already configured in projects
- No bespoke tooling maintenance burden
- Community-tested, well-documented
- Matches obra/superpowers skill-only philosophy

---

## Procedures

### Detect Unused Imports (Tier 1)

**Step 1: Run ESLint with no-unused-vars rule**
```bash
eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error' --format json
```

**Expected Output**:
```json
{
  "results": [
    {
      "filePath": "src/components/Button.tsx",
      "messages": [
        {
          "ruleId": "@typescript-eslint/no-unused-vars",
          "message": "'Button' is assigned a value but never used.",
          "line": 10,
          "column": 7
        }
      ]
    }
  ]
}
```

**Step 2: Extract unused imports**
```bash
eslint . --ext .ts,.tsx \
  --rule '@typescript-eslint/no-unused-vars: error' \
  --format json | \
  jq -r '.results[] | select(.messages | length > 0) |
    "\(.filePath): \([.messages[].message] | join(", "))"'
```

**Step 3: Run TypeScript compiler for unused locals/params**
```bash
tsc --noUnusedLocals --noUnusedParameters --noEmit
```

**Expected Output**:
```
src/utils/helpers.ts:15:11 - error TS6133: 'formatDate' is declared but its value is never read.
```

**Cleanup Command**:
```bash
# Auto-fix with ESLint (safe imports only)
eslint . --ext .ts,.tsx --fix

# Manual removal for unused locals/params
# (TS compiler doesn't auto-fix these)
```

---

### Detect Dead Files (Tier 2)

**Step 1: Find all source files**
```bash
rg --files --type ts --type js --type tsx --type jsx \
  --glob '!*.test.ts' --glob '!*.test.tsx' --glob '!*.test.js' \
  --glob '!*.spec.ts' --glob '!*.spec.tsx' --glob '!*.spec.js' \
  --glob '!*.mock.ts' --glob '!*.mock.tsx' --glob '!*.mock.js' \
  --glob '!*.d.ts' \
  --glob '!*.config.ts' --glob '!*.config.js' \
  --glob '!dist/**' --glob '!build/**' \
  --glob '!node_modules/**' --glob '!.next/**'
```

**Step 2: Check file references**
```bash
check_file_references() {
  local file="$1"
  local basename=$(basename "$file" | sed 's/\.[^.]*$//')

  # Count references (excluding the file itself)
  local ref_count=$(rg -c "(from[[:space:]]+['\"]$file|import[[:space:]]+.*from[[:space:]]+['\"].*$basename)" \
    --glob "!$file" \
    --glob "!node_modules/**" \
    --glob "!.next/**" \
    . 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')

  echo "${ref_count:-0}"
}

# Find dead files
while IFS= read -r file; do
  refs=$(check_file_references "$file")
  if [ "$refs" -eq 0 ]; then
    echo "$file"
  fi
done < <(rg --files --type ts)
```

**Step 3: Risk classification**
```bash
calculate_risk() {
  local file="$1"

  if echo "$file" | grep -qE "(test|spec|mock|example|demo)"; then
    echo "Low"
  elif echo "$file" | grep -qE "(util|helper|service|handler)"; then
    echo "Medium"
  elif echo "$file" | grep -qE "(component|route|controller|middleware|plugin)"; then
    echo "High"
  fi
}
```

**Exclusion Patterns**:
- `index.*`, `main.*`, `cli.*` (entry points)
- `*.config.*` (configuration files)
- `*.test.*`, `*.spec.*`, `*.mock.*` (test files)
- `*.d.ts` (type definitions)
- `dist/**`, `build/**`, `node_modules/**`, `.next/**` (build artifacts)

---

### Safe Deletion Procedure

**Pre-flight Checks**:
```bash
# Check for modified/staged files (block deletion)
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working directory not clean"
  echo "Commit or stash changes before cleanup"
  exit 1
fi

# Verify tests pass
npm test || {
  echo "Error: Tests failing - cannot cleanup"
  exit 1
}
```

**Deletion Loop**:
```bash
BATCH_SIZE=10
CURRENT_BATCH=0

for file in $DEAD_FILES; do
  risk=$(calculate_risk "$file")

  # Auto-apply Low/Medium risk
  if [ "$risk" != "High" ]; then
    git rm "$file" || mv "$file" .trash/
    echo "Removed: $file"
  else
    # High risk: prompt user
    echo "Delete $file? (y/n)"
    read answer
    [ "$answer" = "y" ] && git rm "$file"
  fi

  # Verification after each batch
  ((CURRENT_BATCH++))
  if [ $((CURRENT_BATCH % BATCH_SIZE)) -eq 0 ]; then
    npm test || {
      echo "Tests failed - rolling back"
      git checkout .
      exit 1
    }
  fi
done
```

**Rollback on Failure**:
```bash
# Restore from .trash/
for file in .trash/*; do
  mv "$file" "${file#.trash/}"
done

# Or use git
git checkout .
```

---

## Integration Points

### `/05_cleanup` Command
- **Mode**: `imports` (Tier 1), `files` (Tier 2), `all` (both)
- **Scope**: `repo` (default), `path=...` (specific directory)
- **Flags**: `--dry-run` (preview), `--apply` (execute)

**Usage Examples**:
```bash
/05_cleanup mode=imports          # Detect unused imports (dry-run)
/05_cleanup mode=files --apply    # Delete dead files
/05_cleanup mode=all path=src/components  # Analyze specific dir
```

### Pre-commit Integration
**Optional**: Add to `.claude/hooks.json`
```json
{
  "pre-commit": [
    "eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error'"
  ]
}
```

**Better**: Use CI for enforcement (developer autonomy)

---

## Verification Commands

**After Cleanup**:
```bash
# Verify tests pass
npm test

# Verify type-check clean
tsc --noEmit

# Verify lint clean
eslint . --ext .ts,.tsx

# Verify no broken imports
rg "from ['\"]\.\./.*['\"]" --files-with-matches | xargs -I {} sh -c 'tsc --noEmit {} || echo "{}: broken import"'
```

---

## Error Handling

**ESLint Not Installed**:
```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

**TypeScript Not Installed**:
```bash
npm install --save-dev typescript
```

**Ripgrep Not Installed**:
```bash
brew install ripgrep
```

---

## Related Skills

**vibe-coding**: Code quality standards (≤50 lines functions, ≤200 lines files) | **safe-file-ops**: Safe deletion patterns | **quality-gates**: Pre-commit procedures

---

**Version**: claude-pilot 4.3.0
