# Execute Plan - Detailed Reference

> **Purpose**: Extended details for plan execution workflow
> **Main Skill**: @.claude/skills/execute-plan/SKILL.md
> **Last Updated**: 2026-01-22

---

## Worktree Mode Setup

Full guide: **@.claude/skills/using-git-worktrees/SKILL.md**

### Creation Process

| Step | Action |
|------|--------|
| **1. Parse flag** | Check `--wt` argument |
| **2. Create worktree** | `git worktree add -b wt/{timestamp} ../worktrees/{branch} main` |
| **3. Persist path** | Write to `.pilot/worktree_active.txt` (path, branch, main branch) |
| **4. Restore context** | Read `.pilot/worktree_active.txt` to restore paths across Bash calls |

---

## Parallel Execution Patterns

### SC Dependency Analysis

**Analysis Process**:
1. Extract all Success Criteria from plan file
2. Parse file paths mentioned in each SC
3. Check for file overlaps (conflicts)
4. Check for dependency keywords ("requires", "depends on", "after", "needs")
5. Group SCs by parallel execution capability

**File Conflict Rules**:

| Condition | Execution Mode | Group Assignment |
|-----------|---------------|------------------|
| 2+ SCs modify same file | Sequential | Different groups |
| SC-2 references SC-1 output | Sequential | SC-2 after SC-1 |
| Different files, no references | Parallel | Same group |

### Parallel Invocation

**Group 1**: Invoke multiple Coder agents concurrently for independent SCs
**Group 2+**: Sequential execution after previous group completes

### Process Results

| Marker | Meaning | Action |
|--------|---------|--------|
| `<CODER_COMPLETE>` | SC met, tests pass, coverage ≥80% | Mark todo as complete |
| `<CODER_BLOCKED>` | Cannot complete | **AUTO-DELEGATE to GPT Architect** |

**After ALL agents return**:
1. Mark all parallel todos as `completed` together
2. Verify no file conflicts
3. Integrate results (files, tests, coverage)
4. Proceed to Group 2 or Verification

### Partial Failure Handling

| Step | Action |
|------|--------|
| 1 | Note failure with agent ID and SC |
| 2 | Continue waiting for other parallel agents |
| 3 | Present all results together |
| 4 | Re-invoke **only failed agent** with error context |
| 5 | Merge successful results once retry succeeds |

**Fallback**: If 2+ retries fail, use `AskUserQuestion`

### Single Coder Pattern

**When to use**:
- Plan has 1-2 SCs only
- No clear file separation between SCs
- Sequential dependencies between all SCs
- Resource constraints

---

## Verification Patterns

### Parallel Verification

Invoke three agents in parallel: **tester** (tests + coverage), **validator** (type check + lint), **code-reviewer** (quality review).

### Success Criteria

| Agent | Required Output | Success Criteria |
|-------|----------------|------------------|
| **Tester** | Test results, coverage | All tests pass, coverage ≥80% |
| **Validator** | Type check, lint | Both clean |
| **Code-Reviewer** | Review findings | No CRITICAL issues |

**If any agent fails**: Fix issues and re-run verification

---

## GPT Delegation

### Auto-Delegation to GPT Architect

**MANDATORY**: When Coder returns `<CODER_BLOCKED>`, automatically delegate to GPT Architect

**Process**: Read prompt template → Build context → Call `codex-sync.sh` → Apply response → Re-invoke Coder

**Fallback**: If Architect fails → `AskUserQuestion` (max 2 auto-delegations)

### GPT Expert Escalation

| Trigger | Expert |
|---------|--------|
| 2+ failed fix attempts | Architect (fresh perspective) |
| Architecture decisions | Architect |
| Security concerns | Security Analyst |

**Pattern**: Read `.claude/rules/delegator/prompts/[expert].md` → Call `codex-sync.sh`

---

## Related Guides

- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **Parallel Execution**: @.claude/skills/parallel-subagents/SKILL.md
- **Worktree Setup**: @.claude/skills/using-git-worktrees/SKILL.md
- **GPT Delegation**: @.claude/rules/delegator/orchestration.md
