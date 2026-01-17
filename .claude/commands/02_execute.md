---
description: Execute a plan (auto-moves pending to in-progress) with Ralph Loop TDD pattern
argument-hint: "[--no-docs] [--wt] - optional flags: --no-docs skips auto-documentation, --wt enables worktree mode
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(*), AskUserQuestion, Task
---

# /02_execute

_Execute plan using Ralph Loop TDD pattern - iterate until all tests pass._

## Core Philosophy

- **Single source of truth**: Plan file drives the work
- **One active plan**: Exactly one plan active per git branch
- **No drift**: Update plan and todo list if scope changes
- **Evidence required**: Never claim completion without verification output

**TDD**: @.claude/skills/tdd/SKILL.md | **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md | **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 1: Plan Detection (MANDATORY FIRST ACTION)

> **🚨 YOU MUST DO THIS FIRST - NO EXCEPTIONS**

```bash
ls -la .pilot/plan/pending/*.md 2>/dev/null
ls -la .pilot/plan/in_progress/*.md 2>/dev/null
```

### Step 1.1: Plan State Transition (ATOMIC)

> **🚨 CRITICAL - BLOCKING OPERATION**: MUST complete successfully BEFORE any other work.

**Full worktree setup**: See @.claude/guides/worktree-setup.md

**Standard mode** (without --wt):
```bash
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PLAN_PATH="${EXPLICIT_PATH}"

# Priority: Explicit path → Oldest pending → Most recent in_progress
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

# IF pending, MUST move FIRST
if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "❌ FATAL: Failed to move plan" >&2; exit 1; }
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/in_progress"/*.md 2>/dev/null | head -1)"

# Final validation
[ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ] && { echo "❌ No plan found. Run /00_plan first" >&2; exit 1; }

# Set active pointer
mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"
```

**Worktree mode** (with --wt flag): See guide for complete setup script

---

## Step 1.5: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers before execution
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| 2+ failed attempts | Previous attempts failed | Delegate to Architect |
| Architecture decision | "tradeoffs", "design", "structure" | Delegate to Architect |
| Security concern | "auth", "vulnerability", "secure" | Delegate to Security Analyst |

---

## Step 2: Convert Plan to Todo List

Read plan, extract: Deliverables, Phases, Tasks, Acceptance Criteria, Test Plan

**Rules**:
- **Sequential**: One `in_progress` at a time
- **Parallel**: Mark ALL parallel items as `in_progress` simultaneously
- **MANDATORY**: After EVERY "Implement/Add/Create" todo, add "Run tests for [X]" todo

**Full parallel patterns**: @.claude/guides/parallel-execution.md

---

## Step 2.1: SC Dependency Analysis (MANDATORY)

> **🚨 CRITICAL**: Before invoking Coder agents, analyze SC dependencies to determine parallel execution strategy

> **Implementation**: This analysis is performed inline by reading the plan file. No separate script needed.

### Dependency Analysis Process

1. **Extract all Success Criteria** from plan file
2. **Parse file paths** mentioned in each SC
3. **Check for file overlaps** (conflicts - same file modified by multiple SCs)
4. **Check for dependency keywords** ("requires", "depends on", "after", "needs")
5. **Group SCs** by parallel execution capability

### Dependency Analysis Table Template

| SC | Files | Dependencies | Parallel Group | Notes |
|----|-------|--------------|----------------|-------|
| SC-1 | `src/auth/login.ts` | None | Group 1 | Independent |
| SC-2 | `src/auth/logout.ts` | None | Group 1 | Independent |
| SC-3 | `tests/auth.test.ts` | None | Group 1 | Independent |
| SC-4 | `src/auth/middleware.ts` | SC-1 | Group 2 | Requires SC-1 |
| SC-5 | `docs/auth.md` | SC-4 | Group 3 | Requires middleware |

### File Conflict Detection

**Rules**:
- If 2+ SCs modify the same file → Sequential execution (different groups)
- If SC-2 references SC-1 output → Sequential execution (SC-2 after SC-1)
- If SCs have different files and no references → Parallel execution (same group)

