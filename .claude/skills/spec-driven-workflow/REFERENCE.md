# REFERENCE: Spec-Driven Workflow (Detailed Implementation)

> **Companion**: SKILL.md | **Purpose**: Detailed implementation reference for SPEC-First planning workflow

---

## Detailed Step Implementation

### Step 1: Explore Codebase (Parallel)

**Purpose**: Launch explorer and researcher in parallel for comprehensive discovery

**Parallel Execution**: explorer (codebase files, patterns) + researcher (external docs, best practices)

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

**From SKILL.md**: Triggers include completeness keywords, reference-based requests ("like X"), ambiguous scope, multi-layer architecture. When triggered, ask user to select scope from discovered layers.

---

### Step 1.6: Design Direction Check (SMART DETECTION)

**Purpose**: Detect high-aesthetic-risk tasks and capture design direction early

**Trigger Keywords**: `landing|marketing|redesign|beautiful|modern|premium|hero|pricing|portfolio|homepage|brand|client-facing|polish|revamp`

**When Triggered**: Ask user for aesthetic direction (Minimal/Warm/Bold) via AskUserQuestion, store in draft plan

**When Not Triggered**: Use house style defaults (Minimal), store in draft plan

**House Style Defaults**: Minimalist direction, Geist/Satoshi fonts, off-white backgrounds, varied radii. See `@.claude/skills/frontend-design/SKILL.md`

**Non-Blocking**: If no response within 30 seconds, proceed with `aesthetic_direction: minimal`

**From SKILL.md**: Trigger keywords include landing, marketing, redesign, beautiful, modern, premium, hero, pricing, portfolio, homepage, brand, client-facing, polish, revamp. When triggered, ask user for aesthetic direction (Minimal/Warm/Bold). When not triggered, use "house style" defaults (Minimalist).

---

### Step 1.8: External Context Detection (MANDATORY)

**Purpose**: Detect ANY external context dependency for self-contained execution

**Detection Patterns**: "Like X", external links (URLs, Figma), "Use API/library", "Refactor to match", implicit knowledge, untestable requirements

**When Detected**:
1. **Identify Context Type**: Design, API, Library, Refactor, Domain
2. **Capture Workflow**: Use appropriate MCP tools (playwright for design, webReader/context7 for docs, etc.)
3. **Create Context Pack**: Goal, Inputs (Embedded), Derived Requirements, Assumptions & Unknowns, Traceability Map (see formats below)

**CRITICAL**: Do NOT proceed to Step 2 if context capture incomplete

**From SKILL.md**: Detection patterns include "Like X/similar to Y", external links, "Use API/docs", "Use library X", refactor references, implicit knowledge. Context types: Design, API, Library, Refactor, Domain. Action: Capture context using appropriate tools, create Context Pack with Goal, Inputs, Derived Requirements, Assumptions, Traceability Map.

---

### Step 1.8.5: Context Manifest Generation

**Purpose**: Explicitly list all collected context for verification

**After Step 1.8 (External Context Detection)**:

1. **Generate Context Manifest**:
```markdown
## Context Manifest
### Collected Context: | ID | Type | Source | Status |
### Related Files: | File | Reason | Included? |
### Missing Context: | Item | Why Needed | Resolution |
```

2. **Store in Draft File**: Append manifest to draft plan

**After Manifest Generation**:
- If Missing Context table is empty → proceed to Step 1.9
- If Missing Context has items → AskUserQuestion to resolve

**From SKILL.md**: Generate Context Manifest with Collected Context, Related Files, and Missing Context tables. Store in draft file.

---

### Step 1.9: Absolute Certainty Gate

**Purpose**: Ensure 100% certainty before proceeding to requirements gathering

**Certainty Checklist** (ALL MUST PASS):
1. **Codebase understanding**: 100% relevant files explored (use explorer + researcher agents)
2. **Dependency tracking**: All import/require chains traced (check package.json, imports)
3. **Impact scope**: All affected files identified (grep for references, check callers)
4. **Test strategy**: Concrete verification methods defined (unit, integration, E2E)
5. **Edge cases**: Exception scenarios listed (error handling, edge inputs)
6. **Rollback plan**: Recovery strategy defined (revert steps, backup plan)

