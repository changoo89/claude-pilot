# Agents Context

## Purpose

Specialized agents with distinct capabilities, model allocations, and tool access. Agents are the execution engine of the claude-pilot workflow, each responsible for specific tasks in the development lifecycle.

## Key Agents

| Agent | Model | Lines | Tools | Purpose | Usage |
|-------|-------|-------|-------|---------|-------|
| **explorer** | haiku | 60 | Glob, Grep, Read | Fast codebase exploration | `/00_plan` - Find files, search patterns |
| **researcher** | haiku | 67 | WebSearch, WebFetch, query-docs | External docs research | `/00_plan` - Find external docs |
| **coder** | sonnet | 315 | Read, Write, Edit, Bash | TDD implementation | `/02_execute` - Red-Green-Refactor, Ralph Loop |
| **tester** | sonnet | 148 | Read, Write, Bash | Test writing and execution | `/90_review` - Test coverage, debug |
| **validator** | haiku | 181 | Bash, Read | Type check, lint, coverage | `/90_review` - Quality verification |
| **plan-reviewer** | sonnet | 236 | Read, Glob, Grep | Plan analysis and gaps | `/01_confirm` - Gap detection |
| **code-reviewer** | opus | 199 | Read, Glob, Grep, Bash | Deep code review | `/90_review` - Async bugs, memory leaks |
| **documenter** | haiku | 197 | Read, Write | Documentation generation | `/91_document` - Sync docs |

**Total**: 8 agents, 1403 lines (average: 175 lines per agent)

## Common Tasks

### Explore Codebase
- **Task**: Fast codebase exploration and file discovery
- **Agent**: @.claude/agents/explorer.md (haiku)
- **Tools**: Glob, Grep, Read
- **Usage**: `/00_plan` command (parallel with researcher)

**Capabilities**:
- Find files by pattern (`Glob`)
- Search file contents (`Grep`)
- Read file structure (`Read`)
- Analyze codebase organization

**Why Haiku**: Fast, pattern-based tasks don't require deep reasoning.

### Research External Documentation
- **Task**: Find and extract external documentation
- **Agent**: @.claude/agents/researcher.md (haiku)
- **Tools**: WebSearch, WebFetch, query-docs
- **Usage**: `/00_plan` command (parallel with explorer)

**Capabilities**:
- Search web for documentation
- Fetch and extract relevant information
- Query documentation servers (context7)
- Summarize external docs

**Why Haiku**: Information retrieval, not synthesis. Fast and cost-efficient.

### Implement Features
- **Task**: Implement features using TDD + Ralph Loop
- **Agent**: @.claude/agents/coder.md (sonnet)
- **Tools**: Read, Write, Edit, Bash
- **Skills**: tdd, ralph-loop, vibe-coding
- **Usage**: `/02_execute` command

**Capabilities**:
- Red-Green-Refactor cycle
- Autonomous iteration (Ralph Loop)
- Code quality standards (Vibe Coding)
- Context isolation (~80K tokens)

**Why Sonnet**: Balanced reasoning for implementation tasks. Good quality-to-speed ratio.

### Write and Execute Tests
- **Task**: Generate tests and run coverage
- **Agent**: @.claude/agents/tester.md (sonnet)
- **Tools**: Read, Write, Bash
- **Usage**: `/90_review` command (parallel verification)

**Capabilities**:
- Generate test cases
- Run test suites
- Analyze coverage
- Debug test failures

**Why Sonnet**: Test strategy requires moderate reasoning.

### Verify Code Quality
- **Task**: Type check, lint, extract coverage
- **Agent**: @.claude/agents/validator.md (haiku)
- **Tools**: Bash, Read
- **Usage**: `/90_review` command (parallel verification)

**Capabilities**:
- Run type checks (npx tsc --noEmit, mypy)
- Run linters (eslint, ruff, gofmt)
- Extract coverage percentage
- Verify quality gates

**Why Haiku**: Deterministic checks, no reasoning required.

### Review Plans and Detect Gaps
- **Task**: Analyze plans and detect gaps with GPT Plan Reviewer option
- **Agent**: @.claude/agents/plan-reviewer.md (sonnet)
- **Tools**: Read, Glob, Grep
- **Usage**: `/01_confirm` command

**Capabilities**:
- Review plan completeness
- Detect gaps in external service integration
- Verify success criteria
- Identify missing requirements

**GPT Plan Reviewer Delegation** (Step 5):
- **Trigger**: Large plans (5+ Success Criteria)
- **Expert**: GPT Plan Reviewer via `codex-sync.sh`
- **Action**: Delegates for comprehensive plan validation
- **Fallback**: Claude-only review if Codex not installed

**Why Sonnet**: Analysis requires moderate reasoning.

### Deep Code Review
- **Task**: Deep analysis for critical issues with GPT Security Analyst option
- **Agent**: @.claude/agents/code-reviewer.md (opus)
- **Tools**: Read, Glob, Grep, Bash
- **Usage**: `/90_review` command (parallel verification)

**Capabilities**:
- Async bug detection
- Memory leak analysis
- Performance issue identification
- Security vulnerability scanning

**GPT Security Analyst Delegation** (Step 6):
- **Trigger**: Security-related code detected (auth, crypto, input validation, etc.)
- **Expert**: GPT Security Analyst via `codex-sync.sh`
- **Action**: Delegates for threat modeling, vulnerability assessment
- **Fallback**: Claude-only review if Codex not installed

**Why Opus**: Critical issues require deepest reasoning. High cost justified for quality.

### Generate Documentation
- **Task**: Generate and sync documentation
- **Agent**: @.claude/agents/documenter.md (haiku)
- **Tools**: Read, Write
- **Usage**: `/91_document` command

