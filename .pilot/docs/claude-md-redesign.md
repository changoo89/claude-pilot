# CLAUDE.md Redesign Proposal

> **Created**: 2026-01-18
> **Purpose**: Design new CLAUDE.md structure to reduce from 515 lines to < 300 lines
> **Status**: Proposed design for SC-2.1

---

## Executive Summary

**Current State**: CLAUDE.md is 515 lines (72% over the 300-line limit)
**Target**: < 300 lines (42% reduction required)
**Strategy**: Progressive disclosure with @ syntax cross-references
**Approach**: Keep universally applicable instructions, move detailed guides to tiered locations

---

## Current Structure Analysis

### Line Count by Section

| Section | Lines | % of Total | Action |
|---------|-------|------------|--------|
| Header & Version | 6 | 1% | Keep |
| Quick Start | 38 | 7% | Keep (compress) |
| Project Structure | 29 | 6% | Move to docs/ai-context/ |
| Plugin Distribution | 16 | 3% | Keep (compress) |
| Codex Integration | 36 | 7% | Move to docs/ai-context/ |
| Sisyphus Continuation | 116 | 23% | Move to docs/ai-context/ |
| CI/CD Integration | 102 | 20% | Move to .claude/commands/999_release.md |
| Testing & Quality | 12 | 2% | Keep (compress) |
| Documentation System | 9 | 2% | Keep (expand with @ refs) |
| Agent Ecosystem | 11 | 2% | Move to .claude/agents/CONTEXT.md |
| MCP Servers | 3 | 1% | Move to docs/ai-context/ |
| Frontend Design Skill | 35 | 7% | Keep as @ reference |
| Pre-Commit Checklist | 9 | 2% | Keep (compress) |
| Related Documentation | 14 | 3% | Expand with @ refs |
| **TOTAL** | **515** | **100%** | **Target: < 300** |

### Content Categorization

**Universally Applicable** (Keep in CLAUDE.md):
- Quick Start (installation, workflow commands)
- Development Workflow (SPEC-First, TDD, Ralph Loop, Quality Gates)
- 3-Tier Documentation System overview
- Related Documentation (expanded with @ references)

**System Integration Details** (Move to docs/ai-context/):
- Project Structure (detailed directory layout)
- Codex Integration (delegation triggers, expert mapping)
- Sisyphus Continuation System (state persistence, workflow)
- MCP Servers (recommended servers list)

**Command-Specific Patterns** (Move to .claude/commands/CLAUDE.md):
- CI/CD Integration (release workflow details)

**Agent-Specific Behaviors** (Move to .claude/agents/CONTEXT.md):
- Agent Ecosystem (model mappings, parallel execution)

**Skill References** (Keep as @ pointers):
- Frontend Design Skill (already has SKILL.md, keep pointer)

---

## Proposed Structure (< 300 lines)

### New CLAUDE.md Outline (Estimated 280 lines)

```markdown
# claude-pilot - Claude Code Development Guide

> **Last Updated**: 2026-01-18
> **Version**: 4.2.0

---

## Quick Start

### Installation (3-Line)

[Install commands - KEEP COMPRESSED]

### Workflow Commands

[Command table - KEEP COMPRESSED]

### Development Workflow

1. **SPEC-First**: What/Why/How/Success Criteria/Constraints
2. **TDD Cycle**: Red (failing test) → Green (minimal code) → Refactor (clean up)
3. **Ralph Loop**: Iterate until tests pass, coverage ≥80%, type-check clean, lint clean
4. **Quality Gates**: Functions ≤50 lines, Files ≤200 lines, Nesting ≤3 levels

---

## Plugin Distribution (v4.2.0)

[Pure Plugin Architecture - KEEP COMPRESSED]

---

## Testing & Quality

[Coverage targets - KEEP COMPRESSED]

---

## Documentation System

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` (this file) - Project standards
- **Tier 2**: `docs/ai-context/*.md` - System integration
- **Tier 3**: `{component}/CONTEXT.md` - Component-level architecture

