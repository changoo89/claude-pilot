# Codex Integration (v4.1.0)

> **Last Updated**: 2026-01-18
> **Purpose**: Intelligent GPT delegation for high-difficulty analysis

---

## Overview

**Intelligent GPT Delegation**: Context-aware, autonomous delegation via `codex-sync.sh` for high-difficulty analysis.

---

## Delegation Triggers

### Explicit Triggers (Keyword-Based)

- User explicitly requests: "ask GPT", "review architecture"

### Semantic Triggers (Heuristic-Based)

- **Failure-based**: Agent fails 2+ times on same task
- **Ambiguity**: Vague requirements, no success criteria
- **Complexity**: 10+ success criteria, deep dependencies
- **Risk**: Auth/credential keywords, security-sensitive code
- **Progress stagnation**: No meaningful progress in N iterations

### Description-Based (Claude Code Official)

- Agent descriptions with "use proactively" phrase
- Semantic task matching by Claude Code

---

## GPT Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** (progressive escalation) |
| Coder blocked (automatic) | **Architect** (self-assessment) |

---

## Configuration

### Reasoning Effort

**Default**: `medium` (1-2min response)

**Override**:
```bash
export CODEX_REASONING_EFFORT="low|medium|high|xhigh"
```

**Levels**:
- `low`: Fast response (~30s), good for simple questions
- `medium`: Balanced (~1-2min), default for most tasks
- `high`: Deep analysis (~3-5min), for complex problems
- `xhigh`: Maximum reasoning (~5-10min), most thorough but slowest

### Graceful Fallback

If Codex CLI is not installed, the system gracefully falls back to Claude-only analysis with a warning message.

---

## Available Experts

| Expert | Specialty | Prompt File |
|--------|-----------|-------------|
| **Architect** | System design, tradeoffs | `.claude/rules/delegator/prompts/architect.md` |
| **Plan Reviewer** | Plan validation | `.claude/rules/delegator/prompts/plan-reviewer.md` |
| **Scope Analyst** | Requirements analysis | `.claude/rules/delegator/prompts/scope-analyst.md` |
| **Code Reviewer** | Code quality, bugs | `.claude/rules/delegator/prompts/code-reviewer.md` |
| **Security Analyst** | Vulnerabilities, threats | `.claude/rules/delegator/prompts/security-analyst.md` |

---

## Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure, not first

**Pattern**:
```
Attempt 1 → Fail → Retry with Claude
Attempt 2 → Fail → Delegate to GPT Architect
Attempt 3 → (via GPT) → Success
```

---

## See Also

- **@.claude/guides/intelligent-delegation.md** - Full delegation guide
- **@.claude/rules/delegator/orchestration.md** - Orchestration patterns
- **@CLAUDE.md** - Project standards (Tier 1)
