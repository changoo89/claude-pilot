# REFERENCE: Agent Teams

> **Detailed teammate spawn templates, hook integration, and migration patterns**

---

## Full Teammate Spawn Templates

### execution-team Templates

#### Coder Teammate (General Implementation)
```markdown
Spawn teammate "sc1-impl" with prompt:
  """
  You are a coder agent (see @.claude/agents/coder.md for full definition).

  **TASK**: Execute SC-1 from plan at $PLAN_PATH

  **SC DESCRIPTION**:
  [Include full SC description from plan]

  **CONTEXT**:
  - Working directory: $PWD
  - Plan file: $PLAN_PATH
  - Related files: [list from SC]

  **SKILLS TO USE**:
  - tdd: Red-Green-Refactor cycle
  - ralph-loop: Autonomous iteration until quality gates pass
  - vibe-coding: Code quality standards (functions ≤50 lines, files ≤200 lines)

  **EXPECTED OUTPUT**:
  - All tests pass (npm test or pytest)
  - Coverage ≥80% (core ≥90%)
  - TODO checkbox marked [x] in plan file
  - Type-check clean (tsc --noEmit or mypy)
  - Lint clean (eslint or ruff)

  **IF BLOCKED**:
  - Message the team lead with: <CODER_BLOCKED> + iteration count + last error
  - Lead will delegate to GPT Architect via codex

  **WHEN COMPLETE**:
  - Mark task as done (TaskCompleted hook will verify automatically)
  """
```

#### Frontend-Engineer Teammate
```markdown
Spawn teammate "sc2-frontend" with prompt:
  """
  You are a frontend-engineer agent (see @.claude/agents/frontend-engineer.md).

  **TASK**: Execute SC-2 (Frontend) from $PLAN_PATH

  **SPECIALIZATION**:
  - React components, hooks, state management
  - UI/UX implementation
  - Frontend testing (React Testing Library, Vitest)
  - Accessibility and responsive design

  **SKILLS TO USE**:
  - tdd: Component testing first
  - vibe-coding: Component ≤50 lines
  - frontend-design: UI/UX design thinking

  **QUALITY GATES**:
  - Component tests pass
  - Coverage ≥80%
  - Accessibility checks (eslint-plugin-jsx-a11y)
  - No console warnings

  **COORDINATION**:
  - If backend API needed, message backend-engineer teammate
  - Share component design decisions with team lead

  **WHEN COMPLETE**: Mark task as done
  """
```

#### Backend-Engineer Teammate
```markdown
Spawn teammate "sc3-backend" with prompt:
  """
  You are a backend-engineer agent (see @.claude/agents/backend-engineer.md).

  **TASK**: Execute SC-3 (Backend) from $PLAN_PATH

  **SPECIALIZATION**:
  - API endpoints, middleware, controllers
  - Database queries, migrations, ORM
  - Server-side logic and validation
  - Integration testing

  **SKILLS TO USE**:
  - tdd: API testing first (Supertest, Pytest)
  - ralph-loop: Iterate until integration tests pass
  - vibe-coding: Functions ≤50 lines

  **QUALITY GATES**:
  - Integration tests pass
  - API documentation updated
  - Database migrations tested
  - Error handling complete

  **COORDINATION**:
  - If frontend contract needed, message frontend-engineer teammate
  - Share API schema changes with team lead

  **WHEN COMPLETE**: Mark task as done
  """
```

### review-team Templates

#### Test Coverage Reviewer
```markdown
Spawn teammate "test-reviewer" with prompt:
  """
  You are a tester agent (see @.claude/agents/tester.md).

  **TASK**: Review test coverage for plan at $PLAN_PATH

  **EVALUATION CRITERIA**:
  1. Test completeness: Are all SCs verifiable?
  2. Coverage threshold: ≥80% overall, ≥90% core modules
  3. Verification commands: Do they exist and work?
  4. Edge cases: Are critical paths tested?

  **CROSS-REVIEW**:
  - Message quality-reviewer to discuss any code smells affecting testability
  - Message deep-reviewer to discuss complex logic that needs more tests

  **OUTPUT FORMAT**:
  TEST_PASS or TEST_FAIL
  - Coverage: [percentage]
  - Missing tests: [list]
  - Recommendations: [list]

  **WHEN COMPLETE**: Mark task as done
  """
```

