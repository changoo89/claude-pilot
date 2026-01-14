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
    # ... squash merge, cleanup worktree, move plan to done in main repo
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

> **CRITICAL**: Use Task tool to invoke Documenter Agent for context isolation.

> **Why Agent?**: Documenter Agent runs in **isolated context window** (~30K tokens internally). All documentation analysis and updates happen there. Only summary returns here, preserving main orchestrator context.

### 5.1 Task Invocation Syntax

```
Task:
  subagent_type: documenter
  prompt: |
    Update documentation after plan completion:

    RUN_ID: {RUN_ID}
    Plan Path: {DONE_PATH}

    Changed files (from git diff):
    {CHANGED_FILES}

    Update:
    - CLAUDE.md (Tier 1) - if project-level changes
    - Component CONTEXT.md (Tier 2) - if component changes
    - docs/ai-context/ - always update project-structure.md, system-integration.md
    - Plan file - add execution summary

    Archive implementation artifacts:
    - test-scenarios.md
    - coverage-report.txt
    - ralph-loop-log.md

    Return summary only.
```

### 5.2 Context Flow Diagram

```
/03_close (Orchestrator - Main Context)
    │
    ├─► Read plan (1K tokens)
    │
    ├─► Task: Documenter Agent (Isolated Context)
    │       ├─► [30K tokens consumed internally]
    │       ├─► Reads: All changed files, existing docs
    │       ├─► Updates: CLAUDE.md, CONTEXT.md, docs/ai-context/
    │       ├─► Archives: test-scenarios.md, coverage-report.txt
    │       └─► Returns: "Documentation updated (5 files)" (0.5K)
    │
    └─► Process summary (0.5K)

Total Main Context: ~2K tokens (vs 35K+ without isolation)
```

### 5.3 Process Documenter Results

#### Expected Output Format: `<DOCS_COMPLETE>`

```markdown
## Documentation Update Summary

### Updates Complete ✅
- CLAUDE.md: Updated (Project Structure, 3-Tier Documentation links)
- docs/ai-context/: Updated (project-structure.md, system-integration.md)
- Tier 2 CONTEXT.md: Updated (src/components/CONTEXT.md)
- Plan file: Updated with execution summary

### Files Updated
- `CLAUDE.md`: Added new feature to Project Structure
- `docs/ai-context/project-structure.md`: Added src/newfeature/
- `src/components/CONTEXT.md`: Added newfile.ts

### Artifacts Archived
- `.pilot/plan/done/{RUN_ID}/test-scenarios.md`
- `.pilot/plan/done/{RUN_ID}/coverage-report.txt`
- `.pilot/plan/done/{RUN_ID}/ralph-loop-log.md`

### Next Steps
- None (documentation up to date)
```

### 5.4 Skip Delegation

If `--no-docs` specified:
- Skip Documenter Agent delegation
- Note in commit message: "Documentation skipped (--no-docs)"

---

## Step 6: Documentation Checklist (Manual - Use Agent Instead)

> **NOTE**: This step is preserved for manual review. For automatic updates, use **Step 5: Delegate to Documenter Agent** instead.

> **Before committing**: Ensure documentation is synchronized with implementation

### 5.1 Check Documentation Updates

Read the plan to identify affected components/features, then verify:

```bash
# Check which tiers need updates based on plan scope
PLAN_SCOPE=$(grep "## Scope" "$ACTIVE_PLAN_PATH" 2>/dev/null || echo "")

# Determine affected tiers
if echo "$PLAN_SCOPE" | grep -q "CLAUDE.md\|Project Structure"; then
    TIER1_NEEDED=true
fi
if echo "$PLAN_SCOPE" | grep -q "src/\|lib/\|components/"; then
    TIER2_NEEDED=true
fi
if echo "$PLAN_SCOPE" | grep -q "features/\|deep nested"; then
    TIER3_NEEDED=true
fi
```

### 5.2 Verify Document Sizes

Check if any documentation exceeds size thresholds:

```bash
# Tier 1: CLAUDE.md (max 300 lines)
if [ -f "CLAUDE.md" ]; then
    LINES=$(wc -l < CLAUDE.md)
    if [ "$LINES" -gt 300 ]; then
        echo "⚠️ CLAUDE.md exceeds 300 lines (current: $LINES)"
        echo "Consider moving detailed sections to docs/ai-context/"
    fi
fi

# Tier 2/3: CONTEXT.md files (Tier 2: 200 lines, Tier 3: 150 lines)
find . -name "CONTEXT.md" -type f | while read -r ctx_file; do
    LINES=$(wc -l < "$ctx_file")
    DEPTH=$(echo "$ctx_file" | tr '/' '\n' | wc -l)

    if [ $DEPTH -ge 3 ] || [[ "$ctx_file" =~ features/ ]]; then
        # Tier 3
        if [ "$LINES" -gt 150 ]; then
            echo "⚠️ $ctx_file exceeds 150 lines (current: $LINES)"
        fi
    else
        # Tier 2
        if [ "$LINES" -gt 200 ]; then
            echo "⚠️ $ctx_file exceeds 200 lines (current: $LINES)"
        fi
    fi
done
```

### 5.3 Prompt for Documentation Sync

If documentation is outdated or exceeds thresholds:

```
📋 Documentation Review Required:

Based on the completed work, the following documentation updates may be needed:

- [ ] Tier 1 (CLAUDE.md): Project-level changes
- [ ] Tier 2 (Component CONTEXT.md): Component architecture changes
- [ ] Tier 3 (Feature CONTEXT.md): Feature implementation details
- [ ] Document size management: Apply compression/split if needed

Would you like to run /91_document to synchronize documentation now?
- Enter 'y' to run /91_document auto-sync
- Enter 's' to skip documentation (will note in commit)
- Enter 'q' to abort and run manually later
```

### 5.4 Auto-Trigger /91_document

If user accepts or if coverage/tests/documentation requirements are met:

```bash
# Auto-trigger if all quality gates pass
if [ -n "$AUTO_SYNC_DOCS" ]; then
    echo "Running /91_document auto-sync..."
    # Invoke documentation sync skill
fi
```

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

# Prompt for external repos
echo "Were any external repositories modified? (paths space-separated, or Enter to skip):"
read -r EXTERNAL_REPOS_INPUT

for EXTERNAL_REPO in $EXTERNAL_REPOS_INPUT; do
    if [ -d "$EXTERNAL_REPO" ] && (cd "$EXTERNAL_REPO" && git rev-parse --git-dir > /dev/null 2>&1); then
        REPOS_TO_COMMIT+=("$EXTERNAL_REPO")
    fi
done
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
