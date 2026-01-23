---
name: spec-driven-workflow
description: SPEC-First planning workflow - explore codebase, gather requirements, create execution plan through dialogue (read-only)
---

# SKILL: Spec-Driven Workflow (Planning)

> **Purpose**: Analyze codebase and create SPEC-First execution plan through dialogue (read-only phase)
> **Target**: Planner Agent executing /00_plan command

---

## Quick Start

### When to Use This Skill
- Create new implementation plan
- Explore codebase for task requirements
- Gather user requirements through dialogue
- Design SPEC-First execution plan

### Quick Reference
```bash
# Invoked by: /00_plan "task description"
# Output: Complete plan in .pilot/plan/draft/ + user decision
```

---

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Efficient Dialogue**: Ask user only for business/intent clarification; handle technical details autonomously or via GPT

---

## What This Skill Covers

### In Scope
- Codebase exploration (parallel: explorer + researcher agents)
- Requirement gathering with verbatim capture
- SPEC-First plan creation (PRP framework)
- Decision tracking in real-time
- Dialogue-based user interaction with question filtering

### Out of Scope
- Code implementation → @.claude/skills/execute-plan/SKILL.md
- Plan confirmation → @.claude/skills/confirm-plan/SKILL.md
- Plan execution → @.claude/skills/execute-plan/SKILL.md

---

## EXECUTION DIRECTIVE

**THIS IS A DIALOGUE PHASE - NOT AN EXECUTION PHASE**

You MUST follow this interaction pattern:

1. **ASK only when necessary**: Filter questions before asking user (see Question Filtering below)
2. **WAIT for response**: Do not proceed until user responds to actual questions
3. **NEVER auto-execute**: Do not run /01_confirm or /02_execute without explicit user request
4. **Selection ≠ Execution**: When user chooses an approach, **continue planning with that approach**, do NOT start implementation

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

## Execution Steps

Execute ALL steps in sequence.

### Step 1: Explore Codebase (Parallel)

**Purpose**: Launch explorer and researcher in parallel for comprehensive discovery

```bash
# Task 1.1a: Codebase Exploration
# Invoke parallel-subagents skill with:
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

## Mandatory Checkpoints

**Use AskUserQuestion ONLY when:**
- [ ] Scope is unclear → Clarify what's in/out
- [ ] Multiple approaches with genuinely different user-facing outcomes → Let user choose direction
- [ ] Business requirement ambiguity → Confirm user intent
- [ ] Before completing → Ask next step (A/B/C/D options)

**Skip AskUserQuestion when:**
- Technical details can be inferred from codebase
- Standard patterns apply
- GPT can provide guidance

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

## Related Skills

**parallel-subagents**: Parallel exploration patterns | **gpt-delegation**: GPT consultation with fallback | **confirm-plan**: Plan confirmation workflow | **execute-plan**: Plan execution workflow

---

## Further Reading

**Internal**: @.claude/skills/spec-driven-workflow/REFERENCE.md - Advanced planning patterns | @.claude/skills/parallel-subagents/SKILL.md - Parallel agent execution | @.claude/skills/gpt-delegation/SKILL.md - GPT consultation | @.claude/skills/confirm-plan/SKILL.md - Plan confirmation | @.claude/skills/execute-plan/SKILL.md - Plan execution

**External**: [SPEC-First Development](https://en.wikipedia.org/wiki/Specification_by_example) | [PRP Framework](https://pragprog.com/)

---

**⚠️ CRITICAL**:
- /00_plan is **read-only** - NO code modifications
- **Filter questions**: Self-decide technical details, consult GPT for complex trade-offs, ask user only for business/intent
- **Selection ≠ Execution**: When user chooses approach → continue planning, NOT implement
- Implementation starts ONLY when user explicitly runs `/01_confirm` → `/02_execute`

---

**Version**: claude-pilot 4.4.14
