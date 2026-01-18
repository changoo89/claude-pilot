# Progressive Disclosure Implementation Plan

> **Created**: 2026-01-18
> **Purpose**: Plan progressive disclosure pattern for CLAUDE.md refactoring
> **Target**: Reduce CLAUDE.md from 515 lines to < 300 lines (215+ lines to remove/move)

---

## Executive Summary

**Objective**: Implement progressive disclosure pattern in CLAUDE.md by moving detailed, task-specific content to appropriate locations in the 3-Tier documentation system, keeping only universally applicable instructions in root CLAUDE.md.

**Current State**: CLAUDE.md has 515 lines (72% over the 300-line limit)

**Target State**: CLAUDE.md with < 300 lines through strategic content migration

**Approach**: Keep in CLAUDE.md what everyone needs → Move to docs/ai-context/ what some need → Create component-specific CLAUDE.md for specialized contexts

---

## Progressive Disclosure Principles

### Definition

**Progressive Disclosure**: A design pattern that provides essential information first, with pointers to detailed content available on-demand.

**Benefits**:
- Reduces cognitive load on Claude (less context to parse)
- Improves instruction following (focus on universally applicable rules)
- Easier maintenance (separate concerns, single source of truth)
- Better discoverability (clear @ syntax pointers)

### Implementation Strategy

**Rule**: If content is task-specific or situation-specific, move it out of root CLAUDE.md.

**Decision Framework**:
- **Keep in CLAUDE.md**: Universal rules, always applicable, every agent needs
- **Move to docs/ai-context/**: Detailed methodology, system integration, reference material
- **Create .claude/*/CLAUDE.md**: Component-specific patterns and rules

---

## Section Migration Matrix

### Sections to KEEP in CLAUDE.md (Essential)

| Section | Lines | Reason | Action |
|---------|-------|--------|--------|
| Quick Start | 8-24 | Installation, first-use | ✅ KEEP (essential) |
| Workflow Commands | 26-38 | Primary command reference | ✅ KEEP (essential) |
| Development Workflow | 40-45 | Core methodology | ✅ KEEP (essential) |
| Project Structure | 48-78 | Directory layout | ✅ KEEP (essential) |
| Documentation System | 341-349 | 3-Tier overview | ✅ KEEP (essential) |
| Related Documentation | 420-429 | Navigation pointers | ✅ KEEP (essential) |
| Version/Footer | 432-434 | Version tracking | ✅ KEEP (essential) |

**Subtotal**: ~120 lines to keep

### Sections to MOVE to docs/ai-context/ (Detailed)

| Section | Lines | Target | Reason |
|---------|-------|--------|--------|
| **Plugin Distribution** | 81-97 | `docs/ai-context/plugin-architecture.md` | Detailed installation, version management |
| **Codex Integration** | 100-136 | `docs/ai-context/codex-integration.md` | Advanced delegation pattern |
| **Sisyphus Continuation** | 139-220 | `docs/ai-context/continuation-system.md` | Complex system, detailed config |
| **CI/CD Integration** | 222-324 | `docs/ai-context/cicd-integration.md` | Release process, troubleshooting |
| **Testing & Quality** | 327-339 | `docs/ai-context/testing-quality.md` | Quality standards, hooks |
| **Agent Ecosystem** | 352-363 | `docs/ai-context/agent-ecosystem.md` | Agent details, parallel execution |
| **MCP Servers** | 366-369 | `docs/ai-context/mcp-servers.md` | Server configuration |

**Subtotal**: ~260 lines to move to Tier 2

### Sections to MOVE to .claude/commands/CLAUDE.md (Command-Specific)

| Section | Lines | Target | Reason |
|---------|-------|--------|--------|
| **Frontend Design Skill** | 372-406 | `.claude/skills/frontend-design/SKILL.md` | Already exists, create pointer |

**Subtotal**: ~35 lines to replace with pointer

### Sections to REMOVE (Anti-Patterns)

