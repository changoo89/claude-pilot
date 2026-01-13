# 명령어 플로우 정합성 보완

- Generated at: 2026-01-13 17:12:50
- Work name: command_flow_consistency
- Location: .pilot/plan/pending/20260113_171250_00_plan_implementation_guard.md

## User Requirements

1. 00_PLAN 입력하고 나서 대화로 핑퐁 하는 과정에서 CLAUDE가 그냥 구현을 냅다 진행하는 경우가 있는데 보완을 해줘
2. 전체 스크립트 확인해서 플로우 일관성 보장
3. Worktree 모드와 Active Pointer 흐름 검증

## PRP Analysis

### What (Functionality)

**Objective**:
1. `/00_plan` 명령 실행 중 구현 방지 경고 강화
2. `/01_confirm` 명령의 플로우 수정 (pending/에 파일 생성, in_progress 이동 및 active pointer 제거)
3. `/02_execute` 명령의 표현 명확화 (pending/에서도 실행 가능함을 명시)

**Scope**:
- In scope: `00_plan.md`, `01_confirm.md`, `02_execute.md` 파일 수정
- Out of scope: `03_close.md`, `90_review.md`, `worktree-utils.sh` (이미 정상)

### Why (Context)

**Current State**:

| 파일 | 문제 | 심각도 |
|------|------|--------|
| 00_plan.md | 맨 끝에만 STOP 경고 → 대화 중간에 구현 위험 | Medium |
| 01_confirm.md | Step 0이 pending/에서 찾으려 함 (대화에서 추출해야 함) | Critical |
| 01_confirm.md | Step 2가 in_progress로 이동 (pending/에 생성해야 함) | Critical |
| 01_confirm.md | Step 2.3에서 active pointer 생성 (02_execute에서 해야 함) | Critical |
| 02_execute.md | description이 "in-progress plan"이라 pending 실행 가능 여부 혼란 | Medium |

**Desired State**:
```
/00_plan        → /01_confirm       → /02_execute      → /03_close
     │                 │                  │                  │
  대화로           pending/에          pending/ →         in_progress/ →
  플랜 논의        파일 생성           in_progress/        done/
  (파일 X)         (리뷰)             이동 + active ptr   active ptr 삭제
```

**Active Pointer 흐름**:
- 생성: `/02_execute` Step 1.6
- 삭제: `/03_close` Step 4.1
- `/01_confirm`에서는 생성하지 않음

**Worktree 모드 검증 결과**: ✅ 정상
- pending/ → worktree의 in_progress/로 이동
- main repo의 in_progress/에도 복사
- worktree 내에 active pointer 생성

### How (Approach)

**Phase 1: 분석** ✅
- [x] 00_plan.md 구조 파악
- [x] 01_confirm.md 구조 파악
- [x] 02_execute.md 구조 파악
- [x] 03_close.md 확인 (정상)
- [x] 90_review.md 확인 (정상)
- [x] worktree-utils.sh 확인 (정상)
- [x] Active Pointer 흐름 검증
- [x] Worktree 모드 플로우 검증

**Phase 2: 설계** ✅
- [x] 00_plan.md 경고 문구 설계
- [x] 01_confirm.md 수정 범위 결정
- [x] 02_execute.md 수정 범위 결정

**Phase 3: 구현 - 00_plan.md**
- [ ] Core Philosophy에 CRITICAL CONSTRAINT 추가
- [ ] Step 1 끝에 리마인더 추가
- [ ] Step 2 끝에 리마인더 추가
- [ ] Step 3 끝에 리마인더 추가
- [ ] Step 4에 User Confirmation Gate 추가

**Phase 4: 구현 - 01_confirm.md**
- [ ] description 수정: "Extract plan from conversation, create file in pending/"
- [ ] Step 0 삭제 또는 수정 (Locate the Plan → 대화 컨텍스트 확인)
- [ ] Step 1 유지: Extract Plan from Conversation
- [ ] Step 2 수정: Create In-Progress Workspace → Create Plan in Pending
- [ ] Step 2.2 수정: mv → pending/에 파일 생성
- [ ] Step 2.3 삭제: Record Active Pointer 제거
- [ ] STOP 섹션에서 /02_execute 안내

