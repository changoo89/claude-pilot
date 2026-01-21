---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore codebase, gather requirements, and design SPEC-First execution plan (read-only)._

---

## EXECUTION DIRECTIVE

**THIS IS A DIALOGUE PHASE - NOT AN EXECUTION PHASE**

You MUST follow this interaction pattern:

1. **ASK before acting**: Every major step requires user input
2. **WAIT for response**: Do not proceed until user responds
3. **NEVER auto-execute**: Do not run /01_confirm or /02_execute without explicit user request
4. **ONE question at a time**: Don't overwhelm with multiple questions

**MANDATORY Checkpoints** (must use AskUserQuestion):
- [ ] After codebase exploration → Ask what areas to focus on
- [ ] After requirements gathering → Confirm understanding is correct
- [ ] After proposing approaches → Let user choose approach
- [ ] After each design section → Validate before proceeding
- [ ] Before completing → Ask user's next step preference

**PROHIBITED Actions**:
- Creating plan files without user approval
- Running /01_confirm automatically
- Running /02_execute automatically
- Skipping user validation checkpoints
- Assuming user agreement without explicit confirmation

---

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Collaborative**: Dialogue with user to clarify ambiguities - **EVERY STEP requires user input**

---

## Step 1: Explore Codebase

```bash
# Find relevant files
find . -name "*.ts" -o -name "*.js" -o -name "*.md" | head -20

# Search for patterns
grep -r "keyword" src/ --include="*.ts"
```

---

## Step 1.1: Parallel Exploration (Codebase + External Research)

Launch explorer and researcher in parallel for faster context gathering:

### Task 1.1a: Codebase Exploration

```markdown
Task:
  subagent_type: explorer
  prompt: |
    Explore codebase for {task_description}
    - Find relevant TypeScript/JavaScript files in src/
    - Look for existing patterns related to {domain}
    - Identify config files, test files, and documentation
    - Search for similar implementations using Grep/Glob
    Output: File list with brief descriptions
```

### Task 1.1b: External Research

```markdown
Task:
  subagent_type: researcher
  prompt: |
    Research external documentation for {task_description}
    - Search for official docs and API references
    - Find best practices and design patterns
    - Identify security considerations
    - Look for similar implementations/examples
    Output: Research summary with links and recommendations
```

**Expected Speedup**: 50-60% faster exploration (codebase + external research in parallel)

---

## CHECKPOINT 1: Exploration Review (MANDATORY)

**STOP HERE** - Do not proceed until user responds.

```markdown
AskUserQuestion:
  questions:
    - question: "코드베이스 탐색 결과를 공유했습니다. 어떤 부분에 집중할까요?"
      header: "탐색 결과"
      options:
        - label: "A) 발견한 영역이 맞음"
          description: "이 영역들을 기반으로 요구사항 수집 진행"
        - label: "B) 다른 영역 탐색 필요"
          description: "추가로 살펴볼 영역을 알려주세요"
        - label: "C) 더 자세히 설명해줘"
          description: "발견한 내용을 더 상세히 설명"
      multiSelect: false
```

---

## Step 2: Gather Requirements

**User Requirements (Verbatim)**: Capture user's exact input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | timestamp | "exact user input" | Summary |

---

## Step 2.5: Dialogue-Based Requirements Gathering

**Superpowers Pattern**: 한 번에 하나씩 질문, 객관식 선호

**Key Principles**:
- **Only one question per message**: Don't overwhelm the user
- **Multiple choice preferred**: Easier for users to respond
- **Be flexible**: Go back and clarify if needed

**Example Pattern**:
```markdown
After initial requirements gathering, use AskUserQuestion:

AskUserQuestion:
  questions:
    - question: "이 기능의 우선순위가 무엇인가요?"
      header: "우선순위"
      options:
        - label: "A) 빠른 구현"
          description: "MVP로 빠르게 출시, 나중에 개선"
        - label: "B) 완전한 기능"
          description: "처음부터 모든 기능 구현"
        - label: "C) 절충"
          description: "핵심 기능 위주, 확장 가능하게"
      multiSelect: false
```

---

## CHECKPOINT 2: Requirements Confirmation (MANDATORY)

**STOP HERE** - Do not proceed until user confirms requirements understanding.

```markdown
AskUserQuestion:
  questions:
    - question: "제가 이해한 요구사항이 맞나요?"
      header: "요구사항 확인"
      options:
        - label: "A) 맞아요, 진행해주세요"
          description: "요구사항 이해가 정확함"
        - label: "B) 일부 수정 필요"
          description: "몇 가지 부분을 수정/추가하고 싶어요"
        - label: "C) 다시 설명해줄게요"
          description: "요구사항을 다시 정리해서 알려드릴게요"
      multiSelect: false
```

---

## Step 3: Create SPEC-First Plan

**PRP Framework**:
1. **What** (Functionality): What needs to be built
2. **Why** (Context): Business value and rationale
3. **How** (Approach): Implementation strategy
4. **Success Criteria**: Measurable acceptance criteria

**Success Criteria Format**:
```markdown
- [ ] **SC-1**: [Measurable outcome]
  - **Verify**: [test command]
```
---

## Step 3.5: Explore Approaches (접근법 탐색)

