# Claude Code Official Documentation Standards Mapping

> **Generated**: 2026-01-18
> **Source**: Claude Code official documentation
> **Purpose**: Map current project documentation against official standards

## Official Claude Code Documentation Standards

### CLAUDE.md Standards

| Standard | Requirement | Current Status | Gap |
|----------|-------------|----------------|-----|
| **Length** | < 300 lines recommended | 433 lines | ⚠️ Exceeds by 133 lines |
| **Content** | Universally applicable instructions | Mixed with task-specific | ⚠️ Needs progressive disclosure |
| **Code Style** | Anti-pattern: use linters/hooks instead | Contains style guidelines | ⚠️ Must remove |
| **Structure** | 3-Tier system recommended | Partially implemented | ✅ Good foundation |

### 3-Tier Documentation System

| Tier | Purpose | Location | Standard |
|------|---------|----------|----------|
| **Tier 1** | Project-specific standards | `CLAUDE.md` (root) | < 300 lines |
| **Tier 2** | System integration context | `docs/ai-context/` | Detailed technical docs |
| **Tier 3** | Component-specific context | `CONTEXT.md` in directories | Component-level rules |

### Progressive Disclosure Pattern

**Principle**: Keep task-specific instructions in separate files, use pointers in CLAUDE.md

**Implementation**:
- Root CLAUDE.md: Essential, universally applicable instructions
- Directory CONTEXT.md: Component-specific patterns and rules
- Detailed guides: docs/ai-context/ for comprehensive documentation

**Benefits**:
- Reduces cognitive load on Claude
- Easier to maintain and update
- Better instruction following

### CONTEXT.md Standards

| Standard | Requirement |
|----------|-------------|
| **Purpose** | Directory/table of contents for component |
| **Location** | Every major `.claude/` subdirectory |
| **Content** | Component overview, file descriptions, cross-references |
| **Syntax** | Use `@` syntax for cross-references |

### Cross-Reference Standards

| Syntax | Usage | Example |
|--------|-------|---------|
| `@path/file.md` | Reference other documentation files | `@.claude/skills/tdd/SKILL.md` |
| `@.claude/guides/name` | Reference guide directories | `@.claude/guides/test-environment` |

### Anti-Patterns to Avoid

| Anti-Pattern | Why | Alternative |
|--------------|-----|-------------|
| **Code style in CLAUDE.md** | Use linters/hooks instead | `@.claude/hooks.json`, `.eslintrc` |
| **Excessive length** | Claude may ignore instructions | Progressive disclosure |
| **Flat structure** | Hard to navigate | 3-Tier system |
| **Duplicate content** | Maintenance burden | Single source of truth |

### File Size Recommendations

| File Type | Recommended | Maximum |
|-----------|-------------|---------|
| **CLAUDE.md** | < 300 lines | 300 lines (hard limit) |
| **CONTEXT.md** | < 200 lines | 400 lines |
| **SKILL.md** | < 100 lines | 150 lines |
| **REFERENCE.md** | < 500 lines | 800 lines |
| **Command docs** | < 400 lines | 600 lines |
| **Guide docs** | < 500 lines | 800 lines |

## Current Project Compliance Assessment

### Overall Compliance Score: 65%

| Category | Compliance | Notes |
|----------|------------|-------|
| **CLAUDE.md Length** | ❌ 0% | 433 lines vs 300 limit |
| **3-Tier System** | ✅ 90% | Well-structured hierarchy |
| **CONTEXT.md Coverage** | ⚠️ 70% | Some directories missing |
| **Progressive Disclosure** | ⚠️ 60% | Some task-specific in root |
| **Code Style Anti-Pattern** | ❌ 0% | Style guidelines in CLAUDE.md |
| **Cross-Reference Syntax** | ✅ 85% | Good @ syntax usage |
| **File Size Limits** | ⚠️ 50% | Many files exceed limits |

### Specific Gaps Identified

1. **CLAUDE.md Length Violation** (Priority 1)
   - Current: 433 lines
   - Target: < 300 lines
   - Action: Remove 133+ lines via progressive disclosure

2. **Code Style Guidelines** (Priority 1)
   - Location: CLAUDE.md sections on Vibe Coding
   - Action: Move to linter configuration or separate guide

3. **CONTEXT.md Missing** (Priority 2)
   - Directories needing CONTEXT.md:
     - `.claude/skills/external/`
     - `.claude/scripts/hooks/`
     - `.claude/scripts/`

4. **File Size Exceedances** (Priority 2)
   - 30+ files exceed 500 lines
   - 4 files exceed 1000 lines
   - Action: Split large files into modules

5. **Cross-Reference Inconsistencies** (Priority 3)
   - Some references use relative paths
   - Action: Standardize to @ syntax

## Official Best Practices

### CLAUDE.md Structure (Recommended)

```markdown
# Project Name CLAUDE.md

## Quick Start
[3-line installation + essential command]

## Workflow Commands
[Table of key commands]

## Core Principles
[3-5 essential principles]

## 3-Tier Documentation
[Pointer to docs/ai-context/]

## Related Documentation
[@ syntax cross-references]
```

### CONTEXT.md Template

```markdown
# [Component Name] Context

## Purpose
[What this component does]

## Files
| File | Purpose |
|------|---------|
| file.md | Description |

## Cross-References
- @docs/ai-context/system-integration.md
- @.claude/guides/relevant-guide.md

## Component-Specific Rules
[Any special patterns or rules]
```

### Nested CLAUDE.md Pattern

**Supported**: Directory-specific CLAUDE.md for component-level rules

**Use Cases**:
- `.claude/commands/CLAUDE.md` - Command-specific patterns
- `.claude/agents/CLAUDE.md` - Agent-specific rules
- `.claude/skills/CLAUDE.md` - Skill-specific standards

**Benefits**:
- Scoped context for that directory
- Reduces root CLAUDE.md length
- Easier to maintain component-specific rules

## Migration Path

### Phase 1: Reduce CLAUDE.md (Priority 1)
1. Extract code style guidelines → separate file or linter config
2. Move detailed guides → docs/ai-context/
3. Add progressive disclosure pointers
4. Target: < 300 lines

### Phase 2: Standardize CONTEXT.md (Priority 2)
1. Create CONTEXT.md template
2. Add CONTEXT.md to missing directories
3. Standardize cross-references (@ syntax)
4. Target: 100% coverage

### Phase 3: Split Large Files (Priority 2)
1. Identify files > 500 lines
2. Split into thematic modules
3. Add cross-references between modules
4. Target: All files < recommended limits

### Phase 4: Verification (Priority 3)
1. Validate all @ references resolve
2. Check content preservation
3. Test with real Claude tasks
4. Target: 100% compliance

## Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| CLAUDE.md length | < 300 lines | `wc -l CLAUDE.md` |
| CONTEXT.md coverage | 100% | All major dirs have CONTEXT.md |
| File size compliance | 90%+ | Files within recommended limits |
| Code style removal | Complete | No style guidelines in CLAUDE.md |
| Cross-reference integrity | 100% | All @ references resolve |
| Content preservation | 100% | Zero information loss |

## References

- Claude Code official documentation (web source)
- 3-Tier Documentation System guide
- Progressive Disclosure pattern documentation
- CONTEXT.md best practices
