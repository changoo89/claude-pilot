# Intelligent Delegation Guide

> **Last Updated**: 2026-01-17
> **Version**: 4.1.0
> **Purpose**: Guide for intelligent, context-aware Codex delegation
> **See**: @.claude/guides/intelligent-delegation-REFERENCE.md for detailed reference

---

## Overview

**Intelligent Delegation System**: Context-aware, autonomous decision-making for Codex GPT delegation

| Aspect | Old (Keyword) | New (Intelligent) |
|--------|---------------|-------------------|
| Trigger detection | `grep -qiE "(tradeoff\|design)"` | Heuristic evaluation |
| Decision-making | Binary | Confidence scoring (0.0-1.0) |
| Escalation | Immediate/never | Progressive (after 2nd failure) |
| Agent autonomy | Manual only | Self-assessment with confidence |

---

## Core Concepts

### 1. Three Trigger Types (Hybrid)

| Type | Pattern | Example |
|------|---------|---------|
| **Explicit** | Keyword-based | "ask GPT", "review architecture" |
| **Semantic** | Heuristic-based | `iteration_count >= 2` AND `<CODER_BLOCKED>` |
| **Description-Based** | Agent semantic matching | "use proactively" in agent description |

### 2. Confidence Scoring

**Scale**: 0.0 to 1.0
- **0.9-1.0**: High confidence - autonomous
- **0.5-0.9**: Medium - consider delegation
- **0.0-0.5**: Low - MUST delegate

**Formula** (Coder example):
```
confidence = base - (failure * 0.2) - (ambiguity * 0.3) - (complexity * 0.1)
```

### 3. Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure

```
Attempt 1 → Fail → Retry (Claude)
Attempt 2 → Fail → Delegate (GPT Architect)
Attempt 3 → (via GPT) → Success
```

---

## Heuristic Framework (Summary)

| Heuristic | Trigger | Threshold | Expert |
|-----------|--------|-----------|--------|
| **1. Failure-Based** | 2+ fails on same task | `iteration_count >= 2` | Architect |
| **2. Ambiguity** | Vague task description | Score >= 0.5 | Scope Analyst |
| **3. Complexity** | 10+ success criteria | Score >= 0.7 | Architect |
| **4. Risk** | Auth/credential keywords | Score >= 0.4 | Security Analyst |
| **5. Progress** | No progress in N iterations | 7 iterations, <5% coverage | Architect |

**See**: @.claude/rules/delegator/intelligent-triggers.md for detailed algorithms

---

## Claude Code Official Patterns

### Description-Based Routing

**How it works**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase
4. Delegates automatically when task matches

**Agents with "use proactively"**:
- **coder**: Implementation tasks
- **plan-reviewer**: After plan creation
- **code-reviewer**: After code changes

### Long-Running Task Templates

**Feature List JSON**, **Init Script**, **Progress File** - See @.claude/guides/intelligent-delegation-REFERENCE.md

---

## Best Practices

### Cost Awareness
- One well-structured delegation > multiple vague ones
- Include full context (saves retry costs)
- Reserve for high-value tasks (architecture, security, complex)
- Progressive escalation (try Claude first, delegate after 2nd failure)

### Graceful Fallback (MANDATORY)

```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
    return 0
fi
```

### Backward Compatibility
- Maintain existing keyword triggers
- Add heuristic triggers alongside keywords
- Don't break existing workflows

### Confidence Thresholds
- **0.5**: Default threshold (balance)
- **0.7**: High stakes (architecture, security)
- **0.3**: Low stakes (simple refactors)

---

## Verification

**Test Coverage**:
```bash
bash .pilot/tests/test_delegation.test.sh
```

**Expected**: 11/11 tests passing

**Manual Checks**:
```bash
grep -r "use proactively" .claude/agents/*.md  # 3 matches
ls -la .claude/templates/  # feature-list.json, init.sh, progress.md
ls -la .claude/rules/delegator/intelligent-triggers.md  # exists
```

---

## Related Documentation

- **Intelligent Triggers**: @.claude/rules/delegator/intelligent-triggers.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md
- **Pattern Standard**: @.claude/rules/delegator/pattern-standard.md

---

**Version**: claude-pilot 4.1.0 (Intelligent Delegation)
**Last Updated**: 2026-01-17
