# REFERENCE: Code Cleanup

> **Detailed procedures, risk classification, and troubleshooting for dead code removal**

## Complete Procedures

### Tier 1: Unused Imports Detection

```bash
# Run ESLint with no-unused-vars rule
eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error' --format json

# Parse JSON output
jq '.[].messages[] | select(.ruleId == "no-unused-vars") | {file, line, message}' eslint-report.json

# Auto-fix (safe)
eslint . --ext .ts,.tsx --fix
```

### Tier 2: Dead File Detection

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

### Risk Classification

```bash
#!/bin/bash
# Classify dead files by risk

classify_risk() {
  local file="$1"

  # Low risk: Tests, utils
  if echo "$file" | grep -qE '\.(test|spec)\.'; then
    echo "Low"
  elif echo "$file" | grep -qE '(util|helper|test)'; then
    echo "Low"

  # Medium risk: Components, services
  elif echo "$file" | grep -qE '(component|service)'; then
    echo "Medium"

  # High risk: Core logic, auth, database
  elif echo "$file" | grep -qE '(auth|user|database|model)'; then
    echo "High"
  else
    echo "Medium"
  fi
}
```

## Auto-Apply Workflow

```bash
#!/bin/bash
# Auto-apply Low/Medium risk items without confirmation

detect_dead_files() {
  rg --files --glob '!*.test.ts' src/ | while read file; do
    refs=$(rg -c "from.*['\"]$file" src/ || echo 0)
    if [ "$refs" -eq 0 ]; then
      risk=$(classify_risk "$file")
      echo "$file|$risk"
    fi
  done
}

# Auto-apply Low/Medium risk
detect_dead_files | while IFS='|' read -r file risk; do
  if [ "$risk" = "Low" ] || [ "$risk" = "Medium" ]; then
    echo "Auto-deleting: $file ($risk)"
    rm "$file"
  fi
done

# Confirm High risk
detect_dead_files | while IFS='|' read -r file risk; do
  if [ "$risk" = "High" ]; then
    echo "High risk: $file"
    echo "  1) Delete"
    echo "  2) Skip"
    echo "  3) View content"
    read -p "Choose [1-3]: " choice

    case $choice in
      1) rm "$file" && echo "Deleted: $file" ;;
      2) echo "Skipped: $file" ;;
      3) cat "$file" && read -p "Delete? [y/N]: " confirm && [ "$confirm" = "y" ] && rm "$file" ;;
    esac
  fi
done
```

## Verification

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

## Rollback

```bash
# Rollback if verification fails
git checkout -- .

# Or stash for manual review
git stash save "Cleanup attempt $(date)"
```

## Troubleshooting

### False Positives

**Issue**: File marked as dead but actually used

**Causes**:
1. Dynamic imports: `import(path)` not detected by grep
2. Runtime requires: `require(path)` not detected
3. Non-standard import syntax

**Solution**: Manual review before deletion

### Test Failures After Cleanup

**Issue**: Tests fail after removing "dead" code

**Solution**: Rollback immediately and investigate dependencies

```bash
git checkout -- .
npm test  # Should pass
```

## Further Reading

**Internal**: @.claude/skills/vibe-coding/SKILL.md - Code quality standards

**External**: [ESLint Rules](https://eslint.org/docs/rules/) | [TypeScript Compiler Options](https://www.typescriptlang.org/tsconfig)