| Section | Lines | Reason | Action |
|---------|-------|--------|--------|
| **Pre-Commit Checklist** | 409-417 | Code style in CLAUDE.md is anti-pattern | ❌ REMOVE (use hooks.json) |

**Subtotal**: ~10 lines to remove

---

## Detailed Migration Plan

### Phase 1: Create New Tier 2 Documentation Files

#### File 1: docs/ai-context/plugin-architecture.md

**Content to Move**:
- Plugin Distribution section (lines 81-97)
- Plugin manifests explanation
- Installation flow
- Version management details

**Pointer in CLAUDE.md**:
```markdown
## Plugin Distribution (v4.1.0)

**Pure Plugin Architecture**: Native Claude Code plugin integration

**Installation**: See @docs/ai-context/plugin-architecture.md for detailed setup and version management

**Updates**: `/plugin update claude-pilot`

**Version Source**: `.claude-plugin/plugin.json` (single source of truth)
```

**Line Reduction**: 17 lines → 5 lines (12 lines saved)

#### File 2: docs/ai-context/codex-integration.md

**Content to Move**:
- Codex Integration section (lines 100-136)
- Delegation triggers (explicit, semantic, description-based)
- GPT Expert Mapping table
- Configuration details
- Reasoning effort levels

**Pointer in CLAUDE.md**:
```markdown
## Codex Integration (v4.1.0)

**Intelligent GPT Delegation**: Context-aware, autonomous delegation for high-difficulty analysis

**When to Delegate**: Architecture decisions, 2+ failures, security issues, large plans

**Configuration**: `export CODEX_REASONING_EFFORT="medium"` (default)

**Full guide**: @docs/ai-context/codex-integration.md
```

**Line Reduction**: 37 lines → 7 lines (30 lines saved)

#### File 3: docs/ai-context/continuation-system.md

**Content to Move**:
- Sisyphus Continuation System section (lines 139-220)
- Overview and philosophy
- State persistence details
- Granular todo breakdown
- Configuration options
- State file format
- Workflow steps

**Pointer in CLAUDE.md**:
```markdown
## Sisyphus Continuation System (v4.2.0)

**Intelligent Agent Continuation**: Agents persist work across sessions until completion

**Commands**: `/00_continue` (resume), `/02_execute` (create state), `/03_close` (verify complete)

**Configuration**: `export CONTINUATION_LEVEL="normal"` (aggressive | normal | polite)

**Full guide**: @docs/ai-context/continuation-system.md
```

**Line Reduction**: 82 lines → 7 lines (75 lines saved)

#### File 4: docs/ai-context/cicd-integration.md

**Content to Move**:
- CI/CD Integration section (lines 222-324)
- Hybrid release model
- Workflow configuration
- Usage examples
- Benefits (free tier, version safety)
- Troubleshooting (5 scenarios)

**Pointer in CLAUDE.md**:
```markdown
## CI/CD Integration

**GitHub Actions**: Automated release publishing on git tag push

**Standard Release**:
```bash
/999_release minor          # Bump version, create tag
git push origin main --tags  # Trigger CI/CD
```

**Troubleshooting**: @docs/ai-context/cicd-integration.md
```

**Line Reduction**: 103 lines → 10 lines (93 lines saved)

#### File 5: docs/ai-context/testing-quality.md

**Content to Move**:
- Testing & Quality section (lines 327-339)
- Coverage targets by scope
- Test commands reference
- Hooks configuration

**Pointer in CLAUDE.md**:
```markdown
## Testing & Quality

**Coverage Targets**: Overall 80%, Core 90%, UI 70%

**Hooks**: Pre-commit type check and lint (`.claude/hooks.json`)

**Full standards**: @docs/ai-context/testing-quality.md
```

**Line Reduction**: 13 lines → 7 lines (6 lines saved)

#### File 6: docs/ai-context/agent-ecosystem.md

**Content to Move**:
- Agent Ecosystem section (lines 352-363)
- Agent model mapping
- Parallel execution patterns
- Guide references

**Pointer in CLAUDE.md**:
```markdown
## Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Parallel execution**: @docs/ai-context/agent-ecosystem.md
```

