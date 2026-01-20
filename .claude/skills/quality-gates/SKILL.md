# SKILL: Quality Gates

> **Purpose**: Pre-commit quality validation procedures (type-check, lint, todos, branch guard)
> **Target**: Coder Agent, pre-commit hooks, CI/CD pipelines

---

## Quick Start

### When to Use This Skill
- Before committing code (pre-commit hooks)
- Validating code quality in CI/CD
- Ensuring all todos complete before commit
- Preventing commits to protected branches

### Quick Reference
```bash
# Type check validation
npm run type-check  # or: tsc --noEmit

# Lint validation
npm run lint  # or: eslint . --ext .ts,.tsx

# Todo validation
.claude/scripts/hooks/check-todos.sh

# Branch guard
.claude/scripts/hooks/branch-guard.sh
```

---

## Core Concepts

### Quality Gates Philosophy

**Pre-commit hooks** enforce quality standards before code enters the repository.

**Skills as procedures, hooks as automation**:
- Skills document the **what** and **how** (this file)
- Hooks execute the procedures automatically
- CI provides fallback enforcement
- Developer autonomy preserved (opt-in hooks)

**Why Opt-In Hooks?**
- Mandatory hooks improve baseline quality but create friction
- Skills + CI yields consistent enforcement while preserving autonomy
- Developers can choose strictness level (off/stop/strict profile)

---

## Procedures

### Type Check Validation

**Purpose**: Verify code compiles without type errors

**Command**:
```bash
# TypeScript projects
tsc --noEmit

# Or via npm script
npm run type-check
```

**Expected Output**:
- Success: No output (exit code 0)
- Failure: Type errors with file/line/column (exit code 1)

**Example Failure**:
```
src/auth/login.ts:15:11 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
```

**Hook Script**: `.claude/scripts/hooks/typecheck.sh`

**Project Detection** (auto-detected by hook):
```bash
if [ -f "tsconfig.json" ]; then
  tsc --noEmit
elif [ -f "pyproject.toml" ]; then
  mypy .
elif [ -f "go.mod" ]; then
  go vet ./...
fi
```

**Configuration**:
```json
{
  "pre-commit": [
    ".claude/scripts/hooks/typecheck.sh"
  ]
}
```

---

### Lint Validation

**Purpose**: Enforce code style and catch common errors

**Command**:
```bash
# TypeScript/JavaScript
eslint . --ext .ts,.tsx --max-warnings 0

# Python
ruff check .

# Go
gofmt -l . | gofmt -w

# Or via npm script
npm run lint
```

**Expected Output**:
- Success: No output (exit code 0)
- Failure: Lint violations with rule IDs (exit code 1)

**Example Failure**:
```
src/utils/helpers.ts:42:7 - error no-unused-vars: 'formatDate' is assigned a value but never used.
```

**Hook Script**: `.claude/scripts/hooks/lint.sh`

**Project Detection** (auto-detected by hook):
```bash
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
  eslint . --ext .ts,.tsx
elif [ -f "pyproject.toml" ]; then
  ruff check .
elif [ -f "go.mod" ]; then
  gofmt -l .
fi
```

**Configuration**:
```json
{
  "pre-commit": [
    ".claude/scripts/hooks/lint.sh"
  ]
}
```

---

### Todo Validation

**Purpose**: Ensure all plan todos complete before commit

**Command**:
```bash
.claude/scripts/hooks/check-todos.sh
```

**Expected Output**:
- Success: "All todos complete - commit allowed" (exit code 0)
- Failure: "X todos pending - complete before commit" (exit code 1)

**Logic**:
```bash
PLAN_FILE=".pilot/plan/in_progress/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
  echo "No active plan - skipping todo check"
  exit 0  # Pass (no plan to check)
fi

# Extract incomplete todos
INCOMPLETE=$(grep -c "status: \"pending\"" "$PLAN_FILE")

if [ "$INCOMPLETE" -gt 0 ]; then
  echo "Error: $INCOMPLETE todos pending - complete before commit"
  exit 1  # Fail
fi

echo "All todos complete - commit allowed"
exit 0  # Pass
```

**Hook Script**: `.claude/scripts/hooks/check-todos.sh`

**Configuration**:
```json
{
  "pre-commit": [
    ".claude/scripts/hooks/check-todos.sh"
  ]
}
```

---

### Branch Guard

**Purpose**: Prevent commits to protected branches (main, master)

**Command**:
```bash
.claude/scripts/hooks/branch-guard.sh
```

**Expected Output**:
- Success: Commit allowed (exit code 0)
- Failure: "Error: Cannot commit to protected branch 'main'" (exit code 1)

