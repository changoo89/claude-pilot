# Close Plan Skill - Full Reference

> **Purpose**: Extended details for plan completion workflow
> **Main Skill**: @.claude/skills/close-plan/SKILL.md
> **Last Updated**: 2026-01-22

---

## Worktree Cleanup

### Worktree Context (Step 1)

**Purpose**: Read context from plan file metadata

**Metadata parsing**:
```bash
if grep -q "## Worktree Info" "$ACTIVE_PLAN_PATH" 2>/dev/null; then
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN MAIN_PROJECT_DIR LOCK_FILE <<< "$WORKTREE_META"

    # Validate fields
    [ -z "$WT_BRANCH" ] || [ -z "$WT_PATH" ] && exit 1
    [ ! -d "$MAIN_PROJECT_DIR" ] && exit 1

    # Error trap: cleanup lock on failure
    trap "rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

    # Change to main project
    cd "$MAIN_PROJECT_DIR" || exit 1

    # Squash merge
    if ! do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MSG"; then
        echo "WARNING: Squash merge failed. Manual resolution required."
        exit 1
    fi

    # Push squash merge
    if git config --get remote.origin.url > /dev/null 2>&1; then
        git_push_with_retry "origin" "$WT_MAIN" || exit 1
    fi

    # Cleanup worktree
    cleanup_worktree "$WT_PATH" "$WT_BRANCH"
    rm -rf "$LOCK_FILE"
    trap - EXIT ERR
fi
```

### Worktree Utilities Functions

**Full reference**: @.claude/scripts/worktree-utils.sh

| Function | Purpose |
|----------|---------|
| `read_worktree_metadata()` | Parse 5 fields from plan |
| `do_squash_merge()` | Squash merge worktree branch to main |
| `cleanup_worktree()` | Remove worktree, branch, directory |
| `get_main_project_dir()` | Get main project path from worktree |
| `get_main_pilot_dir()` | Get main `.pilot/` path |

---

## Git Push System

### Helper Functions

**Key functions**: `get_push_error_message()`, `git_push_with_retry()`, `print_push_summary()`

**Error codes**:
- Exit 1: Non-fast-forward, protected branch (don't retry)
- Exit 128: Network, auth, transient errors (retry with exponential backoff: 2s, 4s, 8s)

**Retry logic**: Max 3 attempts, exponential backoff (2^iteration seconds)

### Safe Git Push (Step 7.3)

**Safety**: Dry-run verification, graceful degradation, no force push

**Blocking**: Plan closure blocks if push fails (exit 1)

**Workflow**:
1. Skip if: not git repo, no remote, uncommitted changes, no branch
2. Dry-run verification (`git push --dry-run`)
3. Actual push with retry (if dry-run successful)
4. Track results in `PUSH_RESULTS` array
5. Block plan closure if any push failed

### Verify Git Push Completed (Step 7.4)

**SHA comparison**: Compare local SHA (`git rev-parse HEAD`) with remote SHA (`git rev-parse origin/<branch>`)

**Success**: Local and remote SHA match
**Failure**: SHA mismatch → Mark as failed, print warning

---

## Documenter Agent Delegation

### Documenter Agent Invocation (Step 5)

**Full details**: @.claude/skills/three-tier-docs/SKILL.md

**Default**: Always invoke after plan completion (skip with `--no-docs`)

**Updates**: CLAUDE.md (Tier 1), Component CONTEXT.md (Tier 2), docs/ai-context/, plan file

**Archives**: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

**Expected**: `<DOCS_COMPLETE>` marker

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `/03_close` | Invokes skill | → Archive plan, commit changes |
| Git operations | Commit + push | → Create commit, verify push |
| Worktree cleanup | Remove worktree | → Cleanup if --wt flag used |
| Documenter Agent | Update docs | → Sync documentation |

---

## See Also

**Skill Documentation**:
- @.claude/skills/close-plan/SKILL.md - Quick reference
- @.claude/skills/git-master/SKILL.md - Git operations
- @.claude/skills/execute-plan/SKILL.md - Plan execution workflow

**System Integration**:
- @.claude/skills/three-tier-docs/SKILL.md - Documentation synchronization
- @.claude/scripts/worktree-utils.sh - Worktree utilities

**Command Reference**:
- @.claude/commands/03_close.md - Close command
- @.claude/commands/03_close-details.md - Detailed reference

---

**Last Updated**: 2026-01-22
**Version**: 1.1.0 (Close Plan Skill - Reduced)
