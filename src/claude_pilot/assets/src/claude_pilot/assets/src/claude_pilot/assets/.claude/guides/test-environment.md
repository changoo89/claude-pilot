# Test Environment Detection Guide

## Purpose

Test Environment Detection automatically identifies project type, test framework, and appropriate test commands. This guide explains the detection system and how to use it.

## Detection Priority

> **⚠️ CRITICAL**: Every plan MUST include detected test environment. Do NOT assume `npm run test`.

### 1. Check for Project Type Files

In order of priority:

| File Pattern | Project Type |
|--------------|--------------|
| `pyproject.toml`, `setup.py`, `pytest.ini`, `tox.ini` | Python |
| `package.json` | Node.js |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `*.csproj`, `*.sln` | C#/.NET |
| `pom.xml`, `build.gradle` | Java |

---

## Project Type Configurations

### Python

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| pytest | `pyproject.toml`, `pytest.ini` | `pytest` | `pytest --cov` |
| pytest | `setup.py` | `python -m pytest` | `python -m pytest --cov` |
| unittest | `setup.py` | `python -m unittest` | N/A |

**Test Directory**:
- `tests/`, `test/`
- `*_test.py` files next to source

### Node.js

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| Jest | `package.json` (jest) | `npm test` or `npm run test` | `npm run test:coverage` |
| Vitest | `package.json` (vitest) | `npm run test` | `npm run test:coverage` |
| Mocha | `package.json` (mocha) | `npm test` | `npm run test:coverage` |
| ava | `package.json` (ava) | `npm test` | `npm run test:coverage` |

**Test Directory**:
- `tests/`, `__tests__`
- `*.test.ts`, `*.spec.ts`, `*.test.js`, `*.spec.js`

### Go

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| go test | `go.mod` | `go test ./...` | `go test -cover ./...` |

**Test Directory**:
- `*_test.go` files next to source

### Rust

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| cargo test | `Cargo.toml` | `cargo test` | `cargo test -- --nocapture` |

**Test Directory**:
- `tests/`
- `cfg(test)` modules

### C#/.NET

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| dotnet test | `*.csproj`, `*.sln` | `dotnet test` | `dotnet test --collect:"XPlat Code Coverage"` |

**Test Directory**:
- `*Tests.csproj`
- `*Test.cs` files

### Java

| Test Framework | Files | Test Command | Coverage Command |
|----------------|-------|--------------|------------------|
| JUnit (Maven) | `pom.xml` | `mvn test` | `mvn test jacoco:report` |
| JUnit (Gradle) | `build.gradle` | `gradle test` | `gradle test jacocoTestReport` |

**Test Directory**:
- `src/test/java/`

---

## Detection Function

```bash
DETECT_TEST_CMD() {
    if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        echo "pytest"
    elif [ -f "setup.py" ]; then
        echo "python -m pytest"
    elif [ -f "package.json" ]; then
        # Check if test script exists
        if grep -q '"test"' package.json; then
            echo "npm run test"
        else
            echo "npm test"
        fi
    elif [ -f "go.mod" ]; then
        echo "go test ./..."
    elif [ -f "Cargo.toml" ]; then
        echo "cargo test"
    elif [ -f "pom.xml" ]; then
        echo "mvn test"
    elif [ -f "build.gradle" ]; then
        echo "gradle test"
    else
        echo "npm test"  # Fallback
    fi
}

TEST_CMD=$(DETECT_TEST_CMD)
echo "🧪 Detected test command: $TEST_CMD"
```

---

## Plan Output Format

Every plan must include:

```markdown
## Test Environment (Detected)
- Project Type: Python
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`
```

---

## Fallback Behavior

If no project type detected:

1. Ask user for test command
2. Ask for coverage command
3. Ask for test directory

**Question Template**:
> "Unable to auto-detect test framework. Please specify: test command, coverage command, test directory"

---

## Quick Reference Table

| Project Type | Test Command | Coverage Command | Type Check | Lint |
|--------------|--------------|------------------|------------|------|
| Python (pytest) | `pytest` | `pytest --cov` | `mypy .` | `ruff check .` |
| Node.js (TypeScript) | `npm test` | `npm run test:coverage` | `npx tsc --noEmit` | `npm run lint` |
| Node.js (JavaScript) | `npm test` | `npm run test:coverage` | - | `npm run lint` |
| Go | `go test ./...` | `go test -cover ./...` | - | `golangci-lint run` |
| Rust | `cargo test` | `cargo test` | - | `cargo clippy` |
| C# | `dotnet test` | `dotnet test --collect:"XPlat Code Coverage"` | - | - |
| Java (Maven) | `mvn test` | `mvn test jacoco:report` | - | - |

---

## Type Check & Lint Detection

### Type Check

```bash
# TypeScript (Node.js)
if [ -f "package.json" ] && grep -q "typescript" package.json; then
    echo "Running type check..."; npx tsc --noEmit; TYPE_CHECK_RESULT=$?
# Python (mypy)
elif [ -f "pyproject.toml" ] && grep -q "mypy" pyproject.toml; then
    echo "Running type check..."; mypy .; TYPE_CHECK_RESULT=$?
else
    echo "No type check configured"; TYPE_CHECK_RESULT=0
fi
```

### Lint

```bash
# Node.js (ESLint)
if [ -f "package.json" ] && grep -q '"lint"' package.json; then
    echo "Running lint..."; npm run lint; LINT_RESULT=$?
# Python (ruff)
elif [ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml; then
    echo "Running lint..."; ruff check .; LINT_RESULT=$?
# Go (golangci-lint)
elif [ -f "go.mod" ]; then
    echo "Running lint..."; golangci-lint run; LINT_RESULT=$?
# Rust (clippy)
elif [ -f "Cargo.toml" ]; then
    echo "Running lint..."; cargo clippy; LINT_RESULT=$?
else
    echo "No lint configured"; LINT_RESULT=0
fi
```

---

## See Also

- @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle
- @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop
- @.claude/guides/gap-detection.md - Test Plan Verification (9.7)
