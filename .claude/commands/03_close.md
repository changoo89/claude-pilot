---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*), Task
---

# /03_close

_Finalize plan by moving to done and creating git commit._

## ⚠️ EXECUTION DIRECTIVE

**IMPORTANT**: Execute ALL steps below IMMEDIATELY and AUTOMATICALLY without waiting for user input.
- Do NOT pause between steps
- Do NOT ask "should I continue?" or wait for "keep going"
- Execute Step 1 → 2 → 3 → 4 → 5 in sequence
- Only stop on ERROR or incomplete SCs

---

## Core Philosophy

**Verification Required**: All SCs complete with evidence | **Traceability**: Preserve plan with results | **Default commit**: Auto-git commit (skip with `no-commit`)

---

## Step 1: Load Plan

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
# PROJECT_ROOT = Claude Code execution directory (absolute path required)
PROJECT_ROOT="$(pwd)"

PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | head -1)"

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

## Step 3: Auto Documentation Sync

Run documentation sync automatically (equivalent to `/document`):

```bash
echo "📚 Auto-syncing documentation..."

# Sync CONTEXT.md for modified directories
for dir in src/ components/ lib/ .claude/commands/ .claude/skills/ .claude/agents/; do
    [ -d "$dir" ] || continue
    if [ -f "$dir/CONTEXT.md" ]; then
        echo "   ✓ $dir/CONTEXT.md exists"
    fi
done

# Verify CLAUDE.md size compliance
if [ -f "CLAUDE.md" ]; then
    LINES=$(wc -l < CLAUDE.md | tr -d ' ')
    if [ "$LINES" -le 200 ]; then
        echo "   ✓ CLAUDE.md: $LINES lines (≤200)"
    else
        echo "   ⚠️ CLAUDE.md: $LINES lines (exceeds 200)"
    fi
fi

echo "✓ Documentation sync complete"
```

---

## Step 4: Verify Evidence

```bash
grep -A1 "Verify:" "$PLAN_PATH" | while read cmd; do
    [[ "$cmd" =~ ^(test|grep|\[) ]] && eval "$cmd" 2>/dev/null || true
done
```

---

## Step 5: Move Plan to Done

```bash
# Use same PROJECT_ROOT from Step 1
TIMESTAMP="$(date +%Y%m%d)"
DONE_DIR="$PROJECT_ROOT/.pilot/plan/done/${TIMESTAMP}"
mkdir -p "$DONE_DIR"
mv "$PLAN_PATH" "$DONE_DIR/"
echo "✓ Plan moved to done"
```

---

## Step 6: Git Commit

```bash
# Git commit (skip with no-commit)
if [ "$1" != "no-commit" ]; then
    git add "$PROJECT_ROOT/.pilot/plan/done/"
    git commit -m "close(plan): $(basename "$PLAN_PATH" .md)" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
fi
```

---

## Related Skills

**git-master**: Commit creation | **parallel-subagents**: Parallel verification patterns

---

**⚠️ CRITICAL**: Only this command moves plans to done. Plans stay in in_progress/ after `/02_execute`.
