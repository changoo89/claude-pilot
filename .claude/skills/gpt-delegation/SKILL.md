---
name: gpt-delegation
description: Use when blocked, stuck, or needing fresh perspective. Consults GPT experts via Codex CLI with graceful fallback.
---

# SKILL: GPT Delegation

> **Purpose**: Intelligent Codex/GPT consultation for complex problems, escalation when stuck

---

## Quick Start

### When to Use

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

# Delegate to GPT Architect (direct codex CLI format)
codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "You are a software architect...
TASK: [One sentence atomic goal]
EXPECTED OUTCOME: [What success looks like]
CONTEXT:
- Previous attempts: [what was tried]
- Errors: [exact error messages]
- Current iteration: [N]

MUST DO:
- Analyze why previous attempts failed
- Provide fresh approach
- Report all files modified"
```

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

### Direct Codex CLI Format (CRITICAL)

**Claude MUST use the correct direct codex CLI format**:

**Correct format**:
- `codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "PROMPT"`
- `codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "PROMPT"`

**Parameters**:
- `-m gpt-5.2`: Use GPT-5.2 model
- `-s workspace-write`: Write mode (implementation) or `-s read-only`: Read-only mode (advisory)
- `-c reasoning_effort=medium`: Set reasoning effort to medium
- `--json`: Output JSON format
- `"PROMPT"`: The delegation prompt text

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

## Expert Mapping

| Expert | Purpose | When | Mode | Output |
|--------|---------|------|------|--------|
| **Architect** | Fresh perspective on implementation | 2+ failures, stuck, architecture | workspace-write | Root cause, fresh approach, files modified |
| **Security Analyst** | Vulnerability assessment | Security concerns, auth, sensitive data | read-only | OWASP findings, severity, fixes |
| **Plan Reviewer** | Plan validation | 5+ SCs, complex deps, high-risk | read-only | Quality (1-10), clarity, feasibility, risks |
| **Scope Analyst** | Requirements clarification | Ambiguous requirements, edge cases | read-only | Ambiguities, assumptions, acceptance criteria |
| **Code Reviewer** | Code quality assessment | Explicit review, quality concerns | read-only | Quality issues, violations, refactoring |

## Integration Pattern

### Coder Agent (Ralph Loop)

```bash
# After 2nd failure
if [ $iteration -ge 2 ] && [ $TEST_RESULT -ne 0 ]; then
  PROMPT="TASK: Fix failing test ${TEST_NAME}
  EXPECTED OUTCOME: All tests pass
  CONTEXT: Previous attempts: ${ATTEMPT_SUMMARY}, Errors: $(cat /tmp/test.log | tail -20)"
  codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "$PROMPT"
fi
```

### /00_plan Command

```bash
# Large plan review
if [ $(echo "$PLAN" | grep -c "SC-") -ge 5 ]; then
  PROMPT="Review plan: $PLAN (Clarity, Completeness, Feasibility, Dependencies, Risks)"
  codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "$PROMPT"
fi
```

## Troubleshooting

### Codex CLI Not Installed

**Symptom**: Warning message about Codex CLI not installed

**Solution**: Expected behavior. Skill gracefully falls back to Claude-only analysis.

### Delegation Not Triggering

**Causes**: 1) Trigger not met (< 2 failures) 2) Skill not loaded 3) Codex check failing

**Debug**: Check `echo $iteration`, verify `grep -r "gpt-delegation" .claude/skills/`, test `command -v codex`

### GPT Returns Same Approach

**Solution**: Document previous attempts clearly with errors and stack traces.

## Best Practices

- **Always include graceful fallback**: Codex CLI may not be installed
- **Document previous attempts clearly**: Include errors, stack traces, code snippets
- **Specify expected outcome**: What does success look like?
- **Use appropriate mode**: workspace-write for code changes, read-only for analysis
- **Parse output carefully**: GPT output format may vary
- **Verify suggestions**: Don't blindly apply GPT recommendations

## Further Reading

**Internal**: @.claude/skills/gpt-delegation/REFERENCE.md - Complete prompt templates, integration examples, troubleshooting | @.claude/skills/ralph-loop/SKILL.md - Ralph Loop integration with GPT delegation

**External**: [Codex Documentation](https://github.com/example/codex)
