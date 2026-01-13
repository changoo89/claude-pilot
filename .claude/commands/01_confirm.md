---
description: Confirm and move a plan to in-progress state (ready for execution)
argument-hint: "[plan_path|work_name] --no-review - optional plan path or work name; --no-review skips auto-review"
allowed-tools: Read, Glob, Grep, Write, Bash(*)
---

# /01_confirm

_Move a pending plan to in-progress state, ready for execution with /02_execute._

---

## Core Philosophy

- **Standalone**: The output must be sufficient without reading chat history.
- **Evidence-driven**: Convert vague intent into verifiable acceptance criteria.
- **Executable**: Include concrete steps, commands, and checklists.
- **Merge-aware**: If prior plans exist, inherit and reconcile them explicitly.

---

## Inputs

- Plan file path (optional - if not provided, uses most recent pending plan)
- `--no-review` flag (optional - skips auto-review)

---

## Step 0: Locate the Plan

### 0.1 Determine Plan Path

Priority order:

1. Explicit path from `"$ARGUMENTS"`
2. Work name from `"$ARGUMENTS"` → find matching plan
3. Most recent file in `.pilot/plan/pending/`

```bash
# Find most recent pending plan if no argument
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1tr .pilot/plan/pending/*.md 2>/dev/null | head -1)"
fi

if [ -z "$PLAN_PATH" ]; then
    echo "No pending plan found."
    echo "Run /00_plan first to create a plan."
    exit 1
fi
```

---

## Step 1: Read and Validate Plan

### 1.1 Read Plan Content

Read the plan file and verify:
- [ ] User Requirements section exists
- [ ] Execution Plan with 5 phases exists
- [ ] Acceptance Criteria defined
- [ ] Test Plan included

### 1.2 Validate Completeness

If any required sections are missing:
- Inform user of missing sections
- Ask if they want to proceed with incomplete plan
- If yes, note gaps in plan

---

## Step 2: Create In-Progress Workspace

### 2.1 Create RUN_ID

```bash
PENDING_BASENAME="$(basename "$PLAN_PATH" .md)"

# If already has timestamp prefix, reuse it
if printf "%s" "$PENDING_BASENAME" | grep -qE '^[0-9]{8}_[0-9]{6}_'; then
    RUN_ID="$PENDING_BASENAME"
else
    TS="$(date +%Y%m%d_%H%M%S)"
    RUN_ID="${TS}_${PENDING_BASENAME}"
fi

RUN_DIR=".pilot/plan/in_progress/${RUN_ID}"
mkdir -p "$RUN_DIR"
```

### 2.2 Move Plan

```bash
mv "$PLAN_PATH" "$RUN_DIR/plan.md"
echo "Plan moved to: $RUN_DIR/plan.md"
```

### 2.3 Record Active Pointer

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

printf "%s" "$RUN_DIR" > "$ACTIVE_PTR"
echo "Active plan recorded for branch: $BRANCH"
```

---

## Step 3: Auto-Review (Optional)

> **Principle**: Plan validation before execution. No user intervention needed.

### 3.1 Skip Check

If `"$ARGUMENTS"` contains `--no-review`, skip to Step 4.

### 3.2 Auto-Invoke Review

Use Skill tool to invoke review:

```
Skill: 90_review
Args: (no args - auto-detect in-progress plan)
```

This automatically:
1. Loads the plan from `$RUN_DIR/plan.md`
2. Runs mandatory reviews
3. Runs extended reviews by type
4. Reports findings

### 3.3 Review Results

| Result | Action |
|--------|--------|
| Pass (Critical=0) | Ready for execution |
| Needs Revision | Present issues, update plan |

---

## Step 4: Create Todo List

### 4.1 Generate Todos from Plan

Parse the Execution Plan section and create actionable todos:

```bash
# Create todos based on plan phases
# Each checkbox becomes a todo item
```

### 4.2 Todo Format

```
- Phase 1: Discovery & Alignment
  - [ ] Identify relevant code paths
  - [ ] Confirm integration points
- Phase 2: Design
  - [ ] Draft approach
  - [ ] Define success validation
...
```

---

## Success Criteria

- Plan moved from `pending/` to `in_progress/{RUN_ID}/plan.md`
- Active pointer created for current branch
- Optional review completed
- Ready for `/02_execute`

---

## Next Command

```
/02_execute
```

---

## References

- **Plan Template**: `.claude/templates/PRP.md.template`
- **Context Engineering**: `.claude/guides/context-engineering.md`
- **Ralph Loop TDD**: `.claude/guides/ralph-loop-tdd.md`
