# REFERENCE: Rapid Fix (Detailed Implementation)

> **Companion**: SKILL.md | **Purpose**: Detailed implementation reference for rapid bug fix workflow

---

## Detailed Step Implementation

### Step 1: Scope Validation (Detailed)

> **Purpose**: Reject complex tasks before plan generation
> **Algorithm**: Complexity score calculation (0.0-1.0 scale)

#### Complexity Score Components

**1. Input Length Check** (Weight: 0.3)
- Threshold: >200 characters
- Rationale: Long descriptions often indicate complex multi-faceted issues
- Example: "Fix authentication bug and add user profile page" (>200 chars)

**2. Keyword Detection** (Weight: 0.3)
- Keywords: `refactor`, `redesign`, `architecture`, `tradeoffs`, `design`, `system`
- Rationale: Architecture keywords indicate design decisions, not simple fixes
- Example: "Redesign authentication flow" → triggers architecture keyword

**3. File Count Detection** (Weight: 0.2)
- Threshold: >3 unique file paths
- Rationale: More files = larger blast radius
- Detection: `grep -oE '\w+\.\w+' | sort -u | wc -l`
- Example: "Fix bug in auth.ts, user.ts, and profile.ts" → 3 files (at threshold)

**4. Multiple Tasks Detection** (Weight: 0.2)
- Keywords: `and`, `then`, `also` (case-insensitive, with word boundaries)
- Rationale: Indicates sequential or parallel tasks
- Example: "Fix bug AND add tests" → multiple tasks

#### Rejection Output Format

When complexity score ≥0.5:

```
⚠️  Task too complex for /04_fix

This task appears to require multiple steps (estimated 4+ success criteria).

Reasons:
- Input length: 247 chars (>200 threshold)
- Keywords detected: architecture-related keywords
- Files mentioned: 5 files (>3 threshold)
- Multiple tasks detected

Use /00_plan instead for:
- Complex bug fixes
- Multi-file refactoring
- Architecture decisions
- Feature development

Example: /00_plan "Fix authentication bug and add user profile page"
```

#### When to Override

The complexity score is a guideline, not a hard rule. Override if:
- Task appears complex but is actually simple (false positive)
- User confirms they understand the scope
- Task has clear success criteria and minimal blast radius

**Override method**: Use `/00_plan` directly, bypassing `/04_fix`

---

### Step 2: Auto-Generate Minimal Plan (Detailed)

> **Purpose**: Create focused plan with 1-3 SCs for simple fixes

#### Plan Template Structure

The auto-generated plan follows this structure:

```markdown
# Fix: [BUG_DESCRIPTION]

> **Generated**: [TIMESTAMP] | **Work**: [PLAN_TITLE]

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | [TIME] | [BUG_DESCRIPTION] | Bug fix request |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix the reported bug

**Scope**:
- **In Scope**: Bug fix as described
- **Out of Scope**: Feature additions, refactoring

### Why (Context)

**Current Problem**: Bug reported in user input

**Business Value**: Fix critical bug affecting functionality

### How (Approach)

**Implementation Strategy**:
1. Analyze the bug
2. Implement fix with TDD
3. Verify with tests
4. Close with commit

### Success Criteria

- [ ] **SC-1**: Analyze bug and identify root cause
- [ ] **SC-2**: Implement fix with test coverage
- [ ] **SC-3**: Verify fix and close with commit

---

## Test Plan

| ID | Scenario | Expected | Type |
|----|----------|----------|------|
| TS-1 | Fix resolves bug | Bug no longer occurs | Integration |
| TS-2 | No regressions | Existing tests pass | Regression |

---

## Execution Plan

1. **SC-1**: Analyze bug (coder, 5 min)
2. **SC-2**: Implement fix (coder, 10 min)
3. **SC-3**: Verify and close (validator, 5 min)

---

**Plan Version**: 1.0
**Status**: Pending
```

#### Time Estimation Rationale

**SC-1**: Analyze bug (5 min)
- Bug analysis requires code examination
- Root cause identification
- Test case creation

**SC-2**: Implement fix (10 min)
- Red-Green-Refactor cycle
- Test coverage
- Code quality checks

**SC-3**: Verify and close (5 min)
- Integration test execution
- Git commit creation
- Plan archival

Total estimated time: 20 minutes

---

### Step 5: Execute Plan with TDD + Ralph Loop (Detailed)

> **Purpose**: Auto-execute by calling /02_execute with generated plan

#### Why Call `/02_execute` Directly?

**Consistency Benefits**:
1. **Unified execution behavior**: All plans execute through `/02_execute`
2. **State management**: Leverages existing continuation state system
3. **Ralph Loop integration**: Automatic iteration until quality gates pass
4. **Resumption support**: Compatible with `/continue` for incomplete work

