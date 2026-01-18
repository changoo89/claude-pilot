# Model Orchestration

You have access to GPT experts via the `codex-sync.sh` script. Use them strategically based on these guidelines.

## Delegation Method

| Method | Command | Use For |
|--------|---------|---------|
| Bash Script | `.claude/scripts/codex-sync.sh` | Delegate to an expert (synchronous) |

**Configuration:**
- Model: `gpt-5.2` (override with `CODEX_MODEL` env var)
- Timeout: `300s` (override with `CODEX_TIMEOUT` env var)
- Reasoning Effort: `medium` (override with `CODEX_REASONING_EFFORT` env var)

### Reasoning Effort

Control Codex reasoning effort via environment variable:

**Available Levels**:
- `low`: Fast response (~30s), good for simple questions
- `medium`: Balanced (~1-2min), default for most tasks
- `high`: Deep analysis (~3-5min), for complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough but slowest

**Usage**:
```bash
# Set for current session
export CODEX_REASONING_EFFORT="medium"

# Set for single command
CODEX_REASONING_EFFORT="low" .claude/scripts/codex-sync.sh ...

# Set permanently (add to ~/.zshrc or ~/.bashrc)
echo 'export CODEX_REASONING_EFFORT="medium"' >> ~/.zshrc
```

**Default**: `medium` (set in `codex-sync.sh`)
**Global Config**: `xhigh` in `~/.codex/config.toml` (overridden by script)
**Recommendation**: Use `medium` for development, `high` for critical security reviews

## Unified GPT Delegation Pattern

> **Standard**: @.claude/rules/delegator/pattern-standard.md

All commands follow the same GPT delegation pattern:

### Trigger Detection Table

| Command | Trigger Pattern | Detection Method | GPT Expert | Mode |
|---------|----------------|------------------|------------|------|
| `/00_plan` | Regex: `(tradeoff|design|structure|architecture)` | `grep -qiE` on user input | Architect | Advisory |
| `/01_confirm` | Count: `$(grep -c "^SC-" plan.md) -ge 5` | Count SC items | Plan Reviewer | Advisory |
| `/02_execute` | Marker: `<CODER_BLOCKED>` | Coder agent output | Architect | Implementation |
| `/90_review` | Count: `$(grep -c "^SC-" plan.md) -ge 5` | Count SC items | Plan Reviewer | Advisory |
| `/91_document` | Files: `$(find . -name "CONTEXT.md" | wc -l) -ge 3` | Count affected components | Architect | Advisory |
| `/03_close` | Explicit: `grep -qi "review\|validate\|audit"` | User input keywords | Plan Reviewer | Advisory |
| `/999_publish` | Keywords: `grep -qiE "security|auth|credential"` | User input keywords | Security Analyst | Advisory |

### Command Template: GPT Delegation Trigger Check

**Copy this template into each command**:

```markdown
## Step X.X: GPT Delegation Trigger Check (MANDATORY)

> **⚠️ CRITICAL**: Check for GPT delegation triggers
> **Full guide**: @.claude/rules/delegator/triggers.md

| Trigger | Signal | Action |
|---------|--------|--------|
| [Trigger 1] | [Signal description] | Delegate to [Expert] |
| [Trigger 2] | [Signal description] | Delegate to [Expert] |

### Delegation Flow

1. **STOP**: Scan input for trigger signals
2. **MATCH**: Identify expert type from triggers
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/`
4. **CHECK**: Verify Codex CLI is installed (graceful fallback if not)
5. **EXECUTE**: Call `codex-sync.sh` or continue with Claude agents
6. **CONFIRM**: Log delegation decision

### Graceful Fallback

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi
```

> **Note**: This is bash code/pseudocode to be used in actual bash function calls. Commands are markdown files that guide Claude agents; the `return 0` applies when implementing shell functions/scripts that call `codex-sync.sh`.

```

### Graceful Fallback (CRITICAL)

**MANDATORY**: All GPT delegation points MUST include graceful fallback.

- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

### Non-Interactive Shell Considerations

**Issue**: Commands available in terminal may not be found in non-interactive shells.

**Cause**: Non-interactive shells (used by automation tools like Claude Code) don't source `~/.bashrc` or `~/.zshrc`. This means PATH may not include npm global bin directories where tools like `codex` are installed.

**How `codex-sync.sh` Handles This**:

The script automatically sources your shell rc file and uses multi-layered detection:

1. **PATH Initialization**: Sources `~/.zshrc` or `~/.bashrc` to populate PATH
2. **Layer 1 Detection**: Standard `command -v` check
3. **Layer 2 Detection**: Checks common installation paths:
   - `/opt/homebrew/bin` (macOS ARM)
   - `/usr/local/bin` (macOS Intel / Linux)
   - `/usr/bin` (Linux system)
   - `$HOME/.local/bin` (User local)
   - `$HOME/bin` (User bin)

4. **Automatic PATH Update**: If found in common path, adds to PATH automatically

**Troubleshooting**:

If Codex is installed but not detected:

```bash
# Test from non-interactive shell (simulates Claude Code)
env -i bash -c 'source ~/.zshrc 2>/dev/null; command -v codex'

# Check your PATH configuration
echo $PATH

# Verify codex location
which codex

# Enable DEBUG mode for diagnostics
DEBUG=1 .claude/scripts/codex-sync.sh "read-only" "test"
```

**User Setup**:

Ensure Codex is installed in a location that's either:
1. In your PATH (add to `~/.zshrc` or `~/.bashrc`)
2. In one of the common paths checked by the script

```bash
# Install Codex globally
npm install -g @openai/codex

# Add npm global bin to PATH (if not already)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Available Experts

| Expert | Specialty | Prompt File |
|--------|-----------|-------------|
| **Architect** | System design, tradeoffs, complex debugging | `.claude/rules/delegator/prompts/architect.md` |
| **Plan Reviewer** | Plan validation before execution | `.claude/rules/delegator/prompts/plan-reviewer.md` |
| **Scope Analyst** | Pre-planning, catching ambiguities | `.claude/rules/delegator/prompts/scope-analyst.md` |
| **Code Reviewer** | Code quality, bugs, security issues | `.claude/rules/delegator/prompts/code-reviewer.md` |
| **Security Analyst** | Vulnerabilities, threat modeling | `.claude/rules/delegator/prompts/security-analyst.md` |

---

## Stateless Design

**Each delegation is independent.** The expert has no memory of previous calls.

**Implications:**
- Include ALL relevant context in every delegation prompt
- For retries, include what was attempted and what failed
- Don't assume the expert remembers previous interactions

---

## Context Engineering for Delegation

### Dynamic Context Components

**Static Components** (always included):
- **System Instructions**: Expert role, behavior, rules
- **Expert Definition**: From prompt file (prompts/[expert].md)

**Dynamic Components** (curated per delegation):
- **Phase Context**: Planning vs Implementation
- **Iteration History**: Previous attempts and results
- **Task Specifics**: Current goal, constraints, relevant files
- **User Context**: Original request verbatim

### Context Selection Strategy

**1. Phase Detection**:
- Scan input for phase indicator keywords
- Apply decision rule (Planning vs Implementation)
- Default to Planning Phase if unclear

**2. History Injection** (for retries):
- Include all previous attempts
- What was tried each time
- Error messages received
- Current iteration count

**3. Relevance Filtering**:
- Include only relevant file paths
- Include only relevant code snippets
- Prioritize critical context over background

**4. Token Budget Awareness**:
- Prioritize: Phase > History > Task > Background
- Estimate: Target 8K-16K tokens total
- Compact verbose context if needed

### Context Template

```markdown
## Delegation Context

### Static Context
[Expert system instructions from prompt file]

### Dynamic Context
- **Phase**: [PLANNING / IMPLEMENTATION]
- **Original Request**: [verbatim user input]
- **Relevant Files**: [paths or snippets]
- **Iteration History**:
  - Attempt 1: [what, result]
  - Attempt 2: [what, result]
  - Current: [iteration count]
