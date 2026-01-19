# Update Documentation: Remove PyPI Migration, Add GPT Codex Integration

> **Generated**: 2026-01-19 22:28:53 | **Work**: update_documentation_remove_pypi_add_codex | **Location**: .pilot/plan/draft/20260119_222853_update_documentation_remove_pypi_add_codex.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 22:25 | "우리 리드미, 깃헙 desc, claudecode plugin desc를 비롯해서 전체적인 프로젝트 설명을 갱신해줘" | Update all project descriptions |
| UR-2 | 22:25 | "1. pypi 로 부터 마이그레이션 내용은 제거해줘" | Remove PyPI migration content |
| UR-3 | 22:25 | "2. gpt codex 통합 아키텍쳐 내용을 추가해줘" | Add GPT Codex integration architecture |
| UR-4 | 22:25 | "3. 그 외에 우리 전체적인 플러그인 스펙이 설명에 제대로 녹아들게 해줘" | Integrate plugin specs into descriptions |
| UR-5 | 22:25 | "github star 를 많이 받기 위해 어떻게 해야할지 gpt 와 함께 고민해봐" | GitHub Star growth strategy |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-5 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| UR-3 | ✅ | SC-2, SC-4 | Mapped |
| UR-4 | ✅ | SC-1, SC-5 | Mapped |
| UR-5 | ✅ | SC-1 (optimization section) | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Update all project documentation (README.md, CLAUDE.md, marketplace descriptions) to reflect current plugin architecture, remove PyPI migration content, and add GPT Codex integration architecture with GitHub Star optimization.

**Scope**:
- **In Scope**:
  - README.md - Complete rewrite with hero section, badges, GitHub Star optimization
  - CLAUDE.md - Update plugin documentation with Codex architecture
  - marketplace.json - Update marketplace description with plugin specs
  - GETTING_STARTED.md - Remove outdated PyPI installation, update to current method
  - Archive MIGRATION.md to docs/archive/ (historical reference)
  - Add Codex/GPT integration section to documentation
  - Add GitHub Star optimization elements (badges, CTAs, comparison table)
- **Out of Scope**:
  - Plugin functionality changes (zero code changes)
  - New features or commands
  - Architecture refactoring
  - Core workflow changes

**Deliverables**:
1. Updated README.md with hero section, badges, GitHub Star optimization
2. Updated CLAUDE.md with GPT Codex integration architecture
3. Updated marketplace.json description
4. Archived MIGRATION.md to docs/archive/
5. Updated GETTING_STARTED.md

### Why (Context)

**Current Problem**:
- Documentation contains outdated PyPI migration references (confusing for new users)
- No clear explanation of GPT Codex integration architecture (key differentiator)
- README not optimized for GitHub Star conversion (missing key elements like badges, hero section)
- Plugin specs not clearly communicated in descriptions
- Installation instructions are outdated (curl | bash method vs plugin marketplace)

**Business Value**:
- **User impact**: Clearer onboarding, better understanding of plugin capabilities, quick successful installation
- **Technical impact**: Accurate documentation reflects current state (pure plugin, no Python dependency)
- **Community impact**: GitHub Star growth through better presentation, quality signals, and discoverability

### How (Approach)

**Implementation Strategy**:

1. **Phase 1**: Remove PyPI migration content
   - Archive MIGRATION.md to docs/archive/MIGRATION.md
   - Remove MIGRATION.md references from README.md (line 124), CLAUDE.md (line 150), project-structure.md (lines 162, 189)
   - Remove PyPI migration section from README.md (lines 353-375)
   - Update all PyPI/pip install references

2. **Phase 2**: Add GPT Codex architecture
   - Reference existing documentation: docs/ai-context/codex-integration.md (392 lines, authoritative source)
   - Update README.md with Codex section (based on codex-integration.md content)
   - Expand CLAUDE.md Codex Integration section (lines 73-80) with architecture details
   - Update marketplace.json description with Codex/GPT integration features
   - Add link to codex-integration.md from CLAUDE.md

