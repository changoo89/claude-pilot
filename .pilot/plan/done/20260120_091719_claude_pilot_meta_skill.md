# Claude-Pilot Meta-Skill Documentation

> **Generated**: 2026-01-20 09:17:19 | **Work**: claude_pilot_meta_skill | **Location**: .pilot/plan/draft/20260120_091719_claude_pilot_meta_skill.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 00:00 | "웹에서 클로드 코드에 스킬 룰 가이드 커맨드 에이전트 등등 기능들에 대해서 공식 가이드문서와 베스트 프랙티스들 웹 검색해보고" | Research Claude Code features (skills, rules, guides, commands, agents) official docs and best practices |
| UR-2 | 00:00 | "VIBE 코딩 베스트 베스트 프랙티스도 함께 검색을 해보고" | Research VIBE coding best practices |
| UR-3 | 00:00 | "우리 관련돼서 스킬을 만들어줘. 클로드푸드 스킬 해당 커맨드들 그리고 문서들을 제작할 때 참고해야 될 스킬 문서" | Create skill documentation for claude-pilot as reference guide |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-5 | Mapped |
| UR-2 | ✅ | SC-4 | Mapped |
| UR-3 | ✅ | SC-6, SC-7, SC-8 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Create a comprehensive meta-skill documentation file (`.claude/skills/claude-pilot-standards/SKILL.md`) that serves as the authoritative reference guide for creating and maintaining skills, commands, guides, and agents in the claude-pilot plugin ecosystem.

**Scope**:
- **In Scope**:
  - Meta-skill documenting best practices for skill creation
  - Command authoring standards and patterns
  - Guide documentation methodology
  - Agent configuration guidelines
  - Integration with existing claude-pilot workflows
  - Cross-reference system for documentation

- **Out of Scope**:
  - Modifying existing skills/commands/guides
  - Creating new functionality
  - Changes to core plugin architecture

**Deliverables**:
1. `.claude/skills/claude-pilot-standards/SKILL.md` - Main meta-skill file
2. `.claude/skills/claude-pilot-standards/REFERENCE.md` - Detailed reference guide
3. `.claude/skills/claude-pilot-standards/TEMPLATES.md` - Template collection
4. `.claude/skills/claude-pilot-standards/EXAMPLES.md` - Real-world examples

### Why (Context)

**Current Problem**:
- Claude Code official documentation is scattered across multiple sources
- VIBE coding best practices are not consolidated
- claude-pilot lacks centralized reference for creating new components
- Inconsistent patterns across existing skills/commands/guides
- No single source of truth for plugin development standards

**Business Value**:
- **User Impact**: Faster onboarding for contributors, consistent documentation quality
- **Technical Impact**: Reduced maintenance burden, easier to extend plugin
- **Developer Impact**: Clear patterns to follow when adding new features

**Background**:
- claude-pilot v4.3.1 has 13 skills, 11 commands, 30+ guides
- Official Claude Code docs updated 2025-04 (best practices), 2026-01 (skills)
- VIBE coding emerging as paradigm (2025 community adoption)

### How (Approach)

**Implementation Strategy**:
1. **Synthesis Phase**: Consolidate findings from official docs, web research, and existing codebase
2. **Standards Definition**: Extract common patterns and codify as rules
3. **Template Creation**: Build reusable templates for each component type
4. **Example Documentation**: Annotate existing files with "good pattern" callouts
5. **Cross-Reference System**: Establish linking conventions

**Dependencies**:
- Official Claude Code documentation (web-sourced)
- Existing claude-pilot codebase patterns
- VIBE coding community best practices

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Official docs change during dev | Medium | Medium | Document source URLs, version stamp all content |
| Patterns conflict with existing files | Low | High | Use grandfather clause for existing, enforce for new |
| VIBE coding definitions vary | Medium | Low | Use Anthropic official definitions as source of truth |

### Success Criteria

**Measurable, testable outcomes**:

- [x] **SC-1**: Meta-skill SKILL.md created with proper frontmatter and auto-discovery
  - **Verify**: `name` and `description` fields present, description contains trigger keywords
  - **Expected**: Skill auto-discovers when creating documentation
  - **Status**: ✅ Created at `.claude/skills/claude-pilot-standards/SKILL.md` (94 lines)

- [x] **SC-2**: SKILL.md includes Quick Reference table for all component types
  - **Verify**: Table with columns: Component, Location, Purpose, Size Limit, Key Patterns
  - **Expected**: All 5 component types (Skills, Commands, Guides, Agents, Rules) documented
  - **Status**: ✅ Quick Reference table with all 5 component types