**Line Reduction**: 12 lines → 10 lines (2 lines saved)

#### File 7: docs/ai-context/mcp-servers.md

**Content to Move**:
- MCP Servers section (lines 366-369)
- Recommended server list

**Pointer in CLAUDE.md**:
```markdown
## MCP Servers

**Recommended**: context7, serena, grep-app, sequential-thinking, codex

**Full list**: @docs/ai-context/mcp-servers.md
```

**Line Reduction**: 4 lines → 4 lines (0 lines saved, better organization)

---

### Phase 2: Create Component-Specific CLAUDE.md Files

#### File: .claude/commands/CLAUDE.md

**Purpose**: Command-specific patterns and conventions

**Content**:
```markdown
# Commands CLAUDE.md

## Command-Specific Patterns

### Command File Structure

Every command follows this structure:
1. Summary (what it does)
2. Workflow phase (when to use)
3. Process steps (how it works)
4. GPT delegation triggers (if applicable)
5. Error handling

### Command Naming Convention

- `00_plan`, `01_confirm`: Planning phase (sequential)
- `02_execute`: Execution phase
- `03_close`: Completion phase
- `90_review`, `91_document`: Quality/maintenance (high numbers)
- `999_release`: Release management (emergency/high priority)

### Common Patterns

See @.claude/commands/CONTEXT.md for detailed command workflows
```

#### File: .claude/agents/CLAUDE.md

**Purpose**: Agent-specific rules and patterns

**Content**:
```markdown
# Agents CLAUDE.md

## Agent-Specific Rules

### Agent Model Selection

- **Haiku**: Fast, cost-efficient (exploration, research, validation, documentation)
- **Sonnet**: Balanced quality/speed (implementation, testing, planning)
- **Opus**: Deep reasoning (code review, complex analysis)

### Agent Coordination

See @.claude/agents/CONTEXT.md for agent coordination patterns
```

---

### Phase 3: Remove Anti-Patterns

#### Remove: Pre-Commit Checklist (lines 409-417)

**Reason**: Code style guidelines in CLAUDE.md is an official anti-pattern

**Alternative**: Use `.claude/hooks.json` for hook definitions

**Action**: Delete section, add reference to hooks.json

**Replacement in CLAUDE.md**:
```markdown
## Pre-Commit Hooks

**Configuration**: `.claude/hooks.json`

**Available Hooks**:
- `pre-commit`: Type check, lint
- `pre-push`: Branch guard

**See**: @.claude/hooks.json for hook definitions
```

**Line Reduction**: 9 lines → 7 lines (2 lines saved)

---

## @ Syntax Pointer Examples

### Pointer Syntax Standard

**Format**: `@path/to/file.md` or `@path/to/directory`

**Usage in CLAUDE.md**:
```markdown
## Related Documentation

- **System Integration**: @docs/ai-context/system-integration.md
- **Project Structure**: @docs/ai-context/project-structure.md
- **Plugin Architecture**: @docs/ai-context/plugin-architecture.md
- **Codex Integration**: @docs/ai-context/codex-integration.md
- **Continuation System**: @docs/ai-context/continuation-system.md
- **CI/CD**: @docs/ai-context/cicd-integration.md
- **Testing & Quality**: @docs/ai-context/testing-quality.md
- **Agent Ecosystem**: @docs/ai-context/agent-ecosystem.md
- **MCP Servers**: @docs/ai-context/mcp-servers.md
- **Command Patterns**: @.claude/commands/CLAUDE.md
- **Agent Rules**: @.claude/agents/CLAUDE.md
```

### Inline Pointers

**Example**:
```markdown
## Development Workflow

1. **SPEC-First**: What/Why/How/Success Criteria/Constraints
2. **TDD Cycle**: @.claude/skills/tdd/SKILL.md
3. **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
4. **Quality Gates**: @.claude/skills/vibe-coding/SKILL.md
```

---

## Before/After Comparisons

### Example 1: Codex Integration Section

