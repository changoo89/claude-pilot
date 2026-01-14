---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*)
---

# /03_close

_Finalize plan by moving to done and creating git commit by default._

## Core Philosophy

- **Close only after verification**: Don't archive incomplete plans
- **Traceability**: Preserve plan with evidence (commands, results)
- **Default commit**: Commits created automatically (skip with no-commit flag)

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS"
```

---

## Step 1: Worktree Context (--wt flag)

> **When**: Running /03_close from worktree, perform squash merge and cleanup

```bash
if is_in_worktree; then
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    # ... squash merge, cleanup worktree, move plan to done in main repo
fi
```

---

## Step 2: Locate Active Plan

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

# Priority: explicit args, RUN_ID, active pointer
[ -f "$ACTIVE_PTR" ] && ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}.md"

[ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ] && { echo "No active plan" >&2; exit 1; }
```

---

## Step 3: Verify Completion

Read plan, verify:
- [ ] All acceptance criteria met
- [ ] Evidence present (tests, build, manual)
- [ ] Todos completed or deferred

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
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"
else
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"
fi

# Clear active pointer
[ -f "$ACTIVE_PTR" ] && rm -f "$ACTIVE_PTR"
```

---

## Step 5: Git Commit (Default)

> **Skip only if `no-commit` specified - commit is default behavior**

### 5.1 Identify Modified Repositories

Before committing, identify ALL repositories modified:
1. Current working directory
2. External/linked repositories (absolute paths)
3. Submodules or workspace dependencies

```bash
declare -a REPOS_TO_COMMIT=()

# Check current repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    REPOS_TO_COMMIT+=("$(pwd)")
fi

# Prompt for external repos
echo "Were any external repositories modified? (paths space-separated, or Enter to skip):"
read -r EXTERNAL_REPOS_INPUT

for EXTERNAL_REPO in $EXTERNAL_REPOS_INPUT; do
    if [ -d "$EXTERNAL_REPO" ] && (cd "$EXTERNAL_REPO" && git rev-parse --git-dir > /dev/null 2>&1); then
        REPOS_TO_COMMIT+=("$EXTERNAL_REPO")
    fi
done
```

### 5.2 Commit Repositories

```bash
for REPO in "${REPOS_TO_COMMIT[@]}"; do
    echo "Committing: $REPO"
    cd "$REPO" || continue

    # Check for secrets
    if git status --porcelain | grep -q ".env\|credentials"; then
        echo "⚠️ Warning: Possible secrets detected"
    fi

    # Generate commit message from plan
    PLAN_TITLE="${ACTIVE_PLAN_PATH:-.}"
    [ -f "$PLAN_TITLE" ] && TITLE="$(grep -E '^# ' "$PLAN_TITLE" 2>/dev/null | head -1 | sed 's/^# //')" || TITLE="Update"

    git add -A
    git commit -m "${TITLE}

Co-Authored-By: Claude <noreply@anthropic.com>"

    cd - > /dev/null
done
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
