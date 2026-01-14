# Parallel Workflow Optimization
- Generated: 2026-01-15 06:01:47 | Work: parallel_workflow_optimization | Location: .pilot/plan/pending/

## User Requirements

1. **Performance Priority**: Speed + context isolation through parallelization (cost is not a concern)
2. **Parallel Execution**: Maximize parallel execution across ALL phases (plan, execute, review)
3. **New Agent Types**: Add specialized agents (researcher, tester, validator)
4. **Command Updates**: Update command files with proper parallel agent invocation patterns
5. **Official Compliance**: Follow Claude Code official guide for subagent configuration

## PRP Analysis

### What (Functionality)

**Objective**: Optimize claude-pilot workflow for maximum parallel execution by adding new specialized agents and updating commands

**Scope**:
- **In scope**:
  - Create 3 new agents (researcher.md, tester.md, validator.md)
  - Update existing agent (coder.md for SC-based parallel support)
  - Update command files (00_plan.md, 02_execute.md, 90_review.md) with parallel execution patterns
  - Create parallel execution guide
- **Out of scope**:
  - Git worktree based isolation (separate work)
  - Docker container isolation (infrastructure dependent)
  - External orchestrator build

### Why (Context)

**Current Problem**:
- `/02_execute` takes too long due to sequential TDD + Ralph Loop
- Agent definitions exist but no parallel invocation strategy
- Verification (tests, type, lint) runs sequentially - inefficient
- Planning phase exploration and research are sequential

**Desired State**:
```
Current: [Explore] → [Research] → [Implement] → [Test] → [Type] → [Lint] → [Docs]
Target:  [Explore || Research] → [Impl1 || Impl2] → [Test || Type || Lint] → [Docs]
```

- Plan: Explorer + Researcher parallel execution
- Execute: SC-based Coder parallel + Validator parallel
- Review: 6-angle parallel review

**Business Value**:
- 50-70% execution time reduction (estimated)
- 8x token efficiency through context isolation
- Quality improvement through agent specialization

### How (Approach)

- **Phase 1**: Discovery - Analyze current agents and identify parallelization points ✅
- **Phase 2**: Design - Define new agents and parallel execution patterns ✅
- **Phase 3**: Implementation (TDD)
  - Create new agent files (researcher.md, tester.md, validator.md)
  - Update command files (00_plan, 02_execute, 90_review)
  - Update coder.md for SC-based parallel support
  - Create parallel execution guide
- **Phase 4**: Verification - Test execution and document verification
- **Phase 5**: Handoff - Documentation update

### Success Criteria

SC-1: researcher.md agent created
- Verify: `test -f .claude/agents/researcher.md`
- Expected: File exists with haiku model, WebSearch/WebFetch/query-docs tools

SC-2: tester.md agent created
- Verify: `test -f .claude/agents/tester.md`
- Expected: File exists with **sonnet** model, Read/Write/Bash tools

SC-3: validator.md agent created
- Verify: `test -f .claude/agents/validator.md`
- Expected: File exists with haiku model, Bash/Read tools

SC-4: 00_plan.md includes parallel exploration pattern
- Verify: `grep -c "Explorer.*Researcher\|parallel.*explor" .claude/commands/00_plan.md`
- Expected: ≥1 match with Task tool parallel invocation

SC-5: 02_execute.md includes parallel SC execution pattern
- Verify: `grep -c "Coder.*SC\|Tester.*Validator\|parallel" .claude/commands/02_execute.md`
- Expected: ≥3 matches with dependency analysis and parallel invocation

SC-6: 90_review.md includes multi-angle parallel review
- Verify: `grep -c "parallel.*review\|Security.*Quality" .claude/commands/90_review.md`
- Expected: ≥1 match with parallel angle review

SC-7: coder.md updated for SC-based parallel
- Verify: `grep -c "SC-based\|parallel" .claude/agents/coder.md`
- Expected: ≥1 match

