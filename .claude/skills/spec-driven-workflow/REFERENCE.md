# REFERENCE: Spec-Driven Workflow (Detailed Implementation)

> **Companion**: SKILL.md | **Purpose**: Detailed implementation reference for SPEC-First planning workflow

---

## Detailed Step Implementation

### Step 1: Explore Codebase (Parallel)

**Purpose**: Launch explorer and researcher in parallel for comprehensive discovery

**Parallel Task Execution**:
```bash
# Task 1.1a: Codebase Exploration
subagent_type: explorer
prompt: |
  Explore codebase for {task_description}
  - Find relevant TypeScript/JavaScript files in src/
  - Look for existing patterns related to {domain}
  - Identify config files, test files, and documentation
  Output: File list with brief descriptions

# Task 1.1b: External Research
subagent_type: researcher
prompt: |
  Research external documentation for {task_description}
  - Search for official docs and API references
  - Find best practices and design patterns
  Output: Research summary with links
```

**After Exploration: Self-Assess**
- If scope is clear from task description → proceed to Step 2
- If scope is ambiguous → ask user for clarification (AskUserQuestion)
- Technical details (which files, patterns) → decide autonomously

---

### Step 1.5: Scope Clarity Check (MANDATORY)

**Purpose**: 범위에 대한 암묵적 가정 방지

**Trigger Conditions** (하나라도 해당되면 범위 확인 필수):

1. **Completeness Keywords**:
   - Korean: "전체", "완전한", "모든", "다", "처음부터 끝까지"
   - English: "full", "complete", "entire", "whole", "end-to-end", "from scratch"

2. **Reference-Based Requests**:
   - "이 프로젝트처럼", "레퍼런스 기반", "이거 보고", "똑같이"
   - "like this project", "based on reference", "same as"

3. **Ambiguous Scope**:
   - 사용자가 명시적 범위 지정 없이 작업 요청
   - "XX 만들어줘" (무엇이 "XX"의 전체인지 불명확)

4. **Multi-Layer Architecture Detected**:
   - 탐색 결과 2개 이상의 독립 레이어 발견
   - 서로 다른 기술 스택이 공존 (예: Next.js + Express)

**When Triggered**:

1. Identify distinct layers from exploration:
   - Independent modules/directories
   - Different tech stacks
   - Input/output boundaries

2. Ask user to select scope:
   ```
   AskUserQuestion:
     question: "프로젝트의 전체 범위를 확인합니다. 이번 계획에 포함할 영역을 선택해주세요:"
     header: "Scope"
     multiSelect: true
     options:
       - label: "[Layer 1 from exploration]"
         description: "[Description]"
       - label: "[Layer 2 from exploration]"
         description: "[Description]"
       - label: "단계적 구현"
         description: "먼저 할 부분을 지정"
   ```

3. Document scope decision in draft file

**CRITICAL**:
- Do NOT assume "X first, Y later" without user confirmation
- If plan only covers part of discovered architecture, get explicit confirmation

---

### Step 1.6: Design Direction Check (SMART DETECTION)

**Purpose**: Detect high-aesthetic-risk tasks and capture design direction early

**Trigger Keywords** (high-aesthetic-risk):
```
landing|marketing|redesign|beautiful|modern|premium|hero|pricing|portfolio|homepage|brand|client-facing|polish|revamp
```

**When Triggered** (any keyword present in task description):

1. Ask user for aesthetic direction:
   ```
   AskUserQuestion:
     question: "What visual style should this UI follow?"
     header: "Style"
     multiSelect: false
     options:
       - label: "Minimal (Recommended)"
         description: "Clean, sparse, purposeful - Stripe/Linear style"
       - label: "Warm"
         description: "Organic textures, soft edges - Notion/Gumroad style"
       - label: "Bold"
         description: "High contrast, strong typography - Modern/Experimental"
   ```

2. Store decision in draft plan:
   ```markdown
   | D-{N} | HH:MM | Aesthetic Direction: [Minimal/Warm/Bold] | User selected style for design implementation |
   ```

**When Not Triggered** (no keywords detected):

1. Proceed with "house style" defaults (NO question asked)
2. Store in draft plan:
   ```markdown
   | D-{N} | HH:MM | Aesthetic Direction: Minimal (house style default) | No design keywords detected, using defaults |
   ```

**Canonical Source**: All design defaults reference `@.claude/skills/frontend-design/SKILL.md`

