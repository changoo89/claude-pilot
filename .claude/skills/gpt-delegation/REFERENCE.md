# REFERENCE: GPT Delegation

> **Detailed patterns, examples, and troubleshooting for Codex/GPT delegation**

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

## Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Security-related code | **Security Analyst** |
| Large plan (5+ SCs) | **Plan Reviewer** |
| Architecture decisions | **Architect** |
| 2+ failed fix attempts | **Architect** (progressive escalation) |
| Coder blocked (automatic) | **Architect** (self-assessment) |

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

## Confidence Scoring

- Scale: 0.0-1.0
- Threshold: <0.5 → MUST delegate
- Formula: `confidence = base - (failures * 0.2) - (ambiguity * 0.3) - (complexity * 0.1)`

---

## Prompt Templates

### Core Structure (All Experts)
```
You are a [role] specializing in [domain].

CONTEXT: [problem description, files, previous attempts]

ANALYSIS REQUIRED: [specific questions or tasks]

OUTPUT FORMAT:
## [Section 1]
## [Section 2]
```

### Expert-Specific Sections

| Expert | Role | Key Sections |
|--------|------|-------------|
| **Architect** | Fix implementation issues | Summary, Issues Identified, Fresh Approach, Files Modified, Verification |
| **Security Analyst** | Find vulnerabilities | Security Findings, Recommendations, Code Examples |
| **Plan Reviewer** | Validate plans | Plan Assessment, Issues Found, Recommendations, Risk Assessment |
| **Scope Analyst** | Clarify requirements | Ambiguities Found, Assumptions, Edge Cases, Acceptance Criteria |

**Usage**: Build prompts dynamically using expert-specific sections above

## Troubleshooting

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Codex CLI Missing** | Warning about CLI not installed | Expected behavior. Gracefully falls back to Claude-only analysis. |
| **Delegation Not Triggering** | GPT Architect not called after 2 failures | Check: (1) iteration count `echo $iteration`, (2) skill loaded `grep gpt-delegation .claude/skills/`, (3) Codex CLI `command -v codex` |
| **Direct codex call fails** | Claude calls `codex --sandbox` directly with wrong options | NEVER call codex CLI directly. Always use `.claude/scripts/codex-sync.sh` wrapper. Correct format: `codex exec -m MODEL -s MODE --json "PROMPT"` |
| **GPT Returns Same Approach** | Same solution already failed | Document previous attempts clearly in prompt with errors and code snippets |

## Integration Examples

### Pattern: Progressive Escalation (Coder Agent)
```bash
# After 2nd failure in Ralph Loop
[ $iteration -ge 2 ] && [ $TEST_RESULT -ne 0 ] && {
  .claude/scripts/codex-sync.sh "workspace-write" "$(build_architect_prompt)"
  npm test
}
```

### Pattern: Large Plan Review
```bash
# After generating plan with 5+ SCs
[ $(echo "$PLAN" | grep -c "SC-") -ge 5 ] && {
  .claude/scripts/codex-sync.sh "read-only" "$(build_plan_reviewer_prompt)"
}
```

## Best Practices

| Practice | Why |
|----------|-----|
| Graceful fallback | Codex CLI may not be installed |
| Document previous attempts | Include errors, stack traces, code snippets |
| Specify expected outcome | Clarify what success looks like |
| Use appropriate mode | workspace-write for code changes, read-only for analysis |
| Parse output carefully | GPT output format may vary |
| Verify suggestions | Don't blindly apply recommendations |

## Further Reading

**Internal**: @.claude/skills/ralph-loop/SKILL.md - Ralph Loop integration with GPT delegation

**External**: [Codex Documentation](https://github.com/example/codex)
