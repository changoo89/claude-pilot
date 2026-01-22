# Three-Tier Documentation - Reference

> **Complete templates, examples, and verification patterns**

---

## Tier 1: CLAUDE.md Template

**Complete template with all sections**:

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

### Feature Name 1
**Description**: One-line summary

**Key Capabilities**:
- Capability A
- Capability B
- Capability C

**Full Guide**: `@.claude/skills/feature-1/REFERENCE.md`

### Feature Name 2
**Description**: One-line summary

**Configuration**: `export VAR="value"` (default)

**Full Guide**: `@.claude/skills/feature-2/REFERENCE.md`

---

## Documentation

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` + `docs/ai-context/project-structure.md` + `docs/ai-context/docs-overview.md`
- **Tier 2**: `{component}/CONTEXT.md` - Component details
- **Tier 3**: `{feature}/CONTEXT.md` - Feature implementation

**Key Docs**:
- `@docs/ai-context/project-structure.md` - Project structure
- `@docs/ai-context/docs-overview.md` - Documentation navigation

---

## Version & Distribution

**Plugin Version**: X.Y.Z (Latest features)
**Distribution**: GitHub Marketplace (pure plugin)

**Release Process**: `@.claude/commands/999_release.md`

---

**Line Count**: X lines (Target: ≤200 lines) ✅

---

## Version History

### vX.Y.Z (YYYY-MM-DD)
Short summary of major changes

### vX.Y.Z-1 (YYYY-MM-DD)
Short summary of major changes
```

**Content Rules**:
- ≤200 lines (use `wc -l CLAUDE.md` to verify)
- Essential info only
- No implementation details
- Link to CONTEXT.md for component details
- Include version history at bottom

---

## Tier 2: CONTEXT.md Template

**Complete template for component documentation**:

```markdown
# Component Context

> **Purpose**: [One-line description of component's role]

---

## Purpose

[Detailed description of what this component does and why it exists]

**Key Responsibilities**:
- Responsibility 1
- Responsibility 2
- Responsibility 3

---

## Key Files

| File | Purpose | Lines |
|------|---------|-------|
| file1.ts | Description | N |
| file2.ts | Description | N |
| file3.ts | Description | N |

**Total**: N files (N lines)

---

## Common Tasks

### Task 1: Description

**Command**:
```bash
example command
```

**Result**: Expected output or behavior

**See Also**: @.claude/skills/related-skill/REFERENCE.md

### Task 2: Description

**Pattern**:
```typescript
// Code example
```

**Usage**: When to use this pattern

---

## Integration Points

**Depends on**:
- Component A: For X functionality
- Component B: For Y functionality

**Used by**:
- Component C: For Z functionality
- Component D: For W functionality

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

**Line Count**: X lines (Target: ≤100 lines)
```

**Content Rules**:
- ≤100 lines per file
- Component-specific context only
- Usage examples, not implementation
- Integration points for navigation
- Architecture overview, not details

---

## Tier 1 Supplementary: docs/ai-context/ Structure

**Purpose**: Tier 1 supplementary documents (forms Tier 1 together with CLAUDE.md)

**Allowed files** (2 files only):
```
docs/ai-context/
├── project-structure.md      # Project structure, tech stack, file tree
└── docs-overview.md          # Documentation architecture, Tier mapping, component references
```

**Migration**: Existing ai-context files moved to each component's CONTEXT.md/REFERENCE.md:
- agent-ecosystem.md → `@.claude/agents/CONTEXT.md`
- codex-integration.md → `@.claude/skills/gpt-delegation/REFERENCE.md`
- mcp-servers.md → `@.claude/commands/setup.md`
- system-integration.md → `@.claude/commands/CONTEXT.md`
- cicd-integration.md → `@.claude/commands/999_release.md`

