# System Integration Guide

> **Purpose**: Component interactions, data flow, shared patterns, and integration points
> **Last Updated**: 2026-01-15 (Updated: CONTEXT.md pattern documentation)

---

## Slash Command Workflow

### Core Commands

```
/00_plan (planning) --> /01_confirm (extraction + review) --> /02_execute (TDD + Ralph) --> /03_close (archive)
                                                                                   |
                                                                                   v
                                                                          /90_review (anytime)
                                                                          /999_publish (deploy)
```

### Phase Boundary Protection (Updated 2026-01-15)

The `/00_plan` command includes **Level 3 (Strong) phase boundary protection** to prevent ambiguous confirmations from triggering execution.

#### Key Features

1. **Pattern-Based Detection**: Language-agnostic approach (no word lists)
2. **MANDATORY AskUserQuestion**: Multi-option confirmation at plan completion
3. **Valid Execution Triggers**: Only explicit commands allow phase transition

#### AskUserQuestion Template

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

#### Valid Execution Triggers

- User explicitly types `/01_confirm` or `/02_execute`
- User explicitly says "start coding now" or "begin implementation"
- User selects option C or D from AskUserQuestion

**All other responses** (including "go ahead", "proceed", "그래 그렇게 해") → Continue planning or re-call AskUserQuestion.

#### Anti-Patterns

- **NEVER** use Yes/No questions at phase boundaries
- **NEVER** try to detect specific words or phrases
- **ALWAYS** provide explicit multi-option choices
- **ALWAYS** call AskUserQuestion when uncertain about user intent

### /02_execute Command Workflow (Updated 2026-01-15)

The `/02_execute` command implements the plan using TDD + Ralph Loop pattern. **Step 1 now includes atomic plan state transition** to prevent duplicate work when multiple pending plans are queued.

#### Step 1: Plan State Transition (ATOMIC)

**Key Change (2026-01-15)**: Plan movement from `pending/` to `in_progress/` is now the **FIRST and ATOMIC operation** before any other work begins.

**Atomic Block Structure**:
1. Select plan (pending or in_progress)
2. Move pending → in_progress (if applicable) with early exit on failure
3. Create active pointer

**Critical Features**:
- **BLOCKING markers**: Clear visual indicators with emoji warnings
- **Early exit guards**: `|| exit 1` after `mv` command prevents partial state
- **Worktree mode**: Same atomic priority for `--wt` flag
- **Progress logging**: Clear messages for plan movement and pointer creation

#### Step Sequence

1. **Step 1: Plan State Transition (ATOMIC)**
   - 1.1 Worktree Mode (--wt): Atomic move before worktree setup
   - 1.2 Select and Move Plan (ATOMIC BLOCK): Select + Move + Pointer
   - Exit immediately if move fails

2. **Step 2: Convert Plan to Todo List**
   - Extract deliverables, phases, tasks, acceptance criteria
   - Map SC dependencies for parallel execution

3. **Step 2.5: SC Dependency Analysis (For Parallel Execution)**
   - Analyze SC dependencies
   - Group independent SCs
   - Parallel execution pattern with MANDATORY ACTION sections

4. **Step 3: Delegate to Coder Agent (Context Isolation)**
   - MANDATORY ACTION: Invoke Coder Agent via Task tool
   - Token-efficient context isolation (5K vs 110K+ tokens)

5. **Step 4: Execute with TDD (Legacy)**
   - Red-Green-Refactor cycle
   - Ralph Loop integration

6. **Step 5: Ralph Loop (Autonomous Completion)**
   - Max 7 iterations
   - Verification: tests, type-check, lint, coverage

7. **Step 6: Todo Continuation Enforcement**
   - Never quit halfway
   - One `in_progress` at a time

8. **Step 7: Verification**
   - Type check, tests, lint

9. **Step 8: Update Plan Artifacts**
   - Add Execution Summary

10. **Step 9: Auto-Chain to Documentation**
    - Trigger `/91_document` if all criteria met

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
| `/02_execute` Step 1 | Atomic plan move (pending → in_progress) | → `.pilot/plan/in_progress/` |
| `/02_execute` Step 2+ | Reads plan file | ← `.pilot/plan/in_progress/` |
| `/999_publish` Step 0.5 | Syncs templates | `.claude/` → `src/claude_pilot/templates/.claude/` |
| `/999_publish` Step 3-5 | Updates all 6 version files | pyproject.toml, __init__.py, config.py, install.sh, .pilot-version files |

