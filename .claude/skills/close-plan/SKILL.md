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
- Push to remote with retry logic

### Quick Reference
```bash
# Full workflow
/03_close [RUN_ID|plan_path] [no-commit] [no-push]

# Steps: Load → Verify SCs → Check DI → Docs → Evidence → Move → Commit → Push → Worktree Auto-Merge
```

---

## Execution Steps

Execute ALL steps in sequence. Do NOT pause between steps.

### Step 1: Load Plan

**Purpose**: Find active plan with absolute path detection

```bash
# PROJECT_ROOT = Claude Code execution directory (absolute path required)
PROJECT_ROOT="$(pwd)"

# Parse arguments
PLAN_ARG="$1"
NO_COMMIT_FLAG="$2"
NO_PUSH_FLAG="$3"

# Find plan path
if [ -n "$PLAN_ARG" ] && [ -f "$PLAN_ARG" ]; then
    PLAN_PATH="$PLAN_ARG"
elif [ -n "$PLAN_ARG" ]; then
    # RUN_ID provided
    PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*${PLAN_ARG}*.md" -type f 2>/dev/null | head -1)"
else
    # Find any in-progress plan
    PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | head -1)"
fi

if [ -z "$PLAN_PATH" ]; then
    echo "❌ No plan in progress"
    exit 1
fi

echo "✓ Plan: $PLAN_PATH"
```

---

### Step 2: Verify All SCs Complete

**Purpose**: Ensure all Success Criteria are checked off

```bash
INCOMPLETE_SC="$(grep -c "^- \[ \]" "$PLAN_PATH" 2>/dev/null || echo 0)"

if [ "$INCOMPLETE_SC" -gt 0 ]; then
    echo "⚠️  $INCOMPLETE_SC Success Criteria incomplete"
    echo "   Continue with: /02_execute"
    exit 1
fi

echo "✓ All Success Criteria complete"
```

---

### Step 2.5: Check Active Discovered Issues

**Purpose**: Warn about active Discovered Issues before closing plan

**Pattern**: "Offer, don't force" - Show warning but allow user to proceed

```bash
# Check for active Discovered Issues
ISSUES_STATE_FILE="$PROJECT_ROOT/.pilot/issues/state.json"

if [ -f "$ISSUES_STATE_FILE" ]; then
    # Read issue counts (jq is required for pilot-issues)
    if command -v jq >/dev/null 2>&1; then
        P0_COUNT=$(jq -r '.counts.P0 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        P1_COUNT=$(jq -r '.counts.P1 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        P2_COUNT=$(jq -r '.counts.P2 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        TOTAL=$((P0_COUNT + P1_COUNT + P2_COUNT))

        # Show warning if any active issues exist
        if [ "$TOTAL" -gt 0 ]; then
            echo ""
            echo "⚠️  Warning: $TOTAL active Discovered Issue(s)"
            echo "   P0 (blocking): $P0_COUNT | P1 (follow-up): $P1_COUNT | P2 (backlog): $P2_COUNT"
            echo ""
            echo "   These issues will remain unresolved after closing this plan."
            echo "   Press Ctrl+C to abort, or wait 3 seconds to continue..."
            echo ""
            # Non-blocking wait - user can press Ctrl+C to abort
            sleep 3
        fi
    fi
fi
```

---

### Step 3: Auto Documentation Sync

**Purpose**: Update documentation based on session changes, then verify compliance

#### Step 3.1: Documentation Update

```bash
echo "📚 Running documentation update (three-tier-docs skill)..."
echo "Invoke the three-tier-docs skill to sync documentation with code changes."
```

**Updates**:
- Tier 1: CLAUDE.md, project-structure.md, docs-overview.md
- Tier 2: Component CONTEXT.md files
- Tier 3: Feature CONTEXT.md files

#### Step 3.2: Documentation Verification

```bash
echo "✅ Running documentation verification (docs-verify skill)..."
echo "Invoke the docs-verify skill to validate documentation compliance."
```

