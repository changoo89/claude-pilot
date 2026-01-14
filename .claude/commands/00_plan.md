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

> **⚠️ LANGUAGE - PLAN OUTPUT**: All plan documents MUST be written in English, regardless of conversation language. This includes plan summaries, PRP analysis, success criteria, test scenarios, and all content in the plan file.

> **⚠️ CRITICAL**: DO NOT start implementation during /00_plan.
> - ❌ NO code editing, test writing, or file creation
> - ✅ OK: Exploration (Glob, Grep, Read), Analysis, Planning, Dialogue
> - Implementation starts ONLY after plan is saved (via `/01_confirm` → `/02_execute` or `/02_execute` directly from pending/)

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Parallel Exploration

| Thread | Focus | Tools |
|--------|-------|-------|
| Explore | Related code, patterns | Glob, Grep, Read, find_symbol |
| Research | External docs | WebSearch, query-docs |
| Quality | Tests, CLAUDE.md | Read |

Output: 🔍 [Explore] N files at X, [Research] Docs show Y, [Quality] Convention is Z

---

## Step 1: Requirements Elicitation

Present understanding + AskUserQuestion:
1. **[Scope]**: Boundaries? 2. **[Constraints]**: Performance/compatibility?
3. **[Priority]**: Critical vs nice-to-have? 4. **[Out of Scope]**: Explicitly excluded?
5. **[Dependencies]**: Blockers/prerequisites?

Validate: restate requirements, get confirmation.

---

## Step 2: PRP Definition

### What (Functionality)
**Objective**: Clear statement | **Scope**: In/out of scope

### Why (Context)
**Current**: Problem statement | **Desired**: End state | **Business Value**: User/technical impact

### How (Approach)
- **Phase 1**: Discovery & Alignment
- **Phase 2**: Design
- **Phase 3**: Implementation (TDD: Red → Green → Refactor, Ralph Loop)
- **Phase 4**: Verification (type check + lint + tests + coverage)
- **Phase 5**: Handoff (docs + summary)

### Success Criteria
```
SC-{N}: {Description}
- Verify: {How to test}
- Expected: {Result}
```

### Test Scenarios
| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Happy path | ... | ... | Unit |
| TS-2 | Edge case | ... | ... | Unit |
| TS-3 | Error handling | ... | ... | Integration |

### Constraints
Time, Technical, Resource limits

---

## Step 2.5: External Service Integration (Conditional)

> **⚠️ CONDITIONAL SECTION**: Include ONLY when plan involves:
> - External API calls (REST, GraphQL, SDKs)
> - Database operations (migrations, schema changes)
> - File operations (read/write/temp files)
> - Async operations (timeouts, concurrency)
> - Environment variables
> - Error handling beyond simple try/catch

> **Trigger Keywords**: `API`, `fetch`, `call`, `endpoint`, `database`, `migration`, `SDK`, `HTTP`, `POST`, `GET`, `PUT`, `DELETE`, `async`, `await`, `timeout`, `env`, `.env`

### External Service Integration

```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| [Description] | [Service] | [Service] | [Path/URL] | [Package/Method] | [New/Existing] | [ ] Check |
| Example: GPT Generation | Next.js API | OpenAI | N/A (SDK) | openai@4.x | New | [ ] SDK installed |
| Example: PDF Generation | Next.js API | helper-server | /hater/complaints/pdf | HTTP fetch | Existing | [ ] Endpoint verified |

### New Endpoints to Create
| Endpoint | Service | Method | Handler | Request Schema | Response Schema |
|----------|---------|--------|---------|----------------|-----------------|
| [/api/path] | [Service] | [POST/GET] | [file.ts] | { type: string } | { result: Type } |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| [VAR_NAME] | [Service] | [New/Existing] | [ ] In .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| [Operation name] | [Timeout/Auth/Network] | [Toast/Status/Alert] | [Retry/Fail/Skip] |
```

### Implementation Details Matrix

```markdown
## Implementation Details Matrix

| Task | WHO (Service) | WHAT (Action) | HOW (Mechanism) | VERIFY (Check) |
|------|---------------|---------------|-----------------|----------------|
| [Task description] | [Service/Boundary] | [Action] | [Code/Command] | [Verification] |
| Example: Call GPT | Next.js API route | Generate crime_facts | OpenAI SDK v4 | SDK installed, API key set |
| Example: Save result | Next.js API route | Update complaint | Prisma client | Schema has field |
```

