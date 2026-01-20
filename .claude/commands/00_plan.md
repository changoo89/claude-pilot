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

## Step 2: Gather Requirements

**User Requirements (Verbatim)**: Capture user's exact input

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | timestamp | "exact user input" | Summary |

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

## Step 4: Requirements Coverage Check

**Verify 100% mapping** (UR → SC):

| Requirement | In Scope | Success Criteria | Status |
|-------------|----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |

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

**spec-driven-workflow**: SPEC-First methodology | **gpt-delegation**: GPT consultation with fallback

---

**⚠️ CRITICAL**: /00_plan is read-only. Implementation starts ONLY after `/01_confirm` → `/02_execute`
