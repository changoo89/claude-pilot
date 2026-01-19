# Delegation Triggers

This file defines when to delegate to GPT experts via Codex.

## ⚠️ CRITICAL ENFORCEMENT

**This is NOT optional.** Trigger detection MUST happen automatically.

### Enforcement Protocol

**Commands MUST include trigger detection checkpoints at key decision points:**
- `/02_execute`: After Step 1 (Plan Detection), before Step 2
- `/review`: After Step 0 (Load Plan), before Step 1
- Any command handling failures, architecture decisions, or security concerns

### When to Check (MANDATORY)

- **Before starting ANY command execution**
- **At key decision points within commands**
- **When encountering documented trigger keywords**
- **After ANY failure (2+ attempts → escalate)**

### Trigger Check Template

1. **STOP**: Scan input for trigger signals
2. **MATCH**: Identify expert type from triggers below
3. **READ**: Load expert prompt file from `.claude/rules/delegator/prompts/`
4. **EXECUTE**: Call codex-sync.sh or continue
5. **CONFIRM**: Log delegation decision

### BEFORE PROCEEDING Checklist

- [ ] Scanned for explicit triggers ("ask GPT", "consult GPT")
- [ ] Checked for failure escalation (2+ attempts on same issue)
- [ ] Checked for architecture decision keywords
- [ ] Checked for security-related keywords
- [ ] If trigger matched → read expert prompt → delegate

---

## IMPORTANT: Check These Triggers on EVERY Message

You MUST scan incoming messages for delegation triggers. This is NOT optional.

**Behavior:**
1. **PROACTIVE**: On every user message, check if semantic triggers match → delegate automatically
2. **REACTIVE**: If user explicitly mentions GPT/Codex → delegate immediately

When a trigger matches:
1. Identify the appropriate expert
2. Read their prompt file from `.claude/rules/delegator/prompts/[expert].md`
3. Follow the delegation flow in `rules/orchestration.md`

---

## Trigger Patterns (Hybrid Approach)

This system uses **three complementary trigger types**:

1. **Explicit Triggers** (Keyword-based) - User explicitly requests delegation
2. **Semantic Triggers** (Heuristic-based) - Intent matching via heuristic evaluation
3. **Description-Based Triggers** (Claude Code official) - Agent description matching

### 1. Explicit Triggers (Keyword-Based)

**Legacy pattern**: Direct keyword matching for backward compatibility

| Phrase Pattern | Expert |
|----------------|--------|
| "ask GPT", "consult GPT" | Route based on context |
| "review this architecture" | Architect |
| "review this plan" | Plan Reviewer |
| "analyze the scope" | Scope Analyst |
| "review this code" | Code Reviewer |
| "security review", "is this secure" | Security Analyst |

### 2. Semantic Triggers (Heuristic-Based)

**Intelligent pattern**: Context-aware heuristic evaluation

**Full reference**: @.claude/rules/delegator/intelligent-triggers.md

#### Heuristic: Failure-Based Escalation (→ Architect)

| Trigger | Detection | Action |
|---------|-----------|--------|
| Agent fails 2+ times on same task | `iteration_count >= 2` AND `<CODER_BLOCKED>` | Delegate to Architect |

#### Heuristic: Ambiguity Detection (→ Scope Analyst)

| Trigger | Detection | Action |
|---------|-----------|--------|
| Vague or unclear task description | `grep -qiE "(unclear|ambiguous|not sure|maybe)"` OR `$(grep -c "^SC-" plan.md) -eq 0` | Delegate to Scope Analyst |

**Ambiguity Score** (0.0-1.0):
- Base: 0.0
- +0.3 if vague phrases in user input
- +0.3 if no success criteria
- +0.2 if no test plan
- +0.2 if multiple valid interpretations exist

**Threshold**: Score >= 0.5 → Delegate

#### Heuristic: Complexity Assessment (→ Architect)

| Trigger | Detection | Action |
|---------|-----------|--------|
| Task has many components | `$(grep -c "^SC-" plan.md) -ge 10` | Delegate to Architect |

**Complexity Score** (0.0-1.0):
- Base: 0.0
- +0.1 per SC (max 0.5 at 5 SCs)
- +0.2 per dependency level (max 0.4 at 2+ levels)
- +0.1 if 10+ SCs (complex threshold)

**Thresholds**:
- Score >= 0.5 (5+ SCs) → Consider Architect delegation
- Score >= 0.7 (10+ SCs) → MUST delegate to Architect

#### Heuristic: Risk Evaluation (→ Security Analyst)

| Trigger | Detection | Action |
|---------|-----------|--------|
| Security-sensitive code | `grep -qiE "(auth|credential|password|token|security)"` | Delegate to Security Analyst |

**Risk Score** (0.0-1.0):
- Base: 0.0
- +0.4 if auth/credential keywords
- +0.3 if security/vulnerability keywords
- +0.2 if modifying auth-related files
- +0.1 if destructive operations (delete, drop, truncate)

**Threshold**: Score >= 0.4 → Delegate

### 3. Description-Based Triggers (Claude Code Official)

**Claude Code official pattern**: Agent description semantic matching

**How it works**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase as delegation signal
4. When task matches agent description, delegates automatically

**Agents with "use proactively"**:
- **coder**: "Implementation agent using TDD. Use proactively for implementation tasks."
- **plan-reviewer**: "Plan review specialist... Use proactively after plan creation..."
- **code-reviewer**: "Critical code review agent... Use proactively after code changes..."

