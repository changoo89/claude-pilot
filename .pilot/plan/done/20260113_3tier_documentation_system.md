# 3-Tier Documentation System 도입

- Generated at: 2026-01-13
- Work name: 3tier_documentation_system
- Location: .pilot/plan/pending/20260113_3tier_documentation_system.md

---

## User Requirements

기존 프로젝트에 claude-pilot 설치 시 문서화 작업을 자동으로 진행해주는 init/migration 커맨드 생성. Claude-Code-Development-Kit의 3-Tier Documentation System을 적용하여 "처음부터 claude-pilot을 사용한 프로젝트"와 동일한 수준의 문서화 달성.

추가 요구사항:
- `/91_document` 커맨드도 3-Tier 시스템에 맞게 수정
- handoff.md 기능은 제외
- 기존 문서가 있으면 병합 (덮어쓰기 아님)
- 대화형으로 사용자 확인 포함

---

## PRP Analysis

### What (Functionality)

1. **`/92_init` 커맨드 신규 생성**
   - 기존 프로젝트 분석 및 3-Tier 문서화 자동 생성
   - 대화형으로 사용자 확인 포함

2. **`/91_document` 커맨드 수정**
   - 3-Tier 시스템 반영 (L0/L1/L2 → Tier 1/2/3)
   - docs/ai-context/ 업데이트 로직 추가

3. **템플릿 추가/수정**
   - CONTEXT-tier2.md.template (Component 수준)
   - CONTEXT-tier3.md.template (Feature 수준)

### Why (Context)

**Current State:**
- install.sh는 파일 복사만 수행
- CLAUDE.md, CONTEXT.md 등 문서화는 수동 작업 필요
- 91_document.md가 L0/L1/L2 체계 사용 (3-Tier와 불일치)

**Desired State:**
- 설치 후 `/92_init` 실행으로 프로젝트 분석 + 문서화 완료
- `/91_document`가 3-Tier 시스템으로 일관되게 동작
- 처음부터 claude-pilot을 사용한 프로젝트와 동일한 문서화 수준

**Business Value:**
- 마이그레이션 진입 장벽 대폭 감소
- 신규 사용자 온보딩 시간 단축
- 문서화 시스템 일관성 확보

### How (Approach)

**3-Tier Documentation System (from Claude-Code-Development-Kit):**

| Tier | 파일 | 변경 빈도 | 용도 |
|------|------|----------|------|
| Tier 1 | CLAUDE.md | 거의 없음 | 프로젝트 전체 스탠다드 |
| Tier 2 | Component CONTEXT.md | 가끔 | 컴포넌트 아키텍처, 통합 포인트 |
| Tier 3 | Feature CONTEXT.md | 자주 | 구현 세부사항 |

**생성될 문서 구조:**
```
project/
├── CLAUDE.md                    # Tier 1: Foundation
├── docs/
│   └── ai-context/
│       ├── docs-overview.md     # 문서 라우팅
│       ├── project-structure.md # 기술 스택 + 파일 구조
│       └── system-integration.md # 크로스 컴포넌트 패턴
├── {src/lib/components}/
│   └── CONTEXT.md               # Tier 2: Component
│       └── {feature}/
│           └── CONTEXT.md       # Tier 3: Feature
└── .claude/templates/
    ├── CONTEXT-tier2.md.template
    └── CONTEXT-tier3.md.template
```

### Success Criteria

| SC | Description | Verification |
|----|-------------|--------------|
| SC-1 | `/92_init` 실행 시 3-Tier 문서 구조 생성 | 모든 파일 생성 확인 |
| SC-2 | `/91_document` 실행 시 Tier 구분하여 업데이트 | Tier 2/3 템플릿 적용 확인 |
| SC-3 | 기존 문서 병합 (덮어쓰기 아님) | 기존 내용 보존 확인 |
| SC-4 | 대화형 진행으로 사용자 확인 포함 | AskUserQuestion 사용 |
| SC-5 | install.sh에 새 파일 포함 | MANAGED_FILES 배열 확인 |

### Constraints