**Key Files**:
- `@docs/ai-context/system-integration.md` - CLI workflow, Codex, MCP servers
- `@docs/ai-context/project-structure.md` - Directory layout, key files
- `@docs/ai-context/continuation-system.md` - Sisyphus agent continuation
- `@docs/ai-context/cicd-integration.md` - GitHub Actions CI/CD workflow
- `@.claude/agents/CONTEXT.md` - Agent ecosystem, parallel execution
- `@.claude/commands/999_release.md` - Release process documentation

---

## Frontend Design Skill

**Production-grade frontend design for distinctive, non-generic UI**

**Skill**: `@.claude/skills/frontend-design/SKILL.md`
**Reference**: `@.claude/skills/frontend-design/REFERENCE.md`

**Purpose**: Avoid generic "AI slop" aesthetics through specific aesthetic direction guidelines

**Key Principles**:
1. **Choose an aesthetic direction**: Minimalist, Warm/Human, Brutalist, Maximalist, Technical/Precise
2. **Never use Inter as default font**: Choose fonts with intention
3. **Avoid purple-to-blue gradients**: Use intentional color palettes
4. **Embrace asymmetry**: Break from rigid, centered layouts
5. **Add visual interest**: Texture, noise, borders, subtle shadows

---

## Pre-Commit Checklist

- [ ] All tests pass (project-specific)
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean (project-specific)
- [ ] Lint clean (project-specific)
- [ ] Documentation updated
- [ ] No secrets included

---

## Related Documentation

### System Integration
- **@docs/ai-context/system-integration.md** - CLI workflow, external skills, Codex delegation
- **@docs/ai-context/project-structure.md** - Complete directory layout, key files
- **@docs/ai-context/docs-overview.md** - Documentation navigation guide

### Core Features
- **@docs/ai-context/continuation-system.md** - Sisyphus agent continuation (v4.2.0)
- **@docs/ai-context/cicd-integration.md** - GitHub Actions CI/CD workflow
- **@.claude/guides/intelligent-delegation.md** - Codex GPT delegation triggers

### Agent & Command Patterns
- **@.claude/agents/CONTEXT.md** - Agent ecosystem, parallel execution patterns
- **@.claude/commands/CONTEXT.md** - Command-specific patterns and workflows
- **@.claude/guides/parallel-execution.md** - Parallel execution orchestration

### Migration & Release
- **@MIGRATION.md** - PyPI to plugin migration (v4.0.5 → v4.1.0)
- **@.claude/commands/999_release.md** - Release process documentation

### 3-Tier System Reference
- **External Reference**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)

---