**From SKILL.md**: Ensure 100% certainty before proceeding. Checklist includes: Codebase understanding, Dependency tracking, Impact scope, Test strategy, Edge cases, Rollback plan. Enforcement loop iterates until 100% certainty achieved (max 30min timebox). BLOCKING if incomplete: Escalate to user after timebox.

**Enforcement Loop**:
```bash
iteration=0
max_iterations=10
timebox_minutes=30
start_time=$(date +%s)

while [ $iteration -lt $max_iterations ]; do
  elapsed=$(($(date +%s) - start_time))
  if [ $elapsed -ge $((timebox_minutes * 60)) ]; then
    echo "⏰ Timebox exceeded (${timebox_minutes}min)"
    break
  fi

  # Check all 6 items in Certainty Checklist
  if all_checks_pass; then
    echo "✓ 100% certainty achieved"
    break
  fi

  # Parallel exploration + GPT consultation
  run_parallel_exploration
  consult_gpt_if_needed

  ((iteration++))
done

# BLOCKING if incomplete after timebox
if ! all_checks_pass; then
  AskUserQuestion "Unable to achieve 100% certainty. Need help with: [missing items]"
fi
```

**BLOCKING if incomplete**: Escalate to user after timebox with specific missing items

---

### Step 1.9 Certainty Checklist Details

**Evidence-Based Verification** - Each item requires 3-part verification:

1. **Codebase Understanding**
   - Must produce: File list with purpose annotations (e.g., `auth.ts - authentication logic, api.ts - API client`)
   - Verifier checks: `ls -1 [files] | wc -l` ≥ expected count AND each file annotated with purpose
   - Fail if: Any relevant file missing from list OR any file lacks purpose annotation

2. **Dependency Tracking**
   - Must produce: Dependency graph showing import chains (e.g., `A imports B, B imports C`)
   - Verifier checks: `grep -r "import.*from" [files]` output matches documented chains
   - Fail if: Any import statement not documented OR circular dependency not identified

3. **Impact Scope**
   - Must produce: Affected files list with change description (e.g., `auth.ts - modify login(), api.ts - add endpoint`)
   - Verifier checks: `grep -r "[function/class name]" [files]` returns all callers
   - Fail if: Any caller not identified OR any affected file missing change description

4. **Test Strategy**
   - Must produce: Test plan with test types and commands (e.g., `Unit: npm test auth.test.ts, E2E: npm run e2e`)
   - Verifier checks: Test files exist via `ls tests/` AND commands are runnable
   - Fail if: Test command fails to run OR test file missing for any component

5. **Edge Cases**
   - Must produce: Edge case list with handling approach (e.g., `null input - return error, network timeout - retry 3x`)
   - Verifier checks: Each edge case has defined handling strategy in code or plan
   - Fail if: Any edge case lacks handling strategy OR strategy not implementable

6. **Rollback Plan**
   - Must produce: Rollback steps with verification (e.g., `1. Revert commit ABC123, 2. Verify tests pass`)
   - Verifier checks: Git commands valid via `git log` AND rollback steps are reversible
   - Fail if: Rollback steps incomplete OR any step not verifiable

---

### Step 1.10: Readiness Gate

**Purpose**: Final readiness check before proceeding to plan creation

**Readiness Checklist** (ALL MUST PASS):
1. **Unknowns Enumerated**: All unknowns listed in Assumptions & Unknowns table
2. **Assumptions Verified**: All assumptions validated or marked for user confirmation
3. **Dependencies Clear**: All external dependencies (libraries, APIs, services) identified
4. **Acceptance Criteria Measurable**: All success criteria have concrete verification commands
5. **Verification Plan Defined**: Test strategy includes unit/integration/E2E approach
6. **Rollback Plan Defined**: Recovery steps documented in draft plan

**From SKILL.md**: Final readiness check before plan creation. Checklist: Unknowns Enumerated, Assumptions Verified, Dependencies Clear, Acceptance Criteria Measurable, Verification Plan Defined, Rollback Plan Defined. Uncertainty loop: Max 3 retries with parallel exploration + GPT consultation. BLOCKING if incomplete: Checklist incomplete after MAX_RETRIES.

