# Agents Context

## Purpose

Specialized agents with distinct capabilities, model allocations, and tool access. Agents are the execution engine of the claude-pilot workflow.

## Key Agents

| Agent | Model | Lines | Tools | Purpose | Usage |
|-------|-------|-------|-------|---------|-------|
| **explorer** | haiku | 60 | Glob, Grep, Read | Fast codebase exploration | `/00_plan` - Find files, search patterns |
| **researcher** | haiku | 67 | WebSearch, WebFetch, query-docs | External docs research | `/00_plan` - Find external docs |
| **frontend-engineer** | sonnet | 169 | Read, Write, Edit, Bash, Glob, Grep | Frontend UI/React implementation | `/02_execute` - Component, UI, styling |
| **backend-engineer** | sonnet | 196 | Read, Write, Edit, Bash, Glob, Grep | Backend API/DB implementation | `/02_execute` - API, endpoint, server |
| **coder** | sonnet | 137 (+ EXAMPLES.md) | Read, Write, Edit, Bash | TDD implementation (general) | `/02_execute` - Red-Green-Refactor, Ralph Loop |
| **tester** | sonnet | 302 | Read, Write, Bash | Test writing and execution | `/review` - Test coverage, debug |
| **validator** | haiku | 335 | Bash, Read | Type check, lint, coverage | `/review` - Quality verification |
| **security-analyst** | sonnet | 166 | Read, Grep, Glob, Bash | Security vulnerability analysis | `/review security` - OWASP Top 10 |
| **build-error-resolver** | haiku | 188 (+ TROUBLESHOOTING.md) | Bash, Read, Edit | Build/compilation error resolution | `/02_execute` - Build error recovery |
| **plan-reviewer** | sonnet | 128 | Read, Glob, Grep | Plan analysis and gaps | `/01_confirm` - Gap detection |
| **code-reviewer** | opus | 162 | Read, Glob, Grep, Bash | Enhanced code review with risk areas, assumptions tracking | `/review` - Async bugs, memory leaks, risk assessment |
| **design-reviewer** | sonnet | 170 | Read, Glob, Grep, Bash | Design quality review | `/review --design-review` - Landing pages, pricing, onboarding |
| **documenter** | haiku | 351 | Read, Write | Documentation generation | `/document` - Sync docs |

**Total**: 13 agents (all refactored to ≤200 lines main files + companion docs with enhanced capabilities)

## Agent Categories

### Exploration Agents (Haiku)
- **explorer**: Codebase exploration
- **researcher**: External docs research

### Implementation Agents (Sonnet/Haiku)
- **frontend-engineer** (sonnet): Frontend UI/React implementation
- **backend-engineer** (sonnet): Backend API/DB implementation
- **coder** (sonnet): General TDD implementation (fallback)
- **tester** (sonnet): Test writing and execution
- **build-error-resolver** (haiku): Build/compilation error resolution

### Verification Agents (Haiku/Sonnet/Opus)
- **validator** (haiku): Quality checks
- **security-analyst** (sonnet): Security vulnerability analysis
- **plan-reviewer** (sonnet): Plan analysis
- **code-reviewer** (opus): Deep review
- **design-reviewer** (sonnet): Design quality review for high-stakes UI surfaces

### Documentation Agents (Haiku)
- **documenter**: Documentation generation

## Usage by Commands

### `/00_plan` (Planning)
- **explorer** (haiku): Find files, search patterns
- **researcher** (haiku): Research external docs

### `/01_confirm` (Confirmation)
- **plan-reviewer** (sonnet): Gap detection review

### `/02_execute` (Execution)
- **frontend-engineer** (sonnet): Frontend implementation (component, UI, styling)
- **backend-engineer** (sonnet): Backend implementation (API, endpoint, server)
- **build-error-resolver** (haiku): Build error recovery
- **coder** (sonnet): TDD + Ralph Loop implementation (general fallback)