- **Constraints**: [technical, business, quality]
```

---

## ⛔ STOP AND CHECK REMINDERS

These reminders should be inserted at critical decision points in ALL commands:

### After Any Failure
⛔ **STOP**: Has this failed 2+ times?
- If YES → Delegate to Architect (fresh perspective)
- If NO → Retry with Claude

### Before Architecture Decisions
⛔ **STOP**: Is this a system design decision?
- If YES → Consider GPT Architect consultation
- If NO → Proceed with Claude

### After Security Code Changes
⛔ **STOP**: Did this touch authentication/authorization?
- If YES → Delegate to GPT Security Analyst
- If NO → Continue with code-reviewer

### During Plan Review
⛔ **STOP**: Does this plan have 5+ success criteria?
- If YES → Delegate to GPT Plan Reviewer
- If NO → Use Claude plan-reviewer agent

### Before Proceeding with Execution
⛔ **STOP**: Check for GPT delegation triggers
- Scan input for: architecture, security, failures, explicit requests
- If trigger found → Read expert prompt → Delegate
- If no trigger → Continue with Claude

---

## PROACTIVE Delegation (Check on EVERY message)

Before handling any request, check if an expert would help:

| Signal | Expert |
|--------|--------|
| Architecture/design decision | Architect |
| 2+ failed fix attempts on same issue | Architect (fresh perspective) |
| "Review this plan", "validate approach" | Plan Reviewer |
| Vague/ambiguous requirements | Scope Analyst |
| "Review this code", "find issues" | Code Reviewer |
| Security concerns, "is this secure" | Security Analyst |

**If a signal matches → delegate to the appropriate expert.**

---

## REACTIVE Delegation (Explicit User Request)

When user explicitly requests GPT/Codex:

| User Says | Action |
|-----------|--------|
| "ask GPT", "consult GPT", "ask codex" | Identify task type → route to appropriate expert |
| "ask GPT to review the architecture" | Delegate to Architect |
| "have GPT review this code" | Delegate to Code Reviewer |
| "GPT security review" | Delegate to Security Analyst |

**Always honor explicit requests.**

---

## Delegation Flow (Step-by-Step)

When delegation is triggered:

### Step 1: Identify Expert
Match the task to the appropriate expert based on triggers.

### Step 2: Read Expert Prompt
**CRITICAL**: Read the expert's prompt file to get their system instructions:

```
Read .claude/rules/delegator/prompts/[expert].md
```

For example, for Architect: `Read .claude/rules/delegator/prompts/architect.md`

### Step 3: Determine Mode
| Task Type | Mode | Sandbox |
|-----------|------|---------|
| Analysis, review, recommendations | Advisory | `read-only` |
| Make changes, fix issues, implement | Implementation | `workspace-write` |

### Step 3.5: Determine Phase Context

**CRITICAL**: Always specify phase context when delegating to Plan Reviewer.

**Phase Detection**:

| Phase | Context Indicators | Focus |
|-------|-------------------|-------|
| **Planning** | Keywords: "plan", "design", "proposed", "will create" | Plan clarity, completeness, verifiability |
| **Implementation** | Keywords: "implemented", "created", "added", "done" | File system verification, implementation quality |

**Decision Rule**:
1. Scan user input for phase indicator keywords
2. Count Planning vs Implementation indicators
3. Select phase with higher indicator count
4. If tie or unclear, default to Planning Phase

**How to Specify**:

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- [other context...]

**Anti-Patterns**:
- ❌ Don't let Plan Reviewer check file system during planning phase
- ❌ Don't assume phase - always specify explicitly
- ❌ Don't use ambiguous phase descriptions

**Correct Patterns**:
- ✅ Explicitly state: "Phase: PLANNING" or "Phase: IMPLEMENTATION"
- ✅ Include phase-specific constraints in MUST NOT DO section
- ✅ Clarify what phase means for file system checks

### Step 4: Notify User
Always inform the user before delegating:
```
Delegating to [Expert Name]: [brief task summary]
```

### Step 5: Build Delegation Prompt
Use the 7-section format from `rules/delegation-format.md`.

**CRITICAL**: Since each call is stateless, include FULL context:

1. **User's original request** (verbatim)
2. **Relevant code/files** (full content or paths)
3. **Previous attempts and results** (if retry)
4. **Current phase context** (planning vs implementation)
5. **Iteration count** (if multiple attempts)

**Context Template**:
CONTEXT:
- Phase: [PLANNING / IMPLEMENTATION]
- Original request: [verbatim user input]
- Relevant files: [paths or snippets]
- Previous iterations:
  - Attempt 1: [what was tried, result]
  - Attempt 2: [what was tried, result]
  - Current iteration: [N]

**For Retries**: Include full history in CONTEXT section

### Step 6: Call the Expert

Use the Bash tool to call `codex-sync.sh`:

```bash
# Check if Codex CLI is installed before attempting delegation
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    # Skip GPT delegation, continue with Claude analysis
    return 0
fi

