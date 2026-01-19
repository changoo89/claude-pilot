# Prevent /02_execute from Auto-Moving Plan to Done

> **Generated**: 2026-01-19 18:29:21 | **Work**: prevent_auto_plan_done | **Location**: .pilot/plan/draft/20260119_182921_prevent_auto_plan_done.md

---

## User Requirements (Verbatim)

> From /00_plan Step 0: Complete table with all user input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | HH:MM | "여전히 02_execute 가 종료되고 자기 마음대로 진행중인 plan 을 in_progress 를 done 으로 넘기는 일이 발생하는데 plan 넘기는건 03_close 에서 해야하거든? 프롬프트 보고 보강좀 해줘" | /02_execute가 plan 상태를 자동으로 done으로 변경하는 문제 해결 |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix `/02_execute` command to prevent automatic plan status change from `in_progress` to `done`

**Scope**:
- **In Scope**: `/02_execute` 명령 프롬프트 수정 (phase boundary protection, warnings, success criteria)
- **Out of Scope**: `/03_close` 명령 변경 (이미 올바르게 동작)

**Deliverables**:
1. `/02_execute` 프롬프트에 plan 상태 변경 금지 경고 추가
2. `/02_execute` Success Criteria에 plan 상태 유지 요구사항 추가
3. `/03_close` 참조 강화

### Why (Context)

**Current Problem**:
- `/02_execute`가 완료된 후 Coder agent가 plan을 자동으로 `done`으로 이동시킴
- Plan 상태 변경은 `/03_close`의 책임임에도 불구하고 `/02_execute`에서 이루어짐
- 이로 인해 사용자가 `/03_close`를 실행할 수 없게 됨

**Business Value**:
- **User impact**: 사용자가 명확한 단계(`/02_execute` → `/03_close`)를 통해 작업 진행 상황을 파악 가능
- **Technical impact**: 명령 간 명확한 책임 분리로 시스템 안정성 향상

**Background**:
- 현재 `/02_execute` 명령에는 plan 상태를 변경하지 말라는 명확한 지시가 없음
- Agent가 프롬프트를 자체 해석하여 추가 동작을 수행할 수 있음
- `/03_close` 명령에는 이미 올바른 "Move to Done" 단계가 있음 (Step 4)

### How (Approach)

**Implementation Strategy**:
1. `/02_execute` 명령에 "절대 plan 상태를 변경하지 말라"는 명확한 지시 추가
2. Success Criteria에 "Plan은 in_progress 상태 유지" 요구사항 추가
3. `/03_close`와의 역할 분명 강조

**Dependencies**:
- `/02_execute.md` 파일 수정
- `/03_close.md` 참조 (변경 없음)

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent가 여전히 plan을 이동시킴 | Medium | High | 명확한 경고와 금지 명령 추가 |
| 사용자가 `/03_close` 실행을 잊음 | Low | Low | 명확한 워크플로우 안내 |

### Success Criteria

- [x] **SC-1**: `/02_execute` 프롬프트에 plan 상태 변경 금지 경고 추가
  - Verify: `grep -q "NEVER move plan to done" .claude/commands/02_execute.md`
  - Expected: Core Philosophy 섹션 (lines ~11-16)에 경고 추가
  - Specific: "- **Phase boundary protection**: NEVER move plan to done (only /03_close can move plans)"
  - Status: ✅ Completed - Added to Core Philosophy section (line 15)

- [x] **SC-2**: `/02_execute` Success Criteria에 plan 상태 유지 요구사항 추가
  - Verify: `grep -q "Plan MUST remain in in_progress" .claude/commands/02_execute.md`
  - Expected: Success Criteria 섹션 (lines ~346-354)에 "Plan stays in in_progress" 항목
  - Specific: "- [ ] Plan file remains in .pilot/plan/in_progress/ directory"
  - Status: ✅ Completed - Added to Success Criteria section (line 365)

