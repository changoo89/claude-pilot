---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore codebase, gather requirements, and design SPEC-First execution plan._

## Core Philosophy

- **Read-Only**: NO code modifications. Only exploration, analysis, and planning.
- **SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation.
- **Collaborative**: Dialogue with user to clarify ambiguities.

> **⚠️ LANGUAGE - PLAN OUTPUT**: All plan documents MUST be written in English, regardless of conversation language.

> **⚠️ CRITICAL**: /00_plan is read-only. Implementation starts ONLY after `/01_confirm` → `/02_execute`.
> - ❌ NO: Code editing, test writing, file creation
> - ✅ OK: Exploration (Glob, Grep, Read), Analysis, Planning

---

## Phase Boundary Protection

### Current Phase: PLANNING

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan, Ask questions
- **CANNOT DO**: Edit files, Write files, Create code, Implement
- **EXIT VIA**: User explicitly runs `/01_confirm` or `/02_execute`

### MANDATORY ACTION: Ambiguous Confirmation Handling

> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion` before ANY phase transition.
>
> **CRITICAL**: Do NOT try to detect specific words or phrases. ANY ambiguous confirmation (e.g., "go ahead", "proceed", "that looks good", "알아서 해", "그래 그렇게 해") MUST trigger the `AskUserQuestion` flow below.
>
> **NEVER use Yes/No questions** - always provide explicit multi-option choices.

#### When to Call AskUserQuestion

Call `AskUserQuestion` when plan discussion appears complete, user provides ambiguous confirmation ("go ahead", "proceed", "알아서 해"), OR ANY uncertainty about intent.

#### AskUserQuestion Template (MANDATORY)

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

Proceed only AFTER user selects explicit option (C or D for execution).

### Valid Execution Triggers

**ONLY these triggers allow phase transition to execution**:
1. User explicitly types `/01_confirm` or `/02_execute`
2. User explicitly says "start coding now" or "begin implementation"
3. User selects option C or D from AskUserQuestion above

**All other responses** → Continue planning or AskUserQuestion to clarify.

---

## Mandatory: Deep Project Understanding

> **⚠️ CRITICAL**: Before answering ANY question, you MUST:
> 1. Read ALL related files
> 2. Understand existing patterns
> 3. Map the architecture

**Reading Checklist**:
| File/Folder | Purpose |
|-------------|---------|
| `CLAUDE.md` | Project overview, conventions |
| `.claude/commands/*.md` | Existing patterns |
| `.claude/guides/*.md` | Methodology guides |
| `.claude/templates/*.md` | PRP, CONTEXT templates |
| `src/` or `lib/` | Main structure |
| `tests/` | Test patterns |

**Output Format**:
```markdown
🔍 Deep Project Understanding Results
Project: [Name] | Type: [Python/Node.js/Go/Rust]
Key Files: [list]
Existing Patterns: [list]
```

---

## Step 0: User Requirements Collection

> **Full methodology**: See @.claude/guides/requirements-tracking.md

> **Purpose**: Track ALL user requests verbatim to prevent omissions during long conversations

### 🎯 MANDATORY ACTION: Collect Requirements Immediately

> **YOU MUST collect user requirements BEFORE starting exploration.**
> This prevents requirements mentioned early in conversation from being forgotten.

**Quick Start**:
1. Collect verbatim input (original language, exact wording)
2. Assign UR-IDs (UR-1, UR-2, ...)
3. Build requirements table (see guide for template)
4. Update during conversation
5. Present in plan summary

> **⚠️ CRITICAL**: Do NOT start Step 1 until requirements table is created.
> This ensures ALL user input is captured before exploration begins.

---

## Step 1: Parallel Exploration

**Full details**: See @.claude/guides/parallel-execution.md - Pattern 1: Parallel Exploration

### 🚀 MANDATORY ACTION: Parallel Agent Invocation

> **YOU MUST invoke the following agents NOW using the Task tool.**
> This is not optional. Execute these Task tool calls immediately.

**Execute in parallel** (see guide for full Task call templates):
1. **Explorer Agent**: Explore codebase for related files, patterns, architecture
2. **researcher Agent**: Research external docs, best practices, code examples
3. **Main Thread**: Detect test environment (see @.claude/guides/test-environment.md)

### Agent Coordination

| Thread | Focus | Tools | Agent |
|--------|-------|-------|-------|
| Explore | Related code, patterns | Glob, Grep, Read | **Explorer Agent** |
| Research | External docs | WebSearch, query-docs | **researcher Agent** |
| **Test Env** | **Detect test framework** | **Glob, Read** | **Main (inline)** |

### Result Merge

After parallel agents complete:
1. **Explorer Summary**: Add to "Explored Files" table
2. **researcher Summary**: Add to "Research Findings" table
3. **Test Environment**: Add to plan as "Test Environment (Detected)" section
4. **Integration**: Merge findings, identify conflicts, update plan

> **⚠️ COLLECT FOR HANDOFF**: During exploration, collect:
> - Files read (path + purpose + key lines)
> - Research findings (source + topic + insight)
> - Discovered dependencies
> - Warnings & gotchas
> - Key decisions made
> **See**: Step 2 for execution context template

---

## Step 2: Compile Execution Context

> **Purpose**: Transfer planner's discoveries to executor without re-exploration

### Collect for Handoff

Collect these tables during exploration (becomes "Execution Context (Planner Handoff)" section):

| Table | Purpose |
|-------|---------|
| **Explored Files** | File, Purpose, Key Lines, Notes |
| **Research Findings** | Source, Topic, Key Insight, URL |
| **Discovered Dependencies** | Dependency, Version, Purpose, Status |
| **Warnings & Gotchas** | Issue, Location, Recommendation |
| **Key Decisions Made** | Decision, Rationale, Alternative |

---

## Step 3: Requirements Elicitation

Ask clarifying questions:
1. **[Scope]**: Boundaries?
2. **[Constraints]**: Performance/compatibility?
3. **[Priority]**: Critical vs nice-to-have?
4. **[Out of Scope]**: Explicitly excluded?
5. **[Dependencies]**: Blockers/prerequisites?

---

## Step 4: PRP Definition

**PRP Framework**: See @.claude/guides/prp-framework.md

### What (Functionality)
**Objective**: Clear statement | **Scope**: In/out of scope

### Why (Context)
**Current**: Problem | **Desired**: End state | **Business Value**: Impact

### How (Approach)
- Phase 1: Discovery & Alignment
- Phase 2: Design
- Phase 3: Implementation (TDD: Red → Green → Refactor, Ralph Loop)
- Phase 4: Verification (type check + lint + tests + coverage)
- Phase 5: Handoff (docs + summary)

### Success Criteria
```
SC-{N}: {Description}
- Verify: {How to test}
- Expected: {Result}
```

### Test Scenarios
| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Happy path | ... | ... | Unit | `tests/test_feature.py::test_xxx` |
| TS-2 | Edge case | ... | ... | Unit | `tests/test_feature.py::test_yyy` |

### Constraints
Time, Technical, Resource limits

---

## Step 5: External Service Integration (Conditional)

> **⚠️ Include ONLY when plan involves**: API calls, DB operations, file operations, async, environment variables

**Trigger Keywords**: `API`, `fetch`, `database`, `migration`, `async`, `timeout`, `env`

**Full verification**: See @.claude/guides/gap-detection.md

**Plan Sections**:
- **API Calls Required**: Call, From, To, Endpoint, SDK/HTTP, Status, Verification
- **New Endpoints to Create**: Endpoint, Service, Method, Handler, Request/Response Schema
- **Environment Variables Required**: Variable, Service, Status, Verification
- **Error Handling Strategy**: Operation, Failure Mode, User Notification, Fallback

---

## Step 6: Architecture & Design

**Vibe Coding Guidelines**: See @.claude/skills/vibe-coding/SKILL.md

| Aspect | Content |
|--------|---------|
| **Data Structures** | Schema changes, TypeScript interfaces, API shapes |
| **Module Boundaries** | New files, existing modifications, integration points |
| **Dependencies** | `[A] --uses--> [B] --calls--> [C]` |
| **Risks** | Risk, Likelihood, Impact, Mitigation |
| **Alternatives** | A: Pros/Cons | B: Pros/Cons | Chosen: Reason |

---

## Step 7: Present Plan Summary

### Plan Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name}

## User Requirements (Verbatim)
> From Step 0: Complete table with all user input

### Requirements Coverage Check
> From Step 0: Verification that all URs mapped to SCs

## PRP Analysis (What/Why/How/Success Criteria/Constraints)
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff)
## External Service Integration [if applicable]
## Architecture
## Execution Plan
## Acceptance Criteria
## Test Plan
## Risks & Mitigations
## Open Questions
```

### User Confirmation Gate

> **🚨 MANDATORY ACTION**: Before concluding, you MUST call `AskUserQuestion`:
>
> ```markdown
> AskUserQuestion:
>   What would you like to do next?
>   A) Continue refining the plan
>   B) Explore alternative approaches
>   C) Run /01_confirm (save plan for execution)
>   D) Run /02_execute (start implementation immediately)
> ```
>
> **Proceed only after user selects option C or D.** (A/B → continue, ambiguous → re-ask)

---

## Success Criteria

- [ ] Step 0: User Requirements Collection completed
  - [ ] All user input recorded verbatim in table
  - [ ] Each requirement assigned UR-ID (UR-1, UR-2, ...)
  - [ ] Requirements Coverage Check table created
- [ ] Step 1: Parallel exploration executed
  - [ ] Explorer agent completed (files, patterns)
  - [ ] researcher agent completed (external docs)
  - [ ] Test environment detected
- [ ] Step 2: Execution Context compiled
  - [ ] Explored Files table created
  - [ ] Key Decisions documented
  - [ ] Implementation Patterns extracted
- [ ] Step 3: Requirements elicitation completed
  - [ ] Scope boundaries clarified
  - [ ] Constraints identified
  - [ ] Priorities established
- [ ] Step 4: PRP Analysis defined
  - [ ] What (Functionality) documented
  - [ ] Why (Context) with business value
  - [ ] How (Approach) with phases
  - [ ] Success Criteria with verify commands
- [ ] Step 5: External Service Integration (if applicable)
  - [ ] API Calls table completed
  - [ ] Environment Variables documented
  - [ ] Error Handling Strategy defined
- [ ] Step 6: Architecture documented
  - [ ] Data structures defined
  - [ ] Module boundaries identified
  - [ ] Risks & Alternatives analyzed
- [ ] Step 7: Plan Summary presented
  - [ ] User Requirements (Verbatim) included
  - [ ] Requirements Coverage Check shows 100%
  - [ ] User approved, ready for `/01_confirm`

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
Create    Review      Execute      Archive
```

---

## STOP
> **MANDATORY STOP** - PLANNING phase. No files created.
> Run `/01_confirm` to save plan to `.pilot/plan/pending/`

---

## Related Guides
- @.claude/guides/requirements-tracking.md - User Requirements Collection methodology
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- @.claude/guides/test-environment.md - Test framework detection
- @.claude/skills/vibe-coding/SKILL.md - Code quality standards
- @.claude/guides/gap-detection.md - External service verification
- @.claude/guides/parallel-execution.md - Parallel exploration pattern
