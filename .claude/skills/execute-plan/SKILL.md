---
name: execute-plan
description: Plan execution workflow - parallel SC implementation, worktree mode, verification patterns, GPT delegation. Use for executing plans with TDD + Ralph Loop.
---

# SKILL: Execute Plan (Plan Execution Workflow)

> **Purpose**: Execute plans using TDD + Ralph Loop with parallel execution
> **Target**: Coder Agent implementing Success Criteria from plans

---

## Quick Start

### When to Use This Skill
- Execute plans from `/01_confirm`
- Implement Success Criteria with TDD
- Parallel execution of independent SCs
- Worktree mode for isolated development

### Quick Reference
```bash
# Plan detection (MANDATORY FIRST ACTION)
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"
echo "Plan: $PLAN_PATH"

# Parallel Coder invocation (Group 1 - Independent SCs)
Task: subagent_type: coder, prompt: "Execute SC-1: {DESCRIPTION}..."

# Verification (parallel)
Task: subagent_type: tester, prompt: "Run tests for {PLAN_PATH}"
Task: subagent_type: validator, prompt: "Type check + lint"
Task: subagent_type: code-reviewer, prompt: "Review code"
```

---

## What This Skill Covers

### In Scope
- Plan detection and state transition
- SC dependency analysis and parallel execution
- Worktree mode setup and management
- Parallel verification (tester + validator + code-reviewer)
- GPT delegation triggers and auto-escalation

### Out of Scope
- TDD methodology → @.claude/skills/tdd/SKILL.md
- Ralph Loop iteration → @.claude/skills/ralph-loop/SKILL.md
- Code quality standards → @.claude/skills/vibe-coding/SKILL.md

---

## Execution Steps

### ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 in sequence, then launch parallel/sequential coder agents
- Only stop on ERROR or when all SCs are blocked

### 🚫 PROHIBITED Actions
- **NEVER move plan to done/** - Only `/03_close` has this authority
- Do NOT call close-plan skill automatically
- Do NOT archive the plan file
- Plan MUST remain in `.pilot/plan/in_progress/` after execution completes

---

## Step 1: Plan Detection

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code execution directory (absolute path required)
PROJECT_ROOT="$(pwd)"

# Find plan in pending/ or in_progress/
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"

if [ -z "$PLAN_PATH" ]; then
    echo "❌ No plan found"
    echo "   Create plan first: /00_plan \"describe your task\""
    exit 1
fi

# Move from pending/ to in_progress/
if echo "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

echo "✓ Plan: $PLAN_PATH"
```

---

## Step 2: Extract Success Criteria

```bash
# Extract all SCs from plan
SC_LIST="$(grep -E "^- \[ \] \*\*SC-" "$PLAN_PATH" | sed 's/.*\*\*SC-\([0-9]*\)\*\*.*/SC-\1/')"

if [ -z "$SC_LIST" ]; then
    echo "❌ No Success Criteria found in plan"
    exit 1
fi

SC_COUNT="$(echo "$SC_LIST" | wc -l | tr -d ' ')"
echo "✓ Found $SC_COUNT Success Criteria"
```

---

## Step 2.5: Agent Selection

Select the appropriate agent based on task type:

| Task Type | Agent | Detection Criteria |
|-----------|-------|-------------------|
| Frontend | frontend-engineer | component, UI, React, CSS, Tailwind, landing page, webpage, website, design, page, layout, form, button, card, modal, dashboard, hero, marketing, portfolio |
| Backend | backend-engineer | API, endpoint, database, server, backend, middleware |
| Build Error | build-error-resolver | Build/type-check failures |
| General | coder | All other implementations (fallback) |

**Implementation**:
```bash
PLAN_CONTENT=$(cat "$PLAN_PATH")

if echo "$PLAN_CONTENT" | grep -qiE "component|UI|React|CSS|Tailwind|landing page|webpage|website|design|page|layout|form|button|card|modal|dashboard|hero|marketing|portfolio"; then
  AGENT_TYPE="frontend-engineer"
