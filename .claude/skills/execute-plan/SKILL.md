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
# Plan detection & parallel execution
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"
Task: subagent_type: $AGENT_TYPE, prompt: "Execute SC-1 from $PLAN_PATH"
```

---

## What This Skill Covers

**In Scope**: Plan detection, SC dependency analysis, parallel execution, worktree mode, parallel verification, GPT delegation

**Out of Scope**: TDD methodology → @.claude/skills/tdd/SKILL.md | Ralph Loop → @.claude/skills/ralph-loop/SKILL.md | Code quality → @.claude/skills/vibe-coding/SKILL.md

---

## Execution Steps

### ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps IMMEDIATELY and AUTOMATICALLY.

**Prohibited**: NEVER move plan to done/ (only `/03_close` has this authority), do NOT call close-plan automatically, plan MUST remain in `.pilot/plan/in_progress/`

---

## Step 1: Plan Detection

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"

[ -z "$PLAN_PATH" ] && { echo "❌ No plan found"; exit 1; }

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
SC_LIST="$(grep -E "^- \[ \] \*\*SC-" "$PLAN_PATH" | sed 's/.*\*\*SC-\([0-9]*\)\*\*.*/SC-\1/')"
SC_COUNT="$(echo "$SC_LIST" | wc -l | tr -d ' ')"
echo "✓ Found $SC_COUNT Success Criteria"
```

---

## Step 2.5: Agent Selection

| Task Type | Agent | Detection Criteria |
|-----------|-------|-------------------|
| Frontend | frontend-engineer | component, UI, React, CSS, Tailwind |
| Backend | backend-engineer | API, endpoint, database, server |
| Build Error | build-error-resolver | Build/type-check failures |
| General | coder | All other implementations |

```bash
PLAN_CONTENT=$(cat "$PLAN_PATH")

if echo "$PLAN_CONTENT" | grep -qiE "component|UI|React|CSS|Tailwind"; then
  AGENT_TYPE="frontend-engineer"
elif echo "$PLAN_CONTENT" | grep -qiE "API|endpoint|database|server|backend"; then
  AGENT_TYPE="backend-engineer"
else
  AGENT_TYPE="coder"
fi
```

---

## Step 3: Execute with Ralph Loop

### Step 3.1: Dependency Analysis

```bash
for SC in $SC_LIST; do
    SC_CONTENT=$(sed -n "/\*\*${SC}\*\*/,/^\*- \[ \]/p" "$PLAN_PATH" | head -n -1)
    if echo "$SC_CONTENT" | grep -qiE 'after|depends|requires|follows'; then
        echo "**SequentialGroup**: $SC"
    else
        echo "**ParallelGroup**: $SC"
    fi
done
```

### Step 3.2: Execution Strategies

**Parallel** (Independent SCs): 50-70% speedup
```markdown
Task: subagent_type: $AGENT_TYPE, prompt: "Execute SC-{N} from $PLAN_PATH. Skills: tdd, ralph-loop, vibe-coding. Output: <CODER_COMPLETE> or <CODER_BLOCKED>"
```

**Sequential** (Dependent SCs): Execute one agent with all SCs
**Single Coder** (1-2 SCs): Always delegate for context protection

### Step 3.3: Process Results

1. Check for `<CODER_COMPLETE>` markers from all agents
2. Run tests: `npm test`
3. If tests pass: Mark all SCs as complete in plan
4. If tests fail: Sequential retry of failed SCs

**Quality Gates**: Tests pass, Coverage ≥80%, Type-check clean, Lint clean

### Step 3.4: Handle CODER_BLOCKED

When any coder agent returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect:

```bash
if grep -q "<CODER_BLOCKED>" /tmp/coder_output.log 2>/dev/null; then
    if command -v codex &> /dev/null; then
        codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "$ARCHITECT_PROMPT"
    fi
fi
```

**Critical Parameters**: Model: gpt-5.2 | Sandbox: workspace-write | Reasoning: medium

**Fallback**: Continue with Claude if Codex CLI unavailable

---

## Step 4.5: Project Type Detection

**Purpose**: Auto-detect project type (web/CLI/library) for E2E verification.

**Full Implementation**: @.claude/skills/execute-plan/REFERENCE.md#project-type-detection

---

## Step 4: Completion Message

```bash
echo "✅ All Success Criteria Complete"
echo "📦 Next Step: Run Step 5 for E2E verification"
```

**Proceed to Step 5**: Do NOT call /03_close yet.

---

## Step 5: E2E Verification

**Purpose**: Validate actual functionality, not just code changes.

**Substeps**:
1. Detect project type (web/CLI/library) - @REFERENCE.md#project-type-detection
2. Web: Chrome in Claude (browser_navigate, browser_snapshot) - @REFERENCE.md#e2e-web
3. CLI: Run command, check exit code and stdout - @REFERENCE.md#e2e-cli
4. Library: Run tests, check exit code - @REFERENCE.md#e2e-library
5. Retry on failure (max 3) - @REFERENCE.md#e2e-retry-loop

**Retry Pattern**: MAX_E2E_RETRIES=3, then GPT delegation, then user.

---

## Further Reading

**Internal**: @.claude/skills/execute-plan/REFERENCE.md - Full implementation details, worktree setup, GPT delegation, verification patterns | @.claude/skills/tdd/SKILL.md - Red-Green-Refactor | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop | @.claude/skills/parallel-subagents/SKILL.md - Parallel execution | @.claude/skills/gpt-delegation/SKILL.md - GPT delegation

**External**: [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) | [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Version**: claude-pilot 4.4.14
