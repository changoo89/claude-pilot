---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore codebase, gather requirements, and design SPEC-First execution plan (read-only)._

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Collaborative**: Dialogue with user to clarify ambiguities

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

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

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

**⚠️ CRITICAL**: /00_plan is read-only. Implementation starts ONLY after `/01_confirm` → `/02_execute`
