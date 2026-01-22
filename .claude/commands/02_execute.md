---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern. Single source of truth: plan file drives work._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 in sequence, then launch parallel/sequential coder agents
- Only stop on ERROR or when all SCs are blocked

---

## Step 1: Plan Detection

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code 실행 위치 (절대 경로 필수)
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

---

## Related Skills

ralph-loop | tdd | parallel-subagents | spec-driven-workflow

---

**⚠️ CRITICAL**: Plan stays in `.pilot/plan/in_progress/`. Only `/03_close` can move to done.