**Superpowers Pattern**: Propose 2-3 different approaches with trade-offs

**Key Principles**:
- Present 2-3 distinct implementation approaches
- Highlight pros (장점) and cons (단점) for each
- Recommend one approach with clear reasoning
- Use AskUserQuestion to get user preference

**Example Pattern**:
```markdown
**접근법 A (추천)**: 기존 아키텍처 확장
- 장점: 빠른 구현, 일관성 유지
- 단점: 확장성 제한
- 추천 이유: 현재 요구사항에 충분

**접근법 B**: 새로운 모듈로 분리
- 장점: 확장성, 테스트 용이
- 단점: 초기 구현 시간

**접근법 C**: 완전한 재작성
- 장점: 최신 패턴 적용, 기술 부채 해결
- 단점: 높은 리스크, 긴 개발 시간

AskUserQuestion:
  questions:
    - question: "어떤 접근법을 선호하나요?"
      header: "접근법 선택"
      options:
        - label: "A) 기존 아키텍처 확장"
          description: "빠른 구현, 일관성 유지"
        - label: "B) 새로운 모듈로 분리"
          description: "확장성, 테스트 용이"
        - label: "C) 완전한 재작성"
          description: "최신 패턴, 기술 부채 해결"
      multiSelect: false
```

---

## CHECKPOINT 3: Approach Selection (MANDATORY)

**STOP HERE** - User MUST select an approach before proceeding to detailed design.

This checkpoint is CRITICAL. Do NOT assume user preference. Do NOT proceed with a "recommended" approach without explicit user confirmation.

---

## Step 4: Requirements Coverage Check

**Verify 100% mapping** (UR → SC):

| Requirement | In Scope | Success Criteria | Status |
|-------------|----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |

---

## Step 4.5: Incremental Design Validation (섹션별 검증)

**Superpowers Pattern**: Break design into sections of 200-300 words, validate incrementally

**Key Principles**:
- Present design in small sections (200-300 words each)
- Check for understanding after each section
- Allow users to ask questions or request changes
- Use AskUserQuestion to confirm before proceeding

**Example Pattern**:
```markdown
**Section 1: 아키텍처**
[아키텍처 설명 200-300단어]
- 전체 시스템 구조
- 주요 컴포넌트 관계
- 데이터 흐름

AskUserQuestion:
  questions:
    - question: "지금까지 맞나요?"
      header: "아키텍처 검증"
      options:
        - label: "A) 계속 진행"
          description: "다음 섹션으로 넘어갑니다"
        - label: "B) 수정 필요"
          description: "이 부분을 다시 설명하거나 수정합니다"
        - label: "C) 다시 설명"
          description: "다른 방식으로 설명해주세요"
      multiSelect: false

**Section 2: 컴포넌트 설계**
[컴포넌트 설명 200-300단어]
...

**Section 3: API 설계**
[API 설명 200-300단어]
...
```

---

## Step 5: Confirm Plan Complete

## CHECKPOINT 4: Final User Decision (MANDATORY)

**STOP HERE** - This is the FINAL checkpoint. User MUST explicitly choose next action.

**NEVER auto-proceed to /01_confirm or /02_execute.**

```markdown
AskUserQuestion:
  questions:
    - question: "계획이 완성되었습니다. 다음 단계를 선택해주세요."
      header: "다음 단계"
      options:
        - label: "A) 계획 수정 계속"
          description: "계획을 더 다듬거나 수정하고 싶어요"
        - label: "B) 다른 접근법 탐색"
          description: "대안적인 접근 방식을 보고 싶어요"
        - label: "C) /01_confirm 실행"
          description: "계획을 파일로 저장하고 검토할게요"
        - label: "D) /02_execute 실행"
          description: "바로 구현을 시작할게요"
      multiSelect: false
```

**IMPORTANT**: Only run /01_confirm or /02_execute when user explicitly selects option C or D.

---

## GPT Delegation Triggers

| Trigger | Action |
|---------|--------|
| Architecture decision | Delegate to GPT Architect |
| User explicitly requests | Delegate to GPT Architect |
| 2+ failed attempts | Delegate to GPT Architect |

**Graceful fallback**: `if ! command -v codex &> /dev/null; then echo "Falling back to Claude-only analysis"; return 0; fi`

---

## Related Skills

**spec-driven-workflow**: SPEC-First methodology | **gpt-delegation**: GPT consultation with fallback | **parallel-subagents**: Parallel exploration patterns

---

## Summary: Dialogue Flow

```
CHECKPOINT 1: Exploration Review
      ↓ (user confirms)
CHECKPOINT 2: Requirements Confirmation
      ↓ (user confirms)
CHECKPOINT 3: Approach Selection
      ↓ (user selects)
CHECKPOINT 4: Final Decision
      ↓ (user chooses next step)
```

**Each checkpoint requires AskUserQuestion and user response before proceeding.**

---

**⚠️ CRITICAL**:
- /00_plan is **read-only** and **dialogue-based**
- You MUST use AskUserQuestion at each CHECKPOINT
- You MUST wait for user response before proceeding
- Implementation starts ONLY when user explicitly requests `/01_confirm` → `/02_execute`
- NEVER assume user agreement - always ask explicitly
