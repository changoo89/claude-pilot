# PRP Framework Guide

## Purpose

PRP (Problem-Requirements-Plan) is a structured framework for defining and analyzing software development work. This guide explains each component and how to apply it during planning.

## Framework Overview

PRP consists of three main sections:

| Component | Purpose | Key Questions |
|-----------|---------|---------------|
| **What** | Define functionality | What are we building? |
| **Why** | Provide context | Why are we building it? |
| **How** | Outline approach | How will we build it? |

## What (Functionality)

### Objective
Clear, concise statement of what will be built.

**Format**: "Objective: [One-line summary of the work]"

### Scope
Define what is included and excluded from the work.

**Format**:
- **In scope**: [Specific features, files, modules]
- **Out of scope**: [Explicitly excluded items]

### Example

```markdown
### What (Functionality)

**Objective**: Restructure command files to align with best practices

**Scope**:
- **In scope**: 8 command files, 8 new guide files, backup/restore
- **Out of scope**: Template folder, CLAUDE.md changes
```

## Why (Context)

### Current Problem
What is the current state and what problems exist?

**Key Points**:
- Identify pain points
- Quantify issues (e.g., "average 376 lines")
- Explain why current state is problematic

### Desired State
What does success look like?

**Key Points**:
- Describe the target state
- Define measurable improvements
- Contrast with current state

### Business Value
What is the impact of this work?

**Dimensions**:
- **User impact**: Better experience, faster execution
- **Technical impact**: Improved maintainability, cleaner code
- **Business impact**: Reduced costs, faster delivery

### Example

```markdown
### Why (Context)

**Current Problem**:
- Commands average 376 lines (recommendation: 50-150)
- Commands function as "complete manuals" instead of prompts
- Duplicate sections across multiple files

**Desired State**:
- Commands: Focused execution prompts (50-150 lines)
- Guides: Reusable methodology documents
- Zero information loss from original commands

**Business Value**:
- Faster command execution (less context to process)
- Better maintainability (methodology in one place)
- Reference during any work phase
```

## How (Approach)

### Phase Breakdown
Outline the major phases of work.

**Standard Phases**:
- **Phase 1**: Discovery & Alignment
- **Phase 2**: Design
- **Phase 3**: Implementation (TDD: Red → Green → Refactor, Ralph Loop)
- **Phase 4**: Verification (type check + lint + tests + coverage)
- **Phase 5**: Handoff (docs + summary)

### Example

```markdown
### How (Approach)

- **Phase 1**: Backup current commands
- **Phase 2**: Create methodology guide files
- **Phase 3**: Refactor command files
- **Phase 4**: Verification and cleanup
```

## Success Criteria

### Format
Measurable, testable criteria that define completion.

**Template**:
```markdown
SC-{N}: {Description}
- Verify: {How to test}
- Expected: {Result}
```

### Example

```markdown
### Success Criteria

SC-1: All commands ≤150 lines
- Verify: wc -l .claude/commands/*.md
- Expected: Each file ≤150 lines

SC-2: All 8 guide files created
- Verify: ls .claude/guides/*.md | wc -l
- Expected: 8 files
```

## Constraints

### Types of Constraints

| Type | Description | Examples |
|------|-------------|----------|
| **Time** | Deadlines, milestones | "Complete by sprint end" |
| **Technical** | Platform, language, APIs | "Must use Python 3.9+" |
| **Resource** | Team, budget, access | "Single developer" |

### Example

```markdown
### Constraints

- Must preserve all existing functionality
- No changes to templates folder
- English only for all content
- Backup must be created before changes
```

## Test Scenarios

### Purpose
Define test cases that verify success criteria.

### Format

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Happy path | ... | ... | Unit | `tests/test_feature.py::test_happy_path` |
| TS-2 | Edge case | ... | ... | Unit | `tests/test_feature.py::test_edge_case` |
| TS-3 | Error handling | ... | ... | Integration | `tests/test_integration.py::test_error_handling` |

**Note**: Include concrete file paths to help during implementation.

## PRP Template

```markdown
## PRP Analysis

### What (Functionality)

**Objective**: [Clear statement]

**Scope**:
- **In scope**: [Included items]
- **Out of scope**: [Excluded items]

### Why (Context)

**Current Problem**:
[Current state and issues]

**Desired State**:
[Target state description]

**Business Value**:
- [User impact]
- [Technical impact]

### How (Approach)

- **Phase 1**: [Description]
- **Phase 2**: [Description]
- **Phase 3**: [Description]
- **Phase 4**: [Description]

### Success Criteria

SC-1: [Description]
- Verify: [How to test]
- Expected: [Result]

### Constraints

[Time, Technical, Resource limits]
```

## External Service Integration (Conditional)

> **⚠️ CONDITIONAL**: Include ONLY when plan involves:
> - External API calls
> - Database operations
> - File operations
> - Async operations
> - Environment variables
> - Error handling beyond simple try/catch

### Trigger Keywords
`API`, `fetch`, `call`, `endpoint`, `database`, `migration`, `SDK`, `HTTP`, `POST`, `GET`, `PUT`, `DELETE`, `async`, `await`, `timeout`, `env`, `.env`

### Required Sections

When triggered, add:

1. **API Calls Required** - Table of external API calls
2. **New Endpoints to Create** - Table of new endpoints
3. **Environment Variables Required** - Table of env vars
4. **Error Handling Strategy** - Table of error scenarios
5. **Implementation Details Matrix** - WHO/WHAT/HOW/VERIFY
6. **Gap Verification Checklist** - Verification items

## See Also

- @.claude/guides/gap-detection.md - External service verification
- @.claude/guides/test-environment.md - Test framework detection
