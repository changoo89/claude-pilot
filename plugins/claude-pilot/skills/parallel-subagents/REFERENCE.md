# REFERENCE: Parallel Teammates (Agent Teams)

> **Detailed patterns, examples, and troubleshooting for parallel teammate execution in Agent Teams**

---

## Dependency Analysis

### File Overlap Check

```bash
# Extract files from SC descriptions
sc_1_files=$(echo "$SC_1" | grep -oE 'src/[^ ]+' | sort -u)
sc_2_files=$(echo "$SC_2" | grep -oE 'src/[^ ]+' | sort -u)

# Check for overlap
if [ -n "$(comm -12 <(echo "$sc_1_files") <(echo "$sc_2_files"))" ]; then
  echo "⚠️  SC-1 and SC-2 share files - execute sequentially"
fi
```

### Dependency Keyword Check

```bash
# Look for dependency indicators
if echo "$SC_2" | grep -qiE "after|depends|requires|follows"; then
  echo "⚠️  SC-2 has dependencies - execute after SC-1"
fi
```

### ParallelGroup Annotation

```markdown
## Execution Plan
**ParallelGroup-1**: SC-1, SC-2, SC-3 (independent)
**SequentialGroup-1**: SC-4 (depends on SC-1)
**ParallelGroup-2**: SC-5, SC-6 (independent)
```

## Coordination

### Result Integration

**Pattern**: Team Lead aggregates from shared Task List
```markdown
# Team Lead monitors Task List
Task List:
- [x] SC-1: Auth service (sc1-impl) - COMPLETE
- [x] SC-2: User service (sc2-impl) - COMPLETE
- [x] SC-3: Data service (sc3-impl) - COMPLETE

# All complete → Team Lead aggregates results
# TaskCompleted hook already verified quality gates
```

### Conflict Detection

```bash
# TaskCompleted hook prevents conflicts via quality gates
# If multiple teammates modify same file (rare), git will detect:
git status
# modified: src/shared.ts (by sc1-impl and sc2-impl)

# Resolution: Check SC dependency analysis, may indicate planning error
```

### Todo State Management

**Automated via Shared Task List**:
```markdown
# Team Lead spawns teammates
Spawn teammate "sc1-impl" → Task List: SC-1 IN_PROGRESS
Spawn teammate "sc2-impl" → Task List: SC-2 IN_PROGRESS
Spawn teammate "sc3-impl" → Task List: SC-3 IN_PROGRESS

# Teammates mark done → Task List updates automatically
sc1-impl marks done → Task List: SC-1 COMPLETE
sc2-impl marks done → Task List: SC-2 COMPLETE
sc3-impl marks done → Task List: SC-3 COMPLETE

# Team Lead sees completion via Task List (no manual updates)
```

## Command-Specific Patterns

### /00_plan: Parallel Exploration

```markdown
## Step 1.1: Parallel Exploration via planning-team

### Task 1.1a: Codebase Exploration
Spawn teammate "codebase-explorer" with prompt:
  """
  You are an explorer (see @.claude/agents/explorer.md).
  Find relevant files for {task}:
  - Search for TypeScript/JavaScript files in src/
  - Look for existing patterns related to {domain}
  - Identify config files and test files
  Share findings with docs-researcher via Message.
  Mark task done when complete.
  """

### Task 1.1b: External Research
Spawn teammate "docs-researcher" with prompt:
  """
  You are a researcher (see @.claude/agents/researcher.md).
  Research external documentation for {task}:
  - Search for official docs, best practices
  - Find similar implementations/examples
  - Identify security considerations
  Share findings with codebase-explorer via Message.
  Mark task done when complete.
  """

# Team Lead operates in delegate mode (Shift+Tab)
# Teammates share findings via direct messaging
# Team Lead synthesizes for plan creation
```

### /02_execute: Multi-Coder SC Execution

