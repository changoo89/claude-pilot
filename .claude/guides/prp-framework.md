# PRP Framework Guide

> **Purpose**: Structured framework for defining software development work
> **Template**: @.claude/templates/prp-template.md

---

## Overview

PRP consists of three main sections:

| Component | Purpose | Key Questions |
|-----------|---------|---------------|
| **What** | Define functionality | What are we building? |
| **Why** | Provide context | Why are we building it? |
| **How** | Outline approach | How will we build it? |

---

## What (Functionality)

### Objective
Clear, concise statement of what will be built.

**Format**: "Objective: [One-line summary]"

### Scope
Define what is included and excluded.

**Format**:
- **In scope**: [Specific features, files, modules]
- **Out of scope**: [Explicitly excluded items]

---

## Why (Context)

### Current Problem
- Identify pain points
- Quantify issues
- Explain why current state is problematic

### Desired State
- Describe target state
- Define measurable improvements
- Contrast with current state

### Business Value
- **User impact**: Better experience, faster execution
- **Technical impact**: Improved maintainability, cleaner code
- **Business impact**: Reduced costs, faster delivery

**Full example**: @.claude/templates/prp-template.md

---

## How (Approach)

### Standard Phases

- **Phase 1**: Discovery & Alignment
- **Phase 2**: Design
- **Phase 3**: Implementation (TDD: Red → Green → Refactor, Ralph Loop)
- **Phase 4**: Verification (type check + lint + tests + coverage)
- **Phase 5**: Handoff (docs + summary)

---

## Success Criteria

**Format**:
```markdown
SC-{N}: {Description}
- Verify: {How to test}
- Expected: {Result}
```

**Example**:
```markdown
SC-1: All commands ≤150 lines
- Verify: wc -l .claude/commands/*.md
- Expected: Each file ≤150 lines
```

---

## Constraints

| Type | Description | Examples |
|------|-------------|----------|
| **Time** | Deadlines, milestones | "Complete by sprint end" |
| **Technical** | Platform, language, APIs | "Must use Python 3.9+" |
| **Resource** | Team, budget, access | "Single developer" |

---

## Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Happy path | ... | ... | Unit | `tests/test_x.py::test_happy` |
| TS-2 | Edge case | ... | ... | Unit | `tests/test_x.py::test_edge` |
| TS-3 | Error handling | ... | ... | Integration | `tests/test_int.py::test_error` |

**Note**: Include concrete file paths for implementation.

---

## PRP Template

**Full template**: @.claude/templates/prp-template.md

**Quick template**:
```markdown
## PRP Analysis

### What (Functionality)
**Objective**: [Clear statement]
**Scope**: In scope / Out of scope

### Why (Context)
**Current Problem**: [Issues]
**Desired State**: [Target]
**Business Value**: User / Technical impact

### How (Approach)
- **Phase 1**: [Description]
- **Phase 2**: [Description]
- **Phase 3**: [Description]

### Success Criteria
SC-1: [Description]
- Verify: [How to test]
- Expected: [Result]

### Constraints
[Time, Technical, Resource limits]
```

---

## External Service Integration (Conditional)

> **⚠️ CONDITIONAL**: Include ONLY when triggered by keywords

**Trigger Keywords**: `API`, `fetch`, `database`, `migration`, `SDK`, `async`, `env`

**Required Sections**:
1. API Calls Required
2. New Endpoints to Create
3. Environment Variables Required
4. Error Handling Strategy
5. Implementation Details Matrix
6. Gap Verification Checklist

**Full details**: @.claude/guides/gap-detection.md

---

## See Also

- **@.claude/templates/prp-template.md** - Complete PRP template
- **@.claude/guides/gap-detection.md** - External service verification
- **@.claude/guides/test-environment.md** - Test framework detection

---

**Version**: claude-pilot 4.2.0 (PRP Framework)
**Last Updated**: 2026-01-19
