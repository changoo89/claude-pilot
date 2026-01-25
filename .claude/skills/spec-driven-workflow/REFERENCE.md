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

**Purpose**: Prevent implicit scope assumptions

**Trigger Conditions** (any one triggers mandatory scope confirmation):
1. Completeness keywords (Korean: "전체", "모든" | English: "full", "complete", "entire", "end-to-end")
2. Reference-based requests ("like this project", "based on reference", "same as")
3. Ambiguous scope (no explicit boundaries specified)
4. Multi-layer architecture detected (2+ independent tech stacks)

**When Triggered**:
1. Identify distinct layers from exploration
2. Ask user to select scope via AskUserQuestion (multiSelect: true)
3. Document scope decision in draft file

**CRITICAL**: Do NOT assume "X first, Y later" without user confirmation

---

### Step 1.6: Design Direction Check (SMART DETECTION)

**Purpose**: Detect high-aesthetic-risk tasks and capture design direction early

**Trigger Keywords**: `landing|marketing|redesign|beautiful|modern|premium|hero|pricing|portfolio|homepage|brand|client-facing|polish|revamp`

**When Triggered**: Ask user for aesthetic direction (Minimal/Warm/Bold) via AskUserQuestion, store in draft plan

**When Not Triggered**: Use house style defaults (Minimal), store in draft plan

**House Style Defaults**: Minimalist direction, Geist/Satoshi fonts, off-white backgrounds, varied radii. See `@.claude/skills/frontend-design/SKILL.md`

**Non-Blocking**: If no response within 30 seconds, proceed with `aesthetic_direction: minimal`

---

### Step 1.8: External Context Detection (MANDATORY)

**Purpose**: Detect ANY external context dependency for self-contained execution

**Detection Patterns**: "Like X", external links (URLs, Figma), "Use API/library", "Refactor to match", implicit knowledge, untestable requirements

**When Detected**:
1. **Identify Context Type**: Design, API, Library, Refactor, Domain
2. **Capture Workflow**: Use appropriate MCP tools (playwright for design, webReader/context7 for docs, etc.)
3. **Create Context Pack**: Goal, Inputs (Embedded), Derived Requirements, Assumptions & Unknowns, Traceability Map (see formats below)

**CRITICAL**: Do NOT proceed to Step 2 if context capture incomplete

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

**Purpose**: 3-question check BEFORE Step 2 (Gather Requirements)

**Tests**:
1. **File Test**: All file paths explicit? (Pass: explicit paths | Fail: "related files")
2. **Value Test**: Config values explicit? (Pass: concrete values | Fail: "appropriate value")
3. **Dependency Test**: Dependencies explicit? (Pass: library+version OR "none" | Fail: assumed)

**BLOCKING if any test fails**: AskUserQuestion to resolve (provide details OR use defaults)

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
- Auto-running /01_confirm or /02_execute
- Starting implementation after user selects an approach (selection = continue planning)

### ⛔ NATURAL LANGUAGE INTERPRETATION (CRITICAL)
**Natural language expressions NEVER trigger phase transition**:
- Korean: "진행해", "해결해줘", "고쳐줘", "수정해줘" → Continue planning
- English: "proceed", "go ahead", "fix it", "do it", "sounds good" → Continue planning

**EXPLICIT COMMAND REQUIRED**: `/01_confirm` or `/02_execute` only

**Response to ambiguous requests**: "This is a planning phase. I'll continue refining the plan. Run `/01_confirm` → `/02_execute` to implement."

---

## Context Pack Formats

### Design Context Format
```markdown
### Inputs (Embedded) - Design Reference
> **Source**: Screenshot | **Captured**: {timestamp}
**Colors**: Primary, Secondary, Background, Text (hex values)
**Typography**: Headings, Body (font, weight)
**Layout**: Structure, Spacing | **Components**: Button/Card styles
```

### API Context Format
```markdown
### Inputs (Embedded) - API Documentation
> **Source**: {docs_url} | **Captured**: {timestamp}
**Endpoints**: Method, Endpoint, Description (table)
**Authentication**: Type, Header | **Schema**: Request/Response examples
```

### Library Context Format
```markdown
### Inputs (Embedded) - Library Documentation
> **Source**: {library_name} {version} | **Captured**: {timestamp}
**Installation**: `npm install {library}@{version}`
**Configuration**: Import statement + minimal config
```

---

**Reference Version**: claude-pilot 4.4.40
**Last Updated**: 2026-01-25
