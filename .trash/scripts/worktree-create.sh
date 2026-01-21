#!/usr/bin/env bash
#
# worktree-create.sh
#
# Create a Git worktree for isolated development
#
# Usage: worktree-create.sh <branch_name> [base_branch]
#
# Arguments:
#   branch_name  - Name of the new branch to create
#   base_branch  - Base branch to create from (default: current branch)
#
# Output:
#   WORKTREE_PATH - Absolute path to the created worktree
#
# Returns:
#   0 on success, 1 on failure
#

# Source common environment library
# shellcheck source=../lib/env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/env.sh" ]]; then
    source "$SCRIPT_DIR/../lib/env.sh"
fi

set -o nounset
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Main function
worktree_create() {
    local branch_name="$1"
    local base_branch="${2:-}"
    local project_root=""

    # Get project root
    project_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -z "$project_root" ]; then
        echo -e "${RED}Error: Not in a Git repository${NC}" >&2
        return 1
    fi

    # Validate branch name
    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Branch name is required${NC}" >&2
        return 1
    fi

    # Sanitize branch name for Git and filesystem
    # Git branch names: cannot contain ~^: or spaces, must start with alphanumeric
    local branch_safe
    branch_safe="$(echo "$branch_name" | sed -E 's/[^a-zA-Z0-9._-]+/_/g' | sed -E 's/^[._]+//')"

    # Use sanitized branch name
    branch_name="$branch_safe"

    # Determine base branch
    if [ -z "$base_branch" ]; then
        base_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")"
    fi

    # Calculate worktree path
    local worktree_rel_path="../claude-pilot-wt-${branch_safe}"
    local worktree_abs_path=""

    # Check if worktree already exists
    worktree_abs_path="$(cd "$project_root" && cd "$worktree_rel_path" && pwd 2>/dev/null)"

    if [ -d "$worktree_abs_path" ]; then
        echo -e "${YELLOW}Warning: Worktree already exists at: $worktree_abs_path${NC}" >&2

        # Ask if user wants to remove it (non-interactive: auto-remove)
        echo "Removing existing worktree and branch..."
        git worktree remove "$worktree_abs_path" 2>/dev/null || rm -rf "$worktree_abs_path"

        # Also delete the branch if it exists
        if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; then
            git branch -D "$branch_name" 2>/dev/null || true
        fi

        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to remove existing worktree${NC}" >&2
            return 1
        fi

        echo -e "${GREEN}✓ Existing worktree and branch removed${NC}"
    fi

    # Create worktree
    echo "Creating worktree for branch: $branch_name"
    echo "Base branch: $base_branch"
    echo "Worktree path: $worktree_rel_path"

    # Create worktree with new branch
    git worktree add "$worktree_rel_path" -b "$branch_name" "$base_branch"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create worktree${NC}" >&2
        return 1
    fi

    # Get absolute path
    worktree_abs_path="$(cd "$project_root" && cd "$worktree_rel_path" && pwd)"

    echo -e "${GREEN}✓ Worktree created successfully${NC}"
    echo "WORKTREE_PATH=$worktree_abs_path"
    echo "WORKTREE_BRANCH=$branch_name"

    # Return absolute path
    echo "$worktree_abs_path"

    return 0
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    worktree_create "$@"
fi