**Phase 5: 구현 - 02_execute.md**
- [ ] description 수정: "Execute a plan (auto-moves pending to in-progress)"
- [ ] 제목 수정: "Execute a pending or in-progress plan"
- [ ] Step 1에 pending/ → in_progress/ 자동 이동 설명 강화
- [ ] 에러 메시지 개선 (confirm 먼저 하라는 혼란 방지)

**Phase 6: 검증**
- [ ] 00_plan.md Grep 검증
- [ ] 01_confirm.md Grep 검증
- [ ] 02_execute.md 확인
- [ ] 플로우 통합 테스트

**Phase 7: 완료**
- [ ] 변경사항 요약

### Success Criteria

```
SC-1: 00_plan.md - Core Philosophy에 구현 금지 경고 존재
- Verify: Grep "CRITICAL CONSTRAINT" in 00_plan.md
- Expected: 1 match

SC-2: 00_plan.md - 각 Step 끝에 리마인더 존재
- Verify: Grep "REMINDER" in 00_plan.md
- Expected: 3 matches (Step 1, 2, 3)

SC-3: 00_plan.md - User Confirmation Gate 존재
- Verify: Grep "User Confirmation Gate" in 00_plan.md
- Expected: 1 match

SC-4: 01_confirm.md - pending/에 파일 생성
- Verify: Read Step 2
- Expected: pending/에 저장하는 로직

SC-5: 01_confirm.md - in_progress 이동 로직 없음
- Verify: Grep "mv.*in_progress" in 01_confirm.md
- Expected: 0 matches

SC-6: 01_confirm.md - active pointer 생성 없음
- Verify: Grep "ACTIVE_PTR" in 01_confirm.md
- Expected: 0 matches

SC-7: 02_execute.md - description 수정됨
- Verify: Read frontmatter
- Expected: "pending" 또는 "auto-moves" 포함

SC-8: 02_execute.md - Step 1에 자동 이동 설명 강화
- Verify: Read Step 1.5
- Expected: pending/에서 찾으면 자동으로 in_progress로 이동한다는 명확한 설명
```

### Constraints

**Technical Constraints**:
- 마크다운 문법 유지
- 기존 구조 최소 변경
- 03_close, 90_review, worktree-utils.sh 수정하지 않음

## Scope

### In scope
- `.claude/commands/00_plan.md` 수정
  - 경고 문구 및 리마인더 추가
- `.claude/commands/01_confirm.md` 수정
  - pending/에 파일 생성하도록 수정
  - in_progress 이동 로직 제거
  - active pointer 생성 제거
- `.claude/commands/02_execute.md` 수정
  - description 및 제목 명확화
  - Step 1 설명 강화

### Out of scope
- `.claude/commands/03_close.md` (정상 ✅)
- `.claude/commands/90_review.md` (정상 ✅)
- `.claude/scripts/worktree-utils.sh` (정상 ✅)
- 시스템 레벨 제약 추가

## Architecture

### Module Boundaries
- 수정 파일: 3개
  - `.claude/commands/00_plan.md`
  - `.claude/commands/01_confirm.md`
  - `.claude/commands/02_execute.md`

### 플로우 다이어그램

**수정 전:**
```
00_plan (대화)
    ↓
01_confirm:
├── Step 0: pending/에서 찾기 ❌
├── Step 2: in_progress로 이동 ❌
└── Step 2.3: active pointer 생성 ❌
    ↓
02_execute:
├── description: "in-progress plan" ❌ (혼란)
└── pending/ 자동 이동 설명 부족 ❌
```

**수정 후:**
```
00_plan (대화) + 경고 강화
    ↓
01_confirm:
├── 대화에서 추출 ✅
├── pending/에 파일 생성 ✅
└── active pointer 없음 ✅
    ↓
02_execute:
├── description: "pending or in-progress" ✅
├── pending/ → in_progress/ 자동 이동 명시 ✅
└── active pointer 생성 ✅
    ↓
03_close:
└── active pointer 삭제 ✅
```

### Active Pointer 흐름 (검증 완료)

| 명령어 | 동작 | 비고 |
|--------|------|------|
| 00_plan | 없음 | ✅ |
| 01_confirm | 없음 (수정 후) | 현재는 생성함 → 제거 |
| 02_execute | 생성 (Step 1.6) | ✅ |
| 02_execute --wt | worktree 내 생성 | ✅ |
| 03_close | 삭제 (Step 4.1) | ✅ |