3. **Phase 3**: GitHub Star optimization
   - Rewrite README.md hero section with 5-second pitch
   - Add quality badges: Version, License (MIT), Stars, Tests
   - Add Star CTA after Quick Start section
   - Add comparison section: claude-pilot vs vanilla Claude Code
   - Optimize for GitHub SEO (topics, keywords)

4. **Phase 4**: Update installation documentation
   - Rewrite GETTING_STARTED.md with current install method:
     - `/plugin marketplace add changoo89/claude-pilot`
     - `/plugin install claude-pilot`
     - `/pilot:setup`
   - Remove outdated curl | bash installation
   - Add verification steps

**Dependencies**:
- docs/ai-context/codex-integration.md - Source for Codex architecture content
- .claude-plugin/marketplace.json - Current marketplace configuration
- .claude-plugin/plugin.json - Plugin metadata
- Existing CLAUDE.md structure - Codex section at lines 73-80

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing user workflows | Low | Medium | Keep command interfaces unchanged, only documentation updates |
| GitHub SEO degradation | Low | Low | Use tested README templates from successful projects |
| Information loss from PyPI removal | Medium | Low | Archive MIGRATION.md to docs/archive/ for historical reference |
| Codex architecture unclear | Low | Medium | Reference authoritative codex-integration.md document |

### Success Criteria

- [ ] **SC-1**: README.md updated with hero section, badges (Version, License, Stars, Tests), GitHub Star optimization (CTA, comparison table)
  - Verify CTA: `grep -q '⭐.*Star this repo' README.md` returns exit code 0
  - Verify badges: `grep -c 'badges\.io.*github' README.md | awk '{if ($1 >= 3) exit 0; else exit 1}'`
  - Verify structure: `grep -q 'Quick Start' README.md` returns exit code 0
- [ ] **SC-2**: CLAUDE.md updated with GPT Codex integration architecture (expand lines 73-80, add link to codex-integration.md)
- [ ] **SC-3**: All PyPI migration references removed from core documentation (README.md, CLAUDE.md, project-structure.md, GETTING_STARTED.md)
  - Verify: `grep -r "pypi\|PyPI" README.md CLAUDE.md GETTING_STARTED.md` returns no matches
  - Expected: Zero matches for "PyPI", "pypi.org", "pip install"
- [ ] **SC-4**: GPT Codex integration architecture added to README.md (new section describing delegation system, triggers, experts)
  - Verify: `grep -q "GPT Codex\|Codex Integration" README.md` returns exit code 0
  - Expected: Section describing Codex delegation, triggers, expert types
- [ ] **SC-5**: marketplace.json description updated with plugin specs and Codex/GPT integration features
  - Verify: `jq '.description' .claude-plugin/marketplace.json` contains "GPT Codex", "SPEC-First", "Ralph Loop"
  - Expected: Description includes key features and Codex integration
- [ ] **SC-6**: GETTING_STARTED.md updated with current installation method (plugin marketplace commands)
  - Verify: `grep -q "plugin marketplace add\|plugin install" GETTING_STARTED.md` returns exit code 0
  - Expected: No curl | bash commands, only plugin marketplace install
- [ ] **SC-7**: MIGRATION.md archived to docs/archive/MIGRATION.md
  - Verify: `test -f docs/archive/MIGRATION.md` returns exit code 0
  - Expected: File exists in archive, no MIGRATION.md in root

### Constraints

- **Technical**:
  - No code changes (documentation only)
  - Keep existing command interfaces unchanged
  - Maintain markdown formatting consistency
  - Preserve links to existing documentation
- **Patterns**:
  - Follow existing documentation structure (3-tier hierarchy)
  - Use consistent terminology with codex-integration.md
  - Match CLAUDE.md style guide (≤150 lines for commands, ≤200 lines for guides)
- **Timeline**:
  - Complete all documentation updates in single session
  - No breaking changes to user workflows
- **Rollback Strategy**:
  - Git commit before documentation updates (explicit checkpoint)
  - Original content preserved via git history
  - Restore via: `git checkout <commit-hash> -- <file>`

---

## Scope

### In Scope
- README.md: Complete rewrite with hero section, badges, GitHub Star optimization
- CLAUDE.md: Update Codex Integration section, add link to codex-integration.md
- marketplace.json: Update description with plugin specs and Codex features
- GETTING_STARTED.md: Rewrite with plugin marketplace installation
- MIGRATION.md: Archive to docs/archive/
- project-structure.md: Update/remove MIGRATION.md references