SC-8: parallel-execution.md guide created
- Verify: `test -f .claude/guides/parallel-execution.md`
- Expected: File exists with all parallel patterns documented

SC-9: plan-reviewer.md agent created
- Verify: `test -f .claude/agents/plan-reviewer.md`
- Expected: File exists with **sonnet** model, plan review instructions

SC-10: reviewer.md renamed to code-reviewer.md with opus model
- Verify: `test -f .claude/agents/code-reviewer.md && grep "model:" .claude/agents/code-reviewer.md`
- Expected: `model: opus`

SC-11: /00_plan.md calls explorer agent
- Verify: `grep -c "explorer\|Explorer" .claude/commands/00_plan.md`
- Expected: ≥2 (Task invocation pattern)

SC-12: /01_confirm.md calls plan-reviewer agent
- Verify: `grep -c "plan-reviewer" .claude/commands/01_confirm.md`
- Expected: ≥1

SC-13: /02_execute.md calls code-reviewer agent
- Verify: `grep -c "code-reviewer" .claude/commands/02_execute.md`
- Expected: ≥1

SC-14: /90_review.md calls plan-reviewer agent
- Verify: `grep -c "plan-reviewer" .claude/commands/90_review.md`
- Expected: ≥1

### Constraints

- Must follow official Claude Code subagent format
- Must preserve existing functionality (no breaking changes)
- English only for all documentation
- Model allocation based on task complexity:
  - **Haiku**: explorer, researcher, validator (lint/type), documenter
  - **Sonnet**: coder, tester, **plan-reviewer** (plan analysis)
  - **Opus**: **code-reviewer** (critical code review, deep reasoning)

## Scope

### Files to Create

| File | Purpose | Model | Tools |
|------|---------|-------|-------|
| `.claude/agents/researcher.md` | External research specialist | haiku | WebSearch, WebFetch, query-docs |
| `.claude/agents/tester.md` | Test writing specialist | **sonnet** | Read, Write, Bash |
| `.claude/agents/validator.md` | Verification specialist (type, lint, coverage) | haiku | Bash, Read |
| `.claude/agents/plan-reviewer.md` | **Plan review specialist** (Gap Detection, completeness) | **sonnet** | Read, Glob, Grep |
| `.claude/guides/parallel-execution.md` | Parallel execution patterns guide | N/A | N/A |

### Files to Modify

| File | Purpose |
|------|---------|
| `.claude/commands/00_plan.md` | Add parallel exploration (Explorer + Researcher), **add explorer agent call** |
| `.claude/commands/01_confirm.md` | **Add plan-reviewer agent call** for Gap Detection |
| `.claude/commands/02_execute.md` | Add parallel SC execution (Coder + Tester + Validator), **add code-reviewer call** |
| `.claude/commands/90_review.md` | **Add plan-reviewer agent call** for multi-angle review |
| `.claude/agents/coder.md` | Support SC-based parallel implementation |
| `.claude/agents/reviewer.md` | **Rename to code-reviewer.md**, update model: haiku → **opus** |

### Out of Scope

| Item | Reason |
|------|--------|
| Git worktree isolation | Separate work item |
| Docker container isolation | Infrastructure dependent |
| External orchestrator | Over-engineering |
| Template changes | Not related to parallelization |

## Test Environment (Detected)

