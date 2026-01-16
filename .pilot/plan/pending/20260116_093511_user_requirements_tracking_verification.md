# User Requirements Tracking & Verification System

- Generated: 2026-01-16 09:35:11
- Work: user_requirements_tracking_verification
- Location: .pilot/plan/pending/20260116_093511_user_requirements_tracking_verification.md

---

## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | User Input (Original) | Summary |
|----|----------------------|---------|
| UR-1 | "00_plan 이 바로 시작되는 이슈" | 00_plan phase boundary violation prevention |
| UR-2 | "03_close 이슈" | Add git push to 03_close (**ALREADY COMPLETED**) |
| UR-3 | "00_plan 강화 내용을 아예 문서화를 안했더라고?" | Missing 00_plan enhancement documentation |
| UR-4 | "왜 00 plan 과 01 confirm 에서 이야기 나누었던 계획을 빼먹는지" | Analyze why conversation content gets omitted |
| UR-5 | "유저의 입력값을 모두 기록해두고 있다가 이거와 계획이 모두 동일하게 작성된게 맞는지 검증하는 단계를 추가해줘" | Add User Requirements Tracking & Verification system |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1 (Collection) | Mapped |
| UR-2 | ⏭️ Skip | Already completed | Done |
| UR-3 | ✅ | SC-1, SC-2 | Mapped |
| UR-4 | ✅ | SC-2 (Verification) | Mapped |
| UR-5 | ✅ | SC-1, SC-2, SC-3, SC-4 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Add User Requirements Tracking & Verification system to 00_plan → 01_confirm workflow

**Scope**:
- **In scope**:
  - Add "User Requirements Collection" step to `/00_plan`
  - Add "Requirements Verification" step to `/01_confirm`
  - Add "User Requirements (Verbatim)" section to plan template
  - Add verification checklist with BLOCKING condition
- **Out of scope**:
  - 03_close modification (already completed in previous plan)
  - Existing Phase Boundary Protection (already exists)

### Why (Context)

**Current Problem**:
- User requirements mentioned in `/00_plan` conversation get omitted from plan file
- No verification step to catch omissions
- Long conversations cause early requirements to be forgotten

**Desired State**:
- All user requirements recorded verbatim (original text)
- Automatic verification at plan completion
- BLOCKING warning when requirements are missing

**Business Value**:
- 100% user requirements coverage guarantee
- Improved plan quality
- Reduced rework

### How (Approach)

- **Phase 1**: Add Requirements Collection step to 00_plan.md
- **Phase 2**: Add Requirements Verification step to 01_confirm.md
- **Phase 3**: Add plan template sections
- **Phase 4**: Add BLOCKING condition for verification failure

### Success Criteria

```
SC-1: Add Requirements Collection step to 00_plan.md
- Verify: grep "User Requirements Collection" .claude/commands/00_plan.md
- Expected: Section present with collection instructions

SC-2: Add Requirements Verification step to 01_confirm.md
- Verify: grep "Requirements Verification" .claude/commands/01_confirm.md
- Expected: Verification step with checklist

SC-3: Plan template includes User Requirements (Verbatim) section
- Verify: grep "User Requirements (Verbatim)" .claude/commands/01_confirm.md
- Expected: Section template present

SC-4: Verification failure triggers BLOCKING warning
- Verify: grep -A5 "BLOCKING" .claude/commands/01_confirm.md | grep -i "requirements"
- Expected: BLOCKING condition for missing requirements
```

### Constraints

- Must not break existing workflow
- Must preserve Phase Boundary Protection
- English output for plan files (Korean input OK in Verbatim section)

---

## Scope

### In Scope
| Item | Description |
|------|-------------|
| 00_plan.md | Add User Requirements Collection step |
| 01_confirm.md | Add Requirements Verification step |
| Plan template | Add User Requirements (Verbatim) section |
| BLOCKING condition | Trigger when requirements missing |

### Out of Scope
| Item | Reason |
|------|--------|
| 03_close.md | Already completed (git push added) |
| Phase Boundary Protection | Already exists and working |

---

## Test Environment (Detected)

- Project Type: Python (pyproject.toml detected)
- Test Framework: pytest
- Test Command: `pytest`
- Coverage Command: `pytest --cov`
- Test Directory: `tests/`