### Out of Scope
- Plugin functionality changes
- New features or commands
- Code modifications
- Architecture refactoring
- Core workflow changes

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| N/A | N/A | Manual verification | N/A |

**Note**: Documentation-only plan, no automated tests. Verification via grep/test/jq commands.

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| README.md | Main project description | Lines 353-375: PyPI migration section; Line 124: MIGRATION.md reference | Needs complete rewrite |
| CLAUDE.md | Plugin documentation | Lines 73-80: Codex Integration; Line 150: MIGRATION.md reference | Expand Codex section |
| .claude-plugin/marketplace.json | Marketplace config | Description field | Update with plugin specs |
| docs/ai-context/codex-integration.md | Codex architecture | 392 lines, comprehensive | Authoritative source for SC-2, SC-4 |
| GETTING_STARTED.md | Installation guide | Lines 1-50: Outdated curl | bash method | Rewrite with plugin commands |
| MIGRATION.md | PyPI migration guide | 499 lines | Archive to docs/archive/ |
| docs/ai-context/project-structure.md | Structure docs | Lines 162, 189, 559, 570-576 | Update references |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Archive MIGRATION.md vs delete | Preserve historical context for existing users | Complete deletion (rejected - lose history) |
| Reference codex-integration.md | Authoritative 392-line document already exists | Rewrite from scratch (rejected - duplication) |
| Plugin marketplace install | Current method, simpler than curl | bash | Keep both methods (rejected - confusing) |
| GitHub Star optimization | Research shows badges/CTAs increase conversion | Minimal README (rejected - lower discoverability) |

### Implementation Patterns (FROM CONVERSATION)

#### Codex Integration Architecture
> **FROM CONVERSATION (Explorer agent)**:
> docs/ai-context/codex-integration.md (392 lines) - Complete GPT delegation system documentation
> - Lines 14-32: Delegation triggers (explicit, semantic, description-based)
> - Lines 35-44: GPT expert mapping
> - Lines 95-133: Intelligent delegation system with heuristic framework
> - Lines 140-175: Codex integration flow diagram
> - Lines 280-291: Expert prompts documentation

#### PyPI Reference Locations
> **FROM CONVERSATION (Explorer agent)**:
> **README.md**:
> - Line 124: "MIGRATION.md - PyPI to plugin migration guide"
> - Lines 353-375: Migration from PyPI section (uninstall instructions, benefits)
>
> **CLAUDE.md**:
> - Line 150: "MIGRATION.md - PyPI to plugin migration"
>
> **docs/ai-context/project-structure.md**:
> - Lines 162, 189: MIGRATION.md references
> - Lines 570-576: Pure Plugin Migration section

#### GitHub Star Optimization Template
> **FROM CONVERSATION (Researcher agent)**:
> ```markdown
> # claude-pilot ⭐
> **SPEC-First Development Workflow for Claude Code**
>
> > Autonomous agents. TDD-driven. Documentation sync.
>
> [![Version](https://img.shields.io/github/v/release/changoo89/claude-pilot)](https://github.com/changoo89/claude-pilot/releases)
> [![License](https://img.shields.io/github/license/changoo89/claude-pilot)](LICENSE)
> [![Stars](https://img.shields.io/github/stars/changoo89/claude-pilot)](https://github.com/changoo89/claude-pilot)
>
> ## Why claude-pilot?
>
> Stop planning in your head. Start with SPECs, iterate with agents, review with confidence.
>
> - ✅ **SPEC-First**: Requirements before code
> - 🤖 **Autonomous**: Ralph Loop runs until tests pass
> - 🔄 **Continuous**: Resume across sessions with Sisyphus
> - 📚 **Documented**: Auto-sync 3-tier documentation
>
> ## Quick Start
>
> ```bash
> /plugin marketplace add changoo89/claude-pilot
> /plugin install claude-pilot
> /pilot:setup
> ```
>
> [▶️ See it in action (30s demo)](docs/demo.gif)
>
> ⭐ **Star this repo if it helps your workflow!**
> ```

