# Templates Directory

Standardized templates for consistent documentation across claude-pilot.

## Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `CONTEXT-template.md` | Standardized CONTEXT.md structure | 95 | Template for new CONTEXT.md files |
| `CONTEXT-usage-guide.md` | Complete usage instructions | 429 | How-to guide for using template |
| `README.md` | This file | - | Templates directory overview |

**Total**: 3 files, 524 lines (average: 175 lines per file)

## Quick Start

### Create New CONTEXT.md

```bash
# 1. Copy template
cp .claude/templates/CONTEXT-template.md .claude/{directory}/CONTEXT.md

# 2. Edit template variables
# Replace all {variables} with actual content

# 3. See usage guide for detailed instructions
cat .claude/templates/CONTEXT-usage-guide.md
```

## Template Features

### CONTEXT-template.md

**Standardized structure**:
- Purpose section
- Key Files table (alphabetical, with line counts)
- Common Tasks section
- Patterns section
- File Organization section
- See Also section (with @ syntax)

**Benefits**:
- Consistency across all CONTEXT.md files
- Quick file discovery
- Line count tracking
- Cross-reference standardization

**Size**: 95 lines (well under 200-line target)

### CONTEXT-usage-guide.md

**Comprehensive documentation**:
- Variable reference
- Section guidelines
- Directory-specific examples
- Cross-reference guidelines
- Quality checklist
- Common pitfalls

**Benefits**:
- Step-by-step instructions
- Real-world examples
- Validation scripts
- Maintenance guidelines

## Template Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{Directory Name}` | Capitalized directory name | "Commands", "Agents" |
| `{items}` | Plural item type | "commands", "agents" |
| `{item}` | Singular item type | "command", "agent" |

See `CONTEXT-usage-guide.md` for complete variable list.

## Section Guidelines

### Purpose Section
**Length**: 2-3 sentences
**Content**: What directory contains and its system role

### Key Files Table
**Requirements**:
- Alphabetical order
- Columns: File, Purpose, Lines, Usage
- Total summary at bottom

### Common Tasks Section
**Format**: Task → File → Output → Process
**Length**: 5-10 tasks

### Patterns Section
**Content**: Reusable patterns, conventions
**Format**: Name → Description → Example → Purpose

### See Also Section
**Requirements**:
- Use @ syntax
- Group by type
- Include descriptions

## Quality Checklist

Before marking CONTEXT.md complete:

- [ ] Purpose section is clear
- [ ] Key Files table is alphabetical
- [ ] Line counts are accurate
- [ ] Total summary included
- [ ] Common Tasks cover main use cases
- [ ] Patterns include examples
- [ ] See Also uses @ syntax
- [ ] File length ≤200 lines

## Examples

### Commands Directory
```markdown
## Key Files

| File | Purpose | Lines | Workflow Phase | Description |
|------|---------|-------|----------------|-------------|
| `00_plan.md` | Create SPEC-First plan | 355 | Planning | Plan generation |
| `01_confirm.md` | Confirm plan + gap detection | 315 | Planning | Requirements verification |

**Total**: 2 commands, 670 lines (average: 335 lines per command)
```

### Agents Directory
```markdown
## Key Agents

| Agent | Model | Lines | Tools | Purpose | Usage |
|-------|-------|-------|-------|---------|-------|
| **explorer** | haiku | 60 | Glob, Grep, Read | Fast exploration | `/00_plan` |
| **coder** | sonnet | 315 | Read, Write, Edit | TDD implementation | `/02_execute` |

**Total**: 2 agents, 375 lines (average: 188 lines per agent)
```

## Cross-Reference Syntax

Use @ syntax for all cross-references:

```markdown
**Related guides**:
- @.claude/guides/prp-framework.md - SPEC-First requirements
- @.claude/guides/test-environment.md - Test framework detection
```

**Always include description** after each link.

## Validation

### Check Required Sections

```bash
required_sections=("Purpose" "Key Files" "Common Tasks" "Patterns" "See Also")
for section in "${required_sections[@]}"; do
  if ! grep -q "^## $section" CONTEXT.md; then
    echo "Missing section: $section"
  fi
done
```

### Verify Line Counts

```bash
# Check line counts match
for f in .claude/{directory}/*.md; do
  echo "$f: $(wc -l < "$f")"
done
```

## Maintenance

### Update CONTEXT.md When:
- Adding new files to directory
- Removing files from directory
- Significant file changes (>50 line difference)
- New patterns established

### Recalculate Line Counts
After adding/removing files or major refactoring.

## See Also

**Template Files**:
- @.claude/templates/CONTEXT-template.md - Standardized template
- @.claude/templates/CONTEXT-usage-guide.md - Complete usage guide

**Existing Examples**:
- @.claude/commands/CONTEXT.md - Commands directory
- @.claude/agents/CONTEXT.md - Agents directory
- @.claude/guides/CONTEXT.md - Guides directory
- @.claude/skills/CONTEXT.md - Skills directory

**Documentation Standards**:
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
