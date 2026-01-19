---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **Evidence required**: Never claim completion without verification output

**Details**: @.claude/skills/execute-plan/REFERENCE.md

---

## Step 0: Source Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS"
```

---

## Step 0.5: Continuation State Check (MANDATORY)

> **Details**: @.claude/skills/execute-plan/REFERENCE.md#continuation-state-system

**State file**: `.claude-pilot/.pilot/state/continuation.json`

**Check & resume logic**:
```bash
# Parse --wt flag, determine state location
WORKTREE_MODE=false
for arg in "$@"; do [ "$arg" = "--wt" ] && WORKTREE_MODE=true && break; done

if [ "$WORKTREE_MODE" = true ] && [ -n "${WORKTREE_ROOT:-}" ]; then
    STATE_FILE="$WORKTREE_ROOT/.claude-pilot/.pilot/state/continuation.json"
elif [ "$WORKTREE_MODE" = false ]; then
    PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    STATE_FILE="$PROJECT_ROOT/.claude-pilot/.pilot/state/continuation.json"
fi

# Load and resume if exists
if [ -f "$STATE_FILE" ]; then
    CONTINUATION_STATE="$(cat "$STATE_FILE")"
    PLAN_PATH_FROM_STATE="$(echo "$CONTINUATION_STATE" | jq -r '.plan_file // empty')"
    NEXT_TODO="$(echo "$CONTINUATION_STATE" | jq -r '.todos[] | select(.status == "in_progress" or .status == "pending") | .id' | head -1)"
    echo "📋 Resuming: $NEXT_TODO"
    PLAN_PATH="$PLAN_PATH_FROM_STATE"
