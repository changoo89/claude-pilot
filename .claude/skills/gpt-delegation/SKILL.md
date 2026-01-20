---
name: gpt-delegation
description: Use when blocked, stuck, or needing fresh perspective. Consults GPT experts via Codex CLI with graceful fallback.
---

# SKILL: GPT Delegation

> **Purpose**: Intelligent Codex/GPT consultation for complex problems, escalation when stuck
> **Target**: Orchestrators detecting delegation triggers

---

## Quick Start

### When to Use This Skill
- After 2+ failed attempts on same issue
- Architecture decisions needed
- Security concerns
- Ambiguous requirements
- Plan review for large plans (5+ SCs)

### Quick Reference
```bash
# Check Codex CLI availability
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0
fi

# Delegate to GPT Architect
.claude/scripts/codex-sync.sh "workspace-write" "You are a software architect...

TASK: [One sentence atomic goal]

EXPECTED OUTCOME: [What success looks like]

CONTEXT:
- Previous attempts: [what was tried]
- Errors: [exact error messages]
- Current iteration: [N]

CONSTRAINTS:
- Must work with existing codebase
- Cannot break existing functionality

MUST DO:
- Analyze why previous attempts failed
- Provide fresh approach
- Report all files modified

MUST NOT DO:
- Repeat same approaches that failed

OUTPUT FORMAT:
Summary → Issues identified → Fresh approach → Files modified → Verification"
```

---

## Core Concepts

### Graceful Fallback (CRITICAL)

**MANDATORY**: All GPT delegation points MUST include graceful fallback.

```bash
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0  # NOT an error, continue with Claude
fi
```

**Key Points**:
- Graceful fallback is **NOT** an error
- Log warning message
- Return success (exit 0) to allow continuation
- Continue with Claude agents

### Delegation Triggers

| Trigger | Expert | Mode | When to Delegate |
|---------|--------|------|------------------|
| 2+ failed attempts | Architect | workspace-write | Progressive escalation |
| Stuck on task | Architect | workspace-write | Fresh perspective |
| Architecture decision | Architect | read-only | Design guidance |
| Security concern | Security Analyst | read-only | Vulnerability assessment |
| Ambiguous plan | Scope Analyst | read-only | Requirements clarification |
| Large plan (5+ SCs) | Plan Reviewer | read-only | Plan validation |

### Progressive Escalation

**Principle**: Delegate ONLY after 2nd failure, not first

```
Attempt 1 (Claude) → Fail
     ↓
Attempt 2 (Claude) → Fail
     ↓
Attempt 3 (GPT Architect) → Success
```

**Implementation**:
```bash
if [ $iteration_count -ge 2 ]; then
  # Delegate to GPT
  .claude/scripts/codex-sync.sh "workspace-write" "..."
else
  # Retry with Claude
  echo "Retrying with Claude (iteration $iteration_count)"
fi
```

---

## Expert Specialties

### Architect

**Specialty**: System design, tradeoffs, complex debugging

**When to use**:
- System design decisions
- After 2+ failed fix attempts
- Tradeoff analysis
- Complex debugging

**Output format**:
- Advisory: Bottom line → Action plan → Effort estimate
- Implementation: Summary → Files modified → Verification

### Plan Reviewer

**Specialty**: Plan validation, gap detection

**When to use**:
- Before starting significant work (5+ SCs)
- After creating work plan

**Output format**: APPROVE/REJECT with justification

### Security Analyst

**Specialty**: Vulnerabilities, threat modeling

**When to use**:
- Authentication/authorization changes
- Security-sensitive code

**Output format**: Threat summary → Vulnerabilities → Risk rating

---

## Configuration

### Reasoning Effort

```bash
export CODEX_REASONING_EFFORT="medium"  # low | medium | high | xhigh
```

- **low**: Fast response (~30s), simple questions
- **medium** (default): Balanced (~1-2min)
- **high**: Deep analysis (~3-5min), complex problems
- **xhigh**: Maximum reasoning (~5-10min)

### Model Configuration

```bash
export CODEX_MODEL="gpt-5.2"  # Override model
export CODEX_TIMEOUT="300s"   # Timeout
```

---

## Verification

### Test GPT Delegation
```bash
# Test graceful fallback
command -v codex &> /dev/null || echo "Fallback works"

# Test delegation (if Codex installed)
if command -v codex &> /dev/null; then
  .claude/scripts/codex-sync.sh "read-only" "Test prompt"
fi
```

---

## Related Skills

- **managing-continuation**: State persistence during delegation
- **ralph-loop**: Escalation when blocked (7 iterations)
- **parallel-subagents**: Coordination during parallel execution

---

**Version**: claude-pilot 4.2.0