**Logic**:
```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
PROTECTED_BRANCHES=("main" "master" "develop" "production")

for protected in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$BRANCH" = "$protected" ]; then
    echo "Error: Cannot commit to protected branch '$BRANCH'"
    echo "Create a feature branch: git checkout -b feature/your-feature"
    exit 1
  fi
done

exit 0  # Branch is not protected
```

**Hook Script**: `.claude/scripts/hooks/branch-guard.sh`

**Configuration**:
```json
{
  "pre-commit": [
    ".claude/scripts/hooks/branch-guard.sh"
  ]
}
```

**Protected Branches**: main, master, develop, production

---

## Installation

### Opt-In Installation

**Step 1: Copy hooks to Git hooks directory**
```bash
# Create symlink in .git/hooks/
ln -s ../../.claude/scripts/hooks/check-todos.sh .git/hooks/pre-commit
```

**Step 2: Configure via .claude/hooks.json**
```json
{
  "profile": "strict",
  "pre-commit": [
    ".claude/scripts/hooks/check-todos.sh",
    ".claude/scripts/hooks/branch-guard.sh",
    ".claude/scripts/hooks/lint.sh",
    ".claude/scripts/hooks/typecheck.sh"
  ]
}
```

**Step 3: Set profile mode**
```bash
# Profile modes: off | stop | strict
export CLAUDE_HOOKS_PROFILE="strict"

# off: Disable all hooks
# stop: Run hooks but don't block commit (warnings only)
# strict: Block commit on any hook failure (default)
```

---

## Profile System

### Profile Modes

| Profile | Behavior | Use Case |
|---------|----------|----------|
| **off** | Disable all hooks | Emergency fixes, experimental work |
| **stop** | Run hooks, warn only, don't block | Development mode, fast iteration |
| **strict** | Block commit on any failure | Production code, team collaboration |

### Configuration

**Via environment variable**:
```bash
export CLAUDE_HOOKS_PROFILE="strict"
```

**Via .claude/hooks.json**:
```json
{
  "profile": "strict",
  "hooks": {
    "pre-commit": [
      ".claude/scripts/hooks/typecheck.sh",
      ".claude/scripts/hooks/lint.sh"
    ]
  }
}
```

### Hook Performance

**Dispatcher Pattern**: O(1) project type detection (P95: 20ms)

**Smart Caching**: Config hash-based cache invalidation

**Gate vs Validator**:
- **Gate**: Safety checks (PreToolUse) - Block dangerous operations
- **Validator**: Quality checks (Stop) - Enforce standards

---

## CI/CD Integration

### Primary Enforcement Point

**Philosophy**: CI is the primary enforcement point, not hooks

**Rationale**:
- Hooks are developer convenience
- CI ensures consistency across team
- Pull requests enforce quality before merge
- Local hooks can be bypassed (git commit --no-verify)

**GitHub Actions Example**:
```yaml
name: Quality Gates
on: [pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm test
```

---

## Error Handling

### Hook Fails?

**Option 1: Fix the issues**
```bash
# Run type-check to see errors
npm run type-check

# Fix errors, then commit
git add .
git commit -m "fix: resolve type errors"
```

**Option 2: Skip hooks (not recommended)**
```bash
git commit --no-verify -m "WIP: skip hooks for emergency fix"
```

**Option 3: Switch profile**
```bash
# Temporarily switch to stop mode
export CLAUDE_HOOKS_PROFILE="stop"

# Commit (hooks will warn but not block)
git commit -m "WIP: work in progress"

# Switch back to strict
export CLAUDE_HOOKS_PROFILE="strict"
```

---

## Verification

### Test Hooks

```bash
# Test type-check hook
.claude/scripts/hooks/typecheck.sh
echo "Exit code: $?"  # 0 = pass, 1 = fail

# Test lint hook
.claude/scripts/hooks/lint.sh
echo "Exit code: $?"

# Test todo validation
.claude/scripts/hooks/check-todos.sh
echo "Exit code: $?"

# Test branch guard
.claude/scripts/hooks/branch-guard.sh
echo "Exit code: $?"
```

### Test Profile System

```bash
# Test strict mode
export CLAUDE_HOOKS_PROFILE="strict"
git commit -m "test"  # Should fail if type-check fails

# Test stop mode
export CLAUDE_HOOKS_PROFILE="stop"
git commit -m "test"  # Should warn but not block

# Test off mode
export CLAUDE_HOOKS_PROFILE="off"
git commit -m "test"  # Should skip all hooks
```

---

## Related Skills

**code-cleanup**: Dead code detection and removal | **vibe-coding**: Code quality standards | **tdd**: Test-driven development cycle

---

**Version**: claude-pilot 4.3.0
