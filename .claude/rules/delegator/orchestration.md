# Model Orchestration

You have access to GPT experts via the `codex-sync.sh` script. Use them strategically based on these guidelines.

## Delegation Method

| Method | Command | Use For |
|--------|---------|---------|
| Bash Script | `.claude/scripts/codex-sync.sh` | Delegate to an expert (synchronous) |

**Configuration:**
- Model: `gpt-5.2` (override with `CODEX_MODEL` env var)
- Reasoning: `xhigh` (override with `CODEX_REASONING_EFFORT` env var)
- Timeout: `300s` (override with `CODEX_TIMEOUT` env var)

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

### Step 4: Notify User
Always inform the user before delegating:
```
Delegating to [Expert Name]: [brief task summary]
```

### Step 5: Build Delegation Prompt
Use the 7-section format from `rules/delegation-format.md`.

**IMPORTANT:** Since each call is stateless, include FULL context:
- What the user asked for
- Relevant code/files
- Any previous attempts and their results (for retries)

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