### `/review` (Review)
- **tester** (sonnet): Test coverage and quality
- **validator** (haiku): Type check, lint, coverage
- **security-analyst** (sonnet): Security vulnerability analysis (`/review security`)
- **code-reviewer** (opus): Deep analysis
- **design-reviewer** (sonnet): Design quality review (`/review --design-review`)

### `/document` (Documentation)
- **documenter** (haiku): Sync documentation

### `/03_close` (Plan Completion)
- **validator** (haiku): Evidence verification from Success Criteria
- **documenter** (haiku): Documentation sync + inline verification

## Model Allocation Strategy

**Haiku** (fast, cost-efficient):
- explorer: Pattern matching (Glob, Grep, Read)
- researcher: Information retrieval (WebSearch, WebFetch)
- validator: Deterministic checks (type, lint, coverage)
- build-error-resolver: Build error diagnosis (Bash, Read, Edit)
- documenter: Template generation (Read, Write)

**Sonnet** (balanced quality/speed):
- frontend-engineer: Frontend implementation (React, UI, CSS)
- backend-engineer: Backend implementation (API, database, server)
- coder: General implementation (TDD, Ralph Loop)
- tester: Test strategy (generate, debug)
- security-analyst: Security analysis (OWASP patterns)
- plan-reviewer: Analysis (gap detection)

**Opus** (deep reasoning):
- code-reviewer: Critical issues (async bugs, memory leaks, risk areas, assumptions tracking)

## Frontmatter Pattern

All agents have standard frontmatter:

```yaml
---
name: {agent-name}
description: {clear purpose statement}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list if any]
---
```

## Completion Marker Pattern

Agents output completion markers:

**Coder Agent**:
- `<CODER_COMPLETE>`: All SC met, quality gates pass
- `<CODER_BLOCKED>`: Max iterations reached, needs intervention

**Frontend-Engineer Agent**:
- `<FRONTEND_COMPLETE>`: Frontend implementation complete with design quality self-check
- `<FRONTEND_BLOCKED>`: Build error, needs intervention or delegation

**Backend-Engineer Agent**:
- `<BACKEND_COMPLETE>`: Backend implementation complete, quality gates pass
- `<BACKEND_BLOCKED>`: Max iterations reached, needs intervention

**Build-Error-Resolver Agent**:
- `<BUILD_RESOLVER_COMPLETE>`: Build errors resolved, build passes
- `<BUILD_RESOLVER_BLOCKED>`: Cannot resolve build errors, needs escalation

**Design-Reviewer Agent**:
- `<DESIGN_REVIEW_COMPLETE>`: Design quality review passed, meets Awwwards standards
- `<DESIGN_REVIEW_BLOCKED>`: Design quality issues found, needs fixes

**Documenter Agent**:
- `<DOCS_COMPLETE>`: Documentation synchronized across all 3 tiers
- `<DOCS_BLOCKED>`: Documentation sync failed, needs manual intervention

**Plan-Reviewer Agent**:
- `<PLAN_COMPLETE>`: Plan approved, no gaps
- `<PLAN_BLOCKED>`: BLOCKING gaps found

## Parallel Execution Patterns

### Planning Phase
**Agents**: Explorer + Researcher (parallel)
- **Explorer**: Discovers context, finds relevant files
- **Researcher**: Deep dives into specific topics

### Execution Phase
**Agents**: Parallel Coder agents per SC (independent SCs)
- Each Coder agent works on independent success criteria
- No file conflicts when SCs are properly scoped

### Verification Phase
**Agents**: Tester + Validator + Code-Reviewer (parallel)
- **Tester**: Runs test suite, measures coverage
- **Validator**: Verifies all quality gates pass
- **Code-Reviewer**: Deep code review for issues

## Agent Coordination

**Sequential Execution**: Single agent with `in_progress` status, mark todo as `completed` before next

**Parallel Execution**: Multiple agents with `in_progress` simultaneously, used for independent SCs

## See Also

- @.claude/commands/CONTEXT.md - Command workflow and agent invocation
- @.claude/skills/CONTEXT.md - Agent capabilities and skills
- @.claude/skills/parallel-subagents/SKILL.md - Parallel execution orchestration
