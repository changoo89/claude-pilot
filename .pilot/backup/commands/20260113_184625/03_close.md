---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*)
---

# /03_close

_Finalize the current plan by moving it to done and optionally creating a git commit._

---

## Core Philosophy

- **Close only after verification**: Do not archive a plan that has not met acceptance criteria.
- **Traceability**: Preserve the plan and attach evidence (commands run, results).
- **Optional commit**: Committing is opt-in and must be explicit.

---

## Step 0: Source Worktree Utilities

```bash
# Source worktree utility functions
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
if [ -f "$WORKTREE_UTILS" ]; then
    . "$WORKTREE_UTILS"
else
    echo "Warning: Worktree utilities not found at $WORKTREE_UTILS"
fi
```

---

## Step 0.5: Detect Worktree Context

> **When to handle**: When running /03_close from within a worktree, perform squash merge and cleanup.

### 0.5.1 Check if in Worktree

```bash
if is_in_worktree; then
    echo "Worktree context detected"
    echo ""

    # Get current branch
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    echo "Current branch: $CURRENT_BRANCH"
    echo ""

    # Get worktree metadata from active plan
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"

    if [ -z "$WORKTREE_META" ]; then
        echo "Error: Worktree metadata not found in plan" >&2
        echo "This plan may not have been created with --wt flag" >&2
        echo "Continuing with normal close流程..." >&2
    else
        # Parse metadata
        WT_BRANCH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f1)"
        WT_PATH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f2)"
        WT_MAIN="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f3)"

        echo "Worktree Info:"
        echo "  Branch: $WT_BRANCH"
        echo "  Path: $WT_PATH"
        echo "  Main Branch: $WT_MAIN"
        echo ""

        # Confirm before proceeding
        echo "This will:"
        echo "  1. Commit any uncommitted changes in the worktree"
        echo "  2. Squash merge $WT_BRANCH into $WT_MAIN"
        echo "  3. Remove the worktree, branch, and directory"
        echo ""
        echo "Press Enter to continue or Ctrl+C to cancel..."
        read -r

        # Step 1: Commit any uncommitted changes
        echo ""
        echo "Checking for uncommitted changes..."
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo "Uncommitted changes detected. Creating a commit..."
            git add -A
            git commit -m "WIP: Worktree completion $(date +%Y%m%d_%H%M%S)" || {
                echo "Warning: Failed to create commit" >&2
            }
        else
            echo "No uncommitted changes"
        fi

        # Step 2: Generate commit message from plan
        echo ""
        echo "Preparing squash merge..."
        PLAN_TITLE="$(grep -E '^# ' "$ACTIVE_PLAN_PATH" | head -1 | sed 's/^# //')"
        COMMIT_MESSAGE="${PLAN_TITLE:-Worktree completion}

Co-Authored-By: Claude <noreply@anthropic.com>"

        # Step 3: Squash merge to main
        echo ""
        if do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MESSAGE"; then
            echo "✅ Squash merge successful"

            # Step 4: Check for conflicts
            if has_merge_conflicts; then
                echo ""
                echo "⚠️  Merge conflicts detected"
                if resolve_conflicts_interactive; then
                    echo "✅ Conflicts resolved"
                    git commit --no-edit
                else
                    echo "❌ Failed to resolve conflicts automatically" >&2
                    echo "Please resolve manually and run cleanup manually:" >&2
                    echo "  git worktree remove $WT_PATH" >&2
                    echo "  git branch -D $WT_BRANCH" >&2
                    echo "  rm -rf $WT_PATH" >&2
                    exit 1
                fi
            fi

            # Step 5: Cleanup worktree
            echo ""
            echo "Cleaning up worktree..."
            cleanup_worktree "$WT_PATH" "$WT_BRANCH"

            # Step 6: Move plan to done in main repo
            MAIN_PROJECT_DIR="$(get_main_project_dir)"
            MAIN_PLAN_PATH="${MAIN_PROJECT_DIR}/.pilot/plan/in_progress/$(basename "$ACTIVE_PLAN_PATH")"

            # Move plan from worktree in_progress to main repo done
            mkdir -p "${MAIN_PROJECT_DIR}/.pilot/plan/done"
            DONE_PATH="${MAIN_PROJECT_DIR}/.pilot/plan/done/$(basename "$ACTIVE_PLAN_PATH")"

            if [ -e "$DONE_PATH" ]; then
                TS="$(date +%Y%m%d_%H%M%S)"
                DONE_PATH="${MAIN_PROJECT_DIR}/.pilot/plan/done/$(basename "$ACTIVE_PLAN_PATH" .md)_closed_${TS}.md"
            fi

            cp "$ACTIVE_PLAN_PATH" "$DONE_PATH"
            rm -f "$ACTIVE_PLAN_PATH"
            rm -f "$MAIN_PLAN_PATH"

            echo ""
            echo "✅ Worktree close completed successfully!"
            echo ""
            echo "Plan archived to: $DONE_PATH"
            echo ""
            echo "⚠️  IMPORTANT: You are now in the main project directory:"
            echo "    $MAIN_PROJECT_DIR"
            echo ""

            # Exit here - we've completed the worktree close
            exit 0

        else
            echo "❌ Squash merge failed" >&2
            echo "The worktree is still available for manual resolution" >&2
            exit 1
        fi
    fi
fi
```