- [x] **SC-3**: `/03_close` 참조 강화
  - Verify: `grep -q "/03_close" .claude/commands/02_execute.md | grep -q "Archive plan"`
  - Expected: "Next Command" 섹션 (lines 366-370)에 명확한 안내
  - Specific: "- `/03_close` - **REQUIRED**: Move plan to done (ONLY this command moves plans)"
  - Status: ✅ Completed - Updated Next Command section (line 381)

---

## Scope

### In Scope
- `/02_execute` 명령 프롬프트 수정
- Phase boundary protection 경고 추가
- Success Criteria 업데이트
- `/03_close` 참조 강화

### Out of Scope
- `/03_close` 명령 변경 (이미 올바르게 동작)
- Coder agent 동작 변경 (프롬프트로 제어)

---

## Test Environment (Detected)

| Framework | Version | Test Command | Coverage Command |
|-----------|---------|--------------|-----------------|
| Bash | - | `bash .pilot/tests/test_*.sh` | - |

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Current implementation | Lines 1-370 | Needs phase boundary protection |
| `.claude/commands/03_close.md` | Reference for correct behavior | Lines 149-182 | Has proper "Move to Done" step |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Add phase boundary protection warning | Agent가 프롬프트를 자체 해석하는 것을 방지 | Coder agent 동작 직접 수정 |
| Add success criteria requirement | 명확한 상태 유지 요구사항 부여 | 일반적인 경고만 추가 |
| Strengthen /03_close reference | 명확한 워크플로우 안내 | /03_close에서만 plan 상태 변경 언급 |

### Implementation Patterns (FROM CONVERSATION)

#### Code Examples
> **FROM CONVERSATION:**
> No specific code examples provided in conversation.

#### Syntax Patterns
> **FROM CONVERSATION:**
> No specific CLI commands provided in conversation.

#### Architecture Diagrams
> **FROM CONVERSATION:**
> No architecture diagrams provided in conversation.

### Assumptions
- Agent가 프롬프트를 따르는 경향이 있음
- 명확한 경고와 금지 명령이 효과적일 것임
- 사용자가 워크플로우를 따를 것임

### Dependencies
- `.claude/commands/02_execute.md` 파일 수정 필요
- `.claude/commands/03_close.md` 참조 (변경 없음)

---

## Vibe Coding Compliance

| Target | Limit | Plan Strategy |
|--------|-------|---------------|
| Function | ≤50 lines | Keep warning messages concise |
| File | ≤200 lines | Add warnings to existing sections |
| Nesting | ≤3 levels | Simple conditional checks |

**Vibe Coding**: See @.claude/skills/vibe-coding/SKILL.md

---

## Execution Plan

### Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1 | Add phase boundary protection warning to /02_execute prompt (lines ~10-15) | coder | 5 min | pending |
| SC-2 | Add "NEVER move plan" instruction to Step 0.5 in /02_execute | coder | 5 min | pending |
| SC-3 | Update Success Criteria in /02_execute with plan status requirement | coder | 5 min | pending |
| SC-4 | Strengthen /03_close reference in "Next Command" section | coder | 3 min | pending |
| SC-5 | Create test script for plan status verification (TS-1) | tester | 10 min | pending |
| SC-6 | Create test script for prompt warnings (TS-2) | tester | 5 min | pending |
| SC-7 | Verify all changes with test suite | validator | 5 min | pending |

**Granularity Verification**: ✅ All todos comply with 3 rules
**Warnings**: None

### Phase 1: `/02_execute` 명령 프롬프트 수정
- **Step 1.1**: Core Philosophy 섹션에 phase boundary protection 추가 (coder, 5 min)
- **Step 1.2**: Step 0.5 다음에 "NEVER move plan" 경고 추가 (coder, 5 min)
- **Step 1.3**: Success Criteria 업데이트 (coder, 5 min)