**House Style Defaults** (when no keywords detected):
- **Direction**: Minimalist (clean, sparse, purposeful)
- **Typography**: Geist/Satoshi (NOT Inter)
- **Colors**: Off-white backgrounds, no purple-to-blue gradients
- **Components**: Varied radii, subtle borders, proper states

**Non-Blocking Rule**: If no response within 30 seconds, proceed with `aesthetic_direction: minimal`

---

### Step 1.8: External Context Detection (MANDATORY)

**Purpose**: Detect ANY external context dependency for self-contained execution

**Detection Patterns** (from GPT Architect):

| Pattern | Examples | Context Type |
|---------|----------|--------------|
| "Like X / similar to Y" | "메타랩처럼", "Stripe style", "같은", "based on" | Design/Reference |
| External links | URLs, Figma, Slack, docs, "see above" | Various |
| "Use the API/docs/spec" | "Stripe API", "REST endpoint" | API |
| "Use library X" | "using NextAuth", "with Prisma" | Library |
| "Refactor to match" | "기존처럼", "like the example" | Refactor |
| Implicit knowledge | "우리 브랜드", "standard", "best practice" | Domain |
| Untestable requirement | No acceptance criteria | Scope |

**When Detected**:

1. **Identify Context Type**:
   - Design: website, UI, visual reference
   - API: endpoints, schemas, auth
   - Library: packages, frameworks, tools
   - Refactor: existing code patterns
   - Domain: business rules, brand guidelines

2. **Capture Workflow per Type**:

   **Design Context**:
   ```bash
   # Screenshot + visual analysis
   playwright: browser_navigate(url)
   playwright: browser_take_screenshot(fullPage=true)
   # Extract: colors, typography, layout, components, interactions
   ```

   **API Context**:
   ```bash
   # Documentation capture
   webReader: webReader(docs_url)
   # Extract: endpoints, schemas, auth, errors, examples
   context7: query-docs(libraryId, "API reference")
   ```

   **Library Context**:
   ```bash
   # Version + config + examples
   context7: resolve-library-id(libraryName)
   context7: query-docs(libraryId, "setup configuration")
   # Pin version, capture config, minimal examples
   ```

   **Refactor Context**:
   ```bash
   # Before/after patterns
   # Capture: current code, target pattern, invariants to preserve
   ```

3. **Create Context Pack**:
   ```markdown
   ## Context Pack

   ### Goal
   [User-facing outcome - what success looks like]

   ### Inputs (Embedded)
   [Per context type - see formats below]

   ### Derived Requirements
   [Measurable bullets extracted from inputs - NOT references]

   ### Assumptions & Unknowns
   | Item | Status | Resolution |
   |------|--------|------------|
   | [Gap] | Unknown | Ask user / Use default |

   ### Traceability Map
   | Requirement | Source (Embedded) |
   |-------------|-------------------|
   | [Req-1] | Context Pack → Inputs → [excerpt] |
   ```

**CRITICAL**: Do NOT proceed to Step 2 if context capture incomplete.

---

### Step 1.8.5: Context Manifest Generation

**Purpose**: Explicitly list all collected context for verification

**After Step 1.8 (External Context Detection)**:

1. **Generate Context Manifest**:

```markdown
## Context Manifest

### Collected Context
| ID | Type | Source | Status |
|----|------|--------|--------|
| C-1 | Code | [file path] | Read |
| C-2 | Docs | [doc path] | Read |
| C-3 | External | [URL/reference] | Partial |

### Related Files (Auto-discovered by explorer)
| File | Reason | Included? |
|------|--------|-----------|
| [file] | [why related] | Yes / No (reason) |

### Missing Context (BLOCKING if critical)
| Item | Why Needed | Resolution |
|------|------------|------------|
| [gap] | [reason] | Ask user / Default: [value] |
```

2. **Store in Draft File**: Append manifest to draft plan

**After Manifest Generation**:
- If Missing Context table is empty → proceed to Step 1.9
- If Missing Context has items → AskUserQuestion to resolve

---

### Step 1.9: Quick Sufficiency Test

**Purpose**: Practical 3-question check BEFORE Step 2 (Gather Requirements)

**3 Practical Questions**:

1. **File Test**: "Are all file paths to be modified explicitly specified?"
   - Pass: All file paths explicit (e.g., `src/auth/login.ts`, `tests/auth.test.ts`)
   - Fail: Vague expressions ("관련 파일", "적절한 위치", "related files")

2. **Value Test**: "Are configuration values, constants, strings explicitly specified?"
   - Pass: Concrete values (e.g., `timeout: 5000`, `retries: 3`, `"application/json"`)
   - Fail: Vague expressions ("적절한 값", "필요에 따라", "appropriate value")