elif echo "$PLAN_CONTENT" | grep -qiE "API|endpoint|database|server|backend|middleware"; then
  AGENT_TYPE="backend-engineer"
else
  AGENT_TYPE="coder"
fi

echo "Selected agent: $AGENT_TYPE"
```

---

## Step 3: Execute with Ralph Loop

### Step 3.1: Dependency Analysis

Analyze SC dependencies to determine parallel vs sequential execution:

```bash
# Extract SC list from plan
SC_LIST="$(grep -E "^- \[ \] \*\*SC-" "$PLAN_PATH" | sed 's/.*\*\*SC-\([0-9]*\)\*\*.*/SC-\1/')"

# Analyze dependencies
for SC in $SC_LIST; do
    SC_CONTENT=$(sed -n "/\*\*${SC}\*\*/,/^\*- \[ \]/p" "$PLAN_PATH" | head -n -1)

    # Check for dependency keywords
    if echo "$SC_CONTENT" | grep -qiE 'after|depends|requires|follows'; then
        echo "**SequentialGroup**: $SC (has dependencies)"
    else
        echo "**ParallelGroup**: $SC (independent)"
    fi
done
```

### Step 3.2a: Parallel Execution (Independent SCs)

For independent SCs (no shared files, no dependencies), launch 4 parallel coders:

```markdown
Task:
  subagent_type: coder
  prompt: |
    Execute SC-1 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-1: {description from plan}
    Output: <CODER_COMPLETE> or <CODER_BLOCKED>

Task:
  subagent_type: coder
  prompt: |
    Execute SC-2 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-2: {description from plan}
    Output: <CODER_COMPLETE> or <CODER_BLOCKED>

Task:
  subagent_type: coder
  prompt: |
    Execute SC-3 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-3: {description from plan}
    Output: <CODER_COMPLETE> or <CODER_BLOCKED>

Task:
  subagent_type: coder
  prompt: |
    Execute SC-4 from $PLAN_PATH
    Use skills: tdd, ralph-loop, vibe-coding
    Focus only on SC-4: {description from plan}
    Output: <CODER_COMPLETE> or <CODER_BLOCKED>
```

**Expected Speedup**: 50-70% (4 SCs in ~1.5x time, not 4x)

### Step 3.2b: Sequential Execution (Dependent SCs)

For SCs with dependencies, execute sequentially:

```markdown
Task:
  subagent_type: coder
  prompt: |
    Execute all SCs from $PLAN_PATH using tdd, ralph-loop
    SCs have dependencies - execute sequentially
    Output: <CODER_COMPLETE> or <CODER_BLOCKED>
```

### Step 3.3: Process Results

After parallel execution completes:

1. Check for `<CODER_COMPLETE>` markers from all agents
2. Run tests: `npm test` (or project-specific test command)
3. If tests pass: Mark all SCs as complete in plan
4. If tests fail: Sequential retry of failed SCs

**Quality Gates**: Tests pass, Coverage ≥80%, Type-check clean, Lint clean

### Step 3.4: Handle CODER_BLOCKED

When any coder agent returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect:

```bash
# Check for CODER_BLOCKED markers
BLOCKED_COUNT=$(grep -c "<CODER_BLOCKED>" /tmp/coder_output.log 2>/dev/null || echo 0)

if [ "$BLOCKED_COUNT" -gt 0 ]; then
    echo "⚠️  $BLOCKED_COUNT coder(s) blocked - delegating to GPT Architect"

    # Graceful fallback if Codex CLI not installed
    if ! command -v codex &> /dev/null; then
        echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
        echo "Consider installing Codex CLI for GPT-4 architectural guidance"
        # Continue with Claude - not an error
    else
        # Delegate to GPT Architect (workspace-write mode)
        # Reference: .claude/skills/gpt-delegation/SKILL.md
        ARCHITECT_PROMPT="You are a software architect analyzing a blocked implementation.