#### Quality Reviewer (Type + Lint)
```markdown
Spawn teammate "quality-reviewer" with prompt:
  """
  You are a validator agent (see @.claude/agents/validator.md).

  **TASK**: Review type safety and lint compliance for $PLAN_PATH

  **EVALUATION CRITERIA**:
  1. Type coverage: TypeScript strict mode compliance
  2. Lint violations: Zero errors, minimal warnings
  3. Code consistency: Follows project conventions
  4. Unused code: No dead code or unused imports

  **CROSS-REVIEW**:
  - Message test-reviewer if type issues affect testability
  - Message deep-reviewer to discuss type safety concerns

  **OUTPUT FORMAT**:
  QUALITY_PASS or QUALITY_FAIL
  - Type errors: [count]
  - Lint violations: [count]
  - Recommendations: [list]

  **WHEN COMPLETE**: Mark task as done
  """
```

#### Deep Code Reviewer (Opus)
```markdown
Spawn teammate "deep-reviewer" with prompt:
  """
  You are a code-reviewer agent using Opus model (see @.claude/agents/code-reviewer.md).

  **TASK**: Deep code quality review for $PLAN_PATH

  **EVALUATION CRITERIA**:
  1. Code quality: SOLID principles, design patterns
  2. Performance: Algorithmic complexity, memory usage
  3. Maintainability: Readability, documentation, simplicity
  4. Error handling: Edge cases, race conditions, error recovery

  **CROSS-REVIEW**:
  - Message test-reviewer to suggest additional test cases
  - Message quality-reviewer if type improvements needed
  - Message security-reviewer if security concerns found

  **OUTPUT FORMAT**:
  DEEP_PASS or DEEP_FAIL
  - Quality score: [1-10]
  - Critical issues: [list]
  - Refactoring suggestions: [list]

  **WHEN COMPLETE**: Mark task as done
  """
```

#### Security Reviewer (Conditional)
```markdown
Spawn teammate "security-reviewer" with prompt:
  """
  You are a security-analyst agent (see @.claude/agents/security-analyst.md).

  **TASK**: Security review for $PLAN_PATH (auth/API/data handling changes)

  **EVALUATION CRITERIA**:
  1. OWASP Top 10: Injection, XSS, CSRF, etc.
  2. Authentication/Authorization: Proper checks, token handling
  3. Data validation: Input sanitization, output encoding
  4. Dependencies: Known vulnerabilities (npm audit, pip audit)

  **CROSS-REVIEW**:
  - Message deep-reviewer to discuss security architecture
  - Message quality-reviewer for security-related lint rules

  **OUTPUT FORMAT**:
  SECURITY_PASS or SECURITY_FAIL
  - Vulnerabilities: [severity + description]
  - Recommendations: [list]

  **WHEN COMPLETE**: Mark task as done
  """
```

### planning-team Templates

#### Codebase Explorer
```markdown
Spawn teammate "codebase-explorer" with prompt:
  """
  You are an explorer agent (see @.claude/agents/explorer.md).

  **TASK**: Explore codebase for [domain] related to [user task]

  **EXPLORATION TARGETS**:
  1. Relevant files: TypeScript/JavaScript/Python files in src/
  2. Existing patterns: Similar implementations, conventions
  3. Configuration: Config files, environment variables
  4. Tests: Test patterns, mocking strategies

  **TOOLS**:
  - Glob: Find files by pattern
  - Grep: Search for keywords, patterns
  - Read: Examine file contents

  **COLLABORATION**:
  - Share file list with docs-researcher via Message
  - Highlight gaps where external research needed
  - Discuss findings to inform plan creation

  **OUTPUT FORMAT**:
  - File list with descriptions
  - Pattern summary (conventions, architectures)
  - Integration points (APIs, dependencies)

  **WHEN COMPLETE**: Mark task as done
  """
```

#### Documentation Researcher
```markdown
Spawn teammate "docs-researcher" with prompt:
  """
  You are a researcher agent (see @.claude/agents/researcher.md).

  **TASK**: Research external documentation for [task]

  **RESEARCH TARGETS**:
  1. Official documentation: Framework docs, API references
  2. Best practices: Industry standards, design patterns
  3. Examples: Reference implementations, tutorials
  4. Security: OWASP guidelines, security best practices

  **SOURCES**:
  - Official project documentation
  - Framework documentation
  - Security advisories (OWASP, CVE)
  - Community best practices

  **COLLABORATION**:
  - Share research summary with codebase-explorer via Message
  - Highlight external patterns that match internal code
  - Discuss gaps and recommendations

  **OUTPUT FORMAT**:
  - Research summary with links
  - Best practices list
  - Security considerations
  - Example code snippets

  **WHEN COMPLETE**: Mark task as done
  """
```

---

## Hook Integration