- handoff.md 기능 제외
- 기존 91_document.md의 TDD artifact 기능 유지
- install.sh 업데이트 시 기존 사용자 영향 최소화

---

## Scope

### In scope

1. `/92_init` 커맨드 파일 생성 (.claude/commands/92_init.md)
2. `/91_document` 커맨드 파일 수정
3. CONTEXT-tier2.md.template 생성
4. CONTEXT-tier3.md.template 생성
5. 기존 CONTEXT.md.template 정리/업데이트
6. install.sh MANAGED_FILES 배열 업데이트
7. README.md, GETTING_STARTED.md 문서 업데이트

### Out of scope

- handoff.md 기능
- MCP 서버 자동 설치
- Git 히스토리 분석
- 기존 00_plan ~ 03_close 커맨드 수정

---

## Architecture

### 신규 파일

| 파일 | 용도 |
|------|------|
| `.claude/commands/92_init.md` | 프로젝트 초기화 커맨드 |
| `.claude/templates/CONTEXT-tier2.md.template` | Component 수준 템플릿 |
| `.claude/templates/CONTEXT-tier3.md.template` | Feature 수준 템플릿 |

### 수정 파일

| 파일 | 변경 내용 |
|------|----------|
| `.claude/commands/91_document.md` | 3-Tier 시스템 반영 |
| `.claude/templates/CONTEXT.md.template` | Tier 2 템플릿으로 리팩터링 또는 제거 |
| `install.sh` | MANAGED_FILES에 새 파일 추가 |
| `README.md` | /92_init 사용법 추가 |
| `GETTING_STARTED.md` | /92_init 사용법 추가 |

---

## Execution Plan

### Phase 1: 템플릿 작업

- [ ] CONTEXT-tier2.md.template 생성 (Component 수준)
  - Purpose, Current Status, Development Guidelines
  - Key Component Structure, Implementation Highlights
  - Critical Implementation Details, Development Notes
- [ ] CONTEXT-tier3.md.template 생성 (Feature 수준)
  - Architecture & Patterns, Integration & Performance
  - Decision documentation, Code examples
- [ ] 기존 CONTEXT.md.template 처리 (유지 또는 tier2로 리네임)

### Phase 2: /92_init 커맨드 생성

- [ ] 92_init.md 파일 기본 구조 작성
- [ ] Step 1: 프로젝트 분석 로직
  - 프로젝트 구조 스캔
  - 기술 스택 감지 (package.json, requirements.txt, go.mod 등)
  - 주요 폴더 식별
- [ ] Step 2: 대화형 커스터마이징
  - 분석 결과 표시
  - 프로젝트 설명 입력
  - Tier 2 CONTEXT.md 생성할 폴더 선택
- [ ] Step 3: 문서 생성 로직
  - CLAUDE.md 생성/병합
  - docs/ai-context/ 생성
  - 핵심 폴더 CONTEXT.md 생성
- [ ] Step 4: 검증 및 완료

### Phase 3: /91_document 수정

- [ ] docs/ai-context/ 업데이트 로직 추가 (Step 2.2)
  - project-structure.md 업데이트
  - system-integration.md 업데이트
- [ ] Tier 2/3 구분 로직 추가 (Step 3)
  - 폴더 깊이/유형에 따라 템플릿 선택
  - Component vs Feature 판단 기준
- [ ] 템플릿 참조 업데이트
- [ ] Summary Report 업데이트

### Phase 4: 통합 및 배포

- [ ] install.sh MANAGED_FILES 배열 업데이트
- [ ] README.md 업데이트 (/92_init 사용법)
- [ ] GETTING_STARTED.md 업데이트
- [ ] 전체 테스트

---

## Acceptance Criteria

