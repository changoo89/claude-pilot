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

## Step 3: Delegate to Coder Agent (Context Isolation)

> **Why Agent?**: Coder Agent runs in isolated context window (~80K tokens internally). Only summary returns here (8x token efficiency).

**🚀 MANDATORY ACTION**: Invoke Coder Agent NOW using Task tool

```markdown
Task:
  subagent_type: coder
  prompt: |
    Execute the following plan:

    Plan Path: {PLAN_PATH}
    Success Criteria: {SC_LIST_FROM_PLAN}
    Test Scenarios: {TS_LIST_FROM_PLAN}

    Implement using TDD + Ralph Loop. Return summary only.
```

### 3.1 Process Coder Results

**Expected Output**: `<CODER_COMPLETE>` or `<CODER_BLOCKED>`

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | All SCs met, tests pass, coverage达标 | Proceed to next step |
| `<CODER_BLOCKED>` | Cannot complete | Use `AskUserQuestion` for guidance |

### 3.2 Verify Coder Output (TDD Enforcement)

> **🚨 CRITICAL - MANDATORY Verification**

Required fields in agent output:
- [ ] Test Files created
- [ ] Test Results (PASS/FAIL counts)
- [ ] Coverage percentage (≥80% overall, ≥90% core)
- [ ] Ralph Loop iterations count

**If verification fails**: Re-invoke with explicit instruction or use `AskUserQuestion`

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

### 3.5.2 Process Verification Results

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## Step 4: GPT Expert Escalation (Optional)

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

## Step 5: Todo Continuation Enforcement

> **Principle**: Don't batch - mark todo as `in_progress` → Complete → Move to next

**Micro-Cycle Compliance**:
1. Edit/Write code
2. Mark test todo as `in_progress`
3. Run tests
4. Fix failures or mark complete
5. Repeat

---

## Step 6: Update Plan Artifacts

| Action | Method |
|--------|--------|
| Mark SC complete | Update plan checkboxes |
| Update history | Add findings to Review History |
| Save plan | Write updated plan file |

---

## Step 7: Auto-Chain to Documentation

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
