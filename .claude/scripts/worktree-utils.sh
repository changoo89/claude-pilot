#!/bin/bash
# Worktree utility functions for /02_execute and /03_close
# These functions provide Git worktree support for parallel plan execution

# Check if --wt flag is in arguments
# Usage: is_worktree_mode "$@"
# Returns: 0 if --wt flag present, 1 otherwise
is_worktree_mode() {
    case " $* " in
        *" --wt "*|*" --wt="*) return 0 ;;
        *) return 1 ;;
    esac
}

# Get the oldest pending plan
# Usage: oldest_plan=$(select_oldest_pending)
# Returns: Path to oldest pending plan, or empty if none
select_oldest_pending() {
    ls -1tr .pilot/plan/pending/*.md 2>/dev/null | head -1
}

# Select and lock the oldest pending plan (atomic operation)
# Usage: locked_plan=$(select_and_lock_pending)
# Returns: Path to locked plan, or empty if none available
# This function prevents race conditions when multiple executors select plans
select_and_lock_pending() {
    local lock_dir=".pilot/plan/.locks"
    mkdir -p "$lock_dir"

    for plan in $(ls -1tr .pilot/plan/pending/*.md 2>/dev/null); do
        local plan_name="$(basename "$plan")"
        local lock_file="${lock_dir}/${plan_name}.lock"

        # Atomic lock attempt using mkdir (atomic on POSIX)
        if mkdir "$lock_file" 2>/dev/null; then
            # Verify plan still exists AFTER lock acquired (race condition fix)
            if [ ! -f "$plan" ]; then
                rmdir "$lock_file"  # Release lock
                continue  # Try next plan
            fi
            # Lock acquired and plan verified
            echo "$plan"
            return 0
        fi
        # Lock failed - try next plan
    done

    # No available plans
    return 1
}

# Convert plan filename to branch name
# Usage: branch=$(plan_to_branch "20260113_160000_worktree_support.md")
# Returns: branch name like "feature/20260113-160000-worktree-support"
plan_to_branch() {
    local plan_file="$1"
    plan_file="$(basename "$plan_file" .md)"
    # 20260113_160000_worktree_support → feature/20260113-160000-worktree-support
    printf "feature/%s" "$plan_file" | sed 's/_/-/g'
}

# Create a Git worktree for parallel execution
# Usage: create_worktree "branch-name" "plan-file" "main-branch"
# Creates worktree in ../project-wt-{branch-shortname}
# Returns: Absolute path to worktree directory
create_worktree() {
    local branch_name="$1"
    local plan_file="$2"
    local main_branch="${3:-main}"
    local project_name
    local worktree_dir

    # Get project name from current directory
    project_name="$(basename "$(pwd)")"

    # Create worktree directory name
    local branch_shortname
    branch_shortname="$(printf "%s" "$branch_name" | sed 's|^feature/||')"
    worktree_dir="../${project_name}-wt-${branch_shortname}"

    # Create worktree
    echo "Creating worktree at: $worktree_dir"
    if ! git worktree add -b "$branch_name" "$worktree_dir" "$main_branch" 2>&1; then
        echo "Failed to create worktree" >&2
        return 1
    fi

    # Convert to absolute path (SC-2)
    worktree_dir="$(cd "$worktree_dir" && pwd)"

    printf "%s" "$worktree_dir"
}

# Add worktree metadata to plan file
# Usage: add_worktree_metadata "plan-path" "branch" "worktree-path" "main-branch" ["main-project"] ["lock-file"]
add_worktree_metadata() {
    local plan_path="$1"
    local branch="$2"
    local worktree_path="$3"
    local main_branch="$4"
    local main_project="${5:-}"
    local lock_file="${6:-}"
    local timestamp

    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%S")"

    # Append metadata to plan
    cat >> "$plan_path" << EOF

## Worktree Info

- Branch: ${branch}
- Worktree Path: ${worktree_path}
- Main Branch: ${main_branch}
EOF

    # Add optional fields if provided (SC-3, SC-7)
    if [ -n "$main_project" ]; then
        echo "- Main Project: ${main_project}" >> "$plan_path"
    fi

    if [ -n "$lock_file" ]; then
        echo "- Lock File: ${lock_file}" >> "$plan_path"
    fi

    echo "- Created At: ${timestamp}" >> "$plan_path"
}

# Detect if current directory is a Git worktree
# Usage: is_in_worktree
# Returns: 0 if in worktree, 1 otherwise
is_in_worktree() {
    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return 1

    # Check if .git file contains gitdir: (worktree marker)
    if [ -f "$git_dir" ]; then
        grep -q "^gitdir:" "$git_dir" 2>/dev/null
        return $?
    fi

    return 1
}

# Get worktree metadata from plan file
# Usage: read_worktree_metadata "plan-path"
# Outputs: branch|worktree_path|main_branch|main_project|lock_file (pipe-delimited)
# Returns: 0 if all required fields found, 1 otherwise
read_worktree_metadata() {
    local plan_path="$1"
    local branch worktree_path main_branch main_project lock_file

    # Extract the Worktree Info section (multi-line parsing, SC-5)
    local worktree_section
    worktree_section="$(sed -n '/^## Worktree Info/,/^## /p' "$plan_path" 2>/dev/null | sed '$d')"

    if [ -z "$worktree_section" ]; then
        return 1
    fi

    # Parse each field from the section
    branch="$(printf "%s" "$worktree_section" | grep 'Branch:' | sed 's/.*Branch: *//' | head -1)"
    worktree_path="$(printf "%s" "$worktree_section" | grep 'Worktree Path:' | sed 's/.*Worktree Path: *//' | head -1)"
    main_branch="$(printf "%s" "$worktree_section" | grep 'Main Branch:' | sed 's/.*Main Branch: *//' | head -1)"
    main_project="$(printf "%s" "$worktree_section" | grep 'Main Project:' | sed 's/.*Main Project: *//' | head -1)"
    lock_file="$(printf "%s" "$worktree_section" | grep 'Lock File:' | sed 's/.*Lock File: *//' | head -1)"

    # Return pipe-delimited values (SC-5)
    if [ -n "$branch" ] && [ -n "$worktree_path" ] && [ -n "$main_branch" ]; then
        printf "%s|%s|%s|%s|%s" "$branch" "$worktree_path" "$main_branch" "$main_project" "$lock_file"
        return 0
    fi

    return 1
}

