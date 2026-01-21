# Agents Context

## Purpose

Specialized agents with distinct capabilities, model allocations, and tool access. Agents are the execution engine of the claude-pilot workflow.

## Key Agents

| Agent | Model | Lines | Tools | Purpose | Usage |
|-------|-------|-------|-------|---------|-------|
| **explorer** | haiku | 60 | Glob, Grep, Read | Fast codebase exploration | `/00_plan` - Find files, search patterns |
| **researcher** | haiku | 67 | WebSearch, WebFetch, query-docs | External docs research | `/00_plan` - Find external docs |
| **coder** | sonnet | 280 | Read, Write, Edit, Bash | TDD implementation | `/02_execute` - Red-Green-Refactor, Ralph Loop |
| **tester** | sonnet | 148 | Read, Write, Bash | Test writing and execution | `/review` - Test coverage, debug |
| **validator** | haiku | 181 | Bash, Read | Type check, lint, coverage | `/review` - Quality verification |
| **plan-reviewer** | sonnet | 128 | Read, Glob, Grep | Plan analysis and gaps | `/01_confirm` - Gap detection |
| **code-reviewer** | opus | 122 | Read, Glob, Grep, Bash | Deep code review | `/review` - Async bugs, memory leaks |
| **documenter** | haiku | 197 | Read, Write | Documentation generation | `/document` - Sync docs |

**Total**: 8 agents, 1183 lines (average: 148 lines per agent)

## Agent Categories

### Exploration Agents (Haiku)
- **explorer**: Codebase exploration
- **researcher**: External docs research

### Implementation Agents (Sonnet)
- **coder**: TDD implementation
- **tester**: Test writing and execution

### Verification Agents (Haiku/Sonnet/Opus)
- **validator** (haiku): Quality checks
- **plan-reviewer** (sonnet): Plan analysis
- **code-reviewer** (opus): Deep review

### Documentation Agents (Haiku)
- **documenter**: Documentation generation

## Usage by Commands

### `/00_plan` (Planning)
- **explorer** (haiku): Find files, search patterns
- **researcher** (haiku): Research external docs

### `/01_confirm` (Confirmation)
- **plan-reviewer** (sonnet): Gap detection review

### `/02_execute` (Execution)
- **coder** (sonnet): TDD + Ralph Loop implementation

### `/review` (Review)
- **tester** (sonnet): Test coverage and quality
- **validator** (haiku): Type check, lint, coverage
- **code-reviewer** (opus): Deep analysis

### `/document` (Documentation)
- **documenter** (haiku): Sync documentation

## Model Allocation Strategy

**Haiku** (fast, cost-efficient):
- explorer: Pattern matching (Glob, Grep, Read)
- researcher: Information retrieval (WebSearch, WebFetch)
- validator: Deterministic checks (type, lint, coverage)
- documenter: Template generation (Read, Write)

**Sonnet** (balanced quality/speed):
- coder: Implementation (TDD, Ralph Loop)
- tester: Test strategy (generate, debug)
- plan-reviewer: Analysis (gap detection)

**Opus** (deep reasoning):
- code-reviewer: Critical issues (async bugs, memory leaks)

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

**Plan-Reviewer Agent**:
- `<PLAN_COMPLETE>`: Plan approved, no gaps
- `<PLAN_BLOCKED>`: BLOCKING gaps found

## See Also

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command workflow and agent invocation

**Skill specifications**:
- @.claude/skills/CONTEXT.md - Agent capabilities and skills
