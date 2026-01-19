---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*), Task
---

# /03_close

_Finalize plan by moving to done and creating git commit._

## Core Philosophy

- **Close only after verification**: Don't archive incomplete plans
- **Traceability**: Preserve plan with evidence (commands, results)
- **Default commit**: Commits created automatically (skip with no-commit flag)

**Methodology**: @.claude/skills/close-plan/SKILL.md
**Details**: @.claude/commands/03_close-details.md

---

## Step 0.5: GPT Delegation Trigger Check (MANDATORY)

> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| Completion review | Keywords: "review", "validate", "audit" | Delegate to GPT Plan Reviewer |
| User explicitly requests | "ask GPT", "consult GPT" | Delegate to GPT Plan Reviewer |

**Graceful fallback**:
```bash
command -v codex &> /dev/null || { echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"; return 0; }
```

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS"
```

---

## Step 1: Worktree Context (--wt flag)

> **Full cleanup workflow**: @.claude/commands/03_close-details.md#worktree-cleanup

```bash
# Parse worktree metadata and cleanup
if grep -q "## Worktree Info" "$ACTIVE_PLAN_PATH" 2>/dev/null; then
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN MAIN_PROJECT_DIR LOCK_FILE <<< "$WORKTREE_META"

    # Validate fields and directory
    [ -z "$WT_BRANCH" ] || [ -z "$WT_PATH" ] || [ -z "$WT_MAIN" ] || [ -z "$MAIN_PROJECT_DIR" ] && { echo "ERROR: Invalid metadata" >&2; exit 1; }
    [ ! -d "$MAIN_PROJECT_DIR" ] && { echo "ERROR: Directory not found: $MAIN_PROJECT_DIR" >&2; exit 1; }

    trap "rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR
    cd "$MAIN_PROJECT_DIR" || exit 1

    # Generate commit message and squash merge
    TITLE="$(grep -E '^# ' "$ACTIVE_PLAN_PATH" 2>/dev/null | head -1 | sed 's/^# //')" || "Update"
    COMMIT_MSG="${TITLE}"$'\n\n'"Co-Authored-By: Claude <noreply@anthropic.com>"

    if do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MSG"; then
        # Push, cleanup, and remove lock
        if git config --get remote.origin.url > /dev/null 2>&1; then
            PUSH_OUTPUT="$(git_push_with_retry "origin" "$WT_MAIN" 2>&1)"
            [ $? -ne 0 ] && { echo "✗ Push failed" >&2; rm -rf "$LOCK_FILE"; trap - EXIT ERR; exit 1; }
        fi
        cleanup_worktree "$WT_PATH" "$WT_BRANCH"
        rm -rf "$LOCK_FILE"
        trap - EXIT ERR
    else
        echo "WARNING: Squash merge failed. Worktree preserved." >&2
        rm -rf "$LOCK_FILE"; trap - EXIT ERR
    fi
fi
```

---

## Step 2: Locate Active Plan (Worktree-Aware)

> **Full detection logic**: @.claude/commands/03_close-details.md

```bash
ACTIVE_PLAN_PATH=""

# Worktree-first detection
if is_in_worktree 2>/dev/null; then
    WORKTREE_PLAN="$(get_active_plan_from_metadata)"
    [ -n "$WORKTREE_PLAN" ] && [ -f "$WORKTREE_PLAN" ] && ACTIVE_PLAN_PATH="$WORKTREE_PLAN"
fi

# Standard detection
if [ -z "$ACTIVE_PLAN_PATH" ]; then
    PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
    BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
    KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    ACTIVE_PTR="$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"

    [ -f "$ACTIVE_PTR" ] && ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
    [ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && ACTIVE_PLAN_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${RUN_ID}.md"
    [ -z "$ACTIVE_PLAN_PATH" ] && ACTIVE_PLAN_PATH="$(ls -t "$PROJECT_ROOT/.pilot/plan/in_progress/"*.md 2>/dev/null | head -1)"
fi

[ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ] && { echo "ERROR: No active plan found" >&2; exit 1; }
echo "Active plan: $ACTIVE_PLAN_PATH"
```

---

## Step 3: Verify Completion

Read plan, verify:
- [ ] All acceptance criteria met
- [ ] Evidence present (tests, build, manual)
- [ ] Todos completed or deferred

If not complete: Update plan with remaining items, don't move to done

---

## Step 3.5: Continuation Verification (MANDATORY)

> **Full state management**: @.claude/commands/03_close-details.md#continuation-verification-system

```bash
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"

if [ -f "$STATE_FILE" ]; then
    INCOMPLETE_COUNT="$(jq -r '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE")"
    if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
        echo "⚠️  WARNING: $INCOMPLETE_COUNT incomplete todos detected"
        echo "Options: 1) /99_continue  2) CLOSE_INCOMPLETE=true /03_close  3) Cancel"
        CLOSE_INCOMPLETE="${CLOSE_INCOMPLETE:-false}"
        [ "$CLOSE_INCOMPLETE" != "true" ] && { echo "❌ Refusing to close incomplete plan" >&2; exit 1; }
    fi