3. **Dependency Test**: "Are external dependencies explicitly specified?"
   - Pass: Library + version OR "no external dependencies" stated
   - Fail: Features assumed without dependency mention

**Test Execution**:
```markdown
### Quick Sufficiency Test Results
| Test | Result | Details |
|------|--------|---------|
| File Test | Pass/Fail | [specifics] |
| Value Test | Pass/Fail | [specifics] |
| Dependency Test | Pass/Fail | [specifics] |

**Overall**: Pass/Fail
```

**BLOCKING if any test fails** → AskUserQuestion to resolve before proceeding to Step 2

**Example AskUserQuestion for failures**:
```
AskUserQuestion:
  question: "Context insufficient for self-contained execution. Please resolve:"
  header: "Missing Context"
  multiSelect: false
  options:
    - label: "Provide missing details"
      description: "I'll specify the missing file paths, values, and dependencies"
    - label: "Use defaults"
      description: "Use reasonable defaults and proceed with implementation"
```

---

### Step 2: Gather Requirements

**Purpose**: Capture user requirements verbatim for plan foundation

**User Requirements (Verbatim)**: Capture user's exact input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | timestamp | "exact user input" | Summary |

**After Requirements: Self-Assess**
- If user's intent is clear → proceed to Step 3
- If business requirement is ambiguous → ask user to clarify intent (AskUserQuestion)
- Technical approach → decide autonomously or consult GPT
- **Record Decision**: After clarifying requirements, append to decisions.md (see Decision Tracking below)

---

### Step 3: Create SPEC-First Plan

**Purpose**: Design implementation plan using PRP framework

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

**Approach Selection: Apply Question Filter**
- **If one clear best approach**: Present the recommended plan directly (no options)
- **If 2+ approaches with different user-facing outcomes**: Present options, ask user to choose
- **If technical trade-offs only**: Consult GPT, then decide autonomously

**CRITICAL**: When user selects an approach → **continue planning with that approach** (NOT start implementation)
- **Record Decision**: After approach selection, append to decisions.md (see Decision Tracking below)

---

### Step 4: Final User Decision (MANDATORY)

**Purpose**: Let user choose next action

**NEVER auto-proceed to /01_confirm or /02_execute.**

Ask user to choose next step:
- A) Continue editing plan
- B) Explore different approach
- C) Run /01_confirm (save and review)
- D) Run /02_execute (start implementation)

**IMPORTANT**: Only run /01_confirm or /02_execute when user explicitly selects option C or D.

---

## Decision Tracking (Real-time)

**Purpose**: Record decisions as they happen to prevent omissions in /01_confirm

> **NOTE**: `*_draft.md` is NOT a plan file. It is a temporary working draft stored in `.pilot/plan/draft/` and is exempt from the "Creating plan files without user approval" rule.

### When to Record
Record a decision when user:
- Selects an option from AskUserQuestion
- Confirms scope (in/out)
- Agrees on approach
- Specifies constraints or requirements

### How to Record

**First Decision**: Create draft file
```bash
PROJECT_ROOT="$(pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
DRAFT_FILE="$PROJECT_ROOT/.pilot/plan/draft/${TS}_draft.md"
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
```

Write initial file with header:
```markdown
# {Work Title}

> **Session**: {timestamp}
> **Task**: {task description from arguments}

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|

## Decisions Log

| ID | Time | Decision | Context |
|----|------|----------|---------|

## Success Criteria

- [ ] **SC-1**: [Measurable outcome]
  - **Verify**: [test command or verification step]
```

**Subsequent Decisions**: Append to existing file
- Find latest `*_draft.md` in `.pilot/plan/draft/`
- Append new row to Decisions table
- Decision content MUST be in English

**Decision Format**:

| ID | Time | Decision | Context |
|----|------|----------|---------|
| D-1 | HH:MM | User selected approach B: Use real-time tracking | User chose between A) Post-hoc scan, B) Real-time tracking |
| D-2 | HH:MM | Scope includes: error handling | User confirmed error handling is in scope |

**Note**: The draft file includes both User Requirements and Decisions Log sections for easy reference during /01_confirm.

---

## Selection vs Execution (CRITICAL)

**When user says "Go with B" (choose option B):**
- ✅ CORRECT: Continue planning with approach B → refine plan → present complete plan
- ❌ WRONG: Start implementing approach B

**Example Flow**:
1. Present: "A) Simple approach, B) Scalable approach"
2. User: "Go with B" or "Choose option B"
3. ✅ Do: "I'll refine the plan with approach B. [detailed plan for B]..."
4. ❌ Don't: "I'll start implementing with B. [writes code]"