### settings.json Hook Registration

Add to your Claude Code `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "hooks": {
    "TaskCompleted": {
      "command": ".claude/hooks/verify-task-completion.sh",
      "timeout": 120000
    },
    "TeammateIdle": {
      "command": ".claude/hooks/teammate-idle-check.sh",
      "timeout": 30000
    }
  }
}
```

### Hook Script Examples

#### verify-task-completion.sh
```bash
#!/bin/bash
# TaskCompleted hook: Verify quality gates before allowing completion

set -e

PLAN_PATH="${1:-$(find .pilot/plan/in_progress -name "*.md" -type f | head -1)}"

# Test command auto-detection
if [ -f "package.json" ]; then
    TEST_CMD="npm test"
elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
    TEST_CMD="pytest"
elif [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
else
    TEST_CMD="npm test"  # Fallback
fi

# Run tests
if ! timeout 120s $TEST_CMD; then
    echo "ERROR: Tests failed" >&2
    exit 2  # Reject completion
fi

# Check coverage (simplified - actual script more robust)
COVERAGE=$($TEST_CMD --coverage 2>&1 | grep -oP 'Lines\s+:\s+\K[\d.]+' || echo "0")
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo "ERROR: Coverage $COVERAGE% < 80%" >&2
    exit 2
fi

# Check TODOs
if [ -f "$PLAN_PATH" ] && grep -q "^- \[ \]" "$PLAN_PATH"; then
    echo "ERROR: Unchecked TODOs remain in plan" >&2
    exit 2
fi

echo "✓ Quality gates passed: tests pass, coverage $COVERAGE%, todos checked"
exit 0  # Allow completion
```

#### teammate-idle-check.sh
```bash
#!/bin/bash
# TeammateIdle hook: Check if teammate can go idle

TEAMMATE_NAME="${1:-unknown}"
PLAN_PATH="${2:-$(find .pilot/plan/in_progress -name "*.md" -type f | head -1)}"

# Extract assigned SC from teammate name (sc1-impl → SC-1)
SC_NUM=$(echo "$TEAMMATE_NAME" | grep -oP 'sc\K\d+')
if [ -z "$SC_NUM" ]; then
    exit 0  # No SC assignment, allow idle
fi

# Check if SC is complete
if [ -f "$PLAN_PATH" ] && grep -qE "^- \[x\].*SC-$SC_NUM" "$PLAN_PATH"; then
    exit 0  # SC complete, allow idle
fi

echo "ERROR: SC-$SC_NUM not complete yet, continue working" >&2
exit 2  # Reject idle
```

---

## Delegate Mode Detailed

### What Delegate Mode Means

**Team Lead in delegate mode (Shift+Tab)**:
- ✅ Spawn teammates with clear task assignments
- ✅ Monitor teammate progress (messages, Task List)
- ✅ Aggregate results from completed teammates
- ✅ Handle blockers (delegate to GPT, coordinate dependencies)
- ❌ Never directly edit files
- ❌ Never implement features
- ❌ Never write tests

### Why Delegate Mode is MANDATORY

**Context efficiency**:
- Team Lead: ~5K tokens (coordination only)
- Teammates: ~80K tokens each (full implementation)
- Total capacity: 5K + (n × 80K) vs single 80K limit

**Specialization**:
- Each teammate loads agent-specific context (coder.md, frontend-engineer.md)
- Team Lead focuses on orchestration, not implementation

**Quality gates**:
- TaskCompleted hook ensures quality before lead sees results
- Team Lead receives verified, high-quality outputs

### How to Stay in Delegate Mode

**Pattern 1: Spawning**
```markdown
# ✅ CORRECT: Delegate to teammate
Spawn teammate "impl" with prompt: "Implement auth service..."

# ❌ WRONG: Team Lead implements directly
[Team Lead edits src/auth.ts]
```

**Pattern 2: Coordination**
```markdown
# ✅ CORRECT: Coordinate teammates
Teammate "sc1-impl" complete → Spawn "sc2-impl" (depends on SC-1)

# ❌ WRONG: Team Lead chains implementation
[Team Lead implements SC-1, then SC-2]
```

**Pattern 3: Blockers**
```markdown
# ✅ CORRECT: Escalate to GPT
Teammate messages: <CODER_BLOCKED>
Team Lead: codex exec -m gpt-5.2 "Analyze blocker..."

# ❌ WRONG: Team Lead implements fix
[Team Lead debugs and fixes blocker directly]
```

---

## Teammate Communication Patterns

### Direct Messaging (Teammate ↔ Teammate)

