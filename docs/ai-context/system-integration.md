# System Integration Guide

> **Purpose**: Component interactions, data flow, shared patterns, and integration points
> **Last Updated**: 2026-01-14

---

## Slash Command Workflow

### Core Commands

```
/00_plan (planning) --> /01_confirm (extraction + review) --> /02_execute (TDD + Ralph) --> /03_close (archive)
                                                                                   |
                                                                                   v
                                                                          /90_review (anytime)
```

### /01_confirm Command Workflow

The `/01_confirm` command extracts the plan from the `/00_plan` conversation and creates a plan file in `.pilot/plan/pending/`.

#### Step Sequence

1. **Step 1: Extract Plan from Conversation**
   - Review context for requirements, scope, architecture, execution plan
   - Validate completeness (User Requirements, Execution Plan, Acceptance Criteria, Test Plan)

2. **Step 1.5: Conversation Highlights Extraction** (NEW)
   - Extract code examples (fenced code blocks)
   - Extract syntax patterns (CLI commands, API patterns)
   - Extract architecture diagrams (ASCII art, Mermaid charts)
   - Mark with `> **FROM CONVERSATION:**` prefix
   - Add to plan under "Execution Context → Implementation Patterns"

3. **Step 2: Generate Plan File Name**
   - Create timestamped filename: `YYYYMMDD_HHMMSS_{work_name}.md`

4. **Step 3: Create Plan File**
   - Use plan template structure
   - Include Execution Context with Implementation Patterns
   - Add External Service Integration (if applicable)

5. **Step 4: Auto-Review**
   - Run Gap Detection Review (unless `--no-review`)
   - Interactive Recovery for BLOCKING findings
   - Support `--lenient` flag to bypass BLOCKING

#### Plan File Structure

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
## Architecture
## Vibe Coding Compliance
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
```

#### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` | Produces conversation | → `/01_confirm` extracts |
| `/01_confirm` | Creates plan file | → `.pilot/plan/pending/` |
| `/01_confirm` Step 1.5 | Extracts highlights | → Plan Implementation Patterns |
| Gap Detection | Reviews external services | → Interactive Recovery |
| `/02_execute` | Reads plan file | ← `.pilot/plan/in_progress/` |

---

## Interactive Recovery

### Trigger Conditions

- BLOCKING findings detected during auto-review
- No `--lenient` flag present
- Max 5 iterations

### Flow

```
BLOCKING > 0?
  |
  +-- Yes: Present findings
  |        |
  |        +-- AskUserQuestion for each BLOCKING
  |        |
  |        +-- Update plan with responses
  |        |
  |        +-- Re-run review
  |        |
  |        +-- BLOCKING = 0? → Exit
  |
  +-- No: Proceed to STOP
```

### Plan Update Format

```markdown
## External Service Integration
### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status |
|------|------|----|----------|----------|--------|
| [Description] | [Service] | [Service] | [Path] | [Package] | [New] |

[OR if skipped]
> ⚠️ SKIPPED: Deferred to implementation phase
```

---

## Gap Detection Categories

### External API

- SDK vs HTTP decision
- Endpoint verification
- Error handling strategy

### Database Operations

- Migration files required
- Rollback strategy
- Connection management

### Async Operations

- Timeout configuration
- Concurrent request limits
- Race condition prevention

### File Operations

- Path resolution (absolute vs relative)
- Existence checks before operations
- Cleanup strategy for temporary files

### Environment Variables

- Documentation in plan
- Existence verification
- No secrets in plan

### Error Handling

- No silent catches
- User notification strategy
- Graceful degradation

---

## Ralph Loop Integration

### Entry Point

- Immediately after first code change in `/02_execute`

### Verification Steps

1. Run tests
2. Type check
3. Lint check
4. Coverage report

### Iteration Logic

```
MAX_ITERATIONS = 7

WHILE NOT all_pass AND iterations < MAX:
    IF failures:
        Fix issues
        Run verification
    ELSE:
        Check completion
    iterations++
```

### Success Criteria

- All tests pass
- Coverage 80%+ (core 90%+)
- Type check clean
- Lint clean

---

## MCP Server Integration

### Recommended MCPs

| MCP | Purpose | Integration |
|-----|---------|-------------|
| context7 | Latest library docs | `@context7` for API lookup |
| serena | Semantic code operations | `@serena` for refactoring |
| grep-app | Advanced search | `@grep-app` for pattern search |
| sequential-thinking | Complex reasoning | `@sequential-thinking` for analysis |

### Configuration

Located in `.claude/settings.json`:
- Server definitions
- Connection parameters
- Tool mappings

---

## Hooks Integration

### PreToolUse Hook

- Runs before file edits
- Validates type check
- Validates lint status

### PostToolUse Hook

- Runs after file edits
- Type check validation
- Lint validation

### Stop Hook

- Runs at command end
- Checks TODO completion
- Enforces Ralph Loop continuation

### Hook Scripts

Located in `.claude/scripts/hooks/`:
- `typecheck.sh`: TypeScript validation
- `lint.sh`: ESLint/Pylint/gofmt
- `check-todos.sh`: Ralph continuation enforcement
- `branch-guard.sh`: Protected branch warnings

---

## Plan Management

### Directory Structure

