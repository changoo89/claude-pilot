# Confirm Plan - Detailed Reference

> **Companion**: `SKILL.md` | **Purpose**: Detailed implementation reference for plan confirmation workflow

---

## Detailed Step Implementation

### Step 1: Dual-Source Extraction (Full Details)

> **Purpose**: Extract from both draft decisions file AND conversation to prevent omissions
> **PRP Framework**: See @.claude/skills/spec-driven-workflow/SKILL.md

#### Step 1.1: Load Draft File

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

#### Step 1.2: Scan Conversation (LLM Context)

LLM scans entire `/00_plan` conversation to extract:
- User Requirements (Verbatim) with IDs (UR-1, UR-2, ...)
- Decisions, scope confirmations, approach selections, constraints

#### Step 1.3: Cross-Check

Compare draft vs conversation. Flag MISSING items (in conversation but not in draft).

#### Step 1.4: Resolve Omissions

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

#### Step 1.5: Conversation Highlights Extraction

**Purpose**: Capture implementation details from `/00_plan` conversation

**Scan For**:
- Code blocks (```language, ```)
- CLI commands with specific flags
- API invocation examples
- Architecture diagrams (ASCII/Mermaid)

**Output Format**: Mark with `> **FROM CONVERSATION:**` prefix in plan file

#### Step 1.6: Requirements Verification (BLOCKING)

Verify 100% requirements coverage before creating plan file:

1. Extract User Requirements (Verbatim) table (UR-1, UR-2, ...)
2. Extract Success Criteria (SC-1, SC-2, ...)
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Use AskUserQuestion to resolve before proceeding

**⚠️ CRITICAL**: Do NOT proceed to Step 2 if BLOCKING findings exist.

#### Step 1.7: Scope Completeness Verification

**Purpose**: Verify plan covers all confirmed scopes

**Check:**

1. **Scope vs SC Mapping**
   - Does each selected scope area have a corresponding SC?
   - Example: scope includes "frontend" → SC should have UI-related criteria

2. **Assumption Verification**
   - Are all items in Assumptions table ✅ Verified?
   - Any ⚠️ item is BLOCKING

3. **Layer Coverage**
   - Were any discovered layers excluded from plan?
   - If yes, did user explicitly exclude them?

**BLOCKING if:**
- Scope area without SC mapping exists
- Unverified assumptions exist
- Excluded layer without user confirmation exists

#### Step 1.9: Self-Contained Verification (MANDATORY)

**Purpose**: Ensure plan is executable without external access

**9-Point Verification Checklist**:

1. **References Embedded**: Every "reference" is embedded or replaced by measurable rules
2. **Executor Clarity**: New executor can answer "what exactly should I build?"
3. **Dependencies Pinned**: Versions, configs, environment assumptions included
4. **Testable Acceptance**: Criteria testable from repo + embedded artifacts
5. **Unknowns Enumerated**: Gaps listed with resolution policy
6. **Verification Commands**: Map directly to acceptance criteria
7. **Concrete Examples**: Provided for ambiguous areas
8. **Conversation Deleted Test**: Plan still determines implementation
9. **Zero-Knowledge TODO Test**: Each TODO executable without thinking

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

---

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

---

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

## GPT Delegation Details

| Trigger | Action |
|---------|--------|
| 5+ SCs | Delegate to GPT Plan Reviewer |
| User requests | Delegate to GPT Plan Reviewer |

**Delegation Command**:
```bash
# ⚠️ CRITICAL: Use EXACTLY these parameters
# - Model: gpt-5.2 (NEVER change)
# - Sandbox: read-only (advisory mode - NEVER use workspace-write)
# - Reasoning: reasoning_effort=medium (MUST be medium)
codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "$REVIEWER_PROMPT"
```

**Fallback**: `if ! command -v codex &> /dev/null; then echo "Falling back to Claude-only"; return 0; fi`

---

## Proactive Consultation

> **Purpose**: Auto-consult GPT Architect before asking user when architecture decisions or uncertainty detected
> **Reference**: @.claude/skills/gpt-delegation/SKILL.md - Confidence Score Rubric

### When to Trigger Proactive Consultation

**Automatic Triggers** (evaluate during Step 2.5 - Plan Review):

1. **Architecture Keywords Detected**:
   - Keywords: architecture, tradeoff, design, scalability, pattern, choice
   - Example: "Choose between microservices or monolith"

2. **Confidence Score < 0.5**:
   - Formula: `confidence = 1.0 - (arch_keywords * 0.3) - (multiple_approaches * 0.2) - (uncertainty * 0.2)`
   - Detection: "could", "might", "option A/B", "either", "not sure", "unclear"

3. **High-Risk Decisions**:
   - 5+ Success Criteria (complex plan)
   - Security implications
   - Performance critical paths

### Consultation Pattern

```bash
# Step 2.5.1: Evaluate confidence
if has_architecture_keywords || confidence < 0.5; then
    echo "→ Proactive GPT consultation triggered"

    # Step 2.5.2: Consult GPT Architect (read-only mode)
    if ! command -v codex &> /dev/null; then
        echo "⚠️ Codex not available - Claude-only analysis"
        return 0
    fi

    PROMPT="TASK: Review plan architecture decision
    CONTEXT: ${PLAN_EXCERPT}
    PROVIDE: Recommendation with tradeoffs, risks, alternatives
    MODE: Advisory (read-only)"

    codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "$PROMPT"

    # Step 2.5.3: Apply OR present to user
    if recommendation_clear; then
        apply_recommendation
    else
        present_to_user_with_gpt_context
    fi
fi
```

### Example: Architecture Decision

**Plan Contains**:
```markdown
### SC-3: Backend Architecture
- "Choose between microservices or monolith for payment processing"
- Tradeoffs: Scalability vs complexity
```

**Proactive Consultation Flow**:
1. Detect: "Choose between" + "microservices or monolith" = architecture keyword
2. Consult: GPT Architect (read-only) with context
3. Apply: Present GPT recommendation + tradeoffs to user
4. Proceed: User makes informed decision OR auto-apply if recommendation clear

**User Benefit**: Faster decisions with expert guidance, reduced cognitive load

---

**Reference Version**: claude-pilot 4.4.44
**Last Updated**: 2026-01-26