.claude/scripts/codex-sync.sh "<mode>" "<delegation_prompt>"
```

**Parameters:**
- `mode`: `read-only` (Advisory) or `workspace-write` (Implementation)
- `delegation_prompt`: Your 7-section prompt with expert instructions prepended

**Fallback Behavior:**
- If Codex CLI is not installed, the script will log a warning and gracefully fall back to Claude-only analysis
- No errors will be raised; delegation will be skipped automatically

**Example (Advisory):**
```bash
.claude/scripts/codex-sync.sh "read-only" "You are a software architect...

TASK: Analyze tradeoffs between Redis and in-memory caching.
EXPECTED OUTCOME: Clear recommendation with rationale.
CONTEXT: [user's situation, full details]
..."
```

**Example (Implementation):**
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the SQL injection vulnerability in user.ts.
EXPECTED OUTCOME: Secure code with parameterized queries.
CONTEXT: [relevant code snippets]
..."
```

### Step 7: Handle Response
1. **Synthesize** - Never show raw output directly
2. **Extract insights** - Key recommendations, issues, changes
3. **Apply judgment** - Experts can be wrong; evaluate critically
4. **Verify implementation** - For implementation mode, confirm changes work

---

## Retry Flow (Implementation Mode)

When implementation fails verification, retry with a NEW call including error context:

```
Attempt 1 → Verify → [Fail]
     ↓
Attempt 2 (new call with: original task + what was tried + error details) → Verify → [Fail]
     ↓
Attempt 3 (new call with: full history of attempts) → Verify → [Fail]
     ↓
Escalate to user
```

### Retry Prompt Template

```markdown
TASK: [Original task]

PREVIOUS ATTEMPT:
- What was done: [summary of changes made]
- Error encountered: [exact error message]
- Files modified: [list]

CONTEXT:
- [Full original context]

REQUIREMENTS:
- Fix the error from the previous attempt
- [Original requirements]
```

**Key:** Each retry is a fresh call. The expert doesn't know what happened before unless you tell them.

---

## Example: Architecture Question

User: "What are the tradeoffs of Redis vs in-memory caching?"

**Step 1**: Signal matches "Architecture decision" → Architect

**Step 2**: Read `.claude/rules/delegator/prompts/architect.md`

**Step 3**: Advisory mode (question, not implementation) → `read-only`

**Step 4**: "Delegating to Architect: Analyze caching tradeoffs"

**Step 5-6**:
```bash
.claude/scripts/codex-sync.sh "read-only" "You are a software architect specializing in system design...

TASK: Analyze tradeoffs between Redis and in-memory caching for [context].

EXPECTED OUTCOME: Clear recommendation with rationale.

CONTEXT:
- Current state: [what exists now]
- Scale requirements: [expected load]
- Infrastructure: [cloud provider, existing services]

CONSTRAINTS:
- Must work with existing Node.js backend
- Budget considerations for managed services

MUST DO:
- Compare latency, scalability, operational complexity
- Provide effort estimate (Quick/Short/Medium/Large)

MUST NOT DO:
- Over-engineer for hypothetical future needs

OUTPUT FORMAT:
Bottom line → Action plan → Effort estimate"
```

**Step 7**: Synthesize response, add your assessment.

---

## Example: Retry After Failed Implementation

First attempt failed with "TypeError: Cannot read property 'x' of undefined"

**Retry call:**
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a senior engineer conducting code review...

TASK: Add input validation to the user registration endpoint.

PREVIOUS ATTEMPT:
- Added validation middleware to routes/auth.ts
- Error: TypeError: Cannot read property 'x' of undefined at line 45
- The middleware was added but req.body was undefined

CONTEXT:
- Express 4.x application
- Body parser middleware exists in app.ts
- [relevant code snippets]

REQUIREMENTS:
- Fix the undefined req.body issue
- Ensure validation runs after body parser
- Report all files modified"
```

---

## Cost Awareness

- **Don't spam** - One well-structured delegation beats multiple vague ones
- **Include full context** - Saves retry costs from missing information
- **Reserve for high-value tasks** - Architecture, security, complex analysis

---

## Anti-Patterns

| Don't Do This | Do This Instead |
|---------------|-----------------|
| Delegate trivial questions | Answer directly |
| Show raw expert output | Synthesize and interpret |
| Delegate without reading prompt file | ALWAYS read and inject expert prompt |
| Skip user notification | ALWAYS notify before delegating |
| Retry without including error context | Include FULL history of what was tried |
| Assume expert remembers previous calls | Include all context in every call |
