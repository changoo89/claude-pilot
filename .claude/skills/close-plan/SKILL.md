---
name: close-plan
description: Plan completion workflow - archive plan, verify todos, create git commit, push with retry. Use for finalizing completed plans.
---

# SKILL: Close Plan (Plan Completion Workflow)

> **Purpose**: Archive completed plans and create git commits with safe push retry logic
> **Target**: Coder Agent after implementing all Success Criteria

---

## Quick Start

### When to Use This Skill
- Finalize completed plans
- Archive plan to done/ folder
- Create git commit with Co-Authored-By attribution
- Verify todos complete (Sisyphus enforcement)

### Quick Reference
```bash
# Verify completion (continuation state)
STATE_FILE=".pilot/state/continuation.json"
INCOMPLETE_COUNT=$(jq -r '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE")

# Archive plan to done/
RUN_ID=$(basename "$ACTIVE_PLAN_PATH" .md)
DONE_PATH=".claude-pilot/.pilot/plan/done/${RUN_ID}.md"
mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"

# Git commit with Co-Authored-By
git add -A
git commit -m "$(grep -E '^# ' "$ACTIVE_PLAN_PATH" | head -1 | sed 's/^# //')

Co-Authored-By: Claude <noreply@anthropic.com>"

# Safe git push with retry
git_push_with_retry "origin" "$BRANCH"
```

---

## What This Skill Covers

### In Scope
- Continuation state verification (Sisyphus)
- Plan archival to done/ folder
- Git commit creation with Co-Authored-By
- Safe git push with retry logic (3 attempts)
- Worktree cleanup (if --wt flag used)
- Documenter Agent invocation (default)

### Out of Scope
- Git operations → @.claude/skills/git-master/SKILL.md
- Continuation system → @.claude/guides/continuation-system.md
- Documentation updates → @.claude/guides/3tier-documentation.md

---

## Core Concepts

### Continuation Verification (Sisyphus Enforcement)

**State file**: `.pilot/state/continuation.json`

**Principle**: Verify ALL todos complete before archiving plan

**Check logic**:
```bash
if [ -f "$STATE_FILE" ]; then
    INCOMPLETE_COUNT=$(jq -r '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE")
    if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
        echo "⚠️  WARNING: $INCOMPLETE_COUNT incomplete todos"
        echo "Options: 1) /99_continue  2) CLOSE_INCOMPLETE=true /03_close  3) Cancel"
        exit 1
    fi
fi
```

**Escalation options**:
- Continue work: `/99_continue`
- Force close: `CLOSE_INCOMPLETE=true /03_close`
- Cancel closure: Keep plan in in_progress/

### Safe Git Push with Retry

**Helper functions** (Step 7.2.5):
- `get_push_error_message()`: Simplify error messages
- `git_push_with_retry()`: Retry logic (3 attempts, exponential backoff)
- `print_push_summary()`: Display push failures

**Retry logic**:
```bash
# Exit code 1: Don't retry (non-fast-forward, protected branch)
# Exit code 128: Retry (network, auth, transient errors)
# Wait times: 2s, 4s, 8s (exponential backoff)
```

**Blocking**: Plan closure blocks if push fails (exit 1)

**Verification**: Compare local and remote SHA after push

### Worktree Cleanup

**Purpose**: Clean up isolated worktree after completion

**Workflow**:
1. Read worktree metadata from plan file
2. Squash merge worktree branch to main
3. Push squash merge to remote
4. Remove worktree, branch, directory
5. Remove lock file (error trap ensures cleanup)

### Documenter Agent (Default)

**Invocation**: Always after plan completion (skip with `--no-docs`)

**Updates**:
- CLAUDE.md (Tier 1) - if project-level changes
- Component CONTEXT.md (Tier 2) - if component changes
- docs/ai-context/ - always update project-structure.md, system-integration.md
- Plan file - add execution summary

**Archives**: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

---

## Further Reading

**Internal**: @.claude/skills/close-plan/REFERENCE.md - Full implementation details, state management, git push system, worktree cleanup | @.claude/skills/git-master/SKILL.md - Version control workflow | @.claude/guides/continuation-system.md - Sisyphus continuation system | @.claude/guides/3tier-documentation.md - Documentation synchronization

**External**: [Conventional Commits](https://www.conventionalcommits.org/) | [GitHub CLI](https://cli.github.com/manual/gh_pr_create)