fi
```

---

## Step 4: Move to Done

```bash
mkdir -p "$PROJECT_ROOT/.pilot/plan/done"

# Extract RUN_ID and determine format
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"; IS_FOLDER_FORMAT=true
else
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"; IS_FOLDER_FORMAT=false
fi

DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}.md"
[ -e "$DONE_PATH" ] && DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S).md"

# Move plan or folder
if [ "$IS_FOLDER_FORMAT" = true ]; then
    DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}"
    [ -e "$DONE_DIR" ] && DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S)"
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"
else
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"
fi

# Clear active pointers (main and worktree branch keys)
[ -f "$ACTIVE_PTR" ] && rm -f "$ACTIVE_PTR"
if grep -q "## Worktree Info" "$DONE_PATH" 2>/dev/null; then
    WT_META="$(read_worktree_metadata "$DONE_PATH" 2>/dev/null)"
    [ -n "$WT_META" ] && IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN MAIN_PROJECT LOCK_FILE <<< "$WT_META"
    WT_KEY="$(printf "%s" "$WT_BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    WT_PTR="$PROJECT_ROOT/.pilot/plan/active/${WT_KEY}.txt"
    [ -f "$WT_PTR" ] && rm -f "$WT_PTR"
fi
```

---

## Step 5: Documenter Agent (Context Isolation)

> **Details**: @.claude/guides/3tier-documentation.md

**Default**: Always invoke Documenter Agent after plan completion

**Exception**: `--no-docs` flag skips this step

**🚀 MANDATORY ACTION**:
```markdown
Task:
  subagent_type: documenter
  prompt: |
    Update documentation after plan completion:

    RUN_ID: {RUN_ID}
    Plan Path: {DONE_PATH}
    Changed files: {CHANGED_FILES}

    Update:
    - CLAUDE.md (Tier 1) - if project-level changes
    - Component CONTEXT.md (Tier 2) - if component changes
    - docs/ai-context/ - always update
    - Plan file - add execution summary

    Archive: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

    Return summary only.
```

---

## Step 6: Documentation Checklist

> **For manual review**: Use **Step 5** for automatic updates

| Tier | File | Max Lines | Trigger |
|------|------|-----------|---------|
| **Tier 1** | CLAUDE.md | 300 | Project-level changes |
| **Tier 2** | Component CONTEXT.md | 200 | src/, lib/, components/ changes |
| **Tier 3** | Feature CONTEXT.md | 150 | features/ changes |

**Auto-sync**: Run `/91_document`

---

## Step 7: Git Commit

**Default**: Always create commit (skip with `no-commit` argument)

### 7.1 Identify Repositories
```bash
declare -a REPOS_TO_COMMIT=()
git rev-parse --git-dir > /dev/null 2>&1 && REPOS_TO_COMMIT+=("$(pwd)")
for EXTERNAL_REPO in ${EXTERNAL_REPOS:-}; do
    [ -d "$EXTERNAL_REPO" ] && (cd "$EXTERNAL_REPO" && git rev-parse --git-dir > /dev/null 2>&1) && REPOS_TO_COMMIT+=("$EXTERNAL_REPO")
done
```

### 7.2 Commit Repositories
```bash
for REPO in "${REPOS_TO_COMMIT[@]}"; do
    cd "$REPO" || continue
    git status --porcelain | grep -q ".env\|credentials" && echo "⚠️ Warning: Possible secrets detected"
    TITLE="$(grep -E '^# ' "${ACTIVE_PLAN_PATH:-.}" 2>/dev/null | head -1 | sed 's/^# //')" || "Update"
    git add -A
    git commit -m "${TITLE}"$'\n\n'"Co-Authored-By: Claude <noreply@anthropic.com>"
    cd - > /dev/null
done
```

### 7.2.5 Helper Functions for Git Push

> **Full implementation**: @.claude/commands/03_close-details.md#git-push-system

Helper functions: `get_push_error_message()`, `git_push_with_retry()`, `print_push_summary()`

### 7.3 Safe Git Push (MANDATORY - Blocking on Failure)

> **Full push workflow with retry logic**: @.claude/commands/03_close-details.md

Dry-run verification, push with retry, SHA verification. Blocks closure on failure.

### 7.4 Verify Git Push Completed (MANDATORY)

> **Full verification code**: @.claude/commands/03_close-details.md

Verify push by comparing local and remote SHA for successful pushes.

---

## Success Criteria

- [ ] Plan moved from `in_progress/` to `done/`
- [ ] Archived plan includes acceptance criteria and evidence
- [ ] Git commit created (if git repo and not no-commit)
- [ ] Git push verified or skipped (no remote)

---

## Workflow

```
/00_plan → /01_confirm → /02_execute → /03_close
                                       ↓
                                  (after completion)
```

---

## References

- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`
