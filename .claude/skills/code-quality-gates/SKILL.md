---
name: code-quality-gates
description: Use automatically before and after code changes. Ensures documentation, formatting, type safety, and audit standards.
---

# SKILL: Code Quality Gates

> **Purpose**: Automated quality checks before/after code changes (PreToolUse, PostToolUse, Stop hooks converted to skill logic)
> **Target**: All agents making code changes

---

## Quick Start

### When to Use This Skill
- Before creating any .md files (documentation gate)
- After writing code (formatting, type check, linting)
- Before completing work (final audit)

### Quick Reference
```bash
# PreToolUse: Block .md file creation
block_md_creation() {
  local file="$1"
  if [[ "$file" == *.md ]]; then
    echo "Error: .md file creation blocked. Use Write tool instead." >&2
    return 1
  fi
}

# PostToolUse: Auto-format
auto_format() {
  local file="$1"
  prettier --write "$file" 2>/dev/null || true
  npx prettier --write "$file" 2>/dev/null || true
}

# PostToolUse: Type check
type_check() {
  npx tsc --noEmit 2>/dev/null || true
}

# Stop: Console.log audit
audit_console_logs() {
  grep -rn "console.log" src/ | grep -v "console.log handled" || true
}
```

---

## Quality Gates

### 1. Documentation Gate (PreToolUse)

**Purpose**: Block creation of .md files via Bash tool

**Logic**:
```bash
# Check if Bash tool is creating .md file
check_md_creation() {
  local command="$1"
  if echo "$command" | grep -qiE '\.md|markdown'; then
    echo "⚠️  Use Write tool for .md files, not Bash echo/cat" >&2
    return 1
  fi
}
```

**When to apply**: Before any Bash tool invocation that might create .md files

### 2. Formatting Gate (PostToolUse)

**Purpose**: Auto-format code after changes

**Logic**:
```bash
# Apply formatting based on file type
format_code() {
  local file="$1"
  local ext="${file##*.}"

  case "$ext" in
    js|jsx|ts|tsx|json|css|scss|html|md)
      if command -v prettier &> /dev/null; then
        prettier --write "$file"
      elif command -v npx &> /dev/null; then
        npx prettier --write "$file"
      fi
      ;;
    py)
      if command -v black &> /dev/null; then
        black "$file"
      fi
      ;;
  esac
}
```

**When to apply**: After Edit, Write tool invocations

### 3. Type Safety Gate (PostToolUse)

**Purpose**: Verify type correctness for TypeScript files

**Logic**:
```bash
# Run type check for TypeScript projects
check_types() {
  local project_root="$1"

  if [ -f "$project_root/tsconfig.json" ]; then
    if command -v npx &> /dev/null; then
      npx tsc --noEmit 2>&1 | head -20
    fi
  fi
}
```

**When to apply**: After editing TypeScript files

### 4. Console.log Audit (Stop)

**Purpose**: Flag console.log statements before completion

**Logic**:
```bash
# Find and report console.log statements
audit_logs() {
  local search_dir="${1:-src}"

  echo "🔍 Checking for console.log statements..."
  local logs=$(find "$search_dir" -name "*.ts" -o -name "*.js" | xargs grep -l "console.log" 2>/dev/null || true)

  if [ -n "$logs" ]; then
    echo "⚠️  console.log found in:"
    echo "$logs" | while read file; do
      grep -n "console.log" "$file" | head -5
    done
    echo "  Consider using proper logging library."
  fi
}
```

**When to apply**: Before marking work complete

---

## Integration Points

### Agent Usage

**Coder Agent**:
- Apply PreToolUse check before Bash commands
- Apply PostToolUse formatting after Edit/Write
- Apply PostToolUse type check for .ts files
- Apply Stop audit before completion marker

**All Agents**:
- Respect documentation gate (no .md via Bash)

### Command Integration

**Triggered by**: Hooks.json → Now skill invocation

| Hook Type | Skill Function | Trigger |
|-----------|---------------|---------|
| PreToolUse | check_md_creation | Before Bash |
| PostToolUse | format_code | After Edit/Write |
| PostToolUse | check_types | After .ts file changes |
| Stop | audit_logs | Before completion |

---

## Verification

### Test Quality Gates
```bash
# Test documentation gate
echo "# Test" > test.md 2>&1 | grep -q "Use Write tool"

# Test formatting
echo "const x=1;" > test.js
format_code test.js
grep -q "const x = 1;" test.js  # Should be formatted

# Test type check
echo "const x: string = 1;" > test.ts
check_types .  # Should report type error

# Test console.log audit
echo "console.log('debug');" > src/test.ts
audit_logs src  # Should find console.log
```

---

## Configuration

### Disable Specific Gates

```bash
# Skip formatting for specific file
export SKIP_FORMAT=1

# Skip type check
export SKIP_TYPECHECK=1

# Skip console.log audit
export SKIP_CONSOLE_AUDIT=1
```

### Customize Formatters

```bash
# Use specific formatter
export FORMAT_COMMAND="biome format --write"

# Custom type check command
export TYPECHECK_COMMAND="vue-tsc --noEmit"
```

---

## Related Skills

- **vibe-coding**: Code quality standards (≤50 lines/function, ≤200 lines/file)
- **coding-standards**: TypeScript, React, API, testing standards
- **tdd**: Test-driven development (Red-Green-Refactor)

---

**Version**: claude-pilot 4.3.0
