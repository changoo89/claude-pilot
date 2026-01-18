# Test Environment Detection Guide

> **Purpose**: Auto-detect project type, test framework, and commands
> **Full Reference**: @.claude/guides/test-environment-REFERENCE.md

---

## Detection Priority

> **⚠️ CRITICAL**: Every plan MUST include detected test environment. Do NOT assume `npm run test`.

### 1. Check Project Type Files

| File Pattern | Project Type |
|--------------|--------------|
| `pyproject.toml`, `setup.py`, `pytest.ini`, `tox.ini` | Python |
| `package.json` | Node.js |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `*.csproj`, `*.sln` | C#/.NET |
| `pom.xml`, `build.gradle` | Java |

---

## Project Configurations

### Python
| Framework | Command | Coverage |
|----------|---------|----------|
| pytest | `pytest` | `pytest --cov` |
| unittest | `python -m unittest` | N/A |

**Directory**: `tests/`, `test/`

### Node.js
| Framework | Command | Coverage |
|----------|---------|----------|
| Jest | `npm test` | `npm run test:coverage` |
| Vitest | `npm run test` | `npm run test:coverage` |
| Mocha | `npm test` | `npm run test:coverage` |

**Directory**: `tests/`, `__tests__`

### Go
| Command | Coverage |
|---------|----------|
| `go test ./...` | `go test -cover ./...` |

**Directory**: `*_test.go` files next to source

### Rust
| Command | Coverage |
|---------|----------|
| `cargo test` | `cargo test -- --nocapture` |

**Directory**: `tests/`, `cfg(test)` modules

### C#/.NET
| Command | Coverage |
|---------|----------|
| `dotnet test` | `dotnet test --collect:"XPlat Code Coverage"` |

**Directory**: `*Tests.csproj`, `*Test.cs` files

### Java
| Command | Coverage |
|---------|----------|
| `mvn test` | `mvn test jacoco:report` |
| `gradle test` | `gradle test jacocoTestReport` |

**Directory**: `src/test/java/`

---

## Detection Function

**Full function**: @.claude/guides/test-environment-REFERENCE.md#detection-function

**Quick reference**:
1. Check for project type files
2. Match test framework
3. Return appropriate command

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

**Template**:
> "Unable to auto-detect test framework. Please specify: test command, coverage command, test directory"

---

## Quick Reference

| Type | Test Command | Coverage | Type Check | Lint |
|------|-------------|----------|------------|------|
| Python (pytest) | `pytest` | `pytest --cov` | `mypy .` | `ruff check .` |
| Node.js (TS) | `npm test` | `npm run test:coverage` | `npx tsc --noEmit` | `npm run lint` |
| Go | `go test ./...` | `go test -cover ./...` | - | `golangci-lint run` |
| Rust | `cargo test` | `cargo test` | - | `cargo clippy` |
| C# | `dotnet test` | `dotnet test --collect:"XPlat Code Coverage"` | - | - |

---

## See Also

- **@.claude/skills/tdd/SKILL.md** - Red-Green-Refactor cycle
- **@.claude/skills/ralph-loop/SKILL.md** - Autonomous completion loop
- **@.claude/guides/gap-detection.md** - Test Plan Verification (9.7)

---

**Version**: claude-pilot 4.2.0 (Test Environment)
**Last Updated**: 2026-01-19