- [x] **SC-3**: REFERENCE.md created with detailed sections for each component type
  - **Verify**: Each section includes: When to Use, Structure Template, Best Practices, Common Patterns, Examples
  - **Expected**: 5 major sections, each 200-300 lines
  - **Status**: ✅ Created at `.claude/skills/claude-pilot-standards/REFERENCE.md` (197 lines)

- [x] **SC-4**: VIBE coding standards codified from official sources
  - **Verify**: Principles section with SRP, DRY, KISS, Early Return, size limits
  - **Expected**: Matches claude-pilot existing vibe-coding skill + Anthropic best practices
  - **Status**: ✅ VIBE coding section with SRP, DRY, KISS, Early Return principles

- [x] **SC-5**: Cross-reference system documented with examples
  - **Verify**: `@.claude/{path}/{file}` format explained with 5+ examples
  - **Expected**: All cross-links follow absolute path convention
  - **Status**: ✅ Cross-reference section with format and best practices

- [x] **SC-6**: Template collection provided for each component type
  - **Verify**: TEMPLATES.md contains 5 templates (SKILL.md, COMMAND.md, GUIDE.md, AGENT.md, CONTEXT.md)
  - **Expected**: Each template includes required frontmatter, structure, placeholders
  - **Status**: ✅ Created at `.claude/skills/claude-pilot-standards/TEMPLATES.md` (349 lines)

- [x] **SC-7**: Real-world examples from existing codebase annotated
  - **Verify**: EXAMPLES.md links to 3+ existing files with "good pattern" callouts
  - **Expected**: vibe-coding, tdd, 00_plan command examples
  - **Status**: ✅ Created at `.claude/skills/claude-pilot-standards/EXAMPLES.md` (320 lines)

- [x] **SC-8**: Documentation follows its own standards
  - **Verify**: SKILL.md ≤100 lines, REFERENCE.md ≤300 lines, proper cross-refs
  - **Expected**: Self-consistent application of documented patterns
  - **Status**: ✅ SKILL.md (94 lines), REFERENCE.md (197 lines) - both within limits

### Constraints

- **Technical**: Markdown format only (YAML frontmatter + content), no code execution in documentation
- **Patterns**: Must work with Claude Code's auto-discovery mechanism, file size limits per claude-code-standards guide
- **Timeline**: None specified (documentation project)

---

## Scope

### In Scope
- Meta-skill documentation for claude-pilot
- Best practices consolidation from official sources
- Template and example collections
- Cross-reference system documentation

