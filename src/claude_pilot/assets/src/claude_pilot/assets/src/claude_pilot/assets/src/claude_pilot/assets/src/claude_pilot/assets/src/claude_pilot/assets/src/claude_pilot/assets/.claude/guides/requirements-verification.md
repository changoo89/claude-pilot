# Requirements Verification Guide

> **Purpose**: Verify ALL user requirements are captured in the plan with 100% coverage
> **Used by**: /01_confirm command (Step 1.7: Requirements Verification)

---

## Quick Start

### When to Use This Guide

Use this guide when:
- Running `/01_confirm` to verify requirements coverage
- Reviewing plan before execution
- Checking for missing requirements during planning

### Quick Reference

```markdown
### Requirements Coverage Verification

| UR ID | User Input (Verbatim) | Mapped to SC? | SC ID | Status |
|-------|----------------------|---------------|-------|--------|
| UR-1  | "[exact user words]"  | ✅/❌         | SC-X  | Mapped/Missing |

**Coverage**: X/Y requirements (XX%)
```

---

## Core Concepts

### The Verification Problem

Requirements collected during `/00_plan` may not make it into the final plan:
- Planner forgets early requirements after long exploration
- Conversation highlights omit some requirements
- No explicit check before plan creation

### The Verification Solution

**Double-Check Mechanism**:
1. Extract User Requirements (Verbatim) table
2. Extract all Success Criteria from plan
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing

---

## Verification Process

### Step 1: Extract User Requirements (Verbatim) Section

**Action**: Locate "User Requirements (Verbatim)" table in conversation

**Collect**:
- Total requirement count (UR-1, UR-2, etc.)
- Each requirement's summary
- Out-of-scope markers (⏭️)

**Example Input**:
```markdown
## User Requirements (Verbatim)

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "00_plan 이 바로 시작되는 이슈" | Phase boundary violation |
| UR-2 | "03_close에 git push" | Git push automation |
| UR-3 | "검증 단계 추가해줘" | Add verification step |
```

### Step 2: Extract Success Criteria

**Action**: List all SCs from PRP Analysis section

**Collect**:
- Total SC count
- Each SC description
- SC identifiers (SC-1, SC-2, etc.)

**Example Input**:
```markdown
### Success Criteria

SC-1: Add Requirements Collection step to 00_plan.md
SC-2: Add Requirements Verification step to 01_confirm.md
SC-3: Add git push to 03_close.md
```

### Step 3: Verify Coverage Mapping

**Action**: Create mapping table comparing URs to SCs

**Template**:
```markdown
### Requirements Coverage Verification

| UR ID | User Input (Verbatim) | Mapped to SC? | SC ID | Status |
|-------|----------------------|---------------|-------|--------|
| UR-1  | "[exact user words]"  | ✅/❌         | SC-X  | Mapped/Missing |
| UR-2  | "[exact user words]"  | ✅/❌         | SC-Y  | Mapped/Missing |

**Coverage**: X/Y requirements (XX%)
```

**Rules**:
- **Mapped to SC?**: ✅ if SC exists, ❌ if missing
- **SC ID**: Which SC covers this requirement
- **Status**: "Mapped" if covered, "Missing" if not

### Step 4: Check for BLOCKING Conditions

**Severity Levels**:

| Condition | Severity | Action |
|-----------|----------|--------|
| Missing requirement (no SC mapped) | 🛑 BLOCKING | Must add SC or mark out of scope |
| Ambiguous requirement (unclear mapping) | ⚠️ Warning | Clarify with user |
| Out of scope (explicitly excluded) | ✅ OK | Mark with ⏭️ in table |

**BLOCKING Trigger**: ANY in-scope requirement without SC mapping

### Step 5: Handle BLOCKING Findings

**If BLOCKING findings exist**:

```markdown
## 🛑 BLOCKING: Missing Requirements

The following user requirements are NOT mapped to Success Criteria:

| UR ID | User Input | Issue |
|-------|-----------|-------|
| UR-2  | "[missing requirement]" | No SC found |

**Action Required**: Before proceeding, you MUST either:
1. Add Success Criteria to cover missing requirement(s), OR
2. Mark requirement(s) as "Out of Scope" with user confirmation

Use AskUserQuestion to resolve BLOCKING findings before plan creation.
```

**Resolution Options** (via AskUserQuestion):
- A) Add SC to cover missing requirement
- B) Mark as out of scope (with user confirmation)
- C) Defer to implementation phase (adds TODO)

### Step 6: Update Plan File

**After verification complete**:

Add to plan:
```markdown
## Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| UR-3 | ⏭️ | Out of scope (user confirmed) | Excluded |
| **Coverage** | 100% | All in-scope requirements mapped | ✅ |
```

**Status Values**:
- **Mapped**: UR has corresponding SC
- **Excluded**: UR marked out of scope
- **Missing**: UR has no SC (BLOCKING)

### Step 7: Verification Output Format

**Success (100% coverage)**:
```markdown
## Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |
```

**Failure (BLOCKING)**:
```markdown
## 🛑 BLOCKING: Missing Requirements

| UR ID | User Input | Issue |
|-------|-----------|-------|
| UR-2  | "[missing]" | No SC found |

**Coverage**: 1/2 requirements (50%) ❌
```

---

## Entry Point: /01_confirm Step 1.7

**Location**: `/01_confirm` command, Step 1.7 (after Conversation Highlights extraction, before file creation)

**MANDATORY**: Do NOT proceed to Step 2 (Generate Plan File Name) if BLOCKING findings exist.

Use AskUserQuestion to resolve ALL BLOCKING issues before plan file creation.

---

## Success Criteria

- [ ] All user requirements extracted from User Requirements (Verbatim) table
- [ ] All Success Criteria extracted from PRP Analysis
- [ ] Coverage mapping table created (UR → SC)
- [ ] BLOCKING findings detected and reported
- [ ] 100% coverage verified before plan creation
- [ ] Requirements Coverage Check added to plan file

---

## Common Patterns

### Implicit Requirements

Sometimes requirements are implicit (not directly stated):
- "Make it secure" → May require multiple SCs (auth, encryption, etc.)
- "Improve performance" → May require metrics, optimization, caching

**Action**: Clarify with user if mapping unclear

### Composite Requirements

One user requirement may map to multiple SCs:
- UR-1: "Add search feature" → SC-1 (UI), SC-2 (API), SC-3 (indexing)

**Action**: List all SCs in "Success Criteria" column: "SC-1, SC-2, SC-3"

### Out-of-Scope Requirements

User may confirm exclusion during verification:
- Mark with ⏭️ in "In Scope?" column
- Add note: "Out of scope (user confirmed)"
- Update Coverage percentage (exclude from count)

---

## Integration Points

- **00_plan.md**: Step 0 (User Requirements Collection) - creates table
- **01_confirm.md**: Step 1.7 (Requirements Verification) - verifies table
- **Plan template**: Requirements Coverage Check section

---

## Related Guides

- @.claude/guides/requirements-tracking.md - Collection step in /00_plan
- @.claude/guides/prp-framework.md - Problem-Requirements-Plan definition
- @.claude/guides/gap-detection.md - External service verification