- Project Type: Python
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/agents/explorer.md` | Exploration agent | 1-64 | Haiku model, Glob/Grep/Read |
| `.claude/agents/coder.md` | Implementation agent | 1-264 | Sonnet model, TDD+Ralph |
| `.claude/agents/reviewer.md` | Review agent | 1-194 | Haiku, 6 angles |
| `.claude/agents/documenter.md` | Documentation agent | 1-203 | Haiku, 3-Tier |
| `.claude/commands/02_execute.md` | Execute command | 1-387 | Step 3 delegates to Coder Agent |

### Research Findings

| Source | Topic | Key Insight | URL |
|--------|-------|-------------|-----|
| Anthropic Official | Claude Code Best Practices | "Have one Claude write code; use another Claude to verify" | https://www.anthropic.com/engineering/claude-code-best-practices |
| Simon Willison | Parallel Agents | Research, verification, maintenance tasks are suitable for parallelization | https://simonwillison.net/2025/Oct/5/parallel-coding-agents/ |
| Dev.to Multi-Agent | 10+ Agents | Task Queue + File Locking + Quality Gate pattern | https://dev.to/bredmond1019/multi-agent-orchestration |
| Medium | Parallel Workflows | "One writes, one reviews, one tests" pattern | https://medium.com/@joe.njenga |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Use existing .claude/agents/ structure | Reuse already defined patterns | AGENTS.md separate file (not Claude standard) |
| SC-based parallel implementation | Independent SCs can be implemented simultaneously | Keep sequential implementation |
| Haiku for exploration/review/validation | Cost efficient + sufficient performance | Use Sonnet for everything |
| Sonnet for Coder only | Implementation requires high quality | Use Opus |

### Implementation Patterns (FROM CONVERSATION)

#### /00_plan Parallel Exploration Pattern
> **FROM CONVERSATION:**
> ```
> ┌─────────────────────────────────────────────────┐
> │              Main Orchestrator                  │
> └────────┬────────────────────────────────────────┘
>          │ Parallel Task calls
>          ▼
> ┌────────────────┐  ┌────────────────┐
> │   Explorer     │  │   Researcher   │
> │   (Haiku)      │  │   (Haiku)      │
> │ Glob/Grep/Read │  │ WebSearch/Docs │
> └────────┬───────┘  └────────┬───────┘
>          │                   │
>          └───────┬───────────┘
>                  ▼
>          [Result Merge → Plan Creation]
> ```

#### /02_execute Parallel SC Implementation Pattern
> **FROM CONVERSATION:**
> ```
> ┌─────────────────────────────────────────────────┐
> │              Main Orchestrator                  │
> └────────┬────────────────────────────────────────┘
>          │ Parallel Task calls (per SC)
>          ▼
> ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
> │  Coder-SC1   │ │  Coder-SC2   │ │  Coder-SC3   │
> │  (Sonnet)    │ │  (Sonnet)    │ │  (Sonnet)    │
> │  TDD Cycle   │ │  TDD Cycle   │ │  TDD Cycle   │
> └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
>        │                │                │
>        └────────┬───────┴────────────────┘
>                 ▼
>          [Result Integration]
>                 ▼
> ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
> │   Tester     │ │  Validator   │ │  Documenter  │
> │  (Haiku)     │ │  (Haiku)     │ │  (Haiku)     │
> │  Tests Run   │ │ Type+Lint+Cov│ │  3-Tier Docs │
> └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
>        │                │                │
>        └────────┬───────┴────────────────┘
>                 ▼
>          [Ralph Loop Verification]
> ```

#### /90_review Multi-Angle Parallel Review Pattern
> **FROM CONVERSATION:**
> ```
> ┌─────────────────────────────────────────────────┐
> │              Main Orchestrator                  │
> └────────┬────────────────────────────────────────┘
>          │ Parallel Task calls (6 angles)
>          ▼
> ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
> │Security │ │Quality  │ │Testing  │ │Perf     │
> │Reviewer │ │Reviewer │ │Reviewer │ │Reviewer │
> └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
>      │           │           │           │
>      └───────────┴─────┬─────┴───────────┘
>                        ▼
>               [Comprehensive Report Merge]
> ```

#### New Agent Specifications (UPDATED based on official guide)
> **Model Selection Rationale:**
> - "Use Opus for deep review—catches async bugs, memory leaks, subtle logic errors"
> - "Sonnet can break down a complex problem into multi-step plans"
> - "Haiku for simple, repetitive tasks like linting"
>
> | Agent | Model | Tools | Purpose |
> |-------|-------|-------|---------|
> | researcher | haiku | WebSearch, WebFetch, query-docs | External docs/API research |
> | tester | **sonnet** | Read, Write, Bash | Complex test logic requires quality |
> | validator | haiku | Bash, Read | Type check + Lint + Coverage (repetitive) |
> | **plan-reviewer** | **sonnet** | Read, Glob, Grep | Plan analysis, Gap Detection, completeness |
> | **code-reviewer** | **opus** | Read, Glob, Grep, Bash | Critical code review (deep reasoning) |

## Architecture

### Current Architecture
```
/00_plan → /01_confirm → /02_execute → /03_close
                              │
                              └─► Single Coder Agent (sequential SC)
