# claude-pilot - Plugin Documentation

> **Version**: 4.4.45 | **Last Updated**: 2026-01-26

---

## ⚠️ CRITICAL: Required Reference Documents

**Before starting any work, you MUST read the following documents:**

- `@docs/ai-context/project-structure.md` - Project structure, tech stack, file tree
- `@docs/ai-context/docs-overview.md` - Documentation architecture, Tier mapping, component references

These two documents are Tier 1 documents that all AI agents MUST reference before starting any work, along with CLAUDE.md.

---

## Quick Start

```bash
/plugin marketplace add changoo89/claude-pilot#release
/plugin install claude-pilot
/pilot:setup
```

---

## Plugin Architecture

**Pure Plugin**: No Python dependency, native Claude Code integration

**Superpowers-Style Commands**: All commands invoke skills (single source of truth)
- Commands: ~10 lines (frontmatter + skill invocation)
- Skills: All execution logic (steps, bash scripts, verification)
- Pattern: `Invoke the [skill-name] skill and follow it exactly`

**Core Features**:
- **SPEC-First Planning**: `/00_plan "task"`
- **TDD + Ralph Loop**: `/02_execute` - Autonomous iteration until quality gates pass
- **Multi-Angle Review**: `/review` - Parallel verification
- **Auto-Documentation**: `/document` - 3-Tier sync

**Workflow**: Plan (`/00_plan`) → Confirm (`/01_confirm`) → Execute (`/02_execute`) → Review (`/review`) → Document (`/document`) → Close (`/03_close`)

### OOM Optimization (v4.4.43)
- **Reduced Agent Calls**: `/03_close` now uses 2 agents instead of 3 (33% reduction)
- **Merged Verification**: Documentation sync and verification combined in single agent call
- **No External Dependencies**: Pure bash link checking (removed npx markdown-link-check)
- **Streamlined Steps**: 9 steps → 5 steps (44% reduction)

### E2E Verification Framework (v4.4.43)
- **Mandatory Verification**: Added Step 5 to `/02_execute` for actual functionality validation
- **Project Type Detection**: Auto-detect web/CLI/library projects for appropriate verification
- **Chrome in Claude Integration**: MCP tools for web project visual/functional testing
- **Retry Loop Pattern**: Max 3 attempts with GPT Architect escalation on persistent failures
- **Graceful Fallback**: Skip browser tests with warning when Chrome extension unavailable

### Context Protection Pattern
**Single Agent Delegation**: Always delegate even single tasks to subagents to protect main orchestrator context (~50-80% context savings). Implement mandatory Task tool patterns in all workflow skills.

---

## Plugin Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Commands | Slash commands (11) | `.claude/commands/` |
| Skills | TDD, Ralph Loop, Vibe Coding | `.claude/skills/` |
| Agents | Specialized roles (12) | `.claude/agents/` |

**Plugin Directory**: `@docs/ai-context/project-structure.md`

---

## Key Features

### Codex Integration (v4.2.0)
**Intelligent GPT Delegation**: Context-aware delegation to GPT experts with confidence-based proactive consultation
**Full Guide**: `@.claude/skills/gpt-delegation/REFERENCE.md`

### CI/CD Integration
**GitHub Actions**: Automated release on git tag push

**Release**: `/999_release minor` → Bump version, tag, push → CI creates GitHub Release

**Full Guide**: `@.claude/commands/999_release.md`

### Agent Ecosystem

| Model | Agents | Purpose |
|-------|--------|---------|
| Haiku | explorer, researcher, validator, documenter, build-error-resolver | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer, frontend-engineer, backend-engineer, security-analyst | Balanced quality/speed |
| Opus | code-reviewer | Deep reasoning |

**Full Guide**: `@.claude/agents/CONTEXT.md`

---

## MCP Servers

**Plugin-Recommended**: context7, sequential-thinking

**Setup Guide**: `@.claude/commands/setup.md`

---

## Plugin Skills

