# Gap Detection Guide

## Purpose

Gap Detection reviews identify vague specifications that prevent independent executor work. This guide explains how to detect, report, and resolve gaps in development plans.

## Overview

> **🛑 BLOCKING Severity**: A new severity level higher than Critical
> - **BLOCKING** (🛑): Cannot proceed, triggers Interactive Recovery in `/01_confirm`
> - **Critical** (🚨): Must fix before execution
> - **Warning** (⚠️): Should fix
> - **Suggestion** (💡): Nice to have

### Activation

Run Gap Detection for **ALL plans**, but only report BLOCKING when external service keywords are detected.

## Trigger Keywords

| Category | Keywords |
|----------|----------|
| **External API** | `API`, `fetch`, `call`, `endpoint`, `SDK`, `HTTP`, `POST`, `GET`, `PUT`, `DELETE` |
| **Database** | `database`, `migration`, `schema`, `table`, `column`, `SQL`, `query` |
| **Async** | `async`, `await`, `timeout`, `promise`, `callback` |
| **Files** | `file`, `read`, `write`, `temp`, `path`, `fs` |
| **Environment** | `env`, `.env`, `environment`, `variable`, `config` |
| **Error Handling** | `try`, `catch`, `error`, `exception`, `throw` |

---

## Gap Detection Categories

### 9.1 External API Verification

| Check | Question |
|-------|----------|
| **Mechanism** | All API calls have implementation mechanism (SDK vs HTTP)? |
| **Existence** | All "Existing" endpoints verified to exist in codebase? |
| **Creation** | All "New" endpoints have creation tasks in Execution Plan? |
| **Error Handling** | Error handling strategy defined for each external call? |

**Automated Verification Commands**:
```bash
# Endpoint existence check
grep -r "endpoint_path" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"

# SDK dependency check
grep "package_name" package.json

# Environment variable check
grep "VAR_NAME" .env .env.example .env.local 2>/dev/null
```

### 9.2 Database Operation Verification

| Check | Question |
|-------|----------|
| **Migrations** | Schema changes have migration files specified? |
| **Rollback** | Rollback strategy documented? |
| **Integrity** | Data integrity checks included? |

### 9.3 Async Operation Verification

| Check | Question |
|-------|----------|
| **Timeouts** | Timeout values specified for all async operations? |
| **Limits** | Concurrent operation limits defined? |
| **Race Conditions** | Race condition scenarios addressed? |

### 9.4 File Operation Verification

| Check | Question |
|-------|----------|
| **Paths** | File paths are absolute or properly resolved? |
| **Existence** | File existence checks present before operations? |
| **Cleanup** | Cleanup strategy defined for temporary files? |

### 9.5 Environment Verification

| Check | Question |
|-------|----------|
| **Documentation** | All new env vars documented in .env.example? |
| **Existence** | All referenced env vars exist in current environment? |
| **Secrets** | No actual secret values in plan? |

### 9.6 Error Handling Verification

| Check | Question |
|-------|----------|
| **Silent Catches** | No silent catches (console.error only)? |
| **User Notification** | User notification strategy for each failure mode? |
| **Graceful Degradation** | Graceful degradation paths defined? |

### 9.7 Test Plan Verification (BLOCKING)

> **⚠️ CRITICAL - Test Scenarios are MANDATORY for all plans**

**Trigger**: Run for ALL plans - test verification is always required

| Check | Question |
|-------|----------|
| **Scenarios Defined** | Are there concrete test scenarios in the Test Plan section? |
| **Test Files Specified** | Does each scenario include a test file path? |
| **Test Command Detected** | Is the test command specified for the project type? |
| **Coverage Command** | Is the coverage command included? |
| **Test Environment Section** | Does the plan include "Test Environment (Detected)"? |

**BLOCKING Conditions** (triggers Interactive Recovery):
- Test Plan section missing from plan
- No test scenarios defined (empty table)
- Test scenarios lack "Test File" column entries
- Test command not specified (assumes `npm run test` without detection)
- Coverage command not specified