**State Management Details**:
- **State file**: `.pilot/state/continuation.json`
- **Updated**: Automatically on each Ralph Loop iteration
- **Includes**: session_id, branch, plan_file, todos, iteration_count, max_iterations
- **Resumption**: `/continue` reads state and continues from last checkpoint

#### Execution Flow

```
/04_fix generates plan
       ↓
Sets PILOT_FIX_MODE=1
       ↓
Invokes /02_execute
       ↓
/02_execute:
  1. Reads plan from $PLAN_PATH
  2. Creates/updates continuation state
  3. Executes SCs with TDD + Ralph Loop
  4. Updates state on each iteration
  5. Returns when complete or max iterations reached
       ↓
/04_fix checks completion
       ↓
Prompts user for confirmation
       ↓
Calls /03_close if confirmed
```

#### Environment Variables

**PILOT_FIX_MODE=1**:
- Indicates execution initiated from `/04_fix`
- Enables special handling in `/02_execute`
- Skips plan detection (plan already generated)

**PILOT_FIX_PLAN=$PLAN_PATH**:
- Absolute path to generated fix plan
- Used by `/02_execute` to read plan
- Ensures correct plan is executed

#### Integration with Ralph Loop

The `/02_execute` command runs Ralph Loop:
1. **Iteration 1**: Coder implements fix
2. **Verification**: Tests, type-check, lint
3. **If failures**: Coder fixes issues
4. **State update**: After each iteration, update continuation.json
5. **Max iterations**: 7 (configurable via MAX_ITERATIONS)
6. **Completion**: When all quality gates pass or max iterations reached

#### Continuation State Management

**State File Format** (`continuation.json`):
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

**State Update Lifecycle**:
1. **Initial**: Created by `/02_execute` on first execution
2. **Iteration**: After each Ralph Loop iteration
3. **Completion**: When all todos complete
4. **Cleanup**: Deleted by `/03_close` after commit

---

### Step 6: Verify Completion (Detailed)

> **Purpose**: Check if all SCs completed before auto-close

#### Completion Check Algorithm

**1. Read State File**:
```bash
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"
```

**2. Extract Incomplete Todos**:
```bash
INCOMPLETE_TODOS="$(cat "$STATE_FILE" | jq -r '.todos[] | select(.status != "complete") | .id')"
INCOMPLETE_COUNT="$(echo "$INCOMPLETE_TODOS" | grep -c '^' || echo 0)"
```

**3. Branch Logic**:
- **If INCOMPLETE_COUNT > 0**: Show warning, suggest `/continue`, exit 0
- **If INCOMPLETE_COUNT = 0**: Show success message, proceed to Step 7

#### Incomplete State Output

```
⚠️  Work incomplete: 2 todos remaining

→ Use /continue to resume work
```

#### Complete State Output

```
✅ All todos complete
```

---

### Step 7: User Confirmation Before Auto-Close (Detailed)

> **Purpose**: User must approve changes before commit (SC-4)

#### Confirmation Flow

**1. Show Diff**:
```bash
git diff HEAD
```

This shows all changes made during fix:
- Modified files
- Added lines (green)
- Removed lines (red)
- Context around changes

**2. Display Header**:
```
════════════════════════════════════════════════════════════
📋 Review Changes Before Commit
════════════════════════════════════════════════════════════

[git diff output]

════════════════════════════════════════════════════════════

Commit these changes? (y/n)

Options:
  y) Yes - commit changes and close plan
  n) No - keep changes but don't commit

→ If 'n': Use /continue to resume, or /03_close --no-commit to skip commit
```

**3. Default Behavior**:
- **COMMIT_CONFIRM=false** (default): Requires explicit confirmation
- **COMMIT_CONFIRM=true**: Proceed with commit automatically

**Setting Confirmation**:
```bash
export COMMIT_CONFIRM=true
```

Or in command:
```bash
COMMIT_CONFIRM=true /04_fix "Fix null pointer in auth.ts"
```

#### If User Aborts (COMMIT_CONFIRM=false)

```
ℹ️  Commit confirmation required
   Set COMMIT_CONFIRM=true to proceed with commit

→ Plan complete but not closed. Run:
   COMMIT_CONFIRM=true /03_close
```

**State**: Plan remains in `.pilot/plan/in_progress/`, continuation state preserved

---

### Step 8: Auto-Close on Success (Detailed)

> **Purpose**: Archive plan and create commit (if user confirmed)

#### Close Process (When COMMIT_CONFIRM=true)

**1. Move Plan to Done**:
```bash
mkdir -p "$PROJECT_ROOT/.pilot/plan/done"
DONE_PATH="$PROJECT_ROOT/.pilot/plan/done/$(basename "$PLAN_PATH")"
mv "$PLAN_PATH" "$DONE_PATH"
```

**2. Clear Active Pointer**:
```bash
rm -f "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"
```

