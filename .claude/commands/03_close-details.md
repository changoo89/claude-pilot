# /03_close - Detailed Reference

> **Purpose**: Extended details for /03_close command workflow
> **Main Command**: @.claude/commands/03_close.md
> **Last Updated**: 2026-01-18

---

## Continuation Verification System

### State File Check (Step 3.5)

**Purpose**: Verify ALL todos complete before archiving plan (Sisyphus enforcement)

**State file**: `.pilot/state/continuation.json`

**Check logic**:
```bash
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"

if [ -f "$STATE_FILE" ]; then
    CONTINUATION_STATE="$(cat "$STATE_FILE")"
    INCOMPLETE_TODOS="$(echo "$CONTINUATION_STATE" | jq -r '.todos[] | select(.status != "complete") | .id')"
    INCOMPLETE_COUNT="$(echo "$INCOMPLETE_TODOS" | grep -c '^' || echo 0)"

    echo "📋 Continuation State Check"
    echo "Incomplete todos: $INCOMPLETE_COUNT"

    if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
        echo "⚠️  WARNING: Incomplete todos detected"
        echo "Remaining todos:"
        echo "$INCOMPLETE_TODOS" | while read -r todo_id; do
            todo_details="$(echo "$CONTINUATION_STATE" | jq -r --arg id "$todo_id" '.todos[] | select(.id == $id)')"
            echo "  - $todo_id"
            echo "    Status: $(echo "$todo_details" | jq -r '.status')"
        done

        echo "Options:"
        echo "  1) Continue work (run /99_continue)"
        echo "  2) Close anyway (archive incomplete plan)"
        echo "  3) Cancel closure (keep plan in_progress)"

        CLOSE_INCOMPLETE="${CLOSE_INCOMPLETE:-false}"

        if [ "$CLOSE_INCOMPLETE" != "true" ]; then
            echo "❌ Refusing to close incomplete plan"
            exit 1
        else
            echo "⚠️  Closing incomplete plan (forced)"
        fi
    else
        echo "✅ All todos complete"
    fi
else
    echo "ℹ️  No continuation state found (pre-Sisyphus plan)"
fi
```

### State File Preservation

**CRITICAL**: Continuation state file is PRESERVED even after plan closure for recovery purposes

**Archive state to done/ folder**:
```bash
if [ -f "$STATE_FILE" ]; then
    STATE_ARCHIVE="$PROJECT_ROOT/.pilot/plan/done/${RUN_ID}_continuation_state.json"
    cp "$STATE_FILE" "$STATE_ARCHIVE"
    echo "✓ Archived continuation state: $STATE_ARCHIVE"
    # Note: Original state file is NOT deleted yet
fi
```

**Delete state file AFTER confirmation**:
```bash
DELETE_STATE="${DELETE_STATE:-false}"

if [ "$DELETE_STATE" = "true" ] && [ -f "$STATE_FILE" ]; then
    FINAL_BACKUP="$STATE_FILE.final.backup"
    cp "$STATE_FILE" "$FINAL_BACKUP"
    rm -f "$STATE_FILE"
    echo "✓ Deleted continuation state (backup: $FINAL_BACKUP)"
else
    echo "ℹ️  Continuation state preserved for recovery"
    echo "   To delete: DELETE_STATE=true /03_close"
fi
```

### Escalation for Incomplete Todos

**Option 1: Continue work**
```bash
/99_continue  # Resume from continuation state
```

**Option 2: Force close**
```bash
CLOSE_INCOMPLETE=true /03_close  # Archive incomplete plan
```

**Option 3: Cancel closure**
```bash
# Keep plan in in_progress/, continue work later
```

---

## Worktree Cleanup

### Worktree Context (Step 1)

**Purpose**: Read context from plan file metadata instead of relying on is_in_worktree

