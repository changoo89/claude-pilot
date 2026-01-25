# Close Plan Skill - Full Reference

> **Purpose**: Extended details for plan completion workflow
> **Main Skill**: @.claude/skills/close-plan/SKILL.md
> **Last Updated**: 2026-01-25

---

## Enhanced Step Tracking

### Execution Directive

**CRITICAL**: NEVER skip any step - agent MUST verify execution of each step before proceeding to the next. All steps MUST execute in order. Do NOT pause between steps.

### Step Markers

Each step includes clear markers for execution flow:
- `▶ STEP N`: Start of step
- `✓ STEP N COMPLETE`: Successful completion
- `[MANDATORY GATE]`: Critical validation points that must pass

### Mandatory Gates

Steps 3 and 4 are mandatory gates that must complete successfully:
- **Step 3**: Parallel Documentation Sync + Evidence Verification with timestamp verification
- **Step 4**: Move plan to done (waits for Step 3 to complete)

### Step Tracking Implementation

```bash
# Pattern for all steps
echo "▶ STEP N: [Step Name]"
# ... step logic ...
echo "✓ STEP N COMPLETE"
```

---

## Worktree Cleanup Details

### Worktree Context (Step 7)

**Purpose**: Read context from plan file metadata

**Metadata parsing**:
```bash
if grep -q "## Worktree Info" "$ACTIVE_PLAN_PATH" 2>/dev/null; then
    WORKTREE_META="$(read_worktree_metadata "$PLAN_PATH")"
    IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN MAIN_PROJECT_DIR LOCK_FILE <<< "$WORKTREE_META"

    # Validate fields
    [ -z "$WT_BRANCH" ] || [ -z "$WT_PATH" ] && exit 1
    [ ! -d "$MAIN_PROJECT_DIR" ] && exit 1

    # Error trap: cleanup lock on failure
    trap "rm -f \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

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
    rm -f "$LOCK_FILE"
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

### git_push_with_retry Implementation

```bash
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
```

---

## Discovered Issues Warning

### Active Issues Check (Step 2.5)

**Purpose**: Warn about active Discovered Issues before closing plan

**Pattern**: "Offer, don't force" - Show warning but allow user to proceed

**Implementation**:
```bash
# Check for active Discovered Issues
ISSUES_STATE_FILE="$PROJECT_ROOT/.pilot/issues/state.json"

if [ -f "$ISSUES_STATE_FILE" ]; then
    if command -v jq >/dev/null 2>&1; then
        P0_COUNT=$(jq -r '.counts.P0 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        P1_COUNT=$(jq -r '.counts.P1 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        P2_COUNT=$(jq -r '.counts.P2 // 0' "$ISSUES_STATE_FILE" 2>/dev/null || echo 0)
        TOTAL=$((P0_COUNT + P1_COUNT + P2_COUNT))

        if [ "$TOTAL" -gt 0 ]; then
            echo ""
            echo "⚠️  Warning: $TOTAL active Discovered Issue(s)"
            echo "   P0 (blocking): $P0_COUNT | P1 (follow-up): $P1_COUNT | P2 (backlog): $P2_COUNT"
            echo ""
            echo "   These issues will remain unresolved after closing this plan."
        fi
    fi
fi
```

**Behavior**:
- **Non-blocking**: Warning shows but doesn't prevent closing
- **User choice**: User can press Ctrl+C to abort or wait 3 seconds to continue
- **Graceful degradation**: If jq or state.json missing, skip check silently
- **Priority breakdown**: Shows counts by P0 (blocking), P1 (follow-up), P2 (backlog)

**Related**: @.claude/scripts/pilot-issues - Discovered Issues CLI

---

## Documenter Agent Delegation

### Documenter Agent Invocation (Step 3)

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
| Discovered Issues | Warning check | → Read state.json, show warning |
| Git operations | Commit + push | → Create commit, verify push |
| Worktree cleanup | Remove worktree | → Cleanup if --wt flag used |
| Documenter Agent | Update docs | → Sync documentation |

---

## Step-by-Step Implementation Details

### Step 1: Load Plan (Full)

```bash
echo "▶ STEP 1: Load Plan"

PROJECT_ROOT="$(pwd)"
PLAN_ARG="$1"
NO_COMMIT_FLAG="$2"
NO_PUSH_FLAG="$3"

# Find plan path
if [ -n "$PLAN_ARG" ] && [ -f "$PLAN_ARG" ]; then
    PLAN_PATH="$PLAN_ARG"
elif [ -n "$PLAN_ARG" ]; then
    PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*${PLAN_ARG}*.md" -type f 2>/dev/null | head -1)"
else
    PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | head -1)"
fi

if [ -z "$PLAN_PATH" ]; then
    echo "❌ No plan in progress"
    exit 1
fi

echo "✓ Plan: $PLAN_PATH"
echo "✓ STEP 1 COMPLETE"
```

### Step 2: Verify All SCs Complete (Full)

```bash
echo "▶ STEP 2: Verify All SCs Complete"

INCOMPLETE_SC="$(grep -c "^- \[ \]" "$PLAN_PATH" 2>/dev/null || echo 0)"

if [ "$INCOMPLETE_SC" -gt 0 ]; then
    echo "⚠️  $INCOMPLETE_SC Success Criteria incomplete"
    echo "   Continue with: /02_execute"
    exit 1
fi

echo "✓ All Success Criteria complete"
echo "✓ STEP 2 COMPLETE"
```

### Step 4: Move Plan to Done (Full)

```bash
echo "▶ STEP 4: Move Plan to Done"

TIMESTAMP="$(date +%Y%m%d)"
DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${TIMESTAMP}"
mkdir -p "$DONE_DIR"

mv "$PLAN_PATH" "$DONE_DIR/"
DONE_PLAN_PATH="$DONE_DIR/$(basename "$PLAN_PATH")"

echo "✓ Plan moved to: $DONE_PLAN_PATH"
echo "✓ STEP 4 COMPLETE"
```

### Step 5: Git Commit (Full)

```bash
echo "▶ STEP 5: Git Commit"

if [ "$NO_COMMIT_FLAG" = "no-commit" ]; then
    echo "⚠️  Skipping git commit (no-commit flag)"
    exit 0
fi

git add "$DONE_DIR/"
PLAN_TITLE="$(basename "$PLAN_PATH" .md)"

git commit -m "close(plan): $PLAN_TITLE" -m "Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✓ Git commit created"
echo "✓ STEP 5 COMPLETE"
```

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

**Last Updated**: 2026-01-25
**Version**: 1.4.0 (Close Plan Skill - Refactored for ≤200 lines SKILL.md)