# Perform squash merge to main branch
# Usage: do_squash_merge "source-branch" "main-branch" "commit-message"
do_squash_merge() {
    local source_branch="$1"
    local main_branch="$2"
    local commit_message="$3"

    echo "Squash merging $source_branch into $main_branch..."

    # Checkout main branch
    if ! git checkout "$main_branch" 2>&1; then
        echo "Failed to checkout $main_branch" >&2
        return 1
    fi

    # Squash merge
    if ! git merge --squash "$source_branch" 2>&1; then
        echo "Merge failed or has conflicts" >&2
        return 1
    fi

    # Commit
    if ! git commit -m "$commit_message" 2>&1; then
        echo "Commit failed" >&2
        return 1
    fi

    echo "Squash merge completed successfully"
    return 0
}

# Check if there are merge conflicts
# Usage: has_merge_conflicts
# Returns: 0 if conflicts exist, 1 otherwise
has_merge_conflicts() {
    git diff --name-only --diff-filter=U 2>/dev/null | grep -q .
}

# Get list of conflicted files
# Usage: conflicted_files=$(get_conflicted_files)
get_conflicted_files() {
    git diff --name-only --diff-filter=U 2>/dev/null
}

# Attempt interactive conflict resolution
# Usage: resolve_conflicts_interactive
# Returns: 0 if resolved, 1 if failed
resolve_conflicts_interactive() {
    local conflicts
    conflicts="$(get_conflicted_files)"

    if [ -z "$conflicts" ]; then
        return 0
    fi

    echo "Merge conflicts detected in:"
    echo "$conflicts"
    echo ""
    echo "Attempting automatic resolution..."

    # Try common resolution strategies
    local file
    for file in $conflicts; do
        echo "Resolving: $file"

        # Check if file can be auto-merged by taking "their" version
        # (This is a simple strategy; more complex resolution would go here)
        if git checkout --theirs "$file" 2>/dev/null; then
            git add "$file"
            echo "  Resolved using 'their' version"
        else
            echo "  Failed to resolve $file" >&2
        fi
    done

    # Check if any conflicts remain
    if has_merge_conflicts; then
        echo "Some conflicts could not be resolved automatically" >&2
        echo "Please resolve manually and run git add for resolved files" >&2
        return 1
    fi

    return 0
}

# Cleanup worktree, branch, and directory
# Usage: cleanup_worktree "worktree-path" "branch"
# Handles dirty worktrees with --force option (SC-6)
cleanup_worktree() {
    local worktree_path="$1"
    local branch="$2"
    local project_dir
    local worktree_basename

    worktree_basename="$(basename "$worktree_path")"

    echo "Cleaning up worktree..."

    # Remove worktree (try normal first, then force for dirty state, SC-6)
    if git worktree list | grep -q "$worktree_path"; then
        echo "Removing worktree: $worktree_path"
        # Try normal removal first
        if ! git worktree remove "$worktree_path" 2>/dev/null; then
            # Force removal for dirty worktrees
            echo "Worktree has uncommitted changes, using --force"
            git worktree remove --force "$worktree_path" 2>&1 || true
        fi
    fi

    # Remove directory if it still exists
    if [ -d "$worktree_path" ]; then
        echo "Removing directory: $worktree_path"
        rm -rf "$worktree_path"
    fi

    # Remove branch
    if git rev-parse --verify "$branch" >/dev/null 2>&1; then
        echo "Removing branch: $branch"
        git branch -D "$branch" 2>&1 || true
    fi

    echo "Cleanup completed"
}

# Get the main project directory from a worktree
# Usage: main_dir=$(get_main_project_dir)
get_main_project_dir() {
    local git_common_dir
    git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
    dirname "$git_common_dir"
}

# Get the main project's .pilot directory path
# Usage: main_pilot=$(get_main_pilot_dir)
# Returns: Absolute path to main project's .pilot directory
get_main_pilot_dir() {
    local main_project="$(get_main_project_dir)"
    echo "${main_project}/.pilot"
}

# Check if Git worktree is supported
# Usage: check_worktree_support
# Returns: 0 if supported, 1 if not
check_worktree_support() {
    git worktree --help >/dev/null 2>&1
}