**Check for worktree metadata**:
```bash
if grep -q "## Worktree Info" "$ACTIVE_PLAN_PATH" 2>/dev/null; then
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"

    if [ -n "$WORKTREE_META" ]; then
        # Parse 5 fields: branch|worktree_path|main_branch|main_project|lock_file
        IFS='|' read -r WT_BRANCH WT_PATH WT_MAIN MAIN_PROJECT_DIR LOCK_FILE <<< "$WORKTREE_META"

        # Validate required fields
        if [ -z "$WT_BRANCH" ] || [ -z "$WT_PATH" ] || [ -z "$WT_MAIN" ] || [ -z "$MAIN_PROJECT_DIR" ]; then
            echo "ERROR: Invalid worktree metadata - required fields missing" >&2
            exit 1
        fi

        # Validate main project directory exists
        if [ ! -d "$MAIN_PROJECT_DIR" ]; then
            echo "ERROR: Main project directory not found: $MAIN_PROJECT_DIR" >&2
            exit 1
        fi

        # Error trap: cleanup lock on any failure
        trap "rm -rf \"$LOCK_FILE\" 2>/dev/null" EXIT ERR

        # 1. Change to main project (from metadata)
        cd "$MAIN_PROJECT_DIR" || exit 1

        # 2. Generate commit message from plan
        PLAN_TITLE="${ACTIVE_PLAN_PATH:-.}"
        [ -f "$PLAN_TITLE" ] && TITLE="$(grep -E '^# ' "$PLAN_TITLE" 2>/dev/null | head -1 | sed 's/^# //')" || TITLE="Update"
        COMMIT_MSG="${TITLE}

Co-Authored-By: Claude <noreply@anthropic.com>"

        # 3. Squash merge (with fallback on failure)
        if ! do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MSG"; then
            echo "WARNING: Squash merge failed. Worktree preserved for manual resolution." >&2
            printf "To retry: cd '%s' && git checkout '%s' && git merge --squash '%s'\\n" "$WT_PATH" "$WT_MAIN" "$WT_BRANCH" >&2
            # Still cleanup lock but don't remove worktree
            rm -rf "$LOCK_FILE" 2>/dev/null
            trap - EXIT ERR
            # Continue to move plan to done but skip cleanup
        else
            # 4. Push squash merge to remote
            echo "Pushing squash merge to remote..."
            if ! git config --get remote.origin.url > /dev/null 2>&1; then
                echo "  → No remote configured, skipping push"
            else
                # Use git_push_with_retry function (defined in Git Push section)
                PUSH_OUTPUT="$(git_push_with_retry "origin" "$WT_MAIN" 2>&1)"
                PUSH_EXIT=$?

                if [ "$PUSH_EXIT" -ne 0 ]; then
                    ERROR_MSG="$(get_push_error_message "$PUSH_EXIT" "$PUSH_OUTPUT")"
                    echo "  ✗ Push failed: $ERROR_MSG" >&2
                    echo "  Worktree preserved for manual push" >&2
                    echo "  To push manually: cd '$MAIN_PROJECT_DIR' && git push origin '$WT_MAIN'" >&2
                    rm -rf "$LOCK_FILE" 2>/dev/null
                    trap - EXIT ERR
                    exit 1
                else
                    echo "  ✓ Push successful"
                fi
            fi

            # 5. Cleanup worktree, branch, directory
            cleanup_worktree "$WT_PATH" "$WT_BRANCH"

            # 6. Remove lock file (explicit cleanup, trap handles errors)
            rm -rf "$LOCK_FILE"

            # Clear trap on success
            trap - EXIT ERR
        fi
    fi
fi
```

### Worktree Utilities Functions

**Full reference**: See @.claude/scripts/worktree-utils.sh

**Key functions**:
- `read_worktree_metadata()`: Parse 5 fields from plan
- `do_squash_merge()`: Squash merge worktree branch to main
- `cleanup_worktree()`: Remove worktree, branch, directory
- `get_main_project_dir()`: Get main project path from worktree
- `get_main_pilot_dir()`: Get main `.pilot/` path

---

## Git Push System

### Helper Functions (Step 7.2.5)

