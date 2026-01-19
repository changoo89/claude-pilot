# Testing & Quality

> **Last Updated**: 2026-01-19 (Hooks Performance Optimization v4.3.0)
> **Purpose**: Coverage targets and quality standards

---

## Hooks Performance (v4.3.0)

**Optimization Features**:
- **Dispatcher Pattern**: O(1) project type detection (P95: 20ms)
- **Smart Caching**: Config hash-based cache invalidation
- **Gate vs Validator**: Safety checks (PreToolUse) vs quality checks (Stop)
- **Profile System**: User-configurable modes (off/stop/strict)

**Performance Impact**:
- **Before**: 10-25 seconds for 100 file edits
- **After**: 30-60ms for 100 file edits
- **Improvement**: 99.4-99.8% reduction in overhead

**Migration Guide**: `@docs/migration-guide.md`

---

## Coverage Targets

| Scope | Target | Priority |
|-------|--------|----------|
| Overall | 80% | Required |
| Core Modules | 90%+ | Required |
| UI Components | 70%+ | Nice to have |

---

## Test Commands

Project-specific test commands (depends on language/framework):

**Auto-Detection**:
```bash
# Python (pytest)
if [ -f "pyproject.toml" ]; then
    TEST_CMD="pytest"
# JavaScript/TypeScript (npm)
elif [ -f "package.json" ]; then
    TEST_CMD="npm test"
# Go
elif [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
# Rust
elif [ -f "Cargo.toml" ]; then
    TEST_CMD="cargo test"
else
    TEST_CMD="npm test"  # Fallback
fi
```

---

## Pre-Commit Hooks

**Configuration**: `.claude/hooks.json`

**Available Hooks**:
- `pre-commit`: Type check, lint validation
- `pre-push`: Branch guard

**Hook Definitions**:
```json
{
  "pre-commit": [
    {"command": "npm run type-check", "name": "Type Check"},
    {"command": "npm run lint", "name": "Lint"}
  ]
}
```

---

## Quality Gates

Before marking work complete:

- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Documentation updated
- [ ] No secrets included

---

## See Also

- **@.claude/hooks.json** - Hook definitions
- **@.claude/skills/tdd/SKILL.md** - TDD methodology
- **@.claude/skills/ralph-loop/SKILL.md** - Ralph Loop (autonomous iteration)
- **@CLAUDE.md** - Project standards (Tier 1)
