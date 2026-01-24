---
name: confirm-plan
description: Plan confirmation workflow - extract plan from conversation, create file, auto-review with Interactive Recovery. Use for confirming plans after /00_plan.
---

# SKILL: Confirm Plan (Plan Confirmation Workflow)

> **Purpose**: Extract plan from conversation, create plan file, run auto-review with Interactive Recovery
> **Target**: Plan-Reviewer Agent confirming plans after `/00_plan`

---

## Quick Start

### When to Use This Skill
- Confirm plan after `/00_plan` completes
- Create plan file in `.pilot/plan/pending/`
- Run auto-review with Interactive Recovery for BLOCKING findings
- Verify 100% requirements coverage

### Quick Reference
```bash
# Extract plan from conversation
PLAN_CONTENT=$(extract_from_conversation "$CONVERSATION")

# Generate plan file name
TS="$(date +%Y%m%d_%H%M%S)"
PLAN_FILE="$PROJECT_ROOT/.pilot/plan/pending/${TS}_{work_name}.md"

# Requirements verification (BLOCKING if incomplete)
verify_requirements_coverage "$PLAN_CONTENT"

# Auto-review with Interactive Recovery
invoke_plan-reviewer "$PLAN_FILE"
resolve_blocking_findings "$PLAN_FILE"
```

---

## What This Skill Covers

### In Scope
- **Dual-source extraction**: Load decisions from draft file + scan conversation
- **Cross-check verification**: Compare draft vs conversation, detect omissions
- Plan file creation with full template structure
- Requirements verification (100% coverage required)
- Conversation highlights extraction (code examples, diagrams)
- Auto-review with Interactive Recovery for BLOCKING findings
- GPT delegation for large plans (5+ SCs)

### Out of Scope
- Plan creation → `/00_plan` command
- Plan execution → `/02_execute` command
- TDD methodology → @.claude/skills/tdd/SKILL.md

---

## Core Philosophy

**No Execution**: Only creates plan file and reviews | **Context-Driven**: Extract from conversation | **English Only**: Plan MUST be in English | **Strict Mode Default**: BLOCKING → Interactive Recovery

---

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 2.5 → 3 → 4 in sequence
- Only stop for BLOCKING findings that require Interactive Recovery

---

## Step 1: Dual-Source Extraction

### Step 1.1: Load Draft File

**Strategy**: Reuse draft from /00_plan when available, create new if not found.

```bash
PROJECT_ROOT="$(pwd)"

# First, look for *_draft.md (new naming)
DRAFT_FILE="$(find "$PROJECT_ROOT/.pilot/plan/draft" -name "*_draft.md" -type f 2>/dev/null | sort -r | head -1)"

# Backward compatibility: if no draft.md found, look for *_decisions.md (old naming)
if [ -z "$DRAFT_FILE" ]; then
    DECISIONS_FILE="$(find "$PROJECT_ROOT/.pilot/plan/draft" -name "*_decisions.md" -type f 2>/dev/null | sort -r | head -1)"
    if [ -n "$DECISIONS_FILE" ]; then
        echo "⚠️ Found legacy *_decisions.md file: $DECISIONS_FILE"
        echo "   Will rename to *_draft.md for backward compatibility"
        DRAFT_FILE="$DECISIONS_FILE"
    fi
fi

if [ -n "$DRAFT_FILE" ]; then
    echo "✓ Found draft file: $DRAFT_FILE"
    DRAFT_EXISTS=true
else
    echo "⚠️ No draft file found - will create new draft file"
    DRAFT_EXISTS=false
fi
```

**Parse Draft Content** if file exists:
- Extract Decisions table (D-1, D-2, etc.)
- Extract User Requirements table (UR-1, UR-2, etc.)
- Preserve existing content for merging

### Step 1.2: Scan Conversation (LLM Context)

LLM scans entire `/00_plan` conversation to extract:
- User Requirements (Verbatim) with IDs (UR-1, UR-2, ...)
- Decisions, scope confirmations, approach selections, constraints

