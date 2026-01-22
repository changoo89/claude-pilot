# REFERENCE: Rapid Fix (Detailed Implementation)

> **Companion**: SKILL.md | **Purpose**: Detailed implementation reference for rapid bug fix workflow

---

## Detailed Step Implementation

### Step 1: Scope Validation

**Purpose**: Reject complex tasks before plan generation

**Complexity Score Algorithm** (0.0-1.0 scale):

| Component | Weight | Threshold | Rationale |
|-----------|--------|-----------|-----------|
| Input length | 0.3 | >200 chars | Long descriptions indicate multi-faceted issues |
| Keywords | 0.3 | architecture terms | `refactor`, `redesign`, `architecture`, `tradeoffs`, `design`, `system` |
| File count | 0.2 | >3 files | More files = larger blast radius |
| Multiple tasks | 0.2 | `and`, `then`, `also` | Indicates sequential/parallel tasks |

**Rejection threshold**: Score ≥0.5

**Rejection output**:
```
⚠️  Task too complex for /04_fix

Reasons:
- Input length: 247 chars (>200 threshold)
- Keywords detected: architecture-related keywords
- Files mentioned: 5 files (>3 threshold)

Use /00_plan instead for complex bug fixes, multi-file refactoring, architecture decisions.
```

---

### Step 2: Auto-Generate Minimal Plan

**Plan sections**: User Requirements, PRP Analysis (What/Why/How), Success Criteria (SC-1/SC-2/SC-3), Test Plan, Execution Plan

**Success Criteria template**:
- SC-1: Analyze bug and identify root cause (5 min)
- SC-2: Implement fix with test coverage (10 min)
- SC-3: Verify fix and close with commit (5 min)

---

### Step 5: Execute Plan with TDD + Ralph Loop

**Why call `/02_execute` directly?**

| Benefit | Description |
|---------|-------------|
| Unified execution | All plans execute through `/02_execute` |
| State management | Leverages existing continuation state system |
| Ralph Loop integration | Automatic iteration until quality gates pass |
| Resumption support | Compatible with `/continue` for incomplete work |

**Execution flow**:
```
/04_fix generates plan
       ↓
Sets PILOT_FIX_MODE=1
       ↓
Invokes /02_execute
       ↓
/02_execute executes SCs with TDD + Ralph Loop
       ↓
Updates state on each iteration
       ↓
Returns when complete or max iterations reached
```

**Environment variables**:
- `PILOT_FIX_MODE=1`: Indicates execution from `/04_fix`
- `PILOT_FIX_PLAN=$PLAN_PATH`: Absolute path to generated plan

**Continuation state format** (`continuation.json`):
```json
{
  "version": "1.0",
  "session_id": "uuid",
  "branch": "main",
  "plan_file": ".pilot/plan/in_progress/fix_20260118_235333.md",
  "todos": [
    {"id": "SC-1", "status": "complete", "iteration": 1},
    {"id": "SC-2", "status": "in_progress", "iteration": 0}
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-18T10:30:00Z"
}
```

**State lifecycle**:
1. Created by `/02_execute` on first execution
2. Updated after each Ralph Loop iteration
3. Deleted by `/03_close` after commit

---

### Step 6: Verify Completion

**Completion check algorithm**:
```bash
# 1. Read state file
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"

# 2. Extract incomplete todos
INCOMPLETE_TODOS="$(cat "$STATE_FILE" | jq -r '.todos[] | select(.status != "complete") | .id')"
INCOMPLETE_COUNT="$(echo "$INCOMPLETE_TODOS" | grep -c '^' || echo 0)"

# 3. Branch logic
if [ $INCOMPLETE_COUNT -gt 0 ]; then
  echo "⚠️  Work incomplete: $INCOMPLETE_COUNT todos remaining"
  echo "→ Use /continue to resume work"
  exit 0
else
  echo "✅ All todos complete"
fi
```

---

### Step 7: User Confirmation Before Auto-Close

**Flow**: Show `git diff HEAD` → Prompt (y/n) → If yes: commit and close, If no: preserve plan

**Environment variable**:
- `COMMIT_CONFIRM=false` (default): Requires explicit confirmation
- `COMMIT_CONFIRM=true`: Auto-commit without prompt

---

### Step 8: Auto-Close on Success

**Steps** (when `COMMIT_CONFIRM=true`):
1. Move plan to `.pilot/plan/done/`
2. Clear active pointer
3. Generate commit message: "Fix: [first 50 chars]\n\nCo-Authored-By: Claude <noreply@anthropic.com>"
4. Create git commit: `git add -A && git commit -m "$COMMIT_MSG"`
5. Cleanup state file

---

## Continuation Support

**Triggers**: Ralph Loop max iterations (7), user interrupt, system error

**Resume**: `/continue` reads `.pilot/state/continuation.json`, continues from last checkpoint

**Max iterations**: Default 7, override with `export MAX_ITERATIONS=10`

---

## Error Handling

| Error Type | Cause | Action | Exit Code |
|-----------|-------|--------|-----------|
| Scope validation | Task too complex (≥0.5) | Reject with `/00_plan` suggestion | 1 |
| Plan creation | Permission denied, disk full | Report error and exit | 1 |
| Execution | Coder blocked, max iterations | Preserve state, suggest `/continue` | 0 |
| Commit | Merge conflict, hook failure | Preserve plan and state | 1 |

---

## Best Practices

### When to Use /04_fix

| Category | Good (use /04_fix) | Poor (use /00_plan) |
|----------|-------------------|---------------------|
| Scope | "Fix typo in README.md" | "Add user profile page" |
| Complexity | "Fix null pointer in auth.ts:45" | "Refactor authentication system" |
| Files | Single file changes | "Update auth, user, profile modules" |

### Scope Validation Tips

| Guideline | Good | Bad |
|-----------|------|-----|
| Concise | "Fix null pointer in auth.ts:45" | "Fix authentication bug where null pointer causes crash..." |
| No architecture | "Fix input validation bug" | "Redesign authentication flow" |
| Single bug | "Fix logout not working" | "Fix logout AND add timeout AND update login" |

---

## Testing /04_fix

**Test simple fix**: `/04_fix "Fix typo in README.md"` (should succeed)
**Test complex task**: `/04_fix "Refactor authentication system"` (should reject)

**Verification checklist**: Plan created → moved to in_progress → `/02_execute` invoked → state created/updated → confirmation prompt → if yes: plan archived + commit created → state cleaned up

---

**Reference Version**: claude-pilot 4.4.11
**Last Updated**: 2026-01-22
