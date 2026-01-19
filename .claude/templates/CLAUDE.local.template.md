# {Your Project Name} - Project Documentation

> **Last Updated**: {YYYY-MM-DD}
> **Purpose**: Project-specific configuration, structure, and standards
> **Plugin**: claude-pilot 4.2.0+

---

## Project Configuration

```yaml
---
# Project Configuration
continuation_level: normal  # aggressive | normal | polite
coverage_threshold: 80      # Overall coverage target
core_coverage_threshold: 90 # Core modules coverage target
max_iterations: 7            # Max Ralph Loop iterations
testing_framework: {pytest|jest|go test|cargo test}
type_check_command: {tsc --noEmit|mypy|typecheck}
lint_command: {eslint|ruff|gofmt|lint}
---
```

---

## Quick Reference

### Installation

```bash
# Clone and setup
git clone {repo_url}
cd {project_name}

# Install plugin (if not already)
/plugin marketplace add changoo89/claude-pilot
/plugin install claude-pilot
/pilot:setup

# Create this file (if not already)
cp .claude/templates/CLAUDE.local.template.md ./CLAUDE.local.md
```

### Common Commands

| Task | Command |
|------|---------|
| Plan feature | `/00_plan "implement user auth"` |
| Execute plan | `/02_execute` |
| Continue work | `/00_continue` |
| Review code | `/review` |
| Update docs | `/document` |
| Close plan | `/03_close` |

---

## Project Structure

```
{project_name}/
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Project documentation
├── .claude/                # Claude Code plugin files (gitignored)
├── CLAUDE.local.md         # This file (gitignored)
└── README.md               # Project README
```

---

## Testing Strategy

**Coverage Targets**:
- Overall: 80%
- Core Modules: 90%
- UI Components: 70%

**Test Command**: `{pytest|npm test|go test ./...|cargo test}`

**Test Structure**:
- Unit tests: `tests/unit/`
- Integration tests: `tests/integration/`
- E2E tests: `tests/e2e/`

---

## Quality Standards

**Code Quality Gates**:
- Functions: ≤50 lines
- Files: ≤200 lines
- Nesting: ≤3 levels

**Pre-commit Hooks**:
- Type check: `{type_check_command}`
- Lint: `{lint_command}`
- Tests: `{testing_framework}`

---

## MCP Servers

**Project-Specific MCPs**:
```json
{
  "mcpServers": {
    "context7": { ... },
    "{project_specific_mcp}": { ... }
  }
}
```

---

## Documentation Conventions

**3-Tier Hierarchy**:
- **Tier 1**: This file - Project standards
- **Tier 2**: `docs/ai-context/*.md` - System integration
- **Tier 3**: `{component}/CONTEXT.md` - Component details

**When to Update**:
- After feature implementation: `/document`
- After architecture changes: Manual update
- After adding new components: `/setup {component}`

---

## Pre-Commit Checklist

- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Documentation updated
- [ ] No secrets included

---

## Common Use Cases

### Use Case 1: Aggressive Mode (Fast Iteration)

```yaml
continuation_level: aggressive
max_iterations: 3
```

**When**: Rapid prototyping, time-critical features

### Use Case 2: Strict Quality (Production-Ready)

```yaml
coverage_threshold: 90
core_coverage_threshold: 95
continuation_level: polite
```

**When**: Production releases, security-sensitive features

### Use Case 3: Codex Disabled (Local-Only)

```yaml
# Remove codex from MCP servers in mcp.json
# No special config needed
```

**When**: Offline development, privacy requirements

---

## Customization Examples

### Example 1: Web Application

```yaml
testing_framework: jest
type_check_command: tsc --noEmit
lint_command: eslint
```

### Example 2: Python Service

```yaml
testing_framework: pytest
type_check_command: mypy
lint_command: ruff
```

### Example 3: Go Microservice

```yaml
testing_framework: go test ./...
type_check_command: (none - Go is typed)
lint_command: gofmt -l .
```

---

## Related Documentation

### Plugin Documentation
- **@CLAUDE.md** - Plugin architecture and features
- **@docs/ai-context/system-integration.md** - CLI workflow
- **@docs/ai-context/project-structure.md** - Plugin directory layout

### Project Documentation
- `README.md` - Project overview
- `docs/` - Detailed project documentation

---

**Template Version**: 1.0
**Plugin**: claude-pilot 4.2.0+