**Uncertainty Loop**:
```bash
max_retries=3
retry=0

while [ $retry -lt $max_retries ]; do
  # Check Readiness Checklist
  if readiness_check_pass; then
    echo "✓ Ready to proceed to Step 2"
    break
  fi

  # Parallel exploration for missing items
  launch_explorer_for_unknowns &
  launch_researcher_for_assumptions &
  wait

  # GPT consultation for complex items
  if has_architecture_unknowns; then
    consult_gpt_architect
  fi

  ((retry++))
done

# BLOCKING if checklist incomplete after MAX_RETRIES
if ! readiness_check_pass; then
  echo "❌ BLOCKING: Readiness Gate incomplete after $max_retries retries"
  AskUserQuestion "Cannot proceed with incomplete readiness. Missing: [items]"
  exit 1
fi
```

**BLOCKING if incomplete**: Checklist incomplete after MAX_RETRIES → escalate to user

### Step 1.10 Readiness Checklist Details

**Evidence-Based Verification** - Each item requires 3-part verification:

1. **Unknowns Enumerated**
   - Must produce: Assumptions & Unknowns table with all unknowns listed
   - Verifier checks: `grep -c "| .* | Unknown |" draft_file.md` ≥ 0 (zero is valid if all resolved)
   - Fail if: Unknowns table missing OR unknowns present without resolution plan

2. **Assumptions Verified**
   - Must produce: Assumptions & Unknowns table with Status column filled (Verified/Pending/Waived)
   - Verifier checks: `grep -c "| .* | Assumption | Verified\\|Pending\\|Waived |" draft_file.md` equals assumption count
   - Fail if: Any assumption has empty Status OR no validation method documented

3. **Dependencies Clear**
   - Must produce: Dependencies list (libraries, APIs, services) with versions
   - Verifier checks: `grep -E "(npm|pip|cargo|go get|dependencies)" draft_file.md` returns matches
   - Fail if: External dependencies exist but not documented OR versions not specified

4. **Acceptance Criteria Measurable**
   - Must produce: Success Criteria with concrete verification commands
   - Verifier checks: `grep -c "Verify:" draft_file.md` equals SC count
   - Fail if: Any SC lacks verification command OR command is vague (e.g., "test it")

5. **Verification Plan Defined**
   - Must produce: Test strategy section with unit/integration/E2E approach
   - Verifier checks: `grep -E "(unit|integration|e2e|E2E)" draft_file.md` returns matches
   - Fail if: Test strategy missing OR no test types specified

6. **Rollback Plan Defined**
   - Must produce: Rollback section with recovery steps
   - Verifier checks: `grep -iE "(rollback|revert|recovery)" draft_file.md` returns matches
   - Fail if: Rollback steps missing OR no recovery strategy documented

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

### Step 3.5: Mandatory Oracle Consultation (Detailed)

**From SKILL.md**: GPT consultation at 3 points during /00_plan: start (Analyst), mid (Architect), end (Reviewer). Graceful fallback: WebSearch/Context7 if Codex unavailable.

**mandatory_oracle_consultation** - GPT consultation at 3 points during /00_plan:

| Phase | GPT Role | Purpose |
|-------|----------|---------|
| /00_plan start | Analyst | Requirements interpretation |
| /00_plan mid | Architect | Architecture direction |
| /00_plan end | Reviewer | Plan completeness |

**Graceful Fallback**: WebSearch/Context7 if Codex unavailable

**Implementation**:
1. **Start**: After Step 1 (Explore Codebase), consult GPT Analyst for requirements interpretation
2. **Mid**: After Step 2 (Gather Requirements), consult GPT Architect for architecture direction
3. **End**: After Step 3 (Create Plan), consult GPT Reviewer for plan completeness

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

## Decision Tracking (Real-time) - Detailed

**From SKILL.md**: Draft file (.pilot/plan/draft/{TIMESTAMP}_draft.md) contains: User Requirements (Verbatim) table, Decisions Log table (ID, Time, Decision, Context), Success Criteria with checkboxes.