**BEFORE** (37 lines in CLAUDE.md):
```markdown
## Codex Integration (v4.1.0)

**Intelligent GPT Delegation**: Context-aware, autonomous delegation via `codex-sync.sh` for high-difficulty analysis.

### Delegation Triggers

**Explicit Triggers** (Keyword-Based):
- User explicitly requests: "ask GPT", "review architecture"

**Semantic Triggers** (Heuristic-Based):
- **Failure-based**: Agent fails 2+ times on same task
- **Ambiguity**: Vague requirements, no success criteria
- **Complexity**: 10+ success criteria, deep dependencies
- **Risk**: Auth/credential keywords, security-sensitive code
- **Progress stagnation**: No meaningful progress in N iterations

**Description-Based** (Claude Code Official):
- Agent descriptions with "use proactively" phrase
- Semantic task matching by Claude Code

### GPT Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** (progressive escalation) |
| Coder blocked (automatic) | **Architect** (self-assessment) |

**Configuration**:
- Default reasoning effort: `medium` (1-2min response)
- Override: `export CODEX_REASONING_EFFORT="low|medium|high|xhigh"`
- Graceful fallback: Claude-only analysis if Codex CLI not installed

**Full guide**: `.claude/guides/intelligent-delegation.md`
```

**AFTER** (7 lines in CLAUDE.md + pointer):
```markdown
## Codex Integration (v4.1.0)

**Intelligent GPT Delegation**: Context-aware, autonomous delegation for high-difficulty analysis

**When to Delegate**: Architecture decisions, 2+ failures, security issues, large plans

**Configuration**: `export CODEX_REASONING_EFFORT="medium"` (default)

**Full guide**: @docs/ai-context/codex-integration.md
```

**Lines Saved**: 30 lines

### Example 2: Sisyphus Continuation System

**BEFORE** (82 lines in CLAUDE.md):
```markdown
## Sisyphus Continuation System (v4.2.0)

**Intelligent Agent Continuation**: Agents persist work across sessions and continue until all todos complete.

### Overview

Inspired by the Greek myth of Sisyphus, the continuation system ensures "the boulder never stops" - agents continue working until completion or manual intervention. Tasks are completed automatically without manual restart.

### Key Features

**State Persistence**:
- Continuation state stored in `.pilot/state/continuation.json`
- Tracks: session UUID, branch, plan file, todos, iteration count
- Automatic backup before writes (`.backup` file)

**Agent Continuation**:
- Agents check continuation state before stopping
- Continue if incomplete todos exist and iterations < max (7)
- Escape hatch: `/cancel`, `/stop`, `/done` commands

**Granular Todo Breakdown**:
- Todos broken into ≤15 minute chunks
- Single owner per todo (coder, tester, validator, documenter)
- Enables reliable continuation progress tracking

### Commands

| Command | Purpose |
|---------|---------|
| `/00_continue` | Resume work from continuation state |
| `/02_execute` | Creates/resumes continuation state automatically |
| `/03_close` | Verifies all todos complete before closing |

### Configuration

```bash
# Set continuation aggressiveness
export CONTINUATION_LEVEL="normal"  # aggressive | normal | polite