```markdown
## Step 3.1: Dependency Analysis
[Analyze SC dependencies using file overlap + keyword check]

## Step 3.2a: Parallel Execution (Independent SCs)

### execution-team for independent SCs
Spawn teammate "sc1-impl" with prompt:
  """
  You are a $AGENT_TYPE (see @.claude/agents/$AGENT_TYPE.md).
  Execute SC-1 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task done. If blocked, message team lead.
  """

Spawn teammate "sc2-impl" with prompt:
  """
  You are a $AGENT_TYPE (see @.claude/agents/$AGENT_TYPE.md).
  Execute SC-2 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task done. If blocked, message team lead.
  """

**Note**: `$AGENT_TYPE` is selected per-SC in execute-plan Step 3 based on SC file paths and keywords (frontend-engineer, backend-engineer, coder, etc.)

## Step 3.2b: Sequential Execution (Dependent SCs)

### Sequential spawning for dependent SCs
Spawn teammate "sc1-impl" → Wait for completion → Spawn teammate "sc2-impl" (depends on SC-1)

## Step 3.3: Process Results
[Team Lead monitors Task List, aggregates when all complete]
[TaskCompleted hook auto-verified quality gates]
```

### /review: Multi-Angle Parallel Verification

```markdown
## Step 2: Multi-Angle Parallel Review via review-team

### Test Coverage Review
Spawn teammate "test-reviewer" with prompt:
  """
  You are a tester (see @.claude/agents/tester.md).
  Review plan: $PLAN_PATH
  Evaluate test coverage and verification:
  - Are all SCs verifiable?
  - Do verify commands exist?
  - Is coverage threshold ≥80%?
  Message other reviewers with findings.
  Output: TEST_PASS or TEST_FAIL with findings.
  Mark task done when complete.
  """

### Type Safety & Lint Review
Spawn teammate "quality-reviewer" with prompt:
  """
  You are a validator (see @.claude/agents/validator.md).
  Review plan: $PLAN_PATH
  Evaluate type safety and code quality.
  Message other reviewers with findings.
  Output: QUALITY_PASS or QUALITY_FAIL.
  Mark task done when complete.
  """

### Code Quality Review
Spawn teammate "deep-reviewer" with prompt:
  """
  You are a code-reviewer using Opus (see @.claude/agents/code-reviewer.md).
  Review plan: $PLAN_PATH
  Evaluate code quality and design.
  Message other reviewers with findings.
  Output: DEEP_PASS or DEEP_FAIL.
  Mark task done when complete.
  """

## Step 3: Aggregate Results
[Team Lead collects results from all reviewers]
[Any FAIL → BLOCKING, all PASS → proceed]
[Key enhancement: reviewers cross-reference via direct messaging]
```

## Anti-Patterns

### Bad Parallelization

```markdown
# ❌ WRONG: These conflict
Spawn teammate "auth-impl" with prompt: "Implement authentication in src/auth.ts"
Spawn teammate "auth-test" with prompt: "Add tests to src/auth.test.ts"
# Both modify src/auth.ts - execute sequentially instead
```

### Good Parallelization

```markdown
# ✅ CORRECT: Independent files
Spawn teammate "auth-impl" with prompt: "Implement auth service src/auth/auth.service.ts"
Spawn teammate "user-impl" with prompt: "Implement user service src/users/user.service.ts"
Spawn teammate "data-impl" with prompt: "Implement data service src/data/data.service.ts"
# All different files - safe to parallelize
```

## Performance

- **Independent tasks**: 50-70% faster
- **Verification tasks**: 60-70% faster
- **Review tasks**: 50-60% faster (with cross-review discussion enhancement)
- **Overhead**: ~5-10% for coordination

## Troubleshooting

**Issue**: Merge conflicts after parallel execution
**Solution**: Improve dependency analysis, check file overlap before launching

**Issue**: Sequential tasks executed in parallel
**Solution**: Check for dependency keywords (after, depends, requires, follows)