### Step 1.3: Cross-Check

Compare draft vs conversation. Flag MISSING items (in conversation but not in draft).

### Step 1.4: Resolve Omissions

If MISSING items found, use AskUserQuestion (multi-select) to resolve:

```markdown
AskUserQuestion:
  question: "The following items were found in conversation but not in decisions log. Select items to include:"
  header: "Omissions"
  multiSelect: true
  options:
    - label: "[Item 1]"
      description: "Include in plan"
    - label: "[Item 2]"
      description: "Include in plan"
    - label: "Mark all as out of scope"
      description: "Exclude all missing items"
```

After resolution, proceed to Step 2.

### Step 1.5: Conversation Highlights Extraction

**Purpose**: Capture implementation details from `/00_plan` conversation

**Scan For**:
- Code blocks (```language, ```)
- CLI commands with specific flags
- API invocation examples
- Architecture diagrams (ASCII/Mermaid)

**Output Format**: Mark with `> **FROM CONVERSATION:**` prefix in plan file

### Step 1.6: Requirements Verification (BLOCKING)

Verify 100% requirements coverage before creating plan file:

1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Use AskUserQuestion to resolve before proceeding

**⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.

### Step 1.7: Scope Completeness Verification (NEW)

**Purpose**: 계획이 확인된 범위를 모두 커버하는지 검증

**Check:**

1. **Scope vs SC Mapping**
   - 사용자가 선택한 각 scope 영역에 대응하는 SC가 있는가?
   - 예: scope에 "프론트엔드" 포함 → SC에 UI 관련 기준 있어야 함

2. **Assumption Verification**
   - Assumptions 테이블의 모든 항목이 ✅ Verified인가?
   - ⚠️ 항목 있으면 BLOCKING

3. **Layer Coverage**
   - 탐색에서 발견된 레이어 중 계획에서 제외된 것이 있는가?
   - 제외된 레이어가 있다면 사용자가 명시적으로 제외했는가?

**BLOCKING if:**
- Scope 영역 중 SC 매핑이 없는 것이 있음
- Unverified assumptions 존재
- 제외된 레이어에 대한 사용자 확인 없음

---

### Step 1.9: Self-Contained Verification (MANDATORY)

**Purpose**: Ensure plan is executable without external access

**9-Point Verification Checklist** (from GPT Architect + User):

1. **References Embedded**: Every "reference" is embedded or replaced by measurable rules
   - Scan for: URLs, "like X", "see Y", "use Z API/library"
   - Verify: Corresponding Context Pack section exists

2. **Executor Clarity**: New executor can answer "what exactly should I build?"
   - Mental test: Remove conversation, read only plan
   - Verify: All implementation decisions are explicit

3. **Dependencies Pinned**: Versions, configs, environment assumptions included
   - Check: Library versions, API versions, env vars documented
   - Verify: Install/run steps are complete

4. **Testable Acceptance**: Criteria testable from repo + embedded artifacts
   - Check: No subjective criteria ("looks right")
   - Verify: Each SC has verification command

5. **Unknowns Enumerated**: Gaps listed with resolution policy
   - Check: Assumptions table complete
   - Verify: Each unknown has "ask user" or "use default"

6. **Verification Commands**: Map directly to acceptance criteria
   - Check: Each SC has test command
   - Verify: Commands are executable

7. **Concrete Examples**: Provided for ambiguous areas
   - Check: Code snippets, mock payloads, UI specs
   - Verify: No vague descriptions

8. **Conversation Deleted Test**: Plan still determines implementation
   - Mental test: If /00_plan conversation deleted entirely
   - Verify: Plan alone is sufficient

9. **Zero-Knowledge TODO Test**: Each TODO executable without thinking
   - Check: File paths explicit, values exact, code copy-pasteable
   - Verify: No conditionals ("필요시", "적절히"), no vague terms
   - Test: "아무것도 모르는 실행자가 이 TODO만 보고 바로 실행 가능한가?"

**BLOCKING if**: Any check fails