---

## Step 1: Locate the Active Plan

### 1.1 Active Pointer Convention

Multiple plans may be in progress concurrently. This command closes the plan for the current session/branch.

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"
```

### 1.2 Determine `ACTIVE_PLAN_PATH`

Priority order:

1. Explicit path from `"$ARGUMENTS"`
2. RUN_ID from `"$ARGUMENTS"` → try both file and folder formats:
   - New: `.pilot/plan/in_progress/{RUN_ID}.md`
   - Old: `.pilot/plan/in_progress/{RUN_ID}/plan.md`
3. Read from `ACTIVE_PTR` (may be file or folder path)

```bash
if [ -f "$ACTIVE_PTR" ]; then
    ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
fi

# If explicit RUN_ID provided, try both formats
if [ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ]; then
    # Try new file format first
    if [ -f ".pilot/plan/in_progress/${RUN_ID}.md" ]; then
        ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}.md"
    # Fallback to old folder format
    elif [ -f ".pilot/plan/in_progress/${RUN_ID}/plan.md" ]; then
        ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}/plan.md"
    fi
fi

if [ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ]; then
    echo "No active plan found for this session/branch."
    echo "Options: pass RUN_ID or plan path explicitly."
    ls -la .pilot/plan/in_progress 2>/dev/null || true
    exit 1
fi
```

---

## Step 2: Verify Plan Completion

### 2.1 Read Plan

```bash
# Read the active plan
PLAN_CONTENT="$(cat "$ACTIVE_PLAN_PATH")"
```

### 2.2 Check Acceptance Criteria

Verify:
- [ ] All acceptance criteria met
- [ ] Verification evidence present (tests, build, manual steps)
- [ ] Todos completed or explicitly deferred

If not complete:
- Update plan with remaining items
- Do not move to done yet

---

## Step 3: Prepare Done Directory

### 3.1 Create Destination

```bash
mkdir -p .pilot/plan/done
```

### 3.2 Generate Archive Name

```bash
# Extract RUN_ID from plan path (handle both file and folder formats)
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    # Old folder format: in_progress/{RUN_ID}/plan.md
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"
    IS_FOLDER_FORMAT=true
else
    # New file format: in_progress/{RUN_ID}.md
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"
    IS_FOLDER_FORMAT=false
fi

DONE_PATH=".pilot/plan/done/${RUN_ID}.md"

# Handle naming conflicts
if [ -e "$DONE_PATH" ]; then
    TS="$(date +%Y%m%d_%H%M%S)"
    DONE_PATH=".pilot/plan/done/${RUN_ID}_closed_${TS}.md"
fi
```

---

## Step 4: Move Plan to Done

```bash
if [ "$IS_FOLDER_FORMAT" = true ]; then
    # Old folder format: move the entire folder
    DONE_DIR=".pilot/plan/done/${RUN_ID}"
    if [ -e "$DONE_DIR" ]; then
        TS="$(date +%Y%m%d_%H%M%S)"
        DONE_DIR=".pilot/plan/done/${RUN_ID}_closed_${TS}"
    fi
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"
    echo "Plan archived to: $DONE_DIR"
else
    # New file format: just move the file
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"
    echo "Plan archived to: $DONE_PATH"
fi
```

### 4.1 Clean Active Pointer

```bash
if [ -f "$ACTIVE_PTR" ]; then
    PTR_CONTENT="$(cat "$ACTIVE_PTR")"
    # Check if pointer references this plan (both formats)
    if [ "$PTR_CONTENT" = "$ACTIVE_PLAN_PATH" ] || [ "$PTR_CONTENT" = "$(dirname "$ACTIVE_PLAN_PATH")" ]; then
        rm -f "$ACTIVE_PTR"
        echo "Active pointer cleared"
    fi
fi
```

---

## Step 5: Create Git Commit (Optional)

> **Skip if `"$ARGUMENTS"` contains `no-commit`**

### 5.0 Check Git Repository

```bash
# Check if this is a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository. Skipping commit step."
    echo "Plan has been archived successfully."
    exit 0
fi
```

### 5.1 Check Preconditions

- [ ] Working tree clean (except for intentional changes)
- [ ] No secrets included (no `.env*`, credentials)

### 5.2 Inspect Changes

```bash
git status
git diff
```

### 5.3 Generate Commit Message

Analyze plan and session to create meaningful message:

1. Read plan title and objectives
2. Identify change type:
   - `feat` - new feature
   - `fix` - bug fix
   - `refactor` - restructuring
   - `chore` - maintenance
   - `docs` - documentation
   - `style` - formatting/UI
3. Extract scope (affected area)
4. Summarize accomplishments (imperative mood)

### 5.4 Commit Format

```
<type>(<scope>): <short summary>

<optional body with details>

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 5.5 Create Commit

```bash
git add -A

git commit -m "$(cat <<'EOF'
feat(scope): description of changes

- Change 1
- Change 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Success Criteria

- Plan moved from `in_progress/` to `done/` (file-based or folder-based)
- Archived plan includes acceptance criteria and evidence
- Git commit created if git repo (skipped if not a git repository)

---

## Workflow

```
/00_plan → /01_confirm → /02_execute → /03_close
                              ↓
                         (after completion)
```

---

## References

- **Ralph Loop TDD**: `.claude/guides/ralph-loop-tdd.md`