**Implementation ONLY starts when**: User explicitly runs `/01_confirm` → `/02_execute`

---

## Question Filtering (CRITICAL)

**Before asking user anything, apply this filter:**

### Self-Decide (Do NOT ask user):
- Technical implementation details (file naming, folder structure)
- Obvious patterns already in codebase
- Standard best practices
- Minor trade-offs with clear winner

### Consult GPT First (Ask GPT before user):
- Architecture decisions with multiple valid approaches
- Security considerations
- Complex trade-offs requiring expert analysis
- When stuck or uncertain about technical direction

**GPT Consultation**: Use gpt-delegation skill → "read-only" mode for advisory

### Ask User (ONLY these):
- **Business requirements**: What the user actually wants
- **Direction choices**: When 2+ approaches have genuinely different outcomes
- **Scope clarification**: What's in/out of scope
- **User intent**: When user's request is ambiguous

**Rule**: If you can reasonably infer the answer OR get it from GPT, don't ask user.

---

## PROHIBITED Actions

### ⛔ TOOL RESTRICTIONS (ABSOLUTE)
- Edit tool: FORBIDDEN on any file
- Write tool: ONLY `.pilot/plan/draft/*.md`

- Creating plan files without user approval
- Running /01_confirm automatically
- Running /02_execute automatically
- **Starting implementation after user selects an approach** (selection = continue planning)
- **Interpreting ANY natural language as phase transition trigger**
  - Examples: "proceed", "go ahead", "do it", "sounds good", "yes", "let's do it", "go with B"
  - These expressions mean "continue planning in this direction", NOT "start implementation"

**EXPLICIT COMMAND REQUIRED**:
- To move to /01_confirm: User must type exactly `/01_confirm`
- To move to /02_execute: User must type exactly `/02_execute`
- NO natural language expression can trigger phase transition
- When in doubt, ASK: "Should I continue refining the plan, or run /01_confirm?"

---

### ⛔ NATURAL LANGUAGE INTERPRETATION (CRITICAL)

**Korean Examples**:
- "진행해" (continue/proceed)
- "해결해줘" (fix it/solve it)
- "고쳐줘" (fix it)
- "수정해줘" (modify/fix it)
- "그렇게 해" (do that)

**English Examples**:
- "proceed"
- "go ahead"
- "fix it"
- "solve it"
- "do it"
- "sounds good"
- "yes, let's do it"

**ALL mean "continue planning", NOT "implement"**

**IF USER SAYS these phrases:**
→ Respond: "I'll continue refining the plan. [continue planning with more details]"

**IF USER ASKS TO IMPLEMENT:**
→ Respond: "This is a planning phase. I'll include this in the plan. Run `/01_confirm` → `/02_execute` to implement."

**Response Template**:
```
I understand you want me to [action]. During this planning phase (/00_plan), I'll:

1. Continue refining the plan with [requested changes/details]
2. Document this in the draft plan
3. Present the complete plan for your review

To start implementation, you'll need to:
- Run `/01_confirm` to save and review the plan
- Run `/02_execute` to begin implementation

Shall I continue planning with [specific detail]?
```

---

## Context Pack Formats

### Design Context Format

```markdown
### Inputs (Embedded) - Design Reference

> **Source**: Screenshot captured via playwright
> **Captured**: {timestamp}

#### Visual Analysis

**Colors**:
- Primary: {hex}
- Secondary: {hex}
- Background: {hex}
- Text: {hex}

**Typography**:
- Headings: {font}, {weight}
- Body: {font}, {weight}

**Layout**:
- Structure: {description}
- Spacing: {description}

**Components**:
- Button styles: {description}
- Card styles: {description}
```

### API Context Format

```markdown
### Inputs (Embedded) - API Documentation

> **Source**: {docs_url}
> **Captured**: {timestamp}

#### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/resource | List resources |
| POST | /api/resource | Create resource |

#### Authentication
- Type: {Bearer token / API key / etc}
- Header: {header_name}

#### Request/Response Schema
[JSON examples]
```

### Library Context Format

```markdown
### Inputs (Embedded) - Library Documentation

> **Source**: {library_name} {version} docs
> **Captured**: {timestamp}

#### Installation
```bash
npm install {library-name}@{version}
```

#### Configuration
```javascript
import { Library } from '{library-name}'

const config = {
  // minimal config
}
```
```

---

**Reference Version**: claude-pilot 4.4.40
**Last Updated**: 2026-01-25
