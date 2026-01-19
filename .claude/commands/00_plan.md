---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore codebase, gather requirements, and design SPEC-First execution plan._

## Core Philosophy

- **Read-Only**: NO code modifications. Only exploration, analysis, and planning
- **SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
- **Collaborative**: Dialogue with user to clarify ambiguities

> **⚠️ LANGUAGE**: All plan documents MUST be in English, regardless of conversation language
> **⚠️ CRITICAL**: /00_plan is read-only. Implementation starts ONLY after `/01_confirm` → `/02_execute`

**Full methodology**: @.claude/guides/prp-framework.md

---

## Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan, Ask questions
- **CANNOT DO**: Edit files, Write files, Create code, Implement
- **EXIT VIA**: User explicitly runs `/01_confirm` or `/02_execute`

### MANDATORY: Ambiguous Confirmation Handling

> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion` before ANY phase transition

**When to Call**: Plan discussion appears complete OR user provides ambiguous confirmation ("go ahead", "proceed")

**NEVER use Yes/No questions** - always provide explicit multi-option choices:

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

**Valid Execution Triggers**: User types `/01_confirm` or `/02_execute`, says "start coding", or selects option C/D

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before planning
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Architecture decision | Keywords: "tradeoffs", "design", "structure", "architecture" | Delegate to GPT Architect |
| User explicitly requests | "ask GPT", "consult GPT", "review architecture" | Delegate to GPT Architect |

### Delegation Flow

1. **STOP**: Scan user input for trigger signals
2. **MATCH**: Identify expert type from triggers
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/architect.md`
4. **CHECK**: Verify Codex CLI is installed (graceful fallback if not)
5. **EXECUTE**: Call `codex-sync.sh "read-only" "<prompt>"` or continue with Claude agents
6. **CONFIRM**: Log delegation decision

### Graceful Fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

---

## Step 0: Requirements & Exploration

> **Full methodology**: @.claude/guides/requirements-tracking.md | @.claude/guides/parallel-execution.md

**Requirements**: Collect verbatim input, assign UR-IDs, build table (see guide)
**Exploration**: Invoke Explorer + researcher agents in parallel (see guide)

**Reading Checklist**:
| File/Folder | Purpose |
|-------------|---------|
| `CLAUDE.md` | Project overview |
| `.claude/commands/*.md` | Existing patterns |
| `.claude/guides/*.md` | Methodology guides |
| `src/` or `lib/` | Main structure |

---

## Step 1: Design PRP (What/Why/How/Success Criteria)

> **Full methodology**: @.claude/guides/prp-framework.md

**What**: Objective, scope (in/out), deliverables
**Why**: Current problem, business value, background
**How**: Implementation strategy, dependencies, risks
**Success Criteria**: Measurable, complete, testable

---

## Step 2: Design Test Plan

> **Full methodology**: @.claude/guides/test-plan-design.md

**MANDATORY**: Test scenarios with test file paths

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | [Happy path] | [input] | [output] | [Unit/Integration] | [path] |
| TS-2 | [Edge case] | [input] | [output] | [Unit] | [path] |
| TS-3 | [Error] | [input] | [output] | [Integration] | [path] |

**Test Environment** (auto-detected): Project type, framework, commands, directory

---

## Step 3: Constraints & Risks

**Constraints**: Technical, business, quality
**Risks**: | Risk | Likelihood | Impact | Mitigation |

---

## Step 2.5: Generate Granular Todos (MANDATORY)

> **🚨 CRITICAL**: Break down Success Criteria into granular todos before plan finalization
> **Full guide**: @.claude/guides/todo-granularity/SKILL.md

### Granularity Rules

**Rule 1: Time Rule (≤15 Minutes)**
- Every todo must be completable in 15 minutes or less
- Estimate: Read (2-3 min) + Implement (5-10 min) + Test (2-3 min)
- Warning signs: Contains "and", spans multiple files, vague words like "implement"

**Rule 2: Owner Rule (Single Agent)**
- Every todo must have ONE clear owner agent
- Agent types: coder, tester, validator, documenter, explorer, researcher
- Warning signs: "Implement and test" (coder + tester), "Write code and docs" (coder + documenter)

**Rule 3: Atomic Rule (One File/Component)**
- Every todo must modify ONE file or component
- Scope: New file, Edit file, Delete, Test file
- Warning signs: Multiple file paths in single todo

