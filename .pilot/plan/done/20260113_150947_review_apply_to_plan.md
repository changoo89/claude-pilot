# Review Apply to Plan

- Generated at: 2026-01-13 15:09:47
- Work name: review_apply_to_plan
- Location: .pilot/plan/pending/20260113_150947_review_apply_to_plan.md

## User Requirements

confirm 을 할 때 우리 review 를 거치는데, review 를 할 때 단순히 결과를 대화로(메모리로) 띄우는게 아니라 결과 중 직접 판단하여 계획파일에 반영을 하는 것 까지가 완료인걸로 해줘

**User Preferences**:
- 모든 이슈(Critical/Warning/Suggestion) 자동 반영
- Review History 섹션으로 변경 추적

## PRP Analysis

### What (Functionality)

**01_confirm.md**와 **90_review.md**를 수정하여:
1. 리뷰 결과(Critical/Warning/Suggestion)를 AI가 직접 판단하여 계획 파일에 반영
2. 반영 내역을 `## Review History` 섹션으로 추적
3. 리뷰 → 반영 → 완료의 closed loop 구축

### Why (Context)

**현재 상태**: 리뷰 결과가 대화(메모리)에만 남고, 계획 파일은 그대로 유지됨

**문제점**:
- 실행 시 리뷰에서 발견된 이슈가 반영되지 않은 계획으로 진행
- 리뷰의 가치가 휘발성 피드백으로 끝남

**원하는 상태**: 리뷰 완료 = 계획 파일이 개선된 버전으로 업데이트됨

**Business Value**: 리뷰 품질이 실제 실행 품질로 이어지는 closed-loop 워크플로우

### How (Approach)

**Phase 1: 90_review.md 수정**
- Step 8 추가: "Apply Review Findings to Plan"
- 모든 이슈(Critical/Warning/Suggestion)를 계획에 자동 반영
- `## Review History` 섹션 추가하여 변경 추적

**Phase 2: 01_confirm.md 수정**
- Step 4.3 강화: 리뷰 결과 반영이 완료되어야 confirm 완료로 처리
- 반영 결과 확인 메시지 추가

### Success Criteria

```
SC-1: 리뷰 결과가 계획 파일에 직접 반영됨
- Verify: 리뷰 후 계획 파일에 수정사항 포함 여부
- Expected: Critical/Warning/Suggestion 모두 해당 섹션에 반영

SC-2: Review History 섹션이 생성됨
- Verify: 계획 파일에 ## Review History 섹션 존재
- Expected: 변경 이유와 원본/수정 내용 기록

SC-3: 01_confirm이 리뷰 반영 완료 후 종료
- Verify: confirm 완료 메시지에 반영 결과 포함
- Expected: "Review findings applied: N critical, N warning, N suggestion"
```

### Constraints

- 기존 명령어 구조 유지 (Step 넘버링, 섹션 형식)
- 계획 파일 형식 호환성 유지
- Read-only 특성 유지 (/00_plan), 수정 가능 (/01_confirm, /90_review)

## Scope

### In scope
- 90_review.md: Step 8 "Apply Review Findings" 추가
- 90_review.md: Review History 섹션 형식 정의
- 01_confirm.md: Step 4.3 반영 완료 확인 로직 강화

### Out of scope
- 다른 명령어 파일 수정
- 새로운 템플릿 파일 생성
- 테스트 자동화

## Architecture

### Issue-Section Mapping

> **[W3 반영]** 이슈 유형별 반영 위치 명확화

| Issue Type | Target Section | Apply Method |
|------------|---------------|--------------|
| Missing step | Execution Plan | 해당 Phase에 체크박스 추가 |
| Unclear requirement | User Requirements / Success Criteria | 명확한 문구로 수정 |
| Test gap | Test Plan | 테스트 시나리오 추가/수정 |
| Risk identified | Risks & Mitigations | 새 위험 항목 추가 |
| Alternative approach | How (Approach) | 대안 또는 수정된 접근법 반영 |
| Scope issue | Scope (In/Out) | 범위 조정 |

### Error Handling Policy

> **[W1 반영]** 반영 실패 시 롤백 처리

- 반영 중 오류 발생 시: 원본 계획 유지, 오류 내용을 Review History에 기록
- 부분 반영 시: 적용된 변경만 History에 기록, 미적용 항목 명시

### Data Structures

**Review History 섹션 형식**:
```markdown
## Review History

### Review #1 (2026-01-13 15:09)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 2 | 2 |
| Warning | 3 | 3 |
| Suggestion | 1 | 1 |

**Changes Made**:
1. **[Critical] Execution Plan - Phase 2**
   - Issue: Missing error handling step
   - Applied: Added "Handle API timeout errors" to Phase 2

2. **[Warning] Test Plan - TS-3**
   - Issue: Integration test scope too broad
   - Applied: Split into TS-3a, TS-3b with specific scenarios
```

### Module Boundaries

| File | Modification |
|------|-------------|
| `.claude/commands/90_review.md` | Add Step 8: Apply Review Findings + Update allowed-tools |
| `.claude/commands/01_confirm.md` | Enhance Step 4.3 with apply confirmation |