### Parallel Group Assignment

- **Group 1**: Fully independent SCs (different files, no dependencies)
- **Group 2**: SCs dependent on Group 1 completion
- **Group 3+**: SCs dependent on previous groups

### Output

After analysis, produce:
1. **Dependency table** (as shown above)
2. **Execution strategy**: Parallel vs Sequential for each group
3. **Todo list** organized by parallel groups

---

## Step 2.2: Parallel Coder Invocation (For Independent SCs)

> **For Group 1 (Independent SCs)**: Invoke multiple Coder agents concurrently using Task tool

> **For Group 2+ (Dependent SCs)**: Sequential execution after previous group completes

### Parallel Execution Pattern (Group 1)

**🚀 MANDATORY ACTION**: For each independent SC in Group 1, invoke a separate Coder agent NOW

```markdown
[Parallel Group 1 - Independent SCs]

Task:
  subagent_type: coder
  prompt: |
    Execute SC-1: {SC-1_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

Task:
  subagent_type: coder
  prompt: |
    Execute SC-2: {SC-2_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

Task:
  subagent_type: coder
  prompt: |
    Execute SC-3: {SC-3_DESCRIPTION}

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.
```

### 2.2.1 Process Parallel Coder Results

**Expected Output**: Each agent returns `<CODER_COMPLETE>` or `<CODER_BLOCKED>`

**Wait for ALL agents** in parallel group to complete before proceeding.

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | SC met, tests pass, coverage ≥80% | Mark todo as complete |
| `<CODER_BLOCKED>` | Cannot complete | **AUTO-DELEGATE to GPT Architect** |

**After ALL agents return**:
1. Mark all parallel todos as `completed` together
2. Verify no file conflicts (should be none if dependency analysis correct)
3. Integrate results (combine file lists, test results, coverage data)
4. Proceed to Group 2 (if any) or to Step 3.5 (Verification)

### Sequential Execution Pattern (Group 2+)

For dependent SCs (Group 2+), invoke Coder agents **sequentially** after previous group completes:

```markdown
[Sequential Group 2 - Dependent SCs]

# Invoke one Coder at a time, wait for completion before next
Task:
  subagent_type: coder
  prompt: |
    Execute SC-4: {SC-4_DESCRIPTION}
    (Requires SC-1 to be complete)

    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

    Implement using TDD + Ralph Loop. Return summary only.

# After SC-4 completes, then invoke SC-5, and so on...
```

### 2.2.2 Partial Failure Handling

If 1 of N parallel agents fails:

1. Note the failure with agent ID and SC
2. Continue waiting for other parallel agents
3. Present all results together (successes + failures)
4. Re-invoke **only failed agent** (with error context from previous attempt)
5. Merge successful results once retry succeeds

**Fallback**: If 2+ retries fail, use `AskUserQuestion` for recovery options

---

## Step 2.3: Legacy Single Coder Pattern (Optional)

> **For simple plans** (1-2 SCs, no clear parallelization benefit), use single Coder agent

```markdown
[Single Coder - For Simple Plans]

Task:
  subagent_type: coder
  prompt: |
    Execute the following plan:

    Plan Path: {PLAN_PATH}
    Success Criteria: {SC_LIST_FROM_PLAN}
    Test Scenarios: {TS_LIST_FROM_PLAN}

    Implement using TDD + Ralph Loop. Return summary only.
```

**When to use single Coder**:
- Plan has 1-2 SCs only
- No clear file separation between SCs
- Sequential dependencies between all SCs
- Resource constraints (cost optimization)

---

## Step 3: Process Coder Agent Results

> **Process results from parallel or sequential Coder invocation**

### 3.1 Verify Coder Output (TDD Enforcement)

> **🚨 CRITICAL - MANDATORY Verification**

Required fields in agent output:
- [ ] Test Files created
- [ ] Test Results (PASS/FAIL counts)
- [ ] Coverage percentage (≥80% overall, ≥90% core)
- [ ] Ralph Loop iterations count