**Pattern**: Teammates can Message each other directly
```markdown
# test-reviewer → deep-reviewer
Message to deep-reviewer: "Found low coverage in src/auth.ts.
Can you review the complex logic there and suggest additional test cases?"

# deep-reviewer → test-reviewer
Message to test-reviewer: "Reviewed src/auth.ts. The token validation logic
has 3 edge cases that need tests: expired token, malformed token, missing token."
```

**Use Cases**:
- Cross-review discussion
- Dependency coordination (frontend ↔ backend)
- Knowledge sharing

### Shared Task List

**Pattern**: All teammates see shared Task List
```markdown
Task List:
- [x] SC-1: Auth service (sc1-impl) - COMPLETE
- [ ] SC-2: User service (sc2-impl) - IN_PROGRESS
- [ ] SC-3: API routes (sc3-backend) - WAITING (depends on SC-2)
```

**Benefits**:
- Visibility into team progress
- Dependency tracking
- Coordination without lead intervention

### Messaging Team Lead

**Pattern**: Teammates message lead for blockers or questions
```markdown
# Teammate → Team Lead
Message to team lead: "<CODER_BLOCKED>
Iteration: 3
Last error: Type error in src/auth.ts line 45
Attempts: Tried adding type annotation, still failing"

# Team Lead → GPT (via codex)
codex exec -m gpt-5.2 -s workspace-write "TASK: Fix type error..."

# Team Lead → Teammate
Message to sc1-impl: "GPT Architect analyzed. Apply this fix: [details]"
```

---

## Error Handling and Fallback Patterns

### Teammate Blocked (Ralph Loop Max Iterations)

**Pattern**: Teammate hits max iterations (7 or 2 with --early)
```markdown
1. Teammate messages lead: <CODER_BLOCKED> + context
2. Lead delegates to GPT Architect via codex
3. Lead relays GPT solution to teammate
4. Teammate applies fix and continues Ralph Loop
```

**Fallback**: If GPT also blocked, escalate to user

### Hook Verification Failure

**Pattern**: TaskCompleted hook rejects completion
```bash
# Teammate marks task done → Hook runs → Rejects
ERROR: Tests failed
ERROR: Coverage 65% < 80%

# Teammate receives rejection → Continues working
# Teammate fixes issues → Marks done again → Hook passes
```

**Fallback**: After 3 hook rejections, escalate to lead

### Teammate Spawn Failure

**Pattern**: Agent type not found or spawn fails
```markdown
1. Lead attempts spawn: "sc1-impl" (role: coder)
2. Error: Agent definition not found
3. Fallback: Use generic "coder" agent without specialization
4. Log warning for plugin maintainer
```

---

## Before/After Comparison

### Before: Subagent Pattern

```markdown
## Step 3: Execute SCs

Task:
  subagent_type: coder
  prompt: Execute SC-1 from $PLAN_PATH

Task:
  subagent_type: coder
  prompt: Execute SC-2 from $PLAN_PATH

# Wait for Task completion
# Parse <CODER_COMPLETE> marker
# Update todos manually
```

**Characteristics**:
- One-way communication (subagent → orchestrator)
- Manual marker parsing (<CODER_COMPLETE>)
- Manual TODO updates
- Orchestrator context bloat (~50-80K tokens)

### After: Agent Teams Pattern

```markdown
## Step 3: Execute SCs via Agent Team

Spawn teammate "sc1-impl" with prompt:
  "You are a coder. Execute SC-1 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task as done."

Spawn teammate "sc2-impl" with prompt:
  "You are a coder. Execute SC-2 from $PLAN_PATH.
  Skills: tdd, ralph-loop, vibe-coding.
  When complete, mark task as done."

# Operate in delegate mode (Shift+Tab): coordinate only
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

## Migration Checklist

**From Subagent to Agent Teams**:
- [ ] Replace `Task: subagent_type: X` → `Spawn teammate "name" with prompt`
- [ ] Add delegate mode instruction to Team Lead
- [ ] Update agent definitions with `teammate_role` and `spawn_prompt`
- [ ] Create hook scripts (verify-task-completion.sh, teammate-idle-check.sh)
- [ ] Update settings.json with AGENT_TEAMS env var and hooks
- [ ] Remove `⛔ MAIN ORCHESTRATOR RESTRICTIONS` sections (obsolete)
- [ ] Remove manual TODO update code (automated by Task List)
- [ ] Remove marker parsing code (automated by TaskCompleted hook)
- [ ] Update documentation to reflect Agent Teams patterns

---

**Version**: claude-pilot 5.0.0
