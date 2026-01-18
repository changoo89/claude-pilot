# Gap Detection Guide

> **Purpose**: Identify vague specifications that block independent execution
> **Full Reference**: @.claude/guides/gap-detection-REFERENCE.md

---

## Severity Levels

| Level | Symbol | Action |
|-------|--------|--------|
| **BLOCKING** | 🛑 | Cannot proceed (Interactive Recovery) |
| **Critical** | 🚨 | Must fix before execution |
| **Warning** | ⚠️ | Advisory, recommended |
| **Suggestion** | 💡 | Optional improvements |

---

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

## Detection Categories

### 9.1 External API
- **Mechanism**: SDK vs HTTP specified?
- **Existence**: Existing endpoints verified?
- **Creation**: New endpoints in Execution Plan?
- **Error Handling**: Strategy defined?

### 9.2 Database Operations
- **Migrations**: Migration files specified?
- **Rollback**: Rollback strategy documented?
- **Integrity**: Data integrity checks included?

### 9.3 Async Operations
- **Timeouts**: Values specified?
- **Limits**: Concurrent limits defined?
- **Race Conditions**: Scenarios addressed?

### 9.4 File Operations
- **Paths**: Absolute or properly resolved?
- **Existence**: Pre-operation checks present?
- **Cleanup**: Cleanup strategy defined?

### 9.5 Environment Variables
- **Documentation**: In `.env.example`?
- **Existence**: In current environment?
- **Secrets**: No actual values in plan?

### 9.6 Error Handling
- **Silent Catches**: None (console.error only)?
- **User Notification**: Strategy defined?
- **Graceful Degradation**: Paths defined?

### 9.7 Test Plan Verification (BLOCKING)

> **⚠️ MANDATORY for ALL plans**

**BLOCKING Conditions**:
- Test Plan section missing
- No test scenarios defined
- Test file paths missing
- Test command not detected
- Coverage command missing

**Verification commands and full examples**: @.claude/guides/gap-detection-REFERENCE.md#97-test-plan-verification-blocking

---

## Interactive Recovery Process

### Loop Structure

```
WHILE BLOCKING > 0 AND iteration <= 5:
    1. Present BLOCKING findings
    2. AskUserQuestion for each
    3. Update plan with responses
    4. Re-run review
    5. Exit when BLOCKING = 0
```

### AskUserQuestion Pattern

```
Question: [What's needed?]
Options:
- A) [Specific solution]
- B) [Alternative approach]
- C) Skip - add as TODO
```

### Plan Update Format

**When resolved**:
```markdown
## External Service Integration
### API Calls Required
| Call | Endpoint | SDK/HTTP | Status |
|------|----------|----------|--------|
| [Description] | [Path] | [Type] | New |
```

**When skipped**:
```markdown
> ⚠️ SKIPPED: Deferred to implementation
> Resolution: TODO - specify during execution
```

**Full details**: @.claude/guides/gap-detection-REFERENCE.md#interactive-recovery-process

---

## Lenient Mode

`--lenient` flag converts BLOCKING to warnings:
- Add `## Lenient Mode Warnings` section to plan
- Skip Interactive Recovery
- Proceed to STOP

---

## Result Format

```markdown
## Gap Detection Review (MANDATORY)
| # | Category | Status |
|---|----------|--------|
| 9.1 | External API | ✅/🛑 |
| 9.2 | Database | ✅/🛑 |
| 9.3 | Async | ✅/🛑 |
| 9.4 | Files | ✅/🛑 |
| 9.5 | Environment | ✅/🛑 |
| 9.6 | Error Handling | ✅/🛑 |
| 9.7 | Test Plan | ✅/🛑 |
```

---

## See Also

- **@.claude/guides/review-checklist.md** - Comprehensive review checklist
- **@.claude/guides/prp-framework.md** - External Service Integration section
- **@.claude/guides/test-environment.md** - Test framework detection

---

**Version**: claude-pilot 4.2.0 (Gap Detection)
**Last Updated**: 2026-01-19
