---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore the codebase, gather requirements through dialogue, and design a SPEC-First execution plan._

---

## Core Philosophy

- **Read-Only**: NO code modifications. Only exploration, analysis, and planning.
- **SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation.
- **Collaborative**: Dialogue with user to clarify ambiguities.
- **Executable Output**: Result sufficient for `/01_confirm`.

---

## Inputs

- Task description from `"$ARGUMENTS"` (required)
- Codebase context via exploration
- User responses to clarifying questions

---

## Step 0: Initial Context Gathering

> **Principle**: Parallel exploration before questions.

### 0.1 Parse Task Description

Extract from `"$ARGUMENTS"`:
- Primary objective
- Implicit constraints
- Keywords for search

### 0.2 Parallel Exploration

Launch up to 3 exploration threads:

| Thread | Focus | Tools |
|--------|-------|-------|
| Explore | Related code, patterns | Glob, Grep, Read, find_symbol |
| Research | External docs | WebSearch, query-docs |
| Quality | Tests, CLAUDE.md | Read |

### 0.3 Output

```
🔍 Exploration Results:
- [Explore]: N files, pattern at X
- [Research]: Docs show Y
- [Quality]: Convention is Z
```

---

## Step 1: Requirements Elicitation

> **Principle**: PRP-style clarity (Product Requirements Prompt).

### 1.1 Present Initial Understanding

Based on Step 0:
- What you understood
- Key files affected
- Initial scope

### 1.2 Clarifying Questions

Use AskUserQuestion with consolidated block:
1. **[Scope]**: Boundaries of the change?
2. **[Constraints]**: Performance/compatibility requirements?
3. **[Priority]**: Critical features vs nice-to-have?
4. **[Out of Scope]**: What's explicitly excluded?
5. **[Dependencies]**: Any blockers or prerequisites?

### 1.3 Validate

Restate requirements, get confirmation.

---

## Step 2: PRP Definition

> **Principle**: Product Requirements Prompt + TDD test scenarios.

### 2.1 What (Functionality)

**Objective**: Clear statement of what needs to be built

**Scope**:
- In scope: [What's included]
- Out of scope: [What's explicitly excluded]

### 2.2 Why (Context)

**Current State**: [What's the problem?]

**Desired State**: [What will be true after?]

**Business Value**: [User/technical impact]

### 2.3 How (Approach)

**Phase 1: Discovery & Alignment**
- [ ] Identify relevant code paths
- [ ] Confirm integration points

**Phase 2: Design**
- [ ] Draft approach
- [ ] Define success validation

**Phase 3: Implementation (TDD)**
- [ ] For each SC: Red → Green → Refactor
- [ ] Ralph Loop until all pass

**Phase 4: Verification**
- [ ] Type check + lint
- [ ] Test suite + coverage
- [ ] Manual verification

**Phase 5: Handoff**
- [ ] Update docs
- [ ] Change summary

### 2.4 Success Criteria

```
SC-{N}: {Description}
- Verify: {How to test}
- Expected: {Result}
```

### 2.5 Test Scenarios (TDD-Ready)

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Happy path | ... | ... | Unit |
| TS-2 | Edge: empty | ... | ... | Unit |
| TS-3 | Error handling | ... | ... | Integration |

### 2.6 Constraints

**Time Constraints**: [If applicable]

**Technical Constraints**: [Technology limits]

**Resource Constraints**: [API limits, quotas]

---

## Step 3: Architecture & Design

> **Principle**: Data + structure first.

### 3.1 Data Structures

- Schema changes
- TypeScript interfaces
- API shapes

### 3.2 Module Boundaries

- New files to create
- Existing files to modify
- Integration points

### 3.3 Dependency Map

```
[A] --uses--> [B] --calls--> [C]
```

### 3.4 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

### 3.5 Alternatives

- **Approach A**: Pros/Cons
- **Approach B**: Pros/Cons
- **Chosen**: [Reason]

---

## Step 4: Create Plan File

### 4.1 Generate Plan Structure

Create timestamped plan file:

```bash
mkdir -p .pilot/plan/pending
TS="$(date +%Y%m%d_%H%M%S)"
WORK_NAME="$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | head -c 50)"
PLAN_FILE=".pilot/plan/pending/${TS}_${WORK_NAME}.md"
```

### 4.2 Plan Content Structure

```markdown
# {Work Name}

- Generated at: {timestamp}
- Work name: {work_name}
- Location: {plan_path}

## User Requirements

[Paste user's original request]

## PRP Analysis

### What (Functionality)
[From Step 2.2]

### Why (Context)
[From Step 2.2]

### How (Approach)
[From Step 2.3]

### Success Criteria
[From Step 2.4]

### Constraints
[From Step 2.6]

## Scope

### In scope
[List]

### Out of scope
[List]

## Architecture

### Data Structures
[From Step 3.1]

### Module Boundaries
[From Step 3.2]

## Execution Plan

[Phase breakdown from Step 2.3 with checkboxes]

## Acceptance Criteria

[From Step 2.4 with checkboxes]

## Test Plan

[From Step 2.5]

## Risks & Mitigations

[From Step 3.4]

## Open Questions

[Any unresolved items]
```

### 4.3 Write Plan File

```bash
cat > "$PLAN_FILE" << 'PLAN_EOF'
[Content above]
PLAN_EOF

echo "Plan created: $PLAN_FILE"
```

---

## Success Criteria

### Process
- [ ] Parallel exploration executed
- [ ] Clarifying questions asked/answered
- [ ] Requirements in PRP format
- [ ] Test scenarios TDD-ready

### Output
- [ ] Plan follows structure
- [ ] All 5 phases defined
- [ ] Risks documented
- [ ] Plan file created in .pilot/plan/pending/

### Handoff
- [ ] User approved
- [ ] Ready for /01_confirm
- [ ] No code modified

---

## Workflow Overview

```
/00_plan     → /01_confirm  → /02_execute → /03_close
     │             │              │            │
   Create       Review       Execute      Archive
   Plan         Plan        (TDD+Ralph)   & Commit
```

---

## Next Command

```
/01_confirm {plan_filename}
```

Or just `/01_confirm` to use the most recent pending plan.

---

## References

- **PRP Template**: `.claude/templates/PRP.md.template`
- **Context Engineering**: `.claude/guides/context-engineering.md`
- **Ralph Loop TDD**: `.claude/guides/ralph-loop-tdd.md`