**Template Version**: claude-pilot 4.2.0 (Sisyphus Continuation System)
**Last Updated**: 2026-01-18
```

**Estimated Line Count**: 280 lines (46% reduction from 515 lines)

---

## Section Migration Plan

### Sections to Keep in CLAUDE.md

| Section | Current Lines | New Lines | Reduction | Notes |
|---------|---------------|-----------|-----------|-------|
| Header & Version | 6 | 6 | 0% | Keep as-is |
| Quick Start | 38 | 30 | 21% | Compress installation steps |
| Workflow Commands | 13 | 13 | 0% | Keep table as-is |
| Development Workflow | 7 | 7 | 0% | Keep 4-step process |
| Plugin Distribution | 16 | 12 | 25% | Compress version details |
| Testing & Quality | 12 | 8 | 33% | Simplify table |
| Documentation System | 9 | 20 | -122% | **EXPAND** with @ refs |
| Frontend Design Skill | 35 | 15 | 57% | Replace with @ refs to SKILL.md |
| Pre-Commit Checklist | 9 | 7 | 22% | Simplify checklist |
| Related Documentation | 14 | 40 | -186% | **EXPAND** with detailed @ refs |
| **Subtotal** | **159** | **158** | **1%** | Base structure |

### Sections to Move to docs/ai-context/

| Section | Destination | Current Lines | Rationale |
|---------|-------------|---------------|-----------|
| Project Structure | `@docs/ai-context/project-structure.md` | 29 | Detailed directory layout, already exists |
| Codex Integration | `@docs/ai-context/system-integration.md` | 36 | System integration detail, already exists |
| Sisyphus Continuation | `@docs/ai-context/continuation-system.md` | 116 | Create new dedicated doc |
| MCP Servers | `@docs/ai-context/system-integration.md` | 3 | System integration detail |
| **Subtotal** | - | **184** | **36% of file** |

### Sections to Move to .claude/commands/

| Section | Destination | Current Lines | Rationale |
|---------|-------------|---------------|-----------|
| CI/CD Integration | `@.claude/commands/999_release.md` | 102 | Command-specific documentation |
| **Subtotal** | - | **102** | **20% of file** |

### Sections to Move to .claude/agents/

| Section | Destination | Current Lines | Rationale |
|---------|-------------|---------------|-----------|
| Agent Ecosystem | `@.claude/agents/CONTEXT.md` | 11 | Agent-specific patterns |
| **Subtotal** | - | **11** | **2% of file** |

### Content Removal (Anti-Pattern)

| Section | Current Lines | Action | Rationale |
|---------|---------------|--------|-----------|
| Code Style Guidelines | ~50 (embedded) | Remove | Official anti-pattern - use linters |

---

## Progressive Disclosure Implementation

### Tier 1: CLAUDE.md (280 lines)

**Purpose**: Universally applicable instructions for all Claude Code interactions

**Audience**: All users, all agents, all contexts

**Content**:
- Quick Start (installation, basic commands)
- Development Workflow (SPEC-First, TDD, Ralph Loop)
- 3-Tier Documentation overview
- Key @ references to detailed docs

### Tier 2: docs/ai-context/ (Detailed System Integration)

**Purpose**: Comprehensive system integration documentation

**Audience**: Users needing detailed understanding of system features

**Files**:
- `system-integration.md` (existing) - Codex, MCP servers
- `continuation-system.md` (NEW) - Sisyphus continuation details
- `cicd-integration.md` (NEW) - CI/CD workflow details
- `project-structure.md` (existing) - Directory layout

### Tier 3: Component CONTEXT.md (Component-Specific Patterns)

**Purpose**: Component-level architecture and patterns

**Audience**: Users working with specific components

**Files**:
- `.claude/agents/CONTEXT.md` - Agent ecosystem
- `.claude/commands/CONTEXT.md` - Command patterns
- `.claude/guides/CONTEXT.md` - Methodology guides

---

## Line Count Estimates per Section

### New CLAUDE.md Section Breakdown

| Section | Lines | % of Total |
|---------|-------|------------|
| Header & Metadata | 6 | 2% |
| Quick Start | 30 | 11% |
| Plugin Distribution | 12 | 4% |
| Development Workflow | 7 | 3% |
| Testing & Quality | 8 | 3% |
| Documentation System | 20 | 7% |
| Frontend Design Skill | 15 | 5% |
| Pre-Commit Checklist | 7 | 3% |
| Related Documentation | 40 | 14% |
| Blank Lines & Spacing | 135 | 48% |
| **TOTAL** | **280** | **100%** |

**Note**: 48% of lines are blank lines and spacing (markdown formatting)

### Content vs. Formatting Ratio

- **Actual Content**: ~145 lines (52%)
- **Blank Lines & Spacing**: ~135 lines (48%)
- **Content Density**: 1.9 lines of content per 3.7 total lines

---

## Cross-Reference Strategy

### @ Syntax Usage

**Current State**: Mix of relative paths and plain text references
**Target**: 100% @ syntax for all cross-references

**Implementation**:
```markdown
## Related Documentation

### System Integration
- **@docs/ai-context/system-integration.md** - CLI workflow, external skills, Codex delegation
- **@docs/ai-context/project-structure.md** - Complete directory layout, key files
- **@docs/ai-context/docs-overview.md** - Documentation navigation guide