### Gap Verification Checklist

```markdown
## Gap Verification Checklist

### External API
- [ ] All API calls specify SDK vs HTTP mechanism
- [ ] All "Existing" endpoints verified via codebase search
- [ ] All "New" endpoints have creation tasks in Execution Plan
- [ ] Error handling strategy defined for each external call

### Database Operations
- [ ] Schema changes have migration files specified
- [ ] Rollback strategy documented
- [ ] Data integrity checks included

### Async Operations
- [ ] Timeout values specified for all async operations
- [ ] Concurrent operation limits defined
- [ ] Race condition scenarios addressed

### File Operations
- [ ] File paths are absolute or properly resolved
- [ ] File existence checks before operations
- [ ] Cleanup strategy for temporary files

### Environment
- [ ] All new env vars documented in .env.example
- [ ] All referenced env vars exist in current environment
- [ ] No actual secret values in plan

### Error Handling
- [ ] No silent catches (console.error only)
- [ ] User notification strategy for each failure mode
- [ ] Graceful degradation paths defined
```

> **📝 NOTE**: Copy these templates into the generated plan when external services are involved. Fill with concrete details - no "TODO" or vague references.

---

## Step 3: Architecture & Design

### Data Structures
Schema changes, TypeScript interfaces, API shapes

### Module Boundaries
New files, existing modifications, integration points

### Vibe Coding Guidelines
> **LLM-Readable Code Standards** - Enforce during code generation

| Target | Limit | Action |
|--------|-------|--------|
| Function | ≤50 lines | Split functions |
| Class/File | ≤200 lines | Extract modules |
| Nesting | ≤3 levels | Early return |

**Principles**: SRP, DRY, KISS, Early Return
**AI Rules**: Small increments, test immediately, never trust blindly, edge cases, consistent naming, no secrets

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
- Location: .pilot/plan/pending/{timestamp}_{work_name}.md

## User Requirements [Original request]

## PRP Analysis
### What / Why / How / Success Criteria / Constraints

## Scope: In scope / Out of scope

## External Service Integration [OPTIONAL - if APIs/DB/Files/Async/Env involved]
### API Calls Required / New Endpoints / Environment Variables / Error Handling Strategy

## Implementation Details Matrix [OPTIONAL - if external services involved]
### WHO / WHAT / HOW / VERIFY table

## Gap Verification Checklist [OPTIONAL - if external services involved]
### API / DB / Async / File / Environment / Error Handling checklists

## Architecture
### Data Structures / Module Boundaries / Vibe Coding Guidelines

## Execution Plan [Phases with checkboxes]

## Acceptance Criteria [Checkboxes from SC]

## Test Plan [From Step 2]

## Risks & Mitigations / Open Questions
```

> **📌 CONDITIONAL SECTIONS**: Include External Service Integration, Implementation Details Matrix, and Gap Verification Checklist ONLY when the plan involves:
> - External API calls (REST, GraphQL, SDKs)
> - Database operations (migrations, schema changes)
> - File operations (read/write/temp files)
> - Async operations (timeouts, concurrency)
> - Environment variables
> - Error handling beyond simple try/catch

### User Confirmation Gate
> **⛔ CONFIRMATION REQUIRED**
> Status: ✅ Plan complete (conversation only), ✅ No files created, ✅ Ready for review
> - IF correct → Run `/01_confirm` to save to `pending/`
> - IF changes → Request modifications
> To execute: `/01_confirm` then `/02_execute`, OR `/02_execute` directly if plan in `pending/`

---

## Success Criteria

- [ ] Parallel exploration executed
- [ ] Clarifying questions asked/answered
- [ ] Requirements in PRP format
- [ ] Test scenarios TDD-ready
- [ ] Plan follows structure, all phases defined
- [ ] Risks documented, plan in conversation (no file)
- [ ] User approved, ready for `/01_confirm`

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
 Create    Review      Execute      Archive
 Plan      Plan      (TDD+Ralph)   & Commit
```

---

## STOP
> **MANDATORY STOP** - PLANNING phase. No files created.
> Run `/01_confirm` to save plan to `.pilot/plan/pending/`

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
- **Status**: !`git status --short`