---

## /999_publish Command Workflow

The `/999_publish` command prepares and deploys claude-pilot to PyPI. **Updated with Step 0.5 (2026-01-15)** to automatically sync templates before version bump.

### Step Sequence

1. **Step 0.5: Sync Templates (CRITICAL)** - NEW
   - 0.5.1 Sync commands (excluding 999_publish.md)
   - 0.5.2 Sync skills (SKILL.md + REFERENCE.md)
   - 0.5.3 Sync guides, agents, rules, templates, hooks
   - 0.5.4 Verify sync (file counts and sizes)

2. **Step 1: Pre-Flight Verification**
   - Check git status (must be clean)
   - Verify tests pass
   - Verify type check passes

3. **Step 2: Extract Current Version**
   - Parse pyproject.toml for version
   - Extract all 6 version locations:
     - pyproject.toml
     - src/claude_pilot/__init__.py
     - src/claude_pilot/config.py
     - install.sh
     - .claude/.pilot-version
     - src/claude_pilot/templates/.claude/.pilot-version

4. **Step 3: Check Version Mismatch**
   - Compare all 6 version locations
   - Report mismatches if found
   - Exit if mismatch detected

5. **Step 4: Bump Version**
   - Prompt for new version (patch/minor/major)
   - Update all 6 version files
   - Commit version bump

6. **Step 5: Build & Verify**
   - Build package
   - Verify version in build artifacts
   - Run tests against built package

7. **Step 6: Deploy to PyPI**
   - Publish to PyPI
   - Verify deployment

8. **Step 7: Update .pilot-version Files**
   - Update .claude/.pilot-version
   - Update templates/.claude/.pilot-version
   - Verify all 6 files show new version

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/999_publish` Step 0.5 | Syncs templates | `.claude/` → `src/claude_pilot/templates/.claude/` |
| `/999_publish` Step 4 | Checks version | Reads all 6 version files |
| `/999_publish` Step 5 | Updates version | Writes to all 6 version files |
| `scripts/sync-templates.sh` | Automates sync | Called by Step 0.5 |
| `scripts/verify-version-sync.sh` | Verifies sync | Called after version update |

### Version File Locations

| File | Path | Purpose |
|------|------|---------|
| pyproject.toml | `/pyproject.toml` | Source of truth for package version |
| __init__.py | `/src/claude_pilot/__init__.py` | Runtime version access |
| config.py | `/src/claude_pilot/config.py` | Configuration version |
| install.sh | `/install.sh` | Installation script version |
| .pilot-version | `/.claude/.pilot-version` | Development template version |
| templates/.pilot-version | `/src/claude_pilot/templates/.claude/.pilot-version` | Deployment template version |

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

## CONTEXT.md Pattern (3-Tier Documentation)

### Purpose

CONTEXT.md files provide Tier 2 (Component-level) documentation for major folders, enabling efficient navigation and context discovery.

### Folder Structure

```
.claude/
├── commands/CONTEXT.md       # Command workflow and file list
├── guides/CONTEXT.md         # Guide usage and methodology patterns
├── skills/CONTEXT.md         # Skill list and auto-discovery mechanism
└── agents/CONTEXT.md         # Agent types and model allocation
```

### Standard Template

```markdown
# {Folder Name} Context

## Purpose
[What this folder does]

## Key Files
| File | Purpose | Lines |
|------|---------|-------|

## Common Tasks
- **Task**: Description

## Patterns
[Key patterns in this folder]