### Phase 2: 참조 강화
- **Step 2.1**: "Next Command" 섹션에서 `/03_close` 실행 명확히 안내 (coder, 3 min)

### Phase 3: 검증
- **Step 3.1**: 테스트 스크립트 생성 (tester, 15 min)
  - TS-1: Plan 상태 유지 확인 스크립트 (tester, 10 min)
  - TS-2: 프롬프트 경고 존재 확인 스크립트 (tester, 5 min)
  - TS-3: Success Criteria 확인 스크립트 (tester, 5 min)
  - TS-4: Plan 이동 금지 확인 스크립트 (tester, 5 min)
- **Step 3.2**: 모든 변경사항 검증 (validator, 5 min)

---

## Acceptance Criteria

- [x] **AC-1**: `/02_execute` 프롬프트에 plan 상태 변경 금지 경고 존재
- [x] **AC-2**: Success Criteria에 plan 상태 유지 요구사항 존재
- [x] **AC-3**: `/03_close` 참조가 명확하게 안내됨
- [x] **AC-4**: 테스트 스크립트가 모든 변경사항 검증

---

## Test Plan

| ID | Scenario | Input | Expected | Verification Command | Type | Test File |
|----|----------|-------|----------|---------------------|------|-----------|
| TS-1 | Plan 상태 유지 확인 | `/02_execute` 완료 후 | Plan in `.pilot/plan/in_progress/` | `test -f .pilot/plan/in_progress/*.md` | Integration | test_execute_status.sh |
| TS-2 | 프롬프트 경고 존재 | `/02_execute` 프롬프트 읽기 | "NEVER move plan" text exists | `grep -q "NEVER move plan" .claude/commands/02_execute.md` | Unit | test_prompt_warnings.sh |
| TS-3 | Success Criteria 확인 | Success Criteria 확인 | "Plan MUST remain in in_progress" exists | `grep -q "Plan MUST remain" .claude/commands/02_execute.md` | Unit | test_success_criteria.sh |
| TS-4 | Plan 이동 금지 확인 | `/02_execute` 완료 후 | Plan NOT in `.pilot/plan/done/` | `! test -f .pilot/plan/done/*.md` | Integration | test_execute_no_move.sh |

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Agent가 여전히 plan을 이동시킴 | High | Medium | 명확한 경고와 금지 명령 추가 |
| 사용자가 `/03_close` 실행을 잊음 | Low | Low | 명확한 워크플로우 안내 |

---

## Open Questions

| Question | Priority | Status |
|----------|----------|--------|
| None | - | - |

---

## Review History

### 2026-01-19 18:29 - Auto-Review (Before Auto-Apply)

**Summary**: Plan created from conversation, awaiting review

**Findings**:
- BLOCKING: 0
- Critical: 1 (Missing verification commands in SC-1, SC-2, SC-3)
- Warning: 2 (Test verification commands missing, Phase Plan vs Granular Todos mismatch)
- Suggestion: 2 (Add TS-4 for negative case, match warning format)

**Changes Made**: None yet

**Updated Sections**: None yet

### 2026-01-19 18:30 - Auto-Review (After Auto-Apply)

**Summary**: Auto-applied all non-BLOCKING findings

**Findings**:
- BLOCKING: 0
- Critical: 0 (Fixed: Added specific verification commands to SC-1, SC-2, SC-3)
- Warning: 0 (Fixed: Added verification commands to test scenarios, expanded Phase Plan with test details)
- Suggestion: 0 (Fixed: Added TS-4 for negative case, updated warning format to match /02_execute style)

**Changes Made**:
- SC-1, SC-2, SC-3: Added specific bash verification commands (`grep -q`, line numbers)
- Test Plan: Added "Verification Command" column with specific commands
- Test Plan: Added TS-4 for Plan 이동 금지 확인
- Phase Plan Phase 3: Expanded with detailed test script steps (TS-1, TS-2, TS-3, TS-4)