### Todo Generation Process

1. **Extract Success Criteria** from PRP analysis
2. **Break down each SC** into granular todos following the 3 rules
3. **Assign owner** to each todo (coder, tester, validator, documenter, etc.)
4. **Estimate time** for each todo (target: ≤15 minutes)
5. **Verify granularity** using the checklist below

### Granularity Verification Checklist

For each todo, verify:
- [ ] Time: Can be completed in ≤15 minutes?
- [ ] Owner: Has single, clear owner agent?
- [ ] Atomic: Modifies only ONE file/component?
- [ ] Specific: Clear what "done" looks like?
- [ ] Testable: Can be verified independently?

### Warning System

If ANY todo violates the 3 rules:
1. **WARN** user in plan document
2. **SUGGEST** breaking down into smaller todos
3. **PROVIDE** examples from @.claude/guides/todo-granularity/SKILL.md

### Todo Templates by Task Type

**Feature Implementation**:
```
- SC-N: Create [component] in [file path] (coder, 10 min)
- SC-N+1: Write tests for [component] (tester, 5 min)
- SC-N+2: Verify [component] coverage ≥80% (validator, 2 min)
```

**Bug Fix**:
```
- SC-N: Fix [specific bug] in [file:line] (coder, 10 min)
- SC-N+1: Add regression test for [bug] (tester, 5 min)
- SC-N+2: Verify fix with test suite (validator, 2 min)
```

**Refactoring**:
```
- SC-N: Extract [logic] to [new file] (coder, 10 min)
- SC-N+1: Update imports in [affected files] (coder, 5 min)
- SC-N+2: Write tests for [extracted logic] (tester, 5 min)
- SC-N+3: Verify all tests still pass (validator, 2 min)
```

**Documentation**:
```
- SC-N: Update [file] with [content] (documenter, 10 min)
- SC-N+1: Verify documentation accuracy (validator, 2 min)
```

### Integration with Continuation System

Granular todos enable the Sisyphus continuation system:
- **Checkpoints**: Each todo is a continuation checkpoint
- **Progress**: Clear progress tracking across agent invocations
- **Resumption**: Easy to resume from incomplete todo
- **Completion**: Higher likelihood of full completion

### Output

Add to plan document under "Execution Plan" section:
```markdown
## Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1 | Create login endpoint in src/auth/login.ts | coder | 10 min | pending |
| SC-2 | Write login endpoint tests | tester | 5 min | pending |
| SC-3 | Verify login coverage ≥80% | validator | 2 min | pending |

**Granularity Verification**: ✅ All todos comply with 3 rules
**Warnings**: None
```

---

## Step 3: Present Plan and Guide to Next Step

> **🚨 CRITICAL**: After presenting plan, you MUST call `AskUserQuestion`

**Present Plan Summary**: Show the user a concise summary of the plan including:
- User Requirements (UR-1, UR-2, ...)
- Success Criteria (SC-1, SC-2, ...)
- High-level execution approach

**Guide to Next Step**:
```markdown
Your plan is ready! To proceed with execution, run:

  /01_confirm

This will save your plan to `.pilot/plan/draft/`, run automated reviews, and prepare it for execution.

AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan and prepare for execution)
  D) Run /02_execute (start implementation immediately)
```

**Proceed only AFTER user selects explicit option (C or D for execution)**

---

## Success Criteria

- [ ] User requirements table created (UR-1, UR-2, ...)
- [ ] Parallel exploration completed (Explorer + researcher + Test Env)
- [ ] PRP analysis complete (What/Why/How/Success Criteria)
- [ ] Test scenarios defined with test file paths
- [ ] Test environment detected and documented
- [ ] Constraints and risks identified
- [ ] Granular todos generated (≤15 min each, single owner)
- [ ] User guided to run `/01_confirm` for plan save and review
- [ ] `AskUserQuestion` called for ambiguous confirmation
- [ ] **NO plan file created** (plan saved only by `/01_confirm`)

---

## Related Guides

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Requirements Tracking**: @.claude/guides/requirements-tracking.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment Detection**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **PRP Template**: @.claude/templates/prp-template.md

---

## Next Command

- `/01_confirm` - **REQUIRED**: Save plan to draft, run automated reviews, prepare for execution
- `/02_execute` - Start implementation immediately (skip review only if user confirms)