**Verification Commands**:
```bash
# Check if plan has Test Plan section
grep -A 20 "## Test Plan" "$PLAN_PATH"

# Check if Test Environment is detected
grep -A 10 "Test Environment" "$PLAN_PATH"

# Verify test scenarios have file paths
grep "Test File" "$PLAN_PATH"
```

**BLOCKING Finding Format**:
```markdown
### 🛑 BLOCKING (Cannot proceed - missing test planning)
- **[Test Plan]** No test scenarios defined - cannot proceed without test coverage
  - Location: Test Plan section in plan file
  - Required: Add at least 3 test scenarios (happy path, edge case, error handling)
  - Required: Specify test file paths for each scenario
  - Required: Include Test Environment section with detected test command
```

**Example of Correct Test Plan**:
```markdown
## Test Plan
| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Create user | {name: "John"} | 201 created | Integration | `tests/test_api.py::test_create_user` |
| TS-2 | Duplicate user | {name: "John"} | 409 conflict | Unit | `tests/test_api.py::test_duplicate_user` |
| TS-3 | Invalid input | {name: ""} | 400 bad request | Unit | `tests/test_validation.py::test_empty_name` |

## Test Environment (Detected)
- Project Type: Python
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`
```

---

## Interactive Recovery Process

### Purpose

Gather missing details through dialogue until plan passes review.

### Loop Structure

```bash
MAX_ITERATIONS=5
ITERATION=1

WHILE BLOCKING findings > 0 AND ITERATION <= MAX_ITERATIONS:
    1. Present BLOCKING findings to user
       - Show each finding with location
       - Explain what's missing
       - Provide example of good specification

    2. For each BLOCKING finding, use AskUserQuestion
       - "What SDK should be used?" (for unspecified API calls)
       - "What's the endpoint path?" (for vague endpoints)
       - Include "Skip this check (add as TODO)" option

    3. Update plan with user responses
       - Add to External Service Integration section
       - Or mark as skipped with warning note

    4. Re-run review: Skill 90_review

    5. Check results:
       - IF BLOCKING = 0: Exit loop, proceed to STOP
       - IF BLOCKING > 0 AND ITERATION < MAX_ITERATIONS: Continue loop
       - IF ITERATION = MAX_ITERATIONS: Log warnings, proceed to STOP

    ITERATION++
```

### AskUserQuestion Example

```
BLOCKING Finding: "API mechanism unspecified - missing SDK/HTTP, endpoint"
Location: "Call GPT 5.1 for analysis" in User Requirements

Question: Which implementation mechanism should be used?
Options:
- "OpenAI SDK (openai@4.x)" - Use Node.js SDK
- "HTTP: POST /api/generate" - Call existing API endpoint
- "Skip - add as TODO" - Mark as unresolved with warning
```

### Plan Update Format

```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| GPT Generation | Next.js API | OpenAI | N/A | openai@4.x | New | [ ] SDK installed |

[OR if skipped]
> ⚠️ SKIPPED: API mechanism deferred to implementation phase
> Original: "Call GPT 5.1 for analysis"
> Resolution: TODO - specify SDK or endpoint during execution
```

---

## Lenient Mode

If `--lenient` flag provided:
- Log: "⚠️ Lenient mode: BLOCKING findings converted to warnings"
- Add section to plan: `## Lenient Mode Warnings` with all BLOCKING items
- Proceed to STOP (do not enter Interactive Recovery)

---

## Result Format

```markdown
## Gap Detection Review (MANDATORY)
| # | Category | Status |
|---|----------|--------|
| 9.1 | External API | ✅/🛑 |
| 9.2 | Database Operations | ✅/🛑 |
| 9.3 | Async Operations | ✅/🛑 |
| 9.4 | File Operations | ✅/🛑 |
| 9.5 | Environment | ✅/🛑 |
| 9.6 | Error Handling | ✅/🛑 |
| 9.7 | Test Plan Verification | ✅/🛑 |
```

---

## See Also

- @.claude/guides/review-checklist.md - Comprehensive review checklist
- @.claude/guides/prp-framework.md - External Service Integration section
- @.claude/guides/test-environment.md - Test framework detection