**Issue**: Partial results from parallel teammates
**Solution**: Monitor shared Task List, wait for all completions, TaskCompleted hook ensures quality

## Test Execution Concurrency

### Problem: Worker Explosion

When multiple tester teammates execute in parallel without worker limits:
- 6 parallel tester teammates × 16 default Jest workers = 96 processes
- Load Average spikes to 85+ (normal: 1-4)
- System becomes unresponsive

### Anti-Pattern: Unrestricted Parallel Test Execution

```bash
# DON'T: Multiple tester teammates with default workers
Spawn teammate "unit-tester" with prompt: "Run unit tests"
Spawn teammate "int-tester" with prompt: "Run integration tests"
Spawn teammate "e2e-tester" with prompt: "Run e2e tests"

# Result: 3 teammates × 16 workers = 48 processes (or worse)
```

### Correct Pattern: Test Type-Aware Concurrency

**Worker Limits** (from `@.claude/agents/tester.md`):
- **Jest**: `--maxWorkers=50%` (half of CPU cores)
- **Playwright E2E**: `--workers=1` (sequential)
- **Pytest**: No limit needed (process-based, already safe)
- **Go test**: No limit needed (goroutine-based, efficient)

**Test Type Detection** (from `execute-plan` Step 3):
- **E2E/Integration**: Sequential execution (one at a time)
  - Path-based: `**/e2e/**`, `**/integration/**`, `**/*.e2e.*`
  - Keyword-based: "e2e", "integration", "playwright", "cypress"
  - Script-based: package.json script contains "e2e" or "integration"
- **Unit/Lint/Type**: Parallel allowed with worker limits

**Routing Logic** (from `execute-plan` Step 3):
```bash
# E2E tests → Sequential (environment-bound, stateful)
if echo "$SC_CONTENT" | grep -qiE 'e2e|integration|playwright|cypress'; then
    TEST_TYPE="e2e"
    SequentialGroup  # One at a time
else
    TEST_TYPE="unit"
    ParallelGroup  # Safe with --maxWorkers=50%
fi
```

### Resource Calculation Examples

**Before (Unrestricted)**:
- 6 tester SCs (unit tests)
- All run in parallel
- Each Jest uses 16 workers (default = CPU cores)
- Total: 6 × 16 = **96 processes**, Load: 85+

**After (Controlled)**:
- 6 tester SCs (unit tests)
- All run in parallel
- Each Jest uses `--maxWorkers=50%` (8 workers on 16-core machine)
- Total: 6 × 8 = **48 processes**, Load: ≤10

**E2E Tests** (Sequential):
- 3 E2E SCs
- Run one at a time
- Each uses `--workers=1`
- Total: 1 × 1 = **1 process** per SC, Load: ≤2

### Implementation Patterns

**For Parallel Execution** (Unit tests):
```bash
# Safe parallel execution with worker limits
Spawn teammate "test-auth" with prompt: "You are a tester. SC-1: Test auth module."
Spawn teammate "test-user" with prompt: "You are a tester. SC-2: Test user module."
Spawn teammate "test-api" with prompt: "You are a tester. SC-3: Test API module."

# All use --maxWorkers=50% (tester agent default)
# Result: 3 × 8 = 24 workers (safe)
```

**For Sequential Execution** (E2E tests):
```bash
# E2E tests run one at a time
SequentialGroup:
  - SC-1: E2E test for login flow (test-type=e2e)
  - SC-2: E2E test for checkout (test-type=e2e)
  - SC-3: E2E test for payment (test-type=e2e)

# Spawn one at a time, wait for completion before next
Spawn teammate "e2e-login" → Wait → Spawn teammate "e2e-checkout" → Wait → Spawn teammate "e2e-payment"

# Each uses --workers=1 (tester agent E2E default)
# Result: 1 worker per SC (safe)
```

### Key Principles