```

### Target Architecture
```
/00_plan ─────────────────────► /01_confirm → /02_execute → /03_close
    │                                              │
    ├─► Explorer (architecture)                    ├─► Coder-SC1 (parallel)
    └─► Researcher (external docs)                 ├─► Coder-SC2 (parallel)
              ↓                                    └─► Coder-SC3 (parallel)
    [Result Merge → Plan]                                   ↓
                                                   [Result Integration]
                                                           ↓
                                            ├─► Tester (tests run)
                                            ├─► Validator (type+lint+cov)
                                            └─► Documenter (3-tier docs)
                                                           ↓
                                                   [Ralph Loop]
```

### Dependency Graph
```
[00_plan]
    ├── Explorer Agent (parallel)
    └── Researcher Agent (parallel)
            ↓
[02_execute]
    ├── Coder-SC1 (parallel, independent SC)
    ├── Coder-SC2 (parallel, independent SC)
    └── Coder-SC3 (parallel, independent SC)
            ↓ (after integration)
    ├── Tester Agent (parallel)
    ├── Validator Agent (parallel)
    └── Documenter Agent (parallel)
            ↓
[90_review]
    ├── Security Reviewer (parallel)
    ├── Quality Reviewer (parallel)
    ├── Testing Reviewer (parallel)
    └── Performance Reviewer (parallel)
```

### File Changes Summary
```
.claude/
├── agents/
│   ├── researcher.md        # NEW: External research specialist (haiku)
│   ├── tester.md            # NEW: Test writing specialist (sonnet)
│   ├── validator.md         # NEW: Verification specialist (haiku)
│   ├── plan-reviewer.md     # NEW: Plan review specialist (sonnet)
│   ├── code-reviewer.md     # RENAME from reviewer.md + model → opus
│   ├── coder.md             # UPDATE: SC-based parallel support
│   └── explorer.md          # EXISTING: Will be called from 00_plan
├── commands/
│   ├── 00_plan.md           # UPDATE: Parallel exploration + explorer agent call
│   ├── 01_confirm.md        # UPDATE: plan-reviewer agent call
│   ├── 02_execute.md        # UPDATE: Parallel SC + code-reviewer call
│   └── 90_review.md         # UPDATE: plan-reviewer agent call
└── guides/
    └── parallel-execution.md # NEW: Parallel patterns guide
