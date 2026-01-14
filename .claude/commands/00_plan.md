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

> **⚠️ CRITICAL**: DO NOT start implementation during /00_plan.
> - ❌ NO code editing, test writing, or file creation
> - ✅ OK: Exploration (Glob, Grep, Read), Analysis, Planning, Dialogue
> - Implementation starts ONLY after plan is saved (via `/01_confirm` → `/02_execute`)

---

## Phase Boundary Protection

### Current Phase: PLANNING

> **YOU ARE IN PLANNING PHASE**
> - CAN DO: Read, Search, Analyze, Discuss, Plan, Ask questions
> - CANNOT DO: Edit files, Write files, Create code, Implement
> - EXIT ONLY VIA: User explicitly runs `/01_confirm` or `/02_execute`

### Delegation Detection Principle

> **CRITICAL**: When user says "go ahead", "proceed", "알아서 해", etc.
> **ALWAYS interpret as**: "Continue with PLANNING activities"
> **NEVER interpret as**: "Start implementing/coding"

**Valid triggers to exit planning**:
1. User explicitly types `/01_confirm` or `/02_execute`
2. User explicitly says "start coding now" or "begin implementation"

**When uncertain**: "I'll continue refining the plan. When ready to implement, run `/01_confirm`."

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

## Step 0: Parallel Exploration

| Thread | Focus | Tools |
|--------|-------|-------|
| Explore | Related code, patterns | Glob, Grep, Read |
| Research | External docs | WebSearch, query-docs |
| **Test Env** | **Detect test framework** | **Glob, Read** |

**Test Environment Detection**: See @.claude/guides/test-environment.md

> **⚠️ COLLECT FOR HANDOFF**: During exploration, collect:
> - Files read (path + purpose + key lines)
> - Research findings (source + topic + insight)
> - Discovered dependencies
> - Warnings & gotchas
> - Key decisions made
> **See**: Step 0.5 for execution context template

---

## Step 0.5: Compile Execution Context

> **Purpose**: Transfer planner's discoveries to executor without re-exploration
> **Timing**: After Step 0 exploration, BEFORE Step 1 requirements

### Collect from Exploration

As you explore in Step 0, collect information for these tables:

#### Explored Files
| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/00_plan.md` | Plan command template | 1-261 | Current structure |
| `{file_path}` | {Why read} | {Line range} | {Key insight} |

#### Research Findings
| Source | Topic | Key Insight | URL |
|--------|-------|-------------|-----|
| {Documentation} | {Topic} | {Key takeaway} | {link} |

#### Discovered Dependencies
| Dependency | Version | Purpose | Status |
|------------|---------|---------|--------|
| {package} | {version} | {Why needed} | New/Existing |

#### Warnings & Gotchas
| Issue | Location | Recommendation |
|-------|----------|----------------|
| {Potential problem} | {File/function} | {How to handle} |

#### Key Decisions Made
| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| {Choice} | {Why this way} | {Other option} |

### Output Format

This becomes the **"Execution Context (Planner Handoff)"** section in the final plan document.

---

## Step 1: Requirements Elicitation

Ask clarifying questions:
1. **[Scope]**: Boundaries?
2. **[Constraints]**: Performance/compatibility?
3. **[Priority]**: Critical vs nice-to-have?
4. **[Out of Scope]**: Explicitly excluded?
5. **[Dependencies]**: Blockers/prerequisites?

---

## Step 2: PRP Definition

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

## Step 2.5: External Service Integration (Conditional)

> **⚠️ Include ONLY when plan involves**: API calls, DB operations, file operations, async, environment variables

**Trigger Keywords**: `API`, `fetch`, `database`, `migration`, `async`, `timeout`, `env`

**See**: @.claude/guides/gap-detection.md for verification checklist

**Plan Sections**:
```markdown
## External Service Integration
### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| [Description] | [Service] | [Service] | [Path/URL] | [Package/Method] | [New/Existing] | [ ] Check |

### New Endpoints to Create
| Endpoint | Service | Method | Handler | Request Schema | Response Schema |
|----------|---------|--------|---------|----------------|-----------------|

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| [VAR_NAME] | [Service] | [New/Existing] | [ ] In .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
```

---

## Step 3: Architecture & Design

### Data Structures
Schema changes, TypeScript interfaces, API shapes

### Module Boundaries
New files, existing modifications, integration points

### Vibe Coding Guidelines
**See**: @.claude/guides/vibe-coding.md

| Target | Limit |
|--------|-------|
| Function | ≤50 lines |
| Class/File | ≤200 lines |
| Nesting | ≤3 levels |

### Dependencies
```
[A] --uses--> [B] --calls--> [C]
```

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

### Alternatives
- **A**: Pros/Cons | **B**: Pros/Cons | **Chosen**: Reason

---

## Step 4: Present Plan Summary

### Plan Structure
```markdown
# {Work Name}
- Generated: {timestamp} | Work: {work_name}

## User Requirements
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
> **⛔ CONFIRMATION REQUIRED**
> Status: ✅ Plan complete (conversation only), ✅ No files created
> - IF correct → Run `/01_confirm` to save
> - IF changes → Request modifications
> To execute: `/01_confirm` then `/02_execute`, OR `/02_execute` directly

---

## Success Criteria

- [ ] Parallel exploration executed
- [ ] Requirements in PRP format
- [ ] Test scenarios defined
- [ ] Architecture documented
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
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- @.claude/guides/test-environment.md - Test framework detection
- @.claude/guides/vibe-coding.md - Code quality standards
- @.claude/guides/gap-detection.md - External service verification

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: `git rev-parse --abbrev-ref HEAD`