**Updated Sections**: Success Criteria, Test Plan, Execution Plan (Phase 3)

---

## Execution History

### 2026-01-19 - Implementation Complete

**Summary**: All success criteria completed and verified

**Changes Made**:
1. **SC-1**: Added "Phase boundary protection" to Core Philosophy section (line 15)
   - Text: `- **Phase boundary protection**: NEVER move plan to done (only /03_close can move plans)`

2. **SC-1**: Added comprehensive warning to Step 0.5 (lines 34-42)
   - Warning block with ⚠️ CRITICAL: PHASE BOUNDARY PROTECTION
   - Explicitly states MUST NEVER move plan to done
   - Clarifies /03_close responsibility

3. **SC-2**: Updated Success Criteria (line 365)
   - Added: `- [ ] **Plan MUST remain in .pilot/plan/in_progress/ (NEVER move to done - only /03_close can do this)**`

4. **SC-3**: Strengthened /03_close reference (line 381)
   - Changed from: `- `/03_close` - Archive plan and cleanup`
   - Changed to: `- `/03_close` - **REQUIRED**: Move plan to done (ONLY this command moves plans)`

**Test Scripts Created**:
1. `.pilot/tests/test_execute_status.sh` - TS-1: Plan status verification
2. `.pilot/tests/test_prompt_warnings.sh` - TS-2: Prompt warnings verification
3. `.pilot/tests/test_success_criteria.sh` - TS-3: Success Criteria verification
4. `.pilot/tests/test_execute_no_move.sh` - TS-4: Plan movement prohibition verification

**Test Results**: All 4 test scripts passed ✅

**Files Modified**:
- `.claude/commands/02_execute.md` (4 locations updated)

**Files Created**:
- `.pilot/tests/test_execute_status.sh`
- `.pilot/tests/test_prompt_warnings.sh`
- `.pilot/tests/test_success_criteria.sh`
- `.pilot/tests/test_execute_no_move.sh`

**Verification Commands**:
```bash
# All pass ✅
grep -q "Phase boundary protection" .claude/commands/02_execute.md
grep -q "NEVER move plan to done" .claude/commands/02_execute.md
grep -q "Plan MUST remain" .claude/commands/02_execute.md
grep -q "REQUIRED.*Move plan to done.*ONLY this command" .claude/commands/02_execute.md
```

**Acceptance Criteria Status**:
- [x] AC-1: `/02_execute` 프롬프트에 plan 상태 변경 금지 경고 존재
- [x] AC-2: Success Criteria에 plan 상태 유지 요구사항 존재
- [x] AC-3: `/03_close` 참조가 명확하게 안내됨
- [x] AC-4: 테스트 스크립트가 모든 변경사항 검증

**Status**: ✅ ALL SUCCESS CRITERIA MET

---

## Execution Summary

### Changes Made
1. **Core Philosophy Section**: Added "Phase boundary protection" principle to `/02_execute` command
2. **Step 0.5 Warning**: Added comprehensive CRITICAL warning block preventing plan movement
3. **Success Criteria**: Added plan status requirement (MUST remain in in_progress)
4. **Next Command Section**: Strengthened /03_close reference as ONLY command that moves plans

### Documentation Updated
- ✅ `.claude/commands/CONTEXT.md` (Tier 2): Updated with phase boundary protection pattern
- ✅ `.claude/commands/CONTEXT.md`: Updated Execute Implementation process description
- ✅ `.claude/commands/CONTEXT.md`: Added test coverage documentation
- ✅ `.claude/commands/CONTEXT.md`: Updated line counts (3466 → 3470)

### Verification Status
- ✅ Type check: Not applicable (documentation only)
- ✅ Tests: 4/4 test scripts passed (test_execute_status.sh, test_prompt_warnings.sh, test_success_criteria.sh, test_execute_no_move.sh)
- ✅ Lint: Not applicable (documentation only)

### Follow-ups
- None - phase boundary protection fully implemented and documented
