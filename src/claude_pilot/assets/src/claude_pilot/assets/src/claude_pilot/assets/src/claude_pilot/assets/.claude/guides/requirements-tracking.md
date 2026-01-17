# User Requirements Collection Guide

> **Purpose**: Track ALL user requests verbatim to prevent omissions during long conversations
> **Used by**: /00_plan command (Step 0: User Requirements Collection)

---

## Quick Start

### When to Use This Guide

Use this guide when:
- Starting `/00_plan` to collect user requirements
- User adds requirements mid-conversation
- Preparing plan summary with requirements coverage

### Quick Reference

```markdown
## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | HH:MM | "[exact user words]" | Brief summary |
```

---

## Core Concepts

### The Problem

Long conversations cause requirements mentioned early to be forgotten:
- User: "Add X feature" → [30 minutes of exploration] → Plan created without X
- No explicit tracking → Implicit understanding lost
- No verification step → Missing requirements discovered too late

### The Solution

**Immediate Recording Principle**:
1. Collect verbatim input BEFORE exploration starts
2. Assign unique IDs (UR-1, UR-2, ...)
3. Update table continuously during conversation
4. Verify 100% coverage before plan completion

---

## Collection Process

### Step 1: Collect Verbatim Input

**Rules**:
- Record EVERY user request in original language
- Include timestamp when mentioned
- Preserve exact wording (no translation)
- Capture implicit requirements too

**Example**:
```
User: "00_plan 이 바로 시작되는 이슈"
→ UR-1: "00_plan 이 바로 시작되는 이슈"
→ Summary: 00_plan phase boundary violation prevention
```

### Step 2: Assign Requirement IDs

**Format**: `UR-1`, `UR-2`, `UR-3`, etc.

**Rules**:
- Increment for each new requirement
- Track additions during conversation
- Never re-use IDs
- Mark out-of-scope with ⏭️ instead of deleting

### Step 3: Build Requirements Table

```markdown
## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | HH:MM | "[exact user words]" | Brief summary |
| UR-2 | HH:MM | "[exact user words]" | Brief summary |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅/⏭️ | SC-X | Mapped/Pending |
| UR-2 | ✅/⏭️ | SC-Y | Mapped/Pending |
| **Coverage** | XX% | All requirements mapped | ✅/❌ |
```

**Table Columns**:
- **ID**: Unique requirement identifier
- **Timestamp**: When requirement was mentioned
- **User Input (Original)**: Exact user words (verbatim)
- **Summary**: Brief English summary

**Coverage Check Columns**:
- **Requirement**: UR-ID
- **In Scope?**: ✅ (included), ⏭️ (out of scope)
- **Success Criteria**: Which SC covers this UR
- **Status**: Mapped, Pending, or Missing

### Step 4: Update During Conversation

**When user adds new requirement**:
1. Add new row to requirements table
2. Assign next UR-ID
3. Update Requirements Coverage Check
4. Re-map to SCs if already created

**When requirement deemed out of scope**:
1. Mark with ⏭️ in "In Scope?" column
2. Add note: "Out of scope (user confirmed)"
3. Update Coverage percentage

**When requirement mapped to SC**:
1. Update "Success Criteria" column with SC-ID
2. Change "Status" to "Mapped"
3. Update Coverage percentage

### Step 5: Present in Plan Summary

Include in Step 4 output:
- Full User Requirements (Verbatim) table
- Requirements Coverage Check showing 100% coverage
- Call out any deferred/out-of-scope items

---

## Entry Point: /00_plan Step 0

**Location**: `/00_plan` command, Step 0 (before Parallel Exploration)

**MANDATORY**: Do NOT start Step 1 (Parallel Exploration) until requirements table is created.

This ensures ALL user input is captured before exploration begins.

---

## Success Criteria

- [ ] All user input recorded verbatim in table
- [ ] Each requirement assigned UR-ID (UR-1, UR-2, ...)
- [ ] Requirements Coverage Check table created
- [ ] Table updates continuously during conversation
- [ ] 100% coverage verified before plan completion

---

## Common Patterns

### Implicit Requirements

Users may not state requirements explicitly. Examples:
- "Fix the performance issue" → Implicit: "Add performance metrics"
- "Make it secure" → Implicit: "Add authentication, encryption"

**Action**: Capture as separate UR with clarification

### Out-of-Scope Handling

User may request features beyond current scope:
1. Include in table with ⏭️ mark
2. Note: "Out of scope (deferred to future)"
3. Do NOT map to SC

### Requirement Changes

User may modify earlier requirements:
1. Keep original UR entry
2. Add new UR with note: "Updates UR-1"
3. Update Coverage Check accordingly

---

## Integration Points

- **00_plan.md**: Step 0 (User Requirements Collection)
- **01_confirm.md**: Step 1.7 (Requirements Verification)
- **Plan template**: User Requirements (Verbatim) section

---

## Related Guides

- @.claude/guides/requirements-verification.md - Verification step in /01_confirm
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