**3. Generate Commit Message**:
```bash
TITLE="Fix: $(echo "$BUG_DESCRIPTION" | head -c 50)"
COMMIT_MSG="${TITLE}

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Commit Message Format**:
- **Title**: First 50 chars of bug description
- **Co-Authored-By**: Standard attribution
- **No body**: Single-commit fix (description is enough)

**4. Create Git Commit**:
```bash
cd "$PROJECT_ROOT" || exit 1
git add -A
git commit -m "$COMMIT_MSG"
```

**5. Cleanup**:
```bash
rm -f "$STATE_FILE"
```

Deletes continuation state file since work is complete.

**6. Success Output**:
```
→ Closing plan...
✓ Plan archived: .pilot/plan/done/fix_20260118_235333.md
✓ Git commit created
✓ Continuation state cleaned up

✅ Fix complete!
```

#### If Not Confirmed (COMMIT_CONFIRM=false)

```
→ Plan not closed (awaiting confirmation)
```

**State**: Plan remains in `.pilot/plan/in_progress/`, continuation state preserved

---

## Continuation Support

### When Work is Incomplete

**Triggers**:
- Ralph Loop reached max iterations (7)
- User interrupted execution
- System error during execution

**Continuation State**:
- **Preserved in**: `.pilot/state/continuation.json`
- **Contains**: session_id, branch, plan_file, todos, iteration_count, max_iterations
- **Resumable**: Via `/continue` command

### Resume Workflow

**User Command**:
```bash
/continue
```

**What Happens**:
1. Reads continuation state from `.pilot/state/continuation.json`
2. Loads incomplete plan
3. Continues from last checkpoint (iteration_count)
4. Executes remaining todos
5. Updates state on each iteration

**Max Iterations Safety**:
- **Default**: 7 Ralph Loop iterations
- **Override**: `export MAX_ITERATIONS=10`
- **Manual intervention**: After max iterations, human review required

---

## Error Handling

### Scope Validation Failures

**Error**: Task too complex (complexity ≥0.5)
**Action**: Reject with suggestion to use `/00_plan`
**Exit code**: 1

### Plan Creation Failures

**Error**: Plan file cannot be created
**Causes**: Permission denied, disk full, invalid path
**Action**: Report error and exit gracefully
**Exit code**: 1

### Execution Failures

**Error**: `/02_execute` returns non-zero
**Causes**: Coder blocked, max iterations, system error
**Action**: Preserve state, suggest `/continue`
**Exit code**: 0 (state preserved for resumption)

### Commit Failures

**Error**: Git commit fails
**Causes**: Merge conflict, hook failure, permission denied
**Action**: Report error, preserve plan and state
**Exit code**: 1

---

## Best Practices

### When to Use /04_fix

**Good Candidates**:
- One-line fixes: "Fix typo in README.md"
- Simple validation: "Add email validation to registration form"
- Minor bug fixes: "Fix null pointer in auth.ts:45"
- Typos: "Fix spelling error in error message"

**Poor Candidates** (use `/00_plan` instead):
- Feature additions: "Add user profile page"
- Refactoring: "Refactor authentication system"
- Architecture changes: "Switch to Redis for caching"
- Multi-file changes: "Update auth, user, and profile modules"

### Scope Validation Tips

**Keep Input Concise**:
- ✅ "Fix null pointer in auth.ts:45"
- ❌ "Fix authentication bug where null pointer causes crash when user logs in with invalid credentials"

**Avoid Architecture Keywords**:
- ✅ "Fix input validation bug"
- ❌ "Redesign authentication flow"

**Focus on Single Bug**:
- ✅ "Fix logout not working"
- ❌ "Fix logout and add session timeout AND update login page"

### Commit Message Guidelines

**Good Commit Messages**:
- "Fix: Null pointer in auth.ts on invalid user input"
- "Fix: Logout button redirects to wrong page"
- "Fix: Email validation rejects valid addresses"

**Bad Commit Messages** (auto-generated, trimmed to 50 chars):
- "Fix: Update authentication and user prof..." (too vague)
- "Fix: Various bug fixes" (not specific)

---

## Testing /04_fix

### Manual Testing

**Test Simple Fix**:
```bash
/04_fix "Fix typo in README.md"
```
Expected: Creates plan, executes, confirms, commits

**Test Complex Task**:
```bash
/04_fix "Refactor authentication system"
```
Expected: Rejects with suggestion to use `/00_plan`

### Verification Checklist

After running `/04_fix`:
- [ ] Plan created in `.pilot/plan/pending/`
- [ ] Plan moved to `.pilot/plan/in_progress/`
- [ ] `/02_execute` invoked with correct plan
- [ ] Continuation state created/updated
- [ ] User confirmation prompt shown
- [ ] If confirmed: Plan archived, commit created
- [ ] If not confirmed: Plan preserved for resumption
- [ ] Continuation state cleaned up on success

---

**Reference Version**: claude-pilot 4.2.0
**Last Updated**: 2026-01-19