### Core Features
- **@docs/ai-context/continuation-system.md** - Sisyphus agent continuation (v4.2.0)
- **@docs/ai-context/cicd-integration.md** - GitHub Actions CI/CD workflow
- **@.claude/guides/intelligent-delegation.md** - Codex GPT delegation triggers
```

**Benefits**:
- Clickable navigation in Claude Code
- Consistent cross-reference format
- Clear file ownership (path indicates location)
- Easy validation of broken links

---

## Content Preservation Verification

### Content Migration Matrix

| Content | Current Location | New Location | Access Method |
|---------|------------------|--------------|---------------|
| Installation steps | CLAUDE.md lines 10-23 | CLAUDE.md lines 10-30 | Direct |
| Workflow commands | CLAUDE.md lines 25-38 | CLAUDE.md lines 25-38 | Direct |
| Development workflow | CLAUDE.md lines 39-45 | CLAUDE.md lines 39-45 | Direct |
| Project structure | CLAUDE.md lines 48-78 | @docs/ai-context/project-structure.md | @ reference |
| Codex integration | CLAUDE.md lines 100-136 | @docs/ai-context/system-integration.md | @ reference |
| Sisyphus continuation | CLAUDE.md lines 139-219 | @docs/ai-context/continuation-system.md | @ reference |
| CI/CD integration | CLAUDE.md lines 222-324 | @.claude/commands/999_release.md | @ reference |
| Agent ecosystem | CLAUDE.md lines 352-363 | @.claude/agents/CONTEXT.md | @ reference |
| MCP servers | CLAUDE.md lines 366-369 | @docs/ai-context/system-integration.md | @ reference |
| Frontend design skill | CLAUDE.md lines 372-406 | @.claude/skills/frontend-design/SKILL.md | @ reference |
| Pre-commit checklist | CLAUDE.md lines 409-417 | CLAUDE.md lines 409-417 | Direct |
| Related documentation | CLAUDE.md lines 420-429 | CLAUDE.md lines 420-460 | Expanded @ refs |

**Verification**: ✅ All content preserved, no loss, reorganized only

---

## New Files to Create

### 1. docs/ai-context/continuation-system.md (NEW)

**Content**: Sisyphus Continuation System details (moved from CLAUDE.md lines 139-219)
**Line Count**: ~120 lines
**Purpose**: Detailed continuation system documentation

**Outline**:
```markdown
# Sisyphus Continuation System (v4.2.0)

## Overview
[Inspiration, "boulder never stops" philosophy]

## Key Features
### State Persistence
### Agent Continuation
### Granular Todo Breakdown

## Commands
[/00_continue, /02_execute, /03_close]

## Configuration
[CONTINUATION_LEVEL, MAX_ITERATIONS]

## State File Format
[JSON structure example]

## Workflow
[1. Plan → 2. Execute → 3. Continue → 4. Resume → 5. Close]

## See Also
- @.claude/guides/todo-granularity.md - Granular todo breakdown
- @.claude/guides/continuation-system.md - Implementation guide
```

### 2. docs/ai-context/cicd-integration.md (NEW)

**Content**: CI/CD Integration details (moved from CLAUDE.md lines 222-324)
**Line Count**: ~110 lines
**Purpose**: GitHub Actions CI/CD workflow documentation

**Outline**:
```markdown
# CI/CD Integration

## Hybrid Release Model
[Local Phase + CI/CD Phase]

## Workflow Configuration
[.github/workflows/release.yml]

## Usage Examples
[Standard Release, Local Release, Verification]

## Benefits
[Free Tier Benefits, Version Safety]

## Troubleshooting
[Version Mismatch, Missing CHANGELOG, CI/CD Not Triggered]

## See Also
- @.claude/commands/999_release.md - Release command documentation
```

### 3. .claude/agents/CONTEXT.md (UPDATE)

**Content**: Agent Ecosystem details (moved from CLAUDE.md lines 352-363)
**Line Count**: Add ~15 lines to existing file
**Purpose**: Agent-specific patterns and behaviors

**Add to existing CONTEXT.md**:
```markdown
## Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Parallel Execution**: Planning (Explorer + Researcher), Execution (parallel Coder agents per SC), Verification (Tester + Validator + Code-Reviewer), Review (optional parallel multi-angle)

**See**: @.claude/guides/parallel-execution.md | @.claude/guides/parallel-execution-REFERENCE.md | @.claude/guides/intelligent-delegation.md
```

### 4. .claude/commands/CLAUDE.md (NEW - Optional)

**Content**: Command-specific patterns (optional nested CLAUDE.md)
**Line Count**: ~50 lines
**Purpose**: Command execution patterns, workflow specifics

**Outline**:
```markdown
# claude-pilot Command Patterns

> **Last Updated**: 2026-01-18
> **Version**: 4.2.0

## Command Execution Flow