**Capabilities**:
- Scan codebase structure
- Generate CLAUDE.md
- Sync templates
- Ensure consistency

**Why Haiku**: Template-based generation, no deep reasoning.

## Patterns

### Model Allocation Strategy

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

### Frontmatter Pattern

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

**Required fields**:
- `name`: Agent identifier (kebab-case)
- `description`: Clear purpose (for reference)
- `model`: haiku, sonnet, or opus
- `tools`: List of available tools
- `skills`: Optional list of applicable skills

### Agent Structure Pattern

Standard agent structure:

```markdown
---
[frontmatter]
---

You are the {Agent} Agent. Your mission is...

## Core Principles
[Key behaviors and constraints]

## Workflow
[Step-by-step process]

## Output Format
[Expected response format with markers]

## Important Notes
[Caveats and edge cases]
```

### Completion Marker Pattern

Agents output completion markers:

**Coder Agent**:
- `<CODER_COMPLETE>`: All SC met, quality gates pass
- `<CODER_BLOCKED>`: Max iterations reached, needs intervention

**Plan-Reviewer Agent**:
- `<PLAN_COMPLETE>`: Plan approved, no gaps
- `<PLAN_BLOCKED>`: BLOCKING gaps found

**Pattern**: Output `<AGENT_COMPLETE>` or `<AGENT_BLOCKED>` at end.

### Parallel Execution Pattern

Agents work in parallel for efficiency:

**Planning** (`/00_plan`):
- Explorer + Researcher (parallel exploration)

**Execution** (`/02_execute`):
- Multiple Coders (parallel SC implementation when independent)

**Verification** (`/90_review`):
- Tester + Validator + Code-Reviewer (parallel verification)

**Key principles**:
- Analyze dependencies before parallel execution
- Each agent works on different files
- Merge results after parallel phase

**See**: @.claude/guides/parallel-execution.md for detailed patterns

### Skill Integration Pattern

Agents reference skills for methodology:

**Example: Coder Agent**
```markdown
## Workflow

### Phase 2: TDD Cycle
> **Methodology**: @.claude/skills/tdd/SKILL.md

### Phase 3: Ralph Loop
> **Methodology**: @.claude/skills/ralph-loop/SKILL.md
```

**Benefits**:
- Keep agent files concise
- Single source of truth
- Easy methodology updates

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
- **plan-reviewer** (sonnet): Create SPEC-First plan

### `/01_confirm` (Confirmation)
- **plan-reviewer** (sonnet): Gap detection review

### `/02_execute` (Execution)
- **coder** (sonnet): TDD + Ralph Loop implementation

### `/90_review` (Review)
- **tester** (sonnet): Test coverage and quality
- **validator** (haiku): Type check, lint, coverage
- **code-reviewer** (opus): Deep analysis
- **plan-reviewer** (sonnet): Requirements verification

### `/91_document` (Documentation)
- **documenter** (haiku): Sync documentation

## Size Guidelines

**Target**: 150-200 lines per agent

**Current state**: Average 175 lines (within target)

**Exceptions**:
- `coder.md` (315 lines): Comprehensive implementation workflow
- `plan-reviewer.md` (236 lines): Detailed gap detection

**When to reduce**:
- If agent exceeds 200 lines
- Extract methodology to skills
- Use cross-references

**Example**:
```markdown
BEFORE (in agent):
## TDD Methodology (100 lines)

AFTER (in agent):
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

## Tool Access by Agent

| Tool | explorer | researcher | coder | tester | validator | plan-reviewer | code-reviewer | documenter |
|------|----------|------------|-------|--------|-----------|---------------|---------------|------------|
| **Read** | ✅ | | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Glob** | ✅ | | ✅ | | | ✅ | ✅ | |
| **Grep** | ✅ | | ✅ | | | ✅ | ✅ | |
| **Write** | | | ✅ | ✅ | | | | ✅ |
| **Edit** | | | ✅ | | | | | |
| **Bash** | | | ✅ | ✅ | ✅ | | ✅ | |
| **WebSearch** | | ✅ | | | | | | |
| **WebFetch** | | ✅ | | | | | | |
| **query-docs** | | ✅ | | | | | | |

**Rationale**:
- **explorer**: Read-only exploration
- **researcher**: External information retrieval
- **coder**: Full implementation (read + write + execute)
- **tester**: Test generation and execution
- **validator**: Verification commands only
- **plan-reviewer**: Read-only analysis
- **code-reviewer**: Deep analysis (read + execute)
- **documenter**: Read + write for documentation

## Improvement Opportunities

**Current state**: Most agents within size targets

**Improvements needed**:
1. `coder.md` (315 lines): Extract methodology details to skills
2. `plan-reviewer.md` (236 lines): Verify workflow is concise
3. `documenter.md` (197 lines): Minor format improvements
4. `code-reviewer.md` (199 lines): Verify depth is appropriate
5. `validator.md` (181 lines): Verify tools are appropriate
6. `tester.md` (148 lines): Good (no change)
7. `researcher.md` (67 lines): Good (no change)
8. `explorer.md` (60 lines): Good (no change)

## Frontmatter Verification

**Required frontmatter for all agents**:

```yaml
---
name: {agent-name}
description: {clear purpose}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list]
---
```

**Verification checklist**:
- [ ] `name` present (kebab-case)
- [ ] `description` clear and concise
- [ ] `model` specified (haiku/sonnet/opus)
- [ ] `tools` listed (appropriate for role)
- [ ] `skills` listed if applicable

## See Also

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command workflow and agent invocation

**Skill specifications**:
- @.claude/skills/CONTEXT.md - Agent capabilities and skills

**Orchestration patterns**:
- @.claude/guides/parallel-execution.md - Agent coordination patterns

**Documentation standards**:
- @.claude/guides/claude-code-standards.md - Model allocation rationale