**Resolution per check**:
```markdown
AskUserQuestion:
  question: "Self-contained verification failed: {check_name}. How to resolve?"
  header: "Verify"
  options:
    - label: "Go back to /00_plan"
      description: "Add missing context"
    - label: "Provide details now"
      description: "I'll describe inline"
    - label: "Mark as assumption"
      description: "Add to Assumptions with default"
```

**⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.

---

## Step 2: Create or Update Plan File in draft/

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

### If Draft Exists (reuse and update)

```bash
# Use the existing DRAFT_FILE from Step 1.1
if [ "$DRAFT_EXISTS" = true ]; then
    PLAN_FILE="$DRAFT_FILE"
    echo "✓ Reusing existing draft: $PLAN_FILE"
else
    # Create new draft file
    TS="$(date +%Y%m%d_%H%M%S)"
    PLAN_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_draft.md"
    echo "✓ Creating new draft: $PLAN_FILE"
fi
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
```

**Strategy**:
- **If draft exists**: Reuse and update existing file with complete plan content (merge draft + conversation extraction)
- **If not found**: Create new draft file with complete plan content
- **Backward compatibility**: If `*_decisions.md` found, rename to `*_draft.md` before updating

**Note**: Do NOT use relative paths. The plan must always be created in the project where Claude Code was launched, not in any subdirectory being explored.

**Plan Template**:
```markdown
# Work Title

## User Requirements (Verbatim)
[UR table with 100% coverage check]

## Context Pack

### Goal
[User-facing outcome - what success looks like]

### Inputs (Embedded)
[Per context type - see formats below]

### Derived Requirements
- [DR-1]: [Measurable requirement extracted from inputs]
- [DR-2]: [Another requirement - bullets, not references]

### Assumptions & Unknowns
| ID | Item | Status | Resolution |
|----|------|--------|------------|
| A-1 | [Assumption] | Verified | [How verified] |
| A-2 | [Unknown] | Unknown | Ask user / Default: [value] |

### Traceability Map
| Requirement | Source |
|-------------|--------|
| DR-1 | Context Pack → Inputs → [specific excerpt] |

## Success Criteria
- [ ] **SC-1**: [Outcome] - Verify: [command]

## PRP Analysis
### What, Why, How

## Test Plan
[Test scenarios]

## Assumptions

| ID | Assumption | Verified? |
|----|------------|-----------|
| A-1 | [가정 내용] | ✅ / ⚠️ |

## Design Requirements

| Property | Value | Source |
|----------|-------|--------|
| Aesthetic Direction | Minimal (default) | House style |
| Color Palette | Off-white backgrounds, no purple-blue gradients | frontend-design skill |
| Typography | Geist/Satoshi (never Inter) | frontend-design skill |
| Component Style | Varied radii, subtle borders, proper states | frontend-design skill |

## Context Pack Formats (Reference)

### Design Context Pack
```markdown
### Inputs (Embedded) - Design

> **Source**: {url}
> **Captured**: {timestamp}

#### Visual Analysis
| Property | Value | Notes |
|----------|-------|-------|
| Primary Color | #XXXXXX | Buttons, accents |
| Background | #FAFAFA | Off-white, not pure white |
| Font Family | Geist Sans | Headings + Body |
| Grid System | 12-col | Max-width: 1200px |
| Border Radius | 8px | Cards, buttons |