**Purpose**: Record decisions as they happen to prevent omissions in /01_confirm

> **NOTE**: `*_draft.md` is NOT a plan file. It is a temporary working draft stored in `.pilot/plan/draft/` and is exempt from the "Creating plan files without user approval" rule.

### When to Record: User selects option, confirms scope, agrees approach, specifies constraints.
### How to Record

**Draft File**: `.pilot/plan/draft/{timestamp}_draft.md`
```bash
mkdir -p "$PROJECT_ROOT/.pilot/plan/draft"
# Structure: # {Title} | Session, Task, Requirements (ID|Timestamp|Input|Summary), Decisions (ID|Time|Decision|Context), Success Criteria
```
**Subsequent**: Append to latest draft, decisions in English. Format: `| D-1 | HH:MM | User selected approach B | Context |`

---

## Intermediate File Naming

### File Patterns

| File Type | Pattern | Example |
|-----------|---------|---------|
| Draft | `{TS}_{work_name}_draft.md` | `20260127_183000_api_auth_draft.md` |
| Context Pack | `{TS}_{work_name}_context_pack.md` | `20260127_183000_api_auth_context_pack.md` |

### work_name Derivation

1. Extract from user's task description
2. Sanitize: lowercase, replace spaces with underscores
3. Use first 2-3 significant words (skip articles, prepositions)
4. Max 30 characters

**Examples**:
- "Add user authentication API" → `user_auth_api`
- "Create landing page like Metalab" → `landing_page_metalab`
- "Fix checkout flow bug" → `checkout_flow_bug`

### Lifecycle

```
/00_plan
  ├── Creates: {TS}_{work_name}_draft.md
  └── Creates: {TS}_{work_name}_context_pack.md (if external context)
       ↓
/01_confirm
  ├── Reads draft + context_pack
  ├── Creates plan file in pending/
  └── Deletes draft + context_pack (Step 4.5)
```

---

## Atomic SC Principle (Detailed)

**From SKILL.md**: "One SC = One File OR One Concern" - Each SC touches one file/location OR single technical aspect. Enables parallel execution, clear ownership. Anti-pattern: "Update frontend AND backend" → Split.

**Detailed Explanation**:
- **One File**: SC-1 modifies only `auth.ts`, SC-2 modifies only `api.ts`
- **One Concern**: SC-1 handles authentication logic, SC-2 handles rate limiting
- **Enables Parallel**: Independent SCs can be implemented by different agents simultaneously
- **Clear Ownership**: Each SC has clear file/concern boundaries
- **Anti-pattern**: "Update frontend (3 files) AND backend (2 files)" → Split into SC-1 (frontend) and SC-2 (backend)

---

## Selection vs Execution (CRITICAL) - Detailed

**From SKILL.md**: When user says "Go with B": ✅ Continue planning (refine plan) | ❌ Start implementing. Implementation starts only when user runs `/01_confirm` → `/02_execute`.

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

## Context Pack Structure (Detailed)

**From SKILL.md**: Context Pack contains: Goal (user-facing outcome), Inputs (Embedded - per context type), Derived Requirements (measurable bullets), Assumptions & Unknowns (table with Item, Status, Resolution), Traceability Map (Requirement → Source).

**Full Structure**:
- **Goal**: User-facing outcome
- **Inputs (Embedded)**: Per context type (see formats below)
- **Derived Requirements**: Measurable bullets
- **Assumptions & Unknowns**: Table with Item, Status, Resolution
- **Traceability Map**: Requirement → Source

---

## Context Pack Formats

**Embedded Context**: Inline format with source, timestamp, key properties. See gpt-delegation/SKILL.md for capture tools.

| Type | Format | Key Fields |
|------|--------|------------|
| Design | `### Inputs (Embedded) - Design Reference` | Source, Captured, Colors, Typography, Layout, Components |
| API | `### Inputs (Embedded) - API Documentation` | Source, Captured, Endpoints, Authentication, Schema |
| Library | `### Inputs (Embedded) - Library Documentation` | Source, Captured, Installation, Configuration |

---

## Confidence Score (Detailed)