# Set max iterations (default: 7)
export MAX_ITERATIONS=7
```

**Continuation Levels**:
- `aggressive`: Maximum continuation, minimal pauses
- `normal` (default): Balanced continuation
- `polite`: More frequent checkpoints, user control

### State File Format

```json
{
  "version": "1.0",
  "session_id": "uuid",
  "branch": "main",
  "plan_file": ".pilot/plan/in_progress/plan.md",
  "todos": [
    {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
    {"id": "SC-2", "status": "in_progress", "iteration": 0, "owner": "coder"}
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-18T10:30:00Z",
  "continuation_level": "normal"
}
```

### Workflow

1. **Plan**: `/00_plan "task"` → Generates granular todos (≤15 min each)
2. **Execute**: `/02_execute` → Creates continuation state, starts work
3. **Continue**: Agent continues automatically until:
   - All todos complete, OR
   - Max iterations reached (7), OR
   - User interrupts (`/cancel`, `/stop`)
4. **Resume**: `/00_continue` → If session interrupted
5. **Close**: `/03_close` → Verifies all todos complete

**Full guide**: `.claude/guides/continuation-system.md`
**Todo granularity**: `.claude/guides/todo-granularity.md`
```

**AFTER** (7 lines in CLAUDE.md + pointer):
```markdown
## Sisyphus Continuation System (v4.2.0)

**Intelligent Agent Continuation**: Agents persist work across sessions until completion

**Commands**: `/00_continue` (resume), `/02_execute` (create state), `/03_close` (verify complete)

**Configuration**: `export CONTINUATION_LEVEL="normal"` (aggressive | normal | polite)

**Full guide**: @docs/ai-context/continuation-system.md
```

**Lines Saved**: 75 lines

### Example 3: CI/CD Integration

**BEFORE** (103 lines in CLAUDE.md):
```markdown
## CI/CD Integration

**GitHub Actions Workflow**: Automated release publishing on git tag push

### Hybrid Release Model

The release process uses a hybrid approach combining local preparation with CI/CD automation:

1. **Local Phase** (`/999_release`):
   - Bumps version across all files (plugin.json, marketplace.json, .pilot-version)
   - Generates CHANGELOG entry from git commits
   - Creates git tag (vX.Y.Z)
   - Skips GitHub release creation by default (`--skip-gh`)

2. **CI/CD Phase** (GitHub Actions):
   - Triggered on git tag push (`v*` pattern)
   - Validates version consistency across all files
   - Extracts release notes from CHANGELOG
   - Creates GitHub Release with extracted notes

### Workflow Configuration

**File**: `.github/workflows/release.yml`

**Trigger**: Git tag push matching `v*` pattern

**Validation Checks**:
```bash
# CI validates these match:
- Git tag version (vX.Y.Z)
- plugin.json version
- marketplace.json version
- .pilot-version
```

**Release Notes**: Automatically extracted from CHANGELOG.md section matching tag version

### Usage Examples

**Standard Release** (uses CI/CD):
```bash
/999_release minor          # Bump version, create tag locally
git push origin main --tags  # Trigger CI/CD to create release
```

**Local Release** (skip CI/CD):
```bash
/999_release patch --create-gh  # Create release locally
```

**Verification**:
```bash
# Check CI/CD run status
gh run list --workflow=release.yml

# View specific run
gh run view <run-id>
```

### Benefits

**Free Tier Benefits**:
- No API rate limits (GitHub Actions uses internal API)
- No authentication setup required
- Runs on GitHub's infrastructure (free for public repos)
- Consistent release formatting via CHANGELOG extraction

**Version Safety**:
- CI validates version consistency before creating release
- Prevents releases with mismatched versions
- Fails fast with clear error messages

### Troubleshooting

**Version Mismatch Error**:
```
Error: Tag version (4.1.7) does not match plugin.json version (4.1.6)
```
**Solution**: Re-run `/999_release` to ensure all versions are synchronized

**Missing CHANGELOG Entry**:
```
Release notes section not found for version 4.1.7
```
**Solution**: Manually add CHANGELOG entry or ensure commit messages are formatted for auto-generation

**CI/CD Not Triggered**:
```
git push origin main --tags  # No workflow run
```
**Solution**: Verify tag format matches `v*` pattern (e.g., `v4.1.7`, not `4.1.7`)

**Workflow Configuration**:
```yaml
# .github/workflows/release.yml
on:
  push:
    tags:
      - 'v*'  # Triggers on v1.0.0, v2.3.4, etc.
```

**Full guide**: `.claude/commands/999_release.md`
```

**AFTER** (10 lines in CLAUDE.md + pointer):
```markdown
## CI/CD Integration

**GitHub Actions**: Automated release publishing on git tag push

**Standard Release**:
```bash
/999_release minor          # Bump version, create tag
git push origin main --tags  # Trigger CI/CD
```

**Troubleshooting**: @docs/ai-context/cicd-integration.md
```

**Lines Saved**: 93 lines

---

## Implementation Checklist

### Phase 1: Create Tier 2 Documentation Files

- [ ] Create `docs/ai-context/plugin-architecture.md`
- [ ] Create `docs/ai-context/codex-integration.md`
- [ ] Create `docs/ai-context/continuation-system.md`
- [ ] Create `docs/ai-context/cicd-integration.md`
- [ ] Create `docs/ai-context/testing-quality.md`
- [ ] Create `docs/ai-context/agent-ecosystem.md`
- [ ] Create `docs/ai-context/mcp-servers.md`

### Phase 2: Create Component-Specific CLAUDE.md Files

- [ ] Create `.claude/commands/CLAUDE.md`
- [ ] Create `.claude/agents/CLAUDE.md`
- [ ] Create `.claude/skills/CLAUDE.md` (if needed)

### Phase 3: Refactor CLAUDE.md

- [ ] Replace Codex Integration section with pointer (30 lines saved)
- [ ] Replace Sisyphus Continuation section with pointer (75 lines saved)
- [ ] Replace CI/CD Integration section with pointer (93 lines saved)
- [ ] Replace Testing & Quality section with pointer (6 lines saved)
- [ ] Replace Agent Ecosystem section with pointer (2 lines saved)
- [ ] Replace MCP Servers section with pointer (0 lines saved, better organization)
- [ ] Remove Pre-Commit Checklist (anti-pattern) (2 lines saved)
- [ ] Update Related Documentation section with new @ syntax pointers

### Phase 4: Verification

- [ ] Run `wc -l CLAUDE.md` to verify < 300 lines
- [ ] Check all @ syntax pointers resolve correctly
- [ ] Verify no content loss (all moved content exists in target files)
- [ ] Test CLAUDE.md with real tasks to ensure instruction following

---

## Expected Results

### Line Count Reduction

| Section | Before | After | Savings |
|---------|--------|-------|---------|
| Codex Integration | 37 | 7 | 30 |
| Sisyphus Continuation | 82 | 7 | 75 |
| CI/CD Integration | 103 | 10 | 93 |
| Testing & Quality | 13 | 7 | 6 |
| Agent Ecosystem | 12 | 10 | 2 |
| MCP Servers | 4 | 4 | 0 |
| Pre-Commit Checklist | 9 | 7 | 2 |
| **Total** | **260** | **52** | **208** |

**Current CLAUDE.md**: 515 lines
**Target CLAUDE.md**: 515 - 208 = 307 lines (still 7 lines over)

**Additional Optimization**: Reorganize remaining sections for better flow, possible merge of Project Structure with Documentation System

**Final Target**: < 300 lines (additional 7+ lines to save through section consolidation)

### Benefits Achieved

1. **Reduced Cognitive Load**: Claude sees 208 fewer lines in primary context
2. **Better Organization**: Detailed content in appropriate Tier 2 locations
3. **Improved Discoverability**: Clear @ syntax pointers to detailed information
4. **Easier Maintenance**: Separate concerns, single source of truth for each topic
5. **Compliance**: Aligns with Claude Code official documentation standards

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Broken @ references | Medium | Medium | Verify all pointers resolve, test with real tasks |
| Loss of critical info | Low | High | Preserve all content, only reorganize location |
| Claude ignores pointers | Low | Medium | Keep essential summaries in CLAUDE.md, pointers for details |
| File creation errors | Low | Low | Follow existing docs/ai-context/ file structure patterns |

---

## Next Steps

1. **Execute Implementation** (SC-3.1): Refactor CLAUDE.md according to this plan
2. **Create Tier 2 Files** (SC-3.2): Generate new documentation files in docs/ai-context/
3. **Update Pointers** (SC-3.3): Replace detailed sections with @ syntax pointers
4. **Verify Compliance** (SC-4.1): Run TS-1 to confirm CLAUDE.md < 300 lines

---

**Plan Version**: 1.0
**Status**: Ready for Implementation
**Owner**: Coder Agent
**Estimated Time**: 45 minutes (Phase 1: 20min, Phase 2: 10min, Phase 3: 10min, Phase 4: 5min)
