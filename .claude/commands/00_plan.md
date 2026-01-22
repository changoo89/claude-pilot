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

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Efficient Dialogue**: Ask user only for business/intent clarification; handle technical details autonomously or via GPT

---

## Step 1: Explore Codebase (Parallel)

Launch explorer and researcher in parallel:

### Task 1.1a: Codebase Exploration
```markdown
Task:
  subagent_type: explorer
  prompt: |
    Explore codebase for {task_description}
    - Find relevant TypeScript/JavaScript files in src/
    - Look for existing patterns related to {domain}
    - Identify config files, test files, and documentation
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
    Output: Research summary with links
```

### After Exploration: Self-Assess
- If scope is clear from task description → proceed to Step 2
- If scope is ambiguous → ask user for clarification (AskUserQuestion)
- Technical details (which files, patterns) → decide autonomously

---

## Step 2: Gather Requirements

**User Requirements (Verbatim)**: Capture user's exact input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | timestamp | "exact user input" | Summary |

### After Requirements: Self-Assess
- If user's intent is clear → proceed to Step 3
- If business requirement is ambiguous → ask user to clarify intent (AskUserQuestion)
- Technical approach → decide autonomously or consult GPT

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

### Approach Selection: Apply Question Filter
- **If one clear best approach**: Present the recommended plan directly (no options)
- **If 2+ approaches with different user-facing outcomes**: Present options, ask user to choose
- **If technical trade-offs only**: Consult GPT, then decide autonomously

**CRITICAL**: When user selects an approach → **continue planning with that approach** (NOT start implementation)

---

## Step 4: Final User Decision (MANDATORY)

**NEVER auto-proceed to /01_confirm or /02_execute.**

Ask user to choose next step:
- A) Continue editing plan
- B) Explore different approach
- C) Run /01_confirm (save and review)
- D) Run /02_execute (start implementation)

**IMPORTANT**: Only run /01_confirm or /02_execute when user explicitly selects option C or D.

---

## Related Skills

**spec-driven-workflow**: SPEC-First methodology | **gpt-delegation**: GPT consultation with fallback | **parallel-subagents**: Parallel exploration patterns

---

**⚠️ CRITICAL**:
- /00_plan is **read-only** - NO code modifications
- **Filter questions**: Self-decide technical details, consult GPT for complex trade-offs, ask user only for business/intent
- **Selection ≠ Execution**: When user chooses approach → continue planning, NOT implement
- Implementation starts ONLY when user explicitly runs `/01_confirm` → `/02_execute`
