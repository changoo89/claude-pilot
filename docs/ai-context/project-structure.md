# Project Structure Guide

> **Purpose**: Technology stack, directory layout, and key files
> **Last Updated**: 2026-01-15

---

## Technology Stack

```yaml
Framework: Node.js CLI Tool
Language: TypeScript
Package Manager: npm
Version: 3.2.0
Deployment: npm package distribution
```

---

## Directory Layout

```
claude-pilot/
├── .claude/
│   ├── commands/           # Slash commands (6)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan (with Step 1.5 extraction)
│   │   ├── 02_execute.md   # Execute with TDD
│   │   ├── 03_close.md     # Close & archive
│   │   ├── 90_review.md    # Review code
│   │   ├── 91_document.md  # Update docs
│   │   ├── 92_init.md      # Initialize 3-Tier docs
│   │   └── 999_publish.md  # Publish to npm
│   ├── guides/             # Methodology guides (9)
│   │   ├── prp-framework.md       # Problem-Requirements-Plan
│   │   ├── vibe-coding.md         # Code quality standards
│   │   ├── gap-detection.md       # External service verification
│   │   ├── tdd-methodology.md     # Test-driven development
│   │   ├── ralph-loop.md          # Autonomous iteration
│   │   ├── parallel-execution.md  # Parallel execution patterns
│   │   ├── 3tier-documentation.md # Documentation system
│   │   ├── review-checklist.md    # Code review criteria
│   │   └── test-environment.md    # Test framework detection
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   │   ├── gap-checklist.md
│   │   ├── CONTEXT-tier2.md.template
│   │   └── CONTEXT-tier3.md.template
│   ├── skills/             # Reusable skill modules (4)
│   │   ├── tdd/SKILL.md
│   │   ├── ralph-loop/SKILL.md
│   │   ├── vibe-coding/SKILL.md
│   │   └── git-master/SKILL.md
│   ├── agents/             # Specialized agent configs (8)
│   │   ├── explorer.md
│   │   ├── researcher.md
│   │   ├── coder.md
│   │   ├── tester.md
│   │   ├── validator.md
│   │   ├── plan-reviewer.md
│   │   ├── code-reviewer.md
│   │   └── documenter.md
│   ├── scripts/
│   │   └── hooks/          # Git/workflow hooks (4)
│   │       ├── typecheck.sh
│   │       ├── lint.sh
│   │       ├── check-todos.sh
│   │       └── branch-guard.sh
│   └── rules/              # Core rules
│       ├── core/workflow.md
│       └── documentation/tier-rules.md
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
├── docs/                   # Project documentation
│   ├── ai-context/         # 3-Tier detailed docs
│   │   ├── system-integration.md
│   │   └── project-structure.md
│   ├── plan-gap-analysis-external-api-calls.md
│   └── slash-command-enhancement-examples.md
├── scripts/                # Build/publish scripts
├── src/                    # Source code (if any)
├── tests/                  # Test files
├── CLAUDE.md               # Tier 1: Project documentation
├── README.md               # Project README
├── package.json            # npm configuration
└── CHANGELOG.md            # Version history
```

---

## Key Files by Purpose

### Command Workflow

| File | Purpose | Agent Pattern |
|------|---------|---------------|
| `.claude/commands/00_plan.md` | Generate SPEC-First plan with PRP analysis | **MANDATORY**: Parallel Explorer + Researcher (Step 0) |
| `.claude/commands/01_confirm.md` | Extract plan, create file, auto-review with Interactive Recovery | **MANDATORY**: Plan-Reviewer (Step 4) |
| `.claude/commands/02_execute.md` | Implement with TDD + Ralph Loop | **MANDATORY**: Parallel Coders (Step 2.3), Parallel Verification (Step 2.4), Coder Delegation (Step 3) |
| `.claude/commands/03_close.md` | Archive plan, commit changes | **MANDATORY**: Documenter (Step 5) |
| `.claude/commands/90_review.md` | Review code or plans | **MANDATORY**: Plan-Reviewer (single or parallel) |
| `.claude/commands/91_document.md` | Update documentation | **OPTIONAL**: Documenter |

### Documentation

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Tier 1: Project-level documentation (quick reference) |
| `docs/ai-context/system-integration.md` | Component interactions, workflows |
| `docs/ai-context/project-structure.md` | This file: tech stack, layout |
| `.claude/guides/3tier-documentation.md` | 3-Tier system guide |

### Configuration

| File | Purpose |
|------|---------|
| `.claude/settings.json` | MCP server configuration |
| `package.json` | npm dependencies, scripts, version |
| `.gitignore` | Git exclusions |

### Templates

| File | Purpose |
|------|---------|
| `.claude/templates/gap-checklist.md` | External service verification checklist |
| `.claude/templates/CONTEXT-tier2.md.template` | Component CONTEXT.md template |
| `.claude/templates/CONTEXT-tier3.md.template` | Feature CONTEXT.md template |

---

## /01_confirm Command Structure

### Updated with Step 1.5 (2026-01-14)

The `/01_confirm` command now includes **Step 1.5: Conversation Highlights Extraction** to capture implementation details from the `/00_plan` conversation.

### Command File

- **Location**: `.claude/commands/01_confirm.md`
- **Lines**: 247 (slightly above 200-line Vibe Coding limit, accepted)
- **Sections**:
  1. Extract Plan from Conversation
  1.5. Conversation Highlights Extraction (NEW)
  2. Generate Plan File Name
  3. Create Plan File
  4. Auto-Review with Interactive Recovery

### Step 1.5 Highlights

Extracts three types of implementation patterns:

1. **Code Examples**: Fenced code blocks (```language) from conversation
2. **Syntax Patterns**: CLI commands, API invocation examples
3. **Architecture Diagrams**: ASCII art, Mermaid charts, flow diagrams

Output is marked with `> **FROM CONVERSATION:**` and added to plan under "Execution Context → Implementation Patterns" section.

---

## Plan File Structure

### Template Location

`.claude/commands/01_confirm.md` (Step 3.1)

### Sections

```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name} | Location: {plan_path}

## User Requirements
## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff)
### Explored Files
### Key Decisions Made
### Implementation Patterns (FROM CONVERSATION)  <-- Step 1.5 output
## External Service Integration [if applicable]
### API Calls Required
### New Endpoints to Create
### Environment Variables Required
### Error Handling Strategy
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
## Review History
## Execution Summary
```

---

## 3-Tier Documentation

### Overview

| Tier | Location | Purpose | Max Lines |
|------|----------|---------|-----------|
| **Tier 1** | `CLAUDE.md` | Project standards, architecture, workflows | 300 |
| **Tier 2** | `{component}/CONTEXT.md` | Component-level architecture | 200 |
| **Tier 3** | `{feature}/CONTEXT.md` | Feature-level implementation details | 150 |

### Tier 1 (CLAUDE.md)

- Quick reference for project standards
- Installation and common commands
- Development workflow overview
- Links to Tier 2/3 CONTEXT.md files

### Tier 2 (Component CONTEXT.md)

- Located in major folders (src/, lib/, components/)
- Component purpose and architecture
- Key files and patterns
- Integration points

### Tier 3 (Feature CONTEXT.md)

- Located in feature folders or deep nesting
- Implementation details and decisions
- Performance characteristics
- Code examples

### docs/ai-context/

When Tier 1 exceeds 300 lines, detailed sections move here:

- `system-integration.md`: Component interactions, workflows
- `project-structure.md`: Technology stack, directory layout
- `docs-overview.md`: Navigation for all CONTEXT.md files

---

## Skills and Agents

### Skills (Reusable Modules)

Located in `.claude/skills/{skill_name}/SKILL.md`:

| Skill | Purpose |
|-------|---------|
| `tdd` | Test-driven development cycle |
| `ralph-loop` | Autonomous iteration until tests pass |
| `vibe-coding` | Code quality enforcement |
| `git-master` | Git operations and commits |

### Agents (Specialized Roles)

Located in `.claude/agents/{agent_name}.md`:

**Model Allocation:**

| Model | Agents | Purpose |
|-------|--------|---------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, cost-efficient for repetitive/structured tasks |
| **Sonnet** | coder, tester, plan-reviewer | Balance of quality and speed for complex tasks |
| **Opus** | code-reviewer | Deep reasoning for critical review (async bugs, memory leaks) |

**Agent Details:**

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| `explorer` | haiku | Glob, Grep, Read | Codebase exploration and analysis |
| `researcher` | haiku | WebSearch, WebFetch, query-docs | External documentation and API research |
| `coder` | sonnet | Read, Write, Edit, Bash | Implementation with TDD |
| `tester` | sonnet | Read, Write, Bash | Test writing and execution |
| `validator` | haiku | Bash, Read | Type check, lint, coverage verification |
| `plan-reviewer` | sonnet | Read, Glob, Grep | Plan analysis and gap detection |
| `code-reviewer` | opus | Read, Glob, Grep, Bash | Deep code review (async, memory, security) |
| `documenter` | haiku | Read, Write | Documentation synchronization |

---

## Hooks

### Location

`.claude/scripts/hooks/`

### Hook Types

| Hook | Trigger | Purpose |
|------|---------|---------|
| PreToolUse | Before file edits | Type check, lint validation |
| PostToolUse | After file edits | Type check, lint validation |
| Stop | At command end | TODO completion, Ralph Loop enforcement |

### Hook Scripts

- `typecheck.sh`: TypeScript validation (`tsc --noEmit`)
- `lint.sh`: ESLint/Pylint/gofmt validation
- `check-todos.sh`: Ralph Loop continuation enforcement
- `branch-guard.sh`: Protected branch warnings

---

## Version History

### v3.2.0 (Current)

- Converted agent invocation patterns from descriptive to imperative
- Added MANDATORY ACTION sections with "YOU MUST invoke... NOW" commands
- Added EXECUTE IMMEDIATELY - DO NOT SKIP emphasis headers
- Added VERIFICATION wait instructions after agent invocations
- Enhanced parallel execution support with explicit "send in same message" instructions
- Improved agent delegation reliability through direct imperative language

### v3.1.4

- Added parallel workflow optimization with 8 specialized agents
- New agents: researcher, tester, validator, plan-reviewer, code-reviewer
- Renamed reviewer.md → code-reviewer.md (model: haiku → opus)
- Updated commands with parallel execution patterns
- Added parallel-execution.md guide

### v3.1.0

- Added Skills and Agents for context isolation
- Enhanced /01_confirm with Step 1.5 (Conversation Highlights Extraction)
- Updated plan template to include Implementation Patterns
- Added docs/ai-context/ for detailed documentation

### v3.0.0

- 3-Tier Documentation System
- Enhanced Gap Detection Review
- Interactive Recovery for BLOCKING findings

---

## Related Documentation

- `CLAUDE.md` - Tier 1: Project documentation
- `.claude/guides/3tier-documentation.md` - 3-Tier system guide
- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan
- `.claude/guides/vibe-coding.md` - Code quality standards

---

**Last Updated**: 2026-01-15
**Template**: claude-pilot 3.2.0