**Get simplified error message**:
```bash
get_push_error_message() {
    local exit_code="$1"
    local error_output="$2"

    case "$exit_code" in
        1)
            if echo "$error_output" | grep -qi "non-fast-forward"; then
                echo "Remote has new commits - run 'git pull' before pushing"
            elif echo "$error_output" | grep -qi "protected"; then
                echo "Branch is protected - push not allowed directly"
            else
                echo "Push rejected - check repository status"
            fi
            ;;
        128)
            if echo "$error_output" | grep -qi "authentication"; then
                echo "Authentication failed - check your credentials"
            elif echo "$error_output" | grep -qi "could not read\|connection\|network"; then
                echo "Network error - connection failed"
            elif echo "$error_output" | grep -qi "not found"; then
                echo "Remote repository not found - check remote URL"
            else
                echo "Push failed - check remote configuration"
            fi
            ;;
        *)
            echo "Push failed (exit code: $exit_code)"
            ;;
    esac
}
```

**Git push with retry logic**:
```bash
git_push_with_retry() {
    local remote_name="${1:-origin}"
    local branch="$2"
    local max_retries="${3:-3}"
    local retry_count=0
    local exit_code=0
    local error_output=""

    while [ "$retry_count" -lt "$max_retries" ]; do
        error_output="$(git push "$remote_name" "$branch" 2>&1)"
        exit_code=$?

        if [ "$exit_code" -eq 0 ]; then
            return 0
        fi

        # Don't retry on exit code 1 (non-fast-forward)
        if [ "$exit_code" -eq 1 ]; then
            return $exit_code
        fi

        # Retry on exit code 128 (network, auth, transient errors)
        retry_count=$((retry_count + 1))

        if [ "$retry_count" -lt "$max_retries" ]; then
            local wait_time=$((2 ** retry_count))
            echo "  → Network error (attempt $retry_count/$max_retries), retrying in ${wait_time}s..."
            sleep "$wait_time"
        fi
    done

    return $exit_code
}
```

**Print push failure summary**:
```bash
print_push_summary() {
    if [ ${#PUSH_FAILURES[@]} -eq 0 ]; then
        return
    fi

    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "⚠️  Git Push Summary"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    if [ ${#PUSH_FAILURES[@]} -eq 1 ]; then
        echo "Push failed for 1 repository:"
    else
        echo "Push failed for ${#PUSH_FAILURES[@]} repositories:"
    fi
    echo ""

    for repo in "${!PUSH_FAILURES[@]}"; do
        IFS='|' read -r error_type message <<< "${PUSH_FAILURES[$repo]}"
        echo "  📁 $repo"
        echo "     ❌ $message"
        echo ""
    done

    echo "💡 Tip: Commits were created successfully. Push manually with:"
    echo "   git push origin <branch>"
    echo "════════════════════════════════════════════════════════════"
}
```

### Safe Git Push (Step 7.3)

**Safety First**: Dry-run verification, graceful degradation, no force push

**Blocking**: Plan closure blocks if push fails (exit 1)