> **[W2 반영]** 90_review.md allowed-tools 업데이트 필요

## Execution Plan

### Phase 1: 90_review.md 수정
- [ ] Step 8 "Apply Review Findings to Plan" 섹션 추가
  - [ ] 8.1 Identify Changes: 반영할 변경사항 식별
  - [ ] 8.2 Apply Changes: 계획 파일에 변경 적용
  - [ ] 8.3 Update History: Review History 섹션 업데이트
- [ ] 반영 대상 매핑 테이블 정의 (이슈 유형 → 계획 섹션)
- [ ] Review History 섹션 형식 정의
- [ ] 성공 기준에 반영 완료 조건 추가
- [ ] allowed-tools에 Write 추가 (계획 파일 수정 권한)
- [ ] 반영 실패 시 원본 유지 정책 명시

### Phase 2: 01_confirm.md 수정
- [ ] Step 4.3 "Review Results" 테이블에 Applied 컬럼 추가
- [ ] STOP 섹션에 반영 결과 통계 추가

## Acceptance Criteria

- [ ] AC-1: 90_review.md에 Step 8 "Apply Review Findings to Plan" 존재
- [ ] AC-2: Step 8에 반영 대상 매핑 테이블 포함
- [ ] AC-3: Review History 섹션 형식 정의됨
- [ ] AC-4: 01_confirm.md Step 4.3에 반영 완료 확인 로직 포함
- [ ] AC-5: STOP 메시지에 반영 통계 포함

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | 리뷰 후 계획 반영 | Critical 이슈 있는 계획 | 해당 섹션 수정됨 | Manual |
| TS-2 | History 추적 | 리뷰 완료 후 | Review History 섹션 존재 | Manual |
| TS-3 | 완료 메시지 | confirm 완료 | 반영 통계 포함 | Manual |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 기존 계획 형식과 충돌 | Low | Medium | 섹션 추가만 하고 기존 구조 유지 |
| 과도한 자동 수정 | Medium | Low | 변경 이유를 History에 명확히 기록 |
| 반영 위치 불명확 | Medium | Medium | 이슈-섹션 매핑 테이블 명시 |

## Open Questions

1. ~~반영 범위: Critical만? 모두?~~ → 사용자 확인: 모든 이슈 자동 반영
2. ~~추적 방식: History 섹션? 별도 파일?~~ → 사용자 확인: Review History 섹션

---

## Review History

### Review #1 (2026-01-13 15:10)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 0 | 0 |
| Warning | 3 | 3 |
| Suggestion | 1 | 1 |

**Changes Made**:

1. **[W1] Requirements - Rollback handling**
   - Issue: 반영 실패 시 롤백 처리 미정의
   - Applied: Architecture 섹션에 "Error Handling Policy" 추가

2. **[W2] Project Alignment - allowed-tools**
   - Issue: 90_review.md의 allowed-tools에 Write가 없음
   - Applied: Module Boundaries에 allowed-tools 업데이트 명시, Execution Plan Phase 1에 항목 추가

3. **[W3] Requirements - 반영 대상 명확화**
   - Issue: 이슈 유형별 반영 위치 불명확
   - Applied: Architecture 섹션에 "Issue-Section Mapping" 테이블 추가

4. **[S1] Maintainability - Step 8 구조화**
   - Issue: Step 8이 길어질 수 있음
   - Applied: Execution Plan Phase 1의 Step 8을 8.1/8.2/8.3 서브섹션으로 분리

---

## Execution Summary

### Changes Made

**Phase 1: 90_review.md modifications**
- Added Step 8 "Apply Review Findings to Plan" with three subsections:
  - 8.1 Identify Changes: Maps issue types to target sections
  - 8.2 Apply Changes: Applies findings and handles errors
  - 8.3 Update History: Creates/updates Review History section
- Updated `allowed-tools`: Added `Write` tool for plan file modification
- Included Issue-Section Mapping table for deterministic routing
- Defined Review History format template
- Added Error Handling Policy for rollback scenarios

**Phase 2: 01_confirm.md modifications**
- Enhanced Step 4.3 "Review Results" with apply verification:
  - Added "Verify Apply Completion" checklist
  - Confirms Review History section exists
  - Verifies all findings have entries
- Updated STOP section with conditional review statistics:
  - Shows "Review findings applied to plan"
  - Shows "Review History updated with N changes"

### Verification

- ✅ AC-1: Step 8 exists in 90_review.md
- ✅ AC-2: Issue-Section Mapping table included
- ✅ AC-3: Review History format defined
- ✅ AC-4: Step 4.3 has apply verification logic
- ✅ AC-5: STOP message has apply statistics

### Follow-ups

None - all acceptance criteria met.

### Implementation Complete

The review → apply → complete closed-loop workflow is now implemented:
1. `/90_review` runs analysis and applies findings directly to plan file
2. Review History section tracks all changes
3. `/01_confirm` verifies apply completion before stopping
4. User sees clear feedback on what was applied