**Validation includes** (via docs-verify skill):
- Tier 1 line limits (≤200 lines): CLAUDE.md, project-structure.md, docs-overview.md
- docs/ai-context/ contains exactly 2 files
- No broken cross-references
- No circular references

---

### Step 4: Verify Evidence

**Purpose**: Run verification commands from Success Criteria

```bash
grep -A1 "Verify:" "$PLAN_PATH" | while read cmd; do
    [[ "$cmd" =~ ^(test|grep|\[) ]] && eval "$cmd" 2>/dev/null || true
done
```

---

### Step 5: Move Plan to Done

**Purpose**: Archive plan with timestamp organization

```bash
# Use same PROJECT_ROOT from Step 1
TIMESTAMP="$(date +%Y%m%d)"
DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${TIMESTAMP}"
mkdir -p "$DONE_DIR"

# Move plan to done
mv "$PLAN_PATH" "$DONE_DIR/"
DONE_PLAN_PATH="$DONE_DIR/$(basename "$PLAN_PATH")"

echo "✓ Plan moved to: $DONE_PLAN_PATH"
```

---

### Step 6: Git Commit

**Purpose**: Create conventional commit with Co-Authored-By

```bash
# Skip if no-commit flag
if [ "$NO_COMMIT_FLAG" = "no-commit" ]; then
    echo "⚠️  Skipping git commit (no-commit flag)"
    exit 0
fi

# Stage plan file
git add "$DONE_DIR/"

# Extract plan title for commit message
PLAN_TITLE="$(basename "$PLAN_PATH" .md)"

# Create commit
git commit -m "close(plan): $PLAN_TITLE" -m "Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✓ Git commit created"
```

---

### Step 7: Git Push with Retry

**Purpose**: Push to remote with exponential backoff retry logic

**Git Push**: Reference @.claude/skills/git-operations/SKILL.md for `git_push_with_retry` function

```bash
# Skip if no-push flag
if [ "$NO_PUSH_FLAG" = "no-push" ]; then
    echo "⚠️  Skipping git push (no-push flag)"
    exit 0
fi

# Get current branch
CURRENT_BRANCH="$(git branch --show-current)"

# Source git-operations helpers
source_git_helpers() {
    # Inline git_push_with_retry for standalone execution
    # See @.claude/skills/git-operations/SKILL.md for canonical version

    git_push_with_retry() {
        local remote="${1:-origin}"
        local branch="${2:-$CURRENT_BRANCH}"
        local max_attempts=3
        local wait_times=(2 4 8)  # Exponential backoff

        echo "🔄 Pushing to $remote/$branch..."

        for attempt in $(seq 1 $max_attempts); do
            # Attempt push
            if git push "$remote" "$branch" 2>&1; then
                echo "✓ Push successful"
                return 0
            fi

            local exit_code=$?
            local error_output="$(git push "$remote" "$branch" 2>&1 || true)"

            # Classify error
            if echo "$error_output" | grep -qiE "non-fast-forward|rejected|protected"; then
                echo "❌ Push rejected (non-fast-forward or protected branch)"
                echo "   Run: git pull --rebase && git push"
                return 1
            elif echo "$error_output" | grep -qiE "authentication|permission|credentials"; then
                echo "❌ Authentication error"
                echo "   Check git credentials: git config --list | grep credential"
                return 1
            fi

            # Retry for network/transient errors
            if [ $attempt -lt $max_attempts ]; then
                local wait_time=${wait_times[$((attempt-1))]}
                echo "⚠️  Push failed (attempt $attempt/$max_attempts), retrying in ${wait_time}s..."
                sleep "$wait_time"
            else
                echo "❌ Push failed after $max_attempts attempts"
                return 1
            fi
        done

        return 1
    }
}

# Execute push
source_git_helpers

if ! git_push_with_retry "origin" "$CURRENT_BRANCH"; then
    # Check if remote exists
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo "⚠️  No remote 'origin' configured - local commit preserved"
        exit 0
    fi

    echo "❌ Push failed - plan closure blocked"
    exit 1
fi

echo "✓ Pushed to origin/$CURRENT_BRANCH"
```