TASK: Analyze why coder agents are blocked and provide fresh approach
PLAN FILE: $PLAN_PATH
ITERATION: $ITERATION_COUNT
MUST DO:
- Identify root cause of blockage
- Propose alternative implementation approach
- Report recommended changes"

        # ⚠️ CRITICAL: Use EXACTLY these parameters
        # - Model: gpt-5.2 (NEVER change)
        # - Sandbox: workspace-write (for implementation - NEVER use read-only, workspace-read, or any variation)
        # - Reasoning: reasoning_effort=medium (MUST be medium - NEVER use high/low)
        codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "$ARCHITECT_PROMPT"

        # Re-invoke coder with GPT recommendations
        echo "✓ GPT Architect recommendations applied - retrying implementation"
    fi
fi
```

**Delegation Conditions**:
- Any `<CODER_BLOCKED>` marker detected in agent output
- Max iterations (7) reached without completion
- Critical errors preventing progress

**Fallback Behavior**: Continue with Claude if Codex CLI unavailable

---

## Step 4: Completion Message

After all SCs are complete:

```bash
echo "✅ All Success Criteria Complete"
echo ""
echo "📦 Next Step: Close Plan"
echo "   Run /03_close to finalize and commit the plan"
echo "   - Documentation sync runs automatically during close"
```

**🛑 STOP HERE**:
- Do NOT proceed to /03_close automatically
- Do NOT move plan to done/
- Wait for user to explicitly run `/03_close`

---

## Parallel Execution Patterns

### SC Dependency Analysis

**Rules**:
- **Sequential**: One `in_progress` at a time
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously
- **File conflicts**: If 2+ SCs modify same file → Different groups

**Detection**:
1. Extract all Success Criteria from plan
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts)
4. Check for dependency keywords ("requires", "depends on")
5. Group SCs by parallel execution capability

---

## Worktree Mode

### Purpose
Create isolated worktree for parallel plan execution

### Workflow
1. Parse `--wt` flag from `$ARGUMENTS`
2. Create worktree branch (`wt/{timestamp}`)
3. Store metadata in `.pilot/state/worktree.json`
4. Restore context across Bash calls

### Commands
```bash
# Create worktree
git worktree add ../claude-pilot-wt wt/$(date +%s)

# Store metadata
echo '{"path": "../claude-pilot-wt", "branch": "wt/1234567890"}' > .pilot/state/worktree.json

# Cleanup after execution
git worktree remove ../claude-pilot-wt
```

---

## GPT Delegation Patterns

### Auto-Delegation Triggers

1. **Coder Blocked**: When Coder returns `<CODER_BLOCKED>` → Immediately delegate to GPT Architect
2. **2+ Failed Attempts**: After 2nd failure (not first) → GPT Architect
3. **Architecture Decisions**: Explicit request in plan → GPT Architect
4. **Security Concerns**: Security-related SCs → GPT Security Analyst

### Delegation Flow

```
Trigger Detection (explicit, semantic, description-based)
      ↓
Expert Selection (Architect, Security Analyst, Code Reviewer, Plan Reviewer, Scope Analyst)
      ↓
Delegation (direct codex CLI: codex exec -m gpt-5.2 -s MODE -c reasoning_effort=medium)
      ↓
Response Handling (synthesize, apply, verify)
```

### Expert Mapping

- **Architect**: System design, component interaction, scalability
- **Security Analyst**: Vulnerabilities, authentication, authorization
- **Plan Reviewer**: Plan validation, completeness, clarity
- **Code Reviewer**: Code quality, best practices, maintainability
- **Scope Analyst**: Requirements analysis, feature scoping

---

## Further Reading

**Internal**: @.claude/skills/execute-plan/REFERENCE.md - Full implementation details, state management, worktree setup, verification patterns | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor cycle | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop | @.claude/skills/parallel-subagents/SKILL.md - Parallel execution orchestration | @.claude/skills/gpt-delegation/SKILL.md - GPT delegation patterns

**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) | [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Related Skills**: ralph-loop | tdd | parallel-subagents | spec-driven-workflow | gpt-delegation

**Version**: claude-pilot 4.4.14
