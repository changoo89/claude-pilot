---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*), Task
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

    if [ -n "$WORKTREE_META" ]; then
        IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN <<< "$WORKTREE_META"
        MAIN_PROJECT_DIR="$(get_main_project_dir)"
        LOCK_FILE="${MAIN_PROJECT_DIR}/.pilot/plan/.locks/$(basename "$ACTIVE_PLAN_PATH").lock"

        # Error trap: cleanup lock on any failure
        trap "rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

        # 1. Change to main project
        cd "$MAIN_PROJECT_DIR" || exit 1

        # 2. Generate commit message from plan
        PLAN_TITLE="${ACTIVE_PLAN_PATH:-.}"
        [ -f "$PLAN_TITLE" ] && TITLE="$(grep -E '^# ' "$PLAN_TITLE" 2>/dev/null | head -1 | sed 's/^# //')" || TITLE="Update"
        COMMIT_MSG="${TITLE}

Co-Authored-By: Claude <noreply@anthropic.com>"

        # 3. Squash merge
        do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MSG"

        # 4. Cleanup worktree, branch, directory
        cleanup_worktree "$WT_PATH" "$WT_BRANCH"

        # 5. Remove lock file (explicit cleanup, trap handles errors)
        rm -rf "$LOCK_FILE"

        # Clear trap on success
        trap - EXIT ERR
    fi
fi
```

---

## Step 2: Locate Active Plan

```bash
# Project root detection (always use project root, not current directory)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR="$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"

# Priority: explicit args, RUN_ID, active pointer
[ -f "$ACTIVE_PTR" ] && ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && ACTIVE_PLAN_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${RUN_ID}.md"

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
mkdir -p "$PROJECT_ROOT/.pilot/plan/done"

# Extract RUN_ID (file or folder format)
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"; IS_FOLDER_FORMAT=true
else
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"; IS_FOLDER_FORMAT=false
fi

DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}.md"
[ -e "$DONE_PATH" ] && DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S).md"

if [ "$IS_FOLDER_FORMAT" = true ]; then
    DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}"
    [ -e "$DONE_DIR" ] && DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S)"
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"
else
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"
fi

# Clear active pointer
[ -f "$ACTIVE_PTR" ] && rm -f "$ACTIVE_PTR"
```

---

## Step 5: Delegate to Documenter Agent (Context Isolation)

**Full details**: See @.claude/guides/3tier-documentation.md - Agent delegation pattern

### 🚀 MANDATORY ACTION: Documenter Agent Invocation

> **CRITICAL**: YOU MUST invoke the Documenter Agent NOW using the Task tool for context isolation.
> This is not optional. Execute this Task tool call immediately.

**Why Agent?**: Documenter Agent runs in **isolated context window** (~30K tokens internally). Only summary returns here (8x token efficiency).

**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):

```markdown
Task:
  subagent_type: documenter
  prompt: |
    Update documentation after plan completion:

    RUN_ID: {RUN_ID}
    Plan Path: {DONE_PATH}
    Changed files (from git diff): {CHANGED_FILES}

    Update:
    - CLAUDE.md (Tier 1) - if project-level changes
    - Component CONTEXT.md (Tier 2) - if component changes
    - docs/ai-context/ - always update project-structure.md, system-integration.md
    - Plan file - add execution summary

    Archive: test-scenarios.md, coverage-report.txt, ralph-loop-log.md

    Return summary only.
```

**Expected Output**: `<DOCS_COMPLETE>` marker with files updated and artifacts archived

**Skip**: If `--no-docs` specified, note in commit message

---

## Step 6: Documentation Checklist (Manual - Use Agent Instead)

> **NOTE**: This step is preserved for manual review. For automatic updates, use **Step 5: Delegate to Documenter Agent** instead.

**Full documentation sync**: See @.claude/guides/3tier-documentation.md

### Check Documentation Updates

| Tier | File | Max Lines | Trigger |
|------|------|-----------|---------|
| **Tier 1** | CLAUDE.md | 300 | Project-level changes |
| **Tier 2** | Component CONTEXT.md | 200 | src/, lib/, components/ changes |
| **Tier 3** | Feature CONTEXT.md | 150 | features/ changes |

**Auto-sync**: Run `/91_document` to synchronize all tiers automatically

---

## Step 7: Git Commit (Default)

> **Skip only if `no-commit` specified - commit is default behavior**

### 7.1 Identify Modified Repositories

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

# Note: External repos must be specified via argument or environment variable
# Non-interactive mode - no prompt for external repos
# To commit external repos, use: EXTERNAL_REPOS="/path/to/repo1 /path/to/repo2" /03_close
if [ -n "${EXTERNAL_REPOS:-}" ]; then
    for EXTERNAL_REPO in $EXTERNAL_REPOS; do
        if [ -d "$EXTERNAL_REPO" ] && (cd "$EXTERNAL_REPO" && git rev-parse --git-dir > /dev/null 2>&1); then
            REPOS_TO_COMMIT+=("$EXTERNAL_REPO")
        fi
    done
fi
```

### 7.2 Commit Repositories

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

### 7.3 Safe Git Push (Optional, Non-Blocking)

> **Safety First**: Dry-run verification, graceful degradation, no force push

```bash
# Only push if this is a git repository with a remote
for REPO in "${REPOS_TO_COMMIT[@]}"; do
    echo "Checking git push for: $REPO"
    cd "$REPO" || continue

    # Skip if not a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "  → Not a git repository, skipping push"
        cd - > /dev/null
        continue
    fi

    # Skip if no remote configured
    if ! git config --get remote.origin.url > /dev/null 2>&1; then
        echo "  → No remote configured, skipping push"
        cd - > /dev/null
        continue
    fi

    # Check for uncommitted changes (safety check)
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "  → Uncommitted changes detected, skipping push"
        cd - > /dev/null
        continue
    fi

    # Get current branch
    CURRENT_BRANCH="$(git branch --show-current 2>/dev/null)"
    if [ -z "$CURRENT_BRANCH" ]; then
        echo "  → Cannot determine branch, skipping push"
        cd - > /dev/null
        continue
    fi

    # Dry-run verification (safety check)
    echo "  → Dry-run verification for $CURRENT_BRANCH..."
    if git push --dry-run origin "$CURRENT_BRANCH" > /dev/null 2>&1; then
        # Dry-run successful, proceed with actual push
        echo "  → Pushing to origin/$CURRENT_BRANCH..."
        if git push origin "$CURRENT_BRANCH"; then
            echo "  ✓ Push successful"
        else
            echo "  ✗ Push failed (but commit was created)"
        fi
    else
        echo "  → Dry-run failed, skipping push (commit was created)"
    fi

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
- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`
