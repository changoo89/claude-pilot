---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*), Task
---

# /03_close

_Finalize plan by moving to done and creating git commit._

## Core Philosophy

**Verification Required**: All SCs complete with evidence | **Traceability**: Preserve plan with results | **Default commit**: Auto-git commit (skip with `no-commit`)

---

## Step 1: Load Plan

```bash
PLAN_PATH="$(find .pilot/plan/in_progress -name "*.md" -type f 2>/dev/null | head -1)"

if [ -z "$PLAN_PATH" ]; then
    echo "❌ No plan in progress"
    exit 1
fi

echo "✓ Plan: $PLAN_PATH"
```

---

## Step 2: Verify All SCs Complete

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

## Step 3: Verify Evidence

```bash
grep -A1 "Verify:" "$PLAN_PATH" | while read cmd; do
    [[ "$cmd" =~ ^(test|grep|\[) ]] && eval "$cmd" 2>/dev/null || true
done
```

---

## Step 4: Move Plan to Done

```bash
TIMESTAMP="$(date +%Y%m%d)"
DONE_DIR=".pilot/plan/done/${TIMESTAMP}"
mkdir -p "$DONE_DIR"
mv "$PLAN_PATH" "$DONE_DIR/"
echo "✓ Plan moved to done"
```

---

## Step 5: Archive State & Git Commit

```bash
# Archive state
STATE_FILE=".pilot/state/continuation.json"
if [ -f "$STATE_FILE" ]; then
    mkdir -p .pilot/state/archive
    cp "$STATE_FILE" ".pilot/state/archive/$(date +%Y%m%d_%H%M%S)_continuation.json"
    rm "$STATE_FILE"
fi

# Git commit (skip with no-commit)
if [ "$1" != "no-commit" ]; then
    git add .pilot/plan/done/ .pilot/state/archive/
    git commit -m "close(plan): $(basename "$PLAN_PATH" .md)" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
fi
```

---

## Related Skills

**managing-continuation**: State cleanup | **git-master**: Commit creation

---

**⚠️ CRITICAL**: Only this command moves plans to done. Plans stay in in_progress/ after `/02_execute`.