#### Installation Method
> **FROM CONVERSATION (current state)**:
> ```bash
> /plugin marketplace add changoo89/claude-pilot
> /plugin install claude-pilot
> /pilot:setup
> ```

### Assumptions
- docs/ai-context/codex-integration.md is authoritative and up-to-date
- marketplace.json schema allows description updates
- Users prefer plugin marketplace installation over manual curl | bash
- GitHub Star optimization will not negatively affect existing users
- Archiving MIGRATION.md preserves necessary historical context

### Dependencies
- docs/ai-context/codex-integration.md (exists, 392 lines)
- .claude-plugin/marketplace.json (exists, updatable)
- .claude-plugin/plugin.json (exists, reference for specs)
- Current CLAUDE.md structure (Codex section at lines 73-80)

---

## External Service Integration

> ⚠️ **SKIPPED**: No external services required (documentation-only plan)

---

## Architecture

### System Design

This plan updates documentation to reflect the current claude-pilot plugin architecture:

**Current Architecture**:
- Pure Claude Code plugin (no Python dependency)
- Distributed via GitHub Marketplace
- GPT Codex integration for intelligent delegation
- SPEC-First development workflow
- Sisyphus continuation system
- Ralph Loop autonomous iteration
- 3-tier documentation hierarchy

**Documentation Structure**:
```
README.md (user-facing, GitHub optimized)
├── CLAUDE.md (plugin architecture, 2-tier docs)
│   └── docs/ai-context/*.md (3-tier system integration)
│       └── docs/ai-context/codex-integration.md (authoritative)
└── docs/archive/MIGRATION.md (historical reference)
```

### Components

| Component | Purpose | Integration |
|-----------|---------|-------------|
| README.md | GitHub landing page | Links to CLAUDE.md, marketplace |
| CLAUDE.md | Plugin documentation | Links to codex-integration.md |
| marketplace.json | Plugin metadata | GitHub marketplace distribution |
| codex-integration.md | Codex architecture | Referenced by README, CLAUDE.md |
| GETTING_STARTED.md | Installation guide | Links to marketplace |

### Data Flow

1. User discovers project via GitHub → README.md
2. README.md hero section → Quick start (3 commands)
3. Quick start → /plugin install claude-pilot
4. CLAUDE.md → Full plugin documentation
5. Codex integration section → Link to codex-integration.md

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | N/A (documentation only) |
| File | ≤200 lines | CLAUDE.md target: ≤150 lines (current: 163) |
| Nesting | ≤3 levels | N/A (documentation only) |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Phase 1: Remove PyPI Migration Content (documenter, 15 min)
- Archive MIGRATION.md to docs/archive/MIGRATION.md (documenter, 3 min)
- Remove MIGRATION.md reference from README.md line 124 (documenter, 2 min)
- Remove MIGRATION.md reference from CLAUDE.md line 150 (documenter, 2 min)
- Remove PyPI migration section from README.md lines 353-375 (documenter, 3 min)
- Update project-structure.md MIGRATION.md references (documenter, 5 min)

### Phase 2: Add GPT Codex Architecture (documenter, 25 min)
- Update README.md with Codex section based on codex-integration.md (documenter, 10 min)
- Expand CLAUDE.md Codex Integration section (lines 73-80) (documenter, 8 min)
- Add link to codex-integration.md from CLAUDE.md (documenter, 2 min)
- Update marketplace.json description with Codex features (documenter, 5 min)

### Phase 3: GitHub Star Optimization (documenter, 20 min)
- Rewrite README.md hero section with badges and 5-second pitch (documenter, 10 min)
- Add Star CTA after Quick Start section (documenter, 2 min)
- Add comparison section: claude-pilot vs vanilla Claude Code (documenter, 5 min)
- Add quality badges (Version, License, Stars, Tests) (documenter, 3 min)

### Phase 4: Update Installation Documentation (documenter, 12 min)
- Rewrite GETTING_STARTED.md with plugin marketplace commands (documenter, 8 min)
- Remove outdated curl | bash installation (documenter, 3 min)
- Add verification steps (documenter, 1 min)

