# Three-Tier Documentation - Reference

> **Complete templates, examples, and verification patterns**

---

## Tier 1: CLAUDE.md Template

```markdown
# project-name

> **Version**: X.Y.Z | **Last Updated**: YYYY-MM-DD

---

## Quick Start

```bash
/install/command
/usage/example
```

---

## Plugin Architecture

**Pure Plugin**: No Python dependency, native Claude Code integration

**Core Features**:
- **Feature 1**: Description with key benefits
- **Feature 2**: Description with key benefits
- **Feature 3**: Description with key benefits

**Workflow**: Plan → Confirm → Execute → Review → Document → Close

---

## Plugin Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Commands | Slash commands (N) | `.claude/commands/` |
| Skills | TDD, Ralph Loop, etc | `.claude/skills/` |
| Agents | Specialized roles (N) | `.claude/agents/` |

**Plugin Directory**: `@docs/ai-context/project-structure.md`

---

## Key Features

### Feature Name
**Description**: One-line summary

**Key Capabilities**:
- Capability A
- Capability B

**Full Guide**: `@.claude/skills/feature/REFERENCE.md`

---

## Documentation

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` + `project-structure.md` + `docs-overview.md`
- **Tier 2**: `{component}/CONTEXT.md` - Component details
- **Tier 3**: `{feature}/CONTEXT.md` - Feature implementation

---

## Version & Distribution

**Plugin Version**: X.Y.Z (Latest features)
**Distribution**: GitHub Marketplace (pure plugin)

---

**Line Count**: X lines (Target: ≤200 lines) ✅

---

## Version History

### vX.Y.Z (YYYY-MM-DD)
Short summary of major changes
```

**Content Rules**: ≤200 lines, essential info only, no implementation details, link to CONTEXT.md

---

## Tier 2: CONTEXT.md Template

```markdown
# Component Context

> **Purpose**: [One-line description]

---

## Purpose

[Detailed description]

**Key Responsibilities**:
- Responsibility 1
- Responsibility 2

---

## Key Files

| File | Purpose | Lines |
|------|---------|-------|
| file1.ts | Description | N |
| file2.ts | Description | N |

**Total**: N files (N lines)

---

## Common Tasks

### Task 1: Description

**Command**:
```bash
example command
```

**Result**: Expected output

**See Also**: @.claude/skills/related-skill/REFERENCE.md

---

## Integration Points

**Depends on**: Component A (for X), Component B (for Y)

**Used by**: Component C (for Z), Component D (for W)

---

## Architecture

**Flow**:
```
Input → Component A → Component B → Output
```

**Key Decisions**:
- Decision 1: Rationale
- Decision 2: Rationale

---

**Line Count**: X lines (Target: ≤200 lines)
```

**Content Rules**: ≤200 lines, component-specific context, usage examples not implementation, integration points, architecture overview

---

## Tier 1 Supplementary: docs/ai-context/

**Purpose**: Tier 1 supplementary documents (forms Tier 1 with CLAUDE.md)

**Allowed files** (2 only):
```
docs/ai-context/
├── project-structure.md  # Project structure, tech stack, file tree
└── docs-overview.md      # Documentation architecture, Tier mapping
```

**Migration Map**:
| Old File | New Location |
|----------|--------------|
| agent-ecosystem.md | `@.claude/agents/CONTEXT.md` |
| codex-integration.md | `@.claude/skills/gpt-delegation/REFERENCE.md` |
| mcp-servers.md | `@.claude/commands/setup.md` |
| system-integration.md | `@.claude/commands/CONTEXT.md` |
| cicd-integration.md | `@.claude/commands/999_release.md` |

---

## Verification Patterns

### Line Count Verification

```bash
# Verify CLAUDE.md
lines=$(wc -l < CLAUDE.md)
if [ "$lines" -le 200 ]; then
  echo "✓ CLAUDE.md: $lines lines (≤200)"
else
  echo "✗ CLAUDE.md: $lines lines (>200)"
  exit 1
fi

# Verify all CONTEXT.md files
find . -name "CONTEXT.md" -type f | while read -r file; do
  lines=$(wc -l < "$file")
  [ "$lines" -le 200 ] && echo "✓ $file: $lines" || { echo "✗ $file: $lines"; exit 1; }
done
```

### Cross-Reference Validation

```bash
# Extract and validate all @.claude/ and @docs/ references
grep -roh '@[^/]*\(/[^)]*\)*' --include="*.md" . | sort -u | while read -r ref; do
  path="${ref/@/}"
  [ -e "$path" ] && echo "✓ $ref" || { echo "✗ Broken: $ref"; exit 1; }
done
```

### Frontmatter Validation

```bash
check_skill_frontmatter() {
  local file="$1"
  head -n 1 "$file" | grep -q "^---$" || { echo "✗ Missing frontmatter: $file"; return 1; }

  frontmatter=$(sed -n '1,/^---$/p' "$file" | sed '1d;$d')
  echo "$frontmatter" | grep -q "^name:" || { echo "✗ Missing 'name': $file"; return 1; }
  echo "$frontmatter" | grep -q "^description:" || { echo "✗ Missing 'description': $file"; return 1; }

  echo "✓ Valid: $file"
}

find .claude/skills -name "SKILL.md" -type f | while read -r file; do
  check_skill_frontmatter "$file"
done
```

---

## Migration Example

### CLAUDE.md Too Long (>200 lines)

**Before** (250 lines):
```markdown
# project-name

[200 lines of content]

## Detailed Feature A
[50 lines of detailed explanation]
```

**After** (180 lines + new doc):

CLAUDE.md:
```markdown
# project-name

[180 lines of essential content]

## Key Features

### Feature A
**Full Guide**: `@.claude/skills/feature-a/REFERENCE.md`
```

.claude/skills/feature-a/REFERENCE.md:
```markdown
# Feature A - Reference

[50+ lines of detailed explanation]
```

---

## Best Practices

### DO

- Keep CLAUDE.md focused on architecture and quick start
- Use CONTEXT.md for component navigation
- Put detailed guides in REFERENCE.md
- Verify line counts before committing
- Use absolute paths (@.claude/, @docs/)
- Include version numbers in CLAUDE.md
- Add "Further Reading" sections

### DON'T

- Don't put implementation details in CLAUDE.md
- Don't duplicate content across tiers
- Don't use relative paths
- Don't skip frontmatter in skills/agents
- Don't exceed line limits without extraction
- Don't forget version history

---

**Version**: claude-pilot 4.4.11
