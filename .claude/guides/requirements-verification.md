# Requirements Verification Guide

> **Purpose**: Verify 100% requirements coverage before plan execution
> **Full Reference**: @.claude/guides/requirements-verification-REFERENCE.md
> **Used by**: `/01_confirm` Step 1.7

---

## Quick Reference

```markdown
### Requirements Coverage Verification

| UR ID | User Input (Verbatim) | Mapped to SC? | SC ID | Status |
|-------|----------------------|---------------|-------|--------|
| UR-1  | "[exact words]"       | ✅/❌         | SC-X  | Mapped/Missing |

**Coverage**: X/Y requirements (XX%)
```

---

## Verification Process

### Step 1: Extract User Requirements

Locate "User Requirements (Verbatim)" table from conversation.

**Collect**:
- Total count (UR-1, UR-2, ...)
- Each requirement summary
- Out-of-scope markers (⏭️)

**Full template**: @.claude/guides/requirements-verification-REFERENCE.md#step-1-extract-user-requirements-verbatim-section

### Step 2: Extract Success Criteria

List all SCs from PRP Analysis section.

**Collect**:
- Total SC count
- Each SC description
- SC identifiers (SC-1, SC-2, ...)

**Full template**: @.claude/guides/requirements-verification-REFERENCE.md#step-2-extract-success-criteria

### Step 3: Create Mapping Table

Compare URs to SCs for coverage.

| UR ID | Mapped? | SC ID | Status |
|-------|---------|-------|--------|
| UR-1  | ✅/❌   | SC-X  | Mapped/Missing |

**Rules**:
- ✅ = SC exists
- ❌ = Missing (BLOCKING)
- ⏭️ = Out of scope (OK)

### Step 4: Check BLOCKING Conditions

| Condition | Severity | Action |
|-----------|----------|--------|
| Missing requirement | 🛑 | Must add SC |
| Ambiguous mapping | ⚠️ | Clarify |
| Out of scope | ✅ | Mark ⏭️ |

**BLOCKING**: ANY in-scope requirement without SC

### Step 5: Handle BLOCKING

If BLOCKING findings exist, present to user:

```markdown
## 🛑 BLOCKING: Missing Requirements

| UR ID | User Input | Issue |
|-------|-----------|-------|
| UR-2  | "[missing]" | No SC found |

**Action**: Add SC OR mark out of scope
```

**Resolution Options**:
- A) Add SC
- B) Mark out of scope
- C) Defer to implementation (TODO)

### Step 6: Update Plan

Add to plan after verification:

```markdown
## Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ⏭️ | Out of scope | Excluded |
| **Coverage** | 100% | All mapped | ✅ |
```

**Full details**: @.claude/guides/requirements-verification-REFERENCE.md#step-6-update-plan-file

---

## Entry Point

**Location**: `/01_confirm` Step 1.7

> **⚠️ MANDATORY**: Do NOT proceed to plan creation if BLOCKING findings exist

Use `AskUserQuestion` to resolve ALL BLOCKING issues first.

---

## Common Patterns

### Implicit Requirements

- "Make it secure" → May need multiple SCs
- "Improve performance" → May need metrics, caching

**Action**: Clarify if mapping unclear

### Composite Requirements

One UR may map to multiple SCs:
- UR-1: "Add search" → SC-1 (UI), SC-2 (API), SC-3 (indexing)

**Action**: List all SCs: "SC-1, SC-2, SC-3"

### Out-of-Scope

Mark with ⏭️ and note: "Out of scope (user confirmed)"

---

## Success Criteria

- [ ] All URs extracted from User Requirements table
- [ ] All SCs extracted from PRP Analysis
- [ ] Coverage mapping created (UR → SC)
- [ ] BLOCKING findings reported
- [ ] 100% coverage verified
- [ ] Requirements Coverage Check added to plan

---

## Integration Points

| File | Step | Purpose |
|------|------|---------|
| `00_plan.md` | Step 0 | Creates UR table |
| `01_confirm.md` | Step 1.7 | Verifies coverage |
| Plan template | - | Coverage Check section |

---

## See Also

- **@.claude/guides/requirements-tracking.md** - Collection in `/00_plan`
- **@.claude/guides/prp-framework.md** - PRP definition
- **@.claude/guides/gap-detection.md** - External service verification

---

**Version**: claude-pilot 4.2.0 (Requirements Verification)
**Last Updated**: 2026-01-19