Note: This is a documentation change (markdown files). Testing will be manual verification.

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/00_plan.md` | Plan command | ~200 lines | Add Collection step before Step 0 |
| `.claude/commands/01_confirm.md` | Confirm command | ~150 lines | Add Verification step after Step 1 |
| `.pilot/plan/done/20260116_090342_03_close_git_push_enhancement.md` | Previous plan | 363 lines | Example of missing requirements |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Record verbatim (original text) | Prevents summarization errors | Summarize (but may lose detail) |
| BLOCKING severity for missing | Forces resolution | WARNING (but may be ignored) |
| Add to both 00_plan and 01_confirm | Double-check mechanism | Single location (less robust) |

### Implementation Patterns (FROM CONVERSATION)

#### Architecture Diagram
> **FROM CONVERSATION:**
> ```
> ┌─────────────────────────────────────────────────────────────┐
> │                User Requirements Tracking Flow              │
> ├─────────────────────────────────────────────────────────────┤
> │                                                             │
> │  /00_plan 시작                                              │
> │  │                                                          │
> │  ├─ Step NEW: User Requirements Collection                  │
> │  │   ├─ 사용자의 모든 요구사항을 원문(Verbatim) 수집        │
> │  │   ├─ 각 요구사항에 ID 부여 (UR-1, UR-2, ...)             │
> │  │   └─ "User Requirements (Verbatim)" 테이블 작성          │
> │  │                                                          │
> │  ├─ [기존 단계들...]                                        │
> │  │                                                          │
> │  └─ Step 4: Present Plan Summary                            │
> │      └─ "User Requirements (Verbatim)" 섹션 포함            │
> │                                                             │
> │  /01_confirm 시작                                           │
> │  │                                                          │
> │  ├─ Step NEW: Requirements Verification                     │
> │  │   ├─ User Requirements (Verbatim) vs PRP Analysis 비교   │
> │  │   ├─ 누락된 요구사항 검출                                │
> │  │   └─ 누락 시 BLOCKING 경고                               │
> │  │                                                          │
> │  └─ [기존 단계들...]                                        │
> │                                                             │
> └─────────────────────────────────────────────────────────────┘
> ```

#### Template - User Requirements (Verbatim)
> **FROM CONVERSATION:**
> ```markdown
> ## User Requirements (Verbatim)
>
> > **Purpose**: Track ALL user requests verbatim to prevent omissions
>
> | ID | Timestamp | User Input (원문) | Mapped To |
> |----|-----------|-------------------|-----------|
> | UR-1 | 09:00 | "00_plan 이 바로 시작되는 이슈" | SC-1, SC-2 |
> | UR-2 | 09:00 | "03_close에 git push" | SC-3 |
> | UR-3 | 09:05 | "검증 단계 추가해줘" | SC-4 |
>
> ### Requirements Coverage Check
>
> | Requirement | In Scope? | Success Criteria | Status |
> |-------------|-----------|------------------|--------|
> | UR-1 | ✅ | SC-1, SC-2 | Mapped |
> | UR-2 | ✅ | SC-3 | Mapped |
> | UR-3 | ✅ | SC-4 | Mapped |
> | **Coverage** | 100% | All requirements mapped | ✅ |
> ```

---

## Architecture

### User Requirements Tracking Flow

```
[/00_plan Start]
       │
       ▼
┌──────────────────────────────┐
│ Step -1: Requirements        │
│ Collection (NEW)             │
│ ├─ Collect verbatim input    │
│ ├─ Assign IDs (UR-1, UR-2)   │
│ └─ Build tracking table      │
└──────────────┬───────────────┘
               │
               ▼
       [Existing Steps 0-4]
               │
               ▼
┌──────────────────────────────┐
│ Step 4: Present Plan Summary │
│ └─ Include User Requirements │
│    (Verbatim) section        │
└──────────────┬───────────────┘
               │
               ▼
       [/01_confirm Start]
               │
               ▼
┌──────────────────────────────┐
│ Step 1.7: Requirements       │
│ Verification (NEW)           │
│ ├─ Compare UR vs SC          │
│ ├─ Detect omissions          │
│ └─ BLOCKING if missing       │
└──────────────┬───────────────┘
               │
               ▼
       [Existing Steps 2-4]
```

### Integration Points

- **00_plan.md**: Add before Step 0 (Parallel Exploration)
- **01_confirm.md**: Add after Step 1.5 (Conversation Highlights)

---

## Vibe Coding Compliance

| Metric | Target | Expected |
|--------|--------|----------|
| Function length | ≤50 lines | N/A (markdown) |
| File length | ≤200 lines | 00_plan ~220 lines, 01_confirm ~180 lines |
| Nesting depth | ≤3 levels | Will maintain |

---

## Execution Plan

### Phase 1: 00_plan.md Modification
1. Read current 00_plan.md structure
2. Add "Step -1: User Requirements Collection" before Step 0
3. Add collection instructions (verbatim recording, ID assignment, table format)
4. Update Step 4 to include User Requirements (Verbatim) section

### Phase 2: 01_confirm.md Modification
1. Read current 01_confirm.md structure
2. Add "Step 1.7: Requirements Verification" after Step 1.5
3. Add verification checklist
4. Add BLOCKING condition for missing requirements

### Phase 3: Template Updates
1. Add "User Requirements (Verbatim)" section to plan structure
2. Add "Requirements Coverage Check" table template

### Phase 4: Verification
1. Manual test: Create plan with all requirements → Verify pass
2. Manual test: Create plan with missing requirement → Verify BLOCKING

---

## Acceptance Criteria

- [ ] AC-1: `grep "User Requirements Collection" .claude/commands/00_plan.md` returns matches
- [ ] AC-2: `grep "Requirements Verification" .claude/commands/01_confirm.md` returns matches
- [ ] AC-3: `grep "User Requirements (Verbatim)" .claude/commands/01_confirm.md` returns matches
- [ ] AC-4: BLOCKING condition present for missing requirements
- [ ] AC-5: Template includes coverage check table

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test Method |
|----|----------|-------|----------|------|-------------|
| TS-1 | All requirements included | 3 URs → 3 SCs | Verification pass | Manual | Run /00_plan → /01_confirm |
| TS-2 | Missing requirement | 3 URs → 2 SCs | BLOCKING warning | Manual | Run /00_plan with omission |
| TS-3 | Verbatim recording | Korean input | Original text in table | Manual | Check plan file |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Long conversations lose track | Medium | Medium | Immediate recording principle |
| Implicit requirements | Low | Medium | Explicit confirmation questions |
| Over-strict verification | Low | Low | Allow "Skip" option with TODO |

---

## Open Questions

1. **Should we track timestamps?**
   - **Decision**: Yes, helps identify when requirements were added

2. **What if user adds requirements mid-conversation?**
   - **Decision**: Update table immediately, re-verify at end

3. **How to handle "out of scope" requirements?**
   - **Decision**: Include in table with "Out of Scope" status

---

## Status

- [x] Plan created
- [ ] Auto-review completed
- [ ] BLOCKING findings resolved
- [ ] Ready for execution
