---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*)
---

# /03_close

_Finalize plan by moving to done and optionally creating git commit._

## Core Philosophy

- **Close only after verification**: Don't archive incomplete plans
- **Traceability**: Preserve plan with evidence (commands, results)
- **Optional commit**: Committing is opt-in

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 1: Worktree Context (--wt flag)

> **When**: Running /03_close from worktree, perform squash merge and cleanup

```bash
if is_in_worktree; then
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    if [ -z "$WORKTREE_META" ]; then
        echo "Error: Worktree metadata not found. Continuing with normal close..." >&2
    else
        WT_BRANCH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f1)"
        WT_PATH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f2)"
        WT_MAIN="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f3)"
        echo "Worktree: Branch=$WT_BRANCH, Path=$WT_PATH, Main=$WT_MAIN"
        echo "Press Enter to squash merge and cleanup..."; read -r

        # Commit uncommitted changes
        [ -n "$(git status --porcelain 2>/dev/null)" ] && git add -A && git commit -m "WIP: Worktree completion $(date +%Y%m%d_%H%M%S)"

        # Generate commit message from plan
        PLAN_TITLE="$(grep -E '^# ' "$ACTIVE_PLAN_PATH" | head -1 | sed 's/^# //')"
        COMMIT_MESSAGE="${PLAN_TITLE:-Worktree completion}"$'\n\nCo-Authored-By: Claude <noreply@anthropic.com>'

        # Squash merge and cleanup
        if do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MESSAGE"; then
            has_merge_conflicts && resolve_conflicts_interactive && git commit --no-edit
            cleanup_worktree "$WT_PATH" "$WT_BRANCH"
            MAIN_PROJECT_DIR="$(get_main_project_dir)"
            mkdir -p "${MAIN_PROJECT_DIR}/.pilot/plan/done"
            DONE_PATH="${MAIN_PROJECT_DIR}/.ilot/plan/done/$(basename "$ACTIVE_PLAN_PATH")"
            [ -e "$DONE_PATH" ] && DONE_PATH="${MAIN_PROJECT_DIR}/.pilot/plan/done/$(basename "$ACTIVE_PLAN_PATH" .md)_closed_$(date +%Y%m%d_%H%M%S).md"
            cp "$ACTIVE_PLAN_PATH" "$DONE_PATH"; rm -f "$ACTIVE_PLAN_PATH"
            echo "✅ Worktree closed. Plan: $DONE_PATH"
            exit 0
        else
            echo "❌ Squash merge failed" >&2; exit 1
        fi
    fi
fi
```

---

## Step 2: Locate Active Plan

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

# Priority: explicit args, RUN_ID (file/folder format), active pointer
[ -f "$ACTIVE_PTR" ] && ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && [ -f ".pilot/plan/in_progress/${RUN_ID}.md" ] && ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}.md"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && [ -f ".pilot/plan/in_progress/${RUN_ID}/plan.md" ] && ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}/plan.md"

[ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ] && { echo "No active plan. Pass RUN_ID or path." >&2; ls -la .pilot/plan/in_progress 2>/dev/null; exit 1; }
echo "Active: $ACTIVE_PLAN_PATH"
```

---

## Step 3: Verify Completion

Read plan, verify: [ ] All acceptance criteria met, [ ] Evidence present (tests, build, manual), [ ] Todos completed or deferred

If not complete: Update plan with remaining items, don't move to done

---

## Step 4: Move to Done

```bash
mkdir -p .pilot/plan/done
# Extract RUN_ID (file or folder format)
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"; IS_FOLDER_FORMAT=true
else
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"; IS_FOLDER_FORMAT=false
fi

DONE_PATH=".pilot/plan/done/${RUN_ID}.md"
[ -e "$DONE_PATH" ] && DONE_PATH=".pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S).md"

if [ "$IS_FOLDER_FORMAT" = true ]; then
    DONE_DIR=".pilot/plan/done/${RUN_ID}"
    [ -e "$DONE_DIR" ] && DONE_DIR=".pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S)"
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"; echo "Archived: $DONE_DIR"
else
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"; echo "Archived: $DONE_PATH"
fi

# Clear active pointer if it references this plan
[ -f "$ACTIVE_PTR" ] && PTR_CONTENT="$(cat "$ACTIVE_PTR")" && \
    ([ "$PTR_CONTENT" = "$ACTIVE_PLAN_PATH" ] || [ "$PTR_CONTENT" = "$(dirname "$ACTIVE_PLAN_PATH")" ]) && rm -f "$ACTIVE_PTR" && echo "Pointer cleared"
```

---

## Step 5: Git Commit (Optional)

> **Skip if `"$ARGUMENTS"` contains `no-commit`**

```bash
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repo. Plan archived."
    exit 0
fi

# Check preconditions: [ ] Working tree clean (except intentional changes), [ ] No secrets (.env*, credentials)
git status
git diff

# Generate commit message
# 1) Read plan title/objectives, 2) Identify type (feat/fix/refactor/chore/docs/style), 3) Extract scope, 4) Summarize
git add -A
git commit -m "$(cat <<'EOF'
feat(scope): description

- Change 1
- Change 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Success Criteria

- [ ] Plan moved from `in_progress/` to `done/`
- [ ] Archived plan includes acceptance criteria and evidence
- [ ] Git commit created (if git repo and not no-commit)

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
                                       ↓
                                  (after completion)
```

---

## References
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
- **Status**: !`git status --short`