**From SKILL.md**: MUST Consult GPT when: Architecture keywords detected OR confidence < 0.5. Threshold < 0.5 → MUST consult GPT before AskUserQuestion. See @.claude/skills/gpt-delegation/SKILL.md for full details.

**Purpose**: Determine when to consult GPT proactively before asking user

**Formula** (see @.claude/skills/gpt-delegation/SKILL.md for full rubric):
```
confidence = 1.0 - (architecture_keywords * 0.3) - (multiple_approaches * 0.2) - (uncertainty_markers * 0.2)
```

**Scale**: 0.0 - 1.0

**Thresholds**:
- 0.9-1.0: Proceed autonomously
- 0.5-0.9: Consider consultation
- **< 0.5: MUST consult GPT** (proactive, before user interaction)

**Detection Patterns**:
- Architecture: architecture, tradeoff, design, scalability, pattern, choice
- Multiple approaches: could, might, option A/B, either
- Uncertainty: not sure, unclear, depends

**Proactive GPT Consultation Pattern** (from SKILL.md):
- **Trigger**: Architecture keywords detected OR confidence < 0.5
- **Keywords**: architecture, tradeoff, design, scalability, pattern
- **Threshold**: < 0.5 → MUST consult GPT before AskUserQuestion
- **Pattern**: IF triggered → consult GPT Architect (read-only) → apply recommendation OR present to user → THEN AskUserQuestion if still ambiguous

---

## Fail-Closed Enforcement

**Purpose**: Prevent premature gate passage when evidence is incomplete

**Principle**: Iteration/timebox caps default to FAIL, not PASS

### Enforcement Behavior

**Current Problem**: Gates with iteration caps "fail-open" (cap reached = pass anyway)

**Required Behavior**: Gates must "fail-closed" (cap reached = FAIL with missing-evidence report)

### Iteration Cap Behavior

**When iteration/timebox limit is reached**:
1. **DO NOT** automatically pass the gate
2. **MUST** FAIL with missing-evidence report
3. **MUST** escalate to user with specific blockers

**Example** (Step 1.9 Absolute Certainty Gate):
```bash
# Current (fail-open - WRONG)
if ! all_checks_pass && [ $iteration -eq $max_iterations ]; then
  echo "⏰ Max iterations reached, proceeding anyway"  # ❌ FAIL-OPEN
  # Continue to next step
fi

# Required (fail-closed - CORRECT)
if ! all_checks_pass && [ $iteration -eq $max_iterations ]; then
  echo "❌ FAIL: Max iterations reached without achieving certainty"  # ✓ FAIL-CLOSED
  generate_missing_evidence_report
  AskUserQuestion "Cannot proceed without 100% certainty. Blockers: [list]"
  exit 1
fi
```

### Missing Evidence Report Format

**When gate fails due to iteration/timebox cap**:

```markdown
## Missing Evidence Report

### Gate: [Gate Name]
**Status**: FAIL with missing-evidence report
**Reason**: [Iteration cap reached | Timebox exceeded | Evidence incomplete]

### Missing Evidence Items:
1. **[Checklist Item]**: [What's missing] | [Why it couldn't be obtained] | [Proposed resolution]
2. **[Checklist Item]**: [What's missing] | [Why it couldn't be obtained] | [Proposed resolution]

### Attempted Actions:
- [Action 1]: [Result]
- [Action 2]: [Result]

### Recommended Next Steps:
- [User action required]
- [Alternative approach]
```

### Application to Gates

**Step 1.9 Absolute Certainty Gate**:
- Max iterations: 10, Timebox: 30 minutes
- If cap reached without 100% certainty → FAIL with missing-evidence report
- Report lists: unchecked items, exploration attempts, GPT consultations

**Step 1.10 Readiness Gate**:
- Max retries: 3
- If cap reached with incomplete checklist → FAIL with missing-evidence report
- Report lists: missing unknowns, unverified assumptions, incomplete dependencies

**Escalation Pattern**:
1. Generate missing evidence report
2. AskUserQuestion with specific blockers
3. Wait for user input (do NOT proceed)
4. User provides: missing info | explicit waiver | alternative approach

---

**Reference Version**: claude-pilot 4.4.44
**Last Updated**: 2026-01-26