### Phase 5: Verification (validator, 8 min)
- Verify all PyPI references removed (validator, 3 min)
- Verify Codex section added (validator, 2 min)
- Verify marketplace.json updated (validator, 1 min)
- Verify installation updated (validator, 1 min)
- Verify all documentation links work (validator, 1 min)

**Total estimated time**: 80 minutes

---

## Acceptance Criteria

- [ ] **AC-1**: README.md has hero section with badges, 5-second pitch, Star CTA
- [ ] **AC-2**: CLAUDE.md has expanded Codex Integration section with link to codex-integration.md
- [ ] **AC-3**: No PyPI references in README.md, CLAUDE.md, GETTING_STARTED.md (verified via grep)
- [ ] **AC-4**: README.md has GPT Codex integration architecture section
- [ ] **AC-5**: marketplace.json description includes "GPT Codex", "SPEC-First", "Ralph Loop"
- [ ] **AC-6**: GETTING_STARTED.md uses plugin marketplace commands only
- [ ] **AC-7**: MIGRATION.md archived to docs/archive/MIGRATION.md
- [ ] **AC-8**: All documentation links return 200 status
  - Verify: `grep -oP '\[.*\]\(\K[^)]+' README.md CLAUDE.md | xargs -I{} curl -s -o /dev/null -w "%{http_code}" {} | grep -v 200` returns no output (all 200)

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | PyPI references removed | grep -r "pypi\|PyPI" README.md CLAUDE.md GETTING_STARTED.md | No matches | Integration |
| TS-2 | Codex section exists | grep -q "Codex Integration\|GPT Codex" CLAUDE.md README.md | Exit code 0 | Integration |
| TS-3 | marketplace.json updated | jq '.description' .claude-plugin/marketplace.json | Contains "GPT Codex" | Integration |
| TS-4 | MIGRATION.md archived | test -f docs/archive/MIGRATION.md | File exists | Unit |
| TS-5 | GitHub optimization elements | grep -q "⭐\|badges\|Quick Start" README.md | All found | Integration |
| TS-6 | Documentation links work | grep -oP '\[.*\]\(\K[^)]+' README.md CLAUDE.md | xargs -I{} curl -s -o /dev/null -w "%{http_code}" {} | grep -v 200 | No non-200 responses | Integration |
| TS-7 | Installation updated | grep -q "plugin marketplace add\|plugin install" GETTING_STARTED.md | Exit code 0 | Integration |
| TS-8 | No outdated installation | grep -q "curl | bash\|pip install" GETTING_STARTED.md | Exit code 1 | Unit |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking existing user workflows | Medium | Low | Keep command interfaces unchanged, only documentation updates |
| GitHub SEO degradation | Low | Low | Use tested README templates from successful projects |
| Information loss from PyPI removal | Medium | Low | Archive MIGRATION.md to docs/archive/ for historical reference |
| Codex architecture unclear | Medium | Low | Reference authoritative codex-integration.md document |
| Installation confusion | Low | Medium | Clear step-by-step installation in GETTING_STARTED.md |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| None resolved | - | All BLOCKING findings resolved with conversation data |

---

## Review History

### 2026-01-19 22:28 - GPT Plan Reviewer (Initial Review)

**Summary**: 🛑 **REJECT**

**Findings**:
- BLOCKING: 5 (Codex architecture undefined, plugin specs unclear, PyPI removal unverifiable, installation method unspecified, README criteria subjective)

**Changes Made**: Resolved all BLOCKING findings with data from Explorer and Researcher agents:
- Codex architecture: Reference docs/ai-context/codex-integration.md (authoritative source)
- Plugin specs: Reference .claude-plugin/marketplace.json and .claude-plugin/plugin.json
- PyPI removal: Exact line numbers from Explorer agent
- Installation method: Current plugin marketplace commands
- README criteria: GitHub Star optimization template from Researcher agent

**Updated Sections**:
- Added "Implementation Patterns (FROM CONVERSATION)" section with exact references
- Added "Explored Files" table with line numbers
- Expanded "How (Approach)" with specific content sources
- Added verification commands to Success Criteria
- Added GitHub Star optimization template

**Status**: BLOCKING findings resolved, plan ready for execution

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-19 22:28:53