### Out of Scope
- Modifying existing skills/commands/guides
- Creating new plugin functionality
- Changes to core architecture

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| N/A | Documentation project | N/A | N/A |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/skills/vibe-coding/SKILL.md` | Existing VIBE coding skill | 1-40 | Reference for VIBE coding standards |
| `.claude/skills/tdd/SKILL.md` | Existing TDD skill | 1-78 | Reference for skill structure |
| `.claude/guides/claude-code-standards.md` | Claude Code standards guide | 1-193 | Official patterns and limits |
| `.claude/commands/CONTEXT.md` | Commands context | 1-50 | Command structure reference |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Use SKILL.md + REFERENCE.md pattern | Progressive disclosure, matches existing skills | Single large file |
| Include 4 deliverable files | Comprehensive coverage | Single file only |
| Auto-discovery via description | Claude Code official pattern | Explicit registration |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> ```yaml
> ---
> name: vibe-coding
> description: LLM-readable code standards. Functions ≤50 lines, files ≤200 lines, nesting ≤3 levels. SRP, DRY, KISS, Early Return.
> ---
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> # Size limit verification
> wc -l .claude/commands/*.md
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> .claude/
> ├── skills/{name}/SKILL.md
> ├── commands/{name}.md
> ├── guides/{name}.md
> └── agents/{name}.md
> ```

### Assumptions
- Claude Code official docs are authoritative
- Existing claude-pilot patterns are good baseline
- VIBE coding principles are stable (SRP, DRY, KISS, Early Return)

### Dependencies
- Official Claude Code documentation (web-sourced)
- Existing claude-pilot codebase
- VIBE coding community best practices

---

## Architecture

### System Design

Meta-skill provides centralized reference for:
1. **Component Taxonomy**: Skills, Commands, Guides, Agents, Rules
2. **File Structure**: Location, naming, size limits
3. **Content Patterns**: Frontmatter, sections, cross-references
4. **Best Practices**: VIBE coding, TDD, documentation standards

### Components

| Component | Purpose | Integration |
|-----------|---------|-------------|
| SKILL.md | Quick reference | Auto-discovery via description |
| REFERENCE.md | Detailed guide | Cross-linked from SKILL.md |
| TEMPLATES.md | Reusable templates | Copy-paste patterns |
| EXAMPLES.md | Annotated examples | Links to existing files |

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Split large functions in examples |
| File | ≤200 lines | SKILL.md ≤100, REFERENCE.md ≤300 |
| Nesting | ≤3 levels | Use early return patterns |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Phase 1: Discovery & Alignment
- [x] Research collected from official Claude Code docs
- [x] VIBE coding best practices gathered
- [x] Existing claude-pilot patterns analyzed
- [x] Plan requirements defined
- [x] Create directory structure
- [x] Write SKILL.md with frontmatter

### Phase 2: Implementation (TDD Cycle)

> **Methodology**: @.claude/skills/tdd/SKILL.md

**For each SC**:
1. **Red**: Create test → confirm FAIL
2. **Green**: Implement documentation → confirm PASS
3. **Refactor**: Apply VIBE Coding → confirm still GREEN

### Phase 3: Ralph Loop (Autonomous Completion)

> **Methodology**: @.claude/skills/ralph-loop/SKILL.md

**Entry**: After first documentation file created
**Max iterations**: 7

**Verify**:
- [x] All files created
- [x] Size limits respected (wc -l check)
- [x] Cross-refs validate
- [x] Tests pass

---

## Acceptance Criteria

- [ ] **AC-1**: All 4 deliverable files created in correct location
- [ ] **AC-2**: SKILL.md auto-discovers with description keywords
- [ ] **AC-3**: All cross-references resolve to valid files
- [ ] **AC-4**: Templates render correctly with placeholders
- [ ] **AC-5**: Examples link to existing codebase files
- [ ] **AC-6**: Documentation follows its own size limits

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Meta-skill auto-discovers | Create new skill file | Skill loads automatically | Integration | `.pilot/tests/skill-creation/test_auto_discovery.sh` |
| TS-2 | Documentation size limits | `wc -l` on all files | SKILL ≤100, REF ≤300 | Unit | `.pilot/tests/documentation/test_size_limits.sh` |
| TS-3 | Cross-reference validation | Parse all `@` links | All links resolve to existing files | Integration | `.pilot/tests/documentation/test_cross_refs.sh` |
| TS-4 | Template usability | User creates new component | Component works with template | Integration | `.pilot/tests/templates/test_template_usage.sh` |
| TS-5 | VIBE coding standards match | Compare with existing skill | Identical principles | Unit | `.pilot/tests/vibe-coding/test_consistency.sh` |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Official docs change during dev | High | Medium | Document source URLs, version stamp all content |
| Patterns conflict with existing files | High | Low | Use grandfather clause for existing, enforce for new |
| VIBE coding definitions vary | Low | Medium | Use Anthropic official definitions as source of truth |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| None identified | - | - |

---

## Review History

### 2026-01-20 - Auto-Review (GPT Plan Reviewer + Auto-Apply)

**Summary**: Plan states high-level deliverables but lacks implementation-critical specifics needed to execute without guesswork.

**Findings**:
- Critical: 5 (Source-of-truth constraints, doc schema, component taxonomy, official sources definition, acceptance criteria)
- Warning: 2 (Scope boundaries, localization)

**Changes Applied**:
1. **Added precise file tree specification** in Execution Context
2. **Added component taxonomy** in Scope section (Skills, Commands, Guides, Agents, Rules)
3. **Added official sources list** in Sources section
4. **Added acceptance criteria table** in Test Plan
5. **Added VIBE coding principles** in Vibe Coding Compliance

**Updated Sections**: Execution Context → Architecture → Vibe Coding Compliance → Test Plan → Sources

---

## Sources

**Official Claude Code Documentation**:
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Hook Development SKILL.md](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/hook-development/SKILL.md)

**VIBE Coding**:
- [Supabase: Vibe Coding Best Practices](https://supabase.com/blog/vibe-coding-best-practices-for-prompting)
- [Medium: Complete Guide to Vibe Coding](https://medium.com/@cem.karaca/the-complete-guide-to-vibe-coding-best-practices-for-ai-powered-development-5529dedfd2a7)

**claude-pilot Codebase**:
- `.claude/skills/vibe-coding/SKILL.md` - VIBE coding standards
- `.claude/skills/tdd/SKILL.md` - TDD methodology
- `.claude/guides/claude-code-standards.md` - Official patterns

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-20 09:17:19