**TDD**: `@.claude/skills/tdd/SKILL.md` - Red-Green-Refactor cycle
**Ralph Loop**: `@.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration with Early Escalation option
**Vibe Coding**: `@.claude/skills/vibe-coding/SKILL.md` - Code quality standards
**Coding Standards**: `@.claude/skills/coding-standards/SKILL.md` - TypeScript, React, API, testing standards
**Git Master**: `@.claude/skills/git-master/SKILL.md` - Git operations
**Frontend Design**: `@.claude/skills/frontend-design/SKILL.md` - UI/UX design thinking
**Spec-Driven Workflow**: `@.claude/skills/spec-driven-workflow/SKILL.md` - Enhanced with Atomic SC Principle, Context Manifest, Quick Sufficiency Test, and Proactive GPT Consultation (confidence < 0.5)
**Multi-Angle Review**: `@.claude/skills/review/SKILL.md` - Comprehensive review with enhanced code-reviewer integration
**E2E Verification**: `@.claude/skills/execute-plan/REFERENCE.md` - End-to-end testing with Chrome in Claude integration and Pre-Execution Confidence check
**OOM-Optimized Close**: `@.claude/skills/close-plan/SKILL.md` - Streamlined plan completion (5 steps, 2 agents)

---

## Quality & Skills

**Skill-Based Architecture**: Documentation validation via `docs-verify` skill
- Tier 1 line limit validation (≤200 lines)
- Cross-reference validation
- File count validation (ai-context exactly 2 files)

**No Claude Code Hooks**: Plugin doesn't use Stop/PreToolUse hooks to avoid performance overhead

**Plugin Testing**: Integration tests in `.pilot/tests/`

---

## Plugin Documentation

**3-Tier Hierarchy**:
- **Tier 1**: `CLAUDE.md` + `project-structure.md` + `docs-overview.md` (3 files only)
- **Tier 2**: `{component}/CONTEXT.md` - Component details
- **Tier 3**: `{component}/{feature}/CONTEXT.md` - Feature details

**Key Docs**:
- `@docs/ai-context/project-structure.md` - Plugin layout, tech stack
- `@docs/ai-context/docs-overview.md` - Documentation architecture, Tier mapping
- `@.claude/agents/CONTEXT.md` - Agent ecosystem
- `@.claude/commands/CONTEXT.md` - Command workflows

---

## Version & Distribution

**Plugin Version**: 4.4.45
**Distribution**: GitHub Marketplace via `#release` branch

**Branch Structure**:
- `main`: Development (`.claude/` structure, agent calls without prefix)
- `release`: Distribution (`plugins/claude-pilot/` structure, `claude-pilot:` prefix)

**Build Process** (GitHub Actions on tag push):
1. Copy `.claude/` → `plugins/claude-pilot/`
2. Add `claude-pilot:` prefix to agent references
3. Exclude internal commands (`999_release.md`, `release/` skill)
4. Generate `marketplace.json` with source `./plugins/claude-pilot`

**Release Process**: `@.claude/commands/999_release.md` (internal only)

---

**Line Count**: 188 lines (Target: ≤200 lines) ✅

---

## Version History

### v4.4.40 (2026-01-24)
Self-Contained Planning Framework - External Context Detection, Context Pack Structure, Self-Contained Verification, Zero-Knowledge TODO format

### v4.4.45 (2026-01-26)
Proactive GPT Consultation - Added confidence-based GPT consultation with centralized rubric in gpt-delegation/SKILL.md, Enhanced spec-driven-workflow/SKILL.md with MUST Consult GPT section (architecture keywords OR confidence < 0.5), Enhanced confirm-plan/REFERENCE.md with Proactive Consultation pattern, Enhanced execute-plan/SKILL.md with Pre-Execution Confidence check (Step 2.7), Enhanced ralph-loop/SKILL.md with Early Escalation option (--early flag)

### v4.4.44 (2026-01-26)
Atomic SC Principle - Added "One SC = One File OR One Concern" principle to spec-driven-workflow/SKILL.md for fine-grained Success Criteria, Enhanced confirm-plan/SKILL.md with SC Granularity Check (Step 1.9), Enhanced execute-plan/SKILL.md with Smart Grouping note for parallel execution by specialized agents

### v4.4.43 (2026-01-25)
E2E Verification Framework - Added mandatory E2E verification to /02_execute final stage with project type detection, Chrome in Claude integration for web projects, and retry loop pattern (max 3 attempts), Enhanced QA/QC Framework - Enhanced code-reviewer agent with Risk Areas, Assumptions tracking, Context Manifest format, Quick Sufficiency Test, Documentation Refactoring - 9 SKILL.md and 2 agent files refactored to ≤200 lines, 2 companion docs (TROUBLESHOOTING.md, EXAMPLES.md) created, OOM Optimization - Reduced agent calls in /03_close from 3 to 2, merged verification steps, pure bash link checking

### v4.4.31 (2026-01-24)
Scope Clarity Framework - Step 1.5 in spec-driven-workflow, Step 1.7 in confirm-plan, 4 mandatory triggers for scope validation

**Full History**: See `CHANGELOG.md`