```bash
# Initialize push tracking
declare -A PUSH_FAILURES
declare -A PUSH_RESULTS

# Only push if this is a git repository with a remote
for REPO in "${REPOS_TO_COMMIT[@]}"; do
    echo "Checking git push for: $REPO"
    cd "$REPO" || continue

    # Skip if not a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "  → Not a git repository, skipping push"
        PUSH_RESULTS["$REPO"]="skipped"
        cd - > /dev/null
        continue
    fi

    # Skip if no remote configured
    if ! git config --get remote.origin.url > /dev/null 2>&1; then
        echo "  → No remote configured, skipping push"
        PUSH_RESULTS["$REPO"]="skipped"
        cd - > /dev/null
        continue
    fi

    # Check for uncommitted changes (safety check)
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "  → Uncommitted changes detected, skipping push"
        PUSH_RESULTS["$REPO"]="skipped"
        cd - > /dev/null
        continue
    fi

    # Get current branch
    CURRENT_BRANCH="$(git branch --show-current 2>/dev/null)"
    if [ -z "$CURRENT_BRANCH" ]; then
        echo "  → Cannot determine branch, skipping push"
        PUSH_RESULTS["$REPO"]="skipped"
        cd - > /dev/null
        continue
    fi

    # Dry-run verification (safety check)
    echo "  → Dry-run verification for $CURRENT_BRANCH..."
    DRYRUN_OUTPUT="$(git push --dry-run origin "$CURRENT_BRANCH" 2>&1)"
    DRYRUN_EXIT=$?

    if [ "$DRYRUN_EXIT" -eq 0 ]; then
        # Dry-run successful, proceed with actual push
        echo "  → Pushing to origin/$CURRENT_BRANCH..."
        PUSH_OUTPUT="$(git_push_with_retry "origin" "$CURRENT_BRANCH" 2>&1)"
        PUSH_EXIT=$?

        if [ "$PUSH_EXIT" -eq 0 ]; then
            echo "  ✓ Push successful"
            PUSH_RESULTS["$REPO"]="success"
        else
            ERROR_MSG="$(get_push_error_message "$PUSH_EXIT" "$PUSH_OUTPUT")"
            echo "  ✗ $ERROR_MSG"
            PUSH_FAILURES["$REPO"]="push_failed|$ERROR_MSG"
            PUSH_RESULTS["$REPO"]="failed"
        fi
    else
        # Dry-run failed - get simplified error message
        ERROR_MSG="$(get_push_error_message "$DRYRUN_EXIT" "$DRYRUN_OUTPUT")"
        echo "  → Dry-run failed: $ERROR_MSG (commit was created)"
        PUSH_FAILURES["$REPO"]="dryrun_failed|$ERROR_MSG"
        PUSH_RESULTS["$REPO"]="failed"
    fi

    cd - > /dev/null
done

# Check if any push failed - block plan closure
HAS_FAILED_PUSH=false
for REPO in "${!PUSH_RESULTS[@]}"; do
    if [ "${PUSH_RESULTS[$REPO]}" = "failed" ]; then
        HAS_FAILED_PUSH=true
        break
    fi
done

if [ "$HAS_FAILED_PUSH" = true ]; then
    print_push_summary

    echo ""
    echo "❌ ERROR: Git push failed - plan closure blocked" >&2
    echo "   Commits were created locally but not pushed to remote." >&2
    echo "   Fix the push issue and run /03_close again." >&2
    exit 1
fi
```

### Verify Git Push Completed (Step 7.4)

**Verification Checklist**:
```bash
# Check if push succeeded by examining PUSH_RESULTS array
for REPO in "${!PUSH_RESULTS[@]}"; do
    RESULT="${PUSH_RESULTS[$REPO]}"
    echo "Repository: $REPO"
    echo "  Push Result: $RESULT"

    if [ "$RESULT" = "success" ]; then
        # Verify push by comparing local and remote SHA
        cd "$REPO" || continue
        CURRENT_BRANCH="$(git branch --show-current 2>/dev/null)"

        # Get local SHA
        LOCAL_SHA="$(git rev-parse HEAD 2>/dev/null)"

        # Get remote SHA
        REMOTE_SHA="$(git rev-parse "origin/$CURRENT_BRANCH" 2>/dev/null)"

        # Compare SHAs to verify push succeeded
        if [ -n "$LOCAL_SHA" ] && [ -n "$REMOTE_SHA" ] && [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
            echo "  ✅ Push verified - local and remote SHA match ($LOCAL_SHA)"
        else
            echo "  ⚠️  Push reported success but SHA mismatch!"
            echo "     Local:  $LOCAL_SHA"
            echo "     Remote: $REMOTE_SHA"
            PUSH_FAILURES["$REPO"]="sha_mismatch|SHA mismatch after push"
            PUSH_RESULTS["$REPO"]="failed"
        fi
        cd - > /dev/null
    elif [ "$RESULT" = "failed" ]; then
        echo "  ⚠️  Push failed - commit created locally only"
        echo "  💡 Manual push required: git push origin <branch>"
    elif [ "$RESULT" = "skipped" ]; then
        echo "  ℹ️  Push skipped - no remote or other condition"
    fi
done
```

---

## Documenter Agent Delegation

### Documenter Agent Invocation (Step 5)

**Full details**: See @.claude/guides/3tier-documentation.md

**Default Behavior**: Always invoke Documenter Agent after plan completion

**Exception**: `--no-docs` flag skips this step

**Agent Invocation**:
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
