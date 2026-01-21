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
- [ ] Before completing → Ask user's next step preference

**PROHIBITED Actions**:
- Creating plan files without user approval
- Running /01_confirm automatically
- Running /02_execute automatically
- Skipping user validation checkpoints

---

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Collaborative**: Dialogue with user to clarify ambiguities - **EVERY STEP requires user input**

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

### CHECKPOINT 1: Exploration Review (MANDATORY)
Ask user which areas to focus on before proceeding.

---

## Step 2: Gather Requirements

**User Requirements (Verbatim)**: Capture user's exact input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | timestamp | "exact user input" | Summary |

### CHECKPOINT 2: Requirements Confirmation (MANDATORY)
Ask user to confirm requirements understanding before proceeding.

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

### CHECKPOINT 3: Approach Selection (MANDATORY)
Present 2-3 approaches with trade-offs. Ask user to choose before proceeding.

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
- /00_plan is **read-only** and **dialogue-based**
- You MUST use AskUserQuestion at each CHECKPOINT
- You MUST wait for user response before proceeding
- Implementation starts ONLY when user explicitly requests `/01_confirm` → `/02_execute`