## Related Documentation
[Links to related guides, skills, commands]
```

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| CLAUDE.md | Links to CONTEXT.md files | Tier 1 → Tier 2 navigation |
| CONTEXT.md | Links to individual files | Component → File discovery |
| Individual files | Reference CONTEXT.md | File → Component context |

### Benefits

- **Fast Navigation**: Jump directly to relevant files
- **Context Discovery**: Understand folder purpose without opening all files
- **Token Efficiency**: CONTEXT.md loaded only when navigating to folder
- **Maintainability**: Single source of truth for folder structure

---

## Related Documentation

- `.claude/guides/prp-framework.md` - Problem-Requirements-Plan definition
- `.claude/guides/claude-code-standards.md` - Official Claude Code standards (NEW)
- `.claude/commands/CONTEXT.md` - Command folder context (NEW)
- `.claude/guides/CONTEXT.md` - Guide folder context (NEW)
- `.claude/skills/CONTEXT.md` - Skill folder context (NEW)
- `.claude/agents/CONTEXT.md` - Agent folder context (NEW)
- `.claude/skills/documentation-best-practices/SKILL.md` - Documentation standards (NEW)
- `.claude/skills/vibe-coding/SKILL.md` - Code quality standards
- `.claude/guides/gap-detection.md` - External service verification
- `.claude/skills/tdd/SKILL.md` - Test-driven development
- `.claude/skills/ralph-loop/SKILL.md` - Autonomous iteration
- `.claude/guides/parallel-execution.md` - Parallel execution patterns

---

## Agent Invocation Patterns

### Agent File Format (YAML Frontmatter)

As of v3.2.0, all agent files use official Claude Code CLI YAML format:

**Valid Format**:
```yaml
---
name: coder
description: TDD implementation agent
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
skills: tdd, ralph-loop, vibe-coding, git-master
---

You are the Coder Agent. Implement features using TDD...
```

**Format Requirements**:
- `tools`: Comma-separated string (NOT array)
- `skills`: Comma-separated string (NOT array)
- `instructions`: Body content after `---` (NOT frontmatter field)

### Imperative Command Structure

As of v3.2.0, all agent invocations use **MANDATORY ACTION** sections with imperative language to ensure reliable agent delegation.

#### Pattern Structure

```markdown
### 🚀 MANDATORY ACTION: {Action Name}

> **YOU MUST invoke the following agents NOW using the Task tool.**
> This is not optional. Execute these Task tool calls immediately.

**EXECUTE IMMEDIATELY - DO NOT SKIP**:

[Specific Task tool calls with parameters]

**VERIFICATION**: After sending Task calls, wait for agents to return results before proceeding.
```

#### Key Components

| Component | Purpose | Example |
|-----------|---------|---------|
| 🚀 MANDATORY ACTION header | Visual emphasis for blocking action | "Parallel Agent Invocation" |
| YOU MUST invoke... NOW | Direct imperative command | "YOU MUST invoke the following agents NOW" |
| EXECUTE IMMEDIATELY - DO NOT SKIP | Emphasis on blocking nature | Prevents skipping to later steps |
| VERIFICATION instruction | Wait directive | "wait for both agents to return" |
| "send in same message" | Parallel execution hint | For concurrent Task calls |

### Command-Specific Patterns

| Command | Step | Agents | Pattern |
|---------|------|--------|---------|
| `/00_plan` | Step 0 | explorer + researcher | Parallel: "send in same message" |
| `/01_confirm` | Step 4 | plan-reviewer | Sequential: Single Task call |
| `/02_execute` | Step 2.3 | Multiple coders | Parallel: One Task call per independent SC |
| `/02_execute` | Step 2.4 | tester + validator + code-reviewer | Parallel: "send in same message" |
| `/02_execute` | Step 3 | coder | Sequential: Single Task call with TDD |
| `/03_close` | Step 5 | documenter | Sequential: Single Task call |
| `/90_review` | Main | plan-reviewer | Sequential or parallel (3-angle) |
| `/91_document` | Main | documenter | **OPTIONAL**: May use main thread |

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
- Uses **MANDATORY ACTION** section at Step 0
- Two Task calls sent in **same message** for true parallelism
- Explorer returns: Explored Files table, Key Decisions
- Researcher returns: Research Findings table with sources
- VERIFICATION checkpoint ensures both complete before proceeding

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
- Uses **MANDATORY ACTION** sections at Steps 2.3 and 2.4
- SC dependency analysis before parallel execution
- Independent SCs run concurrently (one Task call per SC)
- Verification agents run in parallel after integration
- VERIFICATION checkpoints after each parallel phase
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
**Template**: claude-pilot 3.3.1
