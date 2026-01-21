---
name: code-cleanup
description: Dead code detection and removal using standard tooling. Use when removing unused imports, variables, or dead files.
---

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
rg --files -g '!*.test.ts' | while read f; do
  refs=$(rg -c "from.*$f" . 2>/dev/null || echo 0)
  [ "$refs" -eq 0 ] && echo "$f"
done
```

## Core Concepts

### Tier System

**Tier 1**: Unused imports (ESLint + TypeScript) - Fast, reliable, zero false positives

**Tier 2**: Dead files (ripgrep reference counting) - Files with zero inbound imports, risk-based classification

**Why Standard Tooling?** ESLint/TypeScript already configured, no bespoke tooling, community-tested

## Procedures

### Detect Unused Imports (Tier 1)

**Step 1**: `eslint . --ext .ts,.tsx --rule '@typescript-eslint/no-unused-vars: error' --format json`

**Step 2**: Parse results: `jq '.[].messages[] | select(.ruleId == "no-unused-vars")' eslint-report.json`

**Step 3**: Auto-fix: `eslint . --ext .ts,.tsx --fix`

### Detect Dead Files (Tier 2)

**Find files**: `rg --files --glob '!*.test.ts' src/`

**Count references**:
```bash
for file in $(rg --files src/); do
  refs=$(rg -c "from.*['\"]$file" src/ || echo 0)
  echo "$file: $refs"
done
```

**Filter zero refs**:
```bash
rg --files src/ | while read file; do
  refs=$(rg -c "from.*['\"]$file" src/ || echo 0)
  [ "$refs" -eq 0 ] && echo "$file"
done
```

### Risk Classification

| Risk | Examples | Action |
|------|----------|--------|
| **Low** | Tests, utils | Auto-delete |
| **Medium** | Components, services | Auto-delete (TTY) or dry-run (CI) |
| **High** | Auth, database, models | User confirmation required |

### Pre-flight Safety

```bash
# Block if modified or staged files exist
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  Working directory not clean"
  exit 2
fi
```

### Auto-Apply Workflow

```bash
# Auto-apply Low/Medium risk
for file in $(detect_dead_files); do
  risk=$(classify_risk "$file")
  if [ "$risk" = "Low" ] || [ "$risk" = "Medium" ]; then
    rm "$file"
  fi
done

# Confirm High risk
for file in $(detect_high_risk_files); do
  read -p "Delete $file? [y/N]: " confirm
  [ "$confirm" = "y" ] && rm "$file"
done
```

## Verification

**After each batch**: `npm test && npm run type-check && npm run lint`

**Final verification**: All checks must pass

**Rollback on failure**: `git checkout -- .`

## Command Integration

### /05_cleanup Command

```bash
# Pre-flight check
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  Working directory not clean"
  exit 2
fi

# Detect and classify
detect_dead_files | while IFS='|' read -r file risk; do
  echo "$file|$risk"
done | tee /tmp/cleanup_candidates.txt
```

## Troubleshooting

### False Positives

**Issue**: File marked as dead but actually used

**Causes**: Dynamic imports | Runtime requires | Non-standard syntax

**Solution**: Manual review before deletion

### Test Failures

**Issue**: Tests fail after cleanup

**Solution**: Rollback immediately: `git checkout -- .`

## Best Practices

- **Run tests after each batch**: Max 10 deletions per batch
- **Conservative exclusion**: Exclude index.*, main.*, *.config.*
- **Risk-based approach**: Auto-apply Low/Medium, confirm High
- **Clean working directory**: Block if modified/staged files exist

## Further Reading

**Internal**: @.claude/skills/code-cleanup/REFERENCE.md - Complete procedures, risk classification, auto-apply workflow, verification, troubleshooting | @.claude/skills/vibe-coding/SKILL.md - Code quality standards

**External**: [ESLint Unused Vars Rule](https://typescript-eslint.io/rules/no-unused-vars/) | [TypeScript Compiler Options](https://www.typescriptlang.org/tsconfig)