```

## Vibe Coding Compliance

| Target | Limit | Status |
|--------|-------|--------|
| Functions | ≤50 lines | N/A (no code) |
| Files | ≤200 lines | ✅ All agent files will be <200 lines |
| Nesting | ≤3 levels | N/A (markdown) |

## Execution Plan

### Phase 1: Create New Agents
1. Create `.claude/agents/researcher.md`
   - Model: haiku
   - Tools: WebSearch, WebFetch, mcp__plugin_context7_context7__query-docs
   - Instructions: External documentation and API research
2. Create `.claude/agents/tester.md`
   - Model: haiku
   - Tools: Read, Write, Bash
   - Instructions: Test writing and execution
3. Create `.claude/agents/validator.md`
   - Model: haiku
   - Tools: Bash, Read
   - Instructions: Type check, lint, coverage verification

### Phase 1.5: Create Plan-Reviewer Agent
1. Create `.claude/agents/plan-reviewer.md`
   - Model: **sonnet**
   - Tools: Read, Glob, Grep
   - Instructions: Gap Detection, completeness check, plan quality analysis

### Phase 2: Update Existing Agents
1. Update `.claude/agents/coder.md`
   - Add SC-based parallel implementation support
   - Add file locking awareness for parallel execution
2. **Rename** `.claude/agents/reviewer.md` → `.claude/agents/code-reviewer.md`
   - Change model: haiku → **opus**
   - Update description: "Critical code review agent (deep reasoning)"
   - Add note about async bugs, memory leaks detection

### Phase 3: Update Command Files
1. Update `.claude/commands/00_plan.md`
   - Add Step 0: Parallel Exploration with **Explorer + Researcher agents**
   - Add Task tool invocation examples for parallel calls
2. Update `.claude/commands/01_confirm.md`
   - Add **plan-reviewer agent call** for Gap Detection
   - Replace inline review logic with agent delegation
3. Update `.claude/commands/02_execute.md`
   - Add SC dependency analysis
   - Add parallel Coder invocation pattern
   - Add Tester + Validator + Documenter parallel phase
   - Add **code-reviewer agent call** after implementation
   - Update Ralph Loop for parallel verification
4. Update `.claude/commands/90_review.md`
   - Add **plan-reviewer agent call** for multi-angle review
   - Add result merge strategy

### Phase 4: Create Guide
1. Create `.claude/guides/parallel-execution.md`
   - Document all parallel patterns
   - Include Task tool syntax
   - Include dependency analysis rules
   - Include file conflict prevention

### Phase 5: Verification
1. Run grep commands for all SC
2. Verify agent frontmatter matches official format
3. Verify markdown syntax

## Acceptance Criteria

| ID | Criterion | Verification |
|----|-----------|--------------|
| AC-1 | researcher.md exists with haiku | `grep -c "model: haiku" .claude/agents/researcher.md` |
| AC-2 | tester.md exists with sonnet | `grep -c "model: sonnet" .claude/agents/tester.md` |
| AC-3 | validator.md exists with haiku | `grep -c "model: haiku" .claude/agents/validator.md` |
| AC-4 | plan-reviewer.md exists with sonnet | `grep -c "model: sonnet" .claude/agents/plan-reviewer.md` |
| AC-5 | code-reviewer.md exists with opus | `grep -c "model: opus" .claude/agents/code-reviewer.md` |
| AC-6 | 00_plan.md calls explorer agent | `grep -i "explorer" .claude/commands/00_plan.md` |
| AC-7 | 01_confirm.md calls plan-reviewer | `grep -i "plan-reviewer" .claude/commands/01_confirm.md` |
| AC-8 | 02_execute.md calls code-reviewer | `grep -i "code-reviewer" .claude/commands/02_execute.md` |
| AC-9 | 90_review.md calls plan-reviewer | `grep -i "plan-reviewer" .claude/commands/90_review.md` |
| AC-10 | coder.md has SC-based parallel | `grep -i "sc-based\|parallel" .claude/agents/coder.md` |
| AC-11 | parallel-execution.md guide exists | `test -f .claude/guides/parallel-execution.md` |
| AC-12 | reviewer.md removed/renamed | `test ! -f .claude/agents/reviewer.md` |

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Verify researcher agent | `grep "model:" researcher.md` | `model: haiku` | Manual | N/A |
| TS-2 | Verify tester agent | `grep "model:" tester.md` | `model: sonnet` | Manual | N/A |
| TS-3 | Verify validator agent | `grep "model:" validator.md` | `model: haiku` | Manual | N/A |
| TS-4 | Verify plan-reviewer | `grep "model:" plan-reviewer.md` | `model: sonnet` | Manual | N/A |
| TS-5 | Verify code-reviewer | `grep "model:" code-reviewer.md` | `model: opus` | Manual | N/A |
| TS-6 | Verify explorer call | `grep -c "explorer" 00_plan.md` | ≥2 | Manual | N/A |
| TS-7 | Verify plan-reviewer call | `grep -c "plan-reviewer" 01_confirm.md` | ≥1 | Manual | N/A |
| TS-8 | Verify code-reviewer call | `grep -c "code-reviewer" 02_execute.md` | ≥1 | Manual | N/A |
| TS-9 | Verify 90_review agent | `grep -c "plan-reviewer" 90_review.md` | ≥1 | Manual | N/A |
| TS-10 | Verify guide exists | `test -f parallel-execution.md` | File exists | Manual | N/A |
| TS-11 | Verify reviewer.md removed | `test ! -f reviewer.md` | File not exists | Manual | N/A |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Parallel agents edit same file | Medium | High | Dependency analysis in 02_execute prevents this |
| Increased API costs | Low | Low | User stated cost is not a concern |
| Context merge conflicts | Low | Medium | Clear merge strategy in guide |
| Breaking existing workflow | Low | High | Preserve all existing functionality |
| Agent file locking race | Medium | Medium | Sequential fallback for dependent SCs |

## Open Questions

1. **Resolved**: Should we create new specialized agents? → Yes, 3 new agents (researcher, tester, validator)
2. **Resolved**: Which model for new agents? → Haiku (cost efficient, sufficient for tasks)
3. **Resolved**: Where to document parallel patterns? → New guide + inline in commands
4. **Resolved**: How to handle file conflicts? → Dependency analysis before parallel execution

---

## Execution Summary
*Completed: 2026-01-15*

### Implementation Complete ✅
- **Success Criteria Met**: All 14/14 success criteria verified
- **Files Changed**: 12
  - `.claude/agents/researcher.md` - NEW: External research specialist (haiku)
  - `.claude/agents/tester.md` - NEW: Test writing specialist (sonnet)
  - `.claude/agents/validator.md` - NEW: Verification specialist (haiku)
  - `.claude/agents/plan-reviewer.md` - NEW: Plan review specialist (sonnet)
  - `.claude/agents/code-reviewer.md` - RENAMED from reviewer.md + model → opus
  - `.claude/agents/coder.md` - UPDATED: SC-based parallel support added
  - `.claude/commands/00_plan.md` - UPDATED: Parallel exploration pattern (Explorer + Researcher agents)
  - `.claude/commands/01_confirm.md` - UPDATED: plan-reviewer agent call
  - `.claude/commands/02_execute.md` - UPDATED: Parallel SC execution + code-reviewer call
  - `.claude/commands/90_review.md` - UPDATED: plan-reviewer agent call + parallel multi-angle review
  - `.claude/guides/parallel-execution.md` - NEW: Parallel patterns guide
  - `.claude/agents/reviewer.md` - REMOVED (renamed to code-reviewer.md)

### Verification Results
All 14 success criteria verified:
- SC-1: researcher.md created ✅
- SC-2: tester.md created ✅
- SC-3: validator.md created ✅
- SC-4: 00_plan.md parallel exploration ✅
- SC-5: 02_execute.md parallel SC execution ✅
- SC-6: 90_review.md parallel review ✅
- SC-7: coder.md SC-based parallel ✅
- SC-8: parallel-execution.md guide created ✅
- SC-9: plan-reviewer.md created ✅
- SC-10: code-reviewer.md with opus ✅
- SC-11: 00_plan.md explorer agent ✅
- SC-12: 01_confirm.md plan-reviewer ✅
- SC-13: 02_execute.md code-reviewer ✅
- SC-14: 90_review.md plan-reviewer ✅

### Ralph Loop Iterations
- Total: 0 iterations (all changes completed on first pass)
- Final Status: Complete

### Follow-ups
- None - All success criteria met and verified