---

### Step 8: Worktree Auto-Merge (Optional)

**Purpose**: Merge feature branch to main when in worktree mode

**Trigger Condition**: One of the following:
1. `[ -f "$PROJECT_ROOT/.pilot/state/worktree.json" ]`
2. `$(git worktree list | wc -l) -gt 1`
3. Current branch starts with `wt/`, `fix/`, or `feat/` prefix

```bash
# Check if worktree mode
IS_WORKTREE="false"
if [ -f "$PROJECT_ROOT/.pilot/state/worktree.json" ]; then
    IS_WORKTREE="true"
elif [ "$(git worktree list | wc -l)" -gt 1 ]; then
    IS_WORKTREE="true"
elif [[ "$CURRENT_BRANCH" =~ ^(wt/|fix/|feat/) ]]; then
    IS_WORKTREE="true"
fi

if [ "$IS_WORKTREE" = "true" ]; then
    FEATURE_BRANCH="$CURRENT_BRANCH"

    # Dynamic main branch detection
    MAIN_BRANCH="$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')"
    MAIN_BRANCH="${MAIN_BRANCH:-main}"

    echo "🔀 Worktree mode detected - merging to $MAIN_BRANCH..."

    # Get worktree path before switching branches
    WORKTREE_PATH="$(jq -r '.path // empty' "$PROJECT_ROOT/.pilot/state/worktree.json" 2>/dev/null)"

    # Switch to main branch
    git checkout "$MAIN_BRANCH" || { echo "❌ Failed to checkout $MAIN_BRANCH"; exit 1; }

    # Merge feature branch (fast-forward preferred)
    if git merge --ff-only "$FEATURE_BRANCH" 2>/dev/null; then
        echo "✓ Fast-forward merge successful"
    elif git merge "$FEATURE_BRANCH" --no-edit; then
        echo "✓ Merge commit created"
    else
        echo "❌ Merge failed - resolve conflicts manually"
        git merge --abort 2>/dev/null || true
        exit 1
    fi

    # Push main branch
    if ! git_push_with_retry "origin" "$MAIN_BRANCH"; then
        echo "❌ Failed to push $MAIN_BRANCH"
        exit 1
    fi

    echo "✓ Merged and pushed $FEATURE_BRANCH → $MAIN_BRANCH"

    # Auto cleanup worktree and branch
    if [ -n "$WORKTREE_PATH" ] && [ -d "$WORKTREE_PATH" ]; then
        echo "🧹 Cleaning up worktree..."
        git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true
        git branch -d "$FEATURE_BRANCH" 2>/dev/null || git branch -D "$FEATURE_BRANCH" 2>/dev/null || true
        rm -f "$PROJECT_ROOT/.pilot/state/worktree.json"
        echo "✓ Worktree and branch cleaned up"
    fi
fi
```

---

## What This Skill Covers

### In Scope
- Plan path detection (absolute paths)
- Success Criteria verification
- Active Discovered Issues warning (non-blocking)
- Documentation update (three-tier-docs skill)
- Documentation verification (docs-verify skill)
- Evidence verification
- Plan archival to done/
- Git commit with Co-Authored-By
- Git push with retry (3 attempts, exponential backoff)
- Worktree auto-merge to main branch with cleanup

### Out of Scope
- Advanced git workflows → @.claude/skills/git-master/SKILL.md

---

## Further Reading

**Internal**: @.claude/skills/close-plan/REFERENCE.md - Full implementation details | @.claude/skills/git-operations/SKILL.md - Git push retry system | @.claude/skills/git-master/SKILL.md - Version control workflow | @.claude/skills/three-tier-docs/SKILL.md - Documentation synchronization | @.claude/skills/using-git-worktrees/SKILL.md - Worktree management

**External**: [Conventional Commits](https://www.conventionalcommits.org/) | [GitHub CLI](https://cli.github.com/manual/gh_pr_create)