**If verification fails**: Re-invoke with explicit instruction or use `AskUserQuestion`

### 3.2 Auto-Delegation to GPT Architect

> **MANDATORY**: When Coder returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect

**Trigger**: Coder agent reports it cannot complete the work

**Action**:
1. Read `.claude/rules/delegator/prompts/architect.md`
2. Build delegation prompt with context:
   - What the coder was trying to do
   - What blocked it
   - Relevant code snippets
   - Error messages
3. Call: `.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"`
4. Process Architect response
5. Re-invoke Coder with Architect guidance

**Fallback**: If Architect also fails, then use `AskUserQuestion`

**Delegation Count**: Track attempts, max 2 auto-delegations before fallback

---

## Step 3.5: Parallel Verification (Multi-Angle Quality Check)

> **Reference**: @.claude/guides/parallel-execution.md#pattern-2

**🚀 MANDATORY ACTION**: Invoke all three verification agents NOW

```markdown
Task:
  subagent_type: tester
  prompt: |
    Run tests and verify coverage for {PLAN_PATH}.
    Return: Test results, Coverage percentage, Failing test details.

Task:
  subagent_type: validator
  prompt: |
    Run type check and lint for {PLAN_PATH}.
    Return: Type check result, Lint result, Error details.

Task:
  subagent_type: code-reviewer
  prompt: |
    Review code for {PLAN_PATH}.
    Focus: Async bugs, memory leaks, security issues.
```

### 3.5.1 Process Verification Results

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## Step 4: Result Integration Pattern

### Parallel Agent Completion

1. **Wait for all agents**: Task tool blocks until all complete
2. **Process inline results**: Each agent returns summary with completion marker
3. **Update todos**: Mark all parallel todos as `completed` together
4. **Verify no conflicts**: Check file overlap (should be none if dependency analysis correct)
5. **Merge results**: Combine file lists, test results, coverage data
6. **Proceed to next phase**: Integration testing or next parallel group

### Partial Failure Handling

If 1 of 3 parallel agents fails:
1. Note the failure with agent ID
2. Continue waiting for other agents
3. Present all results together
4. Re-invoke only failed agent (with error context)
5. Merge successful results once retry succeeds

---

## Step 5: GPT Expert Escalation (Optional)

> **Trigger**: 2+ failed fix attempts, architecture decisions, security concerns
> **Full guide**: @.claude/rules/delegator/orchestration.md

### When to Escalate

| Situation | Expert |
|-----------|--------|
| 2+ failed fix attempts | Architect (fresh perspective) |
| Architecture decisions | Architect |
| Security concerns | Security Analyst |

### Escalation Pattern

```bash
# Read expert prompt
Read .claude/rules/delegator/prompts/[expert].md

# Call codex-sync.sh
.claude/scripts/codex-sync.sh "workspace-write" "<prompt>"
```

---

## Step 6: Todo Continuation Enforcement

> **Principle**: Don't batch - mark todo as `in_progress` → Complete → Move to next

**Micro-Cycle Compliance**:
1. Edit/Write code
2. Mark test todo as `in_progress`
3. Run tests
4. Fix failures or mark complete
5. Repeat

---

## Step 7: Update Plan Artifacts

| Action | Method |
|--------|--------|
| Mark SC complete | Update plan checkboxes |
| Update history | Add findings to Review History |
| Save plan | Write updated plan file |

---

## Step 8: Auto-Chain to Documentation

> **Unless** `--no-docs` flag provided

Auto-chain to `/91_document` to update CONTEXT.md files and README.md

---

## Success Criteria

- [ ] All SCs marked complete in plan
- [ ] All tests pass
- [ ] Coverage ≥80% (overall), ≥90% (core)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Plan file updated with completion status

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Worktree Setup**: @.claude/guides/worktree-setup.md
- **GPT Delegation**: @.claude/rules/delegator/orchestration.md

---

## Next Command

- `/91_document` - Update documentation (unless `--no-docs`)
- `/03_close` - Archive plan and cleanup worktree