**Template**:
```markdown
# Feature/System Name

> **Purpose**: Detailed guide for [feature/system]
> **Audience**: Claude needing deep understanding

---

## Overview

[Comprehensive explanation of the feature/system]

---

## Architecture

**Components**:
- Component A: Role and responsibilities
- Component B: Role and responsibilities

**Data Flow**:
```
Step 1 → Step 2 → Step 3 → Result
```

---

## Configuration

**Required**:
```bash
export VAR1="value1"
export VAR2="value2"
```

**Optional**:
```bash
export VAR3="value3"  # Default: default_value
```

---

## Usage Examples

### Example 1: Common Use Case

**Setup**:
```bash
# Setup commands
```

**Execution**:
```bash
# Execution commands
```

**Expected Output**:
```
Output example
```

### Example 2: Advanced Use Case

[Similar structure]

---

## Troubleshooting

### Issue 1: Description

**Symptoms**: How to recognize this issue

**Cause**: Why this happens

**Solution**:
```bash
# Fix commands
```

---

## Integration

**Integrates with**:
- System A: How it integrates
- System B: How it integrates

**Extension Points**:
- Point A: How to extend
- Point B: How to extend

---

## Best Practices

1. **Practice 1**: Explanation and rationale
2. **Practice 2**: Explanation and rationale
3. **Practice 3**: Explanation and rationale

---

## Further Reading

**Internal**:
- @.claude/skills/related-skill/SKILL.md
- @.claude/commands/CONTEXT.md

**External**:
- [External Resource 1](url)
- [External Resource 2](url)
```

**No line limit** - This is for comprehensive documentation

---

## Verification Patterns

### Line Count Verification

```bash
# Verify CLAUDE.md
lines=$(wc -l < CLAUDE.md)
if [ "$lines" -le 200 ]; then
  echo "✓ CLAUDE.md: $lines lines (≤200)"
else
  echo "✗ CLAUDE.md: $lines lines (>200) - Too long!"
  exit 1
fi

# Verify all CONTEXT.md files
find . -name "CONTEXT.md" -type f | while read -r file; do
  lines=$(wc -l < "$file")
  if [ "$lines" -le 100 ]; then
    echo "✓ $file: $lines lines (≤100)"
  else
    echo "✗ $file: $lines lines (>100) - Too long!"
    exit 1
  fi
done
```

### Cross-Reference Validation

```bash
# Extract all @.claude/ and @docs/ references
grep -roh '@[^/]*\(/[^)]*\)*' --include="*.md" . | sort -u | while read -r ref; do
  # Convert @ to absolute path
  path="${ref/@/}"

  if [ -e "$path" ]; then
    echo "✓ Reference exists: $ref"
  else
    echo "✗ Broken reference: $ref → $path"
    exit 1
  fi
done
```

### Frontmatter Validation

```bash
# Validate SKILL.md frontmatter
check_skill_frontmatter() {
  local file="$1"

  # Check for frontmatter block
  if ! head -n 1 "$file" | grep -q "^---$"; then
    echo "✗ Missing frontmatter: $file"
    return 1
  fi

  # Extract frontmatter
  frontmatter=$(sed -n '1,/^---$/p' "$file" | sed '1d;$d')

  # Check required fields
  if ! echo "$frontmatter" | grep -q "^name:"; then
    echo "✗ Missing 'name' field: $file"
    return 1
  fi

  if ! echo "$frontmatter" | grep -q "^description:"; then
    echo "✗ Missing 'description' field: $file"
    return 1
  fi

  echo "✓ Valid frontmatter: $file"
  return 0
}

# Run on all SKILL.md files
find .claude/skills -name "SKILL.md" -type f | while read -r file; do
  check_skill_frontmatter "$file"
done
```

---

## Migration Examples

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
**Description**: One-line summary

**Full Guide**: `@.claude/skills/feature-a/REFERENCE.md`
```

.claude/skills/feature-a/REFERENCE.md:
```markdown
# Feature A - Reference

[50+ lines of detailed explanation]
```

### CONTEXT.md Too Long (>100 lines)

**Before** (150 lines):
```markdown
# Component Context

[50 lines of purpose and files]

## Common Tasks

[100 lines of detailed examples]
```

**After** (80 lines + updates):

CONTEXT.md:
```markdown
# Component Context

[50 lines of purpose and files]

## Common Tasks

### Task 1
**Command**: `example`
**See Also**: @.claude/skills/component/REFERENCE.md
```

.claude/skills/component/REFERENCE.md:
```markdown
# Component - Reference

[Detailed examples moved here]
```

---

## Best Practices

### DO

- Keep CLAUDE.md focused on architecture and quick start
- Use CONTEXT.md for component navigation
- Put detailed guides in docs/ai-context/
- Verify line counts before committing
- Use absolute paths for cross-references (@.claude/, @docs/)
- Include version numbers in CLAUDE.md
- Add "Further Reading" sections to link tiers

### DON'T

- Don't put implementation details in CLAUDE.md
- Don't duplicate content across tiers
- Don't use relative paths in cross-references
- Don't skip frontmatter in skills/agents
- Don't exceed line limits without extraction
- Don't forget to update version history

---

**Version**: claude-pilot 4.4.11