**Verification**:
- Agent description contains "use proactively"
- Description clearly states when to use the agent
- Task → Agent matching is obvious from description

---

## Available Experts

| Expert | Specialty | Use For | Prompt File |
|--------|-----------|---------|-------------|
| **Architect** | System design, tradeoffs | Architecture decisions, complex debugging | `prompts/architect.md` |
| **Plan Reviewer** | Plan validation | Reviewing work plans before execution | `prompts/plan-reviewer.md` |
| **Scope Analyst** | Pre-planning analysis | Catching ambiguities before work starts | `prompts/scope-analyst.md` |
| **Code Reviewer** | Code quality, bugs | Reviewing code changes, finding issues | `prompts/code-reviewer.md` |
| **Security Analyst** | Vulnerabilities, threats | Security audits, hardening | `prompts/security-analyst.md` |

---

## Semantic Triggers by Expert (Intent Matching)

### Architecture & Design (→ Architect)

| Intent Pattern | Example | Trigger Type |
|----------------|---------|--------------|
| "how should I structure" | "How should I structure this service?" | Semantic |
| "what are the tradeoffs" | "Tradeoffs of this caching approach" | Semantic |
| "should I use [A] or [B]" | "Should I use microservices or monolith?" | Semantic |
| System design questions | "Design a notification system" | Semantic |
| After 2+ failed fix attempts | Escalation for fresh perspective | Heuristic |
| 10+ success criteria | Complex plan requiring architecture | Heuristic |

### Plan Validation (→ Plan Reviewer)

| Intent Pattern | Example | Trigger Type |
|----------------|---------|--------------|
| "review this plan" | "Review my migration plan" | Explicit |
| "is this plan complete" | "Is this implementation plan complete?" | Explicit |
| "validate before I start" | "Validate my approach before starting" | Semantic |
| Before significant work | Pre-execution validation | Heuristic |
| 5+ success criteria | Large plan review | Heuristic |

### Requirements Analysis (→ Scope Analyst)

| Intent Pattern | Example | Trigger Type |
|----------------|---------|--------------|
| "what am I missing" | "What am I missing in these requirements?" | Semantic |
| "clarify the scope" | "Help clarify the scope of this feature" | Semantic |
| Vague or ambiguous requests | Before planning unclear work | Heuristic |
| "before we start" | Pre-planning consultation | Semantic |
| No success criteria | Ambiguity score >= 0.5 | Heuristic |

### Code Review (→ Code Reviewer)

| Intent Pattern | Example | Trigger Type |
|----------------|---------|--------------|
| "review this code" | "Review this PR" | Explicit |
| "find issues in" | "Find issues in this implementation" | Semantic |
| "what's wrong with" | "What's wrong with this function?" | Semantic |
| After implementing features | Self-review before merge | Heuristic |
| "use proactively" in description | Automatic delegation | Description-based |

### Security (→ Security Analyst)

| Intent Pattern | Example | Trigger Type |
|----------------|---------|--------------|
| "security implications" | "Security implications of this auth flow" | Semantic |
| "is this secure" | "Is this token handling secure?" | Semantic |
| "vulnerabilities in" | "Any vulnerabilities in this code?" | Semantic |
| "threat model" | "Threat model for this API" | Semantic |
| "harden this" | "Harden this endpoint" | Semantic |
| Auth/credential keywords | Risk score >= 0.4 | Heuristic |

---

## Trigger Priority

1. **Explicit user request** - Always honor direct requests (keyword triggers)
2. **Security concerns** - When handling sensitive data/auth (heuristic)
3. **Architecture decisions** - System design with long-term impact (heuristic)
4. **Failure escalation** - After 2+ failed attempts (heuristic)
5. **Description-based** - Agent task matching (automatic)
6. **Don't delegate** - Default: handle directly

---

## When NOT to Delegate

| Situation | Reason |
|-----------|--------|
| Simple syntax questions | Answer directly |
| Direct file operations | No external insight needed |
| Trivial bug fixes | Obvious solution |
| Research/documentation | Use other tools |
| First attempt at any fix | Try yourself first |

---

## Advisory vs Implementation Mode

Any expert can operate in two modes:

| Mode | Sandbox | When to Use |
|------|---------|-------------|
| **Advisory** | `read-only` | Analysis, recommendations, review verdicts |
| **Implementation** | `workspace-write` | Actually making changes, fixing issues |

Set the sandbox based on what the task requires, not the expert type.

**Examples:**

```bash
# Architect analyzing (advisory)
.claude/scripts/codex-sync.sh "read-only" "You are a software architect...
TASK: Analyze tradeoffs of Redis vs in-memory caching.
EXPECTED OUTCOME: Clear recommendation with rationale.
CONTEXT: [user's situation, full details]
..."

# Architect implementing (implementation)
.claude/scripts/codex-sync.sh "workspace-write" "You are a software architect...
TASK: Refactor the caching layer to use Redis.
EXPECTED OUTCOME: Working Redis integration.
CONTEXT: [relevant code snippets]
..."

# Security Analyst reviewing (advisory)
.claude/scripts/codex-sync.sh "read-only" "You are a security engineer...
TASK: Review this auth flow for vulnerabilities.
EXPECTED OUTCOME: Vulnerability report with risk rating.
CONTEXT: [auth flow code]
..."

# Security Analyst hardening (implementation)
.claude/scripts/codex-sync.sh "workspace-write" "You are a security engineer...
TASK: Fix the SQL injection vulnerability in user.ts.
EXPECTED OUTCOME: Secure code with parameterized queries.
CONTEXT: [vulnerable code snippet]
..."
```