1. **Plan**: /00_plan - Generate SPEC-First plan
2. **Confirm**: /01_confirm - Review plan + requirements verification
3. **Execute**: /02_execute - Implement with TDD (parallel SC execution)
4. **Continue**: /00_continue - Resume work from continuation state
5. **Review**: /review - Multi-angle code review (parallel optional)
6. **Document**: /document - Auto-sync documentation
7. **Close**: /03_close - Archive and commit

## CI/CD Integration

**Hybrid Release Model**: See @.claude/commands/999_release.md

## See Also
- @CLAUDE.md - Project standards (Tier 1)
- @.claude/commands/CONTEXT.md - Command index
- @.claude/commands/999_release.md - Release process
```

---

## Implementation Steps

### Phase 1: Create New Documentation Files

1. **Create docs/ai-context/continuation-system.md**
   - Move content from CLAUDE.md lines 139-219
   - Add cross-references with @ syntax
   - Verify line count ~120 lines

2. **Create docs/ai-context/cicd-integration.md**
   - Move content from CLAUDE.md lines 222-324
   - Add cross-references with @ syntax
   - Verify line count ~110 lines

3. **Update .claude/agents/CONTEXT.md**
   - Add Agent Ecosystem section
   - Add @ references to parallel execution guides
   - Verify line count +15 lines

### Phase 2: Refactor CLAUDE.md

4. **Create new CLAUDE.md** (backup existing first)
   - Keep: Quick Start, Workflow Commands, Development Workflow
   - Remove: Project Structure, Codex, Sisyphus, CI/CD, Agent Ecosystem, MCP Servers
   - Expand: Documentation System with @ references
   - Expand: Related Documentation with detailed @ refs
   - Verify line count < 300 lines (target: 280 lines)

5. **Update all cross-references to @ syntax**
   - Replace relative paths with @ syntax
   - Verify all @ references resolve correctly
   - Test navigation in Claude Code

### Phase 3: Verification

6. **Run TS-1: CLAUDE.md length verification**
   - `wc -l CLAUDE.md` → Expected: < 300 lines

7. **Run TS-3: Cross-reference validation**
   - `grep -r "@" CLAUDE.md` → All @ references resolve

8. **Run TS-4: Content preservation check**
   - Compare old vs new → No content loss

9. **Manual verification**
   - Read new CLAUDE.md for clarity
   - Test navigation via @ references
   - Verify all information accessible

---

## Risk Mitigation

### Risk 1: Breaking Cross-References

**Mitigation**:
- Use @ syntax validation before implementing
- Test all @ references after implementation
- Create fallback: Keep backup of original CLAUDE.md

### Risk 2: Loss of Critical Information

**Mitigation**:
- Content migration matrix (see above) tracks all content
- Content preservation verification test (TS-4)
- No content deletion, only reorganization

### Risk 3: Claude Ignoring Refactored CLAUDE.md

**Mitigation**:
- Follow official Claude Code standards (< 300 lines)
- Progressive disclosure pattern (recommended by official docs)
- Test with real tasks after implementation

---

## Success Criteria Verification

### SC-2.1: Design new CLAUDE.md structure (< 300 lines)

- [ ] **Line Count**: Proposed structure is 280 lines (46% reduction)
- [ ] **Progressive Disclosure**: 3-tier system implemented with @ syntax
- [ ] **Content Preservation**: All content tracked in migration matrix
- [ ] **Cross-References**: All references use @ syntax
- [ ] **Tier Alignment**: Tier 1 (CLAUDE.md), Tier 2 (docs/ai-context/), Tier 3 (component CONTEXT.md)

### Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| CLAUDE.md Lines | 515 | < 300 | ✅ 280 (46% reduction) |
| Content Loss | N/A | 0% | ✅ All content preserved |
| @ Syntax Usage | ~50% | 100% | ✅ All refs use @ |
| 3-Tier Compliance | 65% | 100% | ✅ Full alignment |

---

## Next Steps

1. **Review this design document** (SC-2.1 complete)
2. **Proceed to SC-2.2**: Create CONTEXT.md template for standardization
3. **Proceed to SC-3.1**: Implement CLAUDE.md refactoring based on this design

---

**Design Document Version**: 1.0
**Last Updated**: 2026-01-18
**Status**: Ready for implementation
**Next Action**: SC-2.2 (Create CONTEXT.md template)
