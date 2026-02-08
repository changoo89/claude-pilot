# REFERENCE: Quality Gates

> **Detailed procedures and troubleshooting for quality validation**

## Complete Hook Scripts

**Note**: Pre-commit hooks were removed in v4.4.14 as part of skill-based architecture migration. The following hook scripts are kept as reference for manual quality validation procedures.

### Type Check Hook

```bash
#!/bin/bash
# Quality validation: Type check

# Auto-detect project type
if [ -f "tsconfig.json" ]; then
  echo "Running TypeScript type check..."
  tsc --noEmit
elif [ -f "package.json" ] && grep -q "typecheck" package.json; then
  echo "Running type check via npm..."
  npm run typecheck
else
  echo "No typecheck configured, skipping"
  exit 0
fi
```

### Lint Hook

```bash
#!/bin/bash
# Quality validation: Lint

# Auto-detect linter
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
  echo "Running ESLint..."
  npx eslint . --ext .ts,.tsx,.js,.jsx
elif [ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml; then
  echo "Running Ruff..."
  ruff check .
else
  echo "No linter configured, skipping"
  exit 0
fi
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Quality Gates

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npm run type-check

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test

      - name: Coverage
        run: npm test -- --coverage
```

## Troubleshooting

### Type Check Failures

**Issue**: `tsc --noEmit` fails with type errors

**Common Causes**:
1. Missing type definitions: `npm install --save-dev @types/node`
2. Incorrect tsconfig: Check `compilerOptions`
3. Third-party library types: Install `@types/library-name`

**Debug Steps**:
```bash
# Verbose output
tsc --noEmit --listFiles

# Check specific file
tsc --noEmit src/problem.ts
```

### Lint Failures

**Issue**: ESLint reports errors but they're false positives

**Solution**: Update `.eslintrc.js` rules or use `// eslint-disable-next-line`

**Temporary Fix**:
```bash
# Auto-fix what can be fixed
npx eslint . --fix
```

## Pre-commit Hook Installation

**Note**: Pre-commit hooks were removed in v4.4.14 as part of skill-based architecture migration. Use docs-verify skill for documentation validation instead.

## Further Reading

**Internal**: @.claude/skills/ralph-loop/SKILL.md - Quality gates in Ralph Loop

**External**: [Husky](https://github.com/typicode/husky) | [pre-commit](https://pre-commit.com/)