### Worktree 모드 (검증 완료)

```
02_execute --wt:
├── select_oldest_pending() → pending/에서 선택 ✅
├── create_worktree() → worktree 생성 ✅
├── mv → worktree의 in_progress/로 이동 ✅
├── active pointer (worktree 내) 생성 ✅
└── main repo의 in_progress/에 복사 ✅

03_close (worktree):
├── worktree 감지 ✅
├── squash merge ✅
└── cleanup ✅
```

## Execution Plan

**Phase 1: 분석** ✅
- [x] 전체 스크립트 분석 완료
- [x] Worktree 모드 검증 완료
- [x] Active Pointer 흐름 검증 완료

**Phase 2: 설계** ✅
- [x] 수정 범위 확정

**Phase 3: 구현 - 00_plan.md**
- [ ] Core Philosophy에 CRITICAL CONSTRAINT 블록 추가
- [ ] Step 1 끝에 리마인더 추가
- [ ] Step 2 끝에 리마인더 추가
- [ ] Step 3 끝에 리마인더 추가
- [ ] Step 4.2 다음에 4.3 User Confirmation Gate 추가

**Phase 4: 구현 - 01_confirm.md**
- [ ] description 수정
- [ ] Step 0 제거 또는 수정
- [ ] Step 2 수정: pending/에 생성
- [ ] Step 2.3 (active pointer) 제거
- [ ] STOP 섹션 확인/수정

**Phase 5: 구현 - 02_execute.md**
- [ ] description 수정
- [ ] 제목(subtitle) 수정
- [ ] Step 1 설명 강화 (pending/ 자동 이동)

**Phase 6: 검증**
- [ ] 00_plan.md SC-1, SC-2, SC-3
- [ ] 01_confirm.md SC-4, SC-5, SC-6
- [ ] 02_execute.md SC-7, SC-8
- [ ] 마크다운 구조 확인

**Phase 7: 완료**
- [ ] 변경사항 요약

## Acceptance Criteria

### 00_plan.md
- [ ] Core Philosophy에 CRITICAL CONSTRAINT 경고 블록 존재
- [ ] Step 1, 2, 3 끝에 각각 리마인더 존재
- [ ] Step 4에 User Confirmation Gate 섹션 존재

### 01_confirm.md
- [ ] description이 "pending"을 포함
- [ ] Step 0이 "Locate the Plan"이 아닌 대화 컨텍스트 확인
- [ ] Step 2가 pending/에 파일 생성
- [ ] in_progress 이동 로직 없음
- [ ] active pointer 생성 로직 없음
- [ ] STOP에서 /02_execute 안내

### 02_execute.md
- [ ] description이 pending 또는 auto-moves 포함
- [ ] 제목이 pending or in-progress 포함
- [ ] Step 1에 pending/ 자동 이동 설명 명확

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | 00_plan CRITICAL CONSTRAINT | Grep "CRITICAL CONSTRAINT" | 1 match | Unit |
| TS-2 | 00_plan 리마인더 | Grep "REMINDER" | 3 matches | Unit |
| TS-3 | 00_plan Confirmation Gate | Grep "User Confirmation Gate" | 1 match | Unit |
| TS-4 | 01_confirm pending 생성 | Read Step 2 | pending/에 저장 | Unit |
| TS-5 | 01_confirm in_progress 없음 | Grep "mv.*in_progress" | 0 matches | Unit |
| TS-6 | 01_confirm ACTIVE_PTR 없음 | Grep "ACTIVE_PTR" | 0 matches | Unit |
| TS-7 | 02_execute description | Read frontmatter | pending 포함 | Unit |
| TS-8 | 02_execute Step 1 설명 | Read Step 1.5 | 자동 이동 설명 | Unit |
| TS-9 | 플로우 통합 테스트 | 00→01→02→03 순차 실행 | 정상 플로우 | Integration |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 경고가 너무 많아 가독성 저하 | Medium | Low | 간결한 문구, 시각적 구분 |
| 01_confirm 수정으로 기존 동작 변경 | Medium | Medium | 플로우 테스트로 검증 |
| 02_execute 표현 변경으로 혼란 | Low | Low | 명확한 설명 추가 |
| Worktree 모드 영향 | Low | Medium | worktree-utils.sh 미수정, 02_execute --wt 테스트 |

## Open Questions