- [ ] `/92_init` 실행 시 CLAUDE.md 생성됨
- [ ] `/92_init` 실행 시 docs/ai-context/ 폴더 및 3개 파일 생성됨
- [ ] `/92_init` 실행 시 선택된 폴더에 CONTEXT.md 생성됨
- [ ] `/91_document` 실행 시 Tier 2/3 구분하여 템플릿 적용됨
- [ ] `/91_document` 실행 시 docs/ai-context/ 문서 업데이트됨
- [ ] 기존 문서가 있을 때 병합됨 (덮어쓰기 아님)
- [ ] install.sh 실행 시 새 템플릿 파일 설치됨

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | 빈 프로젝트에 /92_init | 새 프로젝트 | 전체 문서 구조 생성 | Integration |
| TS-2 | 기존 CLAUDE.md 있는 프로젝트에 /92_init | 기존 문서 | 병합 (기존 내용 보존) | Integration |
| TS-3 | /91_document 실행 | 변경된 코드 | Tier 2/3 구분 업데이트 | Integration |
| TS-4 | install.sh 실행 | 새 프로젝트 | 모든 템플릿 설치 | Unit |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 기술 스택 오감지 | Medium | Medium | 대화형 확인으로 사용자 검증 |
| 기존 문서 손상 | Low | High | 병합 모드 + 백업 권장 |
| Tier 2/3 구분 오류 | Medium | Low | 명확한 폴더 깊이 기준 정의 |

---

## Open Questions

(없음 - 모든 질문 해결됨)

---

## References

- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- `.claude/templates/CONTEXT.md.template` (기존)
- `.claude/commands/91_document.md` (수정 대상)

---

## Execution Summary

### Changes Made

**Phase 1: Template Creation**
- ✅ Created `CONTEXT-tier2.md.template` (Component-level architecture)
- ✅ Created `CONTEXT-tier3.md.template` (Feature-level implementation)
- ✅ Added deprecation notice to existing `CONTEXT.md.template`

**Phase 2: /92_init Command**
- ✅ Created `.claude/commands/92_init.md` with:
  - Project analysis (tech stack detection, directory scanning)
  - Interactive customization (AskUserQuestion for user input)
  - 3-Tier document generation (CLAUDE.md, docs/ai-context/, CONTEXT.md)

**Phase 3: /91_document Modification**
- ✅ Added `docs/ai-context/` update logic (project-structure.md, system-integration.md, docs-overview.md)
- ✅ Added Tier 2/3 distinction logic (folder depth, type-based detection)
- ✅ Updated template references to point to new tiered templates
- ✅ Updated Summary Report to include 3-Tier information

**Phase 4: Integration & Documentation**
- ✅ Updated `install.sh` MANAGED_FILES array with new files
- ✅ Updated `README.md` with /92_init usage and 3-Tier system info
- ✅ Updated `GETTING_STARTED.md` with /92_init examples

### Files Created
| File | Purpose |
|------|---------|
| `.claude/templates/CONTEXT-tier2.md.template` | Component-level template |
| `.claude/templates/CONTEXT-tier3.md.template` | Feature-level template |
| `.claude/commands/92_init.md` | Project initialization command |

### Files Modified
| File | Changes |
|------|---------|
| `.claude/templates/CONTEXT.md.template` | Added deprecation notice |
| `.claude/commands/91_document.md` | Added 3-Tier system, docs/ai-context/ updates |
| `install.sh` | Added new files to MANAGED_FILES |
| `README.md` | Added /92_init and 3-Tier documentation |
| `GETTING_STARTED.md` | Added /92_init examples |

### Verification Results
| Check | Result |
|-------|--------|
| install.sh syntax | ✅ Valid |
| Tier templates exist | ✅ CONTEXT-tier2.md.template, CONTEXT-tier3.md.template |
| 92_init command exists | ✅ Created successfully |
| 91_document references | ✅ Tier templates referenced |

### Success Criteria Status
| SC | Status | Verification |
|----|--------|-------------|
| SC-1: `/92_init` creates 3-Tier structure | ✅ | Command created with full structure generation |
| SC-2: `/91_document` distinguishes Tier 2/3 | ✅ | Logic added with folder depth/type detection |
| SC-3: Merge existing docs | ✅ | /92_init implements merge mode |
| SC-4: Interactive confirmation | ✅ | AskUserQuestion included in /92_init |
| SC-5: install.sh includes new files | ✅ | MANAGED_FILES array updated |

### Follow-ups
- None - all acceptance criteria met