1. **Test Type Detection First**: Always detect test type before routing (see `execute-plan` Step 3)
2. **Fail-Safe Default**: Unknown test type → `unit` (parallel allowed with worker limit)
3. **Environment-Bound Tests**: E2E/integration → Always sequential (stateful, contention-prone)
4. **Unit Tests**: Parallel allowed with `--maxWorkers=50%` (fast, isolated)

---

## Delegate Mode Patterns

### Team Lead Responsibilities

**In delegate mode (Shift+Tab)**:
- ✅ Spawn teammates with clear task assignments
- ✅ Monitor shared Task List and teammate messages
- ✅ Aggregate results from completed teammates
- ✅ Handle blockers (delegate to GPT via codex, coordinate dependencies)
- ❌ Never directly edit files
- ❌ Never implement features
- ❌ Never write tests

### Teammate Responsibilities

**Each teammate**:
- ✅ Execute assigned SC/task using specified skills (tdd, ralph-loop, vibe-coding)
- ✅ Run Ralph Loop autonomously (max 7 iterations, or 2 with --early)
- ✅ Message team lead if blocked (CODER_BLOCKED + context)
- ✅ Message other teammates for cross-review or coordination
- ✅ Mark task done when complete (TaskCompleted hook auto-verifies)
- ❌ Never rely on team lead for implementation

### Communication Flow

```markdown
# Teammate ↔ Team Lead
Teammate "sc1-impl" → Message to team lead: "<CODER_BLOCKED> iteration 3, type error in src/auth.ts"
Team Lead → codex exec -m gpt-5.2 "Analyze blocker..."
Team Lead → Message to sc1-impl: "GPT suggests: [solution]"

# Teammate ↔ Teammate
Teammate "test-reviewer" → Message to deep-reviewer: "Low coverage in src/auth.ts, can you review?"
Teammate "deep-reviewer" → Message to test-reviewer: "Found 3 edge cases needing tests: [list]"
```

---

## Before/After Comparison

### Before: Old Task Delegation Pattern

```markdown
## Step 3: Execute SCs

Task: [Old delegation pattern with agent_type parameter]
  prompt: Execute SC-1 from $PLAN_PATH

Task: [Old delegation pattern with agent_type parameter]
  prompt: Execute SC-2 from $PLAN_PATH

# Wait for Task completion
# Parse <CODER_COMPLETE> marker
# Update todos manually
```

**Characteristics**:
- One-way communication (delegated agent → orchestrator)
- Manual marker parsing (<CODER_COMPLETE>)
- Manual TODO updates
- Orchestrator context bloat (~50-80K tokens)

### After: Agent Teams Pattern

```markdown
## Step 3: Execute SCs via Agent Team

Spawn teammate "sc1-impl" with prompt:
  "You are a coder (see @.claude/agents/coder.md).
  Execute SC-1 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task as done. If blocked, message team lead."

Spawn teammate "sc2-impl" with prompt:
  "You are a coder (see @.claude/agents/coder.md).
  Execute SC-2 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task as done. If blocked, message team lead."

# Team Lead operates in delegate mode (Shift+Tab): coordinate only
# TaskCompleted hook auto-verifies quality gates
# Teammates update shared Task List automatically
```

**Characteristics**:
- Multi-directional communication (teammate ↔ teammate ↔ lead)
- Automated quality gates (TaskCompleted hook)
- Automated TODO updates (shared Task List)
- Team Lead context clean (~5K tokens)

### Key Improvements

| Aspect | Before (Subagent) | After (Agent Teams) |
|--------|------------------|-------------------|
| Communication | One-way | Multi-directional |
| Quality Gates | Manual markers | Automated hooks |
| TODO Updates | Manual orchestrator | Automated Task List |
| Context Isolation | Manual Task delegation | Native per-teammate |
| Cross-Review | No collaboration | Direct teammate messaging |
| Coordination | Orchestrator-driven | Self-organizing + lead oversight |

---

**Version**: claude-pilot 5.0.0