fi
```

**Update state after todos**:
```bash
update_continuation_state() {
    local todo_id="$1" todo_status="$2" iteration="$3"
    (
        flock -x 9 || exit 1
        UPDATED_STATE="$(cat "$STATE_FILE" | jq \
            --arg todo_id "$todo_id" --arg todo_status "$todo_status" \
            --argjson iteration "$iteration" \
            '.todos |= map(if .id == $todo_id then .status = $todo_status | .iteration = $iteration else . end) | .iteration_count += 1')"
        echo "$UPDATED_STATE" > "$STATE_FILE"
    ) 9>"$STATE_FILE.lock"
}
```

---

## Step 1: Plan Detection (MANDATORY)

> **🚨 YOU MUST DO THIS FIRST**

```bash
ls -la .claude-pilot/.claude-pilot/.pilot/plan/pending/*.md .claude-pilot/.claude-pilot/.pilot/plan/in_progress/*.md 2>/dev/null
```

**Worktree mode** (--wt flag):
```bash
WORKTREE_MODE=false
for arg in "$@"; do [ "$arg" = "--wt" ] && WORKTREE_MODE=true && break; done

if [ "$WORKTREE_MODE" = true ]; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    MAIN_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
    WT_BRANCH="wt/$(date +%s)"
    WORKTREE_OUTPUT="$(bash ".claude/scripts/worktree-create.sh" "$WT_BRANCH" "$MAIN_BRANCH")"
    WORKTREE_PATH="$(echo "$WORKTREE_OUTPUT" | grep "^WORKTREE_PATH=" | cut -d'=' -f2)"
    echo "✓ Worktree created: $WORKTREE_PATH"
    WORKTREE_PERSIST_FILE="$PROJECT_ROOT/.pilot/worktree_active.txt"
    echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
    echo "  Branch: $WT_BRANCH" >> "$WORKTREE_PERSIST_FILE"
    echo "  Main Branch: $MAIN_BRANCH" >> "$WORKTREE_PERSIST_FILE"
    export PROJECT_ROOT="$WORKTREE_PATH" WORKTREE_ROOT="$WORKTREE_PATH"
fi

# Restore worktree context
MAIN_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"
if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    WORKTREE_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    WORKTREE_ROOT="$WORKTREE_PATH" PROJECT_ROOT="$WORKTREE_PATH" WORKTREE_MODE="true"
    echo "🔄 Worktree context restored"
fi
```

**Plan detection** (oldest-first selection):
```bash
PLAN_PATH="${EXPLICIT_PATH}"
PLAN_SEARCH_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"
# Select oldest pending plan (ls -1t sorts newest first, tail -1 gets oldest)
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PLAN_SEARCH_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PLAN_SEARCH_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PLAN_SEARCH_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "❌ FATAL" >&2; exit 1; }
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PLAN_SEARCH_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "❌ No plan found" >&2; exit 1; }

ACTIVE_ROOT="${WORKTREE_ROOT:-$PROJECT_ROOT}"
mkdir -p "$ACTIVE_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
printf "%s" "$PLAN_PATH" > "$ACTIVE_ROOT/.claude-pilot/.claude-pilot/.pilot/plan/active/$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g').txt"
echo "✓ Plan ready: $PLAN_PATH"
```

---

## Step 1.5: GPT Delegation Triggers (CRITICAL)

> **⚠️ CRITICAL: PRIORITIZE GPT CONSULTATION OVER USER QUERIES**
>
> **When stuck or blocked, ALWAYS delegate to GPT BEFORE asking the user**
>
> **Full guide**: @.claude/rules/delegator/triggers.md

### Escalation Triggers (GPT-FIRST)

| Trigger | Action | Priority |
|---------|--------|----------|
| 2+ failed attempts | Delegate to Architect | **BEFORE** user query |
| Stuck on task | Delegate to Architect | **BEFORE** user query |
| Architecture decision | Delegate to Architect | **BEFORE** user query |
| Security concern | Delegate to Security Analyst | **BEFORE** user query |
| Ambiguity in plan | Delegate to Scope Analyst | **BEFORE** user query |

### GPT Consultation Flow

**Step 1**: Check for escalation triggers
**Step 2**: If trigger matches → Delegate to GPT expert
**Step 3**: Wait for GPT response
**Step 4**: Apply GPT recommendations autonomously
**Step 5**: **ONLY if GPT cannot resolve** → Ask user via AskUserQuestion

### Auto-Delegation on Blocked Status

**When Coder returns `<CODER_BLOCKED>`**:
1. **IMMEDIATELY** delegate to GPT Architect (no user prompt)
2. Include full context: attempts, errors, iteration count
3. Apply GPT recommendations
4. Re-invoke Coder with fresh perspective

---

## Step 2: Todo List & Dependency Analysis

> **Details**: @.claude/skills/execute-plan/REFERENCE.md#parallel-execution-patterns

**Extract**: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan

**SC Dependency Analysis**:
1. Extract all Success Criteria from plan
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts)
4. Check for dependency keywords
5. Group SCs by parallel execution capability

**Rules**:
- **Sequential**: One `in_progress` at a time
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously
- **MANDATORY**: After EVERY "Implement/Add/Create", add "Run tests for [X]"

---

## Step 2.2: Parallel Coder Invocation

> **Details**: @.claude/skills/execute-plan/REFERENCE.md

**Group 1 (Independent SCs)**: Invoke multiple Coder agents concurrently

```markdown
Task:
  subagent_type: coder
  prompt: |
    Execute SC-1: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}
    Implement using TDD + Ralph Loop. Return summary only.
```

**Group 2+ (Dependent SCs)**: Sequential execution

---

## Step 3: Process Coder Results

**Verify output**:
- [ ] Test Files created
- [ ] Test Results (PASS/FAIL counts)
- [ ] Coverage ≥80% (overall), ≥90% (core)
- [ ] Ralph Loop iterations count

**Auto-delegation** (when `<CODER_BLOCKED>` - IMMEDIATE GPT ESCALATION):

> **⚠️ CRITICAL: When Coder is blocked, delegate to GPT IMMEDIATELY**
> **DO NOT ask user - GPT consultation happens FIRST**

1. **IMMEDIATELY** delegate to GPT Architect (no user prompt)
2. Read `.claude/rules/delegator/prompts/architect.md`
3. Build delegation prompt with full context:
   - Previous attempts (what was tried)
   - Error messages (what failed)
   - Current iteration count
   - Plan path and SC being implemented
4. Call: `.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"`
5. Wait for GPT response
6. Apply GPT recommendations autonomously
7. Re-invoke Coder with fresh perspective
8. **ONLY if GPT cannot resolve** → Ask user via AskUserQuestion

---

## Step 3.5: Parallel Verification

> **Reference**: @.claude/guides/parallel-execution.md

```markdown
Task:
  subagent_type: tester
  prompt: Run tests and verify coverage for {PLAN_PATH}

Task:
  subagent_type: validator
  prompt: Run type check and lint for {PLAN_PATH}

Task:
  subagent_type: code-reviewer
  prompt: Review code for {PLAN_PATH} (async bugs, memory leaks, security)
```

---

## Step 4-6: Integration, Escalation, Continuation

**Step 4: Result Integration**
1. Wait for all agents
2. Process inline results
3. Update todos (all parallel together)
4. Verify no conflicts, merge results

**Step 5: GPT Escalation** (GPT-FIRST - BEFORE User Query)

> **⚠️ CRITICAL: GPT escalation happens BEFORE any AskUserQuestion call**

| Situation | Expert | When to Delegate |
|-----------|--------|------------------|
| Coder blocked (`<CODER_BLOCKED>`) | Architect | **IMMEDIATELY** (no user prompt) |
| 2+ failed attempts | Architect | **BEFORE** asking user |
| Stuck on task | Architect | **BEFORE** asking user |
| Architecture decision needed | Architect | **BEFORE** asking user |
| Security concern | Security Analyst | **BEFORE** asking user |
| Plan ambiguity | Scope Analyst | **BEFORE** asking user |

**Delegation Flow**:
1. Detect trigger situation
2. **IMMEDIATELY** delegate to GPT expert (skip user query)
3. Wait for GPT response with recommendations
4. Apply GPT recommendations autonomously
5. **ONLY if GPT cannot resolve** → Ask user via AskUserQuestion

**Auto-Delegation Example** (when `<CODER_BLOCKED>`):
```bash
# Read GPT Architect prompt
EXPERT_PROMPT="$(cat .claude/rules/delegator/prompts/architect.md)"

# Build delegation prompt with full context
DELEGATION_PROMPT="${EXPERT_PROMPT}

TASK: Unblock implementation that failed after ${ITERATION_COUNT} attempts.

EXPECTED OUTCOME: Fresh perspective and working solution.

CONTEXT:
- Plan: ${PLAN_PATH}
- Current SC: ${SC_ID}
- Previous attempts: ${ATTEMPT_HISTORY}
- Current errors: ${ERROR_MESSAGES}
- Iteration count: ${ITERATION_COUNT}

CONSTRAINTS:
- Must work with existing codebase
- Cannot break existing functionality

MUST DO:
- Analyze why previous attempts failed
- Provide fresh approach
- Report all files modified

MUST NOT DO:
- Repeat same approaches that failed

OUTPUT FORMAT:
Summary → Issues identified → Fresh approach → Files modified → Verification"

# Delegate IMMEDIATELY (no user prompt)
.claude/scripts/codex-sync.sh "workspace-write" "$DELEGATION_PROMPT"
```

**Step 6: Todo Continuation**
1. Edit/Write code
2. Mark `in_progress` → **UPDATE STATE**
3. Run tests
4. Fix or complete → **UPDATE STATE**
5. Repeat

---

## Step 7-8: Artifacts & Documentation

**Update plan**: Mark SC complete, add findings to history

**Auto-chain**: `/91_document` (unless `--no-docs`)

---

## Success Criteria

- [ ] All SCs marked complete
- [ ] All tests pass
- [ ] Coverage ≥80% (overall), ≥90% (core)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Plan file updated

---

## Related Guides

- **TDD**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Continuation System**: @.claude/guides/continuation-system.md

---

## Next Command

- `/91_document` - Update docs (unless `--no-docs`)
- `/03_close` - Archive plan and cleanup