```
.pilot/plan/
├── pending/        # Awaiting confirmation (created by /01_confirm)
├── in_progress/    # Currently executing (moved by /02_execute)
├── done/           # Completed plans (moved by /03_close)
└── active/         # Branch pointers (current plan per branch)
```

### Lifecycle

```
/01_confirm → pending/{timestamp}_{name}.md
/02_execute → in_progress/{timestamp}_{name}.md
/03_close   → done/{timestamp}_{name}.md
              active/{branch}.txt (pointer)
```

---

## Execution Context Handoff

### Purpose

Capture conversation state from `/00_plan` to ensure continuity between planning and execution.

### Components

| Component | Description | Source |
|-----------|-------------|--------|
| Explored Files | Files reviewed during planning | `/00_plan` file reads |
| Key Decisions | Architectural decisions made | `/00_plan` analysis |
| Implementation Patterns | Code examples, syntax, diagrams | Step 1.5 extraction |
| Assumptions | Validation needed during execution | Planner notes |
| Dependencies | External resource requirements | Gap Detection |

### Format

```markdown
## Execution Context (Planner Handoff)

### Explored Files
| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/01_confirm.md` | Current confirm command | 1-194 | Target for modification |

### Key Decisions Made
| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Option A (enhance /01_confirm) | Most direct fix | Option C (markers) |

### Implementation Patterns (FROM CONVERSATION)
#### Code Examples
> **FROM CONVERSATION:**
> ```typescript
> [exact code from /00_plan]
> ```

#### Syntax Patterns
> **FROM CONVERSATION:**
> ```bash
> [exact command from /00_plan]
> ```

#### Architecture Diagrams
> **FROM CONVERSATION:**
> ```
> [exact diagram from /00_plan]
> ```
```

---

## Related Documentation

- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan definition
- `.claude/guides/vibe-coding.md` - Code quality standards
- `.claude/guides/gap-detection.md` - External service verification
- `.claude/guides/tdd-methodology.md` - Test-driven development
- `.claude/guides/ralph-loop.md` - Autonomous iteration
- `.claude/guides/parallel-execution.md` - Parallel execution patterns

---

## Parallel Execution Integration

### Overview

claude-pilot supports parallel agent execution for maximum workflow efficiency. This reduces execution time by 50-70% while improving quality through agent specialization.

### Parallel Patterns by Command

#### /00_plan: Parallel Exploration

```
Main Orchestrator
       │
       ├─► Explorer Agent (Haiku) - Codebase exploration
       └─► Researcher Agent (Haiku) - External docs research
              ↓
       [Result Merge → Plan Creation]
```

**Implementation**:
- Uses Task tool for parallel invocation
- Explorer returns: Explored Files table, Key Decisions
- Researcher returns: Research Findings table with sources
- Main thread merges results into plan structure

#### /02_execute: Parallel SC Implementation

```
Main Orchestrator
       │
       ├─► Coder-SC1 (Sonnet) - Independent SC
       ├─► Coder-SC2 (Sonnet) - Independent SC
       ├─► Coder-SC3 (Sonnet) - Independent SC
              ↓
       [Result Integration]
              ↓
       ├─► Tester Agent (Sonnet) - Test execution
       ├─► Validator Agent (Haiku) - Type+Lint+Coverage
       └─► Code-Reviewer Agent (Opus) - Deep review
              ↓
       [Ralph Loop Verification]
```

**Implementation**:
- SC dependency analysis before parallel execution
- Independent SCs run concurrently
- Verification agents run in parallel after integration
- Code-reviewer uses Opus for catching async bugs, memory leaks

#### /01_confirm & /90_review: Agent Delegation

```
/01_confirm → Plan-Reviewer Agent (Sonnet)
            - Gap Detection Review
            - Interactive Recovery for BLOCKING issues

/90_review → Plan-Reviewer Agent (Sonnet)
            - Multi-angle parallel review (optional)
            - Security, Quality, Testing, Architecture
```

### Agent Invocation Syntax

```markdown
Task:
  subagent_type: {agent_name}
  prompt: |
    {task_description}
    {context}
    {expected_output}
```

### Model Allocation for Parallel Work

| Model | Parallel Tasks | Rationale |
|-------|----------------|-----------|
| Haiku | explorer, researcher, validator | Fast, cost-efficient |
| Sonnet | coder, tester, plan-reviewer | Quality + speed balance |
| Opus | code-reviewer | Deep reasoning for critical review |

### File Conflict Prevention

- Each parallel agent works on different files
- SC dependency analysis identifies file ownership
- Clear merge strategy after parallel phase
- Integration tests verify merged results

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/00_plan` | Parallel: Explorer + Researcher | → Merged plan structure |
| `/02_execute` | Parallel: Coder (per SC) | → Integrated code |
| `/02_execute` | Parallel: Tester + Validator + Code-Reviewer | → Verification results |
| `/01_confirm` | Delegates to plan-reviewer | → Gap Detection report |

### Benefits

| Benefit | Impact |
|---------|--------|
| Speed | 50-70% execution time reduction |
| Context Isolation | 8x token efficiency |
| Quality | Specialized agents per task |
| Scalability | Independent tasks run concurrently |

---

**Last Updated**: 2026-01-15
**Template**: claude-pilot 3.1.0