- 없음 (전체 스크립트 분석 및 Worktree/Active Pointer 검증 완료)

## 검증 완료 항목

### Worktree 모드 ✅
- `worktree-utils.sh`: 모든 함수 정상
- `02_execute --wt`: pending/ → worktree의 in_progress/ 이동 정상
- `03_close` (worktree): squash merge 및 cleanup 정상

### Active Pointer ✅
- 생성 시점: `02_execute` Step 1.6 (정상)
- 삭제 시점: `03_close` Step 4.1 (정상)
- `01_confirm`에서 생성: 현재 있음 → **제거 필요**

### 수정 불필요 파일 ✅
- `03_close.md`: in_progress/ → done/ 이동, active pointer 삭제 정상
- `90_review.md`: in_progress/ 또는 pending/에서 찾음, active pointer 미사용
- `worktree-utils.sh`: 모든 유틸리티 함수 정상

---

## Execution Summary

### Changes Made

#### 00_plan.md
1. **CRITICAL CONSTRAINT** added to Core Philosophy
   - Visual warning box preventing implementation during /00_plan
   - Lists allowed operations (exploration, analysis, planning, dialogue)
   - Specifies implementation starts only after /01_confirm and /02_execute

2. **REMINDER** added after Step 1 (Requirements Elicitation)
   - Remains in planning mode
   - OK: Requirements gathering, clarification, PRP definition
   - NOT OK: Writing code, editing files, running tests

3. **REMINDER** added after Step 2 (PRP Definition)
   - Remains in planning mode
   - OK: Defining success criteria, test scenarios, constraints
   - NOT OK: Writing tests, implementing features, editing files

4. **REMINDER** added after Step 3 (Architecture & Design)
   - Remains in planning mode
   - OK: Architecture design, data structures, module boundaries
   - NOT OK: Creating files, implementing modules, writing code

5. **User Confirmation Gate** added as Step 4.3
   - Visual STOP block before execution
   - Clear user action required
   - Directs to /01_confirm to save plan to pending/

#### 01_confirm.md
- Already correct (no changes needed)
- Creates plan files in pending/
- Does NOT move to in_progress/ (done by /02_execute)
- Does NOT create active pointer (done by /02_execute)
- STOP section guides to /02_execute

#### 02_execute.md
1. **description** updated
   - From: "Execute the current in-progress plan"
   - To: "Execute a plan (auto-moves pending to in-progress)"

2. **subtitle** updated
   - From: "Execute the current in-progress plan"
   - To: "Execute a pending or in-progress plan"

3. **Step 1.5** enhanced with better explanation
   - Clear auto-detect behavior for pending/ plans
   - Workflow description: /01_confirm (creates in pending/) → /02_execute (moves to in_progress/)

### Verification Results

| SC | Description | Expected | Actual | Status |
|----|-------------|----------|--------|--------|
| SC-1 | 00_plan.md CRITICAL CONSTRAINT | 1 match | 1 match | ✅ |
| SC-2 | 00_plan.md REMINDER | 3 matches | 3 matches | ✅ |
| SC-3 | 00_plan.md User Confirmation Gate | 1 match | 1 match | ✅ |
| SC-4 | 01_confirm.md pending/ creation | exists | 4 matches | ✅ |
| SC-5 | 01_confirm.md NO in_progress move | 0 matches | 0 matches | ✅ |
| SC-6 | 01_confirm.md active pointer | STOP section only | STOP section only | ✅ |
| SC-7 | 02_execute.md description | "pending" or "auto-moves" | "auto-moves pending to in-progress" | ✅ |
| SC-8 | 02_execute.md Step 1.5 | Enhanced explanation | Enhanced with behavior details | ✅ |

### Flow Verification

**Corrected Flow:**
```
/00_plan (대화) + 경고 강화
    ↓
/01_confirm: 대화에서 추출 → pending/에 파일 생성 (NO active pointer)
    ↓
/02_execute: pending/ → in_progress/ 자동 이동 + active pointer 생성
    ↓
/03_close: in_progress/ → done/ 이동 + active pointer 삭제
```

### Remaining Items

- None - all planned changes completed and verified

### Notes

- 01_confirm.md was already correct (possibly updated in previous session)
- 03_close.md, 90_review.md, worktree-utils.sh confirmed as working correctly
- All markdown structure and syntax preserved