#### Component Breakdown
- **Hero**: 100vh, gradient background (#XXX→#YYY), centered text
- **Navigation**: Fixed, logo left, menu right, blur backdrop
- **Cards**: 3-col grid, 16px gap, subtle shadow, hover lift

#### Interactions
- **Hover**: scale(1.02), 200ms ease-out
- **Scroll**: fade-in on viewport entry
```

### API Context Pack
```markdown
### Inputs (Embedded) - API

> **Source**: {docs_url}
> **Version**: v2024.01

#### Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/checkout/sessions | Create checkout session |
| GET | /v1/checkout/sessions/{id} | Retrieve session |

#### Request Schema
```json
{
  "line_items": [{ "price": "price_xxx", "quantity": 1 }],
  "mode": "payment",
  "success_url": "https://...",
  "cancel_url": "https://..."
}
```

#### Auth
- Header: `Authorization: Bearer sk_xxx`
- Test key prefix: `sk_test_`

#### Error Cases
| Code | Meaning | Handle |
|------|---------|--------|
| 400 | Invalid request | Show validation error |
| 402 | Payment failed | Retry with different method |
```

### Library Context Pack
```markdown
### Inputs (Embedded) - Library

> **Package**: next-auth
> **Version**: ^4.24.5 (PINNED)

#### Installation
```bash
npm install next-auth@4.24.5
```

#### Configuration
```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from "next-auth"
import GithubProvider from "next-auth/providers/github"

export const authOptions = {
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_ID,
      clientSecret: process.env.GITHUB_SECRET,
    }),
  ],
}

export default NextAuth(authOptions)
```

#### Required Environment
```
GITHUB_ID=xxx
GITHUB_SECRET=xxx
NEXTAUTH_SECRET=xxx
NEXTAUTH_URL=http://localhost:3000
```
```

## Zero-Knowledge TODO Format (MANDATORY)

### Principles
> "아무것도 모르는 실행자가 생각 없이 따라할 수 있는 수준"

| Rule | Bad Example ❌ | Good Example ✅ |
|------|---------------|-----------------|
| **파일 경로 명시** | "컴포넌트 생성" | "src/components/Hero.tsx 파일 생성" |
| **정확한 값 포함** | "적절한 색상 사용" | "배경색 #FAFAFA, 버튼색 #0066FF 사용" |
| **코드 스니펫 포함** | "타입 정의" | "interface Props { title: string; onClick: () => void }" |
| **명령어 그대로 복사** | "패키지 설치" | "npm install next-auth@4.24.5 --save-exact" |
| **위치 정확히 지정** | "import 추가" | "line 3에 import { Button } from '@/components/Button' 추가" |
| **조건문 없음** | "필요시 추가" | "무조건 추가" (조건 판단 금지) |

### TODO Format Example

**❌ BAD (vague, requires thinking)**:
```markdown
- [ ] TODO-1.1: Hero 컴포넌트 생성
- [ ] TODO-1.2: 적절한 스타일링 적용
- [ ] TODO-1.3: 필요한 props 추가
```

**✅ GOOD (Zero-Knowledge executable)**:
```markdown
- [ ] TODO-1.1: `src/components/Hero.tsx` 파일 생성, 다음 코드 복사:
  ```tsx
  export function Hero() {
    return (
      <section className="h-screen bg-gradient-to-b from-[#1a1a2e] to-[#16213e]">
        <div className="max-w-6xl mx-auto px-4 pt-32">
          <h1 className="text-5xl font-bold text-white">Title Here</h1>
        </div>
      </section>
    )
  }
  ```
- [ ] TODO-1.2: `src/app/page.tsx` line 3에 import 추가:
  ```tsx
  import { Hero } from '@/components/Hero'
  ```
- [ ] TODO-1.3: `src/app/page.tsx` line 8 (return 내부 첫 줄)에 추가:
  ```tsx
  <Hero />
  ```
```

---

## Step 2.5: GPT Delegation Check

**Trigger**: Large plans (5+ Success Criteria) automatically trigger GPT Plan Reviewer

```bash
# Check if Codex CLI is available
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
else
  # Count Success Criteria in plan
  SC_COUNT=$(grep -c "^- \[ \] \*\*SC-" "$PLAN_FILE" 2>/dev/null || echo 0)

  if [ "$SC_COUNT" -ge 5 ]; then
    echo "Large plan detected ($SC_COUNT SCs) - delegating to GPT Plan Reviewer..."

    # Delegate to GPT Plan Reviewer using direct codex CLI
    PLAN_CONTENT=$(cat "$PLAN_FILE")
    REVIEWER_PROMPT="You are a Plan Reviewer analyzing a large implementation plan.
PLAN CONTENT:
$PLAN_CONTENT

REVIEW CRITERIA:
- Clarity: Are requirements clear?
- Completeness: Are all SCs measurable?
- Feasibility: Is approach realistic?
- Dependencies: Are they identified?
- Risks: Are they mitigated?

OUTPUT: Quality score (1-10), issues found, recommendations"

    # ⚠️ CRITICAL: Use EXACTLY these parameters
    # - Model: gpt-5.2 (NEVER change)
    # - Sandbox: read-only (for advisory mode - NEVER use workspace-write, workspace-read, or any variation)
    # - Reasoning: reasoning_effort=medium (MUST be medium - NEVER use high/low)
    codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "$REVIEWER_PROMPT"

    echo "GPT Plan Reviewer analysis complete"
  fi
fi
```

**Note**: Graceful fallback if Codex CLI not installed (continues with Claude-only analysis)

---

## Step 3: Auto-Review & Auto-Apply

**Invoke plan-reviewer agent** for analysis:

**Findings**:
- **BLOCKING**: Interactive Recovery (AskUserQuestion)
- **Critical**: Auto-apply
- **Warning**: Auto-apply
- **Suggestion**: Auto-apply

**Auto-apply pattern**: Edit plan file with improvements

**Workflow**:
1. Invoke plan-reviewer agent
2. Check for BLOCKING findings
3. If BLOCKING > 0 → Interactive Recovery loop
4. Use AskUserQuestion to resolve each BLOCKING
5. Re-run plan-reviewer after updates
6. Continue until BLOCKING = 0 or max iterations (5)

**Default**: Strict mode (BLOCKING → Interactive Recovery)
**Exceptions**: `--no-review` (skip), `--lenient` (BLOCKING → WARNING)

---

## Step 4: Move to pending

```bash
# Use same PROJECT_ROOT from Step 2
mkdir -p "$PROJECT_ROOT/.pilot/plan/pending"
mv "$PLAN_FILE" "$PROJECT_ROOT/.pilot/plan/pending/$(basename "$PLAN_FILE")"
echo "✓ Plan ready for execution: /02_execute"
```

**🛑 STOP HERE**:
- Do NOT proceed to /02_execute automatically
- Do NOT execute the plan
- Wait for user to explicitly run `/02_execute`

---

## GPT Delegation

| Trigger | Action |
|---------|--------|
| 5+ SCs | Delegate to GPT Plan Reviewer |
| User requests | Delegate to GPT Plan Reviewer |

**Fallback**: `if ! command -v codex &> /dev/null; then echo "Falling back to Claude-only"; return 0; fi`

---

## Argument Parsing

Parse `$ARGUMENTS` from command invocation:
- `[work_name]`: Optional work name for plan file
- `--lenient`: Bypass BLOCKING findings
- `--no-review`: Skip all review steps

**Example**:
```bash
# Parse arguments
WORK_NAME=""
LENIENT_MODE=false
NO_REVIEW=false

for arg in $ARGUMENTS; do
  case $arg in
    --lenient)
      LENIENT_MODE=true
      ;;
    --no-review)
      NO_REVIEW=true
      ;;
    *)
      WORK_NAME="$arg"
      ;;
  esac
done
```

---

## Related Skills

**spec-driven-workflow**: SPEC-First methodology (Problem-Requirements-Plan) | **gpt-delegation**: Codex integration with fallback | **git-operations**: Safe git operations

---

## Further Reading

**Internal**: @.claude/skills/confirm-plan/REFERENCE.md - Detailed implementation, step-by-step methodology, Interactive Recovery patterns | @.claude/skills/spec-driven-workflow/SKILL.md - SPEC-First methodology (Problem-Requirements-Plan)

**External**: [Specification by Example](https://www.amazon.com/Specification-Example-Gojko-Adzic/dp/0321842733) | [User Stories Applied](https://www.amazon.com/Stories-Agile-Development-Software-Cohn/dp/0321205685)

---

**⚠️ MANDATORY**: This skill only creates plan. Run `/02_execute` to implement.
